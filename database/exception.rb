# encoding: utf-8
class Neo::Database::Exception < Neo::Exception
  def initialize(msg)
    super(500,msg)
  end
end