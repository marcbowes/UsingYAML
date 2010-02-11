def OpenHash(hash, pathname = nil)
  Module.new do
    hash.each_pair do |key, value|
      define_method(key) do
        case value
        when Hash
          value.to_ohash
        when Array
          value.collect { |i| i === Hash ? i.to_ohash : i }
        else
          value
        end
      end

      define_method("#{key}=") do |value|
        case value
        when Hash
          send(:[]=, key, value.to_ohash)
        else
          send(:[]=, key, value)
        end
      end
    end

    if pathname
      define_method(:save) do
        File.open(pathname, 'w') do |f|
          f.puts self.to_yaml
        end
      end
    end
  end
end
