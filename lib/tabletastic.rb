require 'tabletastic/table_builder'
require 'tabletastic/helper'

module Tabletastic
  @@default_table_html = {}
  @@default_table_block = lambda {|table| table.data}

  mattr_accessor :default_table_html, :default_table_block
end
