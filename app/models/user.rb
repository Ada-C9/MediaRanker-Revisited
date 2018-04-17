class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

def self.login(user_hash)
  @user = User.new(uid: auth_hash[:uid], provider: auth_hash[:provider], name: auth_hash[:info][:name], email: auth_hash[:info][:email])

end

end

end
