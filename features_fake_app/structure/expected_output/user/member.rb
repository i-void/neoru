class User::Models::Member < Neo::Database::Model
  MemberQuery = User::Models::MemberQuery
  RoleQuery = Auth::Models::RoleQuery
  IdentityQuery = Auth::Models::IdentityQuery

  attr_accessor :last_visit, :ip

  def initialize
    @labels = 'Member'
  end


  def get_all_friend
    MemberQuery.new.friend_of_member(self).find
  end

  def get_all_role
    RoleQuery.new.role_of_member(self).find
  end

  def get_identity
    IdentityQuery.new.identity_of_member(self).find_one
  end

  def set_identity(identity)
    prev = get_identity
    if prev and prev != identity
      self.unrelate_to identity, 'HasIdentity'
    end
    if not prev or prev != identity
      self.relate_to identity, 'HasIdentity'
    end
  end
end
