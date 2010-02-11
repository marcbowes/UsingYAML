require 'yaml'
require 'pathname'
require 'using_yaml/open_hash'
require 'using_yaml/patches/hash'

module UsingYAML
  class << self
    def cache
      @@cache ||= {}
    end

    def config(klass, key, value = nil)
      @@config ||= {}
      case value
      when nil
        (@@config[klass] ||= {})[key] = value
      else
        @@config[klass]
      end
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
            case value
            when Symbol
              UsingYAML.config(self.class, key, value)
            when Hash
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

        data = YAML.load_file(pathname).to_ohash(pathname)
        UsingYAML.cache[pathname] = data
      end
    end

    def using_yaml_path
      @using_yaml_path ||= Pathname.new(UsingYAML.config(self.class, :pathname) || File.dirname(__FILE__))
    end
  end
end
