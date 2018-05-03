class ChangeUidColumn < ActiveRecord::Migration[5.0]
  def change
    change_column(:users, :uid, :integer, null:false)
  end
end
