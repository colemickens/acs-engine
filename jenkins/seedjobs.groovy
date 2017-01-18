def prefix = "j-"
def repo = "https://github.com/colemickens/acs-engine"
def branchName = "colemickens-msi-jenkins"
def locations = ["westus", "eastus"]

def d = "acs-engine"
folder(d) {
	description("Auto-generated Jenkins jobs for ACS-Engine")
}

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
		job(d+"/pr_"+jobName) {
			scm { git { remote { url(repo) } branch(branchName) } }
		}
		job(d+"/"+jobName) {
			scm { git { remote { url(repo) } branch(branchName) } }
		}
	}
}
