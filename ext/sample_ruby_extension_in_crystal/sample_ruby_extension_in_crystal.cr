require "./ruby"

ruby SampleRubyExtensionInCrystal,
  module SampleRubyExtensionInCrystal
    def self.fib_cr(n : Int32) : Int32
      # (1..n - 1).reduce([1, 1]) { |ns| [ns[1], ns[0] + ns[1]] }[1]
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

    def self.hello_cr : Nil
      puts "Hello, World!"
    end
  end

fun init = Init_sample_ruby_extension_in_crystal
  GC.init
  LibCrystalMain.__crystal_main 0, Pointer(UInt8*).null
end
