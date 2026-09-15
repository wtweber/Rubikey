require 'bcrypt'

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