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

  environment
  {
    NEXUS_PROTO = "http"
    NEXUS_HOST = "nexus.devopsinabox.perficientdevops.com"
    NEXUS_PORT = "8081"
    DEPLOY_ENV_TARGET = "Development"
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
  				VERSION = "$version-$BUILD_TIMESTAMP"
  				VERSION_TAG="${VERSION}"
  				ARTIFACT_FILENAME="${APP_ID}.war"
  				// modify build name to match
  				currentBuild.displayName = "${VERSION_TAG}"
  			}
  			sh "echo \"version: $VERSION\""
  			sh "echo \"version_tag: ${VERSION_TAG}\""
  		}
  	}

    stage('Build') {
      steps
      {
        git 'https://github.com/Perficient-DevOps/jpetstore-6'

        script
        {
          def MVN_HOME = tool 'M3'
          if (isUnix())
          {
            sh "'${MVN_HOME}/bin/mvn' -Dmaven.test.failure.ignore clean package"
          } else {
            bat(/"${MVN_HOME}\bin\mvn" -Dmaven.test.failure.ignore clean package/)
          }
        }
      }
    } // end Build

    stage('Publish JUnit Results') {
      steps
      {
        junit '**/target/surefire-reports/TEST-*.xml'
        archive 'target/*.jar'
      }
    }

    // Publish version to Nexus
    stage('Publish to Nexus') {
      steps
      {
        nexusArtifactUploader artifacts:
          [[artifactId: APP_ID, classifier: '', file: "target/${ARTIFACT_FILENAME}", type: 'war']],
          credentialsId: 'nexus-admin',
          groupId: 'com.perficient',
          nexusUrl: "$NEXUS_HOST:$NEXUS_PORT",
          nexusVersion: 'nexus3',
          protocol: NEXUS_PROTO,
          repository: 'petsonline',
          version: VERSION
      }
    }

    // Publish to UrbanCode Deploy
    stage('Push to UrbanCode Deploy') {
      steps
      {
        step([$class: 'UCDeployPublisher',
          siteName: 'deploy.devopsinabox.perficientdevops.com',
          component: [
              $class: 'com.urbancode.jenkins.plugins.ucdeploy.VersionHelper$VersionBlock',
              componentName: 'JPetStore-app',
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
      steps
      {
        sh "echo ${AUTO_DEPLOY}"
        script
        {
          if ( env.AUTO_DEPLOY == 'true' )
          {
            step([$class: 'UCDeployPublisher',
              siteName: 'deploy.devopsinabox.perficientdevops.com',
              deploy: [
                  $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeployHelper$DeployBlock',
                  deployApp: 'JPetStore',
                  deployEnv: "$DEPLOY_ENV_TARGET",
                  deployProc: 'Deploy',
                  deployVersions: 'JPetStore-app:${VERSION}',
                  deployOnlyChanged: false
                  ]
              ])
          }
        }
      }
    }

  } //end stages

} // end node
