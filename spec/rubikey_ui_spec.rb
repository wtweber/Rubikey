# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubikey do
  # Clean files to allow for tests from initial state
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

  describe '.main_menu' do
    it 'closes the password manager when q is selected' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('q')

      Rubikey.main_menu

      expect(password_manager).to have_received(:close)
    end

    it 'starts creating a password when option 1 is selected' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('1', 'q')
      expect(Rubikey).to receive(:new_password).and_return(Rubikey::Dialogue.password_saved)

      Rubikey.main_menu
    end

    it 'opens the password list when option 2 is selected' do
      password_manager = instance_double(PasswordManager, close: nil, all_passwords: [])
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('2', 'q')
      expect(Rubikey).to receive(:show_passwords).with(any_args)

      Rubikey.main_menu
    end

    it 'opens the search list when option 3 is selected and a search input is given' do
      password_manager = instance_double(PasswordManager, close: nil, all_passwords: [])
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('3', 'q')
      expect(Rubikey).to receive(:search_site).with([]).and_return([])
      expect(Rubikey).to receive(:show_passwords).with([], select_single: true)

      Rubikey.main_menu
    end

    it 'opens the options when option 4 is selected' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('4', 'q')
      expect(Rubikey).to receive(:options) # .with(anything)

      Rubikey.main_menu
    end

    it 'keeps an invalid-option message above the next menu' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      selections = %w[invalid q]
      allow(Rubikey::Terminal).to receive(:prompt) do |*messages|
        puts messages.join
        selections.shift
      end

      expect { Rubikey.main_menu }.to output(/Invalid option\..*Main menu/m).to_stdout
    end

    it 'keeps the empty-password message above the next menu' do
      password_manager = instance_double(PasswordManager, close: nil, all_passwords: [])
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      selections = %w[2 q]
      allow(Rubikey::Terminal).to receive(:prompt) do |*messages|
        puts messages.join
        selections.shift
      end

      expect { Rubikey.main_menu }.to output(/No passwords saved\..*Main menu/m).to_stdout
    end
  end

  describe '.options' do
    it 'reports an invalid option and returns to the main menu when q is selected' do
      selections = %w[invalid q]
      allow(Rubikey::Terminal).to receive(:prompt) do |*messages|
        puts messages.join
        selections.shift
      end

      expect { Rubikey.options }.to output(/Invalid option\..*Options menu/m).to_stdout
    end

    it 'changes the master password when option 1 is selected' do
      allow(Rubikey::Terminal).to receive(:prompt).and_return('1', 'q')
      expect(Rubikey).to receive(:change_master_password).and_return(Rubikey::Dialogue.password_saved)

      expect { Rubikey.options }.to output(a_string_including('Password saved.')).to_stdout
    end
  end

  describe '.dialogue' do
    it 'provides the unavailable-option message' do
      expect(Rubikey::Dialogue.option_not_available).to eq(
        [Rubikey::TextColor::RED + 'That option is not available yet.']
      )
    end
  end

  describe '.search_site' do
    it 'shows case-insensitive partial matches as the query is typed' do
      passwords = [
        Password.new(website: 'google.com', username: 'rudy', id: 1),
        Password.new(website: 'github.com', username: 'dess', id: 2),
        Password.new(website: 'example.com', username: 'carol', id: 3)
      ]
      updates = []
      allow(Rubikey::Terminal).to receive(:getch).and_return('g', 'o', 'o', "\r")
      allow(Rubikey::Terminal).to receive(:output) do |*messages|
        if messages == Rubikey::Dialogue.password_list_header
          updates << []
        else
          updates.last << messages.join
        end
      end
      results = nil

      expect { results = Rubikey.search_site(passwords) }.to output.to_stdout

      expect(updates[1].join).to include('github.com')
      expect(updates.last.join).to include('google.com')
      expect(updates.last.join).not_to include('github.com')
      expect(results.map(&:website)).to eq(['google.com'])
    end
  end

  describe '.new_password' do
    it 'encrypts and saves the prompted password' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('example.com', 'alice')
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('secret')

      Rubikey.new_password

      saved_password = password_manager.get_passwords_for('example.com').first
      expect(saved_password.username).to eq('alice')
      expect(saved_password.get_password('masterPassword')).to eq('secret')
    ensure
      password_manager&.close
    end
  end

  describe '.show_passwords' do
    it 'lists account details and reveals the password after its list number is selected' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      password = Password.new(website: 'example.com', username: 'alice')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)
      allow(Rubikey::Terminal).to receive(:prompt).and_return(password.id.to_s, 'q')

      expect { Rubikey.show_passwords(password_manager.all_passwords) }.to output(
        a_string_including('example.com', 'alice', 'Password: ', 'secret')
      ).to_stdout
    ensure
      password_manager&.close
    end

    it 'selects by the displayed number when database IDs are not sequential' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      removed_password = Password.new(website: 'removed.com', username: 'alice')
      removed_password.update_password('old-secret', 'masterPassword')
      password_manager.add_password(removed_password)
      password = Password.new(website: 'example.com', username: 'bob')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)
      password_manager.remove_password(removed_password)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('1', 'q')

      expect { Rubikey.show_passwords(password_manager.all_passwords) }.to output(
        a_string_including('1. example.com', 'secret')
      ).to_stdout
    ensure
      password_manager&.close
    end

    it 'reveals the only search result without asking for its ID' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      password = Password.new(website: 'example.com', username: 'alice')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('q')

      expect do
        Rubikey.show_passwords(password_manager.all_passwords, select_single: true)
      end.to output(a_string_including('Password: ', 'secret')).to_stdout
      expect(Rubikey::Terminal).to have_received(:prompt).with(*Rubikey::Dialogue.password_revealed_prompt)
    ensure
      password_manager&.close
    end

    it 'deletes the selected password after revealing it' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      password = Password.new(website: 'example.com', username: 'alice')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)
      allow(Rubikey::Terminal).to receive(:prompt).and_return(password.id.to_s, 'd')

      expect(Rubikey.show_passwords(password_manager.all_passwords)).to eq(Rubikey::Dialogue.password_deleted)
      expect(password_manager.all_passwords).to be_empty
    ensure
      password_manager&.close
    end

    it 'deletes the only search result after revealing it' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      password = Password.new(website: 'example.com', username: 'alice')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('d')

      expect(Rubikey.show_passwords(password_manager.all_passwords, select_single: true)).to eq(
        Rubikey::Dialogue.password_deleted
      )
      expect(password_manager.all_passwords).to be_empty
    ensure
      password_manager&.close
    end

    it 'reports when no passwords are saved' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)

      expect(Rubikey.show_passwords(password_manager.all_passwords)).to eq(Rubikey::Dialogue.no_passwords_saved)
    ensure
      password_manager&.close
    end

    it 'reports when the selected password ID does not exist' do
      password = Password.new(website: 'example.com', username: 'alice', id: 1)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('404', 'q')

      expect { Rubikey.show_passwords([password]) }.to output(
        a_string_including('No saved password has that ID.')
      ).to_stdout
    end

    it 'colors the password label white and the revealed value blue' do
      expect(Rubikey::Dialogue.revealed_password('secret')).to eq(
        [Rubikey::TextColor::WHITE + 'Password: ', Rubikey::TextColor::BLUE + 'secret']
      )
    end
  end

  describe '.change_master_password' do
    it 'retries invalid credentials and mismatched confirmations before changing the password' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      password = Password.new(website: 'example.com', username: 'alice')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)

      allow(Rubikey::Terminal).to receive(:password_prompt).and_return(
        'wrongMasterPassword',
        'masterPassword',
        'newMasterPassword',
        'mismatchedPassword',
        'newMasterPassword',
        'newMasterPassword'
      )

      expect { Rubikey.change_master_password }.to output(
        a_string_including('Password does not match. Please try again.')
      ).to_stdout
      expect(password_manager.get_password_with_id(password.id).get_password('newMasterPassword')).to eq('secret')
      expect(password_manager.master_password.auth('newMasterPassword')).to be true
    ensure
      password_manager&.close
    end

    it 'cancels when q is entered instead of the current master password' do
      master_password = instance_double(MasterPassword, auth: true)
      password_manager = instance_double(PasswordManager, master_password: master_password)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('q')

      expect(password_manager).not_to receive(:change_master_password)
      expect(Rubikey.change_master_password).to be_nil
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
        a_string_including('Password does not match. Please try again.')
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

RSpec.describe Rubikey::Terminal do
  describe '.prompt_live' do
    it 'renders live results below the prompt and typed query' do
      allow(Rubikey::Terminal).to receive(:getch).and_return("\r")

      expect do
        Rubikey::Terminal.prompt_live('Search:') do
          Rubikey::Terminal.output('No matching passwords.')
        end
      end.to output(/Search:#{Regexp.escape(Rubikey::TextColor::RESET)} \nNo matching passwords\./).to_stdout
    end

    it 'updates the query for typed and deleted characters until Enter' do
      allow(Rubikey::Terminal).to receive(:getch).and_return('a', 'b', "\u007F", 'c', "\r")
      queries = []
      result = nil

      expect do
        result = Rubikey::Terminal.prompt_live('Search:') { |query| queries << query.dup }
      end.to output.to_stdout

      expect(queries).to eq(['', 'a', 'ab', 'a', 'ac'])
      expect(result).to eq('ac')
    end
  end

  describe '.prompt' do
    it 'prints the prompt and returns the entered value' do
      allow(Rubikey::Terminal).to receive(:gets).and_return("alice\n")

      expect do
        expect(Rubikey::Terminal.prompt('Username:')).to eq('alice')
      end.to output("Username:#{Rubikey::TextColor::RESET} ").to_stdout
    end
  end

  describe '.password_prompt' do
    it 'reads without echoing and returns the entered value' do
      original_stdin = $stdin
      input = double('stdin')
      allow(input).to receive(:noecho) { |&block| block.call(input) }
      allow(input).to receive(:gets).and_return("secret\n")
      $stdin = input

      expect do
        expect(Rubikey::Terminal.password_prompt('Password:')).to eq('secret')
      end.to output("Password:#{Rubikey::TextColor::RESET} ").to_stdout
    ensure
      $stdin = original_stdin
    end
  end
end
