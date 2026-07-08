# StyleCheck

`StyleCheck` provides the `splinter3d_style` CLI and a published `pre-commit` hook.

## Local Development

Use Poetry for local development so the CLI, test dependencies, and release tooling stay aligned with the project metadata.

```bash
poetry install
poetry run splinter3d_style
poetry run pytest
```

If you need to enter the virtual environment directly:

```bash
poetry shell
splinter3d_style
pytest
```

## Build And Test Locally

Build the distribution files locally before creating a release:

```bash
poetry run python -m build
ls dist/
```

Test the built package rather than the source tree:

```bash
pipx install ./dist/splinter3d_style-X.Y.Z-py3-none-any.whl
splinter3d_style
pipx uninstall splinter3d_style
```

You can also validate the source distribution or wheel with a throwaway virtualenv:

```bash
python3 -m venv .venv-build-test
. .venv-build-test/bin/activate
pip install ./dist/splinter3d_style-X.Y.Z-py3-none-any.whl
splinter3d_style
deactivate
```

`X.Y.Z` is a placeholder. Use the actual filename created in `dist/`, or install the first built wheel directly:

```bash
pipx install "$(ls dist/*.whl | head -n 1)"
```

## Install From A Release

Install a published release artifact with `pipx`:

```bash
pipx install git+https://github.com/Splinter3D/StyleCheck
splinter3d_style
```

## Update From A Release

Update a the package with pipx

```bash
pipx upgrade splinter3d_style
```

## Use With pre-commit

Add this repository and a release tag to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/Splinter3D/StyleCheck
    rev: vX.Y.Z
    hooks:
      - id: splinter3d-style
```

Then install and run:

```bash
pre-commit install
pre-commit run --all-files
```

## Release

Releases are driven by pull requests and tags created by GitHub Actions:

- Pull requests into `main` are only valid when they come from `dev` or `hotfix/*`.
- When a pull request is merged into `dev`, CI creates a `vX.Y.Z-rc.N` tag.
- When a pull request is merged into `main`, CI creates a `vX.Y.Z` tag.
- Tag creation uses Commitizen to determine the next base version and defaults to `0.1.0` when no stable tag exists.
- Every pushed release tag triggers the packaging workflow, which builds the distribution files and attaches them to a GitHub release.

Protected GitHub environments can be applied to the `release-rc` and `release` jobs to gate prerelease and production publication independently.
