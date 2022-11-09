## #####################################
##
## Module: Sonar
##
## This makefile contains common instructions to scan projects with SonarQube

## Variables

## SONAR_AUTH_TOKEN is the token you generate to authenticate with your Sonar 
## deployment. You can see how to generate and use one here: 
## https://docs.sonarqube.org/latest/user-guide/user-token/
## THIS TOKEN SHOULD BE KEPT A SECRET
SONAR_AUTH_TOKEN ?=

## SONAR_URL is the URL for your Sonar deployment. While showing this value is 
## not necessarily dangerous, it is recommended that you keep it a secret
SONAR_URL ?=

##
## Sonar Module Targets

## Scans project and sends results to your Sonar deployment
.PHONY: sonar-scan
sonar-scan: | require-SONAR_AUTH_TOKEN require-SONAR_URL require-GO_PROJECT
	docker run \
		--rm \
		--env SONAR_HOST_URL="${SONAR_URL}" \
		--env SONAR_LOGIN="${SONAR_AUTH_TOKEN}" \
		--env SONAR_SCANNER_OPTS="-Dsonar.projectKey=${GO_PROJECT} -Dsonar.sources=. -Dsonar.exclusions=**/*_test.go,**/*.xml,**/*.xsd,**/*.html -Dsonar.tests=. -Dsonar.test.inclusions=**/*_test.go -Dsonar.go.coverage.reportPaths=.cover/cover.out -Dsonar.projectVersion=${VERSION}" \
		--volume "$(CURDIR):/src" \
		--workdir /src \
		sonarsource/sonar-scanner-cli