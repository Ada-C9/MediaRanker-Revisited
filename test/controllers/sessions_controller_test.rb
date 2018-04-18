require "test_helper"

describe SessionsController do
  describe "login" do
    it "can let a user log in via provider" do
      auth_hash = {
        "info" => {
          "name" => "wenjie",
          "email" => "wenjie@ada.org"
        },
        "uid" => 404,
        "provider" => "github"
      }

    end
  end
end
