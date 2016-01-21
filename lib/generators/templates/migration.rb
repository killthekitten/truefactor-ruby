class AddTruefactorTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :truefactor, :text
  end
end
