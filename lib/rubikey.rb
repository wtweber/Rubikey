# Modules
require_relative "rubikey/terminal"
require_relative "rubikey/vars"

module Rubikey
	def self.hello
		puts "Hello, world!"
	end
	def self.run
		Terminal.output(
			TextColor::BOLD + "//////////////////////////////////////////////////////////\n", 
			TextColor::GREEN + "                   Welcome to ",
			TextColor::RED + TextColor::BOLD + "Rubikey.\n",
			TextColor::BOLD + "//////////////////////////////////////////////////////////\n"
		)
		
		self.first_timer
		# TODO: Check whether master password already exists.
		# TODO: Create the master password if it does not exist.
	end
	def self.first_timer
		Terminal.output(
			TextColor::GREEN + "This is the first time you have used this application.\n",
			TextColor::GREEN + "In order to secure your passwords, we require that you create a ",
			TextColor::YELLOW + TextColor::BOLD + "master password.", "\n",
		)
		master_password = Terminal.password_prompt(
			TextColor::GREEN + "Create a new ",
			TextColor::YELLOW + TextColor::BOLD + "master password:"
		)
		
		Terminal.output("Received.")
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