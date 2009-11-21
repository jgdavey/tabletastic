module Tabletastic

  # returns and outputs a table for the given active record collection
  def table_for(collection, *args)
    klass = default_class_for(collection)
    options = args.extract_options!
    options[:html] ||= {}
    options[:html][:id] ||= get_id_for(klass)
    concat(tag(:table, options[:html], true))
    yield TableBuilder.new(collection, klass, self)
    concat("</table>")
  end

  private
  # Finds the class representing the objects within the collection
  def default_class_for(collection)
    if collection.respond_to?(:proxy_reflection)
      collection.proxy_reflection.klass
    elsif !collection.empty?
      collection.first.class
    end
  end

  def get_id_for(klass)
    klass.to_s.tableize
  end

  class TableBuilder
    @@association_methods = %w[display_name full_name name title username login value to_s]
    attr_accessor :field_labels
    attr_reader   :collection, :klass

    def initialize(collection, klass, template)
      @collection, @klass, @template = collection, klass, template
    end

    # builds up the fields that the table will include,
    # returns table head and body with all data
    #
    # Can be used one of three ways:
    #
    #   * Alone, which will try to detect all content columns on the resource
    #   * With an array of methods to call on each element in the collection
    #   * With a block, which assumes you will use +cell+ method to build up
    #     the table
    #
    #
    def data(*args, &block) # :yields: the TableBuilder instance
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

    # individually specify a column, which will build up the header,
    # and method or block to call on each resource in the array
    #
    # Should always be called within the block of +data+
    #
    # For example:
    #
    #   t.cell :blah
    #
    # will simply call +blah+ on each resource
    #
    # You can also provide a block, which allows for other helpers
    # or custom formatting. Since by default erb will just call +to_s+
    # on an any element output, you can more greatly control the output:
    #
    #   t.cell(:price) {|resource| number_to_currency(resource)}
    #
    # would output something like:
    #
    #   <td>$1.50</td>
    #
    def cell(*args, &block)
      options = args.extract_options!
      @field_labels ||= []
      @fields ||= []

      method_or_attribute = args.first.to_sym

      if cell_html = options.delete(:cell_html)
        @fields << [method_or_attribute, cell_html]
      elsif block_given?
        @fields << block.to_proc
      else
        @fields << method_or_attribute
      end

      if heading = options.delete(:heading)
        @field_labels << heading
      else
        @field_labels << method_or_attribute.to_s.humanize
      end
      # Since this will likely be called with <%= %> (aka 'concat'), explicitly return an empty string
      # This suppresses unwanted output
      return ""
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
          cells_for_row(record)
        end
      end
    end

    def cells_for_row(record)
      fields.inject("") do |cells, field_or_array|
        field = field_or_array
        if field_or_array.is_a?(Array)
          field = field_or_array.first
          html_options = field_or_array.last
        end
        cells += content_tag(:td, cell_data(record, field), html_options)
      end
    end

    def cell_data(record, method_or_attribute_or_proc)
      # Get the attribute or association in question
      result = send_or_call(record, method_or_attribute_or_proc)
      # If we already have a string, just return it
      return result if result.is_a?(String)

      # If we don't have a string, its likely an association
      # Try to detect which method to use for stringifying the attribute
      to_string = detect_string_method(result)
      result.send(to_string) if to_string
    end

    def fields
      return @fields if defined?(@fields)
      @fields = @collection.empty? ? [] : active_record_fields
    end

    protected

    def detect_string_method(association)
      @@association_methods.detect { |method| association.respond_to?(method) }
    end


    def active_record_fields
      return [] if klass.blank?
      # normal content columns
      fields = klass.content_columns.map(&:name)

      # active record associations
      if klass.respond_to?(:reflect_on_all_associations)
        associations = klass.reflect_on_all_associations(:belongs_to)
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

    private

    def send_or_call(object, duck)
      if duck.respond_to?(:call)
        duck.call(object)
      else
        object.send(duck)
      end
    end
  end
end
