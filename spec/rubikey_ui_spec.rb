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

      password_manager = Rubikey.first_timer
      password_manager.close

      expect(File).to exist('mp.hash')
      expect(MasterPassword.set?).to be true
    end

    it 'creates a master password that can be used to authenticate' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('masterPassword', 'masterPassword')

      password_manager = Rubikey.first_timer
      password_manager.close
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
        password_manager = Rubikey.first_timer
        password_manager.close
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

      password_manager = Rubikey.second_timer
      password_manager.close
    end

    it 'asks for the password again after an incorrect password' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('wrongPassword', 'masterPassword')

      expect(Rubikey::Terminal).to receive(:password_prompt).twice

      password_manager = Rubikey.second_timer
      password_manager.close
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
end
