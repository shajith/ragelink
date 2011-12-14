module Ragelink
  if ENV['NORUBYEXT']
    require "ragelink/pure"
    extend Pure
  else
    require "ragelink/ext"
    extend Ext
  end
end
