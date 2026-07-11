require 'swagger_helper'

RSpec.describe "Picks", type: :request do
  path "/picks" do
    get "Retrieves the current user's picks" do
      tags "Picks"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "picks found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   user_id: { type: :integer },
                   season_id: { type: :integer },
                   male_contestant_id: { type: :integer },
                   female_contestant_id: { type: :integer },
                   golden_goose_contestant_id: { type: :integer },
                   created_at: { type: :string },
                   updated_at: { type: :string }
                 }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
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

  path "/picks/by_season" do
    get "Retrieves all users' picks for a season" do
      tags "Picks"
      produces "application/json"
      parameter name: :season_id, in: :query, type: :integer, required: true
      security [ bearerAuth: [] ]

      response "200", "picks found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   user_id: { type: :integer },
                   email: { type: :string },
                   season_id: { type: :integer },
                   season_number: { type: :integer },
                   male_contestant: {
                     type: :object,
                     properties: { id: { type: :integer }, name: { type: :string } }
                   },
                   female_contestant: {
                     type: :object,
                     properties: { id: { type: :integer }, name: { type: :string } }
                   },
                   golden_goose_contestant: {
                     type: :object,
                     properties: { id: { type: :integer }, name: { type: :string } }
                   }
                 }
               }
        let!(:requesting_user) { User.create!(email: "requester@example.com", password: "password123") }
        let!(:other_user) { User.create!(email: "otheruser@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "requester@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:male) { Contestant.create!(name: "Male One", gender: "Male", season: season) }
        let!(:female) { Contestant.create!(name: "Female One", gender: "Female", season: season) }
        let!(:goose) { Contestant.create!(name: "Goose One", gender: "Female", season: season) }
        let!(:other_pick) do
          Pick.create!(user: other_user, season: season, male_contestant: male, female_contestant: female, golden_goose_contestant: goose)
        end
        let(:season_id) { season.id }
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.first["email"]).to eq("otheruser@example.com")
          expect(body.first["male_contestant"]["name"]).to eq("Male One")
        end
      end

      response "400", "missing season_id param" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "requester@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "requester@example.com", password: "password123" } }.to_json,
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

  path "/picks" do
    post "Creates a pick" do
      tags "Picks"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          pick: {
            type: :object,
            properties: {
              season_id: { type: :integer },
              male_contestant_id: { type: :integer },
              female_contestant_id: { type: :integer },
              golden_goose_contestant_id: { type: :integer }
            },
            required: %w[season_id male_contestant_id female_contestant_id golden_goose_contestant_id]
          }
        }
      }

      response "201", "pick created" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 user_id: { type: :integer },
                 season_id: { type: :integer },
                 male_contestant_id: { type: :integer },
                 female_contestant_id: { type: :integer },
                 golden_goose_contestant_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:male) { Contestant.create!(name: "Male One", gender: "Male", season: season) }
        let!(:female) { Contestant.create!(name: "Female One", gender: "Female", season: season) }
        let!(:goose) { Contestant.create!(name: "Goose One", gender: "Female", season: season) }
        let(:params) do
          { pick: { season_id: season.id, male_contestant_id: male.id, female_contestant_id: female.id, golden_goose_contestant_id: goose.id } }
        end
        run_test!
      end

      response "422", "invalid gender" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 48) }
        let!(:male) { Contestant.create!(name: "Male One", gender: "Male", season: season) }
        let!(:female) { Contestant.create!(name: "Female One", gender: "Female", season: season) }
        let(:params) do
          { pick: { season_id: season.id, male_contestant_id: female.id, female_contestant_id: female.id, golden_goose_contestant_id: male.id } }
        end
        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let(:Authorization) { nil }
        let!(:season) { Season.create!(number: 49) }
        let(:params) do
          { pick: { season_id: season.id, male_contestant_id: 1, female_contestant_id: 2, golden_goose_contestant_id: 3 } }
        end
        run_test!
      end
    end
  end

  path "/picks/{id}" do
    get "Retrieves a pick" do
      tags "Picks"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "200", "pick found" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 user_id: { type: :integer },
                 season_id: { type: :integer },
                 male_contestant_id: { type: :integer },
                 female_contestant_id: { type: :integer },
                 golden_goose_contestant_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 50) }
        let!(:male) { Contestant.create!(name: "Male One", gender: "Male", season: season) }
        let!(:female) { Contestant.create!(name: "Female One", gender: "Female", season: season) }
        let!(:goose) { Contestant.create!(name: "Goose One", gender: "Female", season: season) }
        let(:id) do
          Pick.create!(user: existing_user, season: season, male_contestant: male, female_contestant: female, golden_goose_contestant: goose).id
        end
        run_test!
      end

      response "404", "pick not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
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
        let(:id) { "invalid" }
        run_test!
      end
    end
  end

  path "/picks/{id}" do
    put "Updates a pick" do
      tags "Picks"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          pick: {
            type: :object,
            properties: {
              season_id: { type: :integer },
              male_contestant_id: { type: :integer },
              female_contestant_id: { type: :integer },
              golden_goose_contestant_id: { type: :integer }
            }
          }
        }
      }
      security [ bearerAuth: [] ]

      response "200", "pick updated" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 user_id: { type: :integer },
                 season_id: { type: :integer },
                 male_contestant_id: { type: :integer },
                 female_contestant_id: { type: :integer },
                 golden_goose_contestant_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 51) }
        let!(:male) { Contestant.create!(name: "Male One", gender: "Male", season: season) }
        let!(:female) { Contestant.create!(name: "Female One", gender: "Female", season: season) }
        let!(:goose) { Contestant.create!(name: "Goose One", gender: "Female", season: season) }
        let!(:goose2) { Contestant.create!(name: "Goose Two", gender: "Male", season: season) }
        let(:id) do
          Pick.create!(user: existing_user, season: season, male_contestant: male, female_contestant: female, golden_goose_contestant: goose).id
        end
        let(:params) { { pick: { golden_goose_contestant_id: goose2.id } } }
        run_test!
      end

      response "404", "pick not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        let(:params) { { pick: {} } }
        run_test!
      end
    end
  end

  path "/picks/{id}" do
    delete "Deletes a pick" do
      tags "Picks"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "204", "pick deleted" do
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 53) }
        let!(:male) { Contestant.create!(name: "Male One", gender: "Male", season: season) }
        let!(:female) { Contestant.create!(name: "Female One", gender: "Female", season: season) }
        let!(:goose) { Contestant.create!(name: "Goose One", gender: "Female", season: season) }
        let(:id) do
          Pick.create!(user: existing_user, season: season, male_contestant: male, female_contestant: female, golden_goose_contestant: goose).id
        end
        run_test!
      end

      response "404", "pick not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "picker@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "picker@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        run_test!
      end
    end
  end
end
