# Welcome to the contributing guide <!-- omit in toc -->

Thank you for investing your time in contributing to our project!

## New contributor guide

To get an overview of the project, read the [README](README.md).

## Linting

Linting commands to run from the devcontainer/pipeline.

Rubocop

```bash
rubocop
```

## Testing

### Unit testing

```bash
rspec
```

### Integration testing

```bash
npx sls invoke -f setter -s dev -p spec/fixtures/s3_event.json
```

## Release

This project uses [Standard Version](https://www.npmjs.com/package/standard-version) for conducting releases. All commits should follow the [Conventional Commits specification](https://www.conventionalcommits.org/en/v1.0.0/) for accurately generating the CHANGELOG.md contents.

To perform a release

```bash
npm install
npm run release
```
