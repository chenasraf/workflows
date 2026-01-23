# Reusable GitHub Workflows

A collection of reusable GitHub Actions workflows.

## Table of Contents

- [Workflows](#workflows)
  - [Go Release](#go-release-go-releaseyml)
  - [Manual Homebrew Release](#manual-homebrew-release-manual-homebrew-releaseyml)
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
