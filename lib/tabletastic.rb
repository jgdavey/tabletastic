require 'tabletastic/table_builder'

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
end
