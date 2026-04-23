Message-ID: <seed-1-1776597266@popfile.test>
From: ci@deploy.example.com
To: dev@company.example.com
Subject: [DEPLOY] Release v3.4.1 to production - SUCCESS
Date: Sun Apr 19 13:14:26 2026
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii

Deployment v3.4.1 to production completed successfully.

  Deployed by: frank@company.example.com
  Duration: 4m 12s
  Instances: 8/8 healthy
  Rollback available: yes

Changes in this release:
- Fix null pointer in payment handler (#1203)
- Increase connection pool size for database
- Update dependencies: rails 7.1.2, pg 1.5.4

No action required. Monitor dashboards for the next 30 minutes.
