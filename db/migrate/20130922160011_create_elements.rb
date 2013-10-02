class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements do |t|

    	t.integer  :number
    	t.string   :symbol
    	t.string   :name
    	t.integer  :element_category
    	t.integer  :group
    	t.string   :name_lat
    	t.float    :boiling_point
    	t.float    :melting_point
    	t.integer  :phase
    	t.float    :atomic_weight
    	t.boolean  :toxicity
    	t.string   :summary
    	t.text     :content
      t.timestamps
    end
  end
end
