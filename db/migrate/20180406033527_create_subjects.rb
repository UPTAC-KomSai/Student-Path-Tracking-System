class CreateSubjects < ActiveRecord::Migration[5.1]
  def change
    create_table :subjects do |t|
      t.references :division, foreign_key: true
      t.string :subject_id
      t.string :name
      t.string :description
      t.references :subjects, foreign_key: true
      t.integer :units
      t.boolean :isGE

      t.timestamps
    end
  end
end
