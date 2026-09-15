# frozen_string_literal: true

require_relative 'masterpassword'

class PasswordManager
  attr_reader :master_password, :passwords

  def initialize(master_password:, new_password: false)
    MasterPassword.store(master_password) if new_password
    @master_password = MasterPassword.new(master_password)
  end
end
