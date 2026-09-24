# frozen_string_literal: true

require_relative 'masterpassword'
require 'sqlite3'

# PasswordManager class to store and handle passwords in an sql database for retrieval
class PasswordManager
  attr_reader :master_password

  def initialize(master_password:, new_password: false)
    MasterPassword.store(master_password) if new_password
    @master_password = MasterPassword.new(master_password)

    # Create and setup the SQL database to store password data
    @database = SQLite3::Database.new('pw.db')
    create_database_table
  end

  # Create SQL database table for passwords
  def create_database_table
    @database.execute <<-SQL
    CREATE TABLE IF NOT EXISTS passwords (
      id INTEGER PRIMARY KEY,
      website TEXT,
      username TEXT,
      enc_password TEXT
      );
    SQL
  end

  # Insert new instance of a password into the database
  def add_password(password)
    @database.execute('INSERT INTO passwords (website, username, enc_password) VALUES (?, ?, ?)',
                      [password.website, password.username, password.enc_password])
  end

  # Get password by ID from database
  def get_password(id)
    #db_row = @database.execute('SELECT * FROM passwords WHERE id = ?', id).first
    #pw = Password.new(db_row[1], db_row[2])
    #pw.enc_password = db_row[3]
    #pw.id = db_row[0]
    #return pw
    Password.new_from_db(@database.execute('SELECT * FROM passwords WHERE id = ?', id).first)
  end

  # Get passwords for specific website
  def get_passwords_for(site)
    @database.execute('SELECT * FROM passwords WHERE website = ?', site).map { |row| Password.new_from_db(row) }
  end

  # Get all passwords from database
  def all_passwords
    all_pw = @database.execute('SELECT * FROM passwords')
    pws = all_pw.map { |row| Password.new_from_db(row) }
    return pws
  end

  # Delete specific instance of Password from db
  def delete_password(password)
    # TODO: delete password from database
  end
end
