ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
# Local checkouts mirror GitHub: ~/github/<org>/<repo>.
SCHMEIDE_DIR ?= $(HOME)/github/schmeide
PUBLIC_REPOS := schmeide.app schmeide.com template iac

.DEFAULT_GOAL := help
.PHONY: help setup setup/repos setup/hooks check/attribution skills/update skills/update-pocock

help: ## List every target
	@grep -E '^[a-zA-Z/_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-22s %s\n", $$1, $$2}'

setup: setup/hooks setup/repos ## Install git hooks and clone missing public repos

setup/repos: ## Clone each public Schmeide repo into $(SCHMEIDE_DIR) unless it is already there
	@mkdir -p "$(SCHMEIDE_DIR)"
	@for repo in $(PUBLIC_REPOS); do \
	  if [ -d "$(SCHMEIDE_DIR)/$$repo/.git" ]; then \
	    echo "$$repo: already at $(SCHMEIDE_DIR)/$$repo"; \
	  else \
	    git clone "https://github.com/schmeide/$$repo.git" "$(SCHMEIDE_DIR)/$$repo" || exit 1; \
	  fi; \
	done
	@[ -d "$(SCHMEIDE_DIR)/project/.git" ] || \
	  echo "project is private: gh repo clone schmeide/project $(SCHMEIDE_DIR)/project"

setup/hooks: ## Install the commit-msg hook that rejects AI attribution
	ln -sf "$(ROOT)/git/hooks/commit-msg" "$(ROOT)/.git/hooks/commit-msg"
	@echo "Git hooks installed"

check/attribution: ## Fail if a pull request carries AI attribution (PR=<n>)
	"$(ROOT)/scripts/check_attribution.sh" "$(PR)"

skills/update: ## Vendor jakubkrehel/skills at REF into .claude/skills, or into DEST
	"$(ROOT)/scripts/vendor_skills.sh" "$(REF)" $(DEST)

skills/update-pocock: ## Vendor mattpocock/skills at REF into .claude/skills, or into DEST
	"$(ROOT)/scripts/vendor_pocock_skills.sh" "$(REF)" $(DEST)
