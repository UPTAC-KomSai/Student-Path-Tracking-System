class CreateStudyPaths < ActiveRecord::Migration[5.1]
  def change
    create_table :study_paths do |t|
      t.references :degree, foreign_key: true
      t.references :subject, foreign_key: true
      t.boolean :isMajor
      t.boolean :isGE
      t.boolean :isRequired

      t.timestamps
    end
  end
end
