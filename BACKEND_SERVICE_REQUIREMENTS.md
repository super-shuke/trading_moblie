# Backend Service Requirements

## 1. Project Summary

### Project Name

GeoTravel

### Product Direction

GeoTravel is a discovery-first travel product centered on cities, POIs, local tips, itineraries, saves, and location-aware exploration.

The frontend is currently a Flutter app. The visual direction is moving toward:
- Flutter as the application shell and UI layer
- Unity as the 3D runtime for globe, city scenes, and navigation scenes

The backend should therefore be designed as the source of truth for:
- global city and POI data
- user accounts
- saved places
- local tips
- itinerary planning
- future Unity scene metadata and navigation data

### Core Product Idea

The app is not a generic booking platform.

It is a curated travel exploration product focused on:
- discovering cities
- exploring POIs inside cities
- reading practical local tips
- identifying places to avoid or visit at the right time
- saving POIs
- building simple itineraries
- using location to personalize the experience

## 2. Business Goals

### Primary Goals

- Build a reliable global city and POI content service
- Support authenticated users via Google sign-in
- Support travel discovery, saves, tips, and itineraries
- Support future Unity-driven 3D presentation without changing business data contracts

### Secondary Goals

- Support content moderation and curation later
- Support rankings, recommendations, and personalized city ordering later
- Support navigation and 3D scene metadata later

## 3. Current Frontend Scope

The current Flutter app already implies these business modules:

- Login with Google
- Explore cities
- View a city detail page
- View POI detail pages
- Read POI tips
- Save and unsave POIs
- View profile summary
- View and reorder itinerary stops
- Use current location to infer nearest city
- Show a globe / map container that will later be backed by Unity

## 4. User Types

### Guest User

- can browse cities
- can browse POIs
- can read tips
- cannot persist personal data across devices in a real backend model

### Authenticated User

- signs in with Google
- has profile data
- can save POIs
- can manage itineraries
- can contribute tips in later versions

### Admin / Curator

Not yet implemented in the app, but backend should allow future support for:
- city management
- POI management
- moderation of tips
- featured content

## 5. Core Business Entities

The current app strongly suggests these backend entities.

### User

- `id`
- `google_subject_id`
- `email`
- `display_name`
- `avatar_url`
- `created_at`
- `updated_at`
- `status`

### User Profile

- `user_id`
- `countries_visited_count`
- `cities_visited_count`
- `tips_contributed_count`
- `home_city_id` optional
- `last_known_lat`
- `last_known_lng`
- `last_location_updated_at`

### City

- `id`
- `external_city_id` optional
- `name`
- `localized_name` optional
- `country_name`
- `country_code`
- `lat`
- `lng`
- `timezone`
- `tagline`
- `hero_image_url`
- `poi_count`
- `popularity_score` optional
- `status`

### City Tag

- `id`
- `city_id`
- `tag`

### City Season

- `id`
- `city_id`
- `season_label`

### POI

- `id`
- `city_id`
- `name`
- `category`
- `lat`
- `lng`
- `short_description`
- `long_description`
- `cover_image_url`
- `tip_count`
- `status`

### POI Rating Summary

- `poi_id`
- `atmosphere_score`
- `photos_score`
- `crowds_score`
- `access_score`
- `rating_count` optional

### POI Best Time

- `id`
- `poi_id`
- `time_label`

### Tip

- `id`
- `poi_id`
- `user_id` optional in current phase if imported content exists
- `author_name`
- `kind`
- `body`
- `likes_count`
- `created_at`
- `updated_at`
- `status`

`kind` should support:
- `positive`
- `neutral`
- `avoid`

### Saved POI

- `id`
- `user_id`
- `poi_id`
- `created_at`

### Itinerary

- `id`
- `user_id`
- `city_id`
- `title`
- `date`
- `created_at`
- `updated_at`

### Itinerary Stop

- `id`
- `itinerary_id`
- `poi_id`
- `sort_order`
- `arrive_at`
- `dwell_minutes`
- `note`

### Visited City

- `id`
- `user_id`
- `city_id`
- `visited_at` optional

### Unity Scene Mapping

For future Unity integration:

- `id`
- `entity_type` such as `globe`, `city`, `poi`, `route`
- `entity_id`
- `unity_scene_id`
- `unity_asset_key`
- `metadata_json`

## 6. Core User Flows

### 6.1 Authentication

1. User opens login page
2. User signs in with Google
3. Backend verifies Google identity token or authorization result
4. Backend creates or updates user record
5. Backend returns app auth token and user profile

### 6.2 Explore Cities

1. User opens explore page
2. App requests city list
3. Backend returns featured or searchable cities
4. App may optionally send user location
5. Backend may later sort or annotate nearest cities

### 6.3 View City Details

1. User selects a city
2. App requests city details
3. App requests POIs under the city
4. Backend returns city metadata and POI list

### 6.4 View POI Details

1. User selects a POI
2. App requests POI detail
3. App requests POI tips
4. Backend returns descriptions, ratings, best times, and tips

### 6.5 Save POI

1. Authenticated user taps save
2. App sends save request
3. Backend creates a saved POI record
4. App refreshes saved list and profile state

### 6.6 Manage Itinerary

1. User views itinerary
2. App requests itinerary and stops
3. User reorders stops
4. App submits updated sort order
5. Backend persists new order

### 6.7 Tips

Current app only reads tips, but backend should support future write operations:

- create tip
- update own tip
- delete own tip
- like tip
- filter by tip kind

### 6.8 Navigation and Unity Scene

Future flow:

1. User opens navigation page
2. App requests route context and scene data
3. Backend returns route payload, target POI, city info, and Unity asset metadata
4. Flutter passes scene-related data to Unity container

## 7. Recommended Backend Modules

### 7.1 Auth Service

- Google login
- session or JWT issuing
- token refresh if needed
- logout

### 7.2 User Service

- profile
- visited cities
- saved POIs
- statistics

### 7.3 City Service

- list cities
- city details
- city search
- nearby city lookup

### 7.4 POI Service

- POI list by city
- POI detail
- POI search
- POI ratings summary

### 7.5 Tip Service

- list tips by POI
- filter by kind
- create tip
- like tip
- moderation-ready status fields

### 7.6 Itinerary Service

- create itinerary
- get itinerary
- reorder itinerary stops
- add and remove stop
- update stop note

### 7.7 Media / Scene Metadata Service

- image URLs
- hero cover metadata
- Unity scene mapping
- asset key lookup

### 7.8 WebSocket / Realtime Service

- persistent client connection support
- authenticated realtime session
- user-targeted event delivery
- room or topic based subscription
- future Unity and navigation state sync
- future collaborative or live presence features

## 8. API Requirements

The exact protocol can be REST first, with later GraphQL if needed. REST is the simplest fit for the current app.

### 8.1 Auth APIs

- `POST /auth/google`
- `POST /auth/logout`
- `GET /me`

### 8.2 User APIs

- `GET /me/profile`
- `PATCH /me/profile`
- `GET /me/saved-pois`
- `POST /me/saved-pois/{poiId}`
- `DELETE /me/saved-pois/{poiId}`
- `GET /me/visited-cities`
- `POST /me/visited-cities/{cityId}`

### 8.3 City APIs

- `GET /cities`
- `GET /cities/{cityId}`
- `GET /cities/{cityId}/pois`
- `GET /cities/search?q=...`
- `GET /cities/nearby?lat=...&lng=...`

### 8.4 POI APIs

- `GET /pois/{poiId}`
- `GET /pois/{poiId}/tips`
- `GET /pois/{poiId}/ratings`

### 8.5 Tip APIs

- `POST /pois/{poiId}/tips`
- `PATCH /tips/{tipId}`
- `DELETE /tips/{tipId}`
- `POST /tips/{tipId}/likes`
- `DELETE /tips/{tipId}/likes`

### 8.6 Itinerary APIs

- `GET /me/itineraries`
- `POST /me/itineraries`
- `GET /me/itineraries/{itineraryId}`
- `PATCH /me/itineraries/{itineraryId}`
- `DELETE /me/itineraries/{itineraryId}`
- `POST /me/itineraries/{itineraryId}/stops`
- `PATCH /me/itineraries/{itineraryId}/stops/reorder`
- `PATCH /me/itineraries/{itineraryId}/stops/{stopId}`
- `DELETE /me/itineraries/{itineraryId}/stops/{stopId}`

### 8.7 Unity / Scene APIs

- `GET /scenes/globe`
- `GET /scenes/cities/{cityId}`
- `GET /scenes/pois/{poiId}`
- `GET /navigation/routes?poiId=...&lat=...&lng=...`

## 8.8 WebSocket Requirement

WebSocket support is mandatory for this backend.

It should not be treated as an optional future enhancement.

Reason:
- the product direction already includes Unity integration
- future 3D globe and city scenes may need bidirectional live messaging
- navigation and scene state are better modeled with realtime updates than repeated polling
- later product phases may include live tip updates, presence, collaborative itinerary editing, or realtime route state

### Minimum WebSocket Capabilities

- authenticated connection
- reconnect-safe session model
- server-to-client event push
- client-to-server command messages
- topic or room subscription model
- heartbeat / ping-pong support
- error event format

### Recommended Initial WebSocket Channels

- `user:{userId}`
- `city:{cityId}`
- `poi:{poiId}`
- `itinerary:{itineraryId}`
- `navigation:{sessionId}`
- `unity:{sessionId}`

### Recommended Initial Event Types

- `connection.ready`
- `connection.error`
- `user.profile.updated`
- `poi.saved`
- `poi.unsaved`
- `tip.created`
- `tip.updated`
- `tip.deleted`
- `itinerary.updated`
- `itinerary.reordered`
- `navigation.updated`
- `unity.scene.ready`
- `unity.city.selected`
- `unity.poi.selected`
- `unity.camera.changed`

### Recommended Initial Client Commands

- `subscribe`
- `unsubscribe`
- `navigation.start`
- `navigation.stop`
- `unity.focus_city`
- `unity.focus_poi`
- `unity.set_mode`
- `itinerary.reorder`

### Transport Recommendation

Recommended first implementation:
- REST for standard CRUD
- WebSocket for realtime events and command flows

This hybrid model fits the current product direction best.

## 9. Data Source Strategy

### Stable Geographic Data

City IDs, coordinates, country data, and timezone data should not depend on live third-party calls at runtime.

Recommended strategy:
- import global city reference data once
- normalize and store it in your own database
- use your own internal `city_id` as the primary key
- keep external IDs as reference fields

### Recommended External Data Sources

- GeoNames for base city reference data
- optional Wikidata or OSM metadata for enrichment
- your own curated POI layer on top

### Recommendation

Do not build the app around direct runtime dependence on public geocoding endpoints for base city data.

Use:
- your own database as source of truth
- external APIs only for enrichment, ingestion, or periodic sync

## 10. Suggested Database Design

A relational database is the best fit for the current product.

Recommended:
- PostgreSQL as primary database

Optional additions:
- PostGIS if you want serious geo queries
- Redis for caching hot city or POI lookups

### Why PostgreSQL fits

- strong relational data model
- good support for user content
- good support for search and indexing
- good path to geo support

## 11. Suggested Search and Geo Capabilities

### Phase 1

- city search by name
- POI lookup by city
- nearest city by coordinates

### Phase 2

- text search across city and POI
- ranking by popularity, recency, or quality
- geo radius search

## 12. Authorization Rules

### Public Read

These can be public in phase 1:
- city list
- city details
- POI details
- tip reads

### Authenticated Write

These require login:
- save POI
- create itinerary
- reorder itinerary
- create tip
- like tip
- update own profile

### Ownership Rules

- users can only edit their own itineraries
- users can only edit or delete their own tips
- users can only modify their own saved POIs

## 13. Non-Functional Requirements

### Performance

- city list should feel fast on mobile
- city and POI detail responses should be lightweight
- saved and itinerary operations should be low latency

### Scalability

- support growth from mock data to global city coverage
- support later scene metadata for Unity

### Reliability

- auth flow must be robust
- location-dependent APIs should degrade gracefully
- writes should be idempotent where useful, especially save / unsave
- realtime connections should support reconnect and state resync

### Observability

- request logs
- auth logs
- error tracking
- audit trail for content moderation later
- WebSocket connection metrics and event tracing

## 14. Phase Plan

### Phase 1: MVP Backend

- Google auth
- user profile
- cities
- POIs
- tips read
- save / unsave POI
- itineraries
- foundational WebSocket service

### Phase 2: Content and Social

- create tip
- like tip
- moderation support
- search improvements

### Phase 3: Unity and Navigation

- scene metadata APIs
- route payload APIs
- city / POI to Unity asset mapping
- richer Unity realtime bridge
- navigation realtime events

## 15. Backend Output Expected From This Document

If this document is used to generate a backend service, the generated service should include:

- database schema for the entities above
- authentication support for Google sign-in based login
- REST APIs for cities, POIs, tips, saves, profile, and itineraries
- WebSocket infrastructure for realtime messaging
- ownership and auth middleware
- a clear extension point for Unity scene metadata and future routing

## 16. Minimal Deliverable Definition

The smallest backend that matches the current frontend product should support:

- user login
- city list
- city details
- POI list by city
- POI details
- tips list by POI
- save and unsave POI
- read profile
- read and reorder itinerary
- authenticated WebSocket connection
- at least basic realtime user and itinerary event delivery

If a backend generator only implements this MVP first, it will still match the current app closely enough to replace local mock data in the next step.
