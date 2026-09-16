# frozen_string_literal: true

require_relative 'cipher'

class Password
  attr_reader :id, :website, :username, :enc_password

  def initialize(website, username)
    raise ArgumentError, 'Website can not be empty' if website.empty?
    raise ArgumentError, 'Username can not be empty' if username.empty?

    @website = website
    @username = username
  end

  def self.new_from_db(row)
    self.new(row[1], row[2])
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

  def update_password(new_password, master_password)
    raise ArgumentError, 'Password can not be empty' if new_password.empty?

    @enc_password = PasswordCipher.encrypt(new_password, master_password)
  end

  def get_password(master_password)
    PasswordCipher.decrypt(@enc_password, master_password)
  end
end
