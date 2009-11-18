module Tabletastic

  # returns and outputs a table for the given active record collection
  def table_for(collection, *args)
    options = args.extract_options!
    options[:html] ||= {}
    options[:html][:id] ||= get_id_for(collection)
    concat(tag(:table, options[:html], true))
    yield TableBuilder.new(collection, self)
    concat("</table>")
  end

  def get_id_for(collection)
    !collection.empty? && collection.first.class.to_s.tableize
  end

  class TableBuilder
    @@association_methods = %w[display_name full_name name title username login value to_s]
    attr_accessor :field_labels

    def initialize(collection, template)
      @collection, @template = collection, template
    end

    # builds up the fields that the table will include,
    # returns table head and body with all data
    def data(*args, &block)
      if block_given?
        yield self
        @template.concat(head)
        @template.concat(body)
      else
        @fields = args unless args.empty?
        @field_labels = fields.map { |f| f.to_s.humanize }
        [head, body].join("")
      end
    end

    def cell(*args)
      options = args.extract_options!
      @field_labels ||= []
      @fields ||= []

      method_or_attribute = args.first.to_sym

      if cell_html = options.delete(:cell_html)
        @fields << [method_or_attribute, cell_html]
      else
        @fields << method_or_attribute
      end

      if heading = options.delete(:heading)
        @field_labels << heading
      else
        @field_labels << method_or_attribute.to_s.humanize
      end

      return "" # Since this will likely be called with <%= erb %>, this suppresses strange output
    end

    def head
      @field_labels ||= fields
      content_tag(:thead) do
        header_row
      end
    end

    def header_row
      content_tag(:tr) do
        @field_labels.inject("") do |result,field|
          result += content_tag(:th, field)
        end
      end
    end

    def body
      content_tag(:tbody) do
        body_rows
      end
    end

    def body_rows
      @collection.inject("") do |rows, record|
        rowclass = @template.cycle("odd","even")
        rows += @template.content_tag_for(:tr, record, :class => rowclass) do
          tds_for_row(record)
        end
      end
    end

    def tds_for_row(record)
      fields.inject("") do |cells, field_or_array|
        field = field_or_array
        if field_or_array.is_a?(Array)
          field = field_or_array.first
          html_options = field_or_array.last
        end
        cells += content_tag(:td, cell_data(record, field), html_options)
      end
    end

    def cell_data(record, method_or_attribute)
      # Get the attribute or association in question
      result = record.send(method_or_attribute)
      # If we already have a string, just return it
      return result if result.is_a?(String)

      # If we don't have a string, its likely an association
      # Try to detect which method to use for stringifying the attribute
      to_string = detect_string_method(result)
      result.send(to_string) if to_string
    end

    def fields
      return @fields if defined?(@fields)
      @fields = @collection.empty? ? [] : active_record_fields_for_object(@collection.first)
    end

    protected

    def detect_string_method(association)
      @@association_methods.detect { |method| association.respond_to?(method) }
    end


    def active_record_fields_for_object(obj)
      # normal content columns
      fields = obj.class.content_columns.map(&:name)

      # active record associations
      associations = obj.class.reflect_on_all_associations(:belongs_to) if obj.class.respond_to?(:reflect_on_all_associations)
      if associations
        associations = associations.map(&:name)
        fields += associations
      end

      # remove utility columns by default
      fields -= %w[created_at updated_at created_on updated_on lock_version version]
      fields = fields.map(&:to_sym)
    end


    def content_tag(name, content = nil, options = nil, escape = true, &block)
      @template.content_tag(name, content, options, escape, &block)
    end
  end
end
