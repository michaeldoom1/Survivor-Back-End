require 'swagger_helper'

RSpec.describe "User Groups", type: :request do
  let!(:owner) { User.create!(email: "owner@example.com", password: "password123", first_name: "Olive", last_name: "Owner") }
  let!(:member) { User.create!(email: "member@example.com", password: "password123", first_name: "Mia", last_name: "Member") }
  let!(:outsider) { User.create!(email: "outsider@example.com", password: "password123", first_name: "Otto", last_name: "Outsider") }

  def token_for(user)
    post "/login",
         params: { user: { email: user.email, password: "password123" } }.to_json,
         headers: { "Content-Type" => "application/json" }
    response.headers["Authorization"]
  end

  group_schema = {
    type: :object,
    properties: {
      id: { type: :integer },
      name: { type: :string },
      owner_id: { type: :integer },
      owner_name: { type: :string },
      is_owner: { type: :boolean },
      members: {
        type: :array,
        items: { type: :object, properties: { id: { type: :integer }, name: { type: :string } } }
      }
    }
  }

  path "/user_groups" do
    get "Lists the groups the current user owns or belongs to" do
      tags "User Groups"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "groups found" do
        schema type: :array, items: group_schema
        let(:Authorization) { token_for(member) }
        before { UserGroup.create!(owner: owner, name: "Family", members: [ member ]) }

        run_test! do |response|
          groups = JSON.parse(response.body)
          expect(groups.map { |g| g["name"] }).to eq([ "Family" ])
          expect(groups.first["is_owner"]).to be(false)
        end
      end

      response "401", "unauthenticated" do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post "Creates a group owned by the current user" do
      tags "User Groups"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :user_group, in: :body, schema: {
        type: :object,
        properties: {
          user_group: {
            type: :object,
            properties: { name: { type: :string }, member_ids: { type: :array, items: { type: :integer } } },
            required: [ "name" ]
          }
        }
      }

      response "201", "group created" do
        schema group_schema
        let(:Authorization) { token_for(owner) }
        let(:user_group) { { user_group: { name: "Family", member_ids: [ member.id ] } } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["is_owner"]).to be(true)
          expect(body["members"].map { |m| m["id"] }).to contain_exactly(owner.id, member.id)
        end
      end

      response "422", "invalid group" do
        let(:Authorization) { token_for(owner) }
        let(:user_group) { { user_group: { name: "" } } }
        run_test!
      end
    end
  end

  path "/user_groups/{id}" do
    parameter name: :id, in: :path, type: :integer

    patch "Updates a group (owner only)" do
      tags "User Groups"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]
      parameter name: :user_group, in: :body, schema: {
        type: :object,
        properties: {
          user_group: {
            type: :object,
            properties: { name: { type: :string }, member_ids: { type: :array, items: { type: :integer } } }
          }
        }
      }

      let!(:group) { UserGroup.create!(owner: owner, name: "Family", members: [ member ]) }
      let(:id) { group.id }

      response "200", "group updated" do
        schema group_schema
        let(:Authorization) { token_for(owner) }
        let(:user_group) { { user_group: { name: "The Fam", member_ids: [ outsider.id ] } } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["name"]).to eq("The Fam")
          # The owner always stays in their own group.
          expect(body["members"].map { |m| m["id"] }).to contain_exactly(owner.id, outsider.id)
        end
      end

      response "404", "not the owner" do
        let(:Authorization) { token_for(member) }
        let(:user_group) { { user_group: { name: "Hijacked" } } }
        run_test! { expect(group.reload.name).to eq("Family") }
      end
    end

    delete "Deletes a group (owner only)" do
      tags "User Groups"
      security [ bearerAuth: [] ]

      let!(:group) { UserGroup.create!(owner: owner, name: "Family", members: [ member ]) }
      let(:id) { group.id }

      response "204", "group deleted" do
        let(:Authorization) { token_for(owner) }
        run_test! { expect(UserGroup.exists?(group.id)).to be(false) }
      end

      response "404", "not the owner" do
        let(:Authorization) { token_for(member) }
        run_test! { expect(UserGroup.exists?(group.id)).to be(true) }
      end
    end
  end

  it "hides groups from users who aren't in them" do
    UserGroup.create!(owner: owner, name: "Family", members: [ member ])
    get "/user_groups", headers: { "Authorization" => token_for(outsider) }
    expect(JSON.parse(response.body)).to eq([])
  end
end
