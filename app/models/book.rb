class Book < ApplicationRecord
  has_many :copies, dependent: :delete_all
end
