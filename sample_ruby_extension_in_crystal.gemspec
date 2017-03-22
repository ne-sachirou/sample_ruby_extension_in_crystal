# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sample_ruby_extension_in_crystal/version'

Gem::Specification.new do |spec|
  spec.name          = 'sample_ruby_extension_in_crystal'
  spec.version       = SampleRubyExtensionInCrystal::VERSION
  spec.authors       = ['ne_Sachirou']
  spec.email         = ['utakata.c4se@gmail.com']

  spec.summary       = 'Sample Ruby extension written by Crystal'
  spec.description   = 'Sample Ruby extension written by Crystal.'
  spec.homepage      = 'http://c4se.jp/profile/ne_sachirou'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org/'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/sample_ruby_extension_in_crystal/extconf.rb']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
