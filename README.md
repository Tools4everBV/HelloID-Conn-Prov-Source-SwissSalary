# HelloID-Conn-Prov-Source-SwissSalary

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |
<br />
<p align="center">
  <img src="https://www.tools4ever.nl/connector-logos/swisssalary-logo.png">
</p> 
<br />

Salary and HR System swisssalary.ch

## Introduction

This connector retrieves HR data from the SwissSalary API. You need to allow some field the API is allowed to access in SwissSalary

# SwissSalary API Documentation

## Getting started
To Start with the sync you need to get your API Credentials (client_id and client secret)
You have to request an OAUTH2 token to get access to the data (companies, departments and employees)

### Configuration Settings
Use the configuration.json in the Source Connector on "Custom connector configuration". You can use the created credentials on the Configuration Tab to set the ClientID and ClienSecret.

### Mappings
Use the personMapping_employment.json and contractMapping_employment.json Mappings as example and remove the Fields which you don't need

# HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
