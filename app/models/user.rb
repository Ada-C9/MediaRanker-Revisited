class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)

    user_data = {
      uid: auth_hash[:uid],
      username: auth_hash[:info][:username],
      email: auth_hash[:info][:email],
      provider: auth_hash[:provider]
    }

    user = self.new(user_data)
    if user.save
      return user
    end
  end
end
