$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "tabletastic/version"

task :build do
  system "gem build tabletastic.gemspec"
end

task :release => :build do
  system "git tag v#{Tabletastic::VERSION}"
  system "gem push tabletastic-#{Tabletastic::VERSION}"
end

# == RSpec
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
end

desc "Test the tabletastic plugin with specdoc formatting and colors"
RSpec::Core::RakeTask.new(:specdoc) do |t|
  t.spec_opts = ["--format documentation", "-c"]
end

desc "Test the tabletastic plugin with rcov"
RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'spec,Library']
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Tabletastic #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
