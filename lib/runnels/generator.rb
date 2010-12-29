require 'traits'

module Runnels # :nodoc:
    class Generator # :nodoc:
        # A simple base class for MessageClass and MessageClass::Attribute.
        # It should probably be elsewhere in the file heirarchy, but...
        include Runnels::Util

        @subclasses = []

        # Retrieve an instance by name.
        def self.[](name)
            @instances[name]
        end

        # Store a new instance.
        def self.[]=(name,attr)
            if @instances.include?(name)
                raise ArgumentError,
                    "Instance of class %s with name %s already exists" %
                    [self, name]
            else
                @instances[name] = attr
            end
        end

        # Add a new instance.
        def self.<<(val)
            unless val.is_a?(self) and val.respond_to?(:name)
                raise ArgumentError, "Cannot accept instances of %s" % val.class
            end
            self[val.name] = val
        end

        # Remove subclasses' existing instances.
        def self.allclear
            @subclasses.each { |sub| sub.clear }
        end

        # Remove existing instances.
        def self.clear
            @instances.clear
        end

        # Remove an individual instance.
        def self.delete(name)
            @instances.delete(name)
        end

        # A new subclass is created.
        def self.inherited(subclass)
            subclass.initvars
            @subclasses << subclass
        end

        # Initialize the class variables.  Mostly just called from the
        # superclasses 'inherited' method.
        def self.initvars
            @instances = {}
        end

        def initialize(opts = {})
            attr_assign(opts, true)
            self.class[self.name] = self
        end
    end
end

# $Id: generator.rb 3 2005-12-27 01:50:12Z luke $
