# AGENTS.md

## Expertise & Standards
Approach every task as a senior full-stack engineer (~20 years across Java/Spring and React/TypeScript) would: favor correctness and maintainability over the fastest patch, anticipate edge cases and failure modes before writing code, and match or improve on the existing architecture rather than bolting on a shortcut. Concretely:
- Read the surrounding code and this file before editing — don't pattern-match from a generic example.
- Prefer the smallest correct fix over a broad rewrite; but don't leave known-bad patterns in place just to keep a diff small if the task touches that code anyway.
- Call out tradeoffs, risks, and assumptions in the PR description — a specialist explains *why*, not just *what*.
- If a "quick" approach would violate a convention in this file (API-first workflow, layering, query-key factories, etc.), don't take it — use the Escape Hatch instead.

## Big Picture
- Monorepo with two deployable apps: `ife-gui` (React + Vite + TypeScript) and `ife-service` (Spring Boot + PostgreSQL), plus `helm/` for AKS packaging.
- Main user flow is report ordering/viewing: GUI calls REST endpoints under `/api/*`, service executes business logic + DB access, then GUI renders reports/event logs/filters.
- API contract is source-of-truth in `ife-service/src/main/resources/openapi/api.yaml`; backend controllers implement generated interfaces (for example `EventLogController implements EventLogApi`).

## Where To Change What
- Frontend UI routes/shell: `ife-gui/src/pages/LandingPage.tsx`, `ife-gui/src/router/AppRouter.tsx`.
- Frontend API calls and DTOs: `ife-gui/src/api/services/reportsService.ts` and `ife-gui/src/api/services/*`.
- Frontend cache keys: `ife-gui/src/api/queryKeys.ts` (reuse existing factories; do not invent ad-hoc keys).
- Backend endpoints: controllers in `ife-service/src/main/java/com/euroclear/ife/service/**`.
- Backend DB schema/migrations: `ife-service/src/main/resources/database/ife/sql` + `db-changelog.xml`.

## Critical Conventions (Project-Specific)
- Runtime config is loaded from `public/config/env.json` at startup (`Env.loadAppConfig()` in `ife-gui/src/main.tsx`), not hardcoded at build time.
- API base URL is normalized in `ife-gui/src/api/client.ts`; `API_SERVER_URL` may include or omit `/api`, client appends `/api` if missing.
- Use `@` alias for frontend imports (configured in `ife-gui/vite.config.ts`).
- React Query pattern: hooks call service methods and key via `queryKeys.*`; mutations invalidate broad keys (`reportTypes`, `orderedReports`, etc.).
- Landing navigation is mostly a single shell component with lazy-loaded subviews (`LandingPage`), even though paths differ.
- i18n strings live in typed translation objects (`ife-gui/src/locales/translations*.ts`); keep `en`, `sv`, `fi` in parity (`npm run i18n:check`).

## Backend Patterns To Preserve
- API-first workflow: edit `api.yaml` -> run Maven build to regenerate -> implement logic in controller/service/repo/mapper.
- Never manually edit generated code under `ife-service/target/generated-sources/openapi`.
- Keep controller -> service -> mapper/repository layering; see `eventlog/EventLogController.java`.
- `openApiNullable=false` is intentional in `pom.xml` (plain nullable fields instead of `JsonNullable`).
- Liquibase runs locally at app startup; in AKS it is executed via a Kubernetes job in the common Helm flow (`ife-service/src/main/resources/database/ife/readme.txt`).

## Dev Workflows
- Frontend (`ife-gui`):
  - `npm install`
  - `npm run dev` (Vite HMR)
  - `npm run test` / `npm run lint` / `npm run build`
  - `npm run i18n:check` before translation-heavy PRs
- Backend (`ife-service`):
  - `./mvnw clean test`
  - `./mvnw spring-boot:run`
- Local DB bootstrap (`ife-service`):
  - `docker compose -f docker-compose.yaml up -d db`
  - `docker compose -f docker-compose.yaml exec db bash /workspace/db/load-ife-rep-data.sh`

## Integration & Deployment Notes
- Local backend defaults: `http://localhost:8080` (`ife-service/config/application.yaml`); frontend sample env points to `http://127.0.0.1:8080`.
- Frontend container expects runtime templated config (`ife-gui/container/config/env.json.template`) and serves via nginx startup script.
- Helm chart `helm/Chart.yaml` depends on `common-efi-aks-webapp`; avoid app-specific Kubernetes drift outside chart values/templates.

## Non-Obvious Gotchas
- Root `README.md` stack notes can lag module reality; rely on module manifests (`ife-gui/package.json`, `ife-service/pom.xml`) when versions are in question.
- `ife-gui/src/api/reportApi.ts` is a backward-compatibility barrel; prefer newer service modules for new code.
- Business code options are currently constrained (`BusinessContext` union type); preserve type-safe checks via `isBusinessCode()`.

## Escape Hatch
- If the correct API contract, DB shape, or a convention isn't visible in `api.yaml`, existing code, or this file, **stop and ask or propose a short plan** rather than guessing. A wrong assumption about the OpenAPI contract or Liquibase changelog is expensive to unwind.
- If a task would require deviating from the API-first workflow, the controller -> service -> mapper/repository layering, or the Helm chart structure, flag the deviation explicitly before making it.

## PR Checklist
- [ ] Title follows Conventional Commits (e.g. `feat(reports): add export endpoint`)
- [ ] `api.yaml` updated first if the change touches a contract, and generated sources were regenerated (not hand-edited)
- [ ] Frontend: `npm run lint`, `npm run test`, `npm run build` all green; `npm run i18n:check` if translation strings changed
- [ ] Backend: `./mvnw clean test` green; new/changed DB schema has a Liquibase changelog entry, not a hand edit to an already-applied one
- [ ] No new query keys invented outside `queryKeys.ts` factories
- [ ] Diff is scoped to the task — no unrelated Helm/chart or config drift
- [ ] Description states what changed and why, and calls out any deviation noted under Escape Hatch
