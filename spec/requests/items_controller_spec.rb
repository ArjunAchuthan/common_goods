# spec/requests/items_controller_spec.rb
require 'rails_helper'

RSpec.describe "Items", type: :request do
  let(:neighborhood) do
    Neighborhood.create!(
      name: "Sunnyvale",
      radius_km: 5.0,
      slug: "sunnyvale"
    )
  end

  let(:user) do
    User.create!(
      name: "Lender User",
      email: "lender@example.com",
      password: "password123",
      password_confirmation: "password123",
      address: "123 Main St",
      neighborhood: neighborhood
    )
  end

  let!(:item) do
    Item.create!(
      name: "Lawn Mower",
      description: "Gas powered push mower.",
      category: :garden,
      condition: :good,
      available: true,
      user: user
    )
  end

  # Bulletproof authentication helper using controller method stubbing
  before do
    allow_any_instance_of(ApplicationController).to receive(:find_session_by_cookie).and_wrap_original do |original, *args|
      @test_session || original.call(*args)
    end
  end

  def sign_in(user)
    @test_session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
  end

  describe "GET /items" do
    context "when unauthenticated" do
      it "returns success because search/index are publicly viewable" do
        get items_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated" do
      before { sign_in(user) }

      it "returns a successful response and lists items" do
        get items_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Lawn Mower")
      end
    end
  end

  describe "GET /items/new" do
    context "when unauthenticated" do
      it "redirects to the login page because creating items requires login" do
        get new_item_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /items/:id" do
    it "returns the item detail page successfully even when unauthenticated" do
      get item_path(item)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Lawn Mower")
    end
  end

  describe "POST /items" do
    before { sign_in(user) }

    context "with valid parameters" do
      let(:valid_params) do
        {
          item: {
            name: "Cordless Drill",
            description: "Dewalt cordless drill with charger.",
            category: "tools",
            condition: "like_new"
          }
        }
      end

      it "creates a new item and redirects to it" do
        expect {
          post items_path, params: valid_params
        }.to change(Item, :count).by(1)

        new_item = Item.find_by(name: "Cordless Drill")
        expect(response).to redirect_to(item_path(new_item))
      end
    end
  end
end
