### A proof of concept showing Azure App Service

This POC uses the following App Service Modules.
* [Web App Module](https://github.com/franknaw/azure-simple-app-service-web-app)
* [Function App Module](https://github.com/franknaw/azure-simple-app-service-function)


***
#### Notes
* To run: TF_LOG=debug terraform apply -var-file="poc.tfvars"
* az webapp list-runtimes --linux

