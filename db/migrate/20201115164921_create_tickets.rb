class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.belongs_to :reader, null: false, foreign_key: true
      t.belongs_to :copy, null: false, foreign_key: true
      t.datetime :due_date
      t.string :ticket_state

      t.timestamps
    end
  end
end
