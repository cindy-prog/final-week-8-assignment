-- Hospital Management System Database
-- Created by CYNTHIA MWAURA

-- Database creation
CREATE DATABASE hospital_db;
USE hospital_db;

-- PATIENTS TABLE
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(15),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- STAFF TABLE (Core entity)
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('Doctor', 'Nurse', 'Administrator', 'Technician', 'Other') NOT NULL,
    specialization VARCHAR(100),
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    department_id INT
) ENGINE=InnoDB;

-- DEPARTMENTS TABLE
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    head_doctor_id INT,
    description TEXT,
    FOREIGN KEY (head_doctor_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;

-- Add FK to staff table now that departments exists
ALTER TABLE staff
ADD CONSTRAINT fk_staff_department
FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- APPOINTMENTS TABLE (1-M relationship between patients and staff)
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    staff_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-show') DEFAULT 'Scheduled',
    reason TEXT,
    notes TEXT,
    duration_minutes INT DEFAULT 30,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;

-- MEDICAL_RECORDS TABLE (1-1 relationship with patients)
CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL UNIQUE,
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    blood_pressure VARCHAR(10),
    allergies TEXT,
    chronic_conditions TEXT,
    current_medications TEXT,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
) ENGINE=InnoDB;

-- TREATMENTS TABLE (M-M relationship between patients and staff)
CREATE TABLE treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    cost DECIMAL(10,2) NOT NULL,
    duration_minutes INT
) ENGINE=InnoDB;

-- Junction table for M-M relationship between staff and treatments
CREATE TABLE staff_treatments (
    staff_id INT NOT NULL,
    treatment_id INT NOT NULL,
    PRIMARY KEY (staff_id, treatment_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id)
) ENGINE=InnoDB;

-- PATIENT_TREATMENTS TABLE (M-M relationship between patients and treatments)
CREATE TABLE patient_treatments (
    patient_treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    treatment_id INT NOT NULL,
    staff_id INT NOT NULL,
    treatment_date DATETIME NOT NULL,
    notes TEXT,
    outcome TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;

-- MEDICINES TABLE
CREATE TABLE medicines (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(100),
    description TEXT,
    dosage_form VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT DEFAULT 10
) ENGINE=InnoDB;

-- PRESCRIPTIONS TABLE (1-M relationship between patients and medicines)
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    staff_id INT NOT NULL,
    issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE,
    instructions TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;

-- PRESCRIPTION_ITEMS TABLE (M-M relationship between prescriptions and medicines)
CREATE TABLE prescription_items (
    prescription_item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration_days INT NOT NULL,
    quantity INT NOT NULL,
    notes TEXT,
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id),
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
) ENGINE=InnoDB;

-- BILLING TABLE (1-1 relationship with patients)
CREATE TABLE billing (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    bill_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    paid_amount DECIMAL(10,2) DEFAULT 0,
    status ENUM('Pending', 'Partially Paid', 'Paid', 'Cancelled') DEFAULT 'Pending',
    payment_method VARCHAR(50),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
) ENGINE=InnoDB;

-- BILLING_ITEMS TABLE (1-M relationship with billing)
CREATE TABLE billing_items (
    billing_item_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    item_type ENUM('Treatment', 'Medicine', 'Room', 'Other') NOT NULL,
    description VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (bill_id) REFERENCES billing(bill_id)
) ENGINE=InnoDB;

-- ROOMS TABLE
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type ENUM('General', 'Private', 'ICU', 'Operating', 'Emergency') NOT NULL,
    department_id INT,
    status ENUM('Available', 'Occupied', 'Maintenance') DEFAULT 'Available',
    daily_rate DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
) ENGINE=InnoDB;

-- ADMISSIONS TABLE (1-M relationship between patients and rooms)
CREATE TABLE admissions (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    reason TEXT,
    attending_doctor_id INT NOT NULL,
    status ENUM('Admitted', 'Discharged', 'Transferred') DEFAULT 'Admitted',
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    FOREIGN KEY (attending_doctor_id) REFERENCES staff(staff_id),
    CONSTRAINT chk_discharge_date CHECK (discharge_date IS NULL OR discharge_date >= admission_date)
) ENGINE=InnoDB;

-- Create indexes for performance optimization
CREATE INDEX idx_patient_name ON patients(last_name, first_name);
CREATE INDEX idx_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_staff_role ON staff(role);
CREATE INDEX idx_medicine_name ON medicines(name);
CREATE INDEX idx_billing_status ON billing(status);
CREATE INDEX idx_admission_status ON admissions(status);

-- Create a view for patient appointments
CREATE VIEW patient_appointment_view AS
SELECT 
    a.appointment_id,
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    a.appointment_date,
    a.status,
    a.reason
FROM 
    appointments a
JOIN 
    patients p ON a.patient_id = p.patient_id
JOIN 
    staff s ON a.staff_id = s.staff_id;

-- Create a view for active admissions
CREATE VIEW active_admissions_view AS
SELECT 
    a.admission_id,
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    r.room_number,
    r.room_type,
    a.admission_date,
    CONCAT(s.first_name, ' ', s.last_name) AS attending_doctor,
    a.status
FROM 
    admissions a
JOIN 
    patients p ON a.patient_id = p.patient_id
JOIN 
    rooms r ON a.room_id = r.room_id
JOIN 
    staff s ON a.attending_doctor_id = s.staff_id
WHERE 
    a.status = 'Admitted';

-- Create a stored procedure for patient registration
DELIMITER //
CREATE PROCEDURE register_patient(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_dob DATE,
    IN p_gender ENUM('Male', 'Female', 'Other'),
    IN p_phone VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_address TEXT,
    IN p_emergency_contact VARCHAR(100),
    IN p_emergency_phone VARCHAR(15)
)
BEGIN
    DECLARE patient_count INT;
    
    -- Check if patient already exists
    SELECT COUNT(*) INTO patient_count
    FROM patients
    WHERE first_name = p_first_name 
    AND last_name = p_last_name
    AND date_of_birth = p_dob;
    
    IF patient_count = 0 THEN
        -- Insert new patient
        INSERT INTO patients (
            first_name, last_name, date_of_birth, gender, 
            phone, email, address, emergency_contact_name, emergency_contact_phone
        ) VALUES (
            p_first_name, p_last_name, p_dob, p_gender,
            p_phone, p_email, p_address, p_emergency_contact, p_emergency_phone
        );
        
        -- Create empty medical record
        INSERT INTO medical_records (patient_id)
        VALUES (LAST_INSERT_ID());
        
        SELECT 'Patient registered successfully' AS message;
    ELSE
        SELECT 'Patient already exists in the system' AS message;
    END IF;
END //
DELIMITER ;

-- Create a trigger to update room status when admission changes
DELIMITER //
CREATE TRIGGER after_admission_update
AFTER UPDATE ON admissions
FOR EACH ROW
BEGIN
    IF NEW.status = 'Discharged' OR NEW.status = 'Transferred' THEN
        UPDATE rooms SET status = 'Available' WHERE room_id = NEW.room_id;
    END IF;
    
    IF NEW.status = 'Admitted' THEN
        UPDATE rooms SET status = 'Occupied' WHERE room_id = NEW.room_id;
    END IF;
END //
DELIMITER ;

-- Sample data insertion (optional - can be removed for production)
-- This is just for demonstration purposes
INSERT INTO departments (name, location, description) VALUES 
('Cardiology', 'Floor 1, Wing A', 'Heart and cardiovascular system treatments'),
('Pediatrics', 'Floor 2, Wing B', 'Medical care for infants, children, and adolescents'),
('Neurology', 'Floor 3, Wing C', 'Disorders of the nervous system');

INSERT INTO staff (first_name, last_name, role, specialization, phone, email, hire_date, salary, department_id) VALUES 
('Anne', 'Mungai', 'Doctor', 'Cardiologist', '0712215997', 'annem@gmail.com', '2015-06-15', 185000.00, 1),
('Peter', 'Kuria', 'Doctor', 'Pediatrician', '0726587345', 'pter1@gmail.com', '2018-03-22', 165000.00, 2),
('Lisa', 'Wambui', 'Nurse', NULL, '0713450294', 'lisawb@gmail.com', '2019-11-05', 75000.00, 1);

UPDATE departments SET head_doctor_id = 1 WHERE department_id = 1;
UPDATE departments SET head_doctor_id = 2 WHERE department_id = 2;