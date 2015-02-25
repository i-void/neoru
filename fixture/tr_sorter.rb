class Neo::Fixture::TrSorter

	def initialize(options)
		@case_sensitive = (options[:case_sensitive] || true)
	end

	def point_of(subject)
		point = 0.0
		arr = %w(0 1 2 3 4 5 6 7 8 9 a  b  c  ç  d  e  f  g  ğ  h  ı  i  j  k  l  m  n  o  ö  p  q  r  s  ş  t  u  ü  v  w  x  y  z)
		cap = %w(# # # # # # # # # # A  B  C  Ç  D  E  F  G  Ğ  H  I  İ  J  K  L  M  N  O  Ö  P  Q  R  S  Ş  T  U  Ü  V  W  X  Y  Z)
		step = 100000.0
		subject.split('').each do |letter|
			index = arr.find_index(letter)
			point += (index+1)*step unless index.nil?
			index = cap.find_index(letter)
			unless index.nil?
				point += @case_sensitive ? (index+1)*step : ((index+1)+arr.length)*step
			end
			step = step/arr.length
			step = step/2 unless @case_sensitive
		end
		point
	end


end