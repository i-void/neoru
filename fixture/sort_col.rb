# Sort col class for the fixtures; if a column must be sorted in the way of a foreign collation
#   use this class to create a sorter for that column
class Neo::Fixture::SortCol

	TrSorter = Neo::Fixture::Sorter::TrTr

	# Constructor
	# @param [Neo::Database::Model] model model of the column
	# @param [String] column name of the column
	# @param [Boolean] case_sensitive set to true if you want to seperate capital letter's sort
	# @param [#sort] sorter sorter class for a collation which must respond to sort
	def initialize(model:, column:, case_sensitive:false, sorter:TrSorter)
		@model = model
		@column = column
		@case_sensitive = case_sensitive
		@sorter = sorter
	end

	# @param [String] string which point will be calculated
	def get_point_for(string:)
		sorter = @sorter.new case_sensitive: @case_sensitive
		sorter.get_point_of string
	end

	def set_sort_point_for(string)
		@model.send(@column+'_seq=',get_point_for(string))
	end

end