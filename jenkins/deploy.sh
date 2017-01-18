#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

###############################################################################

set -euo pipefail
set -x

# JENKINS_USERNAME
# JENKINS_PASSWORD
# CRED_GITHUB_PERSONAL_ACCESS_TOKEN
# CRED_SERVICE_PRINCIPAL_CLIENT_ID
# CRED_SERVICE_PRINCIPAL_CLIENT_SECRET
# CRED_SUBSCRIPTION_ID
# CRED_TENANT_ID
[[ ! -z "${JENKINS_USERNAME:-}" ]] || (echo "Must specify JENKINS_USERNAME" && exit -1)
[[ ! -z "${JENKINS_PASSWORD:-}" ]] || (echo "Must specify JENKINS_PASSWORD" && exit -1)

WORKDIR="$(mktemp -d)"
#trap "rm -rf \"${WORKDIR}\"" EXIT


# Deploy Jenkins on Kubernetes
envsubst<"${DIR}/azjenkins.k8s.yaml.in" >"${WORKDIR}/azjenkins.k8s.yaml"
envsubst<"${DIR}/options" >"${WORKDIR}/options"
envsubst<"${DIR}/init.groovy" >"${WORKDIR}/init.groovy"
kubectl create ns jenkins || true
kubectl delete secret jenkins --namespace=jenkins || true
kubectl create secret generic jenkins --from-file="${WORKDIR}/options" --namespace=jenkins
kubectl apply -f "${WORKDIR}/azjenkins.k8s.yaml"

#sleep 10
# wait for pod



#exit 0

curl --fail http://localhost:8080/jnlpJars/jenkins-cli.jar > "${WORKDIR}/cli.jar"
function cli() {
	command=$1
	shift 1
	java -jar "${WORKDIR}/cli.jar" \
		-s http://localhost:8080/ \
		$command \
		--username=${JENKINS_USERNAME} \
		--password=${JENKINS_PASSWORD} \
		"${@}"
}


#envsubst<"${DIR}/init.groovy" >"${WORKDIR}/init.groovy"
#cli groovy "${WORKDIR}/init.groovy"


# Add secrets
#foreach cred in "${DIR}/creds"; do
#	cred_file="$(mktemp)"

#	envsubst <"${cred}" >"${cred_file}"
#	cli create-secret-from-xml "${cred_file}"
#done

# Install plugins
# (this comes last because it restarts and not sure if CLI blocks for
#  restart to finish)
cli install-plugin \
	ansicolor \
	blueocean \
	branch-api \
	credentials-binding \
	credentials \
	cloudbees-folder \
	git-client \
	git \
	github-api \
	github-oauth \
	github \
	job-dsl \
	kubernetes \
	matrix-auth \
	plain-credentials \
	scm-api \
	workflow-aggregator \
	ws-cleanup \
	-restart

# Configure seed job
jobdsldir="$(mktemp -d)"
(
	cd "${jobdsldir}"
	git clone "https://github.com/sheehan/job-dsl-gradle-example" .
	rm -rf jobs
	cp -a "${DIR}/jenkins/jobs" .
	./gradlew rest \
		-Dpattern=./jobs/seedjob.groovy \
		-DbaseUrl="${JENKINS_URL}" \
		-Dusername="${JENKINS_USERNAME}" \
		-Dpassword="${JENKINS_PASSWORD}"
)

