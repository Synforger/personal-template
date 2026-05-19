#!/bin/bash
set -e

# Setup branch protection using GitHub Rulesets
# Usage: ./scripts/setup-branch-protection.sh
#
# Creates two rulesets:
#   - Protect main: 1 approval required
#   - Protect develop: 0 approvals required (optional review)

OWNER="${GITHUB_OWNER:-$(gh repo view --json owner -q .owner.login)}"
REPO="${GITHUB_REPO:-$(gh repo view --json name -q .name)}"

# GitHub Actions App ID (https://github.com/apps/github-actions)
GITHUB_ACTIONS_APP_ID=15368
# Repository Role ID for Admin (RepositoryRole type)
REPOSITORY_ADMIN_ROLE_ID=5

echo "Setting up branch protection for repository: ${OWNER}/${REPO}"
echo ""

# Function to create or update a ruleset
create_or_update_ruleset() {
  local ruleset_name="$1"
  local branch_pattern="$2"
  local required_approvals="$3"

  echo "Configuring ruleset: ${ruleset_name}"
  echo "  Branch: ${branch_pattern}"
  echo "  Required approvals: ${required_approvals}"

  # Check if ruleset already exists
  existing_ruleset_id=$(gh api "repos/${OWNER}/${REPO}/rulesets" --jq ".[] | select(.name == \"${ruleset_name}\") | .id" 2>/dev/null || echo "")

  if [ -n "$existing_ruleset_id" ]; then
    echo "  Ruleset already exists (ID: ${existing_ruleset_id}). Updating..."
    METHOD="PUT"
    ENDPOINT="repos/${OWNER}/${REPO}/rulesets/${existing_ruleset_id}"
  else
    echo "  Creating new ruleset..."
    METHOD="POST"
    ENDPOINT="repos/${OWNER}/${REPO}/rulesets"
  fi

  # Create or update ruleset
  result=$(gh api "${ENDPOINT}" --method "${METHOD}" --input - <<EOF
{
  "name": "${ruleset_name}",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["${branch_pattern}"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": ${required_approvals},
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "required_status_checks": [
          {"context": "build (3.10, src)", "integration_id": ${GITHUB_ACTIONS_APP_ID}},
          {"context": "build (3.10, flat)", "integration_id": ${GITHUB_ACTIONS_APP_ID}},
          {"context": "build (3.13, src)", "integration_id": ${GITHUB_ACTIONS_APP_ID}},
          {"context": "build (3.13, flat)", "integration_id": ${GITHUB_ACTIONS_APP_ID}}
        ]
      }
    }
  ],
  "bypass_actors": [
    {
      "actor_id": ${REPOSITORY_ADMIN_ROLE_ID},
      "actor_type": "RepositoryRole",
      "bypass_mode": "always"
    }
  ]
}
EOF
2>&1)

  if echo "$result" | grep -q '"id"'; then
    ruleset_id=$(echo "$result" | jq -r '.id')
    echo "  ✓ Successfully configured (ID: ${ruleset_id})"
  else
    echo "  ✗ Error: Failed to configure ruleset"
    echo "  Error details: $result"
    exit 1
  fi
  echo ""
}

# Create ruleset for main branch (1 approval required)
create_or_update_ruleset "Protect main" "refs/heads/main" 1

# Create ruleset for develop branch (0 approvals - optional review)
create_or_update_ruleset "Protect develop" "refs/heads/develop" 0

echo "Branch protection setup completed!"
echo "Please verify the rules in GitHub UI: https://github.com/${OWNER}/${REPO}/rules"
