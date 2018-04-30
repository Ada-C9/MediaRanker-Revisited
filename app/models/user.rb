class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  # validates :username, uniqueness: true, presence: true

  def self.login(auth_hash)
    user_data = {
      username: auth_hash['info']['nickname'],
      email: auth_hash['info']['email'],
      uid: auth_hash[:uid],
      provider: [:provider]
    }
    user = self.new(user_data)
    if user.save
      return user
    end
  end

end
