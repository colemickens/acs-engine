def prefix = "acs-jenkins-msi"
def repo = "github.com/Azure/acs-engine"
def branch = "master"
def locations = ["westus", "eastus"]

locations.each {
	def location = it.name
	def jobName = "${prefix}-${location}"
	job(jobName) {
		scm {
			git("${repo}", branch)
		}
	}
}
