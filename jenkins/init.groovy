import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.*

jenkins = jenkins.model.Jenkins.getInstance()

realm = new HudsonPrivateSecurityRealm();
realm.createAccount("${JENKINS_USERNAME}","${JENKINS_PASSWORD}")

strategy = new FullControlOnceLoggedInAuthorizationStrategy()

jenkins.setSecurityRealm(realm)
jenkins.setAuthorizationStrategy(strategy)
jenkins.save()
