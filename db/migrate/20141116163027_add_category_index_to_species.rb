class AddCategoryIndexToSpecies < ActiveRecord::Migration
  def change
    add_index :species, :category_id
  end
end
