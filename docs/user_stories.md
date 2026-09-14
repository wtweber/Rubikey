## User stories

## User Story 1
* 5 Points
* As a user, I want to store a password in a secure format for a website so that I can recall it later at any time.
* **Acceptance Criteria**
    * Test Cases
	    * Receive empty password string, return error.
	    * Receive password string and master password, expect encrypted string

## User Story 2
* 3 Points
* As a user, I want to retrieve a stored password for a website so that I can login to that website.
* **Acceptance Criteria**
    * Test Cases
        * Using master password, decrypt password string
	    * Using incorrect password, try to decrypt password, expect error

## User Story 3
* 5 Points
* As a user, I want to search for a stored password by using the website name or URL so that I can login to that website.
* **Acceptance Criteria**
    * Test Cases
        * Start with nothing, search for X, expect X to be not found
	    * Search for X website, expect X website’s password to be returned

## User Story 4
* 3 Points
* As a user, I want to be able to set a master password such that I can encrypt my regular passwords.
* **Acceptance Criteria**
    * Test Cases
        * Accept master password, generate password hash for storage, expect string
	    * Receive empty string, return error.

## User Story 5
* 8 Points
* As a user, I want to be able to change the master password in case I accidentally used that password elsewhere, and want to re-secure this application with a new one.
* **Acceptance Criteria**
    * Test Cases
        * Receive incorrect password, expect error.
	    * Compare X password hash to current password hash, expect success
	    * Use password to re-encrypt stored passwords, expect success

## User Story 6
* 3 Points
* As a user, I want to delete a stored password so that I do not store unnecessary passwords for websites I don't use anymore.
* **Acceptance Criteria**
    * Test Cases
        * Prompt for confirmation (y/n)
            * If yes, result is password deleted
            * If no, exit deleting password


## User Story 7
* 3 Points
* As a user, I want to display a list of all websites that I have a password for so that I don't have to search for the website, I can just search the list.
* **Acceptance Criteria**
    * Test Cases
        * Display no passwords if there are none currently stored
            * (Empty list)

## User Story 8
* 5 Points
* As a user, I want to be able to generate a complex password from the application itself so that I do not need to make it myself.
* **Acceptance Criteria**
    * Test Cases
        * Generate new password, expect new password string

## User Story 9
* 3 Points
* As a user, I want the application to deny access to my passwords if I do not know the master password, such that my passwords remain secure from an invalid access. (Sad path)
* **Acceptance Criteria**
    * Test Cases
        * Receive incorrect password, expect error.

## User Story 10
* 3 Points
* As a user, I want the application to require re-inputting the master password each time the app is closed -> re-opened, such that my passwords cannot be accessed by someone else if I accessed them before. (Sad path)
* **Acceptance Criteria**
    * Test Cases
        * Receive incorrect password, expect error.