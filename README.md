# Progress Bar

A modern, lightweight, and cost-efficient VPS-deployed progress bar service that automatically calculates and posts the current year progress (e.g. `[▓▓▓▓▓▓▓▓░░░░░░░] 53%`) to Mastodon.

## Architecture

- **Backend:** A compiled native Dart CLI application (`backend/`) that computes the current year progress percentage and posts updates to Mastodon.
- **Frontend:** A static single-page web app (`static_dart_build/`) served inside the container via **Nginx**.
- **Persistence:** A local SQLite database file (stored on a persistent Docker volume) tracking the last posted percentage to prevent duplicate/redundant posts.
- **Automation:** A system cron daemon running inside the container that triggers the Dart CLI hourly.
- **Deployment:** Containerized and deployed to the `lokaj` VPS using **Kamal 2**.

---

## Local Development & Testing

You can run and test the service fully on your local machine using **Docker** / **OrbStack**.

### 1. Run Unit Tests
To verify the progress math and state storage logic, run:
```sh
cd backend
dart test
```

### 2. Build the Local Docker Container
To compile the native Dart CLI and assemble the Nginx + Cron production container locally:
```sh
make build-local
```

### 3. Run and Verify Locally
You can start the local container in the background (which runs the static web server on port `8080`):
```sh
export MASTODON_ACCESS_TOKEN="your_access_token_here"
make run-local
```
Once running:
- Open http://localhost:8080 in your browser to verify the frontend works.
- View container logs: `make logs-local`
- Force a dry-run execution of the toot CLI inside the running container to see what it would post:
  ```sh
  make toot-local
  ```

To stop the running container:
```sh
make stop-local
```

---

## Frontend Build

To rebuild the legacy `frontend/` using old Dart 2.0 SDK:
```sh
./build_to_server.sh
```

---

## Deployment

The main application is deployed using **Kamal 2** to the `lokaj` VPS.

### 1. Configuration
- The main deployment configuration lives in `config/deploy.yml`.
- Registry and API credentials should be placed in `.kamal/secrets` (do not commit this file).

### 2. Deploy
To deploy the latest changes to production:
```sh
make deploy
```

---

## Google App Engine Redirector

The `/gae` folder contains a modern, minimal Google App Engine project using Python 3. Its sole purpose is to redirect all legacy traffic from Google App Engine to the new VPS URL (`https://progress.filiph.net`).

### Deploying the Redirector
To deploy updates to the GAE redirector:
```sh
cd gae
gcloud app deploy
```
