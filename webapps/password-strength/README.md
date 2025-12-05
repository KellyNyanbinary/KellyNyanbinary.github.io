## Password Strength Checker

This program checks the strength of a password locally and outputs the strength in number of years it will take to crack.

## Installation

The program is a web app and does not require installation. Visit <https://kellynyanbinary.com/webapps/passwordstrength> to use the web app. To use, enter the password into the text entry box.

If you want a local copy,

1. Run `git clone https://github.com/KellyNyanbinary/KellyNyanbinary.github.io.git` in the terminal.
2. Then, `cd KellyNyanbinary.github.io`.
3. Finally, open the file via `open webapps/passwordstrength.html` on macOS or Linux or `start webapps/passwordstrength.html` on Windows.

## Limitations

This program has a hard coded starting cracking rate and a hard coded cracking rate double time scale. It also ignores password cracking techniques such as dictionary lookup. The output of the program is not guaranteed to be correct. Predicting the future correctly is impossible.

## Responsible Use

Do not fully trust the output of the program. See [[README#Limitations|Limitations]]. Misuse is possible by forking the project (or compromising the GitHub repository) and tweaking the parameters to unrealistic values. Misuse is also possible if forks (or the repository) are compromised and the passwords are sent to a server for collection.
