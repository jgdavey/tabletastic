module Tabletastic

  def table_for(collection)
    concat(tag(:table, nil, true))
    yield TableBuilder.new(collection, self)
    concat("</table>")
  end

  class TableBuilder

    def initialize(collection, template)
      @collection, @template = collection, template
    end

    def data(*args)
      @fields = args unless args.empty?
      headers +
      body
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
        rows += @template.content_tag_for(:tr, record) do
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
      record.send(method_or_attribute)
    end


    def fields
      return @fields if defined?(@fields)
      if @collection.empty?
        @fields = []
      else
        @fields = @collection.first.class.content_columns.map(&:name)
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