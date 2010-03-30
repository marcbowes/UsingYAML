require 'yaml'
require 'pathname'

Dir[File.join(File.dirname(__FILE__), 'using_yaml/*')].each do |ext|
  require ext
end

# UsingYAML provides convenient class extensions which make it easy to
# interact with YAML-storage of settings files by defining accessors
# which allow one to talk to the files as if they were fully
# implemented classes.
#
# Each of these files will be automagically enhanced to provide save
# and clean methods of talking to your YAML files without needing to
# worry about checking for nil's, re-serializing or long-winded hash
# access.
#
# This module also provides some static access to make it easy to
# enable/disable options such as squelching error messages (in
# production) and tracking where instances should load their files
# from.
#
# See +using_yaml+ for usage information.
module UsingYAML
  NilClass = add_nilclass_extensions(nil, nil)
  
  class << self
    # Extends the incoming Array/Hash with magic which makes it
    # possible to +save+ and (in the case of Hashes) use methods
    # instead of []-access.
    def add_extensions(object, pathname = nil)
      case object
      when Array
        add_array_extensions(object, pathname)
      when Hash
        add_hash_extensions(object, pathname)
      when ::NilClass
        if pathname
          add_nilclass_extensions(object, pathname)
        else
          UsingYAML::NilClass
        end
      end
            
      object
    end
  
    # Returns the path where the given class will load from. See
    # +using_yaml_path+ for information on how to override this on a
    # per-instance basis.
    def path(klass)
      return @@path[klass] if defined?(@@path)
    end

    # Sets the the path where the given class will load from. See
    # +using_yaml_path+ for information on how to override this on a
    # per-instance basis.
    def path=(args)
      (@@path ||= {})[args.first] = args.last
    end

    # Because of the "safety" UsingYAML provides, it is easy for typos
    # to creep in, which might result in unexpected nil's. UsingYAML
    # therefore is verbose in warning about these potential errors.
    #
    # This method disables those warnings, which is useful in a
    # production environment or if you are sure you aren't making mistakes.
    def squelch!
      @@squelched = true
    end

    # Returns true if UsingYAML will warn about potential typos (or
    # similar) which might otherwise be masked.
    def squelched?
      defined?(@@squelched) && @@squelched
    end

    # Opposite of +squelch!+
    def unsquelch!
      @@squelched = false
    end
  end
  
  def self.included(base)
    base.extend UsingYAML::ClassMethods
  end

  module ClassMethods
    # Used to configure UsingYAML for a class by defining what files
    # should be loaded and from where.
    #
    #   include UsingYAML
    #   using_yaml :foo, :bar, :path => "/some/where"
    #
    # +args+ can contain either filenames or a hash which specifices a
    # path which contains the corresponding files.
    #
    # The value of :path must either be a string or Proc (see
    # +using_yaml_path+ for more information on overriding paths).
    def using_yaml(*args)
      # Include the instance methods which provide accessors and
      # mutators for reading/writing from/to the YAML objects.
      include InstanceMethods

      # Each argument is either a filename or a :path option
      args.each do |arg|
        case arg
        when Symbol, String
          # Define accessors for this file
          using_yaml_file(arg.to_s)
        when Hash
          # Currently only accepts { :path => ... }
          next unless arg.size == 1 && arg.keys.first == :path
          
          # Take note of the path
          UsingYAML.path = [self.inspect, arg.values.first]
        end
      end
    end

    # Special attr_accessor for the suppiled +filename+ such that
    # files are intelligently loaded/written to disk.
    #
    #   using_yaml_file(:foo) # => attr_accessor(:foo) + some magic
    #
    # If class Example is setup with the above, then:
    #
    #   example = Example.new
    #   example.foo      # => loads from foo.yml
    #   example.foo.bar  # => equivalent to example.foo['bar']
    #   example.foo.save # => serialises to foo.yml
    #
    def using_yaml_file(filename)
      # Define an reader for filename such that the corresponding
      # YAML file is loaded. Example: using_yaml_file(:foo) will look
      # for foo.yml in the specified path.
      define_method(filename) do
        # Work out the absolute path for the filename and get a handle
        # on the cachestore for that file.
        pathname = using_yaml_path.join("#{filename}.yml").expand_path
        yaml     = (@using_yaml_cache ||= {})[pathname]

        # If the yaml exists in our cache, then we don't need to hit
        # the disk.
        return yaml if yaml

        # Safe disk read which either reads and parses a YAML object
        # (and caches it against future reads) or graciously ignores
        # the file's existence. Note that an error will appear on
        # stderr to avoid typos (or similar) from causing unexpected
        # behavior. See +UsingYAML.squelch!+ if you wish to hide the
        # error.
        begin
          @using_yaml_cache[pathname] = UsingYAML.add_extensions(YAML.load_file(pathname), pathname)
        rescue Exception => e
          $stderr.puts "(UsingYAML) Could not load #{filename}: #{e.message}" unless UsingYAML.squelched?
          @using_yaml_cache[pathname] = UsingYAML.add_extensions(nil, pathname)
        end
      end

      # Define a writer for filename such that the incoming object is
      # treated as a UsingYAML-ized Hash (magical properties). Be
      # aware that the incoming object will not be saved to disk
      # unless you explicitly do so.
      define_method("#{filename}=".to_sym) do |object|
        # Work out the absolute path for the filename and get a handle
        # on the cachestore for that file.
        pathname = using_yaml_path.join("#{filename}.yml").expand_path
        (@using_yaml_cache ||= {})[pathname] = UsingYAML.add_extensions(object, pathname)
      end
    end
  end

  # Instance methods which allow us to define where YAML files are
  # read/written from/to.
  module InstanceMethods
    # Reader which determines where to find files according to the
    # following recipe:
    #
    #   (1) Load the :path option from +using_yaml+, if set
    #   (2) Possibly invoke a Proc (if supplied to step 1)
    #   (3) Default to the current location if 1 & 2 failed
    #
    # You can, of course, overrite this method if you wish to supply
    # your own logic.
    def using_yaml_path
      return @using_yaml_path unless @using_yaml_path.nil?
      
      path = UsingYAML.path(self.class.name)
      path = path.call(self) if path.is_a? Proc
      @using_yaml_path = Pathname.new(path || '.')
    end

    # Sets the YAML load path to the given argument by invoking
    # +Pathname.new+ on +path+.
    def using_yaml_path=(path)
      @using_yaml_path = path && Pathname.new(path)
    end
  end
end
