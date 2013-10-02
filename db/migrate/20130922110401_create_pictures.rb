class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string   :title_url
      t.string   :title
      t.string   :caption
      t.integer  :resource_id
      t.string   :resource_type
      t.integer  :position

      t.string   :image_file_name
      t.string   :image_content_type
      t.integer  :image_file_size
      t.timestamps
    end
  end
end