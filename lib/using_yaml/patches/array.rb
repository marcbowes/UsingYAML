class Array
  def to_ohash(pathname)
    self.extend OpenHash.from_array(self, pathname)
  end
end
