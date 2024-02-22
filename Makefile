GIT_REF ?= $(shell git symbolic-ref HEAD)
GIT_REF_NAME ?= $(shell git branch --show-current)
GIT_REF_TYPE ?= branch
GIT_COMMIT ?= $(shell git rev-parse HEAD)
BUILD_TIME ?= $(shell date -u --rfc-3339=seconds)
OUTPUT_FILE ?= tmp/main

I18N_LANGUAGES ?= en nl
LANG_TO_GENERATE = $(patsubst generate-translation-%,%,$@)

.PHONY: all clean test build

all: clean install-deps test build

install-deps:
	npm install

clean:
	rm -fv ./assets/output.css ./workout-tracker
	rm -rf ./tmp/ ./node_modules/

dev:
	air

build: build-tw build-server build-docker

build-server:
	go build \
		-ldflags "-X 'main.buildTime=$(BUILD_TIME)' -X 'main.gitCommit=$(GIT_COMMIT)' -X 'main.gitRef=$(GIT_REF)' -X 'main.gitRefName=$(GIT_REF_NAME)' -X 'main.gitRefType=$(GIT_REF_TYPE)'" \
		-o $(OUTPUT_FILE) ./

build-docker:
	docker build -t workout-tracker --pull \
		--build-arg BUILD_TIME="$(BUILD_TIME)" \
		--build-arg GIT_COMMIT="$(GIT_COMMIT)" \
		--build-arg GIT_REF="$(GIT_REF)" \
		--build-arg GIT_REF_NAME="$(GIT_REF_NAME)" \
		--build-arg GIT_REF_TYPE="$(GIT_REF_TYPE)" \
		.

build-tw:
	npx tailwindcss -i ./main.css -o ./assets/output.css

watch-tw:
	npx tailwindcss -i ./main.css -o ./assets/output.css --watch

generate-messages:
	xspreak -p ./locale/ -f json --template-prefix "T" -t "views/**/*.html"

generate-translations: $(patsubst %,generate-translation-%, $(I18N_LANGUAGES))

$(patsubst %,generate-translation-%, $(I18N_LANGUAGES)):
	xspreak merge -i locale/messages.json \
		-o locale/${LANG_TO_GENERATE}.json -l ${LANG_TO_GENERATE}

serve:
	$(OUTPUT_FILE)

test: test-go test-assets

test-assets:
	prettier --check .

test-go:
	go test -short -count 1 -mod vendor -covermode=atomic ./...
	golangci-lint run --allow-parallel-runners --fix
