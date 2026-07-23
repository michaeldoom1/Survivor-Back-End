class EpisodePost < ApplicationRecord
  belongs_to :season
  has_many :memes, dependent: :destroy

  validates :episode_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :episode_number, uniqueness: { scope: :season_id }

  def as_json(options = {})
    super(options.merge(include: :memes))
  end
end
