# frozen_string_literal: true

require_relative 'masterpassword'
require 'sqlite3'

class PasswordManager
  attr_reader :master_password

  def initialize(master_password:, new_password: false)
    MasterPassword.store(master_password) if new_password
    @master_password = MasterPassword.new(master_password)

    @DB = SQLite3::Database.new('pw.db')
    @DB.execute <<-SQL
    CREATE TABLE IF NOT EXISTS passwords (
      id INTEGER PRIMARY KEY,
      website TEXT,
      username TEXT,
      enc_password TEXT
      );
      SQL
  end

  def add_password(password)
    @DB.execute("INSERT INTO passwords (website, username, enc_password) VALUES (?, ?, ?)", [password.website, password.username, password.enc_password])
  end
  def get_password(id)
    Password.new_from_db(@DB.execute("SELECT * FROM passwords WHERE id = ?", id))
  end
  def all_passwords
    @DB.execute("SELECT * FROM passwords").map { |row| Password.new_from_db(row) }
  end
end
