class Contestant < ApplicationRecord
    validates :name, presence: true
    validates :gender, presence: true
end
