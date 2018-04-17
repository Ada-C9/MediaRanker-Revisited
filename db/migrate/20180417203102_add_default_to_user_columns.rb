class AddDefaultToUserColumns < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :uid, :integer, :null => false
    change_column :users, :provider, :string, :null => false
  end
end
