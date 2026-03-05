-- Contents:
--     Create Statetments
--         Enums
--         Tables
--         Views
--         Event Listeners, Procedures, Functions
--         Indexes
--     Insert Statements
--     Queries



--Create Statements

--Enums
CREATE TYPE bay_type AS ENUM (
  'General Service',
  'Quick Service',
  'Diagnostic',
  'Alignment',
  'Body Repair',
  'Paint Prep',
  'Detailing',
  'Teardown Estimating',
  'Heavy Duty',
  'Electrical', 
  'Hybrid'
);

CREATE TYPE bcomp_type as ENUM ( 
  'Safety Certified',
  'Environmental Compliant',
  'Fire Safety Approved',
  'Equipment Calibrated',
  'Hazmat Ready',
  'OSHA Compliant',
  'ISO Certified',
  'Electrical Safety Checked',
  'Ventilation Approved'
);

CREATE TYPE membership_status as ENUM (
    'Active',
    'Inactive',
    'Suspended',
    'Cancelled'
);

CREATE TYPE book_channel as ENUM (
    'Online',
    'Phone',
    'In-Person',
    'Email'
);

CREATE TYPE book_status as ENUM (
    'Scheduled',
    'Completed',
    'Cancelled',
    'No-Show',
    'Ongoing',
    'Rescheduled',
    'Pending',
    'Renewed'
);

CREATE TYPE mot_status AS ENUM (
    'No Action Needed', 
    'Further Review', 
    'Repair', 
    'Replace'
);

CREATE TYPE credit_status AS ENUM (
    'Pending',
    'Paid',
    'Overdue',
    'Cancelled'
);

CREATE TYPE payment_method AS ENUM (
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Cash',
    'Check',
    'Mobile Payment'
);

CREATE TYPE pay_status AS ENUM (
    'Pending',
    'Completed',
    'Failed',
    'Refunded'
);

CREATE TYPE unit AS ENUM (
    'ML', 
    'L', 
    'KG', 
    'CM', 
    'M',
    'MM',
    'G',
    'Ounce', 
    'UNIT'
);

CREATE TYPE court_status AS ENUM (
    'Available',
    'In Use',
    'Under Maintenance',
    'Reserved',
    'Out of Service'
);


--Tables
--1
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    staff_fname VARCHAR(30) NOT NULL,
    staff_lname VARCHAR(30) NOT NULL,
    staff_addr1 VARCHAR(50) NOT NULL,
    staff_addr2 VARCHAR(50),
    staff_county VARCHAR(50) NOT NULL,
    staff_city VARCHAR(50)  NOT NULL,
    staff_postcode VARCHAR(12) NOT NULL,
    staff_email VARCHAR(255) NOT NULL UNIQUE,
    staff_phone VARCHAR(20) NOT NULL UNIQUE,
    staff_emerg_fname VARCHAR(30) NOT NULL,
    staff_emerg_lname VARCHAR(30) NOT NULL,
    staff_emerg_phone VARCHAR(20) NOT NULL
);

--2
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL,
    role_desc VARCHAR(200) NOT NULL
);

--3 
CREATE TABLE staff_role (
    staff_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (staff_id, role_id),
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (role_id) REFERENCES role (role_id)
);

--4
CREATE TABLE branch (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(40) NOT NULL UNIQUE,
    branch_addr1 VARCHAR(50) NOT NULL,
    branch_addr2 VARCHAR(50),
    branch_county VARCHAR(50) NOT NULL,
    branch_city VARCHAR(50) NOT NULL,
    branch_postcode VARCHAR(12) NOT NULL,
    branch_phone VARCHAR(20) NOT NULL UNIQUE,
    branch_email VARCHAR(250) NOT NULL UNIQUE
);

--5
CREATE TABLE staff_branch (
    sb_branch_id INT NOT NULL,
    sb_staff_id INT NOT NULL,
    sb_role_id INT NOT NULL,
    sb_start_date DATE NOT NULL,
    sb_end_date DATE,
    PRIMARY KEY (sb_branch_id, sb_staff_id),
    FOREIGN KEY (sb_branch_id) REFERENCES branch (branch_id),
    FOREIGN KEY (sb_staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (sb_role_id) REFERENCES role (role_id),
    CHECK (sb_end_date IS NULL OR sb_end_date > sb_start_date)    
);

--6
CREATE TABLE shift (
    shift_id SERIAL PRIMARY KEY,
    shift_branch_id INT NOT NULL,
    shift_start TIMESTAMPTZ NOT NULL,
    shift_end TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (shift_branch_id) REFERENCES branch (branch_id),
    CHECK (shift_end > shift_start)
);

--7
CREATE TABLE staff_shift (
    ss_staff_id INT NOT NULL,
    ss_shift_id INT NOT NULL,
    PRIMARY KEY (ss_staff_id, ss_shift_id),
    FOREIGN KEY (ss_staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (ss_shift_id) REFERENCES shift (shift_id)
);

--8
CREATE TABLE department (
    dep_id SERIAL PRIMARY KEY,
    dep_name VARCHAR(50) NOT NULL UNIQUE,
    dep_desc TEXT
);

--9
CREATE TABLE staff_department (
    sd_staff_id INT NOT NULL,
    sd_dep_id INT NOT NULL,
    PRIMARY KEY (sd_staff_id, sd_dep_id),
    FOREIGN KEY (sd_staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (sd_dep_id) REFERENCES department (dep_id)
);

--10
CREATE TABLE certificate (
    cert_id SERIAL PRIMARY KEY,
    cert_name VARCHAR(100) NOT NULL,
    cert_desc TEXT
);

--11
CREATE TABLE staff_certificate (
    sc_staff_id INT NOT NULL,
    sc_cert_id INT NOT NULL,
    sc_issue_date DATE NOT NULL,
    sc_expiry_date DATE,
    PRIMARY KEY (sc_staff_id, sc_cert_id),
    FOREIGN KEY (sc_staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (sc_cert_id) REFERENCES certificate (cert_id),
    CHECK (sc_expiry_date IS NULL OR sc_expiry_date > sc_issue_date)    
);

--12
CREATE TABLE bay (
    bay_id SERIAL PRIMARY KEY,
    bay_branch_id INT NOT NULL,
    bay_name VARCHAR(50) NOT NULL,
    bay_type bay_type NOT NULL,
    FOREIGN KEY (bay_branch_id) REFERENCES branch (branch_id)
);

--13
CREATE TABLE bay_compliance (
    bcomp_id SERIAL PRIMARY KEY,
    bcomp_bay_id INT NOT NULL,
    bcomp_type bcomp_type NOT NULL,
    bcomp_date DATE NOT NULL,
    bcomp_passed BOOLEAN NOT NULL,
    bcomp_due_date DATE NOT NULL,
    FOREIGN KEY (bcomp_bay_id) REFERENCES bay (bay_id),
    CHECK (bcomp_due_date > bcomp_date)
);

--14
CREATE TABLE courtesy_car (
    court_id SERIAL PRIMARY KEY,
    court_branch_id INT NOT NULL,
    court_reg_num VARCHAR(15) NOT NULL,
    court_make VARCHAR(30) NOT NULL,
    court_model VARCHAR(30) NOT NULL,
    court_year SMALLINT NOT NULL,
    court_status court_status NOT NULL,
    FOREIGN KEY (court_branch_id) REFERENCES branch (branch_id)
);

--15
CREATE TABLE membership_type(
    mtype_id SERIAL PRIMARY KEY,
    mtype_name VARCHAR(30) NOT NULL UNIQUE,
    mtype_discount DECIMAL(4,2) NOT NULL, 
    mtype_courtsey_access BOOLEAN NOT NULL,
    mtype_desc TEXT,
    mtype_fee DECIMAL(10,2) NOT NULL,
    CHECK (mtype_discount BETWEEN 0.01 AND 0.99)
);

--16
CREATE TABLE membership(
    mem_id SERIAL PRIMARY KEY,
    mem_type_id INT NOT NULL,
    mem_start  DATE NOT NULL,
    mem_end DATE NOT NULL,
    mem_status membership_status NOT NULL,
    FOREIGN KEY (mem_type_id) REFERENCES membership_type (mtype_id)
);

--17
CREATE TABLE customer(
    cust_id SERIAL PRIMARY KEY,
    cust_mem_id INT,
    cust_fname VARCHAR(30) NOT NULL,
    cust_lname VARCHAR(30) NOT NULL,
    cust_email VARCHAR(255) UNIQUE,
    cust_phone VARCHAR(15) NOT NULL UNIQUE,
    cust_addr1 VARCHAR(50),
    cust_addr2 VARCHAR(50),
    cust_county VARCHAR(50),
    cust_city VARCHAR(50),
    cust_postcode VARCHAR(15),
    cust_emerg_fname VARCHAR(30),
    cust_emerg_lname VARCHAR(30),
    cust_emerg_phone VARCHAR(15),
    FOREIGN KEY (cust_mem_id) REFERENCES membership (mem_id)
);

--18
CREATE TABLE car_make(
    make_id SERIAL PRIMARY KEY,
    make_name VARCHAR(30) NOT NULL UNIQUE
);

--19
CREATE TABLE car_model(
    model_id SERIAL PRIMARY KEY,
    model_make_id INT NOT NULL,
    model_name VARCHAR(30) NOT NULL,
    model_year SMALLINT NOT NULL,
    model_desc TEXT,
    FOREIGN KEY (model_make_id) REFERENCES car_make (make_id)
);

--20
CREATE TABLE car(
    car_id SERIAL PRIMARY KEY,
    car_model INT NOT NULL,
    car_cust INT NOT NULL,
    car_reg_num VARCHAR(15) NOT NULL,
    car_vin CHAR(17) UNIQUE,
    car_colour VARCHAR(15),
    car_mileage DECIMAL(10,1),
    FOREIGN KEY (car_cust) REFERENCES customer (cust_id),
    FOREIGN KEY (car_model) REFERENCES car_model (model_id)
);

--21
CREATE TABLE booking(
    book_id SERIAL PRIMARY KEY,
    book_car_id INT NOT NULL,
    book_appt_time TIMESTAMPTZ NOT NULL,
    book_timestamp TIMESTAMPTZ NOT NULL,
    book_status book_status NOT NULL,
    book_cost DECIMAL(10,2),
    book_channel book_channel NOT NULL,
    FOREIGN KEY (book_car_id) REFERENCES car (car_id)
);

--22
CREATE TABLE mot(
    mot_id SERIAL PRIMARY KEY,
    mot_car_id INT NOT NULL,
    mot_book_id INT NOT NULL,
    mot_date DATE NOT NULL,
    mot_expiry_date DATE NOT NULL,
    mot_mileage DECIMAL(10,1) NOT NULL,
    mot_engine mot_status NOT NULL,
    mot_reg VARCHAR(15) NOT NULL,
    mot_oil_level DECIMAL(4,2),
    mot_wiper_blades mot_status,
    mot_coolant_level DECIMAL(4,2),
    mot_electrics mot_status,
    mot_brakes mot_status,
    mot_air_conditioning mot_status,
    mot_exterior mot_status,
    FOREIGN KEY (mot_car_id) REFERENCES car (car_id),
    FOREIGN KEY (mot_book_id) REFERENCES booking (book_id),
    CHECK (mot_oil_level BETWEEN 0.01 AND 0.99),
    CHECK (mot_coolant_level BETWEEN 0.01 AND 0.99),
    CHECK (mot_expiry_date > mot_date)
);

--23
CREATE TABLE credit(
    credit_id SERIAL PRIMARY KEY,
    credit_due DATE NOT NULL,
    credit_inst_amount INT NOT NULL,
    credit_inst_pay DECIMAL (10,2) NOT NULL,
    credit_total DECIMAL (15,2) NOT NULL,
    credit_status credit_status NOT NULL,
    credit_amount_due DECIMAL (15,2) NOT NULL
);

--24
CREATE TABLE payment(
    pay_id SERIAL PRIMARY KEY,
    pay_book_id INT NOT NULL,
    pay_type payment_method NOT NULL,
    pay_time TIMESTAMPTZ NOT NULL,
    pay_status pay_status NOT NULL,
    pay_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pay_book_id) REFERENCES booking (book_id)
);

--25
CREATE TABLE payment_credit(
    pc_pay_id INT NOT NULL,
    pc_credit_id INT NOT NULL,
    pc_instalment_no INT NOT NULL,
    PRIMARY KEY (pc_pay_id, pc_credit_id),
    FOREIGN KEY (pc_pay_id) REFERENCES payment (pay_id),
    FOREIGN KEY (pc_credit_id) REFERENCES credit (credit_id)
);

--26
CREATE TABLE refund(
    ref_id SERIAL PRIMARY KEY,
    ref_pay_id INT NOT NULL,
    ref_time TIMESTAMPTZ NOT NULL,
    ref_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ref_pay_id) REFERENCES payment (pay_id)
);

--27
CREATE TABLE supplier(
    sup_id SERIAL PRIMARY KEY,
    sup_addr1 VARCHAR(50) NOT NULL,
    sup_addr2 VARCHAR(50),
    sup_postcode VARCHAR(12) NOT NULL,
    sup_city VARCHAR(50) NOT NULL,
    sup_name VARCHAR(64) NOT NULL,
    sup_email VARCHAR(255) UNIQUE,
    sup_phone VARCHAR(20) NOT NULL UNIQUE,
    sup_website VARCHAR(300),
    sup_vat VARCHAR(9) NOT NULL
);

--28
CREATE TABLE part(
    part_id SERIAL PRIMARY KEY,
    part_man_no VARCHAR(32) NOT NULL,
    part_name VARCHAR(100) NOT NULL,
    part_unit unit NOT NULL,
    part_size DECIMAL(10,2) NOT NULL,
    part_qty INT NOT NULL
);

--29
CREATE TABLE part_supplier(
    ps_sup_id INT NOT NULL,
    ps_part_id INT NOT NULL,
    ps_cost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (ps_sup_id, ps_part_id),
    FOREIGN KEY (ps_sup_id) REFERENCES supplier (sup_id),
    FOREIGN KEY (ps_part_id) REFERENCES part (part_id)
);

--30
CREATE TABLE booking_part(
    bp_book_id INT NOT NULL,
    bp_part_id INT NOT NULL,
    bp_qty INT NOT NULL,
    bp_cost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (bp_book_id, bp_part_id),
    FOREIGN KEY (bp_book_id) REFERENCES booking (book_id),
    FOREIGN KEY (bp_part_id) REFERENCES part (part_id)
);

--31
CREATE TABLE service_type(
    stype_id SERIAL PRIMARY KEY,
    stype_name VARCHAR(64) NOT NULL,
    stype_desc TEXT
);

--32
CREATE TABLE service(
    service_id SERIAL PRIMARY KEY,
    service_type_id INT NOT NULL,
    service_dep_id INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    service_desc TEXT,
    service_labour_cost DECIMAL(10,2) NOT NULL,
    service_duration INTERVAL NOT NULL,
    FOREIGN KEY (service_type_id) REFERENCES service_type (stype_id),
    FOREIGN KEY (service_dep_id) REFERENCES department (dep_id)
);

--33
CREATE TABLE booking_service(
    bs_book_id INT NOT NULL,
    bs_service_id INT NOT NULL,
    bs_date_performed DATE,
    bs_note TEXT,
    PRIMARY KEY (bs_book_id, bs_service_id),
    FOREIGN KEY (bs_book_id) REFERENCES booking (book_id),
    FOREIGN KEY (bs_service_id) REFERENCES service (service_id)
);

--34
CREATE TABLE job_allocation(
    job_id SERIAL PRIMARY KEY,
    job_book_id INT NOT NULL,
    job_staff_id INT NOT NULL,
    job_bay_id INT NOT NULL,
    job_start TIMESTAMPTZ NOT NULL,
    job_end TIMESTAMPTZ,
    job_desc TEXT,
    FOREIGN KEY (job_book_id) REFERENCES booking (book_id),
    FOREIGN KEY (job_staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (job_bay_id) REFERENCES bay (bay_id),
    CHECK (job_end IS NULL OR job_end > job_start)
);

--35
CREATE TABLE feedback(
    fb_id SERIAL PRIMARY KEY,
    fb_book_id INT NOT NULL,
    fb_staff_id INT NOT NULL,
    fb_comment TEXT,
    fb_date TIMESTAMPTZ NOT NULL,
    fb_responded BOOLEAN NOT NULL,
    fb_rating SMALLINT NOT NULL,
    FOREIGN KEY (fb_book_id) REFERENCES booking (book_id),
    FOREIGN KEY (fb_staff_id) REFERENCES staff (staff_id),
    CHECK (fb_rating BETWEEN 1 AND 5)
);

--36
CREATE TABLE courtesy_booking(
    cb_court_id INT NOT NULL,
    cb_book_id INT NOT NULL,
    cb_start_date DATE NOT NULL,
    cb_return_date DATE NOT NULL,
    PRIMARY KEY (cb_court_id, cb_book_id),
    FOREIGN KEY (cb_court_id) REFERENCES courtesy_car (court_id),
    FOREIGN KEY (cb_book_id) REFERENCES booking (book_id),
    CHECK (cb_return_date >= cb_start_date)
);


-- Views

CREATE VIEW booking_details AS 
SELECT
    book_id AS "Booking ID",
    cust_fname || ' ' || cust_lname AS "Customer",
    car_reg_num AS "Car Registration",
    DATE(book_appt_time) AS "Appointment Date",
    TO_CHAR(book_appt_time, 'HH24:MI') AS "Appointment Time",
    DATE(book_timestamp) AS "Booking Date",
    book_status AS "Booking Status",
    book_channel AS "Booking Channel",
    book_cost AS "Booking Cost (£)",
    branch_name AS "Branch"
FROM
    booking
JOIN car
    ON book_car_id = car_id
JOIN customer
    ON car_cust = cust_id
JOIN (
    SELECT DISTINCT ON (job_book_id) -- Booking belongs to the branch where the first Job Allocation took place.
    -- even if it is unlikely that a booking would have job allocations in different branches, this ensures data integrity.
           job_book_id,
           job_bay_id
    FROM job_allocation
    ORDER BY job_book_id, job_start
) as first_allocatons 
ON first_allocatons.job_book_id = book_id
JOIN bay
    ON first_allocatons.job_bay_id = bay_id
JOIN branch
    ON bay_branch_id = branch_id;

-- Event Listeners, Procedures, Functions

-- Procedure to check and set courtesy cars to reserved status on the day they are booked to be taken.
CREATE OR REPLACE PROCEDURE check_reserved_courtesy_cars() -- If it is the date when the car should be taken, it sets its status to reserved.
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE courtesy_car c
    SET status = 'reserved'
    FROM courtesy_booking b
    WHERE c.car_id = b.car_id
      AND b.start_date <= NOW()
      AND c.status <> 'reserved';
END;
$$;

-- Runs daily ar 6am, database name is made up for example. Thanks to W10 Lecture for introducing crons.
-- crontab -e
-- 0 6 * * * psql -d M21269_group_01_25_26 -c "CALL reserve_courtesy_cars();"

-- Trigger to prevent overlapping courtesy car bookings.
CREATE OR REPLACE FUNCTION prevent_courtesy_booking_overlap()
RETURNS TRIGGER AS $$
DECLARE
    latest_return DATE;
BEGIN
    SELECT MAX(cb_return_date)
    INTO latest_return
    FROM courtesy_booking
    WHERE cb_court_id = NEW.cb_court_id;
    IF latest_return IS NOT NULL AND NEW.cb_start_date <= latest_return THEN
        RAISE EXCEPTION 'New booking for car % starts before or on latest return date %',
            NEW.cb_court_id, latest_return;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to enforce payment amount matches credit installment amount and update credit amount due.
CREATE OR REPLACE FUNCTION enforce_credit_payment()
RETURNS TRIGGER AS $$
DECLARE
    inst_pay INT;
    pay_amt DECIMAL(10,2);
    next_inst_no INT;
BEGIN
    SELECT credit_inst_pay
    INTO inst_pay
    FROM credit
    WHERE credit_id = NEW.pc_credit_id;

    SELECT pay_amount
    INTO pay_amt
    FROM payment
    WHERE pay_id = NEW.pc_pay_id;

    IF pay_amt <> inst_pay THEN
        RAISE EXCEPTION 'Payment % does not match installment amount % for credit %',
            pay_amt, inst_pay, NEW.pc_credit_id;
    END IF;

    -- Determine next installment number
    SELECT COALESCE(MAX(pc_instalment_no), 0) + 1
    INTO next_inst_no
    FROM payment_credit
    WHERE pc_credit_id = NEW.pc_credit_id;
    
    NEW.pc_instalment_no := next_inst_no;

    -- Update credit_amount_due
    UPDATE credit
    SET credit_amount_due = credit_amount_due - pay_amt
    WHERE credit_id = NEW.pc_credit_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_credit_payment
BEFORE INSERT ON payment_credit
FOR EACH ROW
EXECUTE FUNCTION enforce_credit_payment();


-- Indexes
CREATE INDEX idx_customer_lname on customer (cust_lname);
CREATE INDEX idx_car_reg_num on car (car_reg_num);
CREATE INDEX idx_booking_appt_time on booking (book_appt_time);
CREATE INDEX idx_customer_email on customer (cust_email);
CREATE INDEX idx_customer_phone on customer (cust_phone);
CREATE INDEX idx_staff_email on staff (staff_email);
CREATE INDEX idx_staff_phone on staff (staff_phone);
CREATE INDEX idx_staff_lanem on staff (staff_lname);
CREATE INDEX idx_shift_date on shift (shift_start);
CREATE INDEX idx_job_start on job_allocation (job_start);



-- Inserts
INSERT INTO staff (
    staff_fname, staff_lname, staff_addr1, staff_addr2, staff_county,
    staff_city, staff_postcode, staff_email, staff_phone,
    staff_emerg_fname, staff_emerg_lname, staff_emerg_phone
) VALUES
('Emily', 'Carter', '12 Willow Street', 'Flat 2B', 'Hampshire', 'Portsmouth', 'PO1 3AF', 'emily.carter@example.com', '07452 139284', 'Sarah', 'Carter', '07784 229104'),
('James', 'Walker', '88 Kings Road', NULL, 'Surrey', 'Guildford', 'GU1 4QS', 'james.walker@example.com', '07961 447829', 'Michael', 'Walker', '07534 882917'),
('Sophia', 'Turner', '45 Meadow Lane', NULL, 'West Sussex', 'Chichester', 'PO19 7PL', 'sophia.turner@example.com', '07845 992301', 'Emma', 'Turner', '07482 003917'),
('Daniel', 'Hughes', '29 Brookside Avenue', 'Apt 12', 'Hampshire', 'Southampton', 'SO14 2DQ', 'daniel.hughes@example.com', '07342 118540', 'Laura', 'Hughes', '07852 773002'),
('Olivia', 'Mitchell', '7 Seaview Close', NULL, 'Dorset', 'Bournemouth', 'BH2 5LP', 'olivia.mitchell@example.com', '07512 869334', 'Grace', 'Mitchell', '07945 440821'),
('Benjamin', 'Price', '100 Oakwood Drive', NULL, 'Kent', 'Maidstone', 'ME14 5RJ', 'ben.price@example.com', '07712 540983', 'David', 'Price', '07310 428932'),
('Chloe', 'Martin', '63 Harbour Road', 'Unit 4', 'Hampshire', 'Portsmouth', 'PO2 7LX', 'chloe.martin@example.com', '07411 295034', 'Anna', 'Martin', '07981 224830'),
('Lucas', 'Green', '14 Rosewood Crescent', NULL, 'Surrey', 'Woking', 'GU22 8DN', 'lucas.green@example.com', '07899 002317', 'Oliver', 'Green', '07811 995420'),
('Isabella', 'Foster', '21 Elmhurst Way', NULL, 'Hampshire', 'Fareham', 'PO16 7BY', 'isabella.foster@example.com', '07388 440921', 'Megan', 'Foster', '07792 330851'),
('Matthew', 'Bennett', '56 Parkside Road', 'Flat 1A', 'Berkshire', 'Reading', 'RG1 3TS', 'matt.bennett@example.com', '07488 550349', 'Rachel', 'Bennett', '07930 228640');

INSERT INTO role (role_name, role_desc) VALUES
('Service Advisor', 'Responsible for customer interaction, booking appointments, and communicating service updates.'),
('Technician', 'Performs vehicle inspections, diagnostics, repairs, and maintenance tasks.'),
('Master Technician', 'Highly skilled specialist overseeing complex diagnostics and repair operations.'),
('Receptionist', 'Handles front-desk operations, customer check-ins, calls, and appointment scheduling.'),
('Finance Officer', 'Manages customer invoices, payments, credit accounts, and installment plans.'),
('Parts Specialist', 'Responsible for ordering, tracking, and managing vehicle parts and inventory.'),
('Workshop Manager', 'Oversees daily workshop operations, staff management, safety, and workflow.'),
('Quality Inspector', 'Ensures all completed services meet quality and safety standards before vehicle release.');

INSERT INTO staff_role (staff_id, role_id) VALUES
(1, 1), -- Emily Carter → Service Advisor
(2, 2), -- James Walker → Technician
(3, 4), -- Sophia Turner → Receptionist
(4, 3), -- Daniel Hughes → Master Technician
(5, 6), -- Olivia Mitchell → Parts Specialist
(6, 5), -- Benjamin Price → Finance Officer
(7, 1), -- Chloe Martin → Service Advisor
(7, 4), -- Additional Reception role
(8, 2), -- Lucas Green → Technician
(8, 3), -- Additional Master Technician training
(9, 7), -- Isabella Foster → Workshop Manager
(10, 8); -- Matthew Bennett → Quality Inspector

INSERT INTO branch (
    branch_name, branch_addr1, branch_addr2, branch_county,
    branch_city, branch_postcode, branch_phone, branch_email
) VALUES
('CarCare Hub Portsmouth', '120 Harbour Road', 'Unit A', 'Hampshire', 'Portsmouth', 'PO1 4QF', '023 9275 4410', 'portsmouth@carcarehub.co.uk'),
('CarCare Hub Southampton', '88 Westfield Avenue', NULL, 'Hampshire', 'Southampton', 'SO15 3LP', '023 8034 7721', 'southampton@carcarehub.co.uk'),
('CarCare Hub Guildford', '42 Oakridge Business Park', NULL, 'Surrey', 'Guildford', 'GU2 7YT', '01483 552980', 'guildford@carcarehub.co.uk');

INSERT INTO staff_branch (
    sb_branch_id, sb_staff_id, sb_role_id, sb_start_date, sb_end_date
) VALUES
(1, 1, 1, '2022-03-01', NULL),  -- Emily Carter → Service Advisor
(1, 2, 2, '2021-11-15', NULL),  -- James Walker → Technician
(1, 3, 4, '2023-01-20', NULL),  -- Sophia Turner → Receptionist

(2, 4, 3, '2020-09-10', NULL),  -- Daniel Hughes → Master Technician
(2, 5, 6, '2022-06-05', NULL),  -- Olivia Mitchell → Parts Specialist
(2, 6, 5, '2021-02-18', NULL),  -- Benjamin Price → Finance Officer

(3, 7, 1, '2022-10-12', NULL),  -- Chloe Martin → Service Advisor
(3, 8, 2, '2023-04-03', NULL),  -- Lucas Green → Technician
(3, 9, 7, '2019-12-01', NULL),  -- Isabella Foster → Workshop Manager
(3, 10, 8, '2020-05-30', NULL); -- Matthew Bennett → Quality Inspector

INSERT INTO shift (
    shift_branch_id, shift_start, shift_end
) VALUES
-- Branch 1: Portsmouth
(1, '2025-01-05 08:00:00+00', '2025-01-05 16:00:00+00'),
(1, '2025-01-06 09:00:00+00', '2025-01-06 17:00:00+00'),
(1, '2025-01-07 13:00:00+00', '2025-01-07 21:00:00+00'),

-- Branch 2: Southampton
(2, '2025-01-05 07:00:00+00', '2025-01-05 15:00:00+00'),
(2, '2025-01-06 10:00:00+00', '2025-01-06 18:00:00+00'),
(2, '2025-01-07 14:00:00+00', '2025-01-07 22:00:00+00'),

-- Branch 3: Guildford
(3, '2025-01-05 08:30:00+00', '2025-01-05 16:30:00+00'),
(3, '2025-01-06 09:30:00+00', '2025-01-06 17:30:00+00'),
(3, '2025-01-07 12:00:00+00', '2025-01-07 20:00:00+00');

INSERT INTO staff_shift (ss_staff_id, ss_shift_id) VALUES
-- Shift 1 (Branch 1)
(1, 1),
(2, 1),

-- Shift 2
(3, 2),
(4, 2),

-- Shift 3
(5, 3),
(6, 3),

-- Shift 4 (Branch 2)
(7, 4),
(8, 4),

-- Shift 5
(9, 5),
(10, 5),

-- Shift 6
(1, 6),
(3, 6),

-- Shift 7 (Branch 3)
(2, 7),
(4, 7),

-- Shift 8
(5, 8),
(7, 8),

-- Shift 9
(6, 9),
(9, 9);

INSERT INTO department (dep_name, dep_desc) VALUES
('Engine & Transmission', 'Responsible for engine diagnostics, repairs, transmission servicing, and major mechanical work.'),
('Electrical Systems', 'Handles vehicle electrical diagnostics, wiring, sensors, hybrid components, and battery-related services.'),
('Bodywork & Painting', 'Manages cosmetic repairs, dent removal, repainting, and cosmetic restoration.'),
('General Maintenance', 'Performs routine servicing including oil changes, brake checks, tyre rotations, and safety inspections.'),
('Customer Service', 'Responsible for customer interaction, bookings, front-desk operations, and communication.'),
('Finance & Billing', 'Manages invoicing, payments, credit accounts, installment plans, and financial records.');

INSERT INTO staff_department (sd_staff_id, sd_dep_id) VALUES
-- Engine & Transmission (dep_id = 1)
(2, 1),
(4, 1),
(8, 1),

-- Electrical Systems (dep_id = 2)
(2, 2),
(8, 2),
(10, 2),

-- Bodywork & Painting (dep_id = 3)
(5, 3),
(7, 3),

-- General Maintenance (dep_id = 4)
(1, 4),
(3, 4),
(9, 4),

-- Customer Service (dep_id = 5)
(1, 5),
(3, 5),
(7, 5),

-- Finance & Billing (dep_id = 6)
(6, 6);

INSERT INTO certificate (cert_name, cert_desc) VALUES
('Safety Compliance Certificate', 'Certification awarded to staff who have completed mandatory workplace health and safety training.'),
('Electrical Systems Technician Certificate', 'Covers diagnostics, repair, and safety procedures for vehicle electrical systems.'),
('Hybrid & EV Safety Training', 'Certification for safe handling and servicing of hybrid and electric vehicle components.'),
('Fire Safety & Emergency Response', 'Training certification focused on fire prevention, extinguisher use, and evacuation procedures.'),
('ISO 9001 Quality Standard Awareness', 'Certification related to quality management and adherence to ISO workplace standards.'),
('Equipment Calibration & Handling Certificate', 'Ensures the staff member is trained to use and maintain calibrated workshop equipment.'),
('Hazardous Materials Handling', 'Certification for safe management, storage, and disposal of hazardous automotive chemicals.'),
('Customer Service Excellence', 'Awarded to staff who complete advanced customer care and communication training.');

INSERT INTO staff_certificate (sc_staff_id, sc_cert_id, sc_issue_date, sc_expiry_date) VALUES
(1, 1, '2022-03-10', '2025-03-10'),
(1, 8, '2023-02-14', NULL),

(2, 1, '2021-09-22', '2024-09-22'),
(2, 2, '2023-05-18', '2026-05-18'),
(2, 6, '2022-11-01', NULL),

(3, 8, '2023-04-07', NULL),
(3, 4, '2022-08-12', '2025-08-12'),

(4, 2, '2021-07-19', '2024-07-19'),
(4, 3, '2023-01-11', '2026-01-11'),
(4, 6, '2022-10-05', NULL),

(5, 4, '2022-06-30', '2025-06-30'),
(5, 7, '2023-03-22', NULL),

(6, 1, '2021-10-15', '2024-10-15'),
(6, 5, '2023-02-27', '2026-02-27'),

(7, 8, '2023-06-09', NULL),
(7, 4, '2022-05-18', '2025-05-18'),

(8, 2, '2021-12-01', '2024-12-01'),
(8, 3, '2023-03-10', '2026-03-10'),

(9, 7, '2022-11-25', NULL),
(10, 5, '2023-04-19', '2026-04-19');

INSERT INTO bay (bay_branch_id, bay_name, bay_type) VALUES
-- Branch 1: Portsmouth
(1, 'Portsmouth Bay 1', 'General Service'),
(1, 'Portsmouth Bay 2', 'Diagnostic'),
(1, 'Portsmouth Bay 3', 'Quick Service'),

-- Branch 2: Southampton
(2, 'Southampton Bay 1', 'Body Repair'),
(2, 'Southampton Bay 2', 'Paint Prep'),
(2, 'Southampton Bay 3', 'Alignment'),

-- Branch 3: Guildford
(3, 'Guildford Bay 1', 'Electrical'),
(3, 'Guildford Bay 2', 'Hybrid'),
(3, 'Guildford Bay 3', 'Heavy Duty');

INSERT INTO bay_compliance 
(bcomp_bay_id, bcomp_type, bcomp_date, bcomp_passed, bcomp_due_date)
VALUES
(1, 'Safety Certified', '2025-01-10', TRUE, '2026-01-10'),
(1, 'Fire Safety Approved', '2025-01-15', TRUE, '2026-01-15'),
(2, 'Environmental Compliant', '2025-02-01', FALSE, '2025-03-01'),
(3, 'OSHA Compliant', '2025-03-05', TRUE, '2026-03-05'),
(4, 'Electrical Safety Checked', '2025-04-12', FALSE, '2025-05-12');

INSERT INTO courtesy_car
(court_branch_id, court_reg_num, court_make, court_model, court_year, court_status)
VALUES
(1, 'AB12 XYZ', 'Toyota', 'Yaris', 2020, 'Available'),
(1, 'CD34 LMN', 'Ford', 'Focus', 2019, 'In Use'),
(2, 'EF56 QRS', 'Audi', 'A3', 2021, 'Under Maintenance');

INSERT INTO membership_type
(mtype_name, mtype_discount, mtype_courtsey_access, mtype_desc, mtype_fee)
VALUES
('Basic', 0.05, FALSE, 'Entry-level membership with 5% discount on services.', 39.99),

('Standard', 0.10, FALSE, 'Standard plan offering moderate discounts and priority booking.', 59.99),

('Premium', 0.15, TRUE, 'Premium membership with courtesy car access and multiple extra perks.', 89.99),

('Gold', 0.20, TRUE, 'Gold plan with 20% discount and full courtesy car benefits.', 129.99),

('Elite', 0.30, TRUE, 'Elite membership with maximum discount, courtesy car, and VIP services.', 169.99);

INSERT INTO membership
(mem_type_id, mem_start, mem_end, mem_status)
VALUES
(1, '2024-01-01', '2025-01-01', 'Active'),
(2, '2023-06-15', '2024-06-15', 'Inactive'),
(3, '2024-03-10', '2025-03-10', 'Suspended'),
(4, '2022-11-01', '2023-11-01', 'Cancelled'),
(5, '2024-05-01', '2025-05-01', 'Active');

INSERT INTO customer 
(cust_mem_id, cust_fname, cust_lname, cust_email, cust_phone,
 cust_addr1, cust_addr2, cust_county, cust_city, cust_postcode,
 cust_emerg_fname, cust_emerg_lname, cust_emerg_phone)
VALUES
-- 1
(1, 'James', 'Carter', 'j.carter@example.com', '07123456780',
 '12 Oak Street', NULL, 'Hampshire', 'Portsmouth', 'PO1 2AB',
 'Maria', 'Carter', '07911122334'),

-- 2
(2, 'Emily', 'Thompson', 'emily.t@example.com', '07123456781',
 '45 High Road', 'Flat 3B', 'West Sussex', 'Chichester', 'PO19 8DL',
 'John', 'Thompson', '07899887766'),

-- 3
(NULL, 'Oliver', 'Reed', 'oliver.reed@example.com', '07123456782',
 '8 Willow Close', NULL, 'Surrey', 'Guildford', 'GU1 4RT',
 'Sarah', 'Reed', '07755664422'),

-- 4
(3, 'Sophia', 'Green', 's.green@example.com', '07123456783',
 '19 Elm Avenue', NULL, 'Hampshire', 'Fareham', 'PO14 3AD',
 'Daniel', 'Green', '07422334455'),

-- 5
(NULL, 'Liam', 'Walker', NULL, '07123456784',
 'Apartment 6', 'Seaview House', 'Hampshire', 'Southampton', 'SO14 0AA',
 'Emma', 'Walker', '07333445566'),

-- 6
(4, 'Ava', 'Mitchell', 'ava.m@example.com', '07123456785',
 '23 Rosewood Drive', NULL, 'Dorset', 'Bournemouth', 'BH1 1BA',
 'Hannah', 'Mitchell', '07222334411'),

-- 7
(5, 'Noah', 'Bennett', 'noah.b@example.com', '07123456786',
 '11 Kingfisher Lane', NULL, 'Hampshire', 'Havant', 'PO9 1QX',
 'Michael', 'Bennett', '07655443322'),

-- 8
(NULL, 'Grace', 'Foster', 'grace.f@example.com', '07123456787',
 '7 Station Road', NULL, 'Hampshire', 'Cosham', 'PO6 2LD',
 'Laura', 'Foster', '07544332211'),

-- 9
(2, 'Mason', 'Hughes', NULL, '07123456788',
 '14 Millbrook Court', NULL, 'West Sussex', 'Bognor Regis', 'PO21 4FG',
 'Chloe', 'Hughes', '07788990011'),

-- 10
(1, 'Isabella', 'Turner', 'isabella.t@example.com', '07123456789',
 '2 Maple Grove', 'Unit 5', 'Hampshire', 'Waterlooville', 'PO7 5LR',
 'Robert', 'Turner', '07811223344');

INSERT INTO car_make (make_name) VALUES
('Toyota'),
('Honda'),
('Ford'),
('Nissan'),
('BMW'),
('Mercedes-Benz'),
('Audi'),
('Volkswagen'),
('Hyundai'),
('Kia'),
('Volvo'),
('Mazda'),
('Subaru'),
('Peugeot'),
('Renault'),
('Fiat'),
('Chevrolet'),
('Land Rover'),
('Jaguar'),
('Tesla');

-- Toyota (make_id = 1)
INSERT INTO car_model (model_make_id, model_name, model_year)
VALUES
(1, 'Yaris', 2020),
(1, 'Corolla', 2021),

-- Honda (make_id = 2)
(2, 'Civic', 2020),
(2, 'CR-V', 2022),

-- Ford (make_id = 3)
(3, 'Fiesta', 2019),
(3, 'Focus', 2021),

-- Nissan (make_id = 4)
(4, 'Qashqai', 2022),
(4, 'Micra', 2018),

-- BMW (make_id = 5)
(5, '3 Series', 2021),

-- Mercedes-Benz (make_id = 6)
(6, 'C-Class', 2020),

-- Audi (make_id = 7)
(7, 'A3', 2020),

-- Volkswagen (make_id = 8)
(8, 'Golf', 2019),

-- Hyundai (make_id = 9)
(9, 'i20', 2021),

-- Kia (make_id = 10)
(10, 'Sportage', 2022);

INSERT INTO car
(car_model, car_cust, car_reg_num, car_vin, car_colour, car_mileage)
VALUES
-- 1. Toyota Corolla - Customer 1
(2, 1, 'AB21 XYZ', 'JHMFA16507S012345', 'Blue', 45210.5),

-- 2. Honda CR-V - Customer 2
(4, 2, 'BK19 LMP', '1HGCM82633A004352', 'Silver', 60120.0),

-- 3. Ford Fiesta - Customer 3
(5, 3, 'CU68 RKT', 'WF0DXXGCDDSA12345', 'Red', 38200.2),

-- 4. Nissan Qashqai - Customer 4
(7, 4, 'DG20 HSF', 'SJNFAAZE15U987654', 'Black', 51200.0),

-- 5. BMW 3 Series - Customer 5
(9, 5, 'EF22 PLO', 'WBA8E1C50JA123456', 'White', 29800.7),

-- 6. Mercedes C-Class - Customer 6
(10, 6, 'GH70 MNB', 'WDDGF4HB2DA765432', 'Grey', 40150.3),

-- 7. Audi A3 - Customer 7
(11, 7, 'HJ19 FDE', 'WAUZZZF57KA654321', 'Silver', 33500.0),

-- 8. Volkswagen Golf - Customer 8
(12, 8, 'JK18 RSE', 'WVWZZZAUZJW012345', 'Blue', 72300.4),

-- 9. Hyundai i20 - Customer 9
(13, 9, 'LM21 UOP', 'KMHDH41EXDU123456', 'Red', 21100.0),

-- 10. Kia Sportage - Customer 10
(14, 10, 'NP20 BGF', 'KNDPN3AC0F1234567', 'Black', 46500.9);

INSERT INTO booking
(book_car_id, book_appt_time, book_timestamp, book_status, book_cost, book_channel)
VALUES
-- 1. Customer 1 - Toyota Corolla
(1, '2025-01-12 10:00:00+00', '2024-12-20 09:45:00+00', 'Scheduled', 149.99, 'Online'),

-- 2. Customer 2 - Honda CR-V
(2, '2025-01-14 14:30:00+00', '2024-12-26 11:10:00+00', 'Pending', 89.50, 'Phone'),

-- 3. Customer 3 - Ford Fiesta
(3, '2024-12-28 09:00:00+00', '2024-12-10 13:22:00+00', 'Completed', 120.00, 'In-Person'),

-- 4. Customer 4 - Nissan Qashqai
(4, '2025-02-02 16:00:00+00', '2025-01-10 08:05:00+00', 'Scheduled', 199.99, 'Email'),

-- 5. Customer 5 - BMW 3 Series
(5, '2024-12-30 13:00:00+00', '2024-12-05 12:30:00+00', 'Cancelled', NULL, 'Online'),

-- 6. Customer 6 - Mercedes C-Class
(6, '2025-01-22 11:00:00+00', '2024-12-18 10:15:00+00', 'Rescheduled', 175.00, 'Phone'),

-- 7. Customer 7 - Audi A3
(7, '2025-01-18 15:15:00+00', '2024-12-27 14:50:00+00', 'Ongoing', 250.00, 'In-Person'),

-- 8. Customer 8 - VW Golf
(8, '2024-12-29 10:45:00+00', '2024-12-01 09:55:00+00', 'Completed', 130.00, 'Online'),

-- 9. Customer 9 - Hyundai i20
(9, '2025-01-25 12:00:00+00', '2024-12-29 16:00:00+00', 'Scheduled', 80.00, 'Email'),

-- 10. Customer 10 - Kia Sportage
(10, '2025-01-05 09:30:00+00', '2024-12-21 11:40:00+00', 'No-Show', 0.00, 'Phone');

INSERT INTO mot
(mot_car_id, mot_book_id, mot_date, mot_expiry_date, mot_mileage,
 mot_engine, mot_reg, mot_oil_level, mot_wiper_blades, mot_coolant_level,
 mot_electrics, mot_brakes, mot_air_conditioning, mot_exterior)
VALUES
-- 1. Toyota Corolla (Car 1 | Booking 1)
(1, 1, '2024-12-20', '2025-12-20', 45210.5,
 'No Action Needed', 'AB21 XYZ', 0.85, 'No Action Needed', 0.78,
 'No Action Needed', 'Further Review', 'No Action Needed', 'No Action Needed'),

-- 2. Honda CR-V (Car 2 | Booking 2)
(2, 2, '2024-12-26', '2025-12-26', 60120.0,
 'Further Review', 'BK19 LMP', 0.72, 'Repair', 0.65,
 'No Action Needed', 'Repair', 'Further Review', 'No Action Needed'),

-- 3. Ford Fiesta (Car 3 | Booking 3)
(3, 3, '2024-12-10', '2025-12-10', 38200.2,
 'No Action Needed', 'CU68 RKT', 0.90, 'No Action Needed', 0.88,
 'Further Review', 'No Action Needed', 'No Action Needed', 'Further Review'),

-- 4. Nissan Qashqai (Car 4 | Booking 4)
(4, 4, '2025-01-10', '2026-01-10', 51200.0,
 'Repair', 'DG20 HSF', 0.60, 'Replace', 0.55,
 'Repair', 'Repair', 'No Action Needed', 'No Action Needed'),

-- 5. BMW 3 Series (Car 5 | Booking 5)
(5, 5, '2024-12-05', '2025-12-05', 29800.7,
 'No Action Needed', 'EF22 PLO', 0.92, 'No Action Needed', 0.89,
 'No Action Needed', 'No Action Needed', 'Further Review', 'No Action Needed'),

-- 6. Mercedes C-Class (Car 6 | Booking 6)
(6, 6, '2024-12-18', '2025-12-18', 40150.3,
 'Repair', 'GH70 MNB', 0.68, 'Repair', 0.70,
 'Further Review', 'Replace', 'Repair', 'No Action Needed'),

-- 7. Audi A3 (Car 7 | Booking 7)
(7, 7, '2024-12-27', '2025-12-27', 33500.0,
 'No Action Needed', 'HJ19 FDE', 0.95, 'No Action Needed', 0.90,
 'No Action Needed', 'No Action Needed', 'No Action Needed', 'Further Review'),

-- 8. VW Golf (Car 8 | Booking 8)
(8, 8, '2024-12-01', '2025-12-01', 72300.4,
 'Further Review', 'JK18 RSE', 0.55, 'Repair', 0.60,
 'Repair', 'Further Review', 'No Action Needed', 'Repair'),

-- 9. Hyundai i20 (Car 9 | Booking 9)
(9, 9, '2024-12-29', '2025-12-29', 21100.0,
 'No Action Needed', 'LM21 UOP', 0.88, 'No Action Needed', 0.82,
 'Further Review', 'No Action Needed', 'No Action Needed', 'No Action Needed'),

-- 10. Kia Sportage (Car 10 | Booking 10)
(10, 10, '2024-12-21', '2025-12-21', 46500.9,
 'Replace', 'NP20 BGF', 0.50, 'Replace', 0.48,
 'Repair', 'Replace', 'Further Review', 'Repair');

INSERT INTO credit
(credit_due, credit_inst_amount, credit_inst_pay, credit_total, credit_status, credit_amount_due)
VALUES
-- 1. Active instalment plan
('2025-03-20', 3, 150.00, 450.00, 'Pending', 450.00),

-- 2. Completed plan
('2024-3-10', 3, 200.00, 600.00, 'Paid', 600.00);

INSERT INTO payment
(pay_book_id, pay_type, pay_time, pay_status, pay_amount)
VALUES
-- 1. Booking 1 - Completed (Credit Card)
(1, 'Credit Card', '2024-12-20 10:05:00+00', 'Completed', 150.00),

(1, 'Credit Card', '2025-01-20 13:09:00+00', 'Completed', 150.00),

-- 2. Booking 2 - Pending (Bank Transfer)
(2, 'Bank Transfer', '2024-12-26 11:15:00+00', 'Pending', 89.50),

-- 3. Booking 3 - Completed (Cash)
(3, 'Cash', '2024-12-28 09:10:00+00', 'Completed', 120.00),

-- 4. Booking 4 - Completed (Mobile Payment)
(4, 'Mobile Payment', '2025-01-10 08:10:00+00', 'Completed', 200.00),
(4, 'Mobile Payment', '2025-02-10 08:11:00+00', 'Completed', 200.00),
(4, 'Mobile Payment', '2025-03-10 08:09:00+00', 'Completed', 200.00),

-- 5. Booking 5 - Cancelled booking → Refunded payment
(5, 'Credit Card', '2024-12-05 12:40:00+00', 'Refunded', 149.99),

-- 6. Booking 6 - Rescheduled → still Pending
(6, 'Debit Card', '2024-12-18 10:20:00+00', 'Pending', 175.00),

-- 7. Booking 7 - Ongoing → Partial payment Failed
(7, 'Debit Card', '2024-12-27 14:55:00+00', 'Failed', 250.00),

-- 8. Booking 8 - Completed successfully (Cash)
(8, 'Cash', '2024-12-01 10:50:00+00', 'Completed', 130.00),

-- 9. Booking 9 - Scheduled → Paid early
(9, 'Credit Card', '2024-12-29 16:10:00+00', 'Completed', 80.00),

-- 10. Booking 10 - No-Show → Pending late fee
(10, 'Bank Transfer', '2024-12-21 11:45:00+00', 'Pending', 0.00);

INSERT INTO payment_credit (pc_pay_id, pc_credit_id)
VALUES
-- Credit 1: Active instalment plan (2 payments made)
(1, 1),
(2, 1),
(5, 2),
(6, 2),
(7, 2);

INSERT INTO refund
(ref_pay_id, ref_time, ref_amount)
VALUES
(10, '2024-12-21 12:00:00+00', 0.00),
(3, '2024-12-28 10:00:00+00', 20.00),
(8, '2024-12-01 11:15:00+00', 15.00);

INSERT INTO supplier
(sup_addr1, sup_addr2, sup_postcode, sup_city, sup_name, sup_email, sup_phone, sup_website, sup_vat)
VALUES
-- 1
('12 Industrial Way', NULL, 'PO1 3FA', 'Portsmouth',
 'AutoParts UK Ltd', 'sales@autoparts-uk.com', '023 9400 1122',
 'https://autoparts-uk.com', '123456789'),

-- 2
('44 Meadow Park', 'Unit 7', 'SO14 7LG', 'Southampton',
 'Prime Motor Supplies', 'info@primemotorsupplies.co.uk', '023 8080 3344',
 'https://primemotorsupplies.co.uk', '234567891'),

-- 3
('1 Harbour Road', NULL, 'BN1 5QT', 'Brighton',
 'Brighton Vehicle Components', 'contact@bvc.co.uk', '01273 556677',
 NULL, '345678912'),

-- 4
('78 Kingsfield Estate', NULL, 'RG1 8AS', 'Reading',
 'Reading Auto Electricals', 'service@rae.com', '0118 908 2211',
 'https://rae.com', '456789123'),

-- 5
('25 Motorway Avenue', 'Block C', 'GU14 0JR', 'Farnborough',
 'Farnborough Tyre & Brake Co', 'support@ftbco.uk', '01252 440022',
 NULL, '567891234'),

-- 6
('9 Eastleigh Road', NULL, 'SO50 5DF', 'Eastleigh',
 'Eastleigh Engine Works', 'engines@eastworks.co.uk', '023 8066 9898',
 'https://eastworks.co.uk', '678912345'),

-- 7
('16 West Industrial Park', NULL, 'PO9 2NN', 'Havant',
 'Havant Auto Spares', 'orders@havantas.co.uk', '023 9292 7711',
 NULL, '789123456'),

-- 8
('2 Fleet Street', 'Suite 12', 'SW6 3PQ', 'London',
 'London Performance Parts', 'sales@lpparts.com', '020 7946 5533',
 'https://lpparts.com', '891234567'),

-- 9
('88 New Road', NULL, 'BH1 3AF', 'Bournemouth',
 'Bournemouth Motor Traders', 'hello@bmtltd.uk', '01202 447700',
 NULL, '912345678'),

-- 10
('31 Enterprise Way', 'Unit 4', 'RH10 9TF', 'Crawley',
 'Crawley Automotive Supplies', 'contact@crawleyauto.co.uk', '01293 500600',
 'https://crawleyauto.co.uk', '102938475');

INSERT INTO part
(part_man_no, part_name, part_unit, part_size, part_qty)
VALUES
-- 1. Synthetic Engine Oil (5W30) - 5 L
('OIL-5W30-001', 'Synthetic Engine Oil 5W30', 'L', 5.00, 40),

-- 2. Full Synthetic Engine Oil (0W20) - 4 L
('OIL-0W20-002', 'Full Synthetic Engine Oil 0W20', 'L', 4.00, 30),

-- 3. Oil Filter
('FLT-OIL-100', 'Oil Filter - Standard Fit', 'UNIT', 1.00, 60),

-- 4. Front Brake Pad Set
('BRK-PAD-FR', 'Front Brake Pad Set', 'UNIT', 1.00, 25),

-- 5. Rear Brake Pad Set
('BRK-PAD-RR', 'Rear Brake Pad Set', 'UNIT', 1.00, 20),

-- 6. Engine Air Filter
('FLT-AIR-200', 'Engine Air Filter', 'UNIT', 1.00, 50),

-- 7. Cabin Pollen Filter
('FLT-CAB-250', 'Cabin Pollen Filter', 'UNIT', 1.00, 45),

-- 8. Wiper Blade Pair
('WIP-BLD-PR', 'Wiper Blade Pair 22"', 'UNIT', 1.00, 35),

-- 9. Spark Plug
('SPK-PLG-004', 'Spark Plug - Standard', 'UNIT', 1.00, 80),

-- 10. Engine Coolant / Antifreeze (1 L)
('CLT-ANT-500', 'Engine Coolant / Antifreeze', 'L', 1.00, 70),

-- 11. DOT 4 Brake Fluid (500 ML)
('FLD-BRK-600', 'DOT 4 Brake Fluid', 'ML', 500.00, 50),

-- 12. H7 Headlight Bulb
('BLB-H7-700', 'H7 Halogen Headlight Bulb', 'UNIT', 1.00, 90),

-- 13. Serpentine Drive Belt
('BLT-SERP-800', 'Serpentine Drive Belt', 'UNIT', 1.00, 20),

-- 14. Fuel Filter
('FLT-FUEL-300', 'Fuel Filter Standard', 'UNIT', 1.00, 40),

-- 15. Automatic Transmission Fluid (1 L)
('FLD-TRN-900', 'Transmission Fluid ATF-III', 'L', 1.00, 55);

INSERT INTO part_supplier
(ps_sup_id, ps_part_id, ps_cost)
VALUES
-- Supplier 1 (AutoParts UK) - Common filters + wipers
(1, 3, 5.99),   -- Oil Filter
(1, 6, 7.49),   -- Air Filter
(1, 8, 12.99),  -- Wiper Blades
(1, 12, 3.99),  -- H7 Bulb

-- Supplier 2 (Prime Motor Supplies) - Oils + Brake Pads
(2, 1, 18.50),  -- Engine Oil 5W30 (5L)
(2, 2, 22.00),  -- Engine Oil 0W20 (4L)
(2, 4, 32.99),  -- Front Brake Pads
(2, 5, 28.99),  -- Rear Brake Pads

-- Supplier 3 (Brighton Vehicle Components) - Coolant + Fuel Filter
(3, 10, 6.49),  -- Coolant (1L)
(3, 14, 9.99),  -- Fuel Filter

-- Supplier 4 (Reading Auto Electricals) - Bulbs, Electrics
(4, 12, 4.29),  -- H7 Bulb
(4, 9, 6.50),   -- Spark Plug
(4, 6, 8.00),   -- Air Filter

-- Supplier 5 (Farnborough Tyre & Brake) - Brake & Drive belts
(5, 4, 30.49),  -- Front Brake Pads
(5, 5, 27.49),  -- Rear Brake Pads
(5, 13, 19.99), -- Serpentine Belt

-- Supplier 6 (Eastleigh Engine Works) - Fluids
(6, 1, 17.99),  -- Engine Oil 5W30
(6, 11, 4.50),  -- Brake Fluid (500ml)
(6, 15, 12.99); -- Transmission Fluid (1L)

INSERT INTO booking_part
(bp_book_id, bp_part_id, bp_qty, bp_cost)
VALUES
-- Booking 1: Oil change + filter
(1, 1, 1, 18.50),   -- Engine Oil 5W30 (5L)
(1, 3, 1, 5.99),    -- Oil Filter

-- Booking 2: Brake inspection
(2, 4, 1, 32.99),   -- Front Brake Pads

-- Booking 3: Service completed - Air filter + plugs
(3, 6, 1, 7.49),    -- Air Filter
(3, 9, 4, 6.50),    -- Spark Plugs (set of 4)

-- Booking 4: Major service - coolant + belt
(4, 10, 1, 6.49),   -- Coolant
(4, 13, 1, 19.99),  -- Serpentine Belt

-- Booking 5: Cancelled job (no parts used)
-- (No entries)

-- Booking 6: Brake fluid + rear pads
(6, 11, 1, 4.50),   -- Brake Fluid
(6, 5, 1, 27.49),   -- Rear Brake Pads

-- Booking 7: Bulb replacement
(7, 12, 2, 4.29),   -- H7 Bulbs (2 pcs)

-- Booking 8: Air filter + spark plugs
(8, 6, 1, 8.00),    -- Air Filter
(8, 9, 4, 6.50),    -- Spark Plugs

-- Booking 9: Wiper blades
(9, 8, 1, 12.99),   -- Wiper Blade Pair

-- Booking 10: Transmission fluid
(10, 15, 1, 12.99); -- ATF-III Fluid

INSERT INTO service_type
(stype_name, stype_desc)
VALUES
-- 1
('Full Service', 'Comprehensive vehicle service including oil, filters, brakes, fluids, and safety checks.'),

-- 2
('Interim Service', 'Basic service including oil change, fluid top-ups, and essential checks.'),

-- 3
('MOT Test', 'Mandatory annual MOT inspection covering safety, emissions, and vehicle roadworthiness.'),

-- 4
('Oil & Filter Change', 'Replacement of engine oil and filter, with basic engine health check.'),

-- 5
('Brake Inspection', 'Inspection of brake pads, discs, brake fluid, and braking performance.'),

-- 6
('Engine Diagnostics', 'Computerised engine fault scan and diagnosis of warning lights.'),

-- 7
('Air Conditioning Service', 'Aircon gas recharge, leak test, and cooling performance inspection.'),

-- 8
('Tyre Replacement', 'Removal and fitting of tyres, wheel balancing, and pressure checks.'),

-- 9
('Transmission Service', 'Gearbox oil change and inspection of clutch and transmission components.'),

-- 10
('Electrical System Check', 'Inspection of battery, alternator, wiring, lighting, and electrical components.');

INSERT INTO service
(service_type_id, service_dep_id, service_name, service_desc, service_labour_cost, service_duration)
VALUES
-- Engine & Transmission (dep_id = 1)
(9, 1, 'Transmission Oil Change',
 'Replacement of gearbox oil and inspection of transmission components.',
 120.00, '1 hour'),

(1, 1, 'Full Engine Service',
 'Comprehensive engine service including plugs, filters, belts, and diagnostics.',
 220.00, '3 hours'),

(6, 1, 'Engine Diagnostics Scan',
 'Computerised scan for engine fault codes and performance issues.',
 65.00, '45 minutes'),

-- Electrical Systems (dep_id = 2)
(10, 2, 'Electrical System Check',
 'Battery, alternator, starter, wiring, and fuse diagnostics.',
 80.00, '1 hour'),

(6, 2, 'Hybrid/Electric Vehicle High-Voltage Inspection',
 'Safety checks and diagnostics on hybrid/electric vehicle HV systems.',
 150.00, '1 hour 30 minutes'),

(9, 2, 'Lighting System Repair',
 'Replacement and repair of headlights, indicators, and external lighting components.',
 55.00, '50 minutes'),

-- Bodywork & Painting (dep_id = 3)
(8, 3, 'Minor Dent Removal',
 'Paintless dent removal for small dents and dings.',
 95.00, '2 hours'),

(8, 3, 'Full Body Respray',
 'Complete repaint using high-quality automotive paint.',
 850.00, '1 day'),

(8, 3, 'Bumper Repair & Paint',
 'Repair and repaint minor bumper damage.',
 180.00, '5 hours'),

-- General Maintenance (dep_id = 4)
(4, 4, 'Oil & Filter Change',
 'Drain old oil, replace oil filter, refill with manufacturer-approved oil.',
 45.00, '45 minutes'),

(5, 4, 'Brake Inspection & Adjustment',
 'Inspection of pads, discs, fluid, and brake balance.',
 35.00, '30 minutes'),

(7, 4, 'Air Conditioning Recharge',
 'AC refrigerant recharge, leak inspection, cooling performance test.',
 70.00, '1 hour'),

(2, 4, 'Interim Service',
 'Basic service with essential checks, oil change, and top-ups.',
 90.00, '1 hour 30 minutes'),

-- MOT (dep_id = 4 - General Maintenance normally handles MOT checks)
(3, 4, 'Annual MOT Test',
 'Standard government-required MOT inspection covering safety and emissions.',
 54.85, '1 hour');

INSERT INTO booking_service
(bs_book_id, bs_service_id, bs_date_performed, bs_note)
VALUES
-- Booking 1: Scheduled service (Oil & Filter + Brake Inspection)
(1, 10, '2025-01-12', 'Oil & filter changed, no leaks found.'),
(1, 11, '2025-01-12', 'Brakes inspected and in good condition.'),

-- Booking 2: Pending (Transmission Oil Change)
(2, 1, NULL, 'Awaiting vehicle arrival.'),

-- Booking 3: Completed (Full Engine Service)
(3, 2, '2024-12-28', 'Full service completed. Spark plugs and filters replaced.'),

-- Booking 4: Scheduled (MOT Test)
(4, 14, '2025-02-02', 'MOT passed with advisories.'),

-- Booking 5: Cancelled (no services performed)
-- (No entries)

-- Booking 6: Rescheduled (Brake Inspection)
(6, 11, '2025-01-22', 'Brake pads worn, replacement advised.'),

-- Booking 7: Ongoing (Electrical System Check)
(7, 4, NULL, 'Electrical diagnostics in progress.'),

-- Booking 8: Completed (Engine Diagnostics + Oil & Filter Change)
(8, 3, '2024-12-29', 'Fault code P0420 noted, requires catalytic converter inspection.'),
(8, 10, '2024-12-29', 'Air filter replaced.'),

-- Booking 9: Scheduled (Air Conditioning Recharge)
(9, 12, '2025-01-25', 'AC system cooling restored.'),

-- Booking 10: No-show (Tyre Replacement)
(10, 8, NULL, 'Customer did not attend booking.');

INSERT INTO job_allocation
(job_book_id, job_staff_id, job_bay_id, job_start, job_end, job_desc)
VALUES
-- Booking 1: Oil & Filter + Brake Inspection (Completed)
(1, 1, 3, '2025-01-12 10:00:00+00', '2025-01-12 12:00:00+00',
 'Completed oil & filter change and brake inspection.'),

-- Booking 2: Transmission Oil Change (Pending, not yet started)
(2, 2, 1, '2025-01-14 14:30:00+00', NULL,
 'Technician assigned and bay reserved; awaiting vehicle arrival.'),

-- Booking 3: Full Engine Service (Completed)
(3, 3, 1, '2024-12-28 09:00:00+00', '2024-12-28 12:30:00+00',
 'Full engine service completed, including replacement of plugs and filters.'),

-- Booking 4: MOT Test (Completed)
(4, 4, 3, '2025-02-02 16:00:00+00', '2025-02-02 17:10:00+00',
 'Annual MOT test performed; minor advisories noted.'),

-- Booking 5: Cancelled – no work performed
(5, 5, 3, '2024-12-30 13:00:00+00', NULL,
 'Customer cancelled booking; no work carried out.'),

-- Booking 6: Brake Inspection (Completed)
(6, 6, 3, '2025-01-22 11:00:00+00', '2025-01-22 12:45:00+00',
 'Brake inspection completed; advised replacement of worn pads.'),

-- Booking 7: Electrical System Check (Ongoing)
(7, 7, 7, '2025-01-18 15:00:00+00', NULL,
 'Electrical diagnostics in progress; intermittent battery warning.'),

-- Booking 8: Diagnostics + Oil & Filter (Completed)
(8, 8, 2, '2024-12-29 10:30:00+00', '2024-12-29 12:15:00+00',
 'Engine diagnostic scan completed; air filter and oil replaced.'),

-- Booking 9: Air Conditioning Recharge (Completed)
(9, 9, 3, '2025-01-25 12:00:00+00', '2025-01-25 13:15:00+00',
 'AC recharge completed; leak test passed.'),

-- Booking 10: Tyre Replacement (No-show)
(10, 10, 3, '2025-01-05 09:30:00+00', NULL,
 'Customer did not attend appointment; bay unused.');


INSERT INTO feedback 
(fb_book_id, fb_staff_id, fb_comment, fb_date, fb_responded, fb_rating)
VALUES
-- Booking 1: Completed – Good service
(1, 1, 'Great service, quick and efficient. Car feels smoother.', 
 '2025-01-13 09:15:00+00', TRUE, 5),

-- Booking 2: Pending – no feedback expected (customer hasn’t attended)
(2, 2, 'No feedback provided as the vehicle has not yet arrived.', 
 '2025-01-15 10:00:00+00', FALSE, 3),

-- Booking 3: Completed – Very positive
(3, 3, 'Full engine service done really well. Staff explained everything clearly.', 
 '2024-12-29 14:45:00+00', TRUE, 5),

-- Booking 4: MOT Test – average rating (advisories noted)
(4, 4, 'MOT was fine but the waiting area was a bit busy.', 
 '2025-02-03 11:20:00+00', TRUE, 4),

-- Booking 5: Cancelled – low rating due to cancellation experience
(5, 5, 'Had to cancel my appointment but communication could be improved.', 
 '2024-12-31 10:30:00+00', FALSE, 2),

-- Booking 6: Completed – customer informed about brake pad wear
(6, 6, 'Inspection was helpful, and staff were honest about repair costs.', 
 '2025-01-23 08:50:00+00', TRUE, 4),

-- Booking 7: Ongoing electrical diagnostics – neutral
(7, 7, 'Still waiting for a full diagnosis, but staff kept me updated.', 
 '2025-01-19 12:00:00+00', TRUE, 3),

-- Booking 8: Completed – diagnostics + oil/filter change
(8, 8, 'Diagnostics identified the issue and service was fast.', 
 '2024-12-30 16:10:00+00', TRUE, 5),

-- Booking 9: AC Recharge – satisfied
(9, 9, 'AC now works perfectly. Very happy with the service.', 
 '2025-01-26 14:20:00+00', TRUE, 5),

-- Booking 10: No-show – customer unhappy with rebooking policy
(10, 10, 'Missed my appointment and was charged a fee for rebooking. Not happy.', 
 '2025-01-06 09:00:00+00', FALSE, 1);

INSERT INTO courtesy_booking
(cb_court_id, cb_book_id, cb_start_date, cb_return_date)
VALUES
-- Booking 2: Transmission Oil Change (full-day work)
(1, 2, '2025-01-14', '2025-01-15'),

-- Booking 3: Full Engine Service (long service)
(2, 3, '2024-12-28', '2024-12-29'),

-- Booking 4: MOT Test with advisories
(1, 4, '2025-02-02', '2025-02-03'),

-- Booking 7: Ongoing Electrical Diagnostics
(2, 7, '2025-01-18', '2025-01-20'),

-- Booking 8: Diagnostics + Oil & Filter Change
(1, 8, '2024-12-29', '2024-12-30'),

-- Booking 9: AC Recharge (short loan)
(2, 9, '2025-01-25', '2025-01-25');


-- Queries

--Q1
--Branch Performance in 2024

/*
WITH branch_booking_2025 AS (
    SELECT 
        SUM("Booking Cost (£)") AS total_booking_cost,
        COUNT("Booking ID") AS total_books,
        "Branch" AS branch_name, -- branch_name is AK in branch table
        COUNT(job_id) AS jobs_completed, -- job_id is a PK, so it won't be double counted
        COUNT(DISTINCT job_staff_id) AS staff_involved    
    FROM booking_details -- this view table made the query possible.
    JOIN job_allocation
        ON "Booking ID" = job_book_id
    WHERE EXTRACT(YEAR FROM "Booking Date") = 2024 
        AND "Booking Status" = 'Completed'
        AND job_end IS NOT NULL -- only consider completed jobs
    GROUP BY "Branch"
)
SELECT
    branch.branch_name AS "Branch",
    COALESCE(CEIL(total_booking_cost / 1000), 0) AS "Revenue (Thousands £)",
    COALESCE(total_books, 0) AS "Total Bookings",
    COALESCE(jobs_completed, 0) AS "Jobs Completed",
    COALESCE(staff_involved, 0) AS "Staff Involved",
    COALESCE(
        ROUND(total_booking_cost / NULLIF(total_books, 0), 2), 
        0
    ) AS "Avg Revenue per Booking (£)"
FROM branch_booking_2025 bb2025
RIGHT JOIN branch 
    USING (branch_name)
GROUP BY 
    branch.branch_name, total_booking_cost, total_books, jobs_completed, staff_involved
ORDER BY 
    "Revenue (Thousands £)" DESC;
*/

--Q2
--External Shift Coverage per Branch for Q1 2025
/*
WITH branch_external AS ( -- counts shifts covered by staff from other branches for the period
    SELECT
        worked.branch_id,
        worked.branch_name,
        COUNT(DISTINCT shift_id) AS external_shifts
    FROM staff 
    JOIN staff_branch 
        ON sb_staff_id = staff_id
    JOIN branch home
        ON home.branch_id = sb_branch_id
    JOIN staff_shift 
        ON ss_staff_id = staff_id
    JOIN shift 
        ON shift_id = ss_shift_id
    JOIN branch worked
        ON worked.branch_id = shift_branch_id
    WHERE
        home.branch_id <> worked.branch_id
        AND shift_start >= DATE '2025-01-01'
        AND shift_start <  DATE '2025-04-01'
    GROUP BY
        worked.branch_id, worked.branch_name
),
branch_total AS ( -- counts total shifts per branch for the period
    SELECT
        shift_branch_id AS branch_id,
        COUNT(DISTINCT shift_id) AS total_shifts
    FROM shift 
    WHERE
        shift_start >= DATE '2025-01-01'
        AND shift_start <  DATE '2025-04-01'
    GROUP BY
        shift_branch_id
)
SELECT 
    be.branch_name AS "Branch",
    be.external_shifts AS "External Cover Shifts",
    ROUND(
        be.external_shifts * 100.0
        / NULLIF(bt.total_shifts, 0),
        2
    ) AS "External Cover (%)"
FROM branch_external be
JOIN branch_total bt
    USING(branch_id)
ORDER BY
    "External Cover Shifts" DESC;
*/

--Q3
--Popularty of different memberships
/*
SELECT
    COALESCE(mtype_name, 'No Membership') AS "Membership Option",
    COUNT(cust_id) AS "Customer Count",
    ROUND(
        COUNT(cust_id) * 100.0 / (SELECT COUNT(cust_id) FROM customer),
        2
    ) AS "Percentage"
FROM
    customer 
LEFT JOIN membership -- left join to include customers with no membership.
    ON cust_mem_id = mem_id
    AND mem_status = 'Active'
LEFT JOIN membership_type  
    ON mem_type_id = mtype_id 
GROUP BY
    COALESCE(mtype_name, 'No Membership')
ORDER BY
    "Percentage" DESC;
*/

--Q4
--Courtesy car availability on 2024-12-28
/*
WITH courtesy_availability AS ( 
    SELECT
        cb_court_id,
        MIN(cb_return_date) FILTER ( -- if car is reserved/taken on the chosen date, busy_until is not null
            WHERE DATE '2024-12-28' BETWEEN cb_start_date AND cb_return_date -- Even though the result of filtering cannot be more than one,
        ) AS busy_until, -- It allows to have null values, with default WHERE Clause those rows would be simply excluded. 
        MIN(cb_start_date) FILTER (
            WHERE cb_start_date > DATE '2024-12-28'
        ) AS next_booking -- Attaches next booking after the date if there is one.
    FROM
        courtesy_booking 
    GROUP BY
        cb_court_id
)

SELECT
    CONCAT_WS(' ', court_make, court_model, court_year) as "Courtesy Car",
    court_reg_num AS "Registration Number",
    CASE 
        WHEN ca.busy_until IS NOT NULL THEN 'No'
        ELSE 'Yes'
    END AS "Available",
    ca.busy_until AS "Return Date",
    ca.next_booking AS "Next Booking"
FROM
    courtesy_car 
LEFT JOIN courtesy_availability ca
    ON ca.cb_court_id = court_id
ORDER BY
    "Courtesy Car";
*/

--Q5
--money bussiness has made in the last 6 month
/*
WITH monthly_revenue AS (
    SELECT
        DATE(DATE_TRUNC('month', pay_time)) AS "Month", 
        SUM(pay_amount) AS monthly_revenue
    FROM payment
    WHERE pay_status = 'Completed'
    GROUP BY "Month"
)
SELECT
    TO_CHAR("Month", 'YYYY/MM') as "Date", -- DATE_TRUNC brings pay_times into corresponding monthes but on the first day,
    -- so displaying the full date might be confusing as monthly revenue on 2025/12/1 is not the same as revenue for january
    -- which is technically 2025/12/31
    ROUND(monthly_revenue / 1000, 1) AS "Monthly Revenue (Thousands £)",
    ROUND(
        SUM(monthly_revenue / 1000)  OVER (
            ORDER BY "Month"
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ),
        1
    ) AS "Six Month Revenue"
FROM monthly_revenue
ORDER BY "Month";
*/