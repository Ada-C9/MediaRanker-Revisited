class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
    return User.new(
      # provider: auth_hash[:provider],
      # uid: auth_hash[:uid],
      # email: auth_hash[:info][:email],
      username: auth_hash[:info][:nickname]
    )
  end
end
