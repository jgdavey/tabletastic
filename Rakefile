$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "tabletastic/version"

task :build do
  system "gem build tabletastic.gemspec"
end

task :release => :build do
  system "gem push bundler-#{Tabletastic::VERSION}"
end

# == RSpec
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Test the tabletastic plugin with specdoc formatting and colors'
Spec::Rake::SpecTask.new('specdoc') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ["--format specdoc", "-c"]
end

desc 'Test the tabletastic plugin with rcov'
Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'spec,Library']
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Tabletastic #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
