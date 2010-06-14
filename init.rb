# Include hook code here
require 'tabletastic'

ActiveSupport.on_load(:action_view) do
  include Tabletastic::Helper
end
