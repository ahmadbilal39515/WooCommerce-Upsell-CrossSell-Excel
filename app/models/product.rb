class Product < ApplicationRecord
   belongs_to :category, optional: true
   belongs_to :sub_category, optional: true
end
