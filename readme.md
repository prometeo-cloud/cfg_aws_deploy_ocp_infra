# cfg_aws_deploy_environment

## Description:


## Behaviour:


## Dependencies:

These scripts require Ansible Engine 2.5 or above.  
In addition, the following are required to be installed:

Packages:
- awscli

Python modules:
- boto
- boto3
- pywinrm

The dependencies are installed on the Ansible Control Node by running the `aws_install_prerequisites` role.  
If the role fails due to Python `setuptools` being an older version, then install the Python modules manually.

## Configuration:

A list of the external variables used by the playbook (see first table).

| Variable | Description | Example | Where set |
|-----|-----|-----|-----|
| **aws_region** | AWS region,  Set the required region by editing the `group_vars/all/vars` file, using the `regions` data structure. | Default region is London: `{{ regions.eu.london }}` See [AWS regions](http://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region) | group_vars/all/vars |
| **rhel_image** | AWS AMI,  Set the required AMI by editing the `group_vars/all/vars` file. | Default AMI is London: `{{ london }}` | group_vars/all/vars |
| **vault_access_key** | AWS access key (see [vault.example](group_vars/all/vault.example) | AKIAIOSFODNN7EXAMPLE | group_vars/all/vault |
| **vault_secret_key** | AWS secret key (see [vault.example](group_vars/all/vault.example) | wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY | group_vars/all/vault |
| **master_cert** | Master Certificate | `arn:partition:service:region:account-id:resourcetype/resource` | group_vars/all/vars |
| **apps_router_cert** | Application/Router Certificate | `arn:partition:service:region:account-id:resourcetype/resource` | group_vars/all/vars |
| **organisation** | Organisation ID for Red Hat subscriptions (required to install packages - see [vault.example](group_vars/all/vault.example) | `1234567` | inventories/<inventory_name>/group_vars/aws/vault |
| **activation_key** | Red Hat activation key (required to install packages- see [vault.example](group_vars/all/vault.example)) | `YOUR-KEY` | inventories/<inventory_name>/group_vars/aws/vault |
| **user_keys_latest** | List of user public keys for access to EC2 instances |  | [user_keys_latest](files/user_keys_latest) |

The AWS resource variables are defined in the `groups_vars/box/aws` or `group_vars/all/aws` folder in an inventory.  
Inventories can be found in the top level [inventories](inventories) folder.  
The files contain information on the resources as follows (note: not all inventories contain all of the files listed in the second table).

| Filename | Resources |
|-----|-----|
| ec2_instances | Details of the EC2 Instances to launch |
| elbs | Details of the Elastic Load Balancers |
| igws | Details of the Internet Gateways |
| natgws | Details of the NAT Gateways |
| project | Details of the project (for IAAS) |
| route_tables | Details of the Route Tables |
| security_groups | Details of the Security Groups |
| subnets | Details of the Subnets |
| tags | Details of the resource tags (for R2) |
| target_groups | Details of Target Groups |
| vars | General variables (user names etc.) |
| vpc_peers | Details of VPC Peering Connections |
| vpcs | Details of Virtual Private Clouds |

Example ssh config files can be found for [ocp-test-01](files/config.d/ocp-test-01) in the `files/config.d` folder.  
The relevant file will need to be copied to the Ansible Control Node and the domain names changed to match that being used when deploying the AWS environment.


## Authentication:

Authentication is carried out using AWS keys as follows:

| Host | Description |
|-----|-----|
| Ansible Control Node | Copy the `group_vars/all/vault.example` file and rename as `group_vars/all/vault`.  Update the AWS keys in the `vault` file and encrypt it using `ansible-vault`. |
| Ansible Tower | Ansible Tower sets the AWS credentials (keys) as environment variables.  In `group_vars/all/vars` uncomment the environment variable keys and comment out all other keys. |

The AWS keys are used to create the `~/.aws/config` file for the AWS cli by the role `aws_manage_config`.  
This role should be run first to create the file at the start of the script, and last, to delete the file when the script is finished (see [site.yml](site.yml).)

A list of authorised user public keys is contained in the [files/user_keys_latest](files/user_keys_latest) file.  
By default this is empty.  Add the authorised user public keys to this file before running the scripts.

## Testing:

Testing is currently carried out using an Ansible Control node which will build the environment on AWS. To test, do the following:

1. Clone this role to an Ansible Control node with Ansible Engine 2.5 installed.
3. Set up an AWS account.
4. Generate an AWS key.
5. Set up the AWS key variables in the `vault` file as specified above.
6. Set the AWS region in the `group_vars/all/vars` file (see Configuration for the list of regions).
7. Update the files in the appropriate inventory `aws` folder to match the required AWS environment.
8. Run the `site.yml` playbook (see usage).

Note: a timeout may occur when creating a resource (e.g. a VPC or a subnet).  
If this occurs, logon to the AWS services web page, locate the resource that caused the timeout and manually delete it.  
Once the resource has been deleted, rerun the scripts to complete the environment build.

## Usage:

The following command will run the scripts using the `ocp-test-01` inventory (this will build the AWS environment with all resources prefixed by `TEST`):

```$ ansible-playbook -i inventories/ocp-test-01 site.yml```


