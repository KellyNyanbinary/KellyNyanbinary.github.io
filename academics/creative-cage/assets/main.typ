#set text(
  font: "Inter",
  // size: 9pt,
)
#set page(
  paper: "us-letter",
  numbering: "1 / 1",
  number-align: top + right,
)
#set par(
  first-line-indent: (amount: 0.5in, all: true),
  leading: 0.65*2em,
  spacing: 0.65*2em
)
#show heading: set block(below: 0.65*2em)

#import "@preview/plotst:0.2.0": *
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2": plot, chart
#import "@preview/finite:0.5.0": automaton, layout
#import "@preview/algorithmic:1.0.5"
#import algorithmic: algorithm

#import emoji: face

// #show: columns.with(2, gutter: 12pt)

/* Set fonts. */
#show math.equation: set text(font: "Noto Sans Math") 

/* Define colors. */
#let orange = rgb(255, 128, 0)
#let info-callout-background-color = rgb(232, 240, 255)
#let quote-callout-background-color = oklch(90%, 0, 0deg)
#let info-callout-title-color = info-callout-background-color.saturate(100%)
#let quote-callout-title-color = quote-callout-background-color.darken(40%)
#let code-block-background-color = luma(248)

/* Define corner radius. */
#let medium-corner-radius = 4pt
#let small-corner-radius = 2pt

/* Set list markers. */
#set list(marker: (sym.bullet, sym.bullet, sym.bullet, sym.bullet, sym.bullet))

/* Add a horizontal rule under headings. */
#show heading: it => {
  // Only apply this to heading level 1. To apply to more, do (1, 2, ...)
  if it.level in (1, 2) {
    show: heading => stack(
      spacing: 0.4em,
      it, 
      line(
        length: if it.level == 2 {
          measure(it).width
        } else { 100% },
        stroke: (
          thickness: 2pt,
          paint: orange.lighten(50%),
          cap: "round"
        )
      ) + v(-0.2em)
    )
  } else {
    it
  }
}

#set footnote.entry(
  separator: line(
    length: 100%,
    stroke: (
      thickness: 2pt,
      paint: orange.lighten(50%),
      cap: "round"
    )
  )
)

#show footnote.entry: it => {
  let loc = it.note.location()
  grid(
    columns: (2em, auto),
    [
      #align(right)[
        #numbering(
          "1. ",
          ..counter(footnote).at(loc),
        )
      ]
    ],
    it.note.body
  )
}

#show bibliography: it => {
  show heading: it => align(center)[#it]
  set par(
    first-line-indent: (amount: 0in, all: true),
    hanging-indent: 1in,
    leading: 0.65*1em,
    spacing: 0.65*2em
  )
  it
}

#show link: it => text(fill: orange.darken(10%), it)
#show "https://doi.org/": it => text(fill: orange.darken(10%), it)

#let callout(body, title: "Callout", fill: blue, title-color: white, body-color: black, icon: none) = {
  set par(
    first-line-indent: 0em,
    hanging-indent: 0em,
    leading: 0.65em,
    spacing: 0.65*2em
  )
  block(
    fill: fill,
    width: 100%,
    inset: 16pt,
    radius: medium-corner-radius,
    above: 0.65em*2,
    below: 0.65em*2,
  )[
    === #text(title-color)[#icon #title]
    #text(body-color)[
      #body
    ]
  ]
}

#let info(body, title: "Info") = callout(
  title: title,
  fill: info-callout-background-color,
  title-color: info-callout-title-color,
  icon: "🛈"
)[#body]

#show quote.where(block: true): it => {
  let attribution = if it.at("attribution") == none [Quote] else {it.at("attribution")}
  callout(
    title: attribution,
    fill: quote-callout-background-color,
    title-color: quote-callout-title-color,
    icon: "❞"
  )[#it.at("body")]
}

/* Add block around code (raw). */
#show raw.where(block: true): it => block(
  width: 100%,
  fill: code-block-background-color,
  inset: 12pt,
  radius: medium-corner-radius,
  it,
)

#show raw.where(block: false): it => box(
  fill: code-block-background-color,
  inset: (x: 2pt),
  outset: (y: 4pt),
  radius: 2pt,
  it,
)

#show math.equation: set block(breakable: true)

#show math.equation: it => {
  show smallcaps: set text(font: "Inter")
  it
}

/* Define math functions. */
#let innerproduct(x, y) = $lr(angle.l #x, #y angle.r)$
#let expect(x) = $upright(E)[#x]$
#let var(x) = $"Var"[#x]$
#let cov(x, y) = $"Cov"[#x, #y]$
#let uniform(mu, sigma) = $"Uniform"(#mu, #sigma)$
#let normal(mu, sigma) = $cal(N)(#mu, #sigma)$
#let permutation(n, r) = $attach(P, bl: #n, br: #r)$
#let combination(n, r) = $attach(C, bl: #n, br: #r)$
#let bigunion = $union.big #h(1.5pt)$
/* Trying to make a position macro thing. It doesn't work. */
// #let position(pos, color, name) = {
//   circle(pos, stroke: color, fill: color, radius: 0.05pt)
//   content((), text(color, name), anchor: "west")
// }

// /*
= Preface
All communication excerpts are fictionalized. Real events (such as Adobe transitioning to Creative Cloud) are historical anchors only. The emotional and personal narrative is fictional. Academic references are cited to contextualize major economic and cultural shifts described in the story.

The final result will be a website written from scratch in HTML, CSS, and JS. The quotes in this document will be reproduced to match the contemporary web UI.

= San Jose, May 7, 2012@adobe-announces-cs6
The smell of cardboard and static hung in the air. Pallets of Adobe Creative Suite 6 physical media disc packages sat in rows like a warehouse museum exhibit. Mei Zhang walked past them on her way in and paused. It reminded her of buying her first copy of Photoshop 7 with money she earned doing small commissions in high school.

She swiped her card and entered the engineering building. Her monitor was covered in sticky notes: compiler flags, bug-tracking IDs, ideas she never had time to finish. When she logged in, a new internal memo sat at the top of her inbox.

#quote(block: true, attribution: "Internal Memo Email")[
  From: Evan Harper \
  To: CS Core Engineering \
  Subject: Transition Plan - Creative Cloud Integration
  
  Team, \
  Beginning Q2, we'll start adapting the CS#footnote[Creative Suite] codebase for subscription-based activation. Product verification will occur through Adobe ID login, with periodic checks every 30-90 days.@adobe-identity-management-services@adobe-internet-connectivity We're sunsetting the boxed distribution model.@adobes-creative-suite-is-dead

  \-Evan
]

Mei stared for a long time. She reread the lines until they blurred. She had worked on rendering optimizations and improvements to the color pipeline. She liked math. She liked art. She did not like locks. They reminded her of limits, of functions hidden behind paywalls, of access granted only to the verified and billable. A lock was something she coded once for trial versions in college, a patchwork of expiration dates and hashing functions. It felt like writing code not to build, but to deny.

= Lunch Table, Later That Week

The cafeteria hummed with the usual chatter. A few engineers scrolled through Hacker News. Mei sat with Rina, a UX researcher.

"Are we really doing this?" Mei asked.

Rina poked at her salad. "They've wanted recurring revenue for years. Finance probably pushed hard this time."

"It's not just revenue," Mei said. "It's access. You lose internet and suddenly the software forgets you paid for it. We're not buying software anymore, we're just renting functionality"@the-end-of-ownership

Rina shrugged. "They'll say ninety days is long enough."

Mei didn't answer. Ninety days sounded like a countdown.

= Internal Discussion Forum, 2013

#quote(block: true, attribution: "Adobe Internal Forum Thread")[
  *Why kill the box?*
  
  MeiZhang: What happens when an artist in rural India loses internet access? Are they locked out of Photoshop?
  
  EHarper: Offline grace period of \~90 days. Practically everyone's online now.
  
  MOrtega: So much for perpetual creativity.
  
  AdobeForumBot: Thread closed by admin. Reason: off-topic.
]

Mei closed the notification. It felt symbolic.

= Public Backlash

The announcement went live on a Monday. Within hours, the backlash came. Reddit. Tumblr. Twitter. Blog posts from frustrated illustrators.

#quote(block: true, attribution: "Blog Post: DeviantArt user "miguel.draws"")[
  "You can't put a price on inspiration, but Adobe sure tries. My art software shouldn't stop working because I forgot to log in."
]

#quote(block: true, attribution: "Tweet @gfx_alan")[
  honestly adobe could turn photoshop into a toaster and ppl would still buy it. but subscriptions?? nah.
]

#quote(block: true, attribution: [Tweet \@DSchoffstall#footnote[Real petition by Derek Schoffstall, fake Tweet referencing it.]])[
  50,000+ signatures and rising. Keep Creative Suite alive. \#Adobe \#NoCloud@eliminate-cc-petition 
]

Mei scrolled through the replies and quote tweets. It wasn't just the volume, it was the precision. Artists citing version downgrades, freelancers calculating long-term costs, and educators asking what would happen if budgets dried up. She felt like she was reading receipts for something she had already known in her gut: this wasn't a rollout, it was a rupture.

A Change.org petition spread quickly. As Macworld reported, users worried they'd be trapped in rent-seeking software pricing with no alternative.@adobe-cc-reactions-responses-reassurance

The petition was followed by a wave of memes: Photoshop icons behind jail bars, Illustrator with a ball and chain. Someone edited a fake ad: "Creativity, now available for monthly rent."

Mei didn't laugh. She felt implicated.

That night, she posted impulsively.

#quote(block: true, attribution: "Tweet @MeiZhang (deleted 3 h later)")[
  When your code becomes the padlock instead of the paintbrush… maybe it's time to stop coding.
]

She deleted it, but not fast enough.

= The Leak

Evan rehearsed his rollout deck in a conference room. Charts flashed: projected revenue, user engagement curves, retention models.

Mei watched silently.

"Any questions?" Evan asked.

"Why hide the offline cutoff?" she said.

"It's not hidden," he said, still smiling. "It's just not... front-facing. It confuses new users."

Mei thought about the artists who stayed offline for months while traveling. The students who only had internet access at libraries. The rural designers with inconsistent broadband.

That night, she sat at her apartment desk. The glow of her secondhand monitor reflected off her glasses. She zipped a folder: `adobe_cloud_prototype.zip`. Inside were interface diagrams, mockups of the activation flow, and a line that bothered her: "If validation fails three cycles, disable essential functions."#footnote[For concerned peer reviewers: this entire section regarding Creative Cloud and afterwards are entirely fictional and not representative of Adobe Inc. or Creative Cloud]

She hesitated. Then she hit upload.

By morning, Reddit was on fire.

#quote(block: true, attribution: "Reddit Post Excerpts")[
  u/PixelProphet: She leaked the real docs. They're seriously planning to shut down the app offline.
  
  u/FOSS4Life: Everyone go download Krita NOW.#footnote[https://krita.org]
  
  u/adobe: These claims contain inaccuracies. Creative Cloud supports extended offline use.
]

= Fallout

Security met her at the door.

"Mei Zhang?"

"Yes."

"Come with us."

She handed over her badge. HR repeated phrases like "breach of confidentiality" and "corporate trust." They didn't sound angry. Just disappointed.

Walking out, Mei looked up at the Adobe logo. She had spent her whole career here. She felt older than she was.

#quote(block: true, attribution: "Press Release Excerpt - Adobe Corporate Communications")[
  Misinformation online misrepresents our vision for innovation.@adobe-identity-management-services Adobe remains committed to delivering cutting-edge creative tools through the cloud. Recent misinformation spread online misrepresents our vision of accessibility and innovation...
]

She didn't read the rest.

= Oakland, Months Later

The workspace smelled like burnt coffee and solder. Miguel typed quickly, his foot tapping.

"We're calling it _Aurora Paint_," he said without looking up.

Mei sat beside him, opening her laptop. "Version control?"

"GitLab. Self-hosted."#footnote[https://about.gitlab.com/install/#install-self-managed-gitlab]

"What's the license?"

"GPLv3," Miguel said. "Always free."#footnote[https://www.gnu.org/licenses/gpl-3.0.en.html]

Mei nodded. The word felt soft. "Perpetual."

They worked quietly. It was a simple life: bug reports, community feedback, occasional donations. Her code felt lighter now: no locks, no timers, no license validation scripts. Just tools.

On the homepage, she wrote:

"_Aurora Paint_ exists because art should not expire. Built by those who once wrote code for locks, now writing keys instead."

= Epilogue

#quote(block: true, attribution: "Medium Post: Mei Zhang, 2014")[
  I didn't leave Adobe because I hated the cloud. I left because I love the sky.

  We used to build the tools that people created with. Then those tools began asking for permission. Subscriptions made sense on paper. They didn't make sense for the soul.

  History will call it a business shift. I'll remember it as the moment creativity learned to wait for confirmation.
]

#pagebreak()
// */

#bibliography("bib.yml", style: "chicago-notes", full: true)

// #bibliography("media.yml", style: "chicago-notes", full: true)