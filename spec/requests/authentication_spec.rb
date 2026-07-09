require 'swagger_helper'

RSpec.describe 'Authentication', type: :request do
  path '/signup' do
    post 'Creates a user account' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[email password password_confirmation]
          }
        }
      }

      response '201', 'user created' do
        let(:params) do
          { user: { email: 'friend@example.com', password: 'password123', password_confirmation: 'password123' } }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:params) do
          { user: { email: '', password: 'a', password_confirmation: 'b' } }
        end
        run_test!
      end
    end
  end

  path '/login' do
    post 'Logs in and returns a JWT' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            },
            required: %w[email password]
          }
        }
      }

      response '200', 'logged in' do
        let!(:existing_user) { User.create!(email: 'friend@example.com', password: 'password123') }
        let(:params) { { user: { email: 'friend@example.com', password: 'password123' } } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:params) { { user: { email: 'nobody@example.com', password: 'wrong' } } }
        run_test!
      end
    end
  end

  path '/logout' do
    delete 'Logs out and revokes the current JWT' do
      tags 'Authentication'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'logged out' do
        let!(:existing_user) { User.create!(email: 'friend@example.com', password: 'password123') }
        let(:Authorization) do
          post '/login',
               params: { user: { email: 'friend@example.com', password: 'password123' } }.to_json,
               headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        run_test!
      end

      response '401', 'missing token' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/me' do
    get 'Returns the currently authenticated user' do
      tags 'Authentication'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'current user' do
        let!(:existing_user) { User.create!(email: 'friend@example.com', password: 'password123') }
        let(:Authorization) do
          post '/login',
               params: { user: { email: 'friend@example.com', password: 'password123' } }.to_json,
               headers: { 'Content-Type' => 'application/json' }
          response.headers['Authorization']
        end
        run_test!
      end

      response '401', 'not authenticated' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
