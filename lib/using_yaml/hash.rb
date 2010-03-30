module UsingYAML
  # Calls add_extensions on all children. Also defines a +save+ method
  # iff this is a top-level UsingYAML object (see below for details).
  def self.add_hash_extensions(hash, pathname)
    # Here we define a Module to extend the hash
    extensions = Module.new do
      # Recursively continue to extend.
      hash.each_pair do |key, value|
        UsingYAML.add_extensions(value)
      end

      define_method(:method_missing) do |*args|
        name = args.shift.to_s

        if args.empty?
          value = send(:[], name)
          value.nil? ? UsingYAML::NilClass : value
        elsif args.size == 1 && name =~ /(.+)=/
          # This is an "alias" turning self.key= into self[key]=
          # Also extends the incoming value so that it behaves
          # consistently with the other key-value pairs.
          key   = $1
          value = args.first

          # Save the value in the hashtable
          send(:[]=, key, UsingYAML.add_extensions(value))

          # Define the new reader (as above)
          new_reader_extension = Module.new do
            define_method(key) do
              send(:[], key) || UsingYAML.add_extensions(nil)
            end
          end
          extend(new_reader_extension)

          value
        else
          super(name, args)
        end
      end

      # Define a save method if a pathname was supplied (only happens
      # on the top-level object - that is, example.foo will have a
      # +save+, but example.foo.bar will not).
      if pathname
        define_method(:save) do
          # Serialise using +to_yaml+
          File.open(pathname, 'w') do |f|
            f.puts self.to_yaml
          end
        end
      end
    end

    # Load in the extensions for this instance
    hash.extend(extensions)
    hash
  end
end
