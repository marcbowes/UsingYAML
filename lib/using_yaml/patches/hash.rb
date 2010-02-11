class Hash
  def to_ohash(pathname)
    self.extend OpenHash(self, pathname)
  end
end
