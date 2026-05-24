# spec/models/item_spec.rb
require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:neighborhood) do
    Neighborhood.create!(
      name: "Maplewood Hills",
      radius_km: 3.0,
      slug: "maplewood-hills"
    )
  end

  let(:user) do
    User.create!(
      name: "Bob Builder",
      email: "bob@example.com",
      password: "password123",
      password_confirmation: "password123",
      address: "123 Oak Lane",
      neighborhood: neighborhood
    )
  end

  let(:valid_attributes) do
    {
      name: "DeWalt Cordless Drill",
      description: "Heavy-duty cordless hammer drill with two batteries.",
      category: :tools,
      condition: :like_new,
      available: true,
      flagged: false,
      user: user
    }
  end

  describe 'Validations' do
    it 'is valid with valid attributes' do
      item = Item.new(valid_attributes)
      expect(item).to be_valid
    end

    it 'is invalid without a name' do
      item = Item.new(valid_attributes.merge(name: nil))
      expect(item).not_to be_valid
    end

    it 'is invalid without a description' do
      item = Item.new(valid_attributes.merge(description: nil))
      expect(item).not_to be_valid
    end

    it 'is invalid with a long name' do
      item = Item.new(valid_attributes.merge(name: "A" * 101))
      expect(item).not_to be_valid
    end
  end

  describe 'Scopes' do
    it 'filters available items' do
      available_item = Item.create!(valid_attributes)
      unavailable_item = Item.create!(valid_attributes.merge(available: false))
      flagged_item = Item.create!(valid_attributes.merge(flagged: true))

      available_scope = Item.available
      expect(available_scope).to include(available_item)
      expect(available_scope).not_to include(unavailable_item)
      expect(available_scope).not_to include(flagged_item)
    end

    it 'searches by name or description' do
      drill = Item.create!(valid_attributes.merge(name: "Cordless Drill"))
      mower = Item.create!(valid_attributes.merge(name: "Lawn Mower", description: "Nice lawn mower"))

      expect(Item.search_by_name("Drill")).to include(drill)
      expect(Item.search_by_name("Drill")).not_to include(mower)
      expect(Item.search_by_name("Nice")).to include(mower)
    end
  end
end
