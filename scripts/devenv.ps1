$pwd = (Get-Location).Path

docker build --pull -t acs-engine .
docker run -it \
	--volume="${pwd}:/gopath/src/github.com/Azure/acs-engine" \
	--env=TERM=xterm-256color \
		acs-engine /bin/bash -l

