# Reusable GitHub Workflows

A collection of reusable GitHub Actions workflows.

## Workflows

### Go Release (`go-release.yml`)

A complete CI/CD workflow for Go projects that handles testing, cross-platform builds, releases, and
Homebrew tap updates.

#### Features

- Runs tests with configurable test command
- Cross-platform builds (Linux, macOS, Windows)
- Automated releases via [release-please](https://github.com/googleapis/release-please)
- Automatic Homebrew tap updates via repository dispatch

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
    uses: chenasraf/workflows/.github/workflows/go-release.yml@main
    with:
      name: my-binary
    secrets:
      REPO_DISPATCH_PAT: ${{ secrets.REPO_DISPATCH_PAT }}
```

#### Inputs

| Input               | Description                                          | Required | Default                                                            |
| ------------------- | ---------------------------------------------------- | -------- | ------------------------------------------------------------------ |
| `name`              | Binary/project name                                  | Yes      | -                                                                  |
| `go-version`        | Go version to use                                    | No       | `1.24`                                                             |
| `platforms`         | JSON array of platforms to build                     | No       | `["linux/amd64", "darwin/amd64", "darwin/arm64", "windows/amd64"]` |
| `package`           | Go package path (empty for root)                     | No       | `""`                                                               |
| `compress`          | Compress build artifacts                             | No       | `true`                                                             |
| `test-command`      | Test command to run                                  | No       | `go test -v ./...`                                                 |
| `skip-tests`        | Skip running tests                                   | No       | `false`                                                            |
| `main-branch`       | Main branch name for releases                        | No       | `master`                                                           |
| `homebrew-tap-repo` | Homebrew tap repo for dispatch (leave empty to skip) | No       | ``                                                                 |

#### Secrets

| Secret              | Description                              | Required |
| ------------------- | ---------------------------------------- | -------- |
| `REPO_DISPATCH_PAT` | PAT for dispatching to homebrew tap repo | No       |

#### Example with Custom Options

```yaml
jobs:
  release:
    uses: chenasraf/workflows/.github/workflows/go-release.yml@master
    with:
      name: my-cli
      go-version: '1.24'
      platforms: '["linux/amd64", "darwin/arm64"]'
      main-branch: main
      homebrew-tap-repo: myorg/homebrew-tap
    secrets:
      REPO_DISPATCH_PAT: ${{ secrets.REPO_DISPATCH_PAT }}
```

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

## Nextcloud Workflows

Reusable workflows for Nextcloud app development. These workflows include automatic path filtering to skip unnecessary runs when irrelevant files change.

### PHPUnit MySQL (`nextcloud-phpunit-mysql.yml`)

Runs PHPUnit tests with MySQL database.

```yaml
jobs:
  phpunit:
    uses: chenasraf/workflows/.github/workflows/nextcloud-phpunit-mysql.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `php-versions-min` | Minimum PHP version | `8.2` |
| `php-versions-max` | Maximum PHP version | `8.3` |
| `mysql-version` | MySQL version | `8.4` |
| `php-extensions` | PHP extensions to install | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | _(lib, tests, etc.)_ |

### PHPUnit PostgreSQL (`nextcloud-phpunit-pgsql.yml`)

Runs PHPUnit tests with PostgreSQL database.

```yaml
jobs:
  phpunit:
    uses: chenasraf/workflows/.github/workflows/nextcloud-phpunit-pgsql.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `php-version` | PHP version | `8.3` |
| `php-extensions` | PHP extensions to install | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | _(lib, tests, etc.)_ |

### PHPUnit Incremental Migration (`nextcloud-phpunit-incremental.yml`)

Tests database migrations by upgrading from a baseline version.

```yaml
jobs:
  incremental:
    uses: chenasraf/workflows/.github/workflows/nextcloud-phpunit-incremental.yml@nextcloud-latest
    with:
      baseline-version: v1.0.0
```

| Input | Description | Default |
|-------|-------------|---------|
| `baseline-version` | Git tag/ref to upgrade from | **Required** |
| `php-version` | PHP version | `8.3` |
| `validation-query` | SQL query to validate migration | _(empty)_ |
| `path-filters` | Paths to trigger on (YAML list) | _(lib, tests, etc.)_ |

### Psalm Static Analysis (`nextcloud-psalm.yml`)

Runs Psalm static analysis across supported Nextcloud versions.

```yaml
jobs:
  psalm:
    uses: chenasraf/workflows/.github/workflows/nextcloud-psalm.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `psalm-command` | Command to run Psalm | `composer run psalm` |
| `php-extensions` | PHP extensions to install | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | `**.php`, `psalm.xml` |

### PHP Lint (`nextcloud-lint-php.yml`)

Runs PHP syntax linting across supported PHP versions.

```yaml
jobs:
  lint:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-php.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `lint-command` | Command to run lint | `composer run lint` |
| `php-extensions` | PHP extensions to install | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | `**.php` |

### PHP-CS-Fixer (`nextcloud-lint-php-cs.yml`)

Checks PHP code style with PHP-CS-Fixer.

```yaml
jobs:
  cs:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-php-cs.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `cs-check-command` | Command to check code style | `composer run cs:check` |
| `php-extensions` | PHP extensions to install | _(common extensions)_ |
| `path-filters` | Paths to trigger on (YAML list) | `**.php`, `.php-cs-fixer.dist.php` |

### ESLint (`nextcloud-lint-eslint.yml`)

Runs ESLint on frontend code.

```yaml
jobs:
  eslint:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-eslint.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `lint-command` | Command to run lint | `pnpm lint` |
| `path-filters` | Paths to trigger on (YAML list) | `src/**`, `*.ts`, `*.js`, etc. |

### OpenAPI Lint (`nextcloud-lint-openapi.yml`)

Validates OpenAPI spec is up to date.

```yaml
jobs:
  openapi:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-openapi.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `openapi-command` | Command to regenerate OpenAPI | `composer run openapi` |
| `typescript-types-pattern` | Glob for TypeScript types | `src/types/openapi/openapi*.ts` |
| `path-filters` | Paths to trigger on (YAML list) | `lib/**/*.php`, `openapi.json` |

### AppInfo XML Lint (`nextcloud-lint-appinfo-xml.yml`)

Validates `appinfo/info.xml` against schema.

```yaml
jobs:
  xml:
    uses: chenasraf/workflows/.github/workflows/nextcloud-lint-appinfo-xml.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `schema-url` | URL to XML schema | _(Nextcloud schema)_ |
| `path-filters` | Paths to trigger on (YAML list) | `appinfo/info.xml` |

### NPM Build (`nextcloud-build-npm.yml`)

Builds frontend assets with pnpm.

```yaml
jobs:
  build:
    uses: chenasraf/workflows/.github/workflows/nextcloud-build-npm.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `path-filters` | Paths to trigger on (YAML list) | `src/**`, `*.json`, etc. |

### Vitest (`nextcloud-vitest.yml`)

Runs Vitest frontend tests.

```yaml
jobs:
  vitest:
    uses: chenasraf/workflows/.github/workflows/nextcloud-vitest.yml@nextcloud-latest
```

| Input | Description | Default |
|-------|-------------|---------|
| `vitest-command` | Command to run Vitest | `pnpm vitest` |
| `path-filters` | Paths to trigger on (YAML list) | `src/**`, `*.ts`, etc. |

### Block Unconventional Commits (`nextcloud-block-unconventional-commits.yml`)

Blocks commits that don't follow conventional commit format.

```yaml
jobs:
  commits:
    uses: chenasraf/workflows/.github/workflows/nextcloud-block-unconventional-commits.yml@nextcloud-latest
```

---

## License

MIT
