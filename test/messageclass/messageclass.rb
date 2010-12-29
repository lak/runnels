if __FILE__ == $0
    $:.unshift '..'
    $:.unshift '../../lib'
end

require 'runnels'
require 'testrunnels'
require 'test/unit'

class TestMessageClass < Test::Unit::TestCase
    include TestRunnels

    def test_nameanddesc
        # test with arguments initially
        attr = nil
        assert_nothing_raised {
            attr = Runnels::MessageClass.new(
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
            attr = Runnels::MessageClass.new(
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
            attr = Runnels::MessageClass.new(
                :name => :invalid
            )
        }
        assert_raise(ArgumentError) {
            attr = Runnels::MessageClass.new(
                :desc => :invalid
            )
        }
    end

    # Test that superior classes are retrieved
    def test_sup
        sub = nil
        assert_nothing_raised {
            Runnels::MessageClass.new(
                :name => "base"
            )
            sub = Runnels::MessageClass.new(
                :name => "sub",
                :sup => "base"
            )
        }

        assert_instance_of(Runnels::MessageClass, sub.sup)
    end

    # First test with a single attr
    def test_singleattr
        sub = nil
        mkattrs("a")

        assert_nothing_raised("Could not use attributes") {
            sub = Runnels::MessageClass.new(
                :name => "sub",
                :must => "a"
            )
        }

        sub.must.each { |val|
            assert_instance_of(Runnels::MessageClass::Attribute, val)
        }
    end

    # Then with multiple
    def test_multiattrs
        mkattrs(%w{a b})

        sub = nil
        assert_nothing_raised("Could not use attributes") {
            sub = Runnels::MessageClass.new(
                :name => "other",
                :must => %w{a b}
            )
        }

        sub.must.each { |val|
            assert_instance_of(Runnels::MessageClass::Attribute, val)
        }
    end

    # Test module creation
    def test_mkmodule
        mkattrs(%w{a b c d})

        sub = nil
        assert_nothing_raised("Could not use attributes") {
            sub = Runnels::MessageClass.new(
                :name => "base",
                :must => %w{a b},
                :may => %w{c d}
            )
        }

        mod = nil
        assert_nothing_raised("Could not convert to module") {
            mod = sub.to_module
        }

        assert_instance_of(Module, mod)

        # Now test that we can extend and assign with this module
        a = "yayness"
        assert_nothing_raised {
            a.extend(mod)
        }

        assert_nothing_raised {
            a.a = "boo"
            a.b = "boo"
        }

        # Make sure all of the methods are there
        %w{a b c d}.each { |meth|
            assert(mod.instance_methods.include?(meth),
                "Missing instance method %s" % meth)
            assert(a.respond_to?(meth), "Thing does not respond to %s" % meth)
            assert(a.respond_to?(meth + "="),
                "Thing does not respond to %s" % meth + "=")
        }

    end
end

# $Id: messageclass.rb 3 2005-12-27 01:50:12Z luke $
