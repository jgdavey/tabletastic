require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include TabletasticSpecHelper
include Tabletastic


describe "Tabletastic#table_for" do

  before do
    @output_buffer = ''
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

    context "headers and table body" do
      before do
        table_for([]) do |t|
          concat(t.headers)
          concat(t.body)
        end
      end

      it "should build a basic table and headers" do
        output_buffer.should have_table_with_tag("thead")
      end

      it "should build a basic table and body" do
        output_buffer.should have_table_with_tag("tbody")
      end
    end
  end

  describe "#data" do
    before do
      mock_everything
      ::Post.stub!(:content_columns).and_return([mock('column', :name => 'title'), mock('column', :name => 'body'), mock('column', :name => 'created_at')])
      @post.stub!(:title).and_return("The title of the post")
      @post.stub!(:body).and_return("Lorem ipsum")
      @post.stub!(:created_at).and_return(Time.now)
      @post.stub!(:id).and_return(2)
      @posts = [@post]
    end

    context "with no other arguments" do
      before do
        table_for(@posts) do |t|
          concat(t.data)
        end
      end

      it "should output headers" do
        output_buffer.should have_table_with_tag("thead")
      end

      it "should have a <th> for each attribute" do
        # title and body
        output_buffer.should have_table_with_tag("th", :count => 2)
      end

      it "should include header for Title" do
        output_buffer.should have_table_with_tag("th", "Title")
      end

      it "should include header for Body" do
        output_buffer.should have_table_with_tag("th", "Body")
      end

      it "should output body" do
        output_buffer.should have_table_with_tag("tbody")
      end

      it "should include a row for each record" do
        output_buffer.should have_table_with_tag("tbody") do |tbody|
          tbody.should have_tag("tr", :count => 1)
        end
      end

      it "should have data for each field" do
        output_buffer.should have_table_with_tag("td", "The title of the post")
        output_buffer.should have_table_with_tag("td", "Lorem ipsum")
      end

      it "should include the id for the <tr> for each record" do
        output_buffer.should have_table_with_tag("tr#post_#{@post.id}")
      end
    end

    context "with a list of attributes" do
      before do
        table_for(@posts) do |t|
          concat(t.data(:title, :created_at))
        end
      end

      it "should call each method passed in, and only those methods" do
        output_buffer.should have_table_with_tag("th", "Title")
        output_buffer.should have_table_with_tag("th", "Created at")
        output_buffer.should_not have_table_with_tag("th", "Body")
      end
    end
  end
end

describe TableBuilder do
  before do
    mock_everything
    ::Post.stub!(:content_columns).and_return([mock('column', :name => 'title'), mock('column', :name => 'body'), mock('column', :name => 'created_at')])
    @posts = [@post, Post.new]
    @builder = TableBuilder.new(@posts, nil)
  end

  it "should detect attributes" do
    @builder.fields.should include(:title)
  end

  it "should reject marked attributes" do
    @builder.fields.should_not include(:created_at)
  end
end
