require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include TabletasticSpecHelper
include Tabletastic


describe "Tabletastic#table_for" do

  before do
    @output_buffer = ActiveSupport::SafeBuffer.new
  end

  describe "basics" do
    it "should start with an empty output buffer" do
      output_buffer.should_not have_tag("table")
    end

    it "should build a basic table" do
      table_for([]) do |t|
      end
      output_buffer.should have_tag("table")
    end

    context "with options" do
      it "should pass along html options" do
        table_for([], :html => {:class => 'special'}) do |t|
        end
        output_buffer.should have_tag("table.special")
      end
    end
  end
end
