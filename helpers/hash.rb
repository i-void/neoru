class Hash
  def key
    keys[0]
  end

  def value
    values[0]
  end

  def hmap!(&block)
    replace hmap(&block)
  end

  def hmap(&block)
    Hash[self.map {|k, v| block.call(k,v) }]
  end

  def to_query
    URI.escape(self.collect{|k,v| "#{k}=#{v}"}.join('&'))
  end
end