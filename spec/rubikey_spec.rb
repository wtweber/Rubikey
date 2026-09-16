# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubikey do
  describe '.run' do
    it 'displays the welcome message' do
      allow(MasterPassword).to receive(:set?).and_return(false)
      allow(Rubikey).to receive(:first_timer)
      allow(Rubikey).to receive(:main_menu)

      expect { Rubikey.run }.to output(
        a_string_including('Welcome to ', 'Rubikey.')
      ).to_stdout
    end
  end

  describe '.first_timer' do
    before do
      File.delete('mp.hash') if File.exist?('mp.hash')
    end

    after do
      File.delete('mp.hash') if File.exist?('mp.hash')
    end

    it 'creates a master password when one does not exist' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('masterPassword', 'masterPassword')

      Rubikey.first_timer

      expect(File).to exist('mp.hash')
      expect(MasterPassword.set?).to be true
    end

    it 'creates a master password that can be used to authenticate' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('masterPassword', 'masterPassword')

      Rubikey.first_timer
      expect { MasterPassword.new('masterPassword') }.not_to raise_error
    end

    it 'asks for the password again when the passwords do not match' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return(
        'masterPassword',
        'wrongPassword',
        'masterPassword',
        'masterPassword'
      )

      expect do
        Rubikey.first_timer
      end.to output(
        a_string_including('Passwords do not match. Please try again.')
      ).to_stdout

      expect(MasterPassword.set?).to be true
    end
  end

  describe '.second_timer' do
    before do
      File.delete('mp.hash') if File.exist?('mp.hash')
      MasterPassword.store('masterPassword')
    end

    after do
      File.delete('mp.hash') if File.exist?('mp.hash')
    end

    it 'accepts the correct master password' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('masterPassword')

      expect { Rubikey.second_timer }.not_to raise_error
    end

    it 'asks for the password again after an incorrect password' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('wrongPassword', 'masterPassword')

      expect(Rubikey::Terminal).to receive(:password_prompt).twice

      expect { Rubikey.second_timer }.not_to raise_error
    end

    it 'exits after two incorrect passwords' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return(
        'wrongPassword',
        'wrongPassword'
      )
      allow(Rubikey).to receive(:exit)

      expect { Rubikey.second_timer }.to output(
        a_string_including('Too many failed attempts')
      ).to_stdout
    end
  end

  describe 'Password' do
    it 'should be defined' do
      expect { Password }.not_to raise_error
    end

    describe 'getters and setters' do
      before(:each)  { @password = Password.new('www.google.com', 'userName')
      @password.update_password('password', 'masterpassword')
     }
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
        expect { Password.new('', 'userName') }.to raise_error(ArgumentError)
      end
      it 'should reject invalid user name' do
        expect { Password.new('www.google.com', '') }.to raise_error(ArgumentError)
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
      before(:each) do
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
    it 'should be defined' do
      expect { PasswordManager }.not_to raise_error
    end

    describe 'Passwords' do
      before(:each) { @password_manager = PasswordManager.new }
      it 'should be able to add a password' do
        password = Password.new('www.google.com', 'userName')
        @password_manager.add_password(password)
        expect(@password_manager.passwords).to include(password)
      end
      it 'should be able to remove a password' do
        password = Password.new('www.google.com', 'userName')
        @password_manager.add_password(password)
        @password_manager.remove_password(password)
        expect(@password_manager.passwords).not_to include(password)
      end
      it 'should be able to retrieve a password from the database' do
        password = Password.new('www.google.com', 'userName')
        @password_manager.add_password(password)
        @password_manager = PasswordManager.new
        retrieved_password = @password_manager.retrieve_password(1)
        expect(retrieved_password).to eq(password)
      end
    end
  end
end
