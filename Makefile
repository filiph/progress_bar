.PHONY: build-local run-local stop-local toot-local logs-local deploy

IMAGE_NAME = progress-bar:local
CONTAINER_NAME = progress-bar-local
PORT = 8080
LOCAL_DATA_DIR = $(shell pwd)/local_data

build-local:
	@echo "Building local Docker container..."
	docker build -t $(IMAGE_NAME) .

run-local: build-local
	@echo "Running local container on port $(PORT)..."
	@mkdir -p $(LOCAL_DATA_DIR)
	@docker rm -f $(CONTAINER_NAME) 2>/dev/null || true
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p $(PORT):80 \
		-v $(LOCAL_DATA_DIR):/app/data \
		-e MASTODON_ACCESS_TOKEN="$(MASTODON_ACCESS_TOKEN)" \
		-e MASTODON_BASE_URL="https://techhub.social" \
		$(IMAGE_NAME)
	@echo "Container started. Open http://localhost:$(PORT) to view the static site."

stop-local:
	@echo "Stopping local container..."
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true

toot-local:
	@echo "Executing toot calculation inside container (dry-run)..."
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/toot --dry-run

logs-local:
	@docker logs $(CONTAINER_NAME)

deploy:
	kamal deploy
