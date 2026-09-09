# Project 1 Proposal
## Team members
* Will Weber
* Caleb Austin
## App name
* Rubikey
## App description
* This app will be a password manager with secure storage and customizable password generation rules. Passwords will be stored in a local database as encrypted strings, allowing for decryption with a user set master password.
## Intended user
* Someone who wants a password manager that doesn't store passwords in the cloud.
## Core features
* Store Password
* Retrieve password
* Generate password
* Search for passwords
* Set master password
* Change master password
## Stretch features
* Organize passwords in folders
* Custom special character set
* Custom number of uppercase or special characters
* Force capitalization and/or numbers
## Main classes/modules
* Master Password class
* Password Manager class
* Password Class
* Folder class
## Test cases
* Store password
	* Receive empty password string, return error.
	* Receive password string and master password, expect encrypted string
* Retrieve password
	* Using master password, decrypt password string
	* Using incorrect password, try to decrypt password, expect error
* Password Generation
	* Generate new password, expect new password string
* Search for passwords
	* Start with nothing, search for X, expect X to be not found
	* Search for X website, expect X website’s password to be returned
* Set master password
	* Accept master password, generate password hash for storage, expect string
	* Receive empty string, return error.
* Change master password
	* Receive incorrect password, expect error.
	* Compare X password hash to current password hash, expect success
	* Use password to re-encrypt stored passwords, expect success
