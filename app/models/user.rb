class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :uid, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :email, presence: true # might be redundant with github needing an email

  def self.get_user(data_hash)
    user = User.find_by(uid: data_hash[:uid], provider: data_hash['provider'])
    if user.nil?
      user_data = {
        uid: data_hash['uid'],
        provider: data_hash['provider'],
        name: data_hash['info']['name'],
        email: data_hash['info']['email']
      }
      user = User.new(user_data)
      return user.save ? user : nil
    end
    return user
  end


end
