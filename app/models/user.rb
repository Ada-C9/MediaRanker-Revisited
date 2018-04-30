class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true


  def self.info_from_github(auth_hash)
    return User.new(
      uid: auth_hash[:uid],
      username: auth_hash[:info][:nickname],
      email: auth_hash[:info][:email],
      provider: auth_hash[:provider]
    )
  end
end
