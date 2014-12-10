module DeepMerge
  def look_into_deep(k,v)
    if [self[k],v].all? { |item| item.class.name == 'Hash' }
      self[k].deep_merge! v
    elsif [self[k],v].all? { |item| item.class.name == 'Array' }
      self[k] = (self[k] + v).uniq
    else
      self[k] = v
    end
  end

  def deep_merge!(second)
    if second.class.name == 'Hash'
      second.each { |k, v| (self.has_key? k) ? look_into_deep(k, v) : self[k] = v }
    else
      raise "Error: You cannot merge a Hash with #{second.class.name}"
    end
  end

  def deep_merge(second)
    if second.class.name == 'Hash'
      temp = self.clone
      temp.deep_merge!(second)
      temp
    else
      raise "Error: You cannot merge a Hash with #{second.class.name}"
    end
  end
end

class Hash
  include DeepMerge

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