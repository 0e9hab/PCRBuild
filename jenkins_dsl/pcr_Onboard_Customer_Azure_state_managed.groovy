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
	string(name: 'Branch', defaultValue: 'master', description: 'Application Branch or Tag to be deployed')
        choice(name: 'country_code', choices: ['GB-Commercial', 'GB-Official', 'IT-Commercial', 'IE-Commercial', 'ES-Commercial', 'PT-Commercial', 'AL-Commercial'], description: 'Provide the regional tooling account')
        string(name: 'customer_domain_name', defaultValue: '', description: 'Globally unique domain name of the customer')
        validatingString(name: 'customer_subscription_owner_firstname', defaultValue: '', failedValidationMessage: 'String with no space', regex: '^(^$|\\S)+$', description: 'Firstname of the user to be added to the subscription owner group member list')
        validatingString(name: 'customer_subscription_owner_lastname', defaultValue: '', failedValidationMessage: 'String with no space', regex: '^(^$|\\S)+$', description: 'Lastname of the user to be added to the subscription owner group member list')
        validatingString(name: 'customer_subscription_contributor_firstname', defaultValue: '', failedValidationMessage: 'String with no space', regex: '^(^$|\\S)+$', description: 'Firstname of the user to be added to the subscription contributor group member list')
        validatingString(name: 'customer_subscription_contributor_lastname', defaultValue: '', failedValidationMessage: 'String with no space', regex: '^(^$|\\S)+$', description: 'Lastname of the user to be added to the subscription contributor group member list')
        validatingString(name: 'customer_security_contact_email', defaultValue: '', failedValidationMessage: 'Invalid email address', regex: '^$|^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$', description: 'Security Alert Recipient (email address)')
        validatingString(name: 'customer_service_health_contact_email', defaultValue: '', failedValidationMessage: 'Invalid email address', regex: '^$|^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$', description: 'Azure Service Health Alert Recipient (email address)')
        validatingString(name: 'customer_budget_contact_email', defaultValue: '', failedValidationMessage: 'Invalid email address', regex: '^$|^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$', description: 'Budget Alert Recipient(email address)')
        validatingString(name: 'budgeted_amount', defaultValue: '', failedValidationMessage: 'Budget should be a valid number', regex: '^[0-9]*', description: 'The Budgeted amount')
        string(name: 'vodafone_support_primary_L2_username', defaultValue: '', description: 'Username of Level2 primary support user')
        string(name: 'vodafone_support_primary_L2_useremail', defaultValue: '', description: 'Email id of Level2 primary support user')
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
                checkout([$class: 'GitSCM', branches: [[name: Branch]],
                          userRemoteConfigs: [[ credentialsId: 'vod-srv-github', url: 'https://github.vodafone.com/VFGVBPS-CloudEdge/pcr-uk-azure.git' ]]
                ])
            }
        }
	    stage ("Intializing Providers"){
		steps{
		    sh '''
			set +x
                        az login --service-principal -u ${customer_client_id} -p ${customer_client_secret} --tenant ${customer_tenant_id}
                        set -x
                        az account set -s ${customer_subscription_id}
                        az provider register --namespace 'Microsoft.KeyVault'
			az provider register --namespace 'Microsoft.Network'
			az provider register --namespace 'Microsoft.Advisor'
			az provider register --namespace 'Microsoft.Storage'
			az provider register --namespace 'Microsoft.OperationalInsights'
			az provider register --namespace 'Microsoft.PolicyInsights'
			az provider register --namespace 'Microsoft.Kusto'
			az provider register --namespace 'Microsoft.ManagedIdentity'
			az provider register --namespace 'Microsoft.Security'
			az provider register --namespace 'Microsoft.ADHybridHealthService'
			az provider register --namespace 'Microsoft.Insights'
			az provider register --namespace 'Microsoft.Authorization'
			sleep 30
		    '''
		    }
	    }
        stage ('Configure Customer Account') {
            steps{
                sh '''
				 cd cmdb/customer
				 terraform init
				 terraform workspace select ${customer_domain_name} || terraform workspace new ${customer_domain_name}
				 set +x
				 terraform ${Action} -var "country_code=${country_code}" -var "company_name=${customer_domain_name}" -var "customer_subscription_owner_firstname=${customer_subscription_owner_firstname}" -var "customer_subscription_owner_lastname=${customer_subscription_owner_lastname}" -var "customer_security_contact_email=${customer_security_contact_email}" -var "customer_service_health_contact_email=${customer_service_health_contact_email}" -var "customer_budget_contact_email=${customer_budget_contact_email}" -var "customer_subscription_id=${customer_subscription_id}" -var "customer_client_id=${customer_client_id}" -var "customer_tenant_id=${customer_tenant_id}" -var "customer_client_secret=${customer_client_secret}" -var "budget_amount=${budgeted_amount}" -var "vodafone_support_primary_L2_username=${vodafone_support_primary_L2_username}" -var "vodafone_support_primary_L2_useremail=${vodafone_support_primary_L2_useremail}" -var "customer_subscription_contributor_firstname=${customer_subscription_contributor_firstname}" -var "customer_subscription_contributor_lastname=${customer_subscription_contributor_lastname}"
				 set -x
				 '''
            }
        }
        stage('Upload build output to S3') {
            steps{
                script{
                    sh '''
                        set +x
                        az login --service-principal -u ${customer_client_id} -p ${customer_client_secret} --tenant ${customer_tenant_id}
                        set -x
                        az account set -s ${customer_subscription_id}
                        az resource list >>resource_list.json
                    '''
                    withAWS(){
                        s3Upload(file: 'resource_list.json', bucket: 'cae-mgmt-pcr-build', path: 'azure/' + env.customer_subscription_id + '/resource_list.json', kmsId: 'a7f8217c-62ac-4dc4-9859-92af2cee0eec')
                    }
                }
            }
        }
    }
}
