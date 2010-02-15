class Hash
  def to_ohash(pathname)
    self.extend OpenHash.from_hash(self, pathname)
  end
end
