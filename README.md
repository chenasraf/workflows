# Reusable GitHub Workflows

A collection of reusable GitHub Actions workflows.

## Table of Contents

- [Workflows](#workflows)
  - [Go Release](#go-release-go-releaseyml)
  - [Homebrew Release](#homebrew-release-homebrew-releaseyml)
  - [Manual Homebrew Release](#manual-homebrew-release-manual-homebrew-releaseyml)
  - [Release Please + F-Droid Changelog](#release-please--f-droid-changelog-release-please-fdroid-changelogyml)
  - [Release Notes Check](#release-notes-check-release-notes-checkyml)
- [Nextcloud Workflows](#nextcloud-workflows)
  - [PHPUnit MySQL](#phpunit-mysql-nextcloud-phpunit-mysqlyml)
  - [PHPUnit PostgreSQL](#phpunit-postgresql-nextcloud-phpunit-pgsqlyml)
  - [PHPUnit Incremental Migration](#phpunit-incremental-migration-nextcloud-phpunit-incrementalyml)
  - [Psalm Static Analysis](#psalm-static-analysis-nextcloud-psalmyml)
  - [PHP Lint](#php-lint-nextcloud-lint-phpyml)
  - [PHP-CS-Fixer](#php-cs-fixer-nextcloud-lint-php-csyml)
  - [ESLint](#eslint-nextcloud-lint-eslintyml)
  - [OpenAPI Lint](#openapi-lint-nextcloud-lint-openapiyml)
  - [AppInfo XML Lint](#appinfo-xml-lint-nextcloud-lint-appinfo-xmlyml)
  - [NPM Build](#npm-build-nextcloud-build-npmyml)
  - [Vitest](#vitest-nextcloud-vitestyml)
  - [Block Unconventional Commits](#block-unconventional-commits-nextcloud-block-unconventional-commitsyml)
- [License](#license)

## Workflows

### Go Release (`go-release.yml`)

A complete CI/CD workflow for Go projects that handles testing, cross-platform builds and releases.
For Homebrew tap updates, pair it with [Homebrew Release](#homebrew-release-homebrew-releaseyml)
using this workflow's outputs.

#### Features

- Runs tests with configurable test command
- Cross-platform builds (Linux, macOS, Windows)
- Automated releases via [release-please](https://github.com/googleapis/release-please)
- Exposes `release_created` and `tag_name` for follow-up jobs

#### Usage

```yaml
name: Release

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  release:
    uses: chenasraf/workflows/.github/workflows/go-release.yml@master
    with:
      name: my-cli
      platforms: '["linux/amd64", "darwin/arm64"]'
      main-branch: main

  homebrew:
    needs: release
    if: ${{ needs.release.outputs.release_created }}
    uses: chenasraf/workflows/.github/workflows/homebrew-release.yml@master
    with:
      homebrew-tap-repo: myorg/homebrew-tap
      tag: ${{ needs.release.outputs.tag_name }}
    secrets:
      REPO_DISPATCH_PAT: ${{ secrets.REPO_DISPATCH_PAT }}
```

#### Inputs

| Input               | Description                                          | Required | Default                                                            |
| ------------------- | ---------------------------------------------------- | -------- | ------------------------------------------------------------------ |
| `name`              | Binary/project name                                  | Yes      | -                                                                  |
| `go-version`        | Go version for the test job                          | No       | the `go` directive in `<working-directory>/go.mod`                 |
| `platforms`         | JSON array of platforms to build                     | No       | `["linux/amd64", "darwin/amd64", "darwin/arm64", "windows/amd64"]` |
| `package`           | Go package path (empty for root)                     | No       | `""`                                                               |
| `working-directory` | Directory containing the Go module                   | No       | `.`                                                                |
| `release-type`      | Release Please release type (`simple`, `node`, etc.) | No       | `simple`                                                           |
| `compress`          | Compress build artifacts                             | No       | `true`                                                             |
| `test-command`      | Test command to run                                  | No       | `go test -v ./...`                                                 |
| `skip-tests`        | Skip running tests                                   | No       | `false`                                                            |
| `main-branch`       | Main branch name for releases                        | No       | `master`                                                           |

#### Outputs

| Output            | Description                   |
| ----------------- | ----------------------------- |
| `release_created` | Whether a release was created |
| `tag_name`        | The release tag name          |

---

### Homebrew Release (`homebrew-release.yml`)

Sends a repository dispatch to a Homebrew tap with a release's tag and notes, for a tap that listens
for `trigger-from-release` events with payload `{ tag, repo, body }`. It has no build steps, so it
follows a release job (see [Go Release](#go-release-go-releaseyml)) or suits shell-only packages.

#### Usage

```yaml
jobs:
  homebrew:
    needs: release
    if: ${{ needs.release.outputs.release_created }}
    uses: chenasraf/workflows/.github/workflows/homebrew-release.yml@master
    with:
      homebrew-tap-repo: myorg/homebrew-tap
      tag: ${{ needs.release.outputs.tag_name }}
    secrets:
      REPO_DISPATCH_PAT: ${{ secrets.REPO_DISPATCH_PAT }}
```

#### Inputs

| Input               | Description                                                 | Required | Default         |
| ------------------- | ----------------------------------------------------------- | -------- | --------------- |
| `homebrew-tap-repo` | Homebrew tap repo to dispatch to (e.g., owner/homebrew-tap) | Yes      | -               |
| `tag`               | Release tag to dispatch                                     | No       | Latest release  |

#### Secrets

| Secret              | Description                              | Required |
| ------------------- | ---------------------------------------- | -------- |
| `REPO_DISPATCH_PAT` | PAT for dispatching to homebrew tap repo | Yes      |

---

### Manual Homebrew Release (`manual-homebrew-release.yml`)

Manually triggers a Homebrew tap update for the latest release. Useful when you need to re-trigger a Homebrew formula update without creating a new release.

#### Features

- Fetches the latest release tag and body from the repository
- Sends a repository dispatch event to your Homebrew tap repo
- Works with any Homebrew tap that listens for `trigger-from-release` events with payload: `{ tag, repo, body }`

#### Usage

```yaml
name: Manual Homebrew Release

on:
  workflow_dispatch:

jobs:
  homebrew:
    uses: chenasraf/workflows/.github/workflows/manual-homebrew-release.yml@master
    with:
      homebrew-tap-repo: myorg/homebrew-tap
    secrets:
      REPO_DISPATCH_PAT: ${{ secrets.REPO_DISPATCH_PAT }}
```

#### Inputs

| Input               | Description                                      | Required | Default |
| ------------------- | ------------------------------------------------ | -------- | ------- |
| `homebrew-tap-repo` | Homebrew tap repo to dispatch to (e.g., owner/homebrew-tap) | Yes      | -       |

#### Secrets

| Secret              | Description                              | Required |
| ------------------- | ---------------------------------------- | -------- |
| `REPO_DISPATCH_PAT` | PAT for dispatching to homebrew tap repo | Yes      |

---

### Release Please + F-Droid Changelog (`release-please-fdroid-changelog.yml`)

Runs [release-please](https://github.com/googleapis/release-please), then when a release PR is
created or updated, copies the curated notes for the PR's version (`release-notes/<version>/play.txt`
by default) to `<changelog-dir>/<versionCode>.txt`, where F-Droid reads them from the tagged source.
The file is amended into release-please's commit, so the tag carries it. When the notes don't exist
yet, nothing is copied; pair it with [Release Notes Check](#release-notes-check-release-notes-checkyml)
to keep the release PR from merging without them.

#### Usage

```yaml
jobs:
  release-please:
    uses: chenasraf/workflows/.github/workflows/release-please-fdroid-changelog.yml@fastlane-latest
    with:
      release-type: dart
    secrets:
      token: ${{ secrets.RELEASE_PLEASE_TOKEN }}

  build:
    needs: release-please
    if: ${{ needs.release-please.outputs.release_created }}
    # ...
```

#### Inputs

| Input           | Description                                                        | Required | Default                                      |
| --------------- | ------------------------------------------------------------------ | -------- | -------------------------------------------- |
| `release-type`  | Release Please release type (`dart`, `node`, `python`, `go`, etc.) | Yes      | -                                            |
| `version-file`  | pubspec-style file holding `version: <name>+<code>`                | No       | `pubspec.yaml`                               |
| `notes-file`    | Notes to copy; `{version}` is replaced with the version name       | No       | `release-notes/{version}/play.txt`           |
| `changelog-dir` | Directory F-Droid reads changelogs from                            | No       | `fastlane/metadata/android/en-US/changelogs` |

#### Secrets

| Secret  | Description                                                  | Required |
| ------- | ------------------------------------------------------------ | -------- |
| `token` | GitHub token for release-please (defaults to `GITHUB_TOKEN`) | No       |

#### Outputs

| Output            | Description                   |
| ----------------- | ----------------------------- |
| `release_created` | Whether a release was created |
| `tag_name`        | The release tag name          |
| `version`         | The release version           |

---

### Release Notes Check (`release-notes-check.yml`)

Checks that `release-notes/<version>/` holds complete curated notes: `full.md` plus one file per
destination in `release-notes/config.yml`, each non-empty, within its character limit, and without
leftover template text (`<!-- … -->`).

- `mode: pr` checks the release-please PR and passes on every other PR, so it can be a required
  status check.
- `mode: release` runs on pushes to the default branch. When the version file's version has no tag
  yet, the push is the release and the notes must be complete; make tagging and publishing jobs
  depend on it so a release PR merged past the check doesn't ship.

#### Usage

```yaml
jobs:
  release-notes:
    uses: chenasraf/workflows/.github/workflows/release-notes-check.yml@release-notes-latest
    with:
      mode: ${{ github.event_name == 'pull_request' && 'pr' || 'release' }}
```

`release-notes/config.yml`:

```yaml
version:
  file: pubspec.yaml
  pattern: '^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)' # ERE, version in group 1
tag-prefix: v
destinations:
  play: { file: play.txt, limit: 500 }
  ios: { file: ios.txt, limit: 4000 }
  appstore: { file: appstore.md } # no limit: presence and template text only
```

#### Inputs

| Input                   | Description                                  | Required | Default                    |
| ----------------------- | -------------------------------------------- | -------- | -------------------------- |
| `mode`                  | `pr` or `release`                            | Yes      | -                          |
| `config`                | Path to the release notes config             | No       | `release-notes/config.yml` |
| `release-branch-prefix` | Head branch prefix that marks the release PR | No       | `release-please--`         |

---

## Nextcloud Workflows

Reusable workflows for Nextcloud app development. These workflows include automatic path filtering to skip unnecessary runs when irrelevant files change.

### PHPUnit MySQL (`nextcloud-phpunit-mysql.yml`)

Runs PHPUnit tests with MySQL database.

```yaml
jobs:
  phpunit:
    uses: chenasraf/workflows/.github/workflows/nextcloud-phpunit-mysql.yml@nextcloud-latest
    with:
      php-versions-min: '8.1'
      php-versions-max: '8.4'
      mysql-version: '8.0'
      path-filters: |
        - 'lib/**'
        - 'tests/**'
        - 'composer.json'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `php-versions-min` | Minimum PHP version | No | `8.2` |
| `php-versions-max` | Maximum PHP version | No | `8.3` |
| `mysql-version` | MySQL version | No | `8.4` |
| `php-extensions` | PHP extensions to install | No | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | No | _(lib, tests, etc.)_ |

### PHPUnit PostgreSQL (`nextcloud-phpunit-pgsql.yml`)

Runs PHPUnit tests with PostgreSQL database.

```yaml
jobs:
  phpunit:
    uses: chenasraf/workflows/.github/workflows/nextcloud-phpunit-pgsql.yml@nextcloud-latest
    with:
      php-version: '8.2'
      path-filters: |
        - 'lib/**'
        - 'tests/**'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `php-version` | PHP version | No | `8.3` |
| `php-extensions` | PHP extensions to install | No | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | No | _(lib, tests, etc.)_ |

### PHPUnit Incremental Migration (`nextcloud-phpunit-incremental.yml`)

Tests database migrations by upgrading from a baseline version.

```yaml
jobs:
  incremental:
    uses: chenasraf/workflows/.github/workflows/nextcloud-phpunit-incremental.yml@nextcloud-latest
    with:
      baseline-version: v1.0.0
      php-version: '8.2'
      validation-query: 'SELECT COUNT(*) FROM oc_myapp_users'
      path-filters: |
        - 'lib/Migration/**'
        - 'appinfo/info.xml'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `baseline-version` | Git tag/ref to upgrade from | Yes | - |
| `php-version` | PHP version | No | `8.3` |
| `php-extensions-mysql` | PHP extensions for MySQL tests | No | _(common extensions)_ |
| `php-extensions-pgsql` | PHP extensions for PostgreSQL tests | No | _(common extensions)_ |
| `validation-query` | SQL query to validate migration | No | _(empty)_ |
| `path-filters` | Paths to trigger on (YAML list) | No | _(lib, tests, etc.)_ |

### Psalm Static Analysis (`nextcloud-psalm.yml`)

Runs Psalm static analysis across supported Nextcloud versions.

```yaml
jobs:
  psalm:
    uses: chenasraf/workflows/.github/workflows/nextcloud-psalm.yml@nextcloud-latest
    with:
      psalm-command: 'composer run psalm -- --show-info=true'
      path-filters: |
        - 'lib/**/*.php'
        - 'psalm.xml'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `psalm-command` | Command to run Psalm | No | `composer run psalm` |
| `php-extensions` | PHP extensions to install | No | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | No | `**.php`, `psalm.xml` |

### PHP Lint (`nextcloud-lint-php.yml`)

Runs PHP syntax linting across supported PHP versions.

```yaml
jobs:
  lint:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-php.yml@nextcloud-latest
    with:
      lint-command: 'composer run lint -- --colors'
      path-filters: |
        - 'lib/**/*.php'
        - 'appinfo/**/*.php'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lint-command` | Command to run lint | No | `composer run lint` |
| `php-extensions` | PHP extensions to install | No | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | No | `**.php` |

### PHP-CS-Fixer (`nextcloud-lint-php-cs.yml`)

Checks PHP code style with PHP-CS-Fixer.

```yaml
jobs:
  cs:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-php-cs.yml@nextcloud-latest
    with:
      cs-check-command: 'vendor/bin/php-cs-fixer fix --dry-run --diff'
      path-filters: |
        - 'lib/**/*.php'
        - 'tests/**/*.php'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `cs-check-command` | Command to check code style | No | `composer run cs:check` |
| `php-extensions` | PHP extensions to install | No | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | No | `**.php`, `.php-cs-fixer.dist.php` |

### ESLint (`nextcloud-lint-eslint.yml`)

Runs ESLint on frontend code.

```yaml
jobs:
  eslint:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-eslint.yml@nextcloud-latest
    with:
      lint-command: 'pnpm lint --max-warnings 0'
      path-filters: |
        - 'src/**/*.ts'
        - 'src/**/*.vue'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lint-command` | Command to run lint | No | `pnpm lint` |
| `path-filters` | Paths to trigger on (YAML list) | No | `src/**`, `*.ts`, `*.js`, etc. |

### OpenAPI Lint (`nextcloud-lint-openapi.yml`)

Validates OpenAPI spec is up to date.

```yaml
jobs:
  openapi:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-openapi.yml@nextcloud-latest
    with:
      openapi-command: 'composer run generate-openapi'
      typescript-types-pattern: 'src/api/types/*.ts'
      path-filters: |
        - 'lib/Controller/**/*.php'
        - 'openapi.json'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `openapi-command` | Command to regenerate OpenAPI | No | `composer run openapi` |
| `typescript-types-pattern` | Glob for TypeScript types | No | `src/types/openapi/openapi*.ts` |
| `path-filters` | Paths to trigger on (YAML list) | No | `lib/**/*.php`, `openapi.json` |

### AppInfo XML Lint (`nextcloud-lint-appinfo-xml.yml`)

Validates `appinfo/info.xml` against schema.

```yaml
jobs:
  xml:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-appinfo-xml.yml@nextcloud-latest
    with:
      xml-file: './custom/path/info.xml'
      path-filters: |
        - 'custom/path/info.xml'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `xml-file` | Path to the info.xml file | No | `./appinfo/info.xml` |
| `schema-url` | URL to XML schema | No | _(Nextcloud schema)_ |
| `path-filters` | Paths to trigger on (YAML list) | No | `appinfo/info.xml` |

### NPM Build (`nextcloud-build-npm.yml`)

Builds frontend assets with pnpm.

```yaml
jobs:
  build:
    uses: chenasraf/workflows/.github/workflows/nextcloud-build-npm.yml@nextcloud-latest
    with:
      build-command: 'pnpm build:prod'
      path-filters: |
        - 'src/**'
        - 'package.json'
        - 'pnpm-lock.yaml'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `build-command` | Command to run build | No | `pnpm build` |
| `path-filters` | Paths to trigger on (YAML list) | No | `src/**`, `*.json`, etc. |

### Vitest (`nextcloud-vitest.yml`)

Runs Vitest frontend tests.

```yaml
jobs:
  vitest:
    uses: chenasraf/workflows/.github/workflows/nextcloud-vitest.yml@nextcloud-latest
    with:
      node-version: '20'
      test-command: 'pnpm vitest run --coverage'
      path-filters: |
        - 'src/**'
        - 'tests/**'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `node-version` | Node.js version to use | No | `22` |
| `test-command` | Command to run tests | No | `pnpm test:run` |
| `path-filters` | Paths to trigger on (YAML list) | No | `src/**`, `*.ts`, etc. |

### Block Unconventional Commits (`nextcloud-block-unconventional-commits.yml`)

Blocks commits that don't follow conventional commit format.

```yaml
jobs:
  commits:
    uses: chenasraf/workflows/.github/workflows/nextcloud-block-unconventional-commits.yml@nextcloud-latest
    with:
      allowed-types: 'feat,fix,docs,chore,refactor'
```

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `allowed-types` | Comma-separated list of allowed commit types | No | _(feat, fix, docs, etc.)_ |

---

## License

MIT
