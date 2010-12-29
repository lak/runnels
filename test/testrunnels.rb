libdir = File.join(File.dirname(__FILE__), '../lib')
unless $:.include?(libdir)
    $:.unshift libdir
end

require 'runnels'
require 'facter'
require 'fileutils'
require 'test/unit'

class RunnelsTestSuite
    attr_accessor :subdir

    def self.list
        Dir.entries(".").find_all { |file|
            FileTest.directory?(file) and file !~ /^\./
        }
    end

    def initialize(name)
        unless FileTest.directory?(name)
            puts "TestSuites are directories containing test cases"
            puts "no such directory: %s" % name
            exit(65)
        end

        # load each of the files
        Dir.entries(name).collect { |file|
            File.join(name,file)
        }.find_all { |file|
            FileTest.file?(file) and file =~ /\.rb$/
        }.sort { |a,b|
            # in the order they were modified, so the last modified files
            # are loaded and thus displayed last
            File.stat(b) <=> File.stat(a)
        }.each { |file|
            require file
        }
    end
end

module TestRunnels
    def setup
        if defined? @@testcount
            @@testcount += 1
        else
            @@testcount = 0
        end

        @@tmpfiles = [tmpdir()]
        @@tmppids = []

        if $0 =~ /.+\.rb/
            $VERBOSE = 1
        end
    end

    def teardown
        @@tmpfiles.each { |file|
            if FileTest.exists?(file)
                system("chmod -R 755 %s" % file)
                system("rm -rf %s" % file)
            end
        }
        @@tmpfiles.clear

        @@tmppids.each { |pid|
            %x{kill -INT #{pid} 2>/dev/null}
        }
        @@tmppids.clear
        Runnels::Generator.allclear
    end

    def tmpdir
        unless defined? @tmpdir and @tmpdir
            @tmpdir = case Facter["operatingsystem"].value
            when "Darwin": "/private/tmp"
            when "SunOS": "/var/tmp"
            else
                "/tmp"
            end

            @tmpdir = File.join(@tmpdir, "puppettesting")

            unless File.exists?(@tmpdir)
                FileUtils.mkdir_p(@tmpdir)
                File.chmod(01777, @tmpdir)
            end
        end
        @tmpdir
    end

    def tempfile
        if defined? @tmpfilenum
            @tmpfilenum += 1
        else
            @tmpfilenum = 1
        end
        f = File.join(self.tmpdir(), self.class.to_s +
            "testfile" + @tmpfilenum.to_s)
        @@tmpfiles << f
        return f
    end

    def basedir
        if defined? @testdirnum
            @testdirnum += 1
        else
            @testdirnum = 1
        end
        d = File.join(self.tmpdir(), self.class.to_s +
            "testdir" + @testdirnum.to_s)
        @@tmpfiles << d
        return d
    end

    def mkattrs(*names)
        names.flatten.each { |name|
            next if Runnels::MessageClass::Attribute[name]
            assert_nothing_raised("Could not create attribute %s" % name) {
                Runnels::MessageClass::Attribute.new(
                    :name => name,
                    :desc => "Attribute %s" % name
                )
            }
        }
    end

    def mkmclass(name, must = [], may = [])
        mclass = Runnels::MessageClass.new(:name => name)
        unless must.empty?
            mkattrs(must)
            mclass.must = must
        end
        unless may.empty?
            mkattrs(may)
            mclass.may = may
        end
        mclass
    end

    def initclasses
        mkmclass("message", %w{class uuid sid time}, %w{tag reply replyto})
    end
end

# $Id: testrunnels.rb 3 2005-12-27 01:50:12Z luke $
