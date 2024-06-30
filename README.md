## Objective

The objective is to call Kong using a REST request (JSON) and receive the response in JSON format.

## Project Overview
This project involves creating a Flask application to serve as a SOAP service, Dockerizing the Flask application, setting up Kong with the kong kong soap request transformer plugin, and defining Kong services and routes to interact with the SOAP service.

## Table of Contents
1. Create a Flask Application
2. Dockerize the Flask Application
3. Create a Custom Kong Image with the soap request transformer Plugin
4. Start Kong Using a Docker Container
5. Create Kong Service and Routes for our SOAP Service
6. Add the Plugin to the Service
7. Testing
    - Testing with curl
    - Testing with Postman

## 1. Create a Flask Application
Develop a Flask application that acts as our SOAP service. This service listens for SOAP requests and sends predefined XML SOAP responses.

## 2. Dockerize the Flask Application
Create a Dockerfile for the Flask application and build the Docker image.

## 3. Create a Custom Kong Image with Soap request transformer Plugin
Create a custom Kong image with your plugin.

## 4. Start Kong Using a Docker Container
Start Kong using a Docker container.

## 5. Create Kong Service and Routes for our SOAP Service
Define the service in Kong that points to your SOAP service. Use the following commands:

```bash
curl -i -X POST http://localhost:8001/services/ \
  --data name=soap-service \
  --data url=http://soap.service.com:5000/soap
```
```bash
curl -i -X POST http://localhost:8001/services/soap-service/routes \
  --data paths[]=/soap-service
```
##6.Add the soap request transformer Plugin to the Service

Add the plugin to the Kong service

```bash
curl -i -X POST http://localhost:8001/services/{service-id}/plugins \
    --data "name=soap-request-transformer" \
    --data "config.method=RxScriptDetail" \
    --data "config.namespace=DefaultNamespace" \
    --data "config.remove_attr_tags=false" \
    --data "config.soap_prefix=soapenv"
```
## 6. Testing

Testing with Postman: Use the postman collection **kong-transformer.postman_collection.json** provided to  test.

Use curl to test sending SOAP requests:

```bash

curl -i -X POST \
  --url http://localhost:8000/soap \
  --header "Content-Type: text/json" \
  --data @request.json
  
```









