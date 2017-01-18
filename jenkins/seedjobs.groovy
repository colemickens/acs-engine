def prefix = "acs-jenkins-msi"
def repo = "https://github.com/Azure/acs-engine"
def branch = "master"
def locations = ["westus", "eastus"]

job("acs-engine/seedjob") {
	scm {
		git("${repo}", branch)
	}

	steps {
		dsl {
			external('jenkins/seedjobs.groovy')
			removeAction('DISABLE')
		}
	}
}

locations.each {
	def location = it
	def jobName = "acs-engine/${prefix}-${location}"
	job(jobName) {
		scm {
			git("${repo}", branch)
		}
	}
}
