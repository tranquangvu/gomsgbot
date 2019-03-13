class CreateConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :conversations do |t|
      t.integer :user_id
      t.integer :current_question_id

      t.timestamps
    end
  end
end
