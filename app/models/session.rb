# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :user
end
