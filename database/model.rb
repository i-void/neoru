class Neo::Database::Model
  attr_accessor :id

  def labels=(labels)
    @labels = labels
  end
  def labels
    return @labels
  end
  def save
    node = Node.new.fill_from_model(self)
    @id = node.upsert
  end
  def relate_to(node,relation_name,props={})
    self_node = Node.new.fill_from_model(self)
    node = Node.new.fill_from_model(node)
    self_node.relate_to(node,relation_name,props)
  end

  class << self
    #@param data Hash :hash data which will fill the model ex;{id:3}
    def fill_model(data)
      new_model = self.new
      methods = new_model.methods
      data.each do |k,v|
        if methods.include?((k+'=').to_sym)
          new_model.send(k+'=',v)
        end
      end
      return new_model
    end
  end
end