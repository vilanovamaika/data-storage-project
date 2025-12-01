-- DATA BASE CREATION SCRIPT
-- NAME : Maika Vilanova Almagia
-- GROUP NUMBER : 56

-- LOOKUP TABLES :

--  rules (like max courses per period)
CREATE TABLE allocation_rule (
    id           INT          NOT NULL,
    rule_name    VARCHAR(100) NOT NULL,
    rule_value   INT          NOT NULL,
    
    CONSTRAINT pk_allocation_rule PRIMARY KEY (id),
    CONSTRAINT uq_allocation_rule_name UNIQUE (rule_name)
);

-- Parameters for exam and admin hour calculations
CREATE TABLE formula_parameter (
    id               INT           NOT NULL,
    formula_name     VARCHAR(50)   NOT NULL,
    parameter_name   VARCHAR(50)   NOT NULL,
    parameter_value  NUMERIC(10,3) NOT NULL,
    
    CONSTRAINT pk_formula_parameter PRIMARY KEY (id),
    CONSTRAINT uq_formula_param UNIQUE (formula_name, parameter_name)
);

-- Teaching activity types with multiplication factors
CREATE TABLE teaching_activity (
    id            INT         NOT NULL,
    activity_name VARCHAR(30) NOT NULL,
    factor        NUMERIC(3,1) NOT NULL,
    
    CONSTRAINT pk_teaching_activity PRIMARY KEY (id),
    CONSTRAINT uq_teaching_activity_name UNIQUE (activity_name)
);

-- Job titles for employees 
CREATE TABLE job_title (
    id        INT         NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    
    CONSTRAINT pk_job_title PRIMARY KEY (id),
    CONSTRAINT uq_job_title UNIQUE (job_title)
);


-- CORE ENTITY TABLES :
 

-- Personal information for all individuals
CREATE TABLE person (
    id              INT          NOT NULL,
    personal_number CHAR(10)     NOT NULL,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    address         VARCHAR(200),
    
    CONSTRAINT pk_person PRIMARY KEY (id),
    CONSTRAINT uq_person_number UNIQUE (personal_number)
);

-- Phone numbers (multi-valued attribute)
CREATE TABLE phone (
    person_id INT         NOT NULL,
    phone     VARCHAR(20) NOT NULL,
    
    CONSTRAINT pk_phone PRIMARY KEY (person_id, phone),
    CONSTRAINT fk_phone_person FOREIGN KEY (person_id) 
        REFERENCES person(id) ON DELETE CASCADE
);

-- Academic departments
CREATE TABLE department (
    id              INT         NOT NULL,
    department_name VARCHAR(50) NOT NULL,
    manager_id      INT,
    
    CONSTRAINT pk_department PRIMARY KEY (id),
    CONSTRAINT uq_department_name UNIQUE (department_name)
);

-- Employment information
CREATE TABLE employee (
    id             INT          NOT NULL,
    skill_set      VARCHAR(200),
    person_id      INT          NOT NULL,
    job_id         INT          NOT NULL,
    department_id  INT          NOT NULL,
    supervisor_id  INT,
    
    CONSTRAINT pk_employee PRIMARY KEY (id),
    CONSTRAINT uq_employee_person UNIQUE (person_id),
    CONSTRAINT fk_employee_person FOREIGN KEY (person_id) 
        REFERENCES person(id) ON DELETE CASCADE,
    CONSTRAINT fk_employee_job FOREIGN KEY (job_id) 
        REFERENCES job_title(id),
    CONSTRAINT fk_employee_department FOREIGN KEY (department_id) 
        REFERENCES department(id),
    CONSTRAINT fk_employee_supervisor FOREIGN KEY (supervisor_id) 
        REFERENCES employee(id)
);

-- Add manager FK to department (circular dependency handled by nullable FK)
ALTER TABLE department
    ADD CONSTRAINT fk_department_manager FOREIGN KEY (manager_id) 
        REFERENCES employee(id);

-- Salary history 
CREATE TABLE salary_history (
    id           INT            NOT NULL,
    employee_id  INT            NOT NULL,
    salary       NUMERIC(10,2)  NOT NULL,
    valid_from   DATE           NOT NULL,
    valid_until  DATE,
    
    CONSTRAINT pk_salary_history PRIMARY KEY (id),
    CONSTRAINT uq_salary_version UNIQUE (employee_id, valid_from),
    CONSTRAINT fk_salary_employee FOREIGN KEY (employee_id) 
        REFERENCES employee(id) ON DELETE CASCADE,
    CONSTRAINT chk_salary_positive CHECK (salary > 0)
);


-- Course definitions with temporal versioning
CREATE TABLE course_layout (
    id            INT           NOT NULL,
    course_code   CHAR(10)      NOT NULL,
    course_name   VARCHAR(100)  NOT NULL,
    min_students  INT           NOT NULL,
    max_students  INT           NOT NULL,
    hp            NUMERIC(3,1)  NOT NULL,
    valid_from    DATE          NOT NULL,
    valid_until   DATE,
    
    CONSTRAINT pk_course_layout PRIMARY KEY (id),
    CONSTRAINT uq_course_version UNIQUE (course_code, valid_from),
    CONSTRAINT chk_students CHECK (min_students <= max_students),
    CONSTRAINT chk_hp_positive CHECK (hp > 0)
);

-- Specific course offerings in a given period
CREATE TABLE course_instance (
    id           INT     NOT NULL,
    num_students INT     NOT NULL,
    study_period CHAR(2) NOT NULL,
    study_year   INT     NOT NULL,
    course_id    INT     NOT NULL,
    
    CONSTRAINT pk_course_instance PRIMARY KEY (id),
    CONSTRAINT fk_instance_layout FOREIGN KEY (course_id) 
        REFERENCES course_layout(id),
    CONSTRAINT chk_period CHECK (study_period IN ('P1', 'P2', 'P3', 'P4')),
    CONSTRAINT chk_students_positive CHECK (num_students > 0)
);

-- Planned activity (hours planned for each activity in a course instance)
CREATE TABLE planned_activity (
    id             INT           NOT NULL,
    planned_hours  NUMERIC(5,1)  NOT NULL,
    activity_id    INT           NOT NULL,
    instance_id    INT           NOT NULL,
    
    CONSTRAINT pk_planned_activity PRIMARY KEY (id),
    CONSTRAINT fk_planned_activity FOREIGN KEY (activity_id) 
        REFERENCES teaching_activity(id),
    CONSTRAINT fk_planned_instance FOREIGN KEY (instance_id) 
        REFERENCES course_instance(id) ON DELETE CASCADE,
    CONSTRAINT chk_hours_positive CHECK (planned_hours > 0)
);

-- Allocation (assigns teachers to planned activities)
CREATE TABLE allocation (
    planned_activity_id INT           NOT NULL,
    employee_id         INT           NOT NULL,
    allocated_hours     NUMERIC(5,1)  NOT NULL,
    
    CONSTRAINT pk_allocation PRIMARY KEY (planned_activity_id, employee_id),
    CONSTRAINT fk_allocation_activity FOREIGN KEY (planned_activity_id) 
        REFERENCES planned_activity(id) ON DELETE CASCADE,
    CONSTRAINT fk_allocation_employee FOREIGN KEY (employee_id) 
        REFERENCES employee(id),
    CONSTRAINT chk_allocated_hours_positive CHECK (allocated_hours > 0)
);

