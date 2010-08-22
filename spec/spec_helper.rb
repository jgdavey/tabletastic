require 'rubygems'
require 'spork'

Spork.prefork do
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
    include ActionView::Helpers::RawOutputHelper
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
      def have_table_with_tag(selector, inner_text_or_options = nil, options = {}, &block)
        HaveTag.new("table", nil, {}) &&
          HaveTag.new(selector, inner_text_or_options, options, &block)
      end
    end

    class ::Post
      def id
      end
    end
    class ::Author
    end
    class ::Profile
    end

    def mock_everything
      def post_path(post); "/posts/#{post.id}"; end
      def admin_post_path(post); "/admin/posts/#{post.id}"; end
      def edit_post_path(post); "/posts/#{post.id}/edit"; end
      def edit_admin_post_path(post); "/admin/posts/#{post.id}/edit"; end

      # Sometimes we need a mock @post object and some Authors for belongs_to
      @post = mock('post')
      @post.stub!(:class).and_return(::Post)
      @post.stub!(:id).and_return(nil)
      @post.stub!(:author)
      @post.stub!(:to_key).and_return([2])
      ::Post.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
      ::Post.stub!(:model_name).and_return(ActiveModel::Name.new(::Post))

      @fred = mock('author', :to_key => nil)
      @fred.stub!(:class).and_return(::Author)
      @fred.stub!(:name).and_return('Fred Smith')
      @fred.stub!(:id).and_return(37)

      @profile = mock('profile')
      @profile.stub!(:author).and_return(@fred)
      @profile.stub!(:bio).and_return("This is my bio")
      @fred.stub!(:profile).and_return(@profile)

      ::Author.stub!(:content_columns).and_return([mock('column', :name => "name")])

      ::Author.stub!(:find).and_return([@fred])
      ::Author.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
      ::Author.stub!(:human_name).and_return('Author')
      ::Author.stub!(:model_name).and_return(ActiveModel::Name.new(::Author))

      @freds_post = mock('post')
      @freds_post.stub!(:class).and_return(::Post)
      @freds_post.stub!(:title).and_return('Fred\'s Post')
      @freds_post.stub!(:body)
      @freds_post.stub!(:id).and_return(19)
      @freds_post.stub!(:to_key).and_return([19])
      @freds_post.stub!(:author).and_return(@fred)
      @freds_post.stub!(:author_id).and_return(@fred.id)
      @fred.stub!(:posts).and_return([@freds_post])
      @fred.stub!(:post_ids).and_return([@freds_post.id])

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

end

Spork.each_run do
  # This code will be run each time you run your specs.
  require 'tabletastic'

  include TabletasticSpecHelper
  include Tabletastic
  include Tabletastic::Helper
end
