# frozen_string_literal: true

require_relative 'cipher'

# Stores website info and encrypts passwords using a master master password for later decryption.
class Password
  attr_reader :id, :website, :username, :enc_password

  # Initialization of a password object without the encrypted data
  def initialize(website, username)
    raise ArgumentError, 'Website can not be empty' if website.empty?
    raise ArgumentError, 'Username can not be empty' if username.empty?

    @website = website
    @username = username
  end

  def ==(other)
    conditions = [
      self.class == other.class,
      website == other.website,
      username == other.username,
      enc_password == other.enc_password
    ]
    conditions.all
  end

  # Initilization of a password from the sql row returned from the stored db
  def self.new_from_db(row)
    new(row[1], row[2])
    @enc_password = row[3]
    @id = row[0]
    self
  end

  def website=(new_website)
    raise ArgumentError, 'Website can not be empty' if new_website.empty?

    @website = new_website
  end

  def username=(new_username)
    raise ArgumentError, 'Username can not be empty' if new_username.empty?

    @username = newusername
  end

  # Encrypt and store new password
  def update_password(new_password, master_password)
    raise ArgumentError, 'Password can not be empty' if new_password.empty?

    @enc_password = PasswordCipher.encrypt(new_password, master_password)
  end

  # Decrypt stored pasword data using master password
  def get_password(master_password)
    PasswordCipher.decrypt(@enc_password, master_password)
  end
end
