require 'swagger_helper'

RSpec.describe "Seasons", type: :request do
  path "/seasons" do
    get "Retrieves all seasons" do
      tags "Seasons"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "seasons found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   number: { type: :integer },
                   created_at: { type: :string },
                   updated_at: { type: :string }
                 }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123" } }.to_json,
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

  path "/seasons" do
    post "Creates a season" do
      tags "Seasons"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          season: {
            type: :object,
            properties: {
              number: { type: :integer }
            },
            required: %w[number]
          }
        }
      }

      response "201", "season created" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 number: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:params) { { season: { number: 47 } } }
        run_test!
      end

      response "422", "invalid request" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:existing_season) { Season.create!(number: 47) }
        let(:params) { { season: { number: 47 } } }
        run_test!
      end

      response "403", "forbidden for non-admins" do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:params) { { season: { number: 48 } } }
        run_test!
      end
    end
  end

  path "/seasons/{id}" do
    get "Retrieves a season" do
      tags "Seasons"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "200", "season found" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 number: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { Season.create!(number: 47).id }
        run_test!
      end

      response "404", "season not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:existing_user) { User.create!(email: "user@example.com", password: "password123") }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "user@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        run_test!
      end
    end
  end

  path "/seasons/{id}" do
    put "Updates a season" do
      tags "Seasons"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          season: {
            type: :object,
            properties: {
              number: { type: :integer }
            }
          }
        }
      }
      security [ bearerAuth: [] ]

      response "200", "season updated" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 number: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { Season.create!(number: 47).id }
        let(:params) { { season: { number: 48 } } }
        run_test!
      end

      response "404", "season not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        let(:params) { { season: { number: 48 } } }
        run_test!
      end
    end
  end

  path "/seasons/{id}" do
    delete "Deletes a season" do
      tags "Seasons"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]

      response "204", "season deleted" do
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { Season.create!(number: 47).id }
        run_test!
      end

      response "422", "cannot delete a season that has contestants" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let!(:season) { Season.create!(number: 47) }
        let!(:contestant) { Contestant.create!(name: "Coach", gender: "Male", season: season) }
        let(:id) { season.id }
        run_test!
      end

      response "404", "season not found" do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }
        let!(:admin_user) { User.create!(email: "admin@example.com", password: "password123", admin: true) }
        let(:Authorization) do
          post "/login",
               params: { user: { email: "admin@example.com", password: "password123" } }.to_json,
               headers: { "Content-Type" => "application/json" }
          response.headers["Authorization"]
        end
        let(:id) { "invalid" }
        run_test!
      end
    end
  end
end
