@Library('conduit@latest') _
env.TERRAFORM_VERSION = '0.14.10'
env.TERRAGRUNT_VERSION = '0.28.19'
env.AUTH_TYPE = 'federation'
String containerImage  = 'registry.test.com/enterprise-devops/aws-d-megatainer'
String containerVersion = '1.0.10'

String branchName = env.BRANCH_NAME
String envName = 'FIXME'
String credentialsId = 'FIXME'
String awsAccountNumber
String awsRoleName
String TerraformVersion = env.TERRAFORM_VERSION
String TerragruntVersion = env.TERRAGRUNT_VERSION
boolean isProductionDeployment = false

if ( branchName == 'master') {
    envName = 'prod'
    credentialsId = 'AWS_FED_CREDS'
    isProductionDeployment = false
    awsAccountNumber = '361987197148'
    awsRoleName = 'HPNNETFLEXJENKINSDEPLOY'
  } else if (branchName == 'test') {
    envName = 'test'
    credentialsId = 'AWS_FED_CREDS'
    isProductionDeployment = false
    awsAccountNumber = '790055516420'
    awsRoleName = 'HPNNETFLEXJENKINSDEPLOY'
  } else {
    envName = 'dev'
    credentialsId = 'AWS_FED_CREDS'
    isProductionDeployment = false
    awsAccountNumber = '845028161735'
    awsRoleName = 'HPNNETFLEXJENKINSDEPLOY'
  }

println("envName=" + envName)
println("credentialsId = " + credentialsId)
println("isProductionDeployment = " + isProductionDeployment)

testBuildFlow {
    cloudName = 'rx-networkflex-openshift-devops1'
    githubConnectionName = 'test-github'
    mattermostWebhook = 'https://mm.sys.test.com/hooks/jacpezzsf7ytjfyiikkdn1onpo'
    phases = [
        [
            lintingTypes    : [
                'plz': [
                    verbosityFlag: '-vvv'
                ]
            ],
            pleaseContainerImage  : "${containerImage}",
            pleaseContainerVersion: "${containerVersion}",
            branchPattern   : '.*',
            sdlcEnvironment : envName,
        ],
        [
            buildType       : 'plz',
            container: [
                image  : "${containerImage}",
                version: "${containerVersion}",
                cpu    : 2000,
                memory : 3815  
            ],
            branchPattern   : 'feature.*|develop|test|master',
            sdlcEnvironment : envName,
            awsFed          : [
                credentialsId: 'AWS_FED_CREDS',
                callPlzFed   : false
            ],
            veracode        : [
                credentialsId           : 'veracode-service-id',
                zipUploadIncludesPattern: true,
                settings                : [
                    applicationName         : 'networkflex-netflex-baseinfra',
                    scanName                : 'networkflex-netflex-baseinfra',
                    teams                   : 'Clientdatacuration',
                    uploadExcludesPattern   : '',
                    uploadIncludesPattern   : 'src/**',
                    zipUploadIncludesPattern: false
                ]
            ],
            sonarQube       : [
                credentialsId       : 'sonarqube-service-id',
                scannerProperties   : [
                    'sonar.projectKey=networkflex-netflex-baseinfra',
                    'sonar.projectName=networkflex-netflex-baseinfra',
                    'sonar.analysis.ciid=networkflex-netflex-baseinfra',
                    'sonar.sources=.',
                    'sonar.inclusions=src/**/*.py',
                ],
            ],
        ],
        [
            awsFed          : [
                credentialsId: 'AWS_FED_CREDS',
                callPlzFed   : true
            ],
            branchPattern   : 'feature.*|develop|test|master',
            sdlcEnvironment : envName,
            container: [
                image  : "${containerImage}",
                version: "${containerVersion}"
            ],
            deploymentType  : 'plz',
            alias           : 'plan_all',
            extraArgs       : envName,
            verbosityFlag   : '-vvv',
            sdlcEnvironment : envName,
            isProductionDeployment: isProductionDeployment,
            withEnv: [
                "TF_VAR_env=${envName}"
                "TF_VAR_account_number=${awsAccountNumber}"
            ]
        ],
        [
            awsFed          : [
                credentialsId: 'AWS_FED_CREDS',
                callPlzFed   : true
            ],
            branchPattern   : 'feature.*|develop|test|master',
            sdlcEnvironment : envName,
            container: [
                image  : "${containerImage}",
                version: "${containerVersion}"
            ],
            deploymentType  : 'plz',
            alias           : 'deploy',
            extraArgs       : envName,
            verbosityFlag   : '-vvv',
            sdlcEnvironment : envName,
            isProductionDeployment: isProductionDeployment,
            withEnv: [
                "TF_VAR_env=${envName}"
                "TF_VAR_account_number=${awsAccountNumber}"
            ]
        ]
    ]
}
