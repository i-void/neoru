class Neo::Database::ModelQuery < Neo::Database::Cypher
  attr_accessor :model,:labels
  def initialize
    super
    module_name, class_name = self.class.name.scan(/(.+)::Models::(.+)Query/)[0]
    @model = Kernel.const_get(module_name).const_get('Models').const_get(class_name)
    @labels = @model.new.labels
    @labels = [@labels] if @labels.kind_of?(String)
    add_match('n',@labels+ [Neo::Config.main[:db][:name]])
  end

  def find_one
    set_limit(1)
    found = find
    return found[0] if found.length > 0
    return nil
  end

  def find
    set_return('n')
    return fill_model(@model)
  end

  def filter_by_id(id)
    self.add_where([['id','=', "'#{id}'"]])
    return self
  end
end