IMAGE_NAME ?=k8s-cert-init
TAG ?=alpine3.20

.PHONY:	build
build:
	docker buildx build -t yidoughi/${IMAGE_NAME}:${TAG} . --progress=plain ${OPTIONS}
	docker tag yidoughi/${IMAGE_NAME}:${TAG} yidoughi/${IMAGE_NAME}:latest
.PHONY:	cert
cert:
	cert.sh local 

.PHONY:	push
push:
	docker push yidoughi/${IMAGE_NAME}:${TAG}
	docker push yidoughi/${IMAGE_NAME}:latest

.PHONY:	run
run:
	docker rm -f ${IMAGE_NAME} 
	docker run  --rm --name ${IMAGE_NAME} -d --env-file env/.env.dev yidoughi/${IMAGE_NAME}:latest

.PHONY:	exec
exec:
	docker exec -it ${IMAGE_NAME} sh

.PHONY:	run-all
run-all:
	make build
	make run
	make exec