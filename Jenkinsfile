/*
 Requires:
  - build-timestamp
  - pipeline-utility-steps
  - nexus-artifact-uploader
  - ibm-ucdeploy-publisher - https://developer.ibm.com/urbancode/docs/integrating-jenkins-ibm-urbancode-deploy/

*/

pipeline
{
  agent any
  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10'))
    //timestamps()
  }
  //triggers {}

  environment
  {
    // global server level
    DEPLOY_SERVER = 'deploy.devopsinabox.perficientdevops.com'
    NEXUS_PROTO = "http"
    NEXUS_HOST = "nexus.devopsinabox.perficientdevops.com"
    NEXUS_PORT = "8081"

    // job specific
    GIT_REPO = 'https://github.com/Perficient-DevOps/jpetstore-6'
    NEXUS_CREDSID = 'nexus-admin'
    NEXUS_REPOSITORY = 'petsonline2'
    NEXUS_GROUP = 'com.perficient'
    DEPLOY_ENV_TARGET = "Development"
    DEPLOY_APP_NAME = 'JPetStore'
    DEPLOY_APP_PROCESS = 'Deploy'
    DEPLOY_COMP_NAME = 'JPetStore-app'

  }

  parameters {
    booleanParam (
      name: 'AUTO_DEPLOY',
      defaultValue: false,
      description: 'Post-build deployment by default'
    )
  }

  stages
  {

    stage( "Setup Environment Variables" ) {
      steps{
        script {
          // return http://maven.apache.org/components/ref/3.3.9/maven-model/apidocs/org/apache/maven/model/Model.html
          def pom = readMavenPom file: 'pom.xml'
          def version = pom.getVersion()
          APP_ID = pom.getArtifactId()
          // expecting timestamp to be in yyyyMMdd-HHmmss format
          VERSION = "${version}_${BUILD_TIMESTAMP}"
          VERSION_TAG="${VERSION}"
          ARTIFACT_FILENAME="${APP_ID}.war"
          // modify build name to match
          currentBuild.displayName = "${VERSION_TAG}"
        }
        sh "echo \"version: ${VERSION}\""
        sh "echo \"version_tag: ${VERSION_TAG}\""
      }
    }

    stage('Build') {
      steps
      {
        git GIT_REPO
        sh 'gradle war'
      }
    } // end Build

    stage('Publish JUnit Results') {
      steps
      {
        junit '**/build/surefire-reports/TEST-*.xml'
        archive 'build/*.jar'
      }
    }

    // Publish version to Nexus
    stage('Publish to Nexus') {
      steps
      {
        nexusArtifactUploader artifacts:
          [[artifactId: APP_ID, classifier: '', file: "build/${ARTIFACT_FILENAME}", type: 'war']],
          credentialsId: NEXUS_CREDSID,
          groupId: NEXUS_GROUP,
          nexusUrl: "$NEXUS_HOST:$NEXUS_PORT",
          nexusVersion: 'nexus3',
          protocol: NEXUS_PROTO,
          repository: NEXUS_REPOSITORY,
          version: VERSION
      }
    }

    // Publish to UrbanCode Deploy
    stage('Push to UrbanCode Deploy') {
      steps
      {
        step([$class: 'UCDeployPublisher',
          siteName: DEPLOY_SERVER,
          component: [
              $class: 'com.urbancode.jenkins.plugins.ucdeploy.VersionHelper$VersionBlock',
              componentName: DEPLOY_COMP_NAME,
              delivery: [
                  $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeliveryHelper$Push',
                  pushVersion: VERSION,
                  baseDir: "$WORKSPACE/target",
                  fileIncludePatterns: '*.war',
                  fileExcludePatterns: '',
                  pushProperties: 'jenkins.server=Local\njenkins.reviewed=false',
                  pushDescription: "Pushed from Jenkins Pipeline build ${BUILD_ID}",
                  pushIncremental: false
                  ]
              ]
        ])
      }
    }

    // Trigger deployment
    stage('Deploy to Development') {
      when { expression{ return params.AUTO_DEPLOY } }
      steps
      {
        script
        {
          step([$class: 'UCDeployPublisher',
            siteName: DEPLOY_SERVER,
            deploy: [
                $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeployHelper$DeployBlock',
                deployApp: DEPLOY_APP_NAME,
                deployEnv: DEPLOY_ENV_TARGET,
                deployProc: DEPLOY_APP_PROCESS,
                deployVersions: "${DEPLOY_COMP_NAME}:${VERSION}",
                deployOnlyChanged: false
                ]
            ])
        }
      }
    }

  } //end stages

  // Post build sections available
  // https://jenkins.io/doc/book/pipeline/syntax/#post
  /*
  post {
    always {}
    changed {}
    failure {}
    success {}
    unstable {}
    aborted {}
  }
*/
} // end node
