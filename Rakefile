$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "tabletastic/version"

def gem_file
  "tabletastic-#{current_version}.gem"
end

def current_version
  "#{Tabletastic::VERSION}"
end

task :build do
  system "mkdir -p ./pkg"
  system "gem build tabletastic.gemspec"
  system "mv #{gem_file} pkg/"
end

task :release => :build do
  system "git tag v#{current_version}"
  system "gem push pkg/#{gem_file}"
end

# == RSpec
require 'rspec/core/rake_task'

task :default => :spec
task :specs => :spec

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
end

desc "Test the tabletastic plugin with specdoc formatting and colors"
RSpec::Core::RakeTask.new(:specdoc) do |t|
  t.rspec_opts = ["--format documentation", "-c"]
end

desc "Test the tabletastic plugin with rcov"
RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'spec,Library']
end


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Tabletastic #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
