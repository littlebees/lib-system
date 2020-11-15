class Reader < ApplicationRecord
  has_one :user, as: :role, dependent: :destroy
  has_many :copies, through: :ticket
end
