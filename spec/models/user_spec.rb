# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:neighborhood) do
    Neighborhood.create!(
      name: "Oakridge Hills",
      radius_km: 2.0,
      slug: "oakridge-hills"
    )
  end

  let(:valid_attributes) do
    {
      name: "Sarah Parker",
      email: "Sarah@Example.Com",
      password: "password123",
      password_confirmation: "password123",
      address: "123 Maple Street",
      role: :member,
      neighborhood: neighborhood
    }
  end

  describe 'Validations' do
    it 'is valid with valid attributes' do
      user = User.new(valid_attributes)
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = User.new(valid_attributes.merge(name: nil))
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a short password' do
      user = User.new(valid_attributes.merge(password: "123", password_confirmation: "123"))
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
    end

    it 'is invalid with an improperly formatted email' do
      user = User.new(valid_attributes.merge(email: "bad-email"))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it 'enforces uniqueness of email address' do
      User.create!(valid_attributes)
      duplicate_user = User.new(valid_attributes.merge(email: "sarah@example.com"))
      expect(duplicate_user).not_to be_valid
    end
  end

  describe 'Callbacks' do
    it 'downcases email address before saving' do
      user = User.create!(valid_attributes)
      expect(user.email).to eq("sarah@example.com")
    end
  end

  describe 'Enums & Helper methods' do
    it 'identifies captain_or_admin?' do
      member = User.new(valid_attributes.merge(role: :member))
      captain = User.new(valid_attributes.merge(role: :captain))
      admin = User.new(valid_attributes.merge(role: :admin))

      expect(member.captain_or_admin?).to be false
      expect(captain.captain_or_admin?).to be true
      expect(admin.captain_or_admin?).to be true
    end
  end
end
