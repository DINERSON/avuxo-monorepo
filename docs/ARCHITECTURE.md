# Corrida por Assinatura - System Architecture

## 1. Overview

`Corrida por Assinatura` is a local ride-hailing MVP designed around a subscription business model for drivers. Instead of charging a commission on each ride, the platform charges drivers a recurring monthly subscription. Passengers pay drivers directly at the end of the ride using cash or PIX, which simplifies payment operations for the MVP and reduces fintech complexity in the first version.

This document defines the complete target architecture for the MVP implementation, including client apps, backend services, data model, API design, ride lifecycle, matching logic, security model, and recommended project structure. It is intended to guide implementation across the passenger app, driver app, admin dashboard, and backend.

## 2. Product and Architecture Goals

### 2.1 Primary goals

- Launch a geographically limited local ride-hailing MVP quickly.
- Support two mobile apps built with a shared technology stack.
- Enable real-time driver discovery and trip state updates.
- Keep infrastructure simple enough for an MVP while preserving a clean evolution path.
- Enforce the subscription-first business model for drivers.
- Minimize operational complexity by avoiding in-app payment orchestration in the first version.

### 2.2 MVP business rules

- Drivers must have an active subscription to receive rides.
- Passengers do not pay through the platform.
- Drivers receive payment directly from passengers via cash or PIX.
- Only approved drivers can go online and receive trip requests.
- Dispatch is sequential: nearby drivers are invited one at a time.

### 2.3 Non-goals for the MVP

- Dynamic surge pricing.
- In-app card processing.
- Multi-stop rides.
- Corporate accounts.
- Advanced route optimization.
- Marketplace bidding.
- Full microservices decomposition.

## 3. Tech Stack

The MVP should use the following core stack:

### 3.1 Mobile applications

- **Flutter** for both mobile apps:
  - `passenger-app/` for passengers
  - `driver-app/` for drivers
- Rationale:
  - Single cross-platform codebase for Android and iOS.
  - Fast UI iteration for MVP.
  - Strong real-time and Firebase ecosystem support.
  - Shared design system, networking layer, and mapping integrations.

### 3.2 Backend

- **Node.js + Express**
- Rationale:
  - Excellent fit for API-first development.
  - Easy integration with Firebase Admin SDK.
  - Strong ecosystem for validation, auth middleware, logging, and job orchestration.
  - Fast to implement and maintain for an MVP team.

### 3.3 Firebase services

- **Firestore**
  - Primary document database for users, drivers, rides, subscriptions, ratings, and admin-facing operational data.
- **Realtime Database**
  - Used for highly dynamic live-tracking streams such as driver movement and active ride tracking state.
- **Firebase Cloud Messaging (FCM)**
  - Push notifications to drivers and passengers for ride assignment, ride status changes, and administrative alerts.
- **Firebase Authentication**
  - Phone-based OTP authentication for passengers and drivers.

### 3.4 Mapping and geolocation

- **Google Maps API**
  - Geocoding / reverse geocoding
  - Maps rendering in mobile apps
  - Distance estimation and routing assistance
  - Nearby driver visualization

### 3.5 In-memory cache

- **Redis**
  - Driver location cache
  - Online driver availability cache
  - Fast geospatial / proximity lookup support
  - Short-lived dispatch coordination state
  - Timeout orchestration for sequential driver offers

### 3.6 Admin interface

- **React + TypeScript** in `admin-dashboard/`
- Rationale:
  - Strong productivity for operational dashboards.
  - Type-safe admin workflows.
  - Easy integration with REST APIs and role-based protected routes.

### 3.7 Recommended supporting libraries

Although implementation details may vary, the following are recommended:

- Backend:
  - `express`
  - `firebase-admin`
  - `jsonwebtoken`
  - `zod` or `joi` for validation
  - `ioredis`
  - `pino` or `winston` for logging
  - `helmet`
  - `cors`
  - `express-rate-limit`
- Flutter:
  - `dio` or `http`
  - `firebase_auth`
  - `cloud_firestore`
  - `firebase_messaging`
  - `google_maps_flutter`
  - `geolocator`
  - `flutter_bloc`, `riverpod`, or `provider`
- Admin dashboard:
  - `react`
  - `typescript`
  - `react-router`
  - `tanstack-query`
  - `axios`
  - UI library of choice, such as MUI or Ant Design

## 4. High-Level System Architecture

### 4.1 Architecture style

The MVP should follow a **modular monolith backend** architecture with three client frontends:

- Passenger mobile app
- Driver mobile app
- Admin dashboard
- Single backend API service

This architecture is preferred for MVP speed, operational simplicity, and easier local development. Within the backend, modules should still be clearly separated by domain:

- Auth
- Users
- Drivers
- Rides
- Dispatch
- Subscriptions
- Ratings
- Admin
- Notifications

### 4.2 Component diagram (text)

```text
+-------------------+          +-------------------+          +----------------------+
| Passenger App     |          | Driver App        |          | Admin Dashboard      |
| Flutter           |          | Flutter           |          | React + TypeScript   |
+---------+---------+          +---------+---------+          +----------+-----------+
          |                              |                               |
          | HTTPS REST                   | HTTPS REST                    | HTTPS REST
          | FCM                          | FCM                           |
          |                              | Realtime tracking             |
          v                              v                               v
                     +---------------------------------------------------+
                     |            Node.js + Express Backend              |
                     |---------------------------------------------------|
                     | Auth | Users | Drivers | Rides | Dispatch | Admin |
                     | Subs | Ratings | Notifications | Tracking API     |
                     +-------------------+-------------------------------+
                                         |
        +-------------------+------------+---------------+------------------------+
        |                   |                            |                        |
        v                   v                            v                        v
+---------------+   +---------------+           +----------------+       +----------------+
| Firestore     |   | Realtime DB   |           | Redis          |       | Google Maps    |
| Primary data  |   | Live tracking |           | Driver cache   |       | Geocode/routes |
+---------------+   +---------------+           +----------------+       +----------------+
                                         |
                                         v
                                +-------------------+
                                | Firebase Auth     |
                                | Phone OTP         |
                                +-------------------+
                                         |
                                         v
                                +-------------------+
                                | Firebase FCM      |
                                | Push notifications|
                                +-------------------+
```

### 4.3 Responsibilities by component

#### Passenger app

- Register and authenticate users via phone OTP.
- Create ride requests.
- View nearby drivers and ride state.
- Receive push updates about driver assignment and ride progress.
- Track active ride progress.
- View ride history and submit ratings.

#### Driver app

- Register and submit driver profile and documents.
- Authenticate via phone OTP.
- Toggle online / offline status.
- Continuously publish current location when online and active.
- Receive ride offers.
- Accept or reject ride requests.
- Update ride status throughout the trip lifecycle.
- View subscription status.

#### Admin dashboard

- Review and approve / reject driver registrations.
- View rides and operational activity.
- Manage subscriptions.
- Inspect platform stats.
- Monitor driver status and system health.

#### Backend API

- Central source of business rules.
- Validates authentication and authorization.
- Writes persistent data to Firestore.
- Coordinates real-time state via Realtime Database and Redis.
- Manages ride dispatch sequencing and timeouts.
- Sends push notifications via FCM.
- Enforces subscription and approval requirements for drivers.

#### Firestore

- Source of truth for durable business entities.
- Stores user profiles, driver records, rides, subscriptions, and ratings.

#### Realtime Database

- Stores rapidly changing ride tracking and live location state.
- Optimized for frequent updates such as driver coordinate streaming.

#### Redis

- Maintains latest online driver coordinates and availability.
- Speeds nearby driver lookup during dispatch.
- Holds ephemeral dispatch state such as pending offers and timeout windows.

#### Google Maps API

- Converts addresses to coordinates and back.
- Helps calculate route distance.
- Supports map rendering and navigation context.

### 4.4 Why Firestore + Realtime DB + Redis together

This combination is intentional:

- **Firestore** is excellent for durable application records and querying operational data.
- **Realtime Database** is better suited to continuous, high-frequency, live updates such as driver motion during active trips.
- **Redis** gives low-latency, ephemeral, high-throughput access for matching and dispatch, which Firestore alone is not ideal for.

This avoids overloading Firestore with extremely frequent coordinate updates while still preserving durable ride state in Firestore.

## 5. End-to-End Interaction Model

### 5.1 Authentication flow

1. User submits phone number to backend.
2. Backend coordinates OTP verification through Firebase Auth.
3. User enters OTP.
4. Backend validates the Firebase token / verification proof.
5. Backend creates or updates the user or driver record in Firestore.
6. Backend issues application JWT containing:
   - user id
   - role (`passenger`, `driver`, or `admin`)
   - token expiration
7. Client uses JWT on subsequent REST requests.

### 5.2 Driver online flow

1. Driver logs in.
2. Backend verifies:
   - driver exists
   - driver status is `approved`
   - subscription status is active
3. Driver toggles online status.
4. Driver app starts sending periodic location updates.
5. Backend writes:
   - durable online/offline state to Firestore
   - latest location to Redis
   - active movement stream to Realtime Database when relevant

### 5.3 Ride request flow

1. Passenger creates a ride request with pickup and destination.
2. Backend calculates estimated fare and distance.
3. Ride is stored in Firestore with `status = requested`, then moved to `finding_driver`.
4. Dispatch module queries Redis for nearby eligible drivers within the configured radius.
5. Drivers are sorted by distance.
6. Closest driver receives the first ride offer via FCM.
7. Driver has 30 seconds to accept or reject.
8. If rejected or timed out, backend appends driver id to `rejected_by[]`.
9. Dispatch sends offer to the next closest driver.
10. Once accepted:
    - ride status becomes `assigned`
    - selected `driver_id` is persisted
    - passenger and driver receive updates

### 5.4 Active ride flow

1. Driver navigates to pickup.
2. Driver updates ride status to `driver_arriving`.
3. When passenger boards, driver updates to `in_progress`.
4. During the ride, current location updates are streamed through Realtime Database.
5. At dropoff, driver updates ride status to `completed`.
6. Passenger pays driver directly via cash or PIX.
7. Both sides may submit ratings.

## 6. Real-Time Communication Flow

Real-time behavior is critical for ride-hailing. The MVP should use different channels depending on the type of data:

### 6.1 Communication channels by use case

- **REST API**
  - Authentication
  - Registration
  - Ride creation
  - Ride status transitions
  - History retrieval
  - Admin operations

- **FCM push notifications**
  - New ride offer to driver
  - Ride accepted notification to passenger
  - Ride cancellation notification
  - Driver arriving updates
  - Subscription / administrative alerts

- **Realtime Database**
  - Active driver location stream
  - Active ride tracking stream
  - Optional live ride status mirrors for low-latency mobile UI synchronization

- **Redis**
  - Internal backend-only real-time matching state
  - Latest online drivers location cache
  - Timeout and dispatch sequencing state

### 6.2 Real-time ride dispatch flow

```text
Passenger App
  -> POST /rides/request
Backend
  -> Store ride in Firestore
  -> Query Redis for nearby approved + online + subscribed drivers
  -> Sort by distance
  -> Send FCM offer to first driver
Driver App
  -> Shows offer with pickup, destination, estimated fare
  -> Accept or reject within 30 seconds
Backend
  -> If accept: mark ride assigned in Firestore, notify passenger, stop dispatch
  -> If reject/timeout: append to rejected_by[], send to next driver
```

### 6.3 Real-time location tracking flow

```text
Driver App
  -> Sends periodic coordinates
Backend
  -> Update Redis latest location
  -> Update Firestore current_location for profile snapshot
  -> Update Realtime Database for active tracking stream
Passenger App
  -> Subscribes to ride tracking node
  -> Renders live driver movement on map
```

### 6.4 Recommended location update frequencies

- Driver online but idle: every 8 to 15 seconds
- Driver en route to pickup: every 3 to 5 seconds
- Driver during active ride: every 3 to 5 seconds

This balances responsiveness and mobile battery usage.

## 7. Database Schema

The primary durable schema lives in Firestore. Collection definitions below should be treated as the source-of-truth data model for the MVP.

### 7.1 `users`

Represents passenger accounts and can also be used for generalized user identity metadata where needed.

**Collection:** `users`

**Document shape:**

```json
{
  "id": "user_123",
  "name": "Maria Silva",
  "phone": "+5511999999999",
  "email": "maria@email.com",
  "rating_avg": 4.8,
  "created_at": "2026-04-21T12:00:00Z"
}
```

**Fields:**

- `id`: string, document id, unique user identifier
- `name`: string
- `phone`: string, unique
- `email`: string, optional for MVP but supported
- `rating_avg`: number, aggregated average received by this user as passenger
- `created_at`: timestamp

### 7.2 `drivers`

Represents all driver profiles including approval, subscription, and live availability fields.

**Collection:** `drivers`

**Document shape:**

```json
{
  "id": "drv_123",
  "name": "João Souza",
  "phone": "+5511988888888",
  "email": "joao@email.com",
  "documents": {
    "id_doc": "https://storage.example/id_doc.jpg",
    "license": "https://storage.example/license.jpg",
    "car_info": "Fiat Mobi 2022 - Branco",
    "car_plate": "ABC1D23"
  },
  "status": "approved",
  "is_online": true,
  "current_location": {
    "lat": -23.5505,
    "lng": -46.6333
  },
  "subscription_status": "active",
  "rating_avg": 4.9,
  "created_at": "2026-04-21T12:00:00Z"
}
```

**Fields:**

- `id`: string
- `name`: string
- `phone`: string, unique
- `email`: string
- `documents.id_doc`: string
- `documents.license`: string
- `documents.car_info`: string
- `documents.car_plate`: string
- `status`: enum
  - `pending`
  - `approved`
  - `rejected`
  - `suspended`
- `is_online`: boolean
- `current_location.lat`: number
- `current_location.lng`: number
- `subscription_status`: string, usually derived from subscription state but duplicated for operational speed
- `rating_avg`: number
- `created_at`: timestamp

### 7.3 `rides`

Represents each ride request and lifecycle.

**Collection:** `rides`

**Document shape:**

```json
{
  "id": "ride_123",
  "passenger_id": "user_123",
  "driver_id": "drv_123",
  "pickup": {
    "lat": -23.551,
    "lng": -46.634,
    "address": "Av. Paulista, 1000 - São Paulo"
  },
  "destination": {
    "lat": -23.561,
    "lng": -46.645,
    "address": "Rua Vergueiro, 500 - São Paulo"
  },
  "status": "assigned",
  "fare": 21.25,
  "distance_km": 6.5,
  "created_at": "2026-04-21T12:10:00Z",
  "accepted_at": "2026-04-21T12:11:05Z",
  "started_at": null,
  "completed_at": null,
  "rejected_by": ["drv_777", "drv_888"]
}
```

**Fields:**

- `id`: string
- `passenger_id`: string
- `driver_id`: string or `null` until assigned
- `pickup.lat`: number
- `pickup.lng`: number
- `pickup.address`: string
- `destination.lat`: number
- `destination.lng`: number
- `destination.address`: string
- `status`: enum
  - `requested`
  - `finding_driver`
  - `assigned`
  - `driver_arriving`
  - `in_progress`
  - `completed`
  - `cancelled`
- `fare`: number
- `distance_km`: number
- `created_at`: timestamp
- `accepted_at`: timestamp or `null`
- `started_at`: timestamp or `null`
- `completed_at`: timestamp or `null`
- `rejected_by`: array of driver ids that rejected or timed out

### 7.4 `subscriptions`

Represents driver subscription lifecycle.

**Collection:** `subscriptions`

**Document shape:**

```json
{
  "id": "sub_123",
  "driver_id": "drv_123",
  "plan_name": "Mensal Padrão",
  "amount": 149.9,
  "status": "active",
  "start_date": "2026-04-01T00:00:00Z",
  "end_date": "2026-04-30T23:59:59Z"
}
```

**Fields:**

- `id`: string
- `driver_id`: string
- `plan_name`: string
- `amount`: number
- `status`: enum
  - `active`
  - `expired`
  - `cancelled`
- `start_date`: timestamp
- `end_date`: timestamp

### 7.5 `ratings`

Represents post-ride user feedback.

**Collection:** `ratings`

**Document shape:**

```json
{
  "id": "rat_123",
  "ride_id": "ride_123",
  "from_user_id": "user_123",
  "to_user_id": "drv_123",
  "score": 5,
  "comment": "Motorista educado e pontual"
}
```

**Fields:**

- `id`: string
- `ride_id`: string
- `from_user_id`: string
- `to_user_id`: string
- `score`: integer from 1 to 5
- `comment`: string

### 7.6 Recommended additional operational fields

To make implementation safer and more scalable, the following extra fields are strongly recommended even if not strictly required in the initial spec:

- `updated_at` on all collections
- `fcm_token` on `users` and `drivers`
- `cancel_reason` on `rides`
- `dispatch_attempts` on `rides`
- `last_location_at` on `drivers`
- `approved_at`, `approved_by` on `drivers`
- `payment_method` on `rides` with values such as `cash` or `pix` for operational reporting

These fields are optional additions and should not replace the required schema above.

### 7.7 Firestore indexing recommendations

Recommended composite indexes:

- `drivers.status + drivers.is_online + drivers.subscription_status`
- `rides.passenger_id + rides.created_at desc`
- `rides.driver_id + rides.created_at desc`
- `rides.status + rides.created_at desc`
- `subscriptions.driver_id + subscriptions.status`
- `ratings.to_user_id + ratings.score`

### 7.8 Realtime Database structure recommendation

Suggested live-tracking paths:

```text
/driver_locations/{driverId}
  lat
  lng
  heading
  speed
  timestamp

/ride_tracking/{rideId}
  driver_id
  passenger_id
  status
  driver_location
  updated_at
```

### 7.9 Redis key design recommendation

Suggested Redis keys:

- `driver:location:{driverId}` -> latest coordinates and timestamp
- `driver:online:{driverId}` -> online availability and eligibility snapshot
- `ride:dispatch:{rideId}` -> current dispatch state, offered driver, timeout deadline
- `geo:drivers:{city}` -> geospatial set for nearby search if using geo features

## 8. API Design Principles

### 8.1 API conventions

- Base path: `/api/v1`
- JSON request and response bodies
- JWT in `Authorization: Bearer <token>`
- Standard response envelope recommended:

```json
{
  "success": true,
  "data": {},
  "message": "Optional human-readable message"
}
```

- Standard error envelope recommended:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Detailed error message"
  }
}
```

### 8.2 Roles

- `passenger`
- `driver`
- `admin`

### 8.3 Authentication behavior

- All authenticated endpoints require a valid JWT.
- Driver endpoints require role `driver`.
- Admin endpoints require role `admin`.
- Some driver actions additionally require:
  - `status = approved`
  - `subscription_status = active`

## 9. Full REST API Specification

Examples below are shown relative to `/api/v1`.

### 9.1 Auth

#### `POST /auth/register`

Creates or prepares a passenger or driver account for phone verification.

**Request:**

```json
{
  "name": "Maria Silva",
  "phone": "+5511999999999",
  "email": "maria@email.com",
  "role": "passenger"
}
```

**Driver registration variant:**

```json
{
  "name": "João Souza",
  "phone": "+5511988888888",
  "email": "joao@email.com",
  "role": "driver"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "verification_id": "firebase_verification_reference",
    "role": "passenger"
  },
  "message": "OTP sent successfully"
}
```

#### `POST /auth/verify-otp`

Verifies the OTP and returns application JWT.

**Request:**

```json
{
  "phone": "+5511999999999",
  "otp": "123456",
  "verification_id": "firebase_verification_reference"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "user_123",
      "name": "Maria Silva",
      "phone": "+5511999999999",
      "role": "passenger"
    }
  }
}
```

#### `POST /auth/login`

For phone-based auth flows, this may either initiate a new OTP session or validate a Firebase identity token issued on the client. For the MVP, keeping this endpoint allows a consistent login entry point.

**Request:**

```json
{
  "phone": "+5511999999999"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "verification_id": "firebase_verification_reference"
  },
  "message": "OTP sent"
}
```

### 9.2 Rides

#### `POST /rides/request`

Creates a new ride request from the passenger app.

**Auth:** passenger

**Request:**

```json
{
  "pickup": {
    "lat": -23.551,
    "lng": -46.634,
    "address": "Av. Paulista, 1000 - São Paulo"
  },
  "destination": {
    "lat": -23.561,
    "lng": -46.645,
    "address": "Rua Vergueiro, 500 - São Paulo"
  }
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "ride_123",
    "status": "finding_driver",
    "fare": 21.25,
    "distance_km": 6.5,
    "pickup": {
      "lat": -23.551,
      "lng": -46.634,
      "address": "Av. Paulista, 1000 - São Paulo"
    },
    "destination": {
      "lat": -23.561,
      "lng": -46.645,
      "address": "Rua Vergueiro, 500 - São Paulo"
    },
    "created_at": "2026-04-21T12:10:00Z"
  }
}
```

#### `GET /rides/:id`

Returns ride details.

**Auth:** passenger or assigned driver or admin

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "ride_123",
    "passenger_id": "user_123",
    "driver_id": "drv_123",
    "pickup": {
      "lat": -23.551,
      "lng": -46.634,
      "address": "Av. Paulista, 1000 - São Paulo"
    },
    "destination": {
      "lat": -23.561,
      "lng": -46.645,
      "address": "Rua Vergueiro, 500 - São Paulo"
    },
    "status": "assigned",
    "fare": 21.25,
    "distance_km": 6.5,
    "created_at": "2026-04-21T12:10:00Z",
    "accepted_at": "2026-04-21T12:11:05Z",
    "started_at": null,
    "completed_at": null,
    "rejected_by": ["drv_777"]
  }
}
```

#### `PATCH /rides/:id/accept`

Accepts a pending ride offer.

**Auth:** driver

**Rules:**

- Driver must be the currently offered driver.
- Driver must be approved.
- Driver must be online.
- Driver must have an active subscription.
- Ride must still be in dispatchable state.

**Request:**

```json
{
  "driver_id": "drv_123"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "ride_123",
    "driver_id": "drv_123",
    "status": "assigned",
    "accepted_at": "2026-04-21T12:11:05Z"
  },
  "message": "Ride accepted successfully"
}
```

#### `PATCH /rides/:id/reject`

Rejects a ride offer.

**Auth:** driver

**Request:**

```json
{
  "driver_id": "drv_123",
  "reason": "too_far"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "ride_123",
    "status": "finding_driver",
    "rejected_by": ["drv_123"]
  },
  "message": "Ride rejected, dispatching to next driver"
}
```

#### `PATCH /rides/:id/status`

Updates ride status during execution.

**Auth:** assigned driver, sometimes passenger for cancellation if policy allows

**Allowed transitions for driver:**

- `assigned` -> `driver_arriving`
- `driver_arriving` -> `in_progress`
- `in_progress` -> `completed`
- `assigned` or `driver_arriving` -> `cancelled` if cancellation policy permits

**Request:**

```json
{
  "status": "in_progress"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "ride_123",
    "status": "in_progress",
    "started_at": "2026-04-21T12:18:00Z"
  }
}
```

#### `GET /rides/history`

Returns ride history for the current authenticated passenger or driver.

**Auth:** passenger or driver

**Query params:**

- `page`
- `limit`
- `status` optional

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "ride_123",
        "status": "completed",
        "fare": 21.25,
        "distance_km": 6.5,
        "created_at": "2026-04-21T12:10:00Z",
        "completed_at": "2026-04-21T12:32:00Z"
      }
    ],
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

### 9.3 Drivers

#### `POST /drivers/register`

Completes driver profile registration with documents and vehicle information.

**Auth:** driver

**Request:**

```json
{
  "name": "João Souza",
  "phone": "+5511988888888",
  "email": "joao@email.com",
  "documents": {
    "id_doc": "https://storage.example/id_doc.jpg",
    "license": "https://storage.example/license.jpg",
    "car_info": "Fiat Mobi 2022 - Branco",
    "car_plate": "ABC1D23"
  }
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "drv_123",
    "status": "pending"
  },
  "message": "Driver registration submitted for review"
}
```

#### `PATCH /drivers/:id/online-status`

Updates driver online / offline state.

**Auth:** driver

**Rules:**

- Only the authenticated driver may update their own status.
- Driver must be `approved`.
- Driver must have `subscription_status = active` to go online.

**Request:**

```json
{
  "is_online": true,
  "current_location": {
    "lat": -23.5505,
    "lng": -46.6333
  }
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "drv_123",
    "is_online": true,
    "current_location": {
      "lat": -23.5505,
      "lng": -46.6333
    },
    "subscription_status": "active"
  }
}
```

#### `GET /drivers/nearby`

Returns nearby available drivers for passenger-side visualization or pre-request estimation.

**Auth:** passenger

**Query params:**

- `lat`
- `lng`
- `radius_km`

**Example request:**

`GET /drivers/nearby?lat=-23.551&lng=-46.634&radius_km=5`

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "drv_123",
        "name": "João Souza",
        "rating_avg": 4.9,
        "current_location": {
          "lat": -23.5505,
          "lng": -46.6333
        },
        "distance_km": 0.4
      }
    ]
  }
}
```

### 9.4 Admin

#### `GET /admin/drivers`

Lists drivers for review and operations.

**Auth:** admin

**Query params:**

- `status`
- `page`
- `limit`

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "drv_123",
        "name": "João Souza",
        "phone": "+5511988888888",
        "status": "pending",
        "subscription_status": "expired",
        "created_at": "2026-04-21T12:00:00Z"
      }
    ],
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

#### `PATCH /admin/drivers/:id/approve`

Approves, rejects, or suspends a driver.

**Auth:** admin

**Request:**

```json
{
  "status": "approved"
}
```

**Alternative statuses:**

```json
{
  "status": "rejected"
}
```

```json
{
  "status": "suspended"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "drv_123",
    "status": "approved"
  },
  "message": "Driver status updated successfully"
}
```

#### `GET /admin/rides`

Lists rides for monitoring and support.

**Auth:** admin

**Query params:**

- `status`
- `driver_id`
- `passenger_id`
- `page`
- `limit`

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "ride_123",
        "passenger_id": "user_123",
        "driver_id": "drv_123",
        "status": "completed",
        "fare": 21.25,
        "distance_km": 6.5,
        "created_at": "2026-04-21T12:10:00Z"
      }
    ],
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

#### `GET /admin/stats`

Returns key platform metrics.

**Auth:** admin

**Response:**

```json
{
  "success": true,
  "data": {
    "total_users": 1240,
    "total_drivers": 212,
    "approved_drivers": 180,
    "active_subscriptions": 143,
    "rides_today": 86,
    "rides_completed_today": 72,
    "rides_cancelled_today": 9,
    "revenue_mrr": 21335.7
  }
}
```

#### `GET /admin/subscriptions`

Lists subscriptions.

**Auth:** admin

**Query params:**

- `status`
- `driver_id`
- `page`
- `limit`

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "sub_123",
        "driver_id": "drv_123",
        "plan_name": "Mensal Padrão",
        "amount": 149.9,
        "status": "active",
        "start_date": "2026-04-01T00:00:00Z",
        "end_date": "2026-04-30T23:59:59Z"
      }
    ],
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

#### `POST /admin/subscriptions`

Creates or renews a driver subscription.

**Auth:** admin

**Request:**

```json
{
  "driver_id": "drv_123",
  "plan_name": "Mensal Padrão",
  "amount": 149.9,
  "start_date": "2026-05-01T00:00:00Z",
  "end_date": "2026-05-31T23:59:59Z"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "sub_456",
    "driver_id": "drv_123",
    "status": "active"
  },
  "message": "Subscription created successfully"
}
```

## 10. Ride Flow

The ride flow must follow the exact MVP operational sequence below.

### 10.1 Requested flow

1. Passenger requests a ride.
2. Backend validates pickup and destination.
3. Backend calculates estimated distance and fare.
4. Ride record is created.
5. System finds nearby online drivers within **3 to 5 km**.
6. Drivers are sorted by proximity.
7. Ride offer is sent to the closest driver.
8. Driver sees:
   - pickup
   - destination
   - estimated fare
9. Driver can accept or reject.
10. If the driver rejects, or does not answer within **30 seconds**, the request is sent to the next closest driver.
11. Once a driver accepts, ride becomes `assigned`.
12. Driver navigates to pickup.
13. Driver indicates arrival / en route status.
14. Ride starts when passenger boards.
15. Ride ends at destination.
16. Passenger pays driver directly with cash or PIX.
17. Rating flow is opened.

### 10.2 Ride state machine

```text
requested
  -> finding_driver
      -> assigned
          -> driver_arriving
              -> in_progress
                  -> completed

finding_driver -> cancelled
assigned -> cancelled
driver_arriving -> cancelled
```

### 10.3 Timeout handling

- Each sequential offer window lasts 30 seconds.
- If the driver does not respond in time:
  - backend marks this attempt as timed out
  - driver id is appended to `rejected_by[]`
  - dispatch continues to the next driver
- If no eligible drivers remain:
  - ride status becomes `cancelled`
  - passenger receives a “no drivers available” message

### 10.4 Operational safeguards

- One driver cannot receive multiple simultaneous offers unless explicitly allowed later.
- A driver already assigned to a ride should be excluded from new matching.
- A passenger should have only one active ride at a time.
- Ride acceptance must be atomic to prevent duplicate assignment.

## 11. Fare Calculation

### 11.1 Formula

The MVP fare formula should be:

`fare = base_fare + (distance_km * price_per_km)`

### 11.2 Suggested defaults

- `base_fare = 5.00 BRL`
- `price_per_km = 2.50 BRL`

### 11.3 Example

If the route distance is `6.5 km`:

- base fare = `5.00`
- distance component = `6.5 * 2.50 = 16.25`
- total fare = `21.25 BRL`

### 11.4 Fare calculation source

Distance should be estimated using Google Maps routing or a route distance service at ride request time. For MVP consistency:

- Use the route-based distance if available.
- If route service fails, fall back to straight-line estimation with a configurable multiplier.

### 11.5 Fare policy recommendations

- Display fare as an estimate before assignment.
- Persist the estimated fare in the ride record.
- Allow future admin configurability for:
  - base fare
  - price per km
  - city-specific pricing

## 12. Driver Matching

### 12.1 Matching requirements

The system must:

- Query online drivers within a configured radius.
- Filter only approved drivers.
- Filter only drivers with active subscriptions.
- Filter only drivers not already assigned to another active ride.
- Sort eligible drivers by nearest distance.
- Dispatch sequentially with a 30-second timeout per driver.
- Track `rejected_by[]` to avoid redispatching the same ride to the same driver.

### 12.2 Matching radius

Recommended default:

- primary radius: **3 km**
- fallback radius: expand to **5 km** if no drivers found

This aligns with the requested MVP flow while keeping dispatch practical in lower-density areas.

### 12.3 Matching algorithm

1. Get pickup coordinates.
2. Query Redis for online drivers near pickup.
3. Load eligibility metadata for candidate drivers:
   - approval status
   - active subscription
   - online status
   - current assignment state
4. Remove drivers already in `rejected_by[]`.
5. Sort by ascending distance to pickup.
6. Offer ride to the first driver.
7. Wait up to 30 seconds.
8. If rejected or timed out, move to the next driver.
9. Stop when accepted or when candidate list is exhausted.

### 12.4 Acceptance atomicity

Ride assignment should be protected using one of the following:

- Firestore transaction
- Redis distributed lock
- Combined transaction + lock pattern

The goal is to ensure that two simultaneous accept attempts cannot both succeed.

### 12.5 Pseudocode reference

```text
create ride
set status = finding_driver
candidates = find nearby eligible drivers sorted by distance
for each driver in candidates:
  if driver in rejected_by:
    continue
  send offer to driver
  wait 30s for response
  if accepted:
    atomically assign ride to driver
    notify passenger
    stop
  else:
    append driver to rejected_by
if no acceptance:
  mark ride cancelled
  notify passenger
```

## 13. Project Structure

The MVP should use a monorepo to simplify cross-project coordination and code sharing.

### 13.1 Required structure

```text
corrida-app/
  passenger-app/
  driver-app/
  admin-dashboard/
  backend/
  docs/
```

### 13.2 Detailed recommended structure

```text
corrida-app/
  passenger-app/
    lib/
      app/
      core/
      features/
        auth/
        home/
        rides/
        profile/
      shared/
    pubspec.yaml

  driver-app/
    lib/
      app/
      core/
      features/
        auth/
        onboarding/
        availability/
        ride_offers/
        active_ride/
        earnings/
        profile/
      shared/
    pubspec.yaml

  admin-dashboard/
    src/
      app/
      modules/
        auth/
        drivers/
        rides/
        subscriptions/
        stats/
      components/
      services/
      hooks/
      types/
    package.json

  backend/
    src/
      app/
      config/
      modules/
        auth/
        users/
        drivers/
        rides/
        dispatch/
        subscriptions/
        ratings/
        admin/
        notifications/
        tracking/
      middleware/
      utils/
      shared/
    package.json

  docs/
    ARCHITECTURE.md
```

### 13.3 Shared architectural conventions

- Domain-first module boundaries.
- Clear DTO / validation layers in the backend.
- Repository or service abstraction for Firebase and Redis access.
- Shared API contract documentation.
- Environment-based configuration.

## 14. Security

Security for the MVP must be simple but strict enough to protect users, drivers, and operational integrity.

### 14.1 JWT

The backend should issue JWTs after successful OTP verification.

JWT should contain:

- `sub`: user id
- `role`: `passenger`, `driver`, or `admin`
- `iat`
- `exp`

Recommendations:

- Short to moderate expiry for mobile sessions
- Refresh strategy can be added later if needed
- Always validate signature and expiration on every protected request

### 14.2 Phone OTP authentication

- Use Firebase Auth phone verification.
- OTP verification should be mandatory for both passengers and drivers.
- Backend should trust only validated Firebase identity proofs or a backend-controlled OTP verification process.
- Prevent repeated brute-force verification attempts using rate limits.

### 14.3 Admin RBAC

Admin endpoints must require:

- authenticated JWT
- `role = admin`

Admin privileges should include:

- driver review
- subscription management
- system reporting
- ride oversight

If future staff roles are introduced, split admin roles into finer-grained permissions such as:

- `support_admin`
- `operations_admin`
- `super_admin`

### 14.4 Driver document verification

Driver activation must require manual or semi-manual verification of:

- ID document
- driver license
- vehicle information
- vehicle plate

Only after verification should `status` become `approved`.

### 14.5 Subscription enforcement

Before allowing a driver to:

- go online
- receive ride offers
- accept a ride

the backend must confirm:

- `status = approved`
- `subscription_status = active`

### 14.6 API hardening

Recommended protections:

- `helmet` for HTTP hardening
- strict CORS configuration
- request body validation on all endpoints
- rate limiting on:
  - auth endpoints
  - ride creation
  - admin endpoints
- request logging and audit logging for admin actions

### 14.7 Data access rules

- Passengers can access only their own profile and rides.
- Drivers can access only their own profile, rides, and subscription view.
- Drivers cannot approve themselves or modify protected approval fields.
- Admin can access operational data according to role.

### 14.8 Sensitive data considerations

- Document file URLs should ideally point to protected storage.
- Avoid exposing raw internal verification notes to drivers.
- Encrypt secrets in environment configuration.
- Never trust client-provided role values after login.

### 14.9 Firebase security strategy

Because the backend is the central business authority:

- Prefer backend-mediated reads and writes for sensitive business entities.
- Use Firebase Admin SDK on the backend for trusted operations.
- If clients read directly from Realtime Database for tracking, write strict Firebase security rules limiting access to:
  - assigned passenger
  - assigned driver
  - authorized admins

## 15. Backend Module Breakdown

### 15.1 Auth module

- register user intent
- initiate OTP flow
- verify OTP
- create JWT
- resolve user role and identity

### 15.2 Drivers module

- create and update driver profiles
- store documents metadata
- online / offline status
- current location snapshot
- approval status fetch

### 15.3 Rides module

- create ride
- get ride details
- manage ride transitions
- history retrieval
- cancellation rules

### 15.4 Dispatch module

- find nearby drivers
- sequential offer dispatch
- timeout handling
- rejection tracking
- assignment atomicity

### 15.5 Subscriptions module

- validate active subscription
- create or renew subscriptions
- expire subscriptions
- update driver operational eligibility

### 15.6 Ratings module

- create ratings
- prevent duplicate ratings for the same direction if desired
- recompute aggregated averages

### 15.7 Admin module

- driver review queue
- driver approval / rejection / suspension
- rides listing
- subscription management
- dashboard stats

### 15.8 Notifications module

- send FCM push notifications
- manage tokens
- define message templates by event type

### 15.9 Tracking module

- ingest location updates
- publish active tracking data
- maintain Redis cache and Realtime Database mirror

## 16. Operational State and Data Ownership

### 16.1 Durable state

Stored in Firestore:

- users
- drivers
- rides
- subscriptions
- ratings

### 16.2 Ephemeral state

Stored in Redis:

- online presence snapshot
- nearby driver search data
- pending dispatch windows
- offer timeout state

### 16.3 Streaming state

Stored in Realtime Database:

- active ride tracking
- active driver coordinate stream

This separation keeps each storage technology aligned to its strengths.

## 17. Notifications and Event Triggers

### 17.1 Driver-facing notifications

- new ride offer
- ride cancelled
- subscription expiring soon
- subscription expired
- account approved
- account rejected

### 17.2 Passenger-facing notifications

- driver assigned
- driver arriving
- ride started
- ride completed
- no drivers available
- ride cancelled

### 17.3 Trigger sources

- Backend business logic should be the only source that triggers official event notifications.
- Do not rely on the mobile app alone to initiate critical state notifications.

## 18. Admin Dashboard Functional Scope

The admin dashboard should provide:

- login for administrators
- driver review queue with document inspection
- driver approval / rejection / suspension actions
- ride search and filtering
- subscription list and creation / renewal
- operational stats overview

Recommended dashboard modules:

- Overview
- Drivers
- Rides
- Subscriptions
- Settings later

## 19. Scalability Path

Although the MVP should start as a modular monolith, the architecture supports gradual evolution.

### 19.1 Near-term scaling

- Separate worker process for dispatch and timeout jobs if needed.
- Add more Redis-backed coordination for heavy dispatch volume.
- Add city partitioning for driver geo-indexes.

### 19.2 Later decomposition options

Possible future extracted services:

- Dispatch service
- Notification service
- Subscription / billing service
- Reporting service

This should only happen after real operational load justifies the added complexity.

## 20. Recommended Implementation Priorities

### Phase 1

- Auth
- Passenger registration
- Driver registration
- Driver approval flow
- Subscription management

### Phase 2

- Ride request
- Nearby driver lookup
- Sequential dispatch
- Accept / reject flow

### Phase 3

- Live tracking
- Ride history
- Ratings
- Admin stats

## 21. Final Architectural Decisions

1. **Flutter** is the standard for both mobile apps to maximize reuse and MVP speed.
2. **Node.js + Express** is the central backend for all business logic.
3. **Firestore** is the durable source of truth for core entities.
4. **Realtime Database** is used for live tracking streams.
5. **Redis** is required for fast nearby-driver lookup and dispatch control.
6. **Google Maps API** is the standard provider for maps, geocoding, and distance estimation.
7. **Drivers must have an active subscription** before they can go online or accept rides.
8. **Passengers pay drivers directly** via cash or PIX; no in-app payment settlement is required in the MVP.
9. **Dispatch is sequential** with **30-second** offer windows.
10. **Driver matching uses nearby approved, online, subscribed drivers** within a **3 to 5 km** search radius.

## 22. Implementation Summary

This architecture delivers an MVP that is practical, cost-conscious, and aligned to the subscription-based business model:

- Mobile apps in Flutter for passenger and driver journeys
- A Node.js + Express backend enforcing all business rules
- Firestore for durable operational data
- Realtime Database for live trip tracking
- Redis for fast driver availability and matching
- Google Maps for geolocation and routing
- React + TypeScript admin dashboard for operations

The resulting system is optimized for a local-market launch while preserving a clear path for future growth.