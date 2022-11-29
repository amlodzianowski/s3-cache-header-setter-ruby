# s3-cache-header-setter-ruby

![GitHub Workflow Status](https://github.com/amlodzianowski/s3-cache-header-setter-ruby/actions/workflows/main.yml/badge.svg)

This project is a serverless helper for configuring [Cache-Control headers](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html#ExpirationAddingHeadersInS3) on objects uploaded to S3.

## Deployment

### Prerequisites

[Node](https://nodejs.org/en/download/) installed on the deployment machine

Create a `.env` in the root directory of this project containing the necessary settings:

```bash
S3_BUCKET_NAME=s3-bucket-name
S3_PATH_PREFIX=s3-path-prefix
AWS_REGION=region-where-s3-bucket-lives

```

### Install

```bash
npm install
npx sls deploy -s dev
```

### Uninstall

```bash
npx sls remove -s dev
```
