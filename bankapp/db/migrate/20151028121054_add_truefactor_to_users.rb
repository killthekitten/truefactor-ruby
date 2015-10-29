class AddTruefactorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :truefactor, :text
  end
end
