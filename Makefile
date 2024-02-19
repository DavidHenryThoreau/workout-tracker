GIT_TAG ?= $(shell git describe --tags)

.PHONY: all clean test

all: build-all serve

clean:
	rm ./tmp/main ./assets/output.css

build-all: build-tw build-server

build-server:
	go build -ldflags "-X main.version=$(GIT_TAG)" -o ./tmp/main ./

build-docker:
	docker build -t workouts --pull .

build-tw:
	npx tailwindcss -i ./assets/main.css -o ./assets/output.css

serve:
	./tmp/main
