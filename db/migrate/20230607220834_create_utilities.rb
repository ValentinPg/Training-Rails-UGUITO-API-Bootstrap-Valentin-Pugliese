class CreateUtilities < ActiveRecord::Migration[5.2]
  def change
    create_table :utilities do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.integer :code
      t.string :base_url
      t.string :external_api_key
      t.string :external_api_secret
      t.string :external_api_access_token
      t.datetime :external_api_access_token_expiration
      t.jsonb :integration_urls, :jsonb, default: {}

      t.timestamps
    end
  end
end
