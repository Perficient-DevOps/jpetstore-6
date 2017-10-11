node ( "master" ) {
  def MVN_HOME

  stage('Build') {

    git 'https://github.com/Perficient-DevOps/jpetstore-6'
    MVN_HOME = tool 'M3'

    if (isUnix()) {sh "'${MVN_HOME}/bin/mvn' -Dmaven.test.failure.ignore clean package"}
    else {bat(/"${MVN_HOME}\bin\mvn" -Dmaven.test.failure.ignore clean package/)}
    }

  stage('Publish JUnit Results') {
    junit '**/target/surefire-reports/TEST-*.xml'
    archive 'target/*.jar'
    }

  stage('Publish to Nexus') {
    nexusArtifactUploader artifacts: [[artifactId: 'jpetstore', classifier: '', file: 'target/jpetstore.war', type: 'war']], credentialsId: 'f874c3a9-2332-4efa-9b8c-09b98d8164e2', groupId: 'com.perficient', nexusUrl: '158.85.63.189:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'jenkins-preprod', version: '${BUILD_NUMBER}'
    }

  stage('Push to UrbanCode Deploy') {
    step([$class: 'UCDeployPublisher',
      siteName: 'deploy.devopsinabox.perficientdevops.com',
      component: [
          $class: 'com.urbancode.jenkins.plugins.ucdeploy.VersionHelper$VersionBlock',
          componentName: 'JPetStore-J2EE',
          delivery: [
              $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeliveryHelper$Push',
              pushVersion: '${BUILD_NUMBER}',
              baseDir: '/var/lib/jenkins/workspace/JPetStorePipeline/target',
              fileIncludePatterns: '*.war',
              fileExcludePatterns: '',
              pushProperties: 'jenkins.server=Local\njenkins.reviewed=false',
              pushDescription: 'Pushed from Jenkins Pipeline',
              pushIncremental: false
              ]
          ]
      ])
    }

  stage('Deploy to Development') {
    step([$class: 'UCDeployPublisher',
      siteName: 'deploy.devopsinabox.perficientdevops.com',
      deploy: [
          $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeployHelper$DeployBlock',
          deployApp: 'JPetStore',
          deployEnv: 'Development',
          deployProc: 'JPetStore Deploy',
          deployVersions: 'JPetStore-J2EE:${BUILD_NUMBER}',
          deployOnlyChanged: false
          ]
      ])
    }
  }
