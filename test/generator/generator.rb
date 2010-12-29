if __FILE__ == $0
    $:.unshift '..'
    $:.unshift '../../lib'
end

require 'runnels'
require 'testrunnels'
require 'test/unit'

class TestGenerator < Test::Unit::TestCase
    include TestRunnels

    def teardown
        super
        Runnels::Generator.allclear
    end

    def test_addinginstances
        assert_nothing_raised {
            Runnels::MessageClass::Attribute.new(
                :name => "attribute",
                :desc => "This is an attribute"
            )
        }

        assert(Runnels::MessageClass::Attribute["attribute"])

        assert_nothing_raised {
            Runnels::MessageClass::Attribute.delete("attribute")
        }

        assert_nil(Runnels::MessageClass::Attribute["attribute"])
    end
end

# $Id: generator.rb 3 2005-12-27 01:50:12Z luke $
