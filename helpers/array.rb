class Array
  def each_hash
    each do |hash|
      yield hash.key, hash.value
    end
  end
end