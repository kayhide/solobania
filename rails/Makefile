RAILS_ENV ?= development
MIGRATION_FILES := $(shell find db/migrate -name "*.rb")
MODEL_FILES := $(shell find app/models -name "*.rb")

dump-schema: db/schema.rb db/structure.sql db/erd.pdf
.PHONY: dump-schema

db/schema.rb: $(MIGRATION_FILES)
	rails db:schema:dump

db/structure.sql: $(MIGRATION_FILES)
	RAILS_SCHEMA_FORMAT=sql rails db:schema:dump

db/erd.pdf: $(MIGRATION_FILES) $(MODEL_FILES)
	rails erd
