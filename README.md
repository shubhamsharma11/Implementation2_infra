# Continuous Deployment to Azure with Terraform and Ansible

## Project Overview

This project automates the deployment of a sample application, including a Python frontend and a Redis cache database, on Azure using a CI/CD pipeline. The pipeline is orchestrated through Azure DevOps and utilizes Terraform for infrastructure provisioning, Ansible for configuration management, and Docker for containerization.

## Project Structure

1. **Azure Infrastructure Setup (main.tf):**
    - Creates an Azure Resource Group.
    - Deploys Azure Kubernetes Service (AKS) for container orchestration.
    - Establishes Azure Container Registry (ACR) for Docker image storage.
    - Sets up a virtual network, public IP, network interface, and a virtual machine with boot diagnostics.

2. **CI/CD Pipeline (azure-pipeline.yaml):**
    - Configures a pipeline triggered on changes to the 'main' branch.
    - Installs necessary dependencies, including .NET, Terraform, and Azure CLI.
    - Utilizes Terraform tasks to initialize, plan, validate, and apply infrastructure changes.
    - Implements Azure DevOps tasks for seamless CI/CD integration.

3. **Ansible Configuration:**
    - Copies Ansible deployment YAML file to the Azure virtual machine.
    - Executes a custom script on the virtual machine to initiate deployment.

## Instructions for Use

1. **Prerequisites:**
    - Ensure Azure DevOps is set up with necessary service connections.
    - Update variable values in `variables.tf` for Azure resources and credentials.

2. **Azure DevOps Pipeline:**
    - Configure pipeline triggers and branch policies.
    - Update the pipeline YAML file to match your organization's specific configurations.

3. **Terraform Execution:**
    - Run Terraform commands locally for testing and troubleshooting.
    - Adjust Terraform variable values in `variables.tf` as needed.

4. **Ansible Deployment:**
    - Modify the Ansible deployment YAML (`deploy.yaml`) file according to your application requirements.
    - Customize the Ansible playbook to suit specific configurations.

5. **Documentation:**
    - For additional details on the pipeline stages, consult the inline comments in the Terraform files and the pipeline YAML.

## Notes

- Ensure compliance with company policies regarding resource naming conventions, security, and other relevant guidelines.
- Regularly update secrets and credentials securely using Azure Key Vault or another secure solution.
- Refer to Azure documentation for the latest updates on service features and configurations.

## Disclaimer

This README serves as a general guide and may require adjustments based on your organization's specific requirements and policies. Always adhere to best practices and security measures when implementing CI/CD pipelines and infrastructure automation.
