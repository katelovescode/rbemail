# coding: utf-8
lib = File.expand_path('../lib',__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name           = "rubymail"
  spec.version        = '1.0'
  spec.authors        = ["Kate Klemp"]
  spec.email          = ["kklemp@misdepartment.com"]
  spec.summary        = %q{Send email via a web form on a server running SMTP}
  spec.description    = %q{Using built-in Ruby mail functionality on an SMTP server, send email via a web form}
  spec.homepage       = "http://www.misdepartment.com/"
  spec.license        = "MIT"

  spec.files          = ['lib/rubymail.rb']
  spec.executables    = ['bin/rubymail']
  spec.test_files     = ['tests/test_rubymail.rb']
  spec.require_paths  = ["lib"]
end
