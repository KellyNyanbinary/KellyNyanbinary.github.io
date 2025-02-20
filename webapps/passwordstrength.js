document.addEventListener("DOMContentLoaded", calculateStrength);

function calculateStrength() {
    const passwordInput = document.getElementById("password");
    const strengthMessage = document.getElementById("password-strength");

    passwordInput.addEventListener("input", function() {
        const password = passwordInput.value;
        const baseRatePerSecond = 500000 // guesses per second, taken from https://openbenchmarking.org/test/pts/john-the-ripper for a single high end server in 2025
        const baseRatePerYear = baseRatePerSecond * 3600 * 24 * 365.25 / 1000000000

        // Validate password characters.
        if (password.length == 0) {
            strengthMessage.innerHTML = "Enter a password first to see strength."
        } else if (!isValidPasswordChars(password)) {
            strengthMessage.innerHTML = "Password must contain only ASCII letters and punctuation.";
        } else if (password.length < 4) {
            strengthMessage.innerHTML = "Password is too short."
        } else {
            const possibilities = 95 ** password.length

            // Cumulative guesses are given by integral of (baseRate * 2 ^ (x / 2)) over x
            //const secondsToGuess = -2 + 2 / Math.log(2) * (
            //    Math.log(possibilities * Math.log(2) / baseRate) / Math.log(2)
            //)

            // This is 2 * Wolfram Alpha's result.
            const yearsToGuess = 2 * 1.4427 * Math.log(
                (1.38629 * possibilities - 2 * baseRatePerYear) / baseRatePerYear
            )

            strengthMessage.innerHTML =
                "There are " + possibilities.toExponential(3) + " possibilities.<br>" +
                "It will take " + yearsToGuess.toFixed(0) + " years to guess this password."
        }
    });
}

// This regex allows uppercase/lowercase letters and punctuation characters in these ranges:
// ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
// There should be 26 + 26 + 10 + 32 + 1 = 95
function isValidPasswordChars(password) {
    return /^(?:[\x20-\x7E])+$/g.test(password);
}
