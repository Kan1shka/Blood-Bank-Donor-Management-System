-- ------------------------------------------------------
-- BLOOD BANK MANAGEMENT SYSTEM
-- ------------------------------------------------------
CREATE DATABASE IF NOT EXISTS BloodBankDB;
USE BloodBankDB;
-- ------------------------------------------------------
-- 1. STAFF TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin','operator') NOT NULL DEFAULT 'operator',
    phone VARCHAR(15),
    CHECK (LENGTH(phone) >= 10)
);
-- ------------------------------------------------------
-- 2. HOSPITAL TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Hospital (
    hospital_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20)
);
-- ------------------------------------------------------
-- 3. DONOR TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Donor (
    donor_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_code VARCHAR(20) UNIQUE,
    name VARCHAR(100) NOT NULL,
    gender ENUM('M','F','Other'),
    age INT CHECK(age BETWEEN 18 AND 65),
    blood_group ENUM('A+','A-','B+','B-','O+','O-','AB+','AB-') NOT NULL,
    phone VARCHAR(15),
    city VARCHAR(50),
    last_donation DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (LENGTH(phone) >= 10)
);
-- ------------------------------------------------------
-- 4. CAMP TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Camp (
    camp_id INT AUTO_INCREMENT PRIMARY KEY,
    camp_name VARCHAR(150),
    camp_date DATE,
    location VARCHAR(150),
    organizer VARCHAR(150)
);
-- ------------------------------------------------------
-- 5. CAMP_DONOR TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Camp_Donor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT NOT NULL,
    camp_id INT NOT NULL,
    registration_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (donor_id)
    REFERENCES Donor(donor_id)
    ON DELETE CASCADE,
    
    FOREIGN KEY (camp_id)
    REFERENCES Camp(camp_id)
    ON DELETE CASCADE
);
-- ------------------------------------------------------
-- 6. BLOOD UNIT TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Blood_Unit (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    unit_code VARCHAR(30) UNIQUE NOT NULL,
    donor_id INT,

    blood_group ENUM('A+','A-','B+','B-','O+','O-','AB+','AB-') NOT NULL,

    component ENUM('Whole','RBC','Plasma','Platelets')
    DEFAULT 'Whole',

    collection_date DATE,
    expiry_date DATE,

    status ENUM('available','reserved','issued','expired')
    DEFAULT 'available',

    FOREIGN KEY (donor_id)
    REFERENCES Donor(donor_id)
);
-- ------------------------------------------------------
-- 7. BLOOD REQUEST TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Blood_Request (
    request_id INT AUTO_INCREMENT PRIMARY KEY,

    request_code VARCHAR(40) UNIQUE,

    requester_type ENUM('hospital','patient')
    NOT NULL,

    requester_id INT,

    blood_group VARCHAR(5) NOT NULL,

    units_required INT NOT NULL CHECK(units_required > 0),

    request_status ENUM('pending','approved','rejected','completed')
    DEFAULT 'pending',

    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (requester_id)
    REFERENCES Hospital(hospital_id)
);
-- ------------------------------------------------------
-- 8. BLOOD ISSUE TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Blood_Issue (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,

    request_id INT NOT NULL,
    unit_id INT NOT NULL,
    issued_by INT,

    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (request_id)
    REFERENCES Blood_Request(request_id),

    FOREIGN KEY (unit_id)
    REFERENCES Blood_Unit(unit_id),

    FOREIGN KEY (issued_by)
    REFERENCES Staff(staff_id)
);
-- ------------------------------------------------------
-- 9. INVENTORY LOG TABLE
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS Inventory_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,

    action_type ENUM('add','reserve','issue','expire','delete'),

    unit_code VARCHAR(30),
    blood_group VARCHAR(5),

    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    performed_by INT,

    FOREIGN KEY (performed_by)
    REFERENCES Staff(staff_id)
);
-- ------------------------------------------------------
-- SAMPLE DATA
-- ------------------------------------------------------

INSERT INTO Staff(name, username, password, role, phone)
VALUES
('Admin User','admin',SHA2('adminpass',256),'admin','9999999999'),

('Operator1','op1',SHA2('oppass',256),'operator','8888888888');

INSERT INTO Hospital(name,address,phone)
VALUES
('City Hospital','Sector 15, City','7777777777'),

('Metro Hospital','Main Road, City','6666666666');

INSERT INTO Donor(
donor_code,name,gender,age,blood_group,
phone,city,last_donation
)
VALUES

('DNR1001','Amit Sharma','M',30,'A+',
'9876543210','Delhi','2024-12-01'),

('DNR1002','Riya Singh','F',22,'O+',
'9123456780','Noida',NULL),

('DNR1003','Karan Verma','M',35,'B+',
'9012345678','Delhi','2024-11-20');

INSERT INTO Camp(
camp_name,camp_date,location,organizer
)
VALUES
('Nov Health Camp','2024-11-10',
'Community Hall','Red Cross');

INSERT INTO Camp_Donor(donor_id,camp_id)
VALUES
(1,1),
(2,1);

INSERT INTO Blood_Unit(
unit_code, donor_id, blood_group,
component, collection_date,
expiry_date, status
)
VALUES

('U1001',1,'A+','RBC',
'2024-12-02','2025-01-02','available'),

('U1002',2,'O+','Whole',
'2024-12-05','2025-01-05','available'),

('U1003',3,'B+','Plasma',
'2024-11-21','2024-12-21','available');

INSERT INTO Blood_Request(
request_code, requester_type,
requester_id, blood_group,
units_required, request_status
)
VALUES
('REQ01','hospital',1,'A+',1,'pending');

-- ------------------------------------------------------
-- FUNCTION
-- ------------------------------------------------------

DROP FUNCTION IF EXISTS DaysLeft;

DELIMITER $$

CREATE FUNCTION DaysLeft(expDate DATE)
RETURNS INT
DETERMINISTIC

BEGIN
    RETURN DATEDIFF(expDate, CURDATE());
END $$

DELIMITER ;

-- ------------------------------------------------------
-- STORED PROCEDURE
-- ------------------------------------------------------

DROP PROCEDURE IF EXISTS GetAvailableUnits;

DELIMITER $$

CREATE PROCEDURE GetAvailableUnits(IN bg VARCHAR(5))

BEGIN

    SELECT
        unit_id,
        unit_code,
        expiry_date,
        status

    FROM Blood_Unit

    WHERE blood_group = bg
    AND status = 'available';

END $$

DELIMITER ;

-- ------------------------------------------------------
-- TRIGGERS
-- ------------------------------------------------------

DROP TRIGGER IF EXISTS trg_expire_insert;
DROP TRIGGER IF EXISTS trg_expire_update;
DROP TRIGGER IF EXISTS trg_update_issue_status;
DROP TRIGGER IF EXISTS trg_prevent_expired_issue;
DROP TRIGGER IF EXISTS trg_inventory_add;

DELIMITER $$

-- Auto-expire on insert
CREATE TRIGGER trg_expire_insert
BEFORE INSERT ON Blood_Unit
FOR EACH ROW

BEGIN

    IF NEW.expiry_date < CURDATE() THEN
        SET NEW.status = 'expired';
    END IF;

END $$

-- Auto-expire on update
CREATE TRIGGER trg_expire_update
BEFORE UPDATE ON Blood_Unit
FOR EACH ROW

BEGIN

    IF NEW.expiry_date < CURDATE() THEN
        SET NEW.status = 'expired';
    END IF;

END $$

-- Prevent issuing expired blood
CREATE TRIGGER trg_prevent_expired_issue
BEFORE INSERT ON Blood_Issue
FOR EACH ROW

BEGIN

    DECLARE exp DATE;

    SELECT expiry_date
    INTO exp
    FROM Blood_Unit
    WHERE unit_id = NEW.unit_id;

    IF exp < CURDATE() THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Cannot issue expired blood unit';

    END IF;

END $$

-- Update status after issue
CREATE TRIGGER trg_update_issue_status
AFTER INSERT ON Blood_Issue
FOR EACH ROW

BEGIN

    UPDATE Blood_Unit
    SET status = 'issued'
    WHERE unit_id = NEW.unit_id;

END $$

-- Auto inventory log
CREATE TRIGGER trg_inventory_add
AFTER INSERT ON Blood_Unit
FOR EACH ROW

BEGIN

    INSERT INTO Inventory_Log(
        action_type,
        unit_code,
        blood_group
    )

    VALUES(
        'add',
        NEW.unit_code,
        NEW.blood_group
    );

END $$

DELIMITER ;

-- ------------------------------------------------------
-- VIEWS
-- ------------------------------------------------------

CREATE OR REPLACE VIEW Available_Stock AS

SELECT
    blood_group,
    component,
    COUNT(*) AS total_units

FROM Blood_Unit

WHERE status='available'

GROUP BY blood_group, component;

CREATE OR REPLACE VIEW Donor_History AS

SELECT
    d.name,
    d.blood_group,
    b.unit_code,
    b.collection_date

FROM Donor d

JOIN Blood_Unit b
ON d.donor_id = b.donor_id;

-- ------------------------------------------------------
-- TEST FUNCTION
-- ------------------------------------------------------

SELECT 'FUNCTION OUTPUT:' AS Section;

SELECT
    unit_code,
    expiry_date,
    DaysLeft(expiry_date) AS days_remaining

FROM Blood_Unit;

-- ------------------------------------------------------
-- TEST PROCEDURE
-- ------------------------------------------------------

SELECT 'PROCEDURE OUTPUT (A+):' AS Section;
CALL GetAvailableUnits('A+');

SELECT 'PROCEDURE OUTPUT (O+):' AS Section;
CALL GetAvailableUnits('O+');

-- ------------------------------------------------------
-- TEST TRIGGERS
-- ------------------------------------------------------

INSERT INTO Blood_Unit(
unit_code,
donor_id,
blood_group,
component,
collection_date,
expiry_date
)

VALUES(
'UTEST1',
1,
'A+',
'Whole',
'2024-01-01',
'2024-01-01'
);

SELECT 'TRIGGER INSERT TEST:' AS Section;

SELECT *
FROM Blood_Unit
WHERE unit_code='UTEST1';

UPDATE Blood_Unit
SET expiry_date='2024-01-01'
WHERE unit_code='U1002';

SELECT 'TRIGGER UPDATE TEST:' AS Section;

SELECT *
FROM Blood_Unit
WHERE unit_code='U1002';

-- ------------------------------------------------------
-- TEST BLOOD ISSUE
-- ------------------------------------------------------

INSERT INTO Blood_Issue(
request_id,
unit_id,
issued_by
)

VALUES(
1,
1,
1
);

SELECT 'BLOOD ISSUE STATUS UPDATE:' AS Section;

SELECT *
FROM Blood_Unit
WHERE unit_id=1;

-- ------------------------------------------------------
-- DISPLAY TABLES
-- ------------------------------------------------------

SELECT 'STAFF TABLE';
SELECT * FROM Staff;

SELECT 'HOSPITAL TABLE';
SELECT * FROM Hospital;

SELECT 'DONOR TABLE';
SELECT * FROM Donor;

SELECT 'CAMP TABLE';
SELECT * FROM Camp;

SELECT 'CAMP_DONOR TABLE';
SELECT * FROM Camp_Donor;
	
SELECT 'BLOOD UNIT TABLE';
SELECT * FROM Blood_Unit;

SELECT 'BLOOD REQUEST TABLE';
SELECT * FROM Blood_Request;

SELECT 'BLOOD ISSUE TABLE';
SELECT * FROM Blood_Issue;

SELECT 'INVENTORY LOG TABLE';
SELECT * FROM Inventory_Log;

-- ------------------------------------------------------
-- DISPLAY VIEWS
-- ------------------------------------------------------

SELECT 'AVAILABLE STOCK VIEW';
SELECT * FROM Available_Stock;

SELECT 'DONOR HISTORY VIEW';
SELECT * FROM Donor_History;
