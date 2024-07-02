## Objective

The objective is to call Kong using a REST request (JSON) and receive the response in JSON format.

## Demo video
[Watch the video](https://drive.google.com/file/d/18iCC0cLuetUkA3YtLWTuPS5xaTZxnZJ2/view?usp=sharing)

## Steps
1. Run the Flask Application
2. Build Custom Kong Image with the soap request transformer Plugin
3. Start soap-service and Kong Using a Docker Container
4. Create Kong Service and Routes for our SOAP Service
5. Add the Plugin to the Service
6. Testing
7. New Service ?

    - Testing with Postman
    - Testing with curl

## 1. Build the Flask Application
Develop a Flask application that acts as our SOAP service. This service listens for SOAP requests and sends predefined XML SOAP responses.
```bash
cd soap-service
chmod +x start.sh
./start.sh
```

## 2. Build Custom Kong Image with the soap request transformer Plugin
Create a custom Kong image with  soap-request-transformer plugin.

kong-transformer-plugin-Demo-test/Dockerfile
      
```bash
docker build -t custom-kong:3.0 .

```
## 3. Start Kong Using a Docker Container
Start Kong using a Docker container.

## 4. Create Kong Service and Routes for our SOAP Service
kong-transformer-plugin-Demo-test/docker-compose.yml
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
curl -i -X POST http://localhost:8001/services/188cdbc2-09b3-4dc8-8873-263111bf3c4a/plugins \
    --data "name=soap-request-transformer" \
    --data "config.method=RxScriptDetail" \
    --data "config.service_name=soap_service"\

```
## 6. Testing

Testing with Postman: Use the postman collection **kong-transformer.postman_collection.json** provided to  test.

Use curl to test sending JSON requests:

```bash

curl -i -X POST \
  --url http://localhost:8000/soap \
  --header "Content-Type: text/json" \
  --data @request.json
  
```

## 7. New Service ?

In case of a new service, you don't have to worry. All you have to do is:

Add a new elseif in the access.lua file within the transform_json_body_into_soap function for the new service. Assume the service name is: orders_service.

```bash
 if conf.service_name == "soap_service" then
        local soap_doc = soap.encode(encode_args)
        kong.log.debug("Transformed request: " .. soap_doc)
        return true, soap_doc
    elseif  conf.service_name == "orders_service" then
        local soap_doc = soapOrders.encode(encode_args)  
        kong.log.debug("Transformed request: " .. soap_doc)
        return true, soap_doc  
    end

```
Then create you custom soapOrders template.










