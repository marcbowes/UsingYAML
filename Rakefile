require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "using_yaml"
    gem.summary = %Q{"Load, save and use YAML files"}
    gem.description = %Q{"Load, save and use YAML files as if they were objects"}
    gem.email = "marcbowes@gmail.com"
    gem.homepage = "http://github.com/marcbowes/UsingYAML"
    gem.authors = ["Marc Bowes"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "using_yaml #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'spec/rake/spectask'

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = Rake::FileList["spec/**/*_spec.rb"]
  t.spec_opts = ["-c"]
end

desc "Run a simple performance benchmark"
task :benchmark do
  require 'lib/using_yaml'
  require 'benchmark'

  was_squelched = UsingYAML.squelched?
  UsingYAML.squelch!
  class Person
    include UsingYAML
    using_yaml :children
  end
  p = Person.new
  p.children # "cache" the nil
  n = 10000

  puts "** Testing chains of nils **"
  Benchmark.bmbm(10) do |x|
    x.report("normal")  { n.times do; p.children && p.children['something'] && p.children['invalid']; end }
    x.report("chained") { n.times do; p.children.something.invalid; end }
  end

  p.children = { 'something' => { 'valid' => 1 } }
  puts "\n** Testing where the keys exist **"
  Benchmark.bmbm(10) do |x|
    x.report("normal")  { n.times do; p.children && p.children['something'] && p.children['invalid']; end }
    x.report("chained") { n.times do; p.children.something.invalid; end }
  end
  UsingYAML.unsquelch! unless was_squelched
end

task :default => :spec
