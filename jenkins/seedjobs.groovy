def prefix = "j-"
def repo = "https://github.com/colemickens/acs-engine"
def branchName = "colemickens-msi-jenkins"
def locations = ["westus", "eastus"]

// nest everything in jobs.
// makes dev/test easier, can just wipe out jobs/ and leave seed job intact
// TODO: chris has script for this I think
def d = "acs-engine/jobs"
folder("acs-engine")
folder(d)

class JobDef {
	String jobPrefix
	String clusterDef
	String orchestratorType
	String[] locations
	Map extraEnv
}

jobzz = [
	new JobDef(
		jobPrefix: "k8s-msi",
		clusterDef: "examples/kubernetes.json",
		orchestratorType: "kubernetes",
		locations: ["westus", "eastus"],
		extraEnv: ["ENABLE_MSI":"true"],
	),
]

job("acs-engine/seedjob") {
	scm {
		git {
			remote {
				url(repo)
			}
			branch(branchName)
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

jobzz.each {
	def j = it
	j.locations.each {
		def location = it
		def jobName = "${j.jobPrefix}-${location}"
		d2=d+"pullrequests"
		folder(d2)
		job(d2+"/pr_"+jobName) {
			scm {
				git {
					remote {
						url(repo)
					}
					branch(branchName)
				}
			}
		}
	}
}
