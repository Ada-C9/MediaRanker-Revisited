class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true


  def self.build_from_github(auth_hash)

    user_hash = {
      :username => auth_hash['info']['name'],
      :email => auth_hash['info']['email'],
      :uid => auth_hash['uid'],
      :provider => auth_hash['provider']
    }

    new_user = User.new(user_hash)

    if new_user.save
      return new_user
    else
      return nil
    end
  end
end
