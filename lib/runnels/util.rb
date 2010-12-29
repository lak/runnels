module Runnels
    module Util
        # Take every item in a hash and call the equiv. writer, optionally
        # throwing an exception on missing attributes
        def attr_assign(hash, reject = false)
            hash.each { |opt,val|
                meth = opt.to_s + "="
                begin
                    send meth, val
                    hash.delete opt
                rescue NoMethodError
                    if reject
                        raise ArgumentError,
                            "Classs %s does not accept attribute %s" %
                            [self.class, opt]
                    end
                end
            }
        end

        def clean_hash(hash)
            hash.each { |param, value|
                unless param.is_a?(Symbol)
                    hash.delete(param)
                    hash[param.downcase] = value
                end
            }
        end
    end
end
