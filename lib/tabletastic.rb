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

    def initialize(collection, template)
      @collection, @template = collection, template
    end

    # builds up the fields that the table will include,
    # returns table headers and body with all data
    def data(*args, &block)
      if block_given?
        yield self
        @template.concat(headers)
        @template.concat(body)
      else
        @fields = args unless args.empty?
        [headers, body].join("")
      end
    end

    def cell(method_or_attribute)
      @fields ||= []
      @fields << method_or_attribute.to_sym
      return "" # Since this will likely be called with <%= erb %>, this suppresses strange output
    end

    def headers
      content_tag(:thead) do
        header_row
      end
    end

    def header_row
      content_tag(:tr) do
        fields.inject("") do |result,field|
          result += content_tag(:th, field.to_s.humanize)
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
      fields.inject("") do |cells, field|
        cells += content_tag(:td, cell_data(record, field))
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
