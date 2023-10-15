include .env
postgres:
	docker run --name ${DB_DOCKER_CONTAINER} -p 5432:5432 -e POSTGRES_USER=${USER} -e POSTGRES_PASSWORD=${PASSWORD} -d postgres:12-alpine

createdb:
	docker exec -it ${DB_DOCKER_CONTAINER} createdb --username=${USER} --owner=${USER} ${DB_NAME}

dropdb:
	docker exec -it ${DB_DOCKER_CONTAINER} dropdb ${DB_NAME}

migrate_create:
	migrate create -ext sql -dir db/migration -seq init_schema	

migrate_up:
	migrate -path db/migration -database "postgresql://${USER}:${PASSWORD}@${HOST}:5432/${DB_NAME}?sslmode=disable" -verbose up

migrate_up1:
	migrate -path db/migration -database "postgresql://${USER}:${PASSWORD}@${HOST}:5432/${DB_NAME}?sslmode=disable" -verbose up 1

migrate_down:
	migrate -path db/migration -database "postgresql://${USER}:${PASSWORD}@${HOST}:5432/${DB_NAME}?sslmode=disable" -verbose down

migrate_down1:
	migrate -path db/migration -database "postgresql://${USER}:${PASSWORD}@${HOST}:5432/${DB_NAME}?sslmode=disable" -verbose down 1

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

stop_containers:
	@echo "Stopping other docker container"
	if [ $$(docker ps -q) ]; then \
		echo "found and stopped containers"; \
		docker stop $$(docker ps -q); \
	else \
		echo "no containers running..."; \
	fi
mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/punkzberryz/simplebank/db/sqlc Store
		
git-pull:
	git fetch && git pull