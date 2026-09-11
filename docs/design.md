## Design

* Password_Manager class
    * master_password of type Master_Password
    * passwords aray of [Passwords]

    * add_password(Password) adds a password to the database
    * remove_password(Password) removes the password from the database
    * retrieve_passsword(website_string) returns a password with exact match to website
    * search_passwords(string) returns any passwords with string in website field

* Master_Password class
    * id of type int
    * password_hash of type string
    * salt of type string
    * timestamps

* Password class
    * id of type int
    * website of type string
    * username of type string
    * password of type string (encrypted)
    * timestamps

* Folder class
    * id of type int
    * name of type string
    * passwords aray of ids matching passwords

## UI Design Mockup
![Basic UI design](../images/UI_Mockup.png)
