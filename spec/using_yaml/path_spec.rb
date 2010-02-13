require File.dirname(__FILE__) + '/../spec_helper'

def reset_person!
  Person.class_eval do
    include UsingYAML
    using_yaml :children
  end

  UsingYAML.path = ['Person', nil]
  Person.using_yaml_path = nil
end

describe "UsingYAML#paths" do
  before(:each) do
    @person = Person.new
  end

  it "should return $HOME for non-existant pathnames" do
    Person.using_yaml_path.expand_path.to_s.should == ENV['HOME']
  end

  it "should return path/to/defined for globally set pathnames" do
    Person.using_yaml_path = "global"
    Person.using_yaml_path.expand_path.to_s.should =~ /global/
    reset_person!
  end

  it "should return path/to/defined for locally set pathnames" do
    Person.class_eval do
      using_yaml :children, :path => "local"
    end
    Person.using_yaml_path.expand_path.to_s.should =~ /local/
    reset_person!
  end
end
