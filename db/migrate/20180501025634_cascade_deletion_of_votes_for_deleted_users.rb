class CascadeDeletionOfVotesForDeletedUsers < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :votes, :users

    add_foreign_key :votes, :users, on_delete: :cascade
  end
end
