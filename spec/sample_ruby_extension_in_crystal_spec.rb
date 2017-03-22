require 'spec_helper'

RSpec.describe SampleRubyExtensionInCrystal do
  it 'has a version number' do
    expect(SampleRubyExtensionInCrystal::VERSION).not_to be nil
  end

  describe '.fib_rb' do
    [
      [0, 1],
      [1, 1],
      [2, 2],
      [30, 1_346_269]
    ].each do |n, r|
      it("fib #{n} is #{r}") { expect(described_class.fib_rb(n)).to eq r }
    end
  end

  describe '.fib_c' do
    [
      [0, 1],
      [1, 1],
      [2, 2],
      [30, 1_346_269]
    ].each do |n, r|
      it("fib #{n} is #{r}") { expect(described_class.fib_c(n)).to eq r }
    end
  end
end
