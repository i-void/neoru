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
    found[0] if found.length > 0
  end

  def find
    set_return('n')
    fill_model(@model)
  end

  def filter_by_id(id)
    self.add_where([['id','=', "'#{id}'"]])
    self
  end

  def count
    set_return 'COUNT(n)'
    self.get
  end

  def get_raw
    set_return 'n'
    self.get
  end
end