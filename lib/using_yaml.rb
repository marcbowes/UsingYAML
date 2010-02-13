require 'yaml'
require 'pathname'
require 'using_yaml/open_hash'
require 'using_yaml/patches/hash'

module UsingYAML
  class << self
    def cache
      @@cache ||= {}
    end

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
              using_yaml_file(filename, options)
            end
          end
        end
      end
    end

    def using_yaml_file(filename, options = {})
      define_method(filename) do
        pathname = self.class.using_yaml_path.join("#{filename}.yml").expand_path
        data = UsingYAML.cache[pathname]
        return data if data

        begin
          data = YAML.load_file(pathname).to_ohash(pathname)
          UsingYAML.cache[pathname] = data
        rescue Exception => e
          $stderr.puts "(UsingYAML) Could not load #{filename}: #{e.message}" unless UsingYAML.squelched?
          nil
        end
      end
    end

    def using_yaml_path
      @using_yaml_path ||= Pathname.new(UsingYAML.path(self.inspect) || ENV['HOME'])
    end

    def using_yaml_path=(path)
      @using_yaml_path = path && Pathname.new(path)
    end
  end
end
