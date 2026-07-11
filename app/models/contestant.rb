class Contestant < ApplicationRecord
    belongs_to :season
    has_many :episode_scores, dependent: :destroy

    validates :name, presence: true
    validates :gender, presence: true
    validates :age, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

    validate :photo_url_is_valid
    validate :video_url_is_valid

    def total_points
      episode_scores.sum(&:points)
    end

    private

    def photo_url_is_valid
      validate_url(:photo_url)
    end

    def video_url_is_valid
      validate_url(:video_url)
    end

    def validate_url(attribute)
      url = read_attribute(attribute)
      return if url.blank?

      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) && uri.host.present?
        errors.add(attribute, "must be a valid URL")
      end
    rescue URI::InvalidURIError
      errors.add(attribute, "must be a valid URL")
    end
end
