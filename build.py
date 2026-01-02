#!/usr/bin/env python3

from __future__ import annotations

import re
import shutil
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent
DIST_DIR = REPO_ROOT / "dist"
PARTIALS_DIR = REPO_ROOT / "partials"


@dataclass(frozen=True)
class Variant:
    slug: str  # "" | "dark" | "atkinson" | "dark-atkinson"
    theme: str  # "light" | "dark"
    font: str  # "default" | "atkinson"

    @property
    def out_dir(self) -> Path:
        return DIST_DIR if self.slug == "" else (DIST_DIR / self.slug)

    @property
    def base_path(self) -> str:
        return "" if self.slug == "" else f"/{self.slug}"


VARIANTS: list[Variant] = [
    Variant(slug="", theme="light", font="default"),
    Variant(slug="dark", theme="dark", font="default"),
    Variant(slug="atkinson", theme="light", font="atkinson"),
    Variant(slug="dark-atkinson", theme="dark", font="atkinson"),
]


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _write_text(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8", newline="\n")


def _render_template(template: str, values: dict[str, str]) -> str:
    rendered = template
    for key, value in values.items():
        rendered = rendered.replace(f"{{{{{key}}}}}", value)
    return rendered


def _set_html_attributes(html: str, *, theme: str, font: str) -> str:
    # Insert/replace data-theme and data-font on the <html ...> tag.
    def repl(match: re.Match[str]) -> str:
        tag = match.group(0)

        def upsert_attr(tag_text: str, name: str, value: str) -> str:
            if re.search(rf"\b{name}=\"[^\"]*\"", tag_text):
                return re.sub(rf"\b{name}=\"[^\"]*\"", f'{name}="{value}"', tag_text)
            # insert before closing '>'
            return tag_text[:-1] + f' {name}="{value}">' 

        tag = upsert_attr(tag, "data-theme", theme)
        if font == "atkinson":
            tag = upsert_attr(tag, "data-font", "atkinson")
        else:
            # Remove data-font if present to keep output tidy.
            tag = re.sub(r"\sdata-font=\"[^\"]*\"", "", tag)
        return tag

    return re.sub(r"<html\b[^>]*>", repl, html, count=1)


def _replace_secondary_header(html: str, rendered_header: str) -> str:
    # Replace the first <section class="secondarypagetitle"> ... </section>
    pattern = re.compile(
        r"<section\s+class=\"secondarypagetitle\"[^>]*>.*?</section>",
        re.DOTALL,
    )
    return pattern.sub(rendered_header, html, count=1)


def _replace_index_nav(html: str, rendered_nav: str) -> str:
    # Replace the first <nav>...</nav> inside the maintitle section.
    # This is intentionally narrow to avoid touching other navs.
    pattern = re.compile(
        r"(<section\s+class=\"maintitle\"[^>]*>.*?)(<nav>.*?</nav>)",
        re.DOTALL,
    )

    match = pattern.search(html)
    if not match:
        return html

    before = match.group(1)
    return pattern.sub(before + rendered_nav, html, count=1)


def _rewrite_stylesheet_href(html: str, *, base_path: str) -> str:
    css_href = "/style.css" if base_path == "" else f"{base_path}/style.css"
    return re.sub(r'href="(?:/)?style\.css"', f'href="{css_href}"', html)


def _current_attr(enabled: bool) -> str:
    return 'aria-current="page"' if enabled else ""


def _build_header_context(*, variant: Variant, page_name: str, title: str) -> dict[str, str]:
    base = variant.base_path
    # Map desired targets
    base_light = ""  # light + default
    base_dark = "/dark"
    base_font_default = "" if variant.theme == "light" else "/dark"
    base_font_atkinson = "/atkinson" if variant.theme == "light" else "/dark-atkinson"

    # Current path within a variant
    path = "/" if page_name == "index" else f"/{page_name}/"

    return {
        "TITLE": title,
        "BASE": base,
        "PATH": path,
        "BASE_LIGHT": base_light,
        "BASE_DARK": base_dark,
        "BASE_FONT_DEFAULT": base_font_default,
        "BASE_FONT_ATKINSON": base_font_atkinson,
        "CURRENT_LINKS": _current_attr(page_name == "links"),
        "CURRENT_EXPERIENCES": _current_attr(page_name == "experiences"),
        "CURRENT_PROJECTS": _current_attr(page_name == "projects"),
        "CURRENT_THEME_LIGHT": _current_attr(variant.theme == "light"),
        "CURRENT_THEME_DARK": _current_attr(variant.theme == "dark"),
        "CURRENT_FONT_DEFAULT": _current_attr(variant.font == "default"),
        "CURRENT_FONT_ATKINSON": _current_attr(variant.font == "atkinson"),
    }


def _copy_repo_to_variant(variant: Variant) -> None:
    out_dir = variant.out_dir
    if out_dir.exists():
        shutil.rmtree(out_dir)

    def ignore(_dir: str, names: list[str]) -> set[str]:
        ignored = {
            ".git",
            ".github",
            ".venv",
            ".gitignore",
            "build.py",
            "partials",
            "dist",
            "node_modules",
            "__pycache__",
        }
        return {n for n in names if n in ignored}

    shutil.copytree(REPO_ROOT, out_dir, ignore=ignore)


def _process_variant_html(variant: Variant) -> None:
    secondary_template = _read_text(PARTIALS_DIR / "secondary-header.html")
    index_nav_template = _read_text(PARTIALS_DIR / "index-nav.html")

    pages: dict[str, dict[str, str]] = {
        "index": {"path": "index.html", "title": "KellyNyanbinary"},
        "links": {"path": "links.html", "title": "KellyNyanbinary"},
        "experiences": {"path": "experiences.html", "title": "KellyNyanbinary"},
        "projects": {"path": "projects.html", "title": "KellyNyanbinary"},
        "404": {"path": "404.html", "title": "404"},
    }

    for page_name, meta in pages.items():
        file_path = variant.out_dir / meta["path"]
        if not file_path.exists():
            continue

        html = _read_text(file_path)
        html = _set_html_attributes(html, theme=variant.theme, font=variant.font)
        html = _rewrite_stylesheet_href(html, base_path=variant.base_path)

        if page_name == "index":
            ctx = _build_header_context(variant=variant, page_name="index", title=meta["title"])
            rendered_nav = _render_template(index_nav_template, ctx)
            html = _replace_index_nav(html, rendered_nav)
        else:
            ctx = _build_header_context(
                variant=variant,
                page_name=page_name,
                title=meta["title"],
            )
            rendered_header = _render_template(secondary_template, ctx)
            html = _replace_secondary_header(html, rendered_header)

        _write_text(file_path, html)

        # Generate directory-style URLs: /links/ -> /links/index.html
        # This makes extensionless routes work on GitHub Pages and in local servers.
        if page_name != "index":
            out_dir = variant.out_dir / page_name
            out_dir.mkdir(parents=True, exist_ok=True)
            _write_text(out_dir / "index.html", html)


def main() -> None:
    if not PARTIALS_DIR.exists():
        raise SystemExit("partials/ directory not found")

    DIST_DIR.mkdir(exist_ok=True)

    for variant in VARIANTS:
        _copy_repo_to_variant(variant)
        _process_variant_html(variant)

    print(f"Built {len(VARIANTS)} variants into {DIST_DIR}")


if __name__ == "__main__":
    main()
