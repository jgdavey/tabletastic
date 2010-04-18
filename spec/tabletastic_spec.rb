require 'spec_helper'

describe "Tabletastic#table_for" do

  before do
    @output_buffer = ActiveSupport::SafeBuffer.new
  end

  describe "basics" do
    it "should start with an empty output buffer" do
      output_buffer.should_not have_tag("table")
    end

    it "should build a basic table" do
      concat(table_for([]) {})
      output_buffer.should have_tag("table")
    end

    context "with options" do
      it "should pass along html options" do
        concat(table_for([], :html => {:class => 'special'}){})
        output_buffer.should have_tag("table.special")
      end
    end
  end

  describe "default options" do
    before do
      Tabletastic.default_table_html = {:class => 'default', :cellspacing => 0}
    end

    it "should allow default table html to be set" do
      concat(table_for([]){})
      output_buffer.should have_tag("table.default")
    end

    it "can be overridden with inline options" do
      concat(table_for([], :html => {:class => 'newclass'}){})
      output_buffer.should have_tag("table.newclass")
      output_buffer.should_not have_tag("table.default")
    end
  end
end
