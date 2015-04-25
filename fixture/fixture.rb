# encoding: utf-8
require 'yaml'



# Fixture class for Neoru it parses yml file and adds data to database
class Neo::Fixture

  # Constructor
	# @param [Array] :paths Path of the yml files which will be parsed
	# @param [Neo::Fixture::SortCol] :sort_cols cols which needs collation sorting
	#   * {'Location/City'=> ['name']}
  def initialize(paths:, sort_cols:)
    @paths = paths
		@sort_cols = sort_cols
		@data = {}
    @saved = {}
  end

  # Parses data to data attribute
  # @param [String] path of the yml file
  # @return [Hash] parsed data
  def parse_data(path)
    @data.deep_merge! YAML.load(File.read(path, encoding: 'UTF-8'))
  end

  def models
    @data.each do |model, value|
      model_obj = model.gsub('/', '::Models::').to_obj
      value.each do |props|
        obj = model_obj.new
        data_name, params = props
        params.each do |key,param|
          yield model, data_name, param, key, obj
        end
      end
    end
  end

  def relations

  end

  def load
    @paths.each {|path| parse_data path}
    models do |model, data_name, param, key, obj|
      if not param.is_a? Array and not param.start_with? '+'
        obj.instance_variable_set('@'+key,param)
        if @sort_cols.has_key? model and @sort_cols[model] == key
          SortCol.new(obj,key).set_sort_point_for param
        end
      end
      obj.save
      @saved[data_name] = obj
    end
    models do |model, data_name, param, key, obj|
      if not param.is_a? Array and param.start_with? '+'
        @saved[data_name].relate_to @saved[param.gsub(/^\+/,'')], "Has#{key.camelize}"
      elsif param.is_a? Array
        if param.all? {|p| p.start_with? '+'}
          param.each do |p|
            @saved[data_name].relate_to @saved[p.gsub(/^\+/,'')], "Has#{key.camelize}"
          end
        else
          Neo::Exceptions::SystemError.new(
            "All parameters must include relations in #{model}:#{data_name}:#{key}"
          ).raise
        end
      end
    end
  end
end