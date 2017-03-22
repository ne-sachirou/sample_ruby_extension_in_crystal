require 'sample_ruby_extension_in_crystal/version'
require 'sample_ruby_extension_in_crystal/sample_ruby_extension_in_crystal'

#
module SampleRubyExtensionInCrystal
  def self.fib_rb(n)
    # (1..n - 1).inject([1, 1]) { |ns| [ns[1], ns[0] + ns[1]] }[1]
    ns = [1, 1]
    i = 1
    while i < n
      ns0 = ns[0]
      ns[0] = ns[1]
      ns[1] = ns0 + ns[1]
      i += 1
    end
    ns[1]
  end

  def self.hello_rb
    puts 'Hello, World!'
  end
end
