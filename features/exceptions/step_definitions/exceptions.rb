Then(/^Raise SystemError exception$/) do
	expect {
		Neo::Exceptions::SystemError.new('There is a system error').raise
	}.to raise_error(Neo::Exceptions::SystemError)
end

Then(/^Raise DatabaseError exception$/) do
	expect {
		Neo::Exceptions::DatabaseError.new('There is a database error').raise
	}.to raise_error(Neo::Exceptions::DatabaseError)
end