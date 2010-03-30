require File.dirname(__FILE__) + '/../spec_helper'

describe 'UsingYAML' do
  before(:each) do
    @person = Person.new
  end

  describe 'robustness' do
    it "should return nil for invalid settings files" do
      @person.children.should be_nil
    end

    it "should gracefully handle nil.nil..." do
      @person.children.something.invalid.should be_nil
    end

    it "should return false when expected" do
      YAML.stubs(:load_file).with(anything).returns({ 'example' => false })
      @person.children.example.should == false
    end
  end

  describe 'hashes' do
    it "should work" do
      YAML.stubs(:load_file).with(anything).returns({ 'foo' => 'bar' })
      @person.children.should == { 'foo' => 'bar' }
      @person.children.foo.should == 'bar'
    end

    it "should define methods when a hash gets a new key" do
      YAML.stubs(:load_file).with(anything).returns({})
      @person.children.foo = 'bar'
      @person.children.foo.should == 'bar'
    end

    it "should catchup when a hash gets a new key via []=" do
      YAML.stubs(:load_file).with(anything).returns({})
      @person.children['foo'] = 'bar'
      @person.children.foo.should == 'bar'
    end
  end

  describe 'arrays' do
    it "should work" do
      YAML.stubs(:load_file).with(anything).returns([ { 'foo' => 'bar' } ])
      @person.children.class.name.should == 'Array'
      @person.children.first.should == { 'foo' => 'bar' }
    end
  end

  describe 'assignments' do
    it "should work" do
      @person.children = [ :example ]
      @person.children.should == [ :example ]
      @person.children.respond_to?(:save).should == true
    end
  end
end
