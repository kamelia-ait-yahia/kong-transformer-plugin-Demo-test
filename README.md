## Objective

The objective is to call Kong using a REST request (JSON) and receive the response in JSON format.

## Table of Contents
1. Run the Flask Application
2. Build Custom Kong Image with the soap request transformer Plugin
3. Start soap-service and Kong Using a Docker Container
4. Create Kong Service and Routes for our SOAP Service
5. Add the Plugin to the Service
6. Testing
    - Testing with curl
    - Testing with Postman

## 1. Run the Flask Application
Develop a Flask application that acts as our SOAP service. This service listens for SOAP requests and sends predefined XML SOAP responses.
```bash
cd soap-service
chmod +x start.sh
./start.sh
```

## 2. Build Custom Kong Image with the soap request transformer Plugin
Create a custom Kong image with  soap-request-transformer plugin.

kong-transformer-plugin-Demo-test/
      ├── Dockerfile
```bash
docker build -t custom-kong:3.0 .

```
## 3. Start Kong Using a Docker Container
Start Kong using a Docker container.
kong-transformer-plugin-Demo-test/
      ├── docker-compose.yml
```bash
docker compose up -d
```

## 4. Create Kong Service and Routes for our SOAP Service
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
## 5.Add the soap request transformer Plugin to the Service

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









