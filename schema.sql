-- ============================================================
--  DAYFLOW - Human Resource Management System (HRMS)
--  Database Schema (Step 1: Core Data Model)
--  Compatible with: MySQL 8+ / PostgreSQL 13+
--  Note: Uses MySQL syntax (AUTO_INCREMENT, ENUM). For PostgreSQL,
--  replace AUTO_INCREMENT -> SERIAL/GENERATED ALWAYS AS IDENTITY,
--  and ENUM -> CHECK constraints or native ENUM types.
-- ============================================================

DROP DATABASE IF EXISTS dayflow_hrms;
CREATE DATABASE dayflow_hrms;
USE dayflow_hrms;

-- ============================================================
-- 1. ROLES  (Admin / HR Officer / Employee)
-- ============================================================
CREATE TABLE roles (
    role_id     INT AUTO_INCREMENT PRIMARY KEY,
    role_name   VARCHAR(50) NOT NULL UNIQUE   -- 'Admin', 'HR', 'Employee'
);

INSERT INTO roles (role_name) VALUES ('Admin'), ('HR'), ('Employee');

-- ============================================================
-- 2. DEPARTMENTS
-- ============================================================
CREATE TABLE departments (
    department_id     INT AUTO_INCREMENT PRIMARY KEY,
    department_name   VARCHAR(100) NOT NULL UNIQUE,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. USERS  (Authentication - Sign Up / Sign In)
-- ============================================================
CREATE TABLE users (
    user_id            INT AUTO_INCREMENT PRIMARY KEY,
    employee_code      VARCHAR(20) NOT NULL UNIQUE,     -- e.g. EMP-0001 (business Employee ID)
    email              VARCHAR(150) NOT NULL UNIQUE,
    password_hash      VARCHAR(255) NOT NULL,           -- store bcrypt/argon2 hash, never plain text
    role_id            INT NOT NULL,
    is_email_verified  BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_token        VARCHAR(255),
    reset_token_expiry DATETIME,
    is_active          BOOLEAN DEFAULT TRUE,
    last_login_at      DATETIME,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- ============================================================
-- 4. EMPLOYEES  (Profile Management - personal + job details)
-- ============================================================
CREATE TABLE employees (
    employee_id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT NOT NULL UNIQUE,
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100) NOT NULL,
    gender              ENUM('Male','Female','Other'),
    date_of_birth       DATE,
    phone               VARCHAR(20),
    address             VARCHAR(255),
    profile_picture_url VARCHAR(255),

    -- Job details
    department_id       INT,
    designation          VARCHAR(100),
    date_of_joining      DATE,
    employment_type      ENUM('Full-Time','Part-Time','Contract','Intern') DEFAULT 'Full-Time',
    employment_status    ENUM('Active','On Leave','Resigned','Terminated') DEFAULT 'Active',
    reporting_manager_id INT,                           -- self-reference to employees.employee_id

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (reporting_manager_id) REFERENCES employees(employee_id)
);

-- ============================================================
-- 5. EMPLOYEE DOCUMENTS  (ID proofs, certificates, resume, etc.)
-- ============================================================
CREATE TABLE employee_documents (
    document_id     INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    document_type   VARCHAR(100) NOT NULL,   -- e.g. 'Aadhaar', 'Resume', 'Offer Letter'
    file_url        VARCHAR(255) NOT NULL,
    uploaded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- ============================================================
-- 6. ATTENDANCE  (Daily/Weekly tracking, check-in/check-out)
-- ============================================================
CREATE TABLE attendance (
    attendance_id   INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    attendance_date DATE NOT NULL,
    check_in_time   DATETIME,
    check_out_time  DATETIME,
    status          ENUM('Present','Absent','Half-day','Leave') NOT NULL DEFAULT 'Present',
    remarks         VARCHAR(255),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    UNIQUE KEY uq_employee_date (employee_id, attendance_date)  -- one record per employee per day
);

-- ============================================================
-- 7. LEAVE TYPES  (Paid, Sick, Unpaid, etc.)
-- ============================================================
CREATE TABLE leave_types (
    leave_type_id         INT AUTO_INCREMENT PRIMARY KEY,
    leave_type_name       VARCHAR(50) NOT NULL UNIQUE,   -- 'Paid', 'Sick', 'Unpaid'
    default_days_per_year INT DEFAULT 0
);

INSERT INTO leave_types (leave_type_name, default_days_per_year) VALUES
('Paid', 18), ('Sick', 12), ('Unpaid', 0);

-- ============================================================
-- 8. LEAVE BALANCES  (per employee, per leave type, per year)
-- ============================================================
CREATE TABLE leave_balances (
    balance_id      INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    leave_type_id   INT NOT NULL,
    year            YEAR NOT NULL,
    total_days      DECIMAL(5,1) NOT NULL DEFAULT 0,
    used_days       DECIMAL(5,1) NOT NULL DEFAULT 0,
    remaining_days  DECIMAL(5,1) GENERATED ALWAYS AS (total_days - used_days) STORED,

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id),
    UNIQUE KEY uq_emp_leave_year (employee_id, leave_type_id, year)
);

-- ============================================================
-- 9. LEAVE REQUESTS  (Apply / Approve / Reject workflow)
-- ============================================================
CREATE TABLE leave_requests (
    leave_request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id      INT NOT NULL,
    leave_type_id    INT NOT NULL,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    total_days       DECIMAL(5,1) NOT NULL,
    reason           VARCHAR(500),
    status           ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',

    applied_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_by      INT,              -- FK -> users.user_id (Admin/HR who reviewed)
    reviewed_at      DATETIME,
    admin_comments   VARCHAR(500),

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id),
    FOREIGN KEY (reviewed_by) REFERENCES users(user_id)
);

-- ============================================================
-- 10. SALARY STRUCTURE  (Admin-controlled, versioned by effective date)
-- ============================================================
CREATE TABLE salary_structures (
    salary_structure_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id          INT NOT NULL,
    basic_pay            DECIMAL(12,2) NOT NULL DEFAULT 0,
    hra                  DECIMAL(12,2) NOT NULL DEFAULT 0,
    allowances           DECIMAL(12,2) NOT NULL DEFAULT 0,
    deductions           DECIMAL(12,2) NOT NULL DEFAULT 0,
    gross_salary         DECIMAL(12,2) GENERATED ALWAYS AS (basic_pay + hra + allowances) STORED,
    net_salary           DECIMAL(12,2) GENERATED ALWAYS AS (basic_pay + hra + allowances - deductions) STORED,
    effective_from       DATE NOT NULL,
    created_by           INT,   -- FK -> users.user_id (Admin who set it)

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- ============================================================
-- 11. PAYROLL  (Monthly generated payslips - read-only for employees)
-- ============================================================
CREATE TABLE payroll (
    payroll_id       INT AUTO_INCREMENT PRIMARY KEY,
    employee_id      INT NOT NULL,
    pay_month        TINYINT NOT NULL,     -- 1-12
    pay_year         YEAR NOT NULL,
    gross_salary     DECIMAL(12,2) NOT NULL,
    total_deductions DECIMAL(12,2) NOT NULL DEFAULT 0,
    net_pay          DECIMAL(12,2) NOT NULL,
    payslip_url      VARCHAR(255),
    generated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    UNIQUE KEY uq_emp_month_year (employee_id, pay_month, pay_year)
);

-- ============================================================
-- 12. NOTIFICATIONS  (Email & in-app alerts)
-- ============================================================
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id          INT NOT NULL,
    title            VARCHAR(150) NOT NULL,
    message          VARCHAR(500) NOT NULL,
    is_read          BOOLEAN DEFAULT FALSE,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================
-- 13. AUDIT LOG  (optional but recommended for HR systems)
-- ============================================================
CREATE TABLE audit_logs (
    log_id       INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT,
    action       VARCHAR(255) NOT NULL,      -- e.g. 'Approved Leave #12'
    entity_type  VARCHAR(100),               -- e.g. 'leave_requests'
    entity_id    INT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- USEFUL INDEXES
-- ============================================================
CREATE INDEX idx_attendance_date ON attendance(attendance_date);
CREATE INDEX idx_leave_status ON leave_requests(status);
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_payroll_month_year ON payroll(pay_year, pay_month);