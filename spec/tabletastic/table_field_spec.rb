require 'spec_helper'

describe Tabletastic::TableField do
  it "should guess its heading automatically" do
    tf = TableField.new(:method)
    tf.method_or_proc.should == :method
    tf.heading.should == "Method"
  end

  it "should know what to do with a record" do
    tf = TableField.new(:downcase)
    tf.cell_data("HELLO").should == "hello"
  end

  it "should know what to do with a record (proc)" do
    tf = TableField.new(:fake) do |record|
      record.upcase
    end
    tf.cell_data("hello").should == "HELLO"
  end

  it "should return normal, non html-safe strings" do
    post = mock(:booya => 'crazy')
    tf = TableField.new(:booya)
    tf.cell_data(post).should_not be_html_safe
  end

  describe "#heading" do
    subject { TableField.new(:method, :heading => heading, :klass => Post) }
    context "when heading option is provided" do
      let(:heading) { "Foo" }
      its(:heading) { should == "Foo" }
    end

    context "when heading option is omitted" do
      let(:heading) { nil }
      let(:derived_heading) { "Blah blue" }
      let(:i18n_heading) { "I18n Foo" }

      context "with I18n attributes defined" do
        let(:i18n_translations) do
          { :tabletastic => { :models => { :post => { :method => i18n_heading } } } }
        end
        before { I18n.backend.store_translations :en, i18n_translations }
        after { I18n.backend.reload! }

        its(:heading) { should ==  i18n_heading }
      end

      context "with no I18n attributes defined" do
        context "with human_attribute_name-capable class" do
          before { Post.stub!(:human_attribute_name).with('method').and_return(derived_heading) }
          its(:heading) { should == derived_heading }
        end

        context "without human_attribute_name-capable class" do
          its(:heading) { should == "Method" }
        end
      end

    end
  end
end
