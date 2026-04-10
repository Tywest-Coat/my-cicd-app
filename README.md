# CI/CD Pipeline with AWS ECS Fargate & GitHub Actions

A production-grade CI/CD pipeline that automatically tests, builds, and deploys a containerized Python Flask API to AWS ECS Fargate on every git push.

## Architecture

[placeholder for architecture diagram - add diagram.png once created]

## Pipeline Flow

```
git push → GitHub Actions → Test → Build (Docker + ECR) → Deploy (ECS Fargate)
```

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Python 3.12, Flask |
| Containerization | Docker |
| Container Registry | Amazon ECR (with vulnerability scanning) |
| Orchestration | Amazon ECS Fargate (serverless) |
| Load Balancing | AWS Application Load Balancer |
| CI/CD | GitHub Actions (3-stage pipeline) |
| Logging | Amazon CloudWatch |
| Security | IAM Least Privilege, GitHub Encrypted Secrets |

## Pipeline Stages

### Stage 1 — Test
- Spins up a clean Ubuntu runner on every push to main
- Installs Python dependencies from requirements.txt
- Runs pytest suite against all endpoints
- If any test fails, pipeline stops here. Nothing gets built or deployed.

### Stage 2 — Build
- Only runs if Stage 1 passes
- Only runs on pushes to main branch (not PRs)
- Builds Docker image using python:3.12-slim base
- Tags image with the exact Git commit SHA for full traceability
- Pushes image to Amazon ECR

### Stage 3 — Deploy
- Downloads current ECS Task Definition from AWS
- Swaps the container image URL to the newly built image
- Triggers a rolling deployment on ECS Fargate
- Waits for service stability — if the container fails its health check, ECS automatically rolls back to the last working version

## Security Highlights

- GitHub Actions uses a dedicated IAM user with scoped permissions only (ECR push + ECS update). No admin credentials in the pipeline.
- All AWS credentials stored as GitHub Encrypted Secrets. Zero secrets committed to the repository.
- Docker container runs as a non-root user.
- ECR vulnerability scanning enabled on every image push.

## Project Structure

```
my-cicd-app/
├── .github/
│   └── workflows/
│       └── ci-cd.yml        # GitHub Actions pipeline
├── tests/
│   └── test_app.py          # pytest test suite
├── app.py                   # Flask application
├── Dockerfile               # Container definition
├── .dockerignore            # Docker build exclusions
├── iam-policy.json          # IAM policy template (no real credentials)
├── task-definition.json     # ECS task definition template
└── requirements.txt         # Python dependencies
```

## Key Endpoints

| Endpoint | Method | Description |
|---|---|---|
| / | GET | Returns app status and version |
| /health | GET | Health check used by ALB and ECS |

## How to Run Locally

```bash
# Clone the repo
git clone https://github.com/Tywest-Coat/my-cicd-app.git
cd my-cicd-app

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run tests
python -m pytest tests/ -v

# Run locally
python app.py
```

## Deployment

Any push to the main branch automatically triggers the full pipeline. No manual steps required.

To spin down the ECS service (cost saving):
```bash
aws ecs update-service --cluster my-cicd-cluster --service my-cicd-service --desired-count 0 --region us-east-1
```

To spin it back up:
```bash
aws ecs update-service --cluster my-cicd-cluster --service my-cicd-service --desired-count 1 --region us-east-1
```
