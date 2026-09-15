# frozen_string_literal: true

# Modules
require_relative 'rubikey/terminal'
require_relative 'rubikey/vars'
require_relative 'rubikey/dialogue'
require_relative 'rubikey/cipher'
require_relative 'rubikey/password'
require_relative 'rubikey/masterpassword'
require_relative 'rubikey/passwordmanager'

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
