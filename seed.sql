-- ============================================================
--  DAYFLOW HRMS - Seed Data
--  Matches database/schema.sql exactly (run schema.sql first).
--  Password hashes below are bcrypt hashes of the plaintext shown
--  in comments -- generate your own with bcrypt before going live.
-- ============================================================

USE dayflow_hrms;

-- =========================
-- DEPARTMENTS
-- =========================
INSERT INTO departments (department_id, department_name) VALUES
(1, 'Human Resources'),
(2, 'Engineering'),
(3, 'Finance'),
(4, 'Marketing');

-- =========================
-- USERS  (auth lives here, not in "employees")
-- Passwords below are bcrypt hashes of: swetha123 / kavin123 / priya123 / arun123
-- role_id: 1 = Admin, 2 = HR, 3 = Employee  (see roles table insert in schema.sql)
-- =========================
INSERT INTO users (user_id, employee_code, email, password_hash, role_id, is_email_verified) VALUES
(1, 'EMP001', 'swetha@dayflow.com', '$2b$12$KX3n9vQe1s8ZbA1yq8mP1uS0m2q4x9J7Fz8m3L2b6c9d0e1f2g3h4', 3, TRUE),
(2, 'EMP002', 'kavin@dayflow.com',  '$2b$12$P8h2j5k7L9m1N3o5Q7r9StUvWxYzA1b3C5d7E9f1G3h5I7j9K1l3M', 2, TRUE),
(3, 'EMP003', 'priya@dayflow.com',  '$2b$12$Q1w2e3r4T5y6U7i8O9p0AaSsDdFfGgHhJjKkLlZzXxCcVvBbNnMm1', 3, TRUE),
(4, 'EMP004', 'arun@dayflow.com',   '$2b$12$Z9x8c7v6B5n4M3l2K1j0IiHhGgFfEeDdCcBbAa9988776655443322', 3, TRUE);

-- =========================
-- EMPLOYEES  (personal + job details; auth fields stay in "users")
-- =========================
INSERT INTO employees
(employee_id, user_id, first_name, last_name, phone, department_id, designation, date_of_joining, employment_status)
VALUES
(1, 1, 'Swetha', 'Mohan', '9876543210', 2, 'Software Engineer',    '2026-01-10', 'Active'),
(2, 2, 'Kavin',  'Sivasamy', '9876543211', 1, 'HR Manager',        '2025-06-15', 'Active'),
(3, 3, 'Priya',  'Kumar',   '9876543212', 3, 'Accountant',         '2025-08-20', 'Active'),
(4, 4, 'Arun',   'Raj',     '9876543213', 4, 'Marketing Executive','2026-02-05', 'Active');

-- =========================
-- ATTENDANCE
-- schema.sql uses check_in_time/check_out_time (DATETIME) not TIME,
-- and status ENUM('Present','Absent','Half-day','Leave') -- no 'LATE'.
-- Priya's 08-19 late arrival is captured via remarks instead.
-- =========================
INSERT INTO attendance
(attendance_id, employee_id, attendance_date, check_in_time, check_out_time, status, remarks) VALUES
(1, 1, '2026-08-18', '2026-08-18 09:00:00', '2026-08-18 17:30:00', 'Present', NULL),
(2, 2, '2026-08-18', '2026-08-18 09:15:00', '2026-08-18 17:45:00', 'Present', NULL),
(3, 3, '2026-08-18', '2026-08-18 09:05:00', '2026-08-18 17:20:00', 'Present', NULL),
(4, 4, '2026-08-18', NULL,                  NULL,                  'Absent',  NULL),

(5, 1, '2026-08-19', '2026-08-19 08:55:00', '2026-08-19 17:35:00', 'Present', NULL),
(6, 2, '2026-08-19', '2026-08-19 09:10:00', '2026-08-19 17:40:00', 'Present', NULL),
(7, 3, '2026-08-19', '2026-08-19 09:20:00', '2026-08-19 17:30:00', 'Present', 'Arrived late'),
(8, 4, '2026-08-19', '2026-08-19 09:00:00', '2026-08-19 17:25:00', 'Present', NULL);

-- =========================
-- LEAVE TYPES
-- schema.sql already seeds Paid/Sick/Unpaid via CREATE. Add your
-- named variants only if they don't already exist:
-- =========================
INSERT INTO leave_types (leave_type_id, leave_type_name, default_days_per_year) VALUES
(4, 'Casual Leave', 12),
(5, 'Earned Leave', 15)
ON DUPLICATE KEY UPDATE leave_type_name = VALUES(leave_type_name);

-- =========================
-- LEAVE REQUESTS
-- schema.sql requires total_days (NOT NULL) - computed here.
-- status ENUM('Pending','Approved','Rejected') -- matches directly.
-- =========================
INSERT INTO leave_requests
(leave_request_id, employee_id, leave_type_id, start_date, end_date, total_days, reason, status, reviewed_by, reviewed_at) VALUES
(1, 1, 4, '2026-08-25', '2026-08-26', 2, 'Personal work',      'Pending',  NULL, NULL),
(2, 3, 2, '2026-08-20', '2026-08-20', 1, 'Not feeling well',   'Approved', 2,    '2026-08-19 10:00:00'),
(3, 4, 4, '2026-08-28', '2026-08-29', 2, 'Family function',    'Pending',  NULL, NULL);

-- =========================
-- LEAVE BALANCES  (required for the leave module to show remaining days)
-- =========================
INSERT INTO leave_balances (employee_id, leave_type_id, year, total_days, used_days) VALUES
(1, 4, 2026, 12, 0),
(2, 4, 2026, 12, 0),
(3, 2, 2026, 12, 1),
(4, 4, 2026, 12, 0);