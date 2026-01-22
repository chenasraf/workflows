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
	$(error TAG is required. Usage: make tag TAG=<name> [VERSION=<number>])
endif
	@# Auto-detect version if not provided
	$(eval VERSION ?= $(shell \
		latest=$$(git tag --list '$(TAG)-v*' | sed 's/$(TAG)-v//' | sort -n | tail -1); \
		if [ -z "$$latest" ]; then echo 1; else echo $$((latest + 1)); fi \
	))
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
	@echo "To push tags, run: git push origin v$(GLOBAL_VERSION) $(TAG)-v$(VERSION) $(TAG)-latest --force"
