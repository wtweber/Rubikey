module Rubikey
	def self.hello
		puts "Hello, world!"
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