require "spec_helper"

RSpec.describe Rubikey do
  describe ".hello" do
    it "prints a hello-world message" do
      expect { described_class.hello }.to output("Hello, world!\n").to_stdout
    end
  end
end