# Voatmean (វត្តមាន)

Mobile-first attendance and academic scoring system for a secondary/high school. Successor to [EduAttend](../eduattend), moving from a single-subject "course" model to a **Class × Subject × Timetable** model.

> **Status:** Active development / mid-migration. The new timetable-based schema and API are live, but the legacy course-based schema and endpoints from EduAttend are still present in the codebase and mounted alongside them (see [Migration Status](#migration-status)).

## Team

| Name | Role |
|---|---|
| Kaem Sreyneath | Backend & System Lead |
| Yung Sreyneang | Frontend & Product Lead |

## Overview

- Attendance tracked per timetable slot (class + subject + period + date), not per day.
- Single school, classes spanning both secondary and high-school grade levels.
- Teacher-entered monthly subject scores blended with attendance-derived scoring into a final grade.
- Combined `admin_teacher` role for staff who hold both responsibilities.
- Flutter mobile app (teachers) + Flutter admin surface — one shared Dart codebase.
- Khmer (`km`) and English (`en`) localization built in.
- Schema includes a `school_id` on core tables to allow a second school later without a rewrite (full multi-tenancy is out of scope for this phase).

**Out of scope this phase:** multi-tenant infra, offline attendance marking, legacy React web app (deprecated, not migrated).

## Migration Status

The database and API currently carry **two schemas side by side**:

- **Legacy (EduAttend-era)** — `courses`, `course_sessions`, `session_attendance_records`, `attendance_records`, `majors`, `score_rules` (migration `001_schema.sql`), served via `/api/classes`, `/api/students`, `/api/attendance`, and parts of `/api/admin` (teachers, academic years, majors, terms).
- **Current (Voatmean timetable model)** — `schools`, `homeroom_classes`, `class_students`, `subjects`, `timetable_slots`, `slot_attendance_records`, `subject_scores`, `score_formula_config` (migration `002_timetable_schema.sql`), served via `/api/timetable`, `/api/attendance/slots`, `/api/admin/homeroom-classes`, `/api/admin/subjects`, and `/api/scores`.

Both sets of routes are mounted in `server.js` today. New feature work should target the timetable-model tables/endpoints; the legacy course-based ones are expected to be retired once the mobile/admin clients no longer depend on them. `backend/package.json` still carries the name `eduattend-backend`, a holdover from the predecessor project.

> **Known gap:** `routes/scoreFormula.routes.js` (the `/api/admin/score-formula/*` endpoints described below) is fully implemented and tested but is **not currently imported/mounted in `server.js`**. Until it's wired in, per-subject score-formula overrides can only be set directly in the database — see [Known Gaps / Next Steps](#known-gaps--next-steps).

## Architecture

```
Flutter Mobile App (teacher + admin) ──► Node/Express REST API ──► PostgreSQL
                                                (auth, business logic)  ──► Redis
                                                                         ──► MongoDB
                                          Firebase (client init only)
```

- The API is the only thing that touches the databases — no client talks to Postgres, Redis, or MongoDB directly.
- Clients contain no business logic beyond form validation/display. Role checks, score computation, and attendance rules all live server-side.

### Frontend (Flutter — single codebase)

```
lib/main.dart                         # app entry, Firebase init, locale + theme setup
lib/bloc/                             # auth_bloc / auth_event / auth_state (flutter_bloc) — currently unused scaffolding, see Known Gaps
lib/core/                             # constants (colors, typography, strings), api_service, validators, shared widgets
lib/features/auth/                    # login, register, auth_service
lib/features/teacher/                 # teacher dashboard, attendance marking, reports, students, settings
lib/features/admin/                   # admin dashboard, class/teacher assignment, students, settings
```

- **Routing:** plain `MaterialApp`/widget composition — screens are swapped directly rather than via a router package. There is no `go_router` dependency.
- **State management:** a mix of `provider` (used for simpler screen state) and `flutter_bloc`/`bloc` (used for auth flow). Riverpod is not used.
- **Auth on the client:** Google Sign-In (`google_sign_in`) for OAuth, plus a standard email/password login/register form, backed by `dio` + `cookie_jar`/`dio_cookie_manager` for the HttpOnly session cookie.
- **Firebase:** `firebase_core` is initialized on app startup (`firebase_options.dart`); used for client configuration, not as the primary backend.
- **Localization:** `flutter_localizations` with Khmer and English locales configured in `main.dart`.
- **Responsive:** attendance/teacher screens are phone-first; admin screens are usable on wider viewports but there is no dedicated Flutter Web admin build documented/verified in this repo state.

### Backend (Node.js + Express)

```
routes/         # auth, admin, classes, students, attendance (legacy) +
                # homeroomClass, subject, timetable, slotAttendance, scoreFormula (not yet mounted), score (current)
middleware/     # authenticate (session cookie → Redis + JWT verify),
                # authorize (role check), authorizeClass / authorizeSlot (ownership checks)
controllers/    # request handling + validation; delegates to parameterized queries
config/         # db.js (Postgres pool), redis.js (session store), mongo.js (audit log, Mongoose), logger.js (Winston securityLogger)
migrations/     # 001_schema.sql (legacy, includes its own demo seed data),
                # 002_timetable_schema.sql (current model + placeholder classes),
                # 003_score_formula_decision.sql (default formula),
                # seed.sql (additional timetable-model demo data — subjects, homeroom classes,
                #           students, timetable slots — run separately, see Getting Started)
```

Every mutating endpoint (attendance write, score entry, remark) writes to Postgres **and** an `audit_logs` entry in MongoDB.

### Data model (current / timetable schema)

| Entity | Purpose |
|---|---|
| `schools` | Identifies the deploying school (single row today) |
| `academic_years` / `terms` | Time-boxes the school calendar |
| `homeroom_classes` | Fixed homeroom roster (e.g. Grade 10A), independent of subject |
| `class_students` | Roster: which students belong to which homeroom class |
| `subjects` | School-wide subject catalog |
| `timetable_slots` | A specific Class + Subject + Teacher + Day/Period combination |
| `slot_attendance_records` | One row per student, per timetable slot, per date, with status |
| `subject_scores` | Teacher-entered monthly score per student per subject, with its own `max_score` scale (default 100.00) so different subjects can grade on different scales |
| `score_formula_config` | How the final score is computed — see [Score Formula](#score-formula) below |
| `users` | Admin and/or teacher accounts; authenticated via Google OAuth **or** email/password |
| `audit_logs` (MongoDB) | Append-only who/what/when trail, written on every mutating action |

The legacy `courses` / `course_sessions` / `attendance_records` / `majors` / `score_rules` tables from migration `001` still exist in the same database for backward compatibility during the migration.

- **PostgreSQL** — system of record for all relational data.
- **Redis** — session tokens only (`jti` → session data, TTL-based, deleted on logout). If Redis is unreachable, JWTs still validate by signature but logout can no longer revoke server-side.
- **MongoDB** — `audit_logs` collection only; never queried for core application state. If Mongo is unreachable at boot, audit logging is skipped rather than blocking startup.

## Score Formula

The "replace vs. run alongside vs. combine" question from earlier design docs has been resolved in code (`003_score_formula_decision.sql`):

- **Mode:** `weighted_blend` — the final monthly score blends the attendance-derived score with the teacher-entered subject score (the other two supported modes, `attendance_only` and `teacher_score_only`, remain available per subject).
- **Default weighting:** 70% teacher-entered subject score / 30% attendance-derived score, system-wide.
- **Configurable per subject:** each subject can override the default via `PUT /api/admin/score-formula/:subjectId` — **implemented but not yet reachable via the API** until `scoreFormula.routes.js` is mounted in `server.js` (see the callout in [Migration Status](#migration-status)).
- **Score scale:** each `subject_scores` row carries its own `max_score` (defaults to 100.00), so a teacher's raw score is normalized (`teacher_score / max_score`) before blending — the app does not assume a fixed denominator.

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile client | Flutter (Dart) |
| Client auth | Google Sign-In + email/password |
| HTTP client | `dio` + `cookie_jar` / `dio_cookie_manager` |
| State management | `provider` + `flutter_bloc` / `bloc` |
| Client platform config | Firebase (`firebase_core`) |
| Localization | Khmer (`km`) + English (`en`) |
| Backend runtime | Node.js + Express |
| Primary database | PostgreSQL |
| Session store | Redis |
| Audit log store | MongoDB (via Mongoose) |
| Auth provider | Google OAuth 2.0 (`google-auth-library`) + local password (`bcryptjs`) |
| Session tokens | JWT (`jsonwebtoken`), HttpOnly cookie, `jti` tracked in Redis |
| Security logging | Winston (`securityLogger`) |
| Containerization | Docker + Docker Compose |
| Testing | Jest + Supertest (backend) |
| CI/CD | GitHub Actions (scaffolded) |

## User Roles

- **Admin** — manages classes, subjects, timetable, teacher assignments; reviews/overrides attendance and scores; configures the score formula; views school-wide dashboards.
- **Teacher** — marks attendance and enters subject scores only for timetable slots they are assigned to (`authorizeSlot` enforces this server-side).
- **Admin_Teacher** — a single account holding both capabilities.

## Getting Started

### Prerequisites

- Node.js (LTS)
- Flutter SDK (Android/iOS/Web targets enabled)
- Docker + Docker Compose
- A Google OAuth 2.0 client ID/secret
- A Firebase project (for `firebase_options.dart`)

> **Fastest path:** `mobile/android/app/google-services.json` and `mobile/lib/firebase_options.dart` are already committed with a working project's config, and `backend/.env.example` ships with `GOOGLE_CLIENT_ID` left blank. To reuse the existing setup instead of creating your own Google Cloud OAuth client and Firebase project, open `google-services.json`, copy the `oauth_client` entry's `client_id` value, and paste it into `backend/.env` as `GOOGLE_CLIENT_ID` (leave `GOOGLE_CLIENT_SECRET` blank if you're only testing Google Sign-In from the mobile app — it's only required for server-initiated OAuth flows). If you use a *different* OAuth client than the one baked into `google-services.json`, the backend will reject every Google Sign-In token with an audience mismatch, since it checks `idToken.aud` against `GOOGLE_CLIENT_ID`.

### Backend

```bash
cd backend
cp .env.example .env        # set GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, JWT_SECRET,
                             # DATABASE_URL, REDIS_URL, MONGO_URL
docker compose up -d        # postgres (localhost:5433), redis, mongo, backend
npm install
npm run migrate             # runs 001, 002, 003 in order — includes legacy demo data
                             # (users, courses, majors) from 001, but NOT the current
                             # timetable-model demo data (subjects, homeroom classes,
                             # students, timetable slots)
npm run seed                # populates the current/timetable model with demo data
                             # (schools, subjects, homeroom classes, students, timetable
                             # slots) — skip this only if you're seeding your own data
npm run dev
```

Health check: `GET http://localhost:5000/health`

### First login

There's no self-registration — `POST /api/auth/register` only lets you set a password for an email that's **already** a row in the `users` table (an admin has to add new emails there first). To get your first login without owning one of the seeded team members' real Google accounts:

1. Run `npm run migrate` (above) — this seeds `admin@voatmean.edu.kh` as an admin account with no password set yet.
2. `POST /api/auth/register` with `{ "email": "admin@voatmean.edu.kh", "password": "<pick anything>" }` — this activates the account.
3. `POST /api/auth/login` with that same email/password to get a session cookie.

From there, use the admin console to add your own email to `users` (via Google account or another password) if you want to test the Google Sign-In flow as yourself.

### Flutter (mobile)

```bash
cd mobile
flutter pub get
flutter run                 # mobile (device/emulator)
```

> Development environment is Windows + PowerShell for Flutter/Android work — WSL is avoided due to prior filesystem and emulator issues.

### Running tests

```bash
cd backend
npm test                    # Jest + Supertest, with coverage
```

## Security

- Two supported login paths: Google OAuth (no password stored) and email/password (`bcryptjs` hash) for whitelisted accounts — an admin must add the email to `users` before either login path works. `POST /api/auth/register` checks that the email exists in `users` but does not itself verify ownership of that email (no verification link/code) — treat any email already in your seed data as effectively self-activatable, and don't seed real third-party emails into a shared/public deployment.
- Sessions are signed JWTs in an HttpOnly cookie, cross-checked against a Redis-backed session store on every request — deleting the Redis entry (logout) invalidates the token immediately, even though the JWT signature itself would still verify.
- All SQL access uses parameterized queries — no string-concatenated SQL.
- Client-facing error responses are generic; full error detail is logged server-side only.
- Every authentication/authorization decision is logged to a structured security log (Winston `securityLogger`).
- Rate limiting: stricter limit on `/api/auth/google` (30 req / 15 min), general limit on `/api` (500 req / 15 min).
- `helmet` and scoped `cors` (credentialed, single allowed origin) are applied globally.
- SonarQube (SAST) and OWASP ZAP (DAST) are referenced as part of the security process; wiring into this repo's CI was not verified as part of this review.

## Reliability & Availability

- Attendance and score writes are expected to run inside database transactions — verify per-controller before relying on this for new endpoints.
- Redis (sessions) and MongoDB (audit log) failures degrade gracefully — the server logs a warning and continues rather than failing to start or blocking requests.
- Schema migrations are incremental and numbered (`001`, `002`, `003`); no destructive drop/reseed once real data exists.

## Known Gaps / Next Steps

- Mount `scoreFormula.routes.js` in `server.js` (e.g. `app.use('/api/admin/score-formula', scoreFormulaRoutes)`) so the per-subject score-formula overrides documented above are actually reachable.
- Retire or explicitly deprecate the legacy course-based tables, controllers, and routes (`courses`, `course_sessions`, `attendance_records`, `majors`, `score_rules`, and their `/api/classes` `/api/students` `/api/attendance` `/api/admin` endpoints) once clients fully move to the timetable model.
- Rename `backend/package.json`'s `name` field away from `eduattend-backend`.
- Decide whether a router package (e.g. `go_router`) and a single state-management approach (currently split between `provider` and `flutter_bloc`) are worth consolidating on.
- Remove or wire up `mobile/lib/bloc/auth_bloc.dart` — it's still the unused, unmodified `flutter create`-style boilerplate (auth is actually handled by `auth_service.dart` + `ApiService`).
- Confirm whether a Flutter Web admin build is still in scope — the current `mobile/` app is structured as a single mobile client with an in-app admin role, not a separate web target.
