require 'rubygems'
require 'spec'
require 'mocha'
require File.dirname(__FILE__) + '/../lib/using_yaml.rb'
 
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

UsingYAML.squelch!

class Person
  include UsingYAML
  using_yaml :children
end

def reset_person!
  Person.class_eval do
    include UsingYAML
    using_yaml :children
  end

  UsingYAML.path = ['Person', nil]
  @person.instance_variable_set('@using_yaml_path',  nil)
  @person.instance_variable_set('@using_yaml_cache', nil)
end
