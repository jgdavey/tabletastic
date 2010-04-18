$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'

def smart_require(gem_name, gem_version = '>= 0.0.0', lib_name = nil)
  lib_name ||= gem_name
  begin
    require lib_name if lib_name
  rescue LoadError
    if gem_name
      gem gem_name, gem_version
      require lib_name if lib_name
    end
  end
end

smart_require 'rspec', '>= 1.3.0', 'spec'
require 'spec/autorun'
smart_require 'nokogiri'
smart_require 'rspec_tag_matchers', '>= 1.0.0'
smart_require 'activesupport', '>= 3.0.0.beta3', 'active_support'
smart_require 'actionpack',    '>= 3.0.0.beta3', 'action_pack'
smart_require 'activerecord',  '>= 3.0.0.beta3', 'active_record'
require 'action_controller'
require 'action_view/base'
require 'action_view/template'
require 'action_view/helpers'
Spec::Runner.configure do |config|
  config.include(RspecTagMatchers)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tabletastic'

module TabletasticSpecHelper
  include ActiveSupport
  include ActionView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveModelHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::RecordTagHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::RawOutputHelper
  include ActionController::PolymorphicRoutes

  def self.included(base)
    base.class_eval do
      attr_accessor :output_buffer
    end
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

    @fred = mock('user')
    @fred.stub!(:class).and_return(::Author)
    @fred.stub!(:name).and_return('Fred Smith')
    @fred.stub!(:id).and_return(37)

    ::Author.stub!(:find).and_return([@fred])
    ::Author.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Author.stub!(:human_name).and_return('Author')
    ::Author.stub!(:model_name).and_return(ActiveModel::Name.new(::Author))
    ::Author.stub!(:reflect_on_association).and_return { |column_name| mock('reflection', :options => {}, :klass => Post, :macro => :has_many) if column_name == :posts }

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

    @mock_reflection_belongs_to_author = mock('reflection', :options => {}, :name => :author, :klass => ::Author, :macro => :belongs_to)

    ::Post.stub!(:reflect_on_association).and_return do |column_name|
      @mock_reflection_belongs_to_author if column_name == :author
    end

    ::Post.stub!(:reflect_on_all_associations).with(:belongs_to).and_return([])
  end
end

include TabletasticSpecHelper
include Tabletastic
include Tabletastic::Helper
