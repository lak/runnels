if __FILE__ == $0
    $:.unshift '..'
    $:.unshift '../../lib'
end

require 'runnels'
require 'testrunnels'
require 'test/unit'

class TestMessages < Test::Unit::TestCase
    include TestRunnels

    def setup
        super
        initclasses()
        mkmclass("testing", %w{good bad}, %w{foo bar})
        mkmclass("yayness", %w{fast slow}, %w{fu bar})
    end

    def test_missing
        assert_raise(ArgumentError) {
            message = Runnels::Message.new(
                :class => %w{message testing},
                :uuid => "yay"
            )
        }
    end

    def test_mkmessage
        message = nil
        assert_nothing_raised {
            message = Runnels::Message.new(
                :class => %w{message testing},
                :uuid => "yay",
                :sid => "fakesource",
                :time => Time.now.to_s,
                :good => "yep",
                :bad => "mebbe"
            )
        }

        assert_equal("mebbe", message.bad)

        assert_nothing_raised {
            message.foo = "anotherness"
        }

        assert_raise(NoMethodError) {
            message.fast = "hah"
        }
    end
end

# $Id: simple.rb 3 2005-12-27 01:50:12Z luke $
