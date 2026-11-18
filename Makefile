ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
# Local checkouts mirror GitHub: ~/github/<org>/<repo>.
SCHMEIDE_DIR ?= $(HOME)/github/schmeide
# Every repo `make setup` clones, as <owner>/<repo>. project is private and needs gh auth.
REPOS := schmeide/schmeide.app schmeide/schmeide.com schmeide/template schmeide/iac schmeide/project \
  autobutler-org/factory

.DEFAULT_GOAL := help
.PHONY: help setup setup/repos setup/hooks check/attribution skills/update skills/update-pocock

help: ## List every target
	@grep -E '^[a-zA-Z/_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-22s %s\n", $$1, $$2}'

setup: setup/hooks setup/repos ## Install git hooks and clone every missing repo

setup/repos: ## Clone each repo in REPOS into $(SCHMEIDE_DIR) unless it is already there
	@mkdir -p "$(SCHMEIDE_DIR)"
	@failed=""; \
	for slug in $(REPOS); do \
	  repo=$${slug#*/}; dest="$(SCHMEIDE_DIR)/$$repo"; \
	  if [ -d "$$dest/.git" ]; then \
	    echo "$$repo: already at $$dest"; \
	  elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then \
	    gh repo clone "$$slug" "$$dest" || failed="$$failed $$slug"; \
	  else \
	    git clone "https://github.com/$$slug.git" "$$dest" || failed="$$failed $$slug"; \
	  fi; \
	done; \
	if [ -n "$$failed" ]; then \
	  echo "Could not clone:$$failed. Private repos need 'gh auth login' first."; exit 1; \
	fi

setup/hooks: ## Install the commit-msg hook that rejects AI attribution
	ln -sf "$(ROOT)/git/hooks/commit-msg" "$(ROOT)/.git/hooks/commit-msg"
	@echo "Git hooks installed"

check/attribution: ## Fail if a pull request carries AI attribution (PR=<n>)
	"$(ROOT)/scripts/check_attribution.sh" "$(PR)"

skills/update: ## Vendor jakubkrehel/skills at REF into .claude/skills, or into DEST
	"$(ROOT)/scripts/vendor_skills.sh" "$(REF)" $(DEST)

skills/update-pocock: ## Vendor mattpocock/skills at REF into .claude/skills, or into DEST
	"$(ROOT)/scripts/vendor_pocock_skills.sh" "$(REF)" $(DEST)
