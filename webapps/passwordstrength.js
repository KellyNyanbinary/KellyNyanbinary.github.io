document.addEventListener("DOMContentLoaded", calculateStrength);

function calculateStrength() {
    const passwordInput = document.getElementById("password");
    const characterMessage = document.getElementById("password-characters");
    const strengthMessage = document.getElementById("password-strength");

    passwordInput.addEventListener("input", function() {
        const password = passwordInput.value;
        const baseRatePerYear = 500000 * 3600 * 24 * 365.25  // guesses per second, taken from https://openbenchmarking.org/test/pts/john-the-ripper for a single high end server in 2025
        const yearsToDouble = 2 // Moore's Law

        let rangeSize = 0
        let characterText = ""

        if (/[a-z]/g.test(password)) {
            rangeSize += 26
            characterText += "Lowercase letters &#9989;<br>"
        } else
            characterText += "Lowercase letters &#10060;<br>"

        if (/[A-Z]/g.test(password)) {
            rangeSize += 26
            characterText += "Uppercase letters &#9989;<br>"
        } else
            characterText += "Uppercase letters &#10060;<br>"

        if (/[0-9]/g.test(password)) {
            rangeSize += 10
            characterText += "Numerical digits &#9989;<br>"
        } else
            characterText += "Numerical digits &#10060;<br>"

        if (/[\x20-\x2F]|[\x3A-\x40]|[\x5B-\x60]|[\x7B-\x7E]/g.test(password)) {
            rangeSize += 33
            characterText += "Special characters &#9989;<br>"
        } else
            characterText += "Special characters &#10060;<br>"

        characterMessage.innerHTML = characterText

        // Validate password characters.
        if (password.length == 0) {
            strengthMessage.innerHTML = "Enter a password to see expected time to guess."
            return
        }

        // Validate password characters.
        if (!isValidPasswordChars(password)) {
            strengthMessage.innerHTML = "Password must contain only ASCII letters and punctuation.";
            return
        }

        const possibilities = rangeSize ** password.length
        const entropy = password.length * Math.log2(rangeSize)

        const possibilitiesText = "There are " + possibilities.toExponential(3) + " possibilities."
        const rangeSizeText = "The range size is " + rangeSize + " characters."

        // This is Wolfram Alpha's result.
        const yearsToGuess = yearsToDouble * 1.4427 * Math.log(
            (0.3465735 * possibilities) / (baseRatePerYear * yearsToDouble) + 1
        )

        const yearText = yearsToGuess.toFixed(0) == "1" ? "year" : "years"
        const yearsToGuessText = "It is expected to take " + yearsToGuess.toFixed(0) + " " + yearText + " to guess this password."

        if (yearsToGuess < 0) {
            strengthMessage.innerHTML = rangeSizeText + "<br>" + possibilitiesText + "<br>" + "Password is too short and can be guessed in under a year."
        } else {
            strengthMessage.innerHTML = rangeSizeText + "<br>" + possibilitiesText + "<br>" + yearsToGuessText
        }
    });
}

// This regex allows uppercase/lowercase letters and punctuation characters in these ranges:
// ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
// There should be 26 + 26 + 10 + 32 + 1 = 95 valid characters.
function isValidPasswordChars(password) {
    return /^(?:[\x20-\x7E])+$/g.test(password);
}
