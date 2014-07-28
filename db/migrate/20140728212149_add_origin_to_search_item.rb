class AddOriginToSearchItem < ActiveRecord::Migration
  def change
    add_column :search_items, :origin, :string
  end
end
