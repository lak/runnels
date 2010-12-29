require 'traits'

module Runnels
    # This class is used to generate modules, and the generated modules will
    # support all of the attributes that the class definition provided.  The
    # modules will also provide facilities for checking whether all required
    # attributes are provided.
    class MessageClass < Runnels::Generator
        require 'runnels/messageclass/attribute'
        include Runnels::Util

        def names2attrs(*names)
            names.flatten.collect { |name|
                Runnels::MessageClass::Attribute[name] or
                    raise(ArgumentError, "Unknown attribute '%s'" % name)
            }
        end

        def name2messageclass(name)
            self.class[name] or
                raise(ArgumentError, "Unknown message class '%s'" % name)
        end

        trait "name", "type" => String
        trait "desc", "type" => String

        # We can't use this typing validator, because the 'type_hook' is
        # before the cast hook.
        #trait "sup", "type" => String, "cast" => :to_messageclass
        trait "sup", "cast" => :name2messageclass
        trait "must", "cast" => :names2attrs
        trait "may", "cast" => :names2attrs

        # The list of all valid attributes for this specific class (not including
        # superclasses).
        def attributes
            [self.must, self.may].flatten.reject { |attr|
                attr.nil?
            }.collect { |attr|
                attr.name
            }
        end

        # Is the attribute optional?
        def optional?(attr)
            self.may.include?(
                Runnels::MessageClass::Attribute[attr]
            )
        end

        # Return the list of required attributes
        def required
            self.must.collect { |attr|
                attr.name
            }
        end

        # Is the attribute required?
        def required?(attr)
            self.must.include?(
                Runnels::MessageClass::Attribute[attr]
            )
        end

        # Convert the current message class to a Ruby module and return
        # the module
        def to_module
            unless defined? @module
                mclass = self
                @module = Module.new do
                    def self.messageclass
                        mclass
                    end

                    def self.optional?(attr)
                        mclass.optional?(attr)
                    end

                    def self.superior
                        mclass.sup
                    end

                    # This isn't right, since the attributes are often
                    # multi-valued.  I'm also not doing any evaluation
                    # of the values to make sure they're valid.
                    # Crapper.
                    attr_accessor(*mclass.attributes)
                end
            end
            return @module
        end

        # Is the attribute valid?
        def valid?(attr)
            required?(attr) or optional?(attr) or self.sup.valid?(attr)
        end
    end
end

# $Id: messageclass.rb 3 2005-12-27 01:50:12Z luke $
