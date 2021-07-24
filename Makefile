REPOSITORY?=jkieley/tsis-clearer
TAGNAME?=latest

# Ensure that the python version on the PATH is version 3.7.6
# You can check this by useing the version check  task

# Builds the docker image
build:
	docker build -t ${REPOSITORY} .
# Runs the docker image
run:
	docker run ${REPOSITORY}
	# see 1password entry: "Docker Cluster Creation w/ Keys" for command with keys injected
image-push:
	docker push ${REPOSITORY}:${TAGNAME}
view:
	docker run -it --entrypoint=/bin/sh ${REPOSITORY}:latest
c:
	./create_cluster.sh
d:
	./destory_cluster.sh
install-mon:
	./promethius-grafana/install.sh

br: build run
bi: build image-push
bv: build view