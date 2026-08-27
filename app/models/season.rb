class Season < ApplicationRecord
  has_many :contestants, dependent: :restrict_with_error
  has_many :picks, dependent: :restrict_with_error
  has_many :episode_scores, dependent: :restrict_with_error
  has_many :episode_posts, dependent: :destroy

  validates :number, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validate :cast_video_url_is_valid

  private

  def cast_video_url_is_valid
    validate_url(:cast_video_url)
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
