# frozen_string_literal: true

# Modules
require_relative 'rubikey/terminal'
require_relative 'rubikey/vars'
require_relative 'rubikey/dialogue'
require_relative 'rubikey/cipher'
require 'bcrypt'
require 'openssl'
require 'base64'
require 'json'

module Rubikey
  def self.run
    Terminal.output(*Dialogue.welcome_message)

    @password_manager = MasterPassword.set? ? second_timer : first_timer

    main_menu
  end

  def self.first_timer
    Terminal.output(*Dialogue.first_time_message)

    master_password = first_time_loop

    PasswordManager.new(master_password, true)
  end

  def self.first_time_loop
    loop do
      master_password = Terminal.password_prompt(*Dialogue.create_master_password_prompt)

      master_password_confirm = Terminal.password_prompt(*Dialogue.confirm_master_password_prompt)

      return master_password if master_password == master_password_confirm

      Terminal.output(*Dialogue.passwords_do_not_match)
    end
  end

  def self.second_timer
    master_password = Terminal.password_prompt(*Dialogue.enter_master_password_prompt)
    begin
      PasswordManager.new(master_password)
    rescue StandardError
      master_password = Terminal.password_prompt(*Dialogue.incorrect_password_prompt)
      begin
        PasswordManager.new(master_password)
      rescue StandardError
        Terminal.output(*Dialogue.too_many_failed_attempts)
        exit
      end
    end
  end

  def self.main_menu
    Terminal.clear
    Terminal.prompt(*Dialogue.main_menu)
  end
end

class PasswordManager
  attr_reader :master_password, :passwords

  def initialize(master_password, new_password = false)
    MasterPassword.store(master_password) if new_password
    @master_password = MasterPassword.new(master_password)
  end
end

class Password
  attr_reader :website, :username, :enc_password

  def initialize(website, username, password, master_password)
    raise ArgumentError, 'Website can not be empty' if website.empty?
    raise ArgumentError, 'Username can not be empty' if username.empty?
    raise ArgumentError, 'Password can not be empty' if password.empty?

    @website = website
    @username = username
    @enc_password = PasswordCipher.encrypt(password, master_password)
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

class MasterPassword
  attr_reader :password

  def initialize(password)
    begin
      stored_hash = File.read('mp.hash')
    rescue StandardError
      raise ArgumentError, 'Master Password has not been set.'
    end
    raise ArgumentError, 'Master Password does not match.' unless BCrypt::Password.new(stored_hash) == password

    @password = password
  end

  def update(new_password)
    # TODO: update the master password and reencrypt all saved passwords.
  end

  def self.store(password)
    File.write('mp.hash', BCrypt::Password.create(password))
  end

  def self.set?
    File.exist?('mp.hash')
  end
end

