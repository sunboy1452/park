# Remote MySQL Configuration and Bootstrap Plan

> **For agentic workers:** Use superpowers:executing-plans to carry out this plan task-by-task.

**Goal:** Configure the Spring Boot backend to use the user's remote MySQL server without storing credentials in source, then initialize marketing tables only after confirming the target schema state.

**Architecture:** Add an opt-in `remote-db` Spring profile that overrides the datasource while retaining the `dev` profile for the existing supporting services. Use environment variables for all credentials. Inspect and back up the target before applying either the destructive base bootstrap or the additive marketing extension.

**Tech Stack:** Java 17, Spring Boot 4, Spring profiles, MySQL 8, PowerShell.

**Spec:** `../../../../数智招商与园区运营平台_实施规划.md`; current scope is Web admin and Spring Boot only, with UniApp/App deferred.

## Global Constraints

- Do not store the provided database password in source, logs, or documentation.
- Keep the existing `dev` profile active with `remote-db` so other development settings remain available.
- Never run the full bootstrap against a database with existing data; it contains `DROP TABLE` statements.
- Do not apply marketing SQL until base schema and menu IDs have been inspected and backed up.
- Restrict MySQL network access to trusted source IPs or use an SSH tunnel.

---

### Task 1: Add an opt-in remote datasource profile

**Files:**
- Create: `src/main/resources/application-remote-db.yml`
- Create: `docs/remote-database.md`

**Interfaces:**
- Consumes: `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_DATABASE`, `MYSQL_USERNAME`, `MYSQL_PASSWORD` environment variables.
- Produces: Spring profile `remote-db`, activated with `dev,remote-db`.

- [x] Define the MySQL URL and credentials using environment placeholders.
- [x] Document activation commands and safe schema setup order.
- [x] Compile the backend with the new profile resource.

### Task 2: Inspect remote database before changes

**Files:**
- Read: `sql/youlai_admin_tenant.sql`
- Read: `sql/extensions/marketing.sql`

- [ ] Confirm MySQL connectivity or establish an authorized SSH tunnel.
- [ ] List schemas and tables without changing them.
- [ ] Back up the target schema and determine whether it is empty or contains existing data.
- [ ] Confirm whether the marketing menu IDs and grants conflict with existing customizations.

### Task 3: Initialize and verify

**Files:**
- Execute only after Task 2: `sql/youlai_admin_tenant.sql` when the database is confirmed empty.
- Execute only after the base schema exists: `sql/extensions/marketing.sql`.

- [ ] Use a database administrator to initialize schema only after confirming the target is safe.
- [ ] Create or use a restricted application database account.
- [ ] Start Spring Boot with `dev,remote-db` and environment variables.
- [ ] Verify backend health and the anonymous public-space API.
- [ ] Sign in to the admin and verify marketing menu routes and CRUD flows.

## Current Status

Task 1 is complete and `mvn -DskipTests compile` passes. Task 2 is blocked: TCP 3306 to `101.34.52.78` is unreachable, and SSH accepts no authorized key for the attempted account. No remote database or SQL was accessed. Continue after an allowlisted MySQL route or an authorized SSH tunnel is available.
