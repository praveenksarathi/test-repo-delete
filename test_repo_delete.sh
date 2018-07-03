#! /bin/bash
registry='localhost:5000'

echo "Enter the image Image"
read name

echo  "enter the tag to use"
read buildTag

echo "creating test docker repository"
echo "initializing repository with Registry local storage delete Enabled"
docker run -d -p 5000:5000 --restart=always --name registry  -e REGISTRY_STORAGE_DELETE_ENABLED=true -v /docker/registry/latest:/tmp registry:2.4

sleep 2

echo "creating test image"

docker build -t ${registry}/${name} .

echo "tagging the image to appropriate image tag"

docker tag ${registry}/${name}:latest ${registry}/${name}:${buildTag}

sleep 2

echo "pushing the image to created repo"

docker push ${registry}/${name}:${buildTag}

sleep 2

echo "Test Image entry in repo catalogs before delete"

https_proxy=  curl -k http://localhost:5000/v2/_catalog?n=2000 | python -m json.tool

sleep 2

echo "initializing Repo Image Delete"

curl -v -sSL -X DELETE "http://${registry}/v2/${name}/manifests/$(
    curl -sSL -I \
        -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        "http://${registry}/v2/${name}/manifests/$(
            curl -sSL "http://${registry}/v2/${name}/tags/list" | jq -r '.tags[0]'
        )" \
    | awk '$1 == "Docker-Content-Digest:" { print $2 }' \
    | tr -d $'\r' \
)"

sleep 2

echo "image manifest deleted!"

echo "initializing Garbage collection"

sleep 2

docker exec -it registry bin/registry garbage-collect /etc/docker/registry/config.yml

docker exec -it registry rm -rf /var/lib/registry/docker/registry/v2/repositories/${name}

echo "manifest garbage cleared"

sleep 2

echo "Test Image entry in repo catalogs after delete"

https_proxy=  curl -k http://localhost:5000/v2/_catalog?n=2000 | python -m json.tool

sleep 4

echo "deleting created test repository & test image"

docker rm registry -f

docker rmi ${registry}/${name} -f


