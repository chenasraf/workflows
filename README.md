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
| `homebrew-tap-repo` | Homebrew tap repo for dispatch (leave empty to skip) | No       | `chenasraf/homebrew-tap`                                           |

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
