def prefix = "acs-jenkins-msi"
def repo = "https://github.com/colemickens/acs-engine"
def branch = "colemickens-msi-jenkins"
def locations = ["westus", "eastus"]

folder("acs-engine") {
	description("Auto-generated Jenkins jobs for ACS-Engine")
}

job("acs-engine/seedjob") {
	scm {
		git {
			remote {
				url(repo)
			}
			branch(branch)
		}
	}
	triggers {
		cron("* * * * *")
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
			git {
				remote {
					url(repo)
				}
				branch(branch)
			}
		}
	}
}
