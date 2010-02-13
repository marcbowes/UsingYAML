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
