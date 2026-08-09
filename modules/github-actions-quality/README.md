# GitHub Actions quality workflow

Copy `files/.github/workflows/quality.yml` into a repository that exposes the
canonical mise lifecycle. Update only its workflow name/default branch. It uses
least-privilege permissions, cancellation, full history, and exact PR base/head
SHAs. Keep deployments, provider credentials, and application matrices out.
