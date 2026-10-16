require 'rails_helper'

RSpec.describe Meme, type: :model do
  let(:episode_post) { EpisodePost.create!(season: Season.create!(number: 1), episode_number: 1) }

  def build_meme(attrs)
    Meme.new({ episode_post: episode_post }.merge(attrs))
  end

  it "requires an image or a post URL" do
    expect(build_meme({})).not_to be_valid
  end

  it "accepts an X post URL" do
    expect(build_meme(x_url: "https://x.com/someone/status/1234567890")).to be_valid
    expect(build_meme(x_url: "https://twitter.com/someone/status/1234567890?s=20")).to be_valid
  end

  it "rejects an X URL that is not a post" do
    expect(build_meme(x_url: "https://x.com/someone")).not_to be_valid
    expect(build_meme(x_url: "https://example.com/someone/status/123")).not_to be_valid
  end

  it "accepts a Reddit post URL" do
    expect(build_meme(reddit_url: "https://www.reddit.com/r/survivor/comments/abc123/some_title/")).to be_valid
  end

  it "rejects a Reddit URL that is not a post" do
    expect(build_meme(reddit_url: "https://www.reddit.com/r/survivor/")).not_to be_valid
    expect(build_meme(reddit_url: "https://example.com/r/survivor/comments/abc123/")).not_to be_valid
  end
end
