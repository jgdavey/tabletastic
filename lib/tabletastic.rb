module Tabletastic

  # returns and outputs a table for the given active record collection
  def table_for(collection, *args)
    klass = default_class_for(collection)
    options = args.extract_options!
    options[:html] ||= {}
    options[:html][:id] ||= get_id_for(klass)
    concat(tag(:table, options[:html], true))
    yield TableBuilder.new(collection, klass, self)
    concat("</table>".html_safe)
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
    @@default_hidden_columns = %w[created_at updated_at created_on updated_on lock_version version]
    @@destroy_confirm_message = "Are you sure?"

    attr_accessor :field_labels
    attr_reader   :collection, :klass, :fields

    def initialize(collection, klass, template)
      @collection, @klass, @template = collection, klass, template
      @field_labels = []
    end

    # builds up the fields that the table will include,
    # returns table head and body with all data
    #
    # Can be used one of three ways:
    #
    # * Alone, which will try to detect all content columns on the resource
    # * With an array of methods to call on each element in the collection
    # * With a block, which assumes you will use +cell+ method to build up
    #   the table
    #
    #
    def data(*args, &block) # :yields: tablebody
      options = args.extract_options!
      if block_given?
        @fields = []
        yield self
        action_cells(options[:actions], options[:action_prefix])
        @template.concat(head.html_safe)
        @template.concat(body.html_safe)
      else
        @fields = args.empty? ? active_record_fields : args
        @field_labels = fields.map { |f| f.to_s.humanize }
        action_cells(options[:actions], options[:action_prefix])
        [head, body].join("").html_safe
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
    def cell(*args, &proc)
      options = args.extract_options!
      method = args.first.to_sym
      method_or_proc = block_given? ? proc : method

      @fields << [method_or_proc, options.delete(:cell_html)]

      @field_labels << (options.delete(:heading) || method.to_s.humanize).html_safe
      # Since this will likely be called with <%= %> (aka 'concat'), explicitly return an empty string
      # This suppresses unwanted output
      return ""
    end

    def head
      content_tag(:thead) do
        content_tag(:tr) do
          self.field_labels.inject("") do |result,field|
            result += content_tag(:th, field)
          end
        end
      end
    end

    def body
      content_tag(:tbody) do
        @collection.inject("") do |rows, record|
          rowclass = @template.cycle("odd","even")
          rows += @template.content_tag_for(:tr, record, :class => rowclass) do
            cells_for_row(record)
          end
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

    # Used internally to build up cells for common CRUD actions
    def action_cells(actions, prefix = nil)
      return if actions.blank?
      actions = [actions] if !actions.respond_to?(:each)
      actions = [:show, :edit, :destroy] if actions == [:all]
      actions.each do |action|
        action_link(action.to_sym, prefix)
      end
    end

    # Dynamically builds links for the action
    def action_link(action, prefix)
      html_class = "actions #{action.to_s}_link"
      self.cell(action, :heading => "", :cell_html => {:class => html_class}) do |resource|
        compound_resource = [prefix, resource].compact
        case action
        when :show
          @template.link_to("Show", compound_resource)
        when :destroy
          @template.link_to("Destroy", compound_resource, :method => :delete, :confirm => @@destroy_confirm_message)
        else # edit, other resource GET actions
          @template.link_to(action.to_s.titleize, @template.polymorphic_path(compound_resource, :action => action))
        end
      end
    end

    protected

    def detect_string_method(association)
      @@association_methods.detect { |method| association.respond_to?(method) }
    end


    def active_record_fields
      return [] if klass.blank?
      fields = klass.content_columns.map(&:name)
      fields += active_record_association_reflections
      fields -= @@default_hidden_columns
      fields = fields.map(&:to_sym)
    end

    def active_record_association_reflections
      return [] unless klass.respond_to?(:reflect_on_all_associations)
      associations = klass.reflect_on_all_associations(:belongs_to).map(&:name)
    end

    private

    def content_tag(name, content = nil, options = nil, escape = true, &block)
      @template.content_tag(name, content, options, escape, &block)
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
