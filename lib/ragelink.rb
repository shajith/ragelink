module Ragelink
  if ENV['NO_EXT']
    require "ragelink/pure"
    extend Pure
  else
    require "ragelink/ext"
    extend Ext
  end
end
