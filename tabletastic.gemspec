lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'tabletastic/version'

Gem::Specification.new do |s|
  s.name     = 'tabletastic'
  s.version  = Tabletastic::VERSION
  s.platform = Gem::Platform::RUBY

  s.authors  = ["Joshua Davey"]
  s.email    = 'josh@joshuadavey.com'
  s.homepage = 'http://github.com/jgdavey/tabletastic'
  s.date     = '2011-08-10'

  s.summary  = 'A smarter table builder for Rails collections'
  s.description = <<-EOT
    A table builder for active record collections that
    produces semantically rich and accessible table markup
  EOT

  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.rdoc CHANGELOG.rdoc init.rb)

  s.require_path = 'lib'
  s.required_rubygems_version = ">= 1.3.6"
  s.add_runtime_dependency('activesupport', '~> 3.0')
  s.test_files = Dir.glob("spec/**/*_spec.rb") + %w{spec/spec_helper.rb}
  s.add_development_dependency "rspec"
end

