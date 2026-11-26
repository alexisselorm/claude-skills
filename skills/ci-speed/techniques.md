# CI/CD speed techniques, by what the project uses

Use only the sections whose signal you found in the repo. Each entry says what to check
first, what it saves, and what it costs or weakens. Every one is a hypothesis until a
measured run confirms it. Re-check any source a decision rests on: docs change.

## Anywhere (GitHub Actions)

| Technique | Check first | Saves | Costs / weakens |
|---|---|---|---|
| Overlap independent waits | Two steps in one job where neither reads the other's output (installs vs image build, downloads vs installs) | The shorter of the two | Contention on 2 vCPU runners: measure both steps before and after. A backgrounded step must fail the job with its own exit code. |
| Path filters | Commits that touch only docs or one half of a monorepo still run everything | Whole runs | A required check whose workflow is skipped stays Pending and blocks merges. Filter at job level and gate on one aggregate job. Source: https://github.com/github/docs/blob/main/content/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks.md |
| Concurrency groups | Superseded PR pushes still running | Runner minutes, queue | Never `cancel-in-progress` on deploying refs: a half-done deploy is worse than a wait |
| Dependency cache (`setup-*` `cache:`) | Install step time in the timings; whether the cache key is the lockfile | Download time only; installs still run | A cache written by a PR is visible only to that PR. 10 GB per repo, kept 7 days, least recently used evicted first. Source: https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching |
| Do work once | The same install, codegen or build in two jobs, or a build on the host and again in Docker | That step's time | Merging jobs serialises what ran in parallel. Check the critical path, not the total. |
| Test what ships | Tests run on a host build while a separate image build ships | A whole build, and the guarantee gets stronger | Build the artifact once, test it, then promote that exact artifact |
| Bigger or third-party runners | Only when CPU-bound steps dominate the critical path and queue time is near zero | Varies | Costs money; GitHub Free can't use larger runners. A third-party runner would hold the job's secrets. Vendors' benchmarks are their own claims. |

Traps:
- Steps from `run:` don't get `ACTIONS_RUNTIME_TOKEN` or `ACTIONS_RESULTS_URL`. If a shell step needs them (for example `docker buildx` with `type=gha`), start the command from `actions/github-script`, whose `process.env` has them, and pass them only to that child process. Exporting them to `$GITHUB_ENV` hands them to every later step, npm/pip install scripts included.
- Background work in one step, awaited in a later one: write the exit code to a file when the work ends, and have the wait loop check that the file is non-empty (`-s`) rather than that it exists (`-f`), or it can read an empty file and pass.
- A step that "got slower" after an unrelated change usually lost a race for disk or network. Read the timings of the steps around it.

## Docker images (Dockerfile, buildx, bake, compose)

| Technique | Check first | Saves | Costs / weakens |
|---|---|---|---|
| gha or registry layer cache | Image build time in the timings; whether `cache-from`/`cache-to` exist and use one scope per image | Rebuild of unchanged layers | Write the cache from default-branch pushes only. `type=registry,mode=max` stays outside the 10 GB quota. Since 2025-04-15 only cache API v2 works. Source: https://docs.docker.com/build/ci/github-actions/cache/ |
| Build once, promote by manifest copy | Images rebuilt after the tests, or once per environment | A full build | `docker buildx imagetools create` copies the manifest; wrapping a single-platform image this way changes its digest. Source: https://docs.docker.com/reference/cli/docker/buildx/imagetools/create/ |
| Build in parallel (bake) | Several images built one after another | The serial sum minus the longest | Shared stages build once only in the same bake |
| containerd image store | Time spent exporting an image as a tarball and importing it into Docker (`load: true` with the docker-container driver) | The tarball export and import, and the builder boot | Needs a dockerd restart on the runner; the default `docker` driver supports the gha cache only with that store. Spike it. Source: https://docs.docker.com/build/cache/backends/ |
| Skip loading what isn't used | `load: true` for images no later step runs | Their import time | |
| Smaller runtime layers | Image size (`docker history`), registry pull time in the deploy log | Pull time on every deploy | Measure first: BuildKit keys `COPY --from` on content, so a dependency layer copied from a build stage often already survives code changes. Rebuild with a one-line source change and compare `docker inspect -f '{{.RootFS.Layers}}'` before splitting stages. |
| Fast health probes while starting | `compose up --wait` or a deploy waiting a full probe interval | Up to one interval per service | `start_interval` / `--start-interval` needs Engine 25+ wherever the container runs. Check the deploy target's engine. A compose `healthcheck:` replaces the image's, so the image's start interval does nothing there. Source: https://docs.docker.com/reference/dockerfile/ |
| Prefetch images a later step needs | Pulls inside the test script | Pull time | Started too early, they compete with installs; started too late, the test script pulls them anyway. Start them when the step they would compete with ends. |

Traps:
- `load: true` together with an attestation needs `provenance: false`, because an attestation index can't be loaded into the classic store.
- A Dockerfile change invalidates every layer after it in the CI cache, so the deploy target downloads those layers again. Judge a speed change on a run that changes only source code.

## Language toolchains

| Signal | Check | Notes |
|---|---|---|
| Node (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`) | `npm ci` / install time; codegen repeated in several jobs | The `setup-node` cache saves only the download. An image build never reads host `node_modules` when `.dockerignore` excludes it, so the build can overlap host installs. |
| Python (`uv.lock`, `poetry.lock`, `requirements*.txt`) | Install time; whether wheels are built from source | `uv` with its cache is usually far faster than pip; pin the interpreter |
| Go (`go.mod`) | Module download vs build time | `setup-go` caches both; separate the two in the timings |
| JVM (`gradle`, `pom.xml`) | Daemon and dependency resolution time | Gradle's build cache and configuration cache; `setup-java` caches only dependencies |
| Rust (`Cargo.lock`) | Compile time | Cache `target/` keyed on the lockfile; incremental builds are usually off in CI |

## Browser and e2e tests (Playwright, Cypress)

| Technique | Check first | Notes |
|---|---|---|
| Run in the vendor's image | Browser install time vs image pull time | The image ships the browser and its system libraries. It costs a pull on a fresh runner, so prefetch it. |
| Browser cache | | Playwright advises against caching browsers: restoring takes about as long as downloading. Source: https://playwright.dev/docs/ci |
| Workers / sharding | Single-use fixtures shared across tests; suite time vs per-job setup time | Playwright recommends 1 worker in CI and sharding across jobs to scale. Each shard repeats the job's setup. More workers need one fixture per worker (Playwright sets `TEST_PARALLEL_INDEX` 0..workers-1). Adopt only after many green runs in a row. Source: https://playwright.dev/docs/test-sharding |

## Deploy step

| Technique | Check first | Notes |
|---|---|---|
| Skip no-op migrations | Deploy log shows the migrate step reporting nothing pending | Record what ran (image id and command) after a migration **succeeds**, and skip on an exact match. Comparing image ids before and after the pull is wrong: a failed migration's image is already pulled, so the next deploy would skip it. If the id can't be read, run the migration. |
| Cleanup off the clock | Image prune or log rotation before the deploy reports done | Run it detached after the done message, with any lock descriptor closed so it can't block the next deploy |
| Recreate only what changed | Every container restarts on each deploy | Compose recreates only containers whose image or config changed. Changing a database's config recreates it. |
| Registry pull time | The deploy log's pull lines | Usually one large layer that changed; see "Smaller runtime layers" |
