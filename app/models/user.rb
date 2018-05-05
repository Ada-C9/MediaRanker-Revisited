class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, presence: true, uniqueness: true

  def self.build_login(auth_hash)
    user_data = {
      uid: auth_hash[:uid],
      username: auth_hash["info"]["nickname"],
      email: auth_hash["info"]["email"],
      provider: auth_hash[:provider]
    }
    user = self.new(user_data)
    if user.save
      return user
    end
  end

end
