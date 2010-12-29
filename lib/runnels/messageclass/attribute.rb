require 'traits'

module Runnels # :nodoc:
    class MessageClass # :nodoc:
        class Attribute < Runnels::Generator
            # The attributes that make up message classes.  Pretty much just
            # a name and a description.
            trait "name", "type" => String
            trait "desc", "type" => String
        end
    end
end

# $Id: attribute.rb 3 2005-12-27 01:50:12Z luke $
