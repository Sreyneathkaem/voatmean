# Voatmean

Mobile-first attendance and academic scoring system for a secondary/high school. Successor to [EduAttend](../eduattend), moving from a single-subject "course" model to a realistic **Class × Subject × Timetable** model.

> **Status:** Draft — two open decisions pending (see [Open Decisions](#open-decisions)).

## Team

| Name | Role |
|---|---|
| Kaem Sreyneath | Backend & System Lead |
| Yung Sreyneang | Frontend & Product Lead |

## Overview

- Attendance tracked per timetable slot (class + subject + period + date), not per day.
- Single school, classes spanning both secondary and high-school grade levels.
- Teacher-entered monthly subject scores alongside attendance-derived scoring.
- Combined `admin_teacher` role for staff who hold both responsibilities.
- Flutter mobile app (teachers) + Flutter Web admin console — one shared Dart codebase.
- Schema includes a `school_id` on core tables to allow a second school later without a rewrite (full multi-tenancy is out of scope for this phase).

**Out of scope this phase:** multi-tenant infra, offline attendance marking, legacy React web app (deprecated, not migrated).

## Architecture

```
Flutter Mobile App ─┐
                     ├──► Node/Express REST API ──► PostgreSQL
Flutter Web (Admin) ─┘     (auth, business logic)  ──► Redis
                                                     ──► MongoDB
```

- The API is the only thing that touches the databases — no client talks to Postgres, Redis, or MongoDB directly.
- Clients contain no business logic beyond form validation/display. Role checks, score computation, and attendance rules all live server-side.

### Frontend (Flutter — mobile + web, single codebase)

```
lib/core          # API client (dio), auth/session handling, shared models — no platform-specific imports
lib/features/attendance   # timetable view, per-slot attendance marking
lib/features/scores       # monthly subject-score entry (teacher) + score review (admin)
lib/features/admin        # class/subject/timetable management, dashboards (web-first, tablet-usable)
```

- Routing: `go_router` with role-based guards (mirrors the legacy React `Guard` pattern).
- State management: Riverpod or Provider (Riverpod preferred if starting fresh).
- Responsive: attendance screens optimized for phone; admin dashboards optimized for wider viewports.

### Backend (Node.js + Express)

```
routes/         # one router per resource: auth, classes, subjects, timetable, attendance, scores, admin
middleware/     # authenticate (session cookie → Redis), authorize (role check),
                # authorizeSlot (confirms a teacher owns the timetable slot being written to)
controllers/    # request handling + validation; delegates to parameterized queries
config/         # db.js (Postgres pool), redis.js (session store), mongo.js (audit log), logger.js (Winston securityLogger)
```

Every mutating endpoint (attendance write, score entry, remark) writes to Postgres **and** an `audit_logs` entry in MongoDB.

### Data model

| Entity | Purpose |
|---|---|
| `schools` | Identifies the deploying school (single row today) |
| `academic_years` / `terms` | Time-boxes the school calendar |
| `classes` | Fixed homeroom roster (e.g. Grade 10A), independent of subject |
| `subjects` | School-wide subject catalog |
| `timetable_slots` | A specific Class + Subject + Teacher + Day/Period combination |
| `attendance_records` | One row per student, per timetable slot, per date, with status |
| `subject_scores` | Teacher-entered monthly score per student per subject |
| `users` | Admin and/or teacher accounts, authenticated via Google OAuth |
| `audit_logs` (MongoDB) | Append-only who/what/when trail, written on every mutating action |

- **PostgreSQL** — system of record for all relational data.
- **Redis** — session tokens only (`jti` → session data, TTL-based, deleted on logout).
- **MongoDB** — `audit_logs` collection only; never queried for core application state.

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile client | Flutter (Dart) |
| Web admin console | Flutter Web (same codebase as mobile) |
| HTTP client | `dio` + `cookie_jar` / `dio_cookie_manager` |
| State management | Riverpod or Provider |
| Navigation | `go_router` |
| Backend runtime | Node.js + Express |
| Primary database | PostgreSQL |
| Session store | Redis |
| Audit log store | MongoDB |
| Auth provider | Google OAuth 2.0 |
| Security logging | Winston (`securityLogger`) |
| Containerization | Docker + Docker Compose |
| Security scanning | SonarQube (SAST) + OWASP ZAP (DAST) |
| CI/CD | GitHub Actions |

## User Roles

- **Admin** — manages classes, subjects, timetable, teacher assignments; reviews/overrides attendance and scores; views school-wide dashboards.
- **Teacher** — marks attendance and enters subject scores only for timetable slots they are assigned to.
- **Admin_Teacher** — a single account holding both capabilities.

## Getting Started

### Prerequisites

- Node.js (LTS)
- Flutter SDK (Android/iOS/Web targets enabled)
- Docker + Docker Compose
- A Google OAuth 2.0 client ID/secret

### Backend

```bash
cd backend
cp .env.example .env        # set GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, DATABASE_URL, REDIS_URL, MONGO_URL
docker compose up -d        # postgres, redis, mongo, backend
npm install
npm run migrate             # run incremental Postgres migrations
npm run dev
```

### Flutter (mobile + web)

```bash
cd app
flutter pub get
flutter run                 # mobile (device/emulator)
flutter run -d chrome       # web admin console
```

> Development environment is Windows + PowerShell for Flutter/Android work — WSL is avoided due to prior filesystem and emulator issues.

## Security

- No local password storage — auth is fully delegated to Google OAuth.
- Sessions are HttpOnly-cookie based, backed by Redis, and individually revocable (logout invalidates instantly, server-side).
- All SQL access uses parameterized queries — no string-concatenated SQL.
- Client-facing error responses are generic; full error detail is logged server-side only.
- Every authentication/authorization decision is logged to a structured security log (Winston `securityLogger`).
- SonarQube (SAST) and OWASP ZAP (DAST) run against the backend prior to each milestone, and in CI on every pull request.

## Reliability & Availability

- Attendance and score writes run inside database transactions — partial-batch failures roll back completely.
- Redis (sessions) and MongoDB (audit log) failures degrade gracefully — the core attendance/scoring flow stays up if either is temporarily unreachable.
- Schema migrations are incremental and numbered; no destructive drop/reseed once real data exists.

## Open Decisions

Must be resolved before FR-11 (final score computation) is marked final:

1. Does the teacher-entered subject score (FR-10) **replace** the attendance-derived score, run **alongside** it, or **combine** into a single weighted final score?
2. If combined, what weighting applies (e.g. 70% subject score / 30% attendance) — and is it configurable per subject or fixed system-wide?

## Carried Forward from EduAttend

The following are unchanged from the predecessor system and are not re-specified as new requirements:

- Google OAuth flow and HttpOnly session-cookie pattern
- Redis-backed session store with instant server-side logout revocation
- Structured security logging on every authn/authz decision
- Generic client-facing error handling, full detail logged server-side only
- MongoDB audit-log pattern for attendance and score changes
- Docker Compose service topology and GitHub Actions CI scaffolding
