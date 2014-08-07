class Hash
  def key
    keys[0]
  end

  def value
    values[0]
  end

  def hmap!(&block)
    self.keys.each do |key|
      hash = block.call(key, self[key])

      self[hash.keys.first] = hash[hash.keys.first]
      self.delete(key)
    end
    self
  end

  def hmap(&block)
    Hash[self.map {|k, v| block.call(k,v) }]
  end
end