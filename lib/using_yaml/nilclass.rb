module UsingYAML
  def self.add_nilclass_extensions(instance, pathname)
    extensions = Module.new do
      define_method(:method_missing) do
        # Child objects should not have #save
        if respond_to? :save
          add_extensions(nil)
        else
          # One nil is the same as the next :)
          self
        end
      end
      
      # Define a save method if a pathname was supplied (only happens
      # on the top-level object - that is, example.foo will have a
      # +save+, but example.foo.bar will not).
      if pathname
        # Being nil translates to "no file", not to "empty file", so we
        # want to actually delete any existing file. This is a semantic
        # difference, but important: there is a huge different between
        # an _empty_ file and a _non-existant_ file. YAML does not
        # reflect this difference, so we do.
        define_method(:save) do
          # If we can't delete it (permissions, ENOENT..), then there
          # ain't much we can do, so just squelch the error.
          FileUtils.rm(pathname) rescue nil
        end
      end
    end

    instance.extend(extensions)
  end
end
