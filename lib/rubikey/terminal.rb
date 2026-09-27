# frozen_string_literal: true

# Modules
require 'io/console'
require_relative 'vars'

module Rubikey
  # Wrapper for outputting to terminal. 
  # This module automatically resets text between each received string.
  module Terminal
    def self.output(*messages)
      puts messages.map { |message| "#{message}#{TextColor::RESET}" }.join
    end

    def self.prompt(*messages)
      print messages.map { |message| "#{message}#{TextColor::RESET}" }.join
      print ' '
      gets.chomp
    end

    def self.prompt_live(*messages)
      query = +''
      loop do
        clear
        print messages.map { |message| "#{message}#{TextColor::RESET}" }.join
        puts "#{query} "
        yield query

        character = getch
        if ["\r", "\n"].include?(character)
          puts
          return query
        elsif ["\b", "\u007F"].include?(character)
          query.chop! unless query.empty?
        elsif character.match?(/\A[[:print:]]\z/)
          query << character
        end
      end
    end

    def self.getch
      $stdin.getch
    end

    def self.password_prompt(*messages)
      print messages.map { |message| "#{message}#{TextColor::RESET}" }.join
      print ' '
      $stdin.noecho(&:gets).chomp
    end

    def self.clear
      puts "\e[H\e[2J"
    end
  end
end
