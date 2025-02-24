pipeline{
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '100', daysToKeepStr: '60'))
        disableConcurrentBuilds()
        timestamps()
        ansiColor('xterm')
    }
    parameters{
        choice(name: 'Action', choices: ['plan', 'apply -auto-approve', 'destroy -auto-approve'], description: 'Action to perform')
        string(name: 'customer_domain_name', defaultValue: '', description: 'Globally unique domain name of the customer')
        validatingString(name: 'kyn_guest_user_email', defaultValue: '', failedValidationMessage: 'Invalid email address', regex: '^$|^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$', description: 'Email id of the guest user')
        booleanParam(name: 'IMI_Commerical_add_on', defaultValue: false, description: 'Set true to setup IMI Commercial configurations in the aws account')
        booleanParam(name: 'IMI_UK_Official_add_on', defaultValue: false, description: 'Set true to setup IMI UK Official configurations in the aws account')
        booleanParam(name: 'VBMP_Enterprise_Marketplace_add_on', defaultValue: false, description: 'Set true to setup VBMP configurations in the aws account')
        string(name: 'customer_subscription_id', defaultValue: '', description: '')
        string(name: 'customer_client_id', defaultValue: '', description: '')
        string(name: 'customer_tenant_id', defaultValue: '', description: '')
        password(name: 'customer_client_secret', defaultValue: '', description: '')
    }
    stages{
        stage('Approval On Delete'){
            when {
                environment name: 'Action',
                        value: 'destroy -auto-approve'
            }
            steps{
                timeout(time: 5, unit: "MINUTES"){
                    input message: "Are you sure, you want to delete the configuration?",
                            ok: "Proceed",
                            submitter: 'admin'
                }
                script{
                    echo "Confirmation Received.."
                }
            }
        }
        stage("Checkout IAC Code"){
            steps{
                cleanWs()
                checkout([$class: 'GitSCM', branches: [[name: 'master']],
                          userRemoteConfigs: [[ credentialsId: 'vod-srv-github', url: 'https://github.vodafone.com/VFGVBPS-CloudEdge/pcr-uk-azure.git' ]]
                ])
            }
        }
        stage ('Configure Customer Account') {
            steps{
                sh '''
				 cd cmdb/addons
				 terraform init
				 terraform workspace select ${customer_subscription_id} || terraform workspace new ${customer_subscription_id}
				 set +x
				 terraform ${Action} -var "company_name=${customer_domain_name}" -var "customer_subscription_id=${customer_subscription_id}" -var "customer_client_id=${customer_client_id}" -var "customer_tenant_id=${customer_tenant_id}" -var "customer_client_secret=${customer_client_secret}" -var "imi_commercial_addon=${IMI_Commerical_add_on}" -var "imi_uk_official_addon=${IMI_UK_Official_add_on}" -var "vbmp_addon=${VBMP_Enterprise_Marketplace_add_on}" -var "guestuseremail=${kyn_guest_user_email}"
				 set -x
				 '''
            }
        }
    }
}
