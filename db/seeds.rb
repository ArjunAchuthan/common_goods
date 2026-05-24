# db/seeds.rb — Sample data for development
# Run with: rails db:seed

puts "🌱 Seeding CommonGoods..."

# Configure Geocoder to run offline in test mode
Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates'  => [40.7128, -74.0060],
      'address'      => 'New York, NY',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

# Create a neighborhood
neighborhood = Neighborhood.create!(
  name: "Maplewood Heights",
  description: "A friendly community in the heart of the city. We share tools, gear, and more!",
  radius_km: 3.0,
  slug: "maplewood-heights"
)

puts "  ✓ Neighborhood: #{neighborhood.name}"

# Create users
captain = User.create!(
  name: "Sarah Chen",
  email: "sarah@example.com",
  password: "password123",
  password_confirmation: "password123",
  address: "123 Maple Street",
  role: :captain,
  neighborhood: neighborhood
)

alice = User.create!(
  name: "Alice Johnson",
  email: "alice@example.com",
  password: "password123",
  password_confirmation: "password123",
  address: "456 Oak Avenue",
  role: :member,
  neighborhood: neighborhood
)

bob = User.create!(
  name: "Bob Martinez",
  email: "bob@example.com",
  password: "password123",
  password_confirmation: "password123",
  address: "789 Pine Road",
  role: :member,
  neighborhood: neighborhood
)

puts "  ✓ Users: #{User.count} created (captain: sarah@example.com)"

# Create items
items_data = [
  { name: "DeWalt Cordless Drill", description: "20V MAX cordless drill with 2 batteries and charger. Great for most home projects.", category: :tools, condition: :good, user: captain },
  { name: "Extension Ladder (24ft)", description: "Werner 24-foot aluminum extension ladder. Supports up to 225 lbs.", category: :tools, condition: :fair, user: captain },
  { name: "4-Person Camping Tent", description: "Coleman Sundome tent. Easy setup, includes rain fly. Used 3 times.", category: :camping, condition: :like_new, user: alice },
  { name: "Stand Mixer - KitchenAid", description: "Artisan 5-quart stand mixer in silver. Comes with 3 attachments.", category: :kitchen, condition: :good, user: alice },
  { name: "Mountain Bike", description: "Trek Marlin 5, medium frame. Recently tuned up. Helmet included", category: :sports, condition: :good, user: bob },
  { name: "Pressure Washer", description: "Sun Joe 2030 PSI electric pressure washer. Perfect for decks and driveways.", category: :tools, condition: :like_new, user: bob },
  { name: "Folding Camping Chairs (set of 4)", description: "Comfortable quad chairs with cup holders. Great for tailgating or camping.", category: :camping, condition: :good, user: bob },
  { name: "Circular Saw", description: "SKIL 15 Amp 7-1/4 inch circular saw with laser guide.", category: :tools, condition: :fair, user: captain },
]

items_data.each do |data|
  Item.create!(data)
end

puts "  ✓ Items: #{Item.count} listed"

# Create a sample loan
loan = Loan.create!(
  item: Item.first,
  borrower: alice,
  start_date: Date.current + 2,
  end_date: Date.current + 5,
  message: "Hi Sarah! I need to hang some shelves this weekend. Would love to borrow your drill!",
  status: :pending
)

puts "  ✓ Loans: 1 sample loan request created"

# Create a sample invitation
invitation = Invitation.create!(
  inviter: captain,
  neighborhood: neighborhood,
  invitee_email: "newneighbor@example.com"
)

puts "  ✓ Invitations: 1 sample invitation (token: #{invitation.token})"

puts ""
puts "🎉 Seeding complete!"
puts ""
puts "📋 Login credentials:"
puts "   Captain: sarah@example.com / password123"
puts "   Member:  alice@example.com / password123"
puts "   Member:  bob@example.com / password123"
