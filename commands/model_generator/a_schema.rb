class Neo::Commands::ModelGenerator::ASchema

  def initialize(module_name, name, data)
    @module = module_name
    @name = name.to_s
    @properties = data[:HasProperties]
  end

  def get_index_query(property_name)
    "CREATE INDEX ON :#{@name}(#{property_name});\n"
  end

  def get_unique_query(property_name)
    "CREATE CONSTRAINT ON (n:#{@name}) ASSERT n.#{property_name} IS UNIQUE;\n"
  end

  def generate
    mapper = {'+'=>'unique', '/'=>'index'}
    @properties.reduce(get_unique_query('id')) do |memo, property|
      memo + (/^[\+\/]/===property ? send("get_#{mapper[property[0]]}_query", property[1..-1]) : '')
    end
  end

end