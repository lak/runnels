module Runnels
    class Message
        # Actual message instances.  These are members of one or more
        # classes.
        include Runnels::Util
        def initialize(hash)
            clean_hash(hash)

            unless hash.include? :class
                raise RunnelsError, "Invalid message: Missing class names"
            end

            unless hash[:class].is_a? Array
                hash[:class] = [hash[:class]]
            end

            # Make sure the message includes the top-level class
            unless hash[:class].include?("message")
                hash[:class].unshift "message"
            end

            @messageclasses = []

            # Extend this object with the module associated with each class
            hash[:class].each { |klass|
                if mclass = Runnels::MessageClass[klass.downcase]
                    mod = mclass.to_module
                    self.extend mod
                    @messageclasses << mclass
                else
                    raise ArgumentError, "Unknown class '%s'" % klass
                end
            }

            # Now assign each of the values.
            hash.each { |param, value|
                begin
                    self.send(param.to_s + "=", value)
                rescue NoMethodError => detail
                    raise ArgumentError, "Attribute %s is invalid" % param
                end
            }

            # Make sure none of the required attributes are missing.
            if attrs = self.missing
                raise ArgumentError, "Missing attributes '%s'" % attrs.join(" ")
            end
        end

        # Which required attributes are missing?
        def missing
            attrs = self.required.find_all { |attr|
                self.send(attr).nil?
            }

            if attrs.empty?
                return nil
            else
                return attrs
            end
        end

        # The entire list of required attributes.
        def required
            @messageclasses.collect { |mc|
                mc.required
            }.flatten.uniq
        end
    end
end
