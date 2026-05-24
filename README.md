# CommonGoods 🌿

> A private, invite-only platform for neighbors to share tools and items for free lending.

## Tech Stack

- **Backend:** Rails 8, PostgreSQL + PostGIS
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS
- **Real-time:** ActionCable
- **Background Jobs:** Solid Queue
- **Storage:** ActiveStorage
- **Geocoding:** Geocoder gem + Nominatim

## Prerequisites

- Ruby 3.3+
- Rails 8.0+
- PostgreSQL 15+ with PostGIS extension
- Node.js 20+
- Redis (production only)

## Setup

```bash
# Clone and install
cd common_goods
bundle install
rails tailwindcss:install

# Create database with PostGIS
rails db:create db:migrate db:seed

# Start the dev server
bin/dev
```

## Seed Accounts

| Role    | Email              | Password     |
|---------|--------------------|--------------|
| Captain | sarah@example.com  | password123  |
| Member  | alice@example.com  | password123  |
| Member  | bob@example.com    | password123  |

## Features

- **Hyper-local discovery** — PostGIS spatial queries within 2/5/10km radius
- **Trust circles** — Invite-only neighborhoods with token-based invitations
- **Booking system** — Calendar-based borrow requests with date validation
- **Real-time notifications** — ActionCable push notifications on loan requests
- **Admin dashboard** — Neighborhood Captains manage members and flag items

## Architecture

```
Fat Models, Skinny Controllers
├── Concerns: Geocodable, Notifiable
├── State Machine: Loan (pending → approved → active → returned)
├── Background: NotificationBroadcastJob, GeocodingJob
└── Channels: NotificationsChannel (per-user streaming)
```

## License

MIT
