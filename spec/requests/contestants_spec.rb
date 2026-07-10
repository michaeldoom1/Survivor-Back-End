require 'swagger_helper'

RSpec.describe "Contestants", type: :request do
  path "/contestants" do
    get "Retrieves all contestants" do
      tags "Contestants"
      produces "application/json"
      security [ bearerAuth: [] ]
      response "200", "contestants found" do
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
        let(:Authorization) { nil }
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
            },
            required: %w[name gender]
          }
        }
      }

      response "201", "contestant created" do
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: true) }
        let(:Authorization) do
          post '/login', 
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let(:params) do
          { contestant: { name: "John Doe", gender: "Male", tribename: "Tribal" } }
        end
        run_test!
      end

      response "422", "invalid request" do
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
    end
  end

  path "/contestants/{id}" do
    get "Retrieves a contestant" do
      tags "Contestants"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      security [ bearerAuth: [] ]
      response "200", "contestant found" do
        let!(:existing_user) { User.create!(email: 'admin@example.com', password: 'password123', admin: false) }
        let(:Authorization) do
          post '/login', 
          params: { user: { email: 'admin@example.com', password: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        let(:id) { Contestant.create(name: "Jane Doe", gender: "Female", tribename: "Tribal").id }
        run_test!
      end

      response "404", "contestant not found" do
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
        let(:Authorization) { nil }
        let(:id) { Contestant.create(name: "Jane Doe", gender: "Female", tribename: "Tribal").id }
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
            }
          }
        }
      }

      response "200", "contestant updated" do
        let(:id) { Contestant.create(name: "Jane Doe", gender: "Female", tribename: "Tribal").id }
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
        let(:id) { Contestant.create(name: "Jane Doe", gender: "Female", tribename: "Tribal").id }
        run_test! 
      end

      response "404", "contestant not found" do
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