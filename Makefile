.PHONY: tag help

help:
	@echo "Usage: make tag [TAG=<name>] [VERSION=<number>]"
	@echo ""
	@echo "  TAG      - Tag prefix name (e.g., 'go-release', 'nextcloud')"
	@echo "             Can also be set via TAG env var"
	@echo "  VERSION  - Version number (optional, auto-increments if omitted)"
	@echo ""
	@echo "Examples:"
	@echo "  make tag TAG=go-release"
	@echo "  make tag TAG=go-release VERSION=3"
	@echo "  TAG=nextcloud make tag"

tag:
ifndef TAG
	@read -p "Enter tag name: " tag_input; \
	if [ -z "$$tag_input" ]; then \
		echo "Error: TAG is required"; \
		exit 1; \
	fi; \
	$(MAKE) tag TAG=$$tag_input $(if $(VERSION),VERSION=$(VERSION),)
else
	@# Auto-detect version if not provided
	$(eval _detected_version := $(shell \
		latest=$$(git tag --list '$(TAG)-v*' | sed 's/$(TAG)-v//' | sort -n | tail -1); \
		if [ -z "$$latest" ]; then echo 1; else echo $$((latest + 1)); fi \
	))
	$(eval VERSION := $(or $(VERSION),$(_detected_version)))
	@# Get latest global version
	$(eval GLOBAL_VERSION := $(shell \
		latest=$$(git tag --list 'v*' | grep -E '^v[0-9]+$$' | sed 's/v//' | sort -n | tail -1); \
		if [ -z "$$latest" ]; then echo 1; else echo $$((latest + 1)); fi \
	))
	@echo "Tagging with:"
	@echo "  Global version: v$(GLOBAL_VERSION)"
	@echo "  Tag version:    $(TAG)-v$(VERSION)"
	@echo "  Latest tag:     $(TAG)-latest"
	@echo ""
	@# Create global version tag
	git tag -f v$(GLOBAL_VERSION)
	@# Create tag-specific version
	git tag -f $(TAG)-v$(VERSION)
	@# Remove old latest tag and re-create
	-git tag -d $(TAG)-latest 2>/dev/null || true
	git tag $(TAG)-latest
	@echo ""
	@echo "Tags created successfully!"
	@read -p "Push tags to remote? [Y/n] " answer; \
	answer=$${answer:-y}; \
	if echo "$$answer" | grep -iq "^y"; then \
		echo "Pushing tags to remote..."; \
		git push origin v$(GLOBAL_VERSION) $(TAG)-v$(VERSION) $(TAG)-latest --force; \
	else \
		echo "To push tags later, run: git push origin v$(GLOBAL_VERSION) $(TAG)-v$(VERSION) $(TAG)-latest --force"; \
	fi
endif
