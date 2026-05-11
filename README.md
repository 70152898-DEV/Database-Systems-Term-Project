# Vehicle Dealership Management System

## 1. Project Description
The **Vehicle Dealership Management System** is a relational database solution designed to streamline the core operations of an automotive dealership.  
It digitizes the full vehicle lifecycle—from inventory acquisition to final sale—while maintaining strong data integrity, reducing administrative effort, and improving operational visibility.

## 2. What We Are Building
This project provides a centralized backend database architecture to manage:
- inventory tracking
- personnel and organizational structure
- customer records
- sales and payment transactions

The schema follows a normalized relational design to reduce redundancy and improve reporting/query performance.

---

## 3. Key Features
- **Comprehensive Inventory Tracking**: Track vehicle stock in real time, including chassis number, fuel type, transmission, and availability.
- **Hierarchical Organizational Management**: Link employees to departments and defined roles.
- **Customer Relationship Management (CRM)**: Maintain customer contact details and engagement history.
- **Automated Sales Processing**: Connect customer, vehicle, and salesperson records in unified sale entries.
- **Transaction & Payment Logging**: Log payment methods and amounts tied to specific sales.
- **Data Integrity & Security**: Enforce PK/FK constraints to maintain referential integrity and prevent orphaned records.

---

## 4. Project Outcome
The deliverable is a fully documented, scalable SQL-ready database schema that supports:
1. **Efficiency**: Faster sales processing and inventory updates.
2. **Accuracy**: Reduced manual-entry errors in vehicle and pricing data.
3. **Insight**: Reporting on sales performance, popular brands/models, and revenue trends.

---

## 5. Database Schema Description

### 5.1 Core Operations & Sales

#### SALES
Records each customer purchase transaction.
- `sale_id` (PK): Unique identifier for each sale
- `customer_id` (FK): Customer who made the purchase
- `vehicle_id` (FK): Vehicle sold
- `salesperson_id` (FK): Employee who handled the sale
- `sale_date`: Date of sale
- `total_amount`: Total sale amount
- `payment_status`: Payment state (e.g., Pending, Completed)

#### PAYMENTS
Stores payment transactions for each sale.
- `payment_id` (PK): Unique identifier for each payment
- `sale_id` (FK): Associated sale
- `amount`: Payment amount
- `payment_date`: Date payment was received
- `method`: Payment method (e.g., Cash, Credit, Bank Transfer)

### 5.2 Vehicle & Inventory Management

#### VEHICLES_INVENTORY
Stores all vehicle units in stock or sold.
- `vehicle_id` (PK): Unique vehicle unit ID
- `chassis_no`: Manufacturer serial/chassis number
- `registration_number`: Legal registration/plate number
- `model_id` (FK): Linked vehicle model
- `manufacture_year`: Production year
- `color`: Vehicle color
- `mileage`: Odometer reading
- `fuel_type`: Fuel type (e.g., Petrol, Diesel, Electric)
- `transmission`: Gearbox type (e.g., Automatic, Manual)
- `purchase_price`: Acquisition cost
- `sale_price`: Intended/final sale price
- `status`: Availability (e.g., In Stock, Sold)

#### VEHICLE_MODELS
Defines model-level vehicle data.
- `model_id` (PK): Unique model identifier
- `brand_id` (FK): Linked manufacturer/brand
- `model_name`: Model name

#### VEHICLE_BRANDS
Defines vehicle manufacturers.
- `brand_id` (PK): Unique brand identifier
- `brand_name`: Brand name (e.g., Toyota, Ford)

### 5.3 Customers & Staff

#### CUSTOMERS
Stores customer personal/contact information.
- `customer_id` (PK): Unique customer identifier
- `first_name`: First name
- `last_name`: Last name
- `phone`: Contact number
- `email`: Email address
- `address`: Residential/billing address
- `customer_since`: First engagement date

#### EMPLOYEES
Stores employee records.
- `employee_id` (PK): Unique employee identifier
- `first_name`: First name
- `last_name`: Last name
- `phone`: Contact number
- `email`: Work email address
- `hire_date`: Hiring date
- `salary`: Compensation value
- `department_id` (FK): Assigned department
- `employee_role` (FK): Assigned role

#### DEPARTMENTS
Defines company departments.
- `department_id` (PK): Unique department identifier
- `department_name`: Department name (e.g., Sales, Maintenance)

#### EMPLOYEE_ROLE
Defines employee job roles/titles.
- `role_id` (PK): Unique role identifier
- `role_name`: Role title (e.g., Manager, Sales Associate)

---

## 6. Entity Relationships
- **One-to-Many**: `DEPARTMENTS` → `EMPLOYEES`  
  A department can include many employees; each employee belongs to one department.
- **One-to-Many**: `EMPLOYEE_ROLE` → `EMPLOYEES`  
  A role can be assigned to many employees; each employee has one role.
- **One-to-Many**: `VEHICLE_BRANDS` → `VEHICLE_MODELS`  
  One brand can have many models.
- **One-to-Many**: `VEHICLE_MODELS` → `VEHICLES_INVENTORY`  
  One model can have many physical units.
- **One-to-Many**: `CUSTOMERS` → `SALES`  
  One customer can make multiple purchases.
- **One-to-Many**: `EMPLOYEES` → `SALES`  
  One salesperson can complete many sales.
- **One-to-One**: `VEHICLES_INVENTORY` ↔ `SALES`  
  One vehicle unit can appear in at most one sale. In this schema, each inventory record represents a unique physical unit tracked through first sale; any later buy-back/trade-in should be inserted as a new inventory record.
- **One-to-Many**: `SALES` → `PAYMENTS`  
  A sale can include one or multiple payments.

---

## ER Diagram

<img src="https://github.com/user-attachments/assets/26c3fc4b-5404-4748-a8dc-7950db65644b" alt="Vehicle Dealership Management System ER Diagram">

If the image does not render in your environment, replace the URL above with a repository-hosted diagram file path (for example, in a `/docs` folder).
