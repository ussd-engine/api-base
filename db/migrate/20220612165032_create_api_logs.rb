class CreateApiLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :api_base_api_logs do |t|
      t.text :api, null: false
      t.text :origin, null: false
      t.text :source, null: false
      t.text :endpoint, null: false
      t.text :method, null: false
      t.jsonb :request_headers
      t.jsonb :request_body
      t.integer :status_code
      t.jsonb :response_headers
      t.jsonb :response_body
      t.float :duration
      t.jsonb :exception

      t.timestamps
    end
  end
end
