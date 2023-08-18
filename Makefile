COMPOSE_PROJECT_NAME ?= $(shell basename $(shell pwd))
COMPOSE_COMMAND := docker-compose

dev:
	$(COMPOSE_COMMAND) up -d rails frontend-purs-dev
	@$(MAKE) --no-print-directory envs
.PHONY: dev

down:
	$(COMPOSE_COMMAND) down
	@rm -rf .direnv/envs/*_PORT
.PHONY: down

# `docker-compose port` does not work because it only picks the first port which is bound on ipv4.
# To pick a port bound to ipv6, refer to the last item listed in insepction.
envs: DB_PORT = $(shell docker inspect $(COMPOSE_PROJECT_NAME)_db_1 | jq -r '.[].NetworkSettings.Ports."5432/tcp"[-1].HostPort')
envs:
	@mkdir -p .direnv/envs
	@echo "$(DB_PORT)" > .direnv/envs/DB_PORT
.PHONY: envs

image:
	nix build ".#dev-image"
	cat result | docker load
	rm result
.PHONY: image

# Create an initial user in the database.  This is convenient for
# development when you need a user to be able to login to the web app.
seed-user:
	$(COMPOSE_COMMAND) run --rm rails bash -c 'cd /app/rails && SEED_USERS="$(SEED_USERS)" rails db:seed'
.PHONY: seed-user

# Get a token for being able to access the API on the command line
# using curl.
get-dev-token: EMAIL ?= $(shell echo $$SEED_USERS | sed 's/^[^<]*<\([^>]*\).*/\1/')
get-dev-token: PASSWORD ?= $(shell echo $$SEED_USERS | sed "s/^[^:]*:\([^<]*\).*/\1/")
get-dev-token:
	@curl --silent --request POST --header "Content-Type: application/json" \
		--data '("email":"$(EMAIL)", "password":"$(PASSWORD)")' \
		'http://localhost:3000/api/auth' | \
		jq -r .token
.PHONY: get-dev-token
