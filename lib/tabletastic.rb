require 'tabletastic/table_builder'

module Tabletastic
  # returns and outputs a table for the given active record collection
  def table_for(collection, *args, &block)
    raise ArgumentError, "you must provide a block" unless block_given?
    klass = default_class_for(collection)
    options = args.extract_options!
    options[:html] ||= {}
    options[:html][:id] ||= get_id_for(klass)
    result = block.call(TableBuilder.new(collection, klass, self))
    content_tag(:table, result, options[:html])
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
    klass ? klass.model_name.collection : ""
  end
end
