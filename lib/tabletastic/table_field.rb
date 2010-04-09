require 'active_support/core_ext/object'

module Tabletastic
  class TableField
    @@association_methods = %w[to_label display_name full_name name title username login value to_str to_s]

    attr_accessor :heading, :method_or_proc, :cell_html

    def initialize(*args, &proc)
      options = args.extract_options!
      method = args.first.to_sym
      @method_or_proc = block_given? ? proc : method
      @cell_html = options[:cell_html]
      @klass = options.delete(:klass)
      @heading = options.delete(:heading) || @klass.try(:human_attribute_name, method.to_s) || method.to_s.humanize
    end

    def cell_data(record)
      # Get the attribute or association in question
      result = send_or_call(record, method_or_proc)
      # If we already have a string, just return it
      return result if result.is_a?(String)

      # If we don't have a string, its likely an association
      # Try to detect which method to use for stringifying the attribute
      to_string = detect_string_method(result)
      result.send(to_string) if to_string
    end

    private

    def detect_string_method(association)
      @@association_methods.detect { |method| association.respond_to?(method) }
    end

    def send_or_call(object, duck)
      if duck.respond_to?(:call)
        duck.call(object)
      else
        object.send(duck)
      end
    end
  end
end