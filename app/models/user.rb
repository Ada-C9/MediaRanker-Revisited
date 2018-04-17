class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.get_info_from_authhash

    auth_hash = request.env['omniauth.auth']

    @user = User.new(username: auth_hash['info']['username'], email: auth_hash['info']['email'], uid: auth_hash['uid'],
      provider: auth_hash['provider'])

      if @user.save
        #saved successfully
        session[:user_id]= @user.id
        flash[:sucess] = "Logged in successfully"
        redirect_to root_path
      end
    end
  end
end
