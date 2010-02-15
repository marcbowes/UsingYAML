require 'yaml'
require 'pathname'
require 'using_yaml/open_hash'
require 'using_yaml/patches/array'
require 'using_yaml/patches/hash'

module UsingYAML
  class << self
    def path(klass)
      return @@path[klass] if defined?(@@path)
    end

    def path=(args)
      (@@path ||= {})[args.first] = args.last
    end

    def squelch!
      @@squelched = true
    end

    def squelched?
      defined?(@@squelched) && @@squelched
    end
  end
  
  def self.included(base)
    base.extend UsingYAML::ClassMethods
  end

  module ClassMethods
    def using_yaml(*args)
      include InstanceMethods
      
      args.each do |arg|
        case arg
        when Symbol, String
          filename = arg.to_s
          using_yaml_file(filename)
        when Hash
          arg.each do |key, value|
            case key
            when :path
              UsingYAML.path = [self.inspect, value]
            else
              filename = key
              options  = value
              using_yaml_file(filename)
            end
          end
        end
      end
    end

    def using_yaml_file(filename)
      define_method(filename) do
        pathname = using_yaml_path.join("#{filename}.yml").expand_path
        cache    = (@using_yaml_cache ||= {})
        data     = @using_yaml_cache[pathname]
        return data if data

        begin
          data = YAML.load_file(pathname).to_ohash(pathname)
          @using_yaml_cache[pathname] = data
        rescue Exception => e
          $stderr.puts "(UsingYAML) Could not load #{filename}: #{e.message}" unless UsingYAML.squelched?
          nil
        end
      end
    end
  end

  module InstanceMethods
    attr_accessor :using_yaml_cache
    
    def using_yaml_path
      path = UsingYAML.path(self.class.name)
      path = path.call(self) if path.is_a? Proc
      @using_yaml_path ||= Pathname.new(path || ENV['HOME'])
    end

    def using_yaml_path=(path)
      @using_yaml_path = path && Pathname.new(path)
    end
  end
end
