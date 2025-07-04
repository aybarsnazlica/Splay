.PHONY: release changelog tag push

changelog:
	git-cliff --unreleased --bump --prepend CHANGELOG.md

tag:
	$(eval VERSION := $(shell git-cliff --bumped-version))
	$(eval VERSION := $(shell echo $(VERSION) | sed 's/^v*//'))
	git add CHANGELOG.md
	git commit -m "docs: update changelog for $(VERSION)"
	git tag -a "v$(VERSION)" -m "Release v$(VERSION)"

push:
	git push && git push --tags

release: changelog tag push
