require "spec_helper"

RSpec.describe Rubikey do
  describe ".hello" do
    it "prints a hello-world message" do
      expect { described_class.hello }.to output("Hello, world!\n").to_stdout
    end
  end

  describe 'Password' do
    it 'should be defined' do
      expect { Password }.not_to raise_error
    end

    describe 'getters and setters' do
      before(:each)  { @password = Password.new('www.google.com', 'userName', 'password') }
      it 'should set website' do
        expect(@password.website).to eq('www.google.com')
      end
      it 'should set user name' do
        expect(@password.user_name).to eq('userName')
      end
      it 'should set password' do
        expect(@password.password).to eq('password')
      end
      it 'should be able to change password' do
        @password.password = 'newPassword'
        expect(@password.password).to eq('newPassword')
      end
    end

    describe 'constructor' do
      it 'should reject invalid website' do
        expect { Password.new('', 'userName', 'password') }.to raise_error(ArgumentError)
      end
      it 'should reject invalid user name' do
        expect { Password.new('www.google.com', '', 'password') }.to raise_error(ArgumentError)
      end
      it 'should reject invalid password' do
        expect { Password.new('www.google.com', 'userName', '') }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Master_Password' do
    it 'should be defined' do
      expect { Master_Password }.not_to raise_error
    end

    describe 'getters and setters' do
      before(:each)  { @master_password = Master_Password.new('masterPassword') }
      it 'should set master password' do
        expect(@master_password.master_password).to eq('masterPassword')
      end
      it 'should be able to change master password' do
        @master_password.master_password = 'newMasterPassword'
        expect(@master_password.master_password).to eq('newMasterPassword')
      end
    end

    describe 'constructor' do
      it 'should reject invalid master password' do
        expect { Master_Password.new('') }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Password_Manager' do
    it 'should be defined' do
      expect { Password_Manager }.not_to raise_error
    end

    describe 'Passwords' do
      before(:each)  { @password_manager = Password_Manager.new }
      it 'should be able to add a password' do
        password = Password.new('www.google.com', 'userName', 'password')
        @password_manager.add_password(password)
        expect(@password_manager.passwords).to include(password)
      end
      it 'should be able to remove a password' do
        password = Password.new('www.google.com', 'userName', 'password')
        @password_manager.add_password(password)
        @password_manager.remove_password(password)
        expect(@password_manager.passwords).not_to include(password)
      end
      it 'should be able to retrieve a password from the database' do
        password = Password.new('www.google.com', 'userName', 'password')
        @password_manager.add_password(password)
        @password_manager = Password_Manager.new
        retrieved_password = @password_manager.retrieve_password('www.google.com')
        expect(retrieved_password).to eq(password)
      end
    end
  end
end