$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'

def smart_require(lib_name, gem_name, gem_version = '>= 0.0.0')
  begin
    require lib_name if lib_name
  rescue LoadError
    if gem_name
      gem gem_name, gem_version
      require lib_name if lib_name
    end
  end
end

smart_require 'spec', 'spec', '>= 1.2.8'
require 'spec/autorun'
smart_require false, 'rspec-rails', '>= 1.2.7.1'
smart_require 'hpricot', 'hpricot', '>= 0.6.1'
smart_require 'rspec_hpricot_matchers', 'rspec_hpricot_matchers', '>= 1.0.0'
smart_require 'active_support', 'activesupport', '>= 2.3.4'
smart_require 'action_controller', 'actionpack', '>= 2.3.4'
smart_require 'action_view', 'actionpack', '>= 2.3.4'

Spec::Runner.configure do |config|
  config.include(RspecHpricotMatchers)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tabletastic'

module TabletasticSpecHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::RecordTagHelper
  include ActionView::Helpers::CaptureHelper
  include ActiveSupport
  include ActionController::PolymorphicRoutes

  def self.included(base)
    base.class_eval do
      attr_accessor :output_buffer
      def protect_against_forgery?
        false
      end
    end
  end

  module ::RspecHpricotMatchers
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
    ::Post.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Post.stub!(:human_name).and_return('Post')

    @fred = mock('user')
    @fred.stub!(:class).and_return(::Author)
    @fred.stub!(:name).and_return('Fred Smith')
    @fred.stub!(:id).and_return(37)

    ::Author.stub!(:find).and_return([@fred])
    ::Author.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Author.stub!(:human_name).and_return('Author')
    ::Author.stub!(:reflect_on_association).and_return { |column_name| mock('reflection', :options => {}, :klass => Post, :macro => :has_many) if column_name == :posts }

    @freds_post = mock('post')
    @freds_post.stub!(:class).and_return(::Post)
    @freds_post.stub!(:title).and_return('Fred\'s Post')
    @freds_post.stub!(:body)
    @freds_post.stub!(:id).and_return(19)
    @freds_post.stub!(:author).and_return(@fred)
    @freds_post.stub!(:author_id).and_return(@fred.id)
    @fred.stub!(:posts).and_return([@freds_post])
    @fred.stub!(:post_ids).and_return([@freds_post.id])

    @mock_reflection_belongs_to_author = mock('reflection', :options => {}, :name => :author, :klass => ::Author, :macro => :belongs_to)

    ::Post.stub!(:reflect_on_association).and_return do |column_name|
      @mock_reflection_belongs_to_author if column_name == :author
    end

    ::Post.stub!(:reflect_on_all_associations).with(:belongs_to).and_return([])
  end
end
