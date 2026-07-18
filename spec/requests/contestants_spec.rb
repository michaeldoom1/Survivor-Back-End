require 'swagger_helper'

RSpec.describe "Contestants", type: :request do
  path "/contestants" do
    get "Retrieves all contestants" do
      tags "Contestants"
      produces "application/json"
      security [ bearerAuth: [] ]
      response "200", "contestants found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   gender: { type: :string },
                   tribename: { type: :string, nullable: true },
                   season_id: { type: :integer },
                   occupation: { type: :string, nullable: true },
                   bio: { type: :string, nullable: true },
                   age: { type: :integer, nullable: true },
                   photo_url: { type: :string, nullable: true },
                   video_url: { type: :string, nullable: true },
                   created_at: { type: :string },
                   updated_at: { type: :string }
                 }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: false) }
        let(:Authorization) do
          post '/login',
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
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

  path "/contestants/scores" do
    get "Retrieves all contestants in a season with their episode scores and total" do
      tags "Contestants"
      produces "application/json"
      parameter name: :season_id, in: :query, type: :integer, required: true
      security [ bearerAuth: [] ]

      response "200", "scores found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   gender: { type: :string },
                   tribename: { type: :string, nullable: true },
                   total_points: { type: :integer },
                   episode_scores: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         episode_number: { type: :integer },
                         scoring_event: { type: :string },
                         points: { type: :integer }
                       }
                     }
                   }
                 }
               }
        let!(:existing_user) { User.create!(email: "scores_user@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "scores_user@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(person: Person.create!(name: "Coach", gender: "Male"), season: season) }
        let!(:scoring_event) { ScoringEvent.create!(name: "Won Individual Immunity", points: 5) }
        let!(:episode_score) do
          EpisodeScore.create!(contestant: contestant, scoring_event: scoring_event, episode_number: 2, season: season)
        end
        let(:season_id) { season.id }
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.first["total_points"]).to eq(5)
          expect(body.first["episode_scores"].first["scoring_event"]).to eq("Won Individual Immunity")
        end
      end

      response "400", "missing season_id param" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "scores_user@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "scores_user@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:season_id) { nil }
        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let(:Authorization) { nil }
        let!(:season) { Season.create!(number: 47) }
        let(:season_id) { season.id }
        run_test!
      end
    end
  end

  path "/contestants" do
    post "Creates a contestant" do
      tags "Contestants"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          contestant: {
            type: :object,
            properties: {
              name: { type: :string },
              gender: { type: :string },
              tribename: { type: :string },
              season_id: { type: :integer },
              occupation: { type: :string },
              bio: { type: :string },
              age: { type: :integer },
              photo_url: { type: :string },
              video_url: { type: :string }
            },
            required: %w[name gender season_id]
          }
        }
      }

      response "201", "contestant created" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 gender: { type: :string },
                 tribename: { type: :string, nullable: true },
                 season_id: { type: :integer },
                 occupation: { type: :string, nullable: true },
                 bio: { type: :string, nullable: true },
                 age: { type: :integer, nullable: true },
                 photo_url: { type: :string, nullable: true },
                 video_url: { type: :string, nullable: true },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login',
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let!(:season) { Season.create!(number: 47) }
        let(:params) do
          {
            contestant: {
              name: "John Doe", gender: "Male", tribename: "Tribal", season_id: season.id,
              occupation: "Firefighter", bio: "A brief bio.", age: 32,
              photo_url: "https://example.com/john.jpg", video_url: "https://youtube.com/watch?v=abc123"
            }
          }
        end
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["occupation"]).to eq("Firefighter")
          expect(body["age"]).to eq(32)
        end
      end

      response "422", "invalid request" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login',
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let(:params) do
          { contestant: { name: "", gender: "Invalid", tribename: "" } }
        end
        run_test!
      end

      response "422", "invalid age and photo_url" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login',
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let!(:season) { Season.create!(number: 47) }
        let(:params) do
          { contestant: { name: "Bad Data", gender: "Male", season_id: season.id, age: -5, photo_url: "not-a-url" } }
        end
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["errors"]).to include("Age must be greater than 0")
          expect(body["errors"]).to include("Photo url must be a valid URL")
        end
      end
    end
  end

  path "/contestants/{id}" do
    get "Retrieves a contestant" do
      tags "Contestants"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]
      response "200", "contestant found" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 gender: { type: :string },
                 tribename: { type: :string, nullable: true },
                 season_id: { type: :integer },
                 occupation: { type: :string, nullable: true },
                 bio: { type: :string, nullable: true },
                 age: { type: :integer, nullable: true },
                 photo_url: { type: :string, nullable: true },
                 video_url: { type: :string, nullable: true },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: false) }
        let(:Authorization) do
          post '/login',
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let!(:season) { Season.create!(number: 47) }
        let(:id) { Contestant.create(person: Person.create!(name: "Jane Doe", gender: "Female"), tribename: "Tribal", season: season).id }
        run_test!
      end

      response "404", "contestant not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: false) }
        let(:Authorization) do
          post '/login',
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let(:id) { "invalid" }
        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let(:Authorization) { nil }
        let!(:season) { Season.create!(number: 47) }
        let(:id) { Contestant.create(person: Person.create!(name: "Jane Doe", gender: "Female"), tribename: "Tribal", season: season).id }
        run_test!
      end
    end
  end

  path "/contestants/{id}" do
    put "Updates a contestant" do
      tags "Contestants"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          contestant: {
            type: :object,
            properties: {
              name: { type: :string },
              gender: { type: :string },
              tribename: { type: :string },
              season_id: { type: :integer }
            }
          }
        }
      }

      response "200", "contestant updated" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 gender: { type: :string },
                 tribename: { type: :string, nullable: true },
                 season_id: { type: :integer },
                 occupation: { type: :string, nullable: true },
                 bio: { type: :string, nullable: true },
                 age: { type: :integer, nullable: true },
                 photo_url: { type: :string, nullable: true },
                 video_url: { type: :string, nullable: true },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:season) { Season.create!(number: 47) }
        let(:id) { Contestant.create(person: Person.create!(name: "Jane Doe", gender: "Female"), tribename: "Tribal", season: season).id }
        let(:params) { { contestant: { name: "Jane Smith", gender: "Female", tribename: "Tribal" } } }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login',
               params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
               headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        run_test!
      end

      response "404", "contestant not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login',
               params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
               headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let(:id) { "invalid" }
        let(:params) { { contestant: { name: "Jane Smith", gender: "Female", tribename: "Tribal" } } }
        run_test!
      end
    end
  end

  path "/contestants/{id}" do
    delete "Deletes a contestant" do
      tags "Contestants"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]
      response "204", "contestant deleted" do
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login',
               params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
               headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let!(:season) { Season.create!(number: 47) }
        let(:id) { Contestant.create(person: Person.create!(name: "Jane Doe", gender: "Female"), tribename: "Tribal", season: season).id }
        run_test!
      end

      response "404", "contestant not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login',
               params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
               headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let(:id) { "invalid" }
        run_test!
      end
    end
  end
end
