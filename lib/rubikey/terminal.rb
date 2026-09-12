# Modules
require "io/console"
require_relative "vars"

module Rubikey
    module Terminal
        def self.output(message)
            puts "#{message}#{TextColor::RESET}"
        end

        def self.prompt(message)
            print "#{message}#{TextColor::RESET} "
            gets.chomp
        end

        def self.password_prompt(message)
            print "#{message}#{TextColor::RESET} "
            STDIN.noecho(&:gets).chomp
        end
    end
end