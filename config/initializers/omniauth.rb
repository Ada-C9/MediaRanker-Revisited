Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], scope: "user:email"
end
