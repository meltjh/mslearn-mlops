region := westeurope
resource_group_name := rg-mt-mslearn
workspace_name := ws-mt-mslearn
subscription_id := cf8cebc1-45e2-4a8e-a4ec-b01521fed8e3
service_principal_name := sp-mt-mslearn

# ----- create resources

create_service_principal:
	az ad sp create-for-rbac \
		--name ${service_principal_name} \
		--role contributor \
		--scopes /subscriptions/${subscription_id}/resourceGroups/${resource_group_name} \
		--sdk-auth

create_jobs:
	az ml job create \
		--file ./src/job.yml \
		--resource-group ${resource_group_name} \
		--workspace-name ${workspace_name}

create_basic_resources:
	az group create -l ${region} --name ${resource_group_name}
	az ml workspace create --name ws-mt-mslearn --resource-group ${resource_group_name}

create_cluster:
	az ml compute create --file ./infra/compute_cluster.yml --resource-group ${resource_group_name} --workspace-name ${workspace_name}

create_data_asset:
	az ml data create \
		-f ./infra/data_asset.yml \
		--resource-group ${resource_group_name} \
		--workspace-name ${workspace_name}

create_all: create_basic_resources create_cluster create_data_asset create_jobs create_service_principal

# ----- delete resources

delete_rg:
	az group delete --name ${resource_group_name} --yes

delete_workspace:
	az ml workspace delete \
		--name ${workspace_name} \
		--resource-group ${resource_group_name} \
		--all-resources --yes --permanently-delete

delete_all: delete_workspace delete_rg