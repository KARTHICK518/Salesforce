# Salesforce - WhatNext Vision Motors

Salesforce DX Project for **WhatNext Vision Motors** automotive management platform, designed to manage vehicles, dealers, customer orders, test drive scheduling, and service requests.

## 📋 Project Overview

This project implements an end-to-end automotive dealership and service management solution on Salesforce:
- **Vehicle Management (`Vehicle__c`)**: Vehicle catalog, models, specifications, and availability.
- **Customer Management (`Vehicle_Customer__c`)**: Customer profiles, preferences, and interaction history.
- **Dealership Network (`Vehicle_Dealer__c`)**: Partner dealer locations, inventory allocation, and dealer management.
- **Vehicle Orders (`Vehicle_Order__c`)**: Purchase orders, sales pipeline, approval workflows, and order fulfillment.
- **Test Drive Scheduling (`Vehicle_Test_Drive__c`)**: Test drive bookings, customer feedback, and vehicle assignment.
- **Service Requests (`Vehicle_Service_Request__c`)**: Maintenance schedules, repair tickets, and customer support.

Project documentation and design specifications can be found in [`Documentation/Project-Documentation.pdf`](Documentation/Project-Documentation.pdf).

---

## 🛠️ Salesforce DX Project

Salesforce DX is a development approach that brings source-driven development, team collaboration, and continuous integration to the Salesforce Platform. Instead of working directly in an org through a web browser, you work with metadata as source files in a local DX project, track changes in version control, and deploy through automated processes.

### Prerequisites

Before you start, make sure you have:

- **Salesforce CLI** - Download from [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli).
- **VS Code with Salesforce Extension Pack** - See [Installation Instructions](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/install.html).
- **A development org** - Sign up for a free Developer Edition org [here](https://developer.salesforce.com/signup).

### Project Structure

- **`force-app/main/default/`** - Salesforce metadata source files (Objects, Fields, Layouts, Triggers, Tabs, etc.).
- **`manifest/package.xml`** - Manifest file listing all metadata components.
- **`Documentation/`** - Project documentation and specifications.
- **`config/`** - Scratch org definitions and project settings.
- **`scripts/`** - Apex and SOQL scripts for automation and testing.
- **`sfdx-project.json`** - Project manifest and configuration.

### Common Salesforce CLI Commands

- Authorize an org:
  ```bash
  sf org login web
  ```
- Deploy metadata to your org:
  ```bash
  sf project deploy start
  ```
- Retrieve metadata from your org:
  ```bash
  sf project retrieve start
  ```
- Run Apex tests:
  ```bash
  sf apex run test
  ```
