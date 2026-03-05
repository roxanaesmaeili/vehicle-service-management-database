# Vehicle Service Management Database

## Overview
This project implements a relational database for a vehicle service and repair company called **CarCare Hub**.  
The database manages workshop operations such as customer records, vehicle information, service bookings, staff allocation, payments, and parts inventory.

The system was developed as part of the **Database Principles (M21269)** module at the **University of Portsmouth**.

---

## Database Features

The system supports several business operations including:

- Customer and vehicle management
- Workshop service bookings
- Job allocation to technicians and service bays
- Membership management
- Payment and credit tracking
- Parts and supplier management
- Courtesy car bookings
- Customer feedback tracking

---

## Database Design

The database follows **relational database design principles** including:

- Normalisation
- Primary and foreign key relationships
- Data integrity constraints
- Indexing for performance optimisation
- ENUM data types for controlled values

An **Entity Relationship Diagram (ERD)** was created during the design phase to model relationships between entities. :contentReference[oaicite:0]{index=0}

---

## Advanced SQL Features

The database includes advanced SQL functionality such as:

**Views**
- `booking_details` view linking bookings to the correct branch.

**Stored Procedures**
- Automated courtesy car reservation status updates.

**Triggers**
- Validation of credit instalment payments to maintain financial data integrity.

---

## Example Business Queries

The system includes analytical queries for business insights such as:

- Branch performance analysis
- External staff shift coverage
- Membership popularity analysis
- Courtesy car availability
- Six-month business revenue tracking

These queries help the business monitor operational performance and financial trends. :contentReference[oaicite:1]{index=1}

---

## Technologies Used

- PostgreSQL
- SQL
- Relational Database Design
- ER Modelling

---

## Repository Structure
vehicle-service-management-database
│
├── DatabaseCW.sql
└── README.md


---

## Author

Roxana Esmaeili  
BSc Data Science and Artificial Intelligence  
University of Portsmouth
