require 'spec_helper'

describe Tabletastic::TableField do
  it "should guess its heading automatically" do
    tf = TableField.new(:method)
    tf.method_or_proc.should == :method
    tf.heading.should == "Method"
  end

  it "should know its heading when provided" do
    tf = TableField.new(:method, :heading => 'Foo', :klass => ::Post)
    tf.heading.should == "Foo"
  end

  it "should know what to do with a record" do
    tf = TableField.new(:downcase)
    tf.cell_data("HELLO").should == "hello"
  end

  it "should use a human_attribute_name whenever possible" do
    ::Post.stub!(:human_attribute_name).with('method').and_return("Blah blue")
    tf = TableField.new(:method, :klass => ::Post)
    tf.heading.should == "Blah blue"
  end

  it "should know what to do with a record (proc)" do
    tf = TableField.new(:fake) do |record|
      record.upcase
    end
    tf.cell_data("hello").should == "HELLO"
  end

  it "should return normal, non html-safe strings" do
    post = mock(:booya => 'crazy')
    tf = TableField.new(:booya)
    tf.cell_data(post).should_not be_html_safe
  end
end
