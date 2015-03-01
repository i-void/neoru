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
  end

  # Parses data to data attribute
  # @param [String] path of the yml file
  # @return [Hash] parsed data
  def parse_data(path)
    @data.deep_merge! YAML.load(File.read(path, encoding: 'UTF-8'))
  end

  def load
    @paths.each {|path| parse_data path}
    @data.each do |model, value|
      obj = model.to_obj
      value.each do |params|
        obj_instance = obj.new
        params.each do |key,param|
          obj_instance.instance_variable_set('@'+key,param)
        end
        unless sort_col.nil?
          point = send(sorter,obj_instance.send(sort_col),case_insentive)
          obj_instance.send(sort_col+'_seq=',point)
        end
        obj_instance.save
      end
    end
  end
end