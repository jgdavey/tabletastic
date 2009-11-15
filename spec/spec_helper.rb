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

  def mock_everything
    # Sometimes we need a mock @post object and some Authors for belongs_to
    @post = mock('post')
    @post.stub!(:class).and_return(::Post)
    @post.stub!(:id).and_return(nil)
    ::Post.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Post.stub!(:human_name).and_return('Post')
  end
end

