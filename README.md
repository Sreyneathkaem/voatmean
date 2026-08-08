# Voatmean

A high school attendance management system with role-based access for admins and teachers — REST API backend with a Flutter mobile app, built with a security-first and DevOps-ready architecture.

> **Course project** — Joint deliverable for FESE311 (Software Security) and FESE308 (DevOps Engineering), Cambodia University of Technology and Science (CamTech).
> Successor to [EduAttend](https://github.com/Sreyneathkaem/eduattend), rebuilt around period/subject-level attendance for a high school timetable.

---

## Team

| Name | Role |
|---|---|
| Kaem Sreyneath | Backend & System Lead |
| Yung Sreyneang | Frontend & Product Lead |

**Shared goal:** Introduce a ready-to-use application to our former high school and workplace, reducing the complexity of the current attendance system.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Mobile app** | Flutter (teacher + admin) |
| **Backend** | Node.js + Express REST API |
| **Database** | PostgreSQL (primary application data) |
| **Audit Logs** | MongoDB (structured audit trail) |
| **Auth** | Google OAuth (web + Android + iOS clients) + JWT |
| **Containerization** | Docker + Docker Compose |
| **Security Scanning** | SonarQube (SAST), OWASP ZAP (DAST) |
| **CI/CD** | GitHub Actions |

---

## Project Structure

```
voatmean/
├── backend/          # Node/Express API
├── mobile/           # Flutter app (teacher + admin)
├── web/              # Legacy React web app (status: TBD)
├── docs/             # Architecture, ERD, API contract, security reports
└── .github/workflows/
```

---

## Architecture (in progress)

Period/subject-level attendance model — see `docs/schema.md` for the timetable/attendance ERD once added.

```
        +--------------+        +--------------+
        |  Flutter App |        |  Web (legacy)|
        +------+-------+        +------+-------+
               |                       |
               +----------+------------+
                    +------v------+
                    |   Backend   |  Node/Express API
                    +--+---+---+--+
                       |   |   |
            +----------+   |   +----------+
            v              v              v
     +------------+ +------------+ +------------+
     | PostgreSQL | |   Redis    | |  MongoDB   |
     +------------+ +------------+ +------------+
```

---

## Getting Started

### Prerequisites
- Docker Desktop
- Node.js 18+
- Flutter SDK 3.x

### Backend
```bash
cd backend
cp .env.example .env   # fill in DATABASE_URL, JWT_SECRET, GOOGLE_CLIENT_ID(S)
docker compose up -d
npm run migrate
npm run dev
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

Full setup docs: `docs/setup.md` *(to be added)*.

---

## Security

- Role-based access control (admin / admin_teacher / teacher), enforced server-side, default-deny
- All secrets via environment variables, never committed
- Parameterized queries throughout — no raw string SQL
- Structured audit logging for all attendance changes
- SAST (SonarQube) and DAST (OWASP ZAP) scans — reports in `docs/security/`

---

## Roadmap

See `docs/roadmap.md` for the current 8-week milestone plan.

---

## License

_No license has been added yet. All rights reserved by default until a LICENSE file is added._