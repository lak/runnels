if __FILE__ == $0
    $:.unshift '..'
    $:.unshift '../../lib'
end

require 'runnels'
require 'testrunnels'
require 'test/unit'

class TestMessageClassAttributes < Test::Unit::TestCase
    include TestRunnels

    def teardown
        super
        Runnels::MessageClass::Attribute.clear
    end

    def test_mkattribute
        # test with arguments initially
        attr = nil
        assert_nothing_raised {
            attr = Runnels::MessageClass::Attribute.new(
                :name => "attribute",
                :desc => "This is an attribute"
            )
        }

        # now test manually setting them
        assert_nothing_raised {
            attr.name = "another"
            attr.desc = "A longer yayness"
        }

        # test the allowed attribute list
        assert_raise(ArgumentError) {
            attr = Runnels::MessageClass::Attribute.new(
                "yayness" => :invalid
            )
        }

        # test that the values are ok
        assert_raise(ArgumentError) {
            attr.name = 42
        }
        assert_raise(ArgumentError) {
            attr.desc = :another
        }

        # and test that the same assertions work on initialization
        assert_raise(ArgumentError) {
            attr = Runnels::MessageClass::Attribute.new(
                :name => :invalid
            )
        }
        assert_raise(ArgumentError) {
            attr = Runnels::MessageClass::Attribute.new(
                :desc => :invalid
            )
        }
    end
end

# $Id: attribute.rb 3 2005-12-27 01:50:12Z luke $
