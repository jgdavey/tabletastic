# Include hook code here
require File.join(File.dirname(__FILE__), *%w[.. lib tabletastic])
ActionView::Base.send :include, Tabletastic