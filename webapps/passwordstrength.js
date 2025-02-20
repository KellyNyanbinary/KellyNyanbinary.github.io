document.addEventListener("DOMContentLoaded", calculateStrength);

function calculateStrength() {
    const passwordInput = document.getElementById("password");
    const strengthMessage = document.getElementById("password-strength");

    passwordInput.addEventListener("input", function() {
        const password = passwordInput.value;
        const baseRatePerYear = 500000 * 3600 * 24 * 365.25  // guesses per second, taken from https://openbenchmarking.org/test/pts/john-the-ripper for a single high end server in 2025

        // Validate password characters.
        if (password.length == 0) {
            strengthMessage.innerHTML = "Enter a password to see time to guess."
        } else if (!isValidPasswordChars(password)) {
            strengthMessage.innerHTML = "Password must contain only ASCII letters and punctuation.";
        } else {
            const possibilities = 95 ** password.length

            // This is Wolfram Alpha's result.
            const yearsToGuess = 2 * 1.4427 * Math.log(
                (0.693146 * possibilities) / baseRatePerYear
            ) - 2

            if (yearsToGuess < 0) {
                strengthMessage.innerHTML = "Password is too short and can be guessed in under a year."
            } else {
                const yearText = yearsToGuess.toFixed(0) == "1" ? "year" : "years"
                strengthMessage.innerHTML =
                    "There are " + possibilities.toExponential(3) + " possibilities.<br>" +
                    "It will take " + yearsToGuess.toFixed(0) + " " + yearText + " to guess this password."
            }
        }
    });
}

// This regex allows uppercase/lowercase letters and punctuation characters in these ranges:
// ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
// There should be 26 + 26 + 10 + 32 + 1 = 95 valid characters.
function isValidPasswordChars(password) {
    return /^(?:[\x20-\x7E])+$/g.test(password);
}
