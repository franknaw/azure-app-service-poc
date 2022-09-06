## A proof of concept showing Azure App Service

This POC uses the following App Service Modules.
* [Web App Module](https://github.com/franknaw/azure-simple-app-service-web-app)
* [Function App Module](https://github.com/franknaw/azure-simple-app-service-function)

The project consists of the following subprojects.
* [App Service](./app-service/main.tf)
  * Creates the networking resources, app service environment and service plan
* [App Web](./app-web/main.tf)
  * Uses the "Web App Module" and creates an app web service
* [App Function](./app-function/main.tf)
  * Uses the "App Function Module" and creates an app function service

***
###Provisioning resources


First provision the App Service
* Go to the app-service directory and type the following
  * terraform init
  * terraform apply -var-file="poc.tfvars"


Provision the App Web Service
* Go to the app-web directory and type the following
  * terraform init
  * terraform apply -var-file="../app-service/poc.tfvars"


Provision the Function Service
* Go to the app-function directory and type the following
  * terraform init
  * terraform apply -var-file="../app-service/poc.tfvars"

***
#### Notes
* To enable detailed logging: TF_LOG=debug terraform apply -var-file="poc.tfvars"
* az webapp list-runtimes --linux

