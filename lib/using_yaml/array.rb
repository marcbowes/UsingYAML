module UsingYAML
  # Calls add_extensions on all children. Also defines a +save+ method
  # iff this is a top-level UsingYAML object (see below for details).
  def self.add_array_extensions(array, pathname)
    # Here we define a Module to extend the array
    extensions = Module.new do
      # Iterate over the items
      array.each do |item|
        # Recursively continue to extend.
        UsingYAML.add_extensions(item)
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
    array.extend(extensions)
  end
end
