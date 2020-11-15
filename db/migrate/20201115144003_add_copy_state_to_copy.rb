class AddCopyStateToCopy < ActiveRecord::Migration[6.0]
  def change
    add_column :copies, :copy_state, :string
  end
end
