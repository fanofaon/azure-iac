PROJECT_NAME := $(shell bash -c 'source .project.env && printf "%s" "$$PROJECT_NAME"')
GITHUB_USERNAME := $(shell bash -c 'source .project.env && printf "%s" "$$GITHUB_USERNAME"')

GITHUB_REPO := $(GITHUB_USERNAME)/$(PROJECT_NAME)
VISIBILITY ?= public

.PHONY: \
	gh-login \
	gh-status \
	gh-create \
	gh-push \
	gh-open \
	gh-protect-main \
	gh-protection-status

gh-login:
	gh auth login

gh-status:
	gh auth status

gh-create:
	gh repo create $(GITHUB_REPO) \
		--$(VISIBILITY) \
		--source=. \
		--remote=origin \
		--push

gh-push:
	git push -u origin $$(git branch --show-current)

gh-open:
	gh repo view --web

gh-protect-main:
	@printf '%s\n' '{"required_status_checks":null,"enforce_admins":true,"required_pull_request_reviews":{"dismiss_stale_reviews":true,"require_code_owner_reviews":false,"required_approving_review_count":0,"require_last_push_approval":false},"restrictions":null,"required_linear_history":false,"allow_force_pushes":false,"allow_deletions":false,"block_creations":false,"required_conversation_resolution":true,"lock_branch":false,"allow_fork_syncing":false}' | \
	gh api \
		--method PUT \
		-H "Accept: application/vnd.github+json" \
		-H "X-GitHub-Api-Version: 2026-03-10" \
		"/repos/$(GITHUB_REPO)/branches/main/protection" \
		--input -

gh-protection-status:
	gh api \
		-H "Accept: application/vnd.github+json" \
		-H "X-GitHub-Api-Version: 2026-03-10" \
		"/repos/$(GITHUB_REPO)/branches/main/protection"
