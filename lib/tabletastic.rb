module Tabletastic

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
    @@association_methods = %w[to_label display_name full_name name title username login value to_s]

    def initialize(collection, template)
      @collection, @template = collection, template
    end

    def data(*args, &block)
      if block_given?
        yield self
        @template.concat(headers)
        @template.concat(body)
      else
        @fields = args unless args.empty?
        headers + body
      end
    end

    def headers
      content_tag(:thead) do
        header_row
      end
    end

    def header_row
      output = "<tr>"
      fields.each do |field|
        output += content_tag(:th, field.to_s.humanize)
      end
      output += "</tr>"
    end

    def body
      content_tag(:tbody) do
        body_rows
      end
    end

    def body_rows
      @collection.inject("") do |rows, record|
        rowclass = cycle("odd","even")
        rows += @template.content_tag_for(:tr, record, :class => rowclass) do
          tds_for_row(record)
        end
      end
    end

    def tds_for_row(record)
      fields.inject("") do |cells, field|
        cells += content_tag(:td, cell_for(record, field))
      end
    end

    def cell_for(record, method_or_attribute)
      result = record.send(method_or_attribute)
      return result if result.is_a?(String)
      to_string = detect_string_method(result)
      result.send(to_string) if to_string
    end

    def detect_string_method(association)
      @@association_methods.detect { |method| association.respond_to?(method) }
    end

    def cell(method_or_attribute)
      @fields ||= []
      @fields << method_or_attribute.to_sym
      return ""
    end

    def fields
      return @fields if defined?(@fields)
      if @collection.empty?
        @fields = []
      else
        object = @collection.first
        associations = object.class.reflect_on_all_associations(:belongs_to) if object.class.respond_to?(:reflect_on_all_associations)
        @fields = object.class.content_columns.map(&:name)
        if associations
          associations = associations.map(&:name)
          @fields += associations
        end
        @fields -= %w[created_at updated_at created_on updated_on lock_version version]
        @fields.map!(&:to_sym)
      end
    end

    private

      def content_tag(name, content = nil, options = nil, escape = true, &block)
        @template.content_tag(name, content, options, escape, &block)
      end
  end
end
