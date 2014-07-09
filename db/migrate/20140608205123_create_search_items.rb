class CreateSearchItems < ActiveRecord::Migration
  def change
    create_table :search_items do |t|
      t.string :name
      t.string :address
      t.string :url
      t.string :phone_number
      t.string :distance
      t.string :search_type
      t.integer :user_id
      t.timestamps
    end
    
    add_index :search_items, :user_id
  end
end
