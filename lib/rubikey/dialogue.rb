# frozen_string_literal: true

# Modules
require_relative 'vars'

module Rubikey
  module Dialogue
    def self.welcome_message
      [
        TextColor::BOLD + "//////////////////////////////////////////////////////////\n",
        TextColor::GREEN + '                   Welcome to ',
        TextColor::RED + TextColor::BOLD + "Rubikey.\n",
        TextColor::BOLD + "//////////////////////////////////////////////////////////\n"
      ]
    end

    def self.first_time_message
      [
        TextColor::GREEN + "This is the first time you have used this application.\n",
        TextColor::GREEN + 'In order to secure your passwords, we require that you create a ',
        TextColor::YELLOW + TextColor::BOLD + 'master password.',
        "\n"
      ]
    end

    def self.create_master_password_prompt
      [
        TextColor::GREEN + 'Create a new ',
        TextColor::YELLOW + TextColor::BOLD + 'master password:'
      ]
    end

    def self.confirm_master_password_prompt
      [
        TextColor::GREEN + 'Confirm the new ',
        TextColor::YELLOW + TextColor::BOLD + 'master password:'
      ]
    end

    def self.passwords_do_not_match
      [
        TextColor::RED + "\nPasswords do not match. Please try again.\n"
      ]
    end

    def self.enter_master_password_prompt
      [
        TextColor::GREEN + 'Enter your ',
        TextColor::YELLOW + TextColor::BOLD + 'master password:'
      ]
    end

    def self.incorrect_password_prompt
      [
        TextColor::RED + "Incorrect Password. Please try again...\n\n",
        TextColor::GREEN + 'Enter your ',
        TextColor::YELLOW + TextColor::BOLD + 'master password:'
      ]
    end

    def self.too_many_failed_attempts
      [
        TextColor::RED + 'Too many failed attempts, exiting Rubikey.'
      ]
    end

    def self.main_menu
      [
        TextColor::GREEN + "\nMain menu\n",
        TextColor::GREEN + "1. New password\n",
        TextColor::GREEN + "2. Show passwords\n",
        TextColor::GREEN + "3. Search\n",
        TextColor::GREEN + "4. Options\n\n",
        TextColor::YELLOW + TextColor::BOLD + 'Select an option:'
      ]
    end

    def self.new_password_website
      [
        TextColor::GREEN + "\nNew password\n",
        TextColor::YELLOW + TextColor::BOLD + 'Enter the website:'
      ]
    end

    def self.new_password_username
      [
        TextColor::YELLOW + TextColor::BOLD + 'username:'
      ]
    end

    def self.new_password_username
      [
        TextColor::YELLOW + TextColor::BOLD + 'Would you like to generate a password:'
      ]
    end
  end
end
