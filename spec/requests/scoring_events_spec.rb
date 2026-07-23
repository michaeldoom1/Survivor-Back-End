require 'swagger_helper'

RSpec.describe "ScoringEvents", type: :request do
  path "/scoring_events" do
    get "Retrieves all scoring events" do
      tags "ScoringEvents"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "scoring events found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   points: { type: :integer },
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

  path "/scoring_events" do
    post "Creates a scoring event" do
      tags "ScoringEvents"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          scoring_event: {
            type: :object,
            properties: {
              name: { type: :string },
              points: { type: :integer }
            },
            required: %w[name points]
          }
        }
      }

      response "201", "scoring event created" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 points: { type: :integer },
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
        let(:params) { { scoring_event: { name: "Won Individual Immunity", points: 5 } } }
        run_test!
      end

      response "422", "invalid request" do
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
        let(:params) { { scoring_event: { name: "", points: 5 } } }
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
        let(:params) { { scoring_event: { name: "Won Reward", points: 2 } } }
        run_test!
      end
    end
  end

  path "/scoring_events/{id}" do
    get "Retrieves a scoring event" do
      tags "ScoringEvents"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "200", "scoring event found" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 points: { type: :integer },
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
        let(:id) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5).id }
        run_test!
      end

      response "404", "scoring event not found" do
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

  path "/scoring_events/{id}" do
    put "Updates a scoring event" do
      tags "ScoringEvents"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          scoring_event: {
            type: :object,
            properties: {
              name: { type: :string },
              points: { type: :integer }
            }
          }
        }
      }
      security [ bearerAuth: [] ]

      response "200", "scoring event updated" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 points: { type: :integer },
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
        let(:id) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5).id }
        let(:params) { { scoring_event: { points: 6 } } }
        run_test!
      end

      response "404", "scoring event not found" do
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
        let(:params) { { scoring_event: { points: 6 } } }
        run_test!
      end
    end
  end

  path "/scoring_events/{id}" do
    delete "Deletes a scoring event" do
      tags "ScoringEvents"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "204", "scoring event deleted" do
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123", first_name: "Test", last_name: "User" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5).id }
        run_test!
      end

      response "422", "cannot delete a scoring event that has recorded episode scores" do
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
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Coach", gender: "Male"), season: season) }
        let!(:episode_score) do
          EpisodeScore.create!(contestant: contestant, scoring_event: scoring_event, episode_number: 1, season: season)
        end
        let(:id) { scoring_event.id }
        run_test!
      end

      response "404", "scoring event not found" do
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
