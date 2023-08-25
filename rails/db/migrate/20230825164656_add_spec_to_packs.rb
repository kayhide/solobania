class AddSpecToPacks < ActiveRecord::Migration[7.0]
  def change
    add_reference :packs, :spec, null: false, foreign_key: true
  end
end
