require 'swagger_helper'

RSpec.describe "EpisodeScores", type: :request do
  path "/episode_scores" do
    get "Retrieves all episode scores" do
      tags "EpisodeScores"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "episode scores found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   contestant_id: { type: :integer },
                   scoring_event_id: { type: :integer },
                   episode_number: { type: :integer },
                   points: { type: :integer },
                   season_id: { type: :integer },
                   created_at: { type: :string },
                   updated_at: { type: :string }
                 }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123", first_name: "Test", last_name: "User") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/episode_scores" do
    post "Creates an episode score" do
      tags "EpisodeScores"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          episode_score: {
            type: :object,
            properties: {
              contestant_id: { type: :integer },
              scoring_event_id: { type: :integer },
              episode_number: { type: :integer },
              season_id: { type: :integer }
            },
            required: %w[contestant_id scoring_event_id episode_number season_id]
          }
        }
      }

      response "201", "episode score created" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 contestant_id: { type: :integer },
                 scoring_event_id: { type: :integer },
                 episode_number: { type: :integer },
                 points: { type: :integer },
                 season_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Coach", gender: "Male"), season: season) }
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let(:params) do
          { episode_score: { contestant_id: contestant.id, scoring_event_id: scoring_event.id, episode_number: 3, season_id: season.id } }
        end
        run_test!
      end

      response "422", "contestant's season does not match" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:other_season) { Season.create!(number: 46) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Old Timer", gender: "Male"), season: other_season) }
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let(:params) do
          { episode_score: { contestant_id: contestant.id, scoring_event_id: scoring_event.id, episode_number: 3, season_id: season.id } }
        end
        run_test!
      end

      response "403", "forbidden for non-admins" do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123", first_name: "Test", last_name: "User") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Coach", gender: "Male"), season: season) }
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let(:params) do
          { episode_score: { contestant_id: contestant.id, scoring_event_id: scoring_event.id, episode_number: 3, season_id: season.id } }
        end
        run_test!
      end
    end
  end

  path "/episode_scores/{id}" do
    get "Retrieves an episode score" do
      tags "EpisodeScores"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "200", "episode score found" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 contestant_id: { type: :integer },
                 scoring_event_id: { type: :integer },
                 episode_number: { type: :integer },
                 points: { type: :integer },
                 season_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123", first_name: "Test", last_name: "User") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Coach", gender: "Male"), season: season) }
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let(:id) do
          EpisodeScore.create!(contestant: contestant, scoring_event: scoring_event, episode_number: 3, season: season).id
        end
        run_test!
      end

      response "404", "episode score not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123", first_name: "Test", last_name: "User") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        run_test!
      end
    end
  end

  path "/episode_scores/{id}" do
    put "Updates an episode score" do
      tags "EpisodeScores"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          episode_score: {
            type: :object,
            properties: {
              episode_number: { type: :integer }
            }
          }
        }
      }
      security [ bearerAuth: [] ]

      response "200", "episode score updated" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 contestant_id: { type: :integer },
                 scoring_event_id: { type: :integer },
                 episode_number: { type: :integer },
                 points: { type: :integer },
                 season_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Coach", gender: "Male"), season: season) }
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let(:id) do
          EpisodeScore.create!(contestant: contestant, scoring_event: scoring_event, episode_number: 3, season: season).id
        end
        let(:params) { { episode_score: { episode_number: 4 } } }
        run_test!
      end

      response "404", "episode score not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        let(:params) { { episode_score: { episode_number: 4 } } }
        run_test!
      end
    end
  end

  path "/episode_scores/{id}" do
    delete "Deletes an episode score" do
      tags "EpisodeScores"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "204", "episode score deleted" do
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Coach", gender: "Male"), season: season) }
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let(:id) do
          EpisodeScore.create!(contestant: contestant, scoring_event: scoring_event, episode_number: 3, season: season).id
        end
        run_test!
      end

      response "404", "episode score not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        run_test!
      end
    end
  end
end
