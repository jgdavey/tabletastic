require 'spec_helper'

describe Tabletastic::TableField do
  it "should guess its heading automatically" do
    tf = TableField.new(:method)
    tf.method_or_proc.should == :method
    tf.heading.should == "Method"
  end

  it "should know its heading when provided" do
    tf = TableField.new(:method, :heading => 'Foo')
    tf.heading.should == "Foo"
  end

  it "should know what to do with a record" do
    tf = TableField.new(:downcase)
    tf.cell_data("HELLO").should == "hello"
  end

  it "should know what to do with a record (proc)" do
    tf = TableField.new(:fake) do |record|
      record.upcase
    end
    tf.cell_data("hello").should == "HELLO"
  end
end
