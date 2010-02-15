module OpenHash
  class << self
    def from_hash(hash, pathname = nil)
      Module.new do
        hash.each_pair do |key, value|
          define_method(key) do
            value.respond_to?(:to_ohash) ? value.to_ohash(value) : value
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

    def from_array(array, pathname = nil)
      Module.new do
        array.each do |e|
          e.to_ohash(e)
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
  end
end
