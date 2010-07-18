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

  describe "guessing its class collection" do
    before do
      mock_everything
    end

    it "should find the class of the collection (ActiveRecord::Relation)" do
      table = mock(Arel::Table)
      collection = ActiveRecord::Relation.new(@post.class, table)
      collection.stub!(:build_arel => table)
      klass = Tabletastic::TableBuilder.send(:default_class_for, collection)
      klass.should == Post
    end

    it "should find the class of the collection (Array of AR objects)" do
      collection = [@post]
      klass = Tabletastic::TableBuilder.send(:default_class_for, collection)
      klass.should == Post
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

  describe "without a block" do
    it "should use default block" do
      concat table_for([])
      output_buffer.should have_tag("table")
    end
  end
end
