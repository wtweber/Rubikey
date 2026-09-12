# Modules
require_relative "rubikey/terminal"
require_relative "rubikey/vars"

module Rubikey
	def self.hello
		puts "Hello, world!"
	end
	def self.run
		Terminal.output("#{TextColor::YELLOW}Welcome to #{TextColor::RED + TextColor::BOLD}Rubikey.")

		master_password = Terminal.password_prompt("Enter your master password:")
		
		Terminal.output("Received")
		# TODO: Check whether master password already exists.
		# TODO: Create the master password if it does not exist.
	end
end

class Password_Manager
end

class Password
	attr_reader :website, :username

	def initialize(website, username, password)
       raise ArgumentError, 'Website can not be empty' if website.empty?
       raise ArgumentError, 'Username can not be empty' if username.empty?
       raise ArgumentError, 'Password can not be empty' if password.empty?

       @website = website
       @username = username
	end

end

class Master_Password
end

Rubikey.run