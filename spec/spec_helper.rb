## Use bundler to exec the specs
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
Bundler.setup
require 'rspec'

require 'rspec_tag_matchers'
require 'active_record'
require 'action_controller'

require 'action_view/base'
require 'action_view/template'
require 'action_view/helpers'

RSpec.configure do |config|
  config.include(RspecTagMatchers)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

module TabletasticSpecHelper
  include ActiveSupport
  include ActionView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveModelHelper
  include ActionView::Helpers::RecordTagHelper
  include ActionView::Helpers::CaptureHelper
  include ActionDispatch::Routing::PolymorphicRoutes

  def self.included(base)
    base.class_eval do
      attr_accessor :output_buffer
    end
  end

  def reset_output_buffer!
    @output_buffer = ActionView::OutputBuffer.new
  end

  module ::RspecTagMatchers
    class HaveTag
      def description
        description = "have tag <#@selector>"
        description << " with inner text '#@inner_text'" if @inner_text
        description
      end
    end
    def have_table_with_tag(selector, inner_text_or_options = nil, options = {}, &block)
      HaveTag.new("table", nil, {}) &&
        HaveTag.new(selector, inner_text_or_options, options, &block)
    end
  end

  class MockARModel
    def id
    end
    def to_key
      [id]
    end
    def self.human_attribute_name(col)
      col.humanize if col
    end
    def self.model_name
      ActiveModel::Name.new(self)
    end
  end
  class ::Author < MockARModel; end
  class ::Post < MockARModel; end
  class ::Profile < MockARModel; end

  def mock_everything
    def post_path(post); "/posts/#{post.id}"; end
    def admin_post_path(post); "/admin/posts/#{post.id}"; end
    def author_post_path(author, post); "/authors/#{author.id}/posts/#{post.id}"; end
    def admin_author_post_path(author, post); "/admin/authors/#{author.id}/posts/#{post.id}"; end
    def edit_post_path(post); "/posts/#{post.id}/edit"; end
    def edit_admin_post_path(post); "/admin/posts/#{post.id}/edit"; end
    def edit_admin_author_post_path(author, post)
      "/admin/authors/#{author.id}/posts/#{post.id}/edit"
    end

    # Sometimes we need a mock @post object and some Authors for belongs_to
    @post = Post.new
    @post.stub(:id => nil)
    @post.stub!(:author)
    ::Post.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }

    @fred = Author.new
    @fred.stub(:name => "Fred Smith", :id => 37)

    @profile = Profile.new
    @profile.stub(:author => @fred, :bio => "This is my bio")
    @fred.stub(:profile => @profile)

    ::Author.stub!(:content_columns).and_return([mock('column', :name => "name")])
    ::Author.stub!(:find).and_return([@fred])

    @freds_post = Post.new
    @freds_post.stub(:title => "Fred's Post", :id => 19, :author => @fred, :author_id => @fred.id)
    @freds_post.stub!(:body)
    @fred.stub(:posts => [@freds_post])

    @mock_reflection_belongs_to_author = mock('reflection1', :options => {}, :name => :author, :macro => :belongs_to, :collection => false)

    @mock_reflection_has_one_profile = mock('reflection2', :options => {}, :name => :profile, :macro => :has_one, :collection => false)

    ::Post.stub!(:reflect_on_association).and_return do |column_name|
      @mock_reflection_belongs_to_author if column_name == :author
    end

    ::Author.stub!(:reflect_on_association).and_return do |column_name|
      mock('reflection', :options => {}, :klass => Post, :macro => :has_many) if column_name == :posts
      @mock_reflection_has_one_profile if column_name == :profile
    end


    ::Post.stub!(:reflect_on_all_associations).and_return([])
    ::Author.stub!(:reflect_on_all_associations).and_return([])
  end
end


require 'tabletastic'

include TabletasticSpecHelper
include Tabletastic
include Tabletastic::Helper
