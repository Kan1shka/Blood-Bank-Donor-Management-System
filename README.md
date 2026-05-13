# BLOOD BANK AND DONOR MANAGEMENT SYSTEM
The Blood Bank & Donor Management System is designed to automate and organize the records of blood donors, blood units, hospitals, and blood requests. Manual tracking leads to delays, errors, and difficulties in checking real-time availability.

This system provides a centralized database to store donor information, track blood stock, verify expiry dates, manage blood requests, and issue blood units safely. It includes SQL-based implementation for full DBMS features and a Python + SQLite backend for basic CRUD operations and demonstration.

The project shows how database systems can improve reliability, speed, and transparency in life-saving operations like blood management.

## Features
- Donor registration and record management
- Blood unit collection and availability tracking
- Hospital and patient blood request management
- Blood issue and inventory update process
- Expiry tracking using SQL triggers
- Inventory logging for audit and tracking
- Basic CRUD operations through a Python-based backend
- SQL queries, views, functions, and stored procedures for fast data retrieval

## DBMS Concepts Used
- Relational database design
- Normalization up to 3NF
- Primary keys and foreign keys
- Constraints for data integrity
- SQL triggers
- Stored procedures
- User-defined functions
- Views
- CRUD operations
- Transaction and inventory logging

## Tech Stack
- MySQL / phpMyAdmin
- SQLite3
- Python 3
- SQL

# DATABASE DESIGN 
**Core Entities**
•	Staff – Stores admin and operator login details.
•	Hospital – Contains records of hospitals requesting blood.
•	Camp – Stores information about blood donation camps.

**Donor and Blood Management**
•	Donor – Holds personal details and medical information of donors.
•	Camp_Donor – Maps donors who participated in a particular camp.
•	Blood_Unit – Maintains records of collected blood units, including expiry and status.

**Requests and Inventory**
•	Blood_Request – Stores blood requests made by hospitals or patients.
•	Blood_Issue – Tracks the blood units issued to fulfil requests.
•	Inventory_Log – Logs all inventory actions (add, issue, expire, reserve) for audit and tracking.

## Key SQL Components
- `DaysLeft(expiry_date)` function to calculate remaining shelf life of blood units
- `GetAvailableUnits(blood_group)` stored procedure to fetch available blood units
- Triggers to automatically mark expired blood units as expired
- Views for available stock and donor history

## How to Run
1. Download or clone this repository on your system.
2. Open the project folder in VS Code, PyCharm, or any preferred editor.
3. Make sure Python 3 is installed on your system.
4. Run the Python file provided in the project folder.
5. The program will open a menu-driven interface in the terminal.
6. Select the required option from the menu to add, view, update, or manage donor and blood bank records.
7. To test the SQL implementation, open the SQL file in MySQL or phpMyAdmin and execute it.
8. The SQL file will create the required tables, relationships, constraints, triggers, functions, procedures, and views.
9. After execution, you can run sample queries to check blood availability, donor history, inventory logs, and expiry status.

Note: The SQL implementation is mainly for demonstrating DBMS concepts, while the Python backend is used for basic CRUD operations and project demonstration.
