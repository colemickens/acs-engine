def githubRepo = "colemickens/acs-engine"
def repoUrl = "https://github.com/colemickens/acs-engine"
def branchName = "colemickens-msi-jenkins"
def locations = ["westus", "eastus"]

def githubCred = "github_pat"
def githubAdmins = ['colemickens',]

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

prJobs = [
	/*new JobDef(
		jobPrefix: "k8s-msi",
		clusterDef: "examples/kubernetes.json",
		orchestratorType: "kubernetes",
		locations: ["westus", "eastus"],
		extraEnv: ["ENABLE_MSI":"true"],
	),*/
	new JobDef(
		jobPrefix: "k8s",
		clusterDef: "examples/kubernetes.json",
		orchestratorType: "kubernetes",
		locations: ["westus2"],
		extraEnv: [:],
	),
]
regularJobs = prJobs

job("acs-engine/seedjob") {
	scm {
		git {
			remote {
				github(githubRepo)
				credentials(githubCred)
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

// Setup the "regular" jobs
regularJobs.each {
	def jobName = "${j.jobPrefix}-${location}"
	job(d+"/"+jobName) {
		scm {
			git {
				remote {
					github(githubRepo)
					refspec('+refs/pull/*:refs/remotes/origin/pr/*')
					credentials(githubCred)
				}
				branch("master")
			}
		}
		triggers {
			// run it every two hours
			// run it in response to any pushes to master
		}
	}
}


// Setup the PR jobs
prJobs.each {
	def j = it
	j.locations.each {
		def location = it
		def jobName = "${j.jobPrefix}-${location}"
		d2=d+"/pullrequests"
		folder(d2)
		job(d2+"/"+jobName) {
			scm {
				git {
					remote {
						github(githubRepo)
						refspec('+refs/pull/*:refs/remotes/origin/pr/*')
						credentials(githubCred)
					}
					branch("master")
				}
			}
			triggers {
				githubPullRequest {
					admins(githubAdmins)
					cron("* * * * *")
					/*extensions {
						commitStatus {
							completedStatus("SUCCESS", "Woot!")
						}
					}*/
				}
			}
		}
	}
}
