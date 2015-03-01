# sorter class for Turkish collation
class Neo::Fixture::Sorter::TrTr

	def initialize(case_sensitive:true)
		@case_sensitive = case_sensitive
	end

	# Calculates a sort point
	#   you can save this into a db column and order by with this
	# @param [String] string keyword which point will be calculated
	def get_point_of(string)
		arr = %w(_ 1 2 3 4 5 6 7 8 9 0 a b c ç d e f g ğ h ı i j k l m n o ö p q r s ş t u ü v w x y z)
		cap = %w(_ _ _ _ _ _ _ _ _ _ _ A B C Ç D E F G Ğ H I İ J K L M N O Ö P Q R S Ş T U Ü V W X Y Z)
		step = 100000.0
		string.split('').reduce(0.0) do |memo, letter|
			index = arr.find_index(letter)
			memo += (index+1)*step unless index.nil?
			index = cap.find_index(letter)
			unless index.nil?
				memo += @case_sensitive ? (index+1)*step : ((index+1)+arr.length)*step
			end
			step = step/arr.length
			step = step/2 unless @case_sensitive
			memo
		end
	end

end