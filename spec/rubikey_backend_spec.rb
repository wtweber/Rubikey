# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubikey do
  #Clean files to allow for tests from initial state
  before do
      File.delete('pw.db') if File.exist?('pw.db')
      File.delete('mp.hash') if File.exist?('mp.hash')
    end
  after do
    File.delete('pw.db') if File.exist?('pw.db')
    File.delete('mp.hash') if File.exist?('mp.hash')
  end

  describe 'Password' do

    it 'should be defined' do
      expect { Password }.not_to raise_error
    end

    describe 'getters and setters' do
      before do
        @password = Password.new(website: 'www.google.com', username: 'userName')
        @password.update_password('password', 'masterpassword')
      end

      it 'should set website' do
        expect(@password.website).to eq('www.google.com')
      end
      it 'should set user name' do
        expect(@password.username).to eq('userName')
      end
      it 'should set password' do
        expect(@password.get_password('masterpassword')).to eq('password')
      end
      it 'should be able to change password' do
        @password.update_password('newPassword', 'masterpassword')
        expect(@password.get_password('masterpassword')).to eq('newPassword')
      end
    end

    describe 'constructor' do
      it 'should reject invalid website' do
        expect { Password.new(website: '', username: 'userName') }.to raise_error(ArgumentError)
      end
      it 'should reject invalid user name' do
        expect { Password.new(website: 'www.google.com', username: '') }.to raise_error(ArgumentError)
      end
      #it 'should reject invalid password' do
      #  expect { Password.new('www.google.com', 'userName', '') }.to raise_error(ArgumentError)
      #end
    end
  end

  describe 'MasterPassword' do
    it 'should be defined' do
      expect { MasterPassword }.not_to raise_error
    end

    describe 'getters and setters' do
      before do
        MasterPassword.store('masterPassword')
        @master_password = MasterPassword.new('masterPassword')
      end

      after do
        File.delete('mp.hash') if File.exist?('mp.hash')
      end

      it 'should set master password' do
        expect(@master_password.password).to eq('masterPassword')
      end
      it 'should fail when incorrect password is input' do
        expect { MasterPassword.new('notTheMasterPassword') }.to raise_error(ArgumentError)
      end
      it 'should be able to change master password' do
        @master_password.update 'newMasterPassword'
        expect(@master_password.password).to eq('newMasterPassword')
      end
    end

    describe 'constructor' do
      it 'should reject invalid master password' do
        expect { MasterPassword.new('') }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'PasswordManager' do
    before do
      @password_manager = PasswordManager.new(master_password: 'masterpassword', new_password: true)
      @password = Password.new(website: 'www.google.com', username: 'userName')
      @password.update_password('password', 'masterpassword')
    end

    it 'should be defined' do
      expect { PasswordManager }.not_to raise_error
    end

    describe 'Passwords' do
      it 'should be able to add a password' do
        pw_count = @password_manager.all_passwords.count
        @password_manager.add_password(@password)
        expect(@password_manager.all_passwords.count == pw_count + 1)
        expect(@password_manager.all_passwords).to include(@password)
      end
      
      it 'should be able to retrieve a password from the database by id' do
        @password_manager.add_password(@password)
        retrieved_password = @password_manager.get_password(1)
        expect(retrieved_password).to be_kind_of(Password)
      end

      it 'should be able to handle an id not found in the database' do
        expect { @password_manager.get_password(100) }.to raise_error(ArgumentError)
      end

      it 'should be able to retrieve passwords from the database by an exact website' do
        @password_manager.add_password(@password)
        retrieved_passwords = @password_manager.get_passwords_for('www.google.com')
        expect(retrieved_passwords.count).to be > 0
      end

      it 'should be able to handle nothing returned for websitte' do
        expect(@password_manager.get_passwords_for('www.unknown_website.com')).to be_empty
      end

      it 'should be able to remove a password' do
        @password_manager.remove_password(password)
        expect(@password_manager.all_passwords).not_to include(password)
      end
    end
  end
end
