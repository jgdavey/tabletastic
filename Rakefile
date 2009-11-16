require 'rubygems'
require 'rake'

GEM = "tabletastic"
LONGDESCRIPTION = %Q{A table builder for active record collections \
  that produces semantically rich and accessible markup}

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = GEM
    s.summary = %Q{A smarter table builder for Rails collections}
    s.description = LONGDESCRIPTION
    s.email = "josh@joshuadavey.com"
    s.homepage = "http://github.com/jgdavey/tabletastic"
    s.authors = ["Joshua Davey"]

    s.require_path = 'lib'
    s.autorequire = GEM

    s.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

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
