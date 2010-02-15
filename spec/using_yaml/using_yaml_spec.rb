require File.dirname(__FILE__) + '/../spec_helper'

describe 'UsingYAML#core' do
  before(:each) do
    @person = Person.new
  end

  it "should return nil for invalid settings files" do
    @person.children.should be_nil
  end

  it "should return valid settings files" do
    YAML.stubs(:load_file).with(anything).returns({ 'foo' => 'bar' })
    @person.children.should == { 'foo' => 'bar' }
    @person.children.foo.should == 'bar'
  end

  it "should work with arrays" do
    YAML.stubs(:load_file).with(anything).returns([ { 'foo' => 'bar' } ])
    @person.children.class.name.should == 'Array'
    @person.children.first.should == { 'foo' => 'bar' }
  end
end
