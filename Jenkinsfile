node ( "master" )
{

  def MVN_HOME
  def NEXUS_PROTO = "http"
  def NEXUS_HOST = "nexus.devopsinabox.perficientdevops.com"
  def NEXUS_PORT = "8081"

  stage('Build') {

    git 'https://github.com/Perficient-DevOps/jpetstore-6'
    MVN_HOME = tool 'M3'

    if (isUnix())
    {
      sh "'${MVN_HOME}/bin/mvn' -Dmaven.test.failure.ignore clean package"
    } else {
      bat(/"${MVN_HOME}\bin\mvn" -Dmaven.test.failure.ignore clean package/)
    }

  }

  stage('Publish JUnit Results') {
    junit '**/target/surefire-reports/TEST-*.xml'
    archive 'target/*.jar'
  }

  // Publish version to Nexus
  stage('Publish to Nexus') {
    nexusArtifactUploader artifacts:
      [[artifactId: 'jpetstore', classifier: '', file: 'target/jpetstore.war', type: 'war']],
      credentialsId: 'nexus-admin',
      groupId: 'com.perficient',
      nexusUrl: '${NEXUS_HOST}:${NEXUS_PORT}',
      nexusVersion: 'nexus3',
      protocol: '${NEXUS_HOST}',
      repository: 'petsonline',
      version: '${BUILD_NUMBER}'
    }

  // Publish to UrbanCode Deploy
  stage('Push to UrbanCode Deploy') {
    step([$class: 'UCDeployPublisher',
      siteName: 'deploy.devopsinabox.perficientdevops.com',
      component: [
          $class: 'com.urbancode.jenkins.plugins.ucdeploy.VersionHelper$VersionBlock',
          componentName: 'JPetStore-app',
          delivery: [
              $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeliveryHelper$Push',
              pushVersion: '${BUILD_NUMBER}',
              baseDir: '/var/lib/jenkins/workspace/JPetStore-Demo/target',
              fileIncludePatterns: '*.war',
              fileExcludePatterns: '',
              pushProperties: 'jenkins.server=Local\njenkins.reviewed=false',
              pushDescription: 'Pushed from Jenkins Pipeline',
              pushIncremental: false
              ]
          ]
      ])
  }

  // Trigger deployment
  stage('Deploy to Development') {
    step([$class: 'UCDeployPublisher',
      siteName: 'deploy.devopsinabox.perficientdevops.com',
      deploy: [
          $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeployHelper$DeployBlock',
          deployApp: 'JPetStore',
          deployEnv: 'DEV',
          deployProc: 'Deploy',
          deployVersions: 'JPetStore-app:${BUILD_NUMBER}',
          deployOnlyChanged: false
          ]
      ])
  }

} // end node
