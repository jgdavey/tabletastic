require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Tabletastic" do
  include TabletasticSpecHelper
  include Tabletastic

  before do
    @output_buffer = ''
  end


  it "should start with an empty output buffer" do
    output_buffer.should_not have_tag("table")
  end
  
  it "should build a basic table" do
    table_for([]) do |t|
    end
    output_buffer.should have_tag("table")
    output_buffer.should == "<table></table>"
  end
end
