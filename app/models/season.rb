class Season < ApplicationRecord
  has_many :contestants, dependent: :restrict_with_error
  has_many :picks, dependent: :restrict_with_error
  has_many :episode_scores, dependent: :restrict_with_error
  has_many :episode_posts, dependent: :destroy

  validates :number, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
end
