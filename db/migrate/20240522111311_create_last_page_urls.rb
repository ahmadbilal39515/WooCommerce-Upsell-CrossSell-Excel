class CreateLastPageUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :last_page_urls do |t|
      t.string :url
      t.timestamps
    end
  end
end
