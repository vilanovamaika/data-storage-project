-- QUERIES SCRIPT
-- NAME : Maika Vilanova Almagia
-- GROUP NUMBER : 56

-- QUERIE 1
SELECT 
    cl.course_code,
    ci.id AS instance_id,
    cl.hp,
    ci.study_period,
    ci.num_students,

    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN pa.planned_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Others' THEN pa.planned_hours * ta.factor ELSE 0 END) AS other_overhead_hours,
    SUM(CASE WHEN ta.activity_name = 'Administration' THEN pa.planned_hours * ta.factor ELSE 0 END) AS admin_hours,
    SUM(CASE WHEN ta.activity_name = 'Examination' THEN pa.planned_hours * ta.factor ELSE 0 END) AS exam_hours,
    SUM(pa.planned_hours * ta.factor) AS total_hours

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.id
JOIN planned_activity pa ON pa.instance_id = ci.id
JOIN teaching_activity ta ON pa.activity_id = ta.id

WHERE ci.study_year = 2025
GROUP BY 
    cl.course_code,
    ci.id,
    cl.hp,
    ci.study_period,
    ci.num_students;

-- QUERIE 2
SELECT 
    cl.course_code,
    ci.id AS instance_id,
    cl.hp,
    p.first_name || ' ' || p.last_name AS teacher_name,
    j.job_title AS Designation,

    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN al.allocated_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN al.allocated_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN al.allocated_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN al.allocated_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Others' THEN al.allocated_hours * ta.factor ELSE 0 END) AS other_overhead_hours,
    SUM(CASE WHEN ta.activity_name = 'Administration' THEN al.allocated_hours * ta.factor ELSE 0 END) AS admin_hours,
    SUM(CASE WHEN ta.activity_name = 'Examination' THEN al.allocated_hours * ta.factor ELSE 0 END) AS exam_hours,

    SUM(al.allocated_hours * ta.factor) AS total_hours


FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.id
JOIN planned_activity pa ON pa.instance_id = ci.id
JOIN teaching_activity ta ON pa.activity_id = ta.id
JOIN allocation al ON al.planned_activity_id = pa.id
JOIN employee e ON al.employee_id = e.id
JOIN person p ON e.person_id = p.id
JOIN job_title j ON e.job_id = j.id

WHERE cl.course_code = 'IV1351'
GROUP BY 
    cl.course_code,
    ci.id,
    cl.hp,
    teacher_name,
    Designation;


-- QUERIE 3
SELECT 
    cl.course_code,
    ci.id AS instance_id,
    cl.hp,
    ci.study_period,
    p.first_name || ' ' || p.last_name AS teacher_name,


    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN al.allocated_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN al.allocated_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN al.allocated_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN al.allocated_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Others' THEN al.allocated_hours * ta.factor ELSE 0 END) AS other_overhead_hours,
    SUM(CASE WHEN ta.activity_name = 'Administration' THEN al.allocated_hours * ta.factor ELSE 0 END) AS admin_hours,
    SUM(CASE WHEN ta.activity_name = 'Examination' THEN al.allocated_hours * ta.factor ELSE 0 END) AS exam_hours,

    SUM(al.allocated_hours * ta.factor) AS total_hours

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.id
JOIN planned_activity pa ON pa.instance_id = ci.id
JOIN teaching_activity ta ON pa.activity_id = ta.id
JOIN allocation al ON al.planned_activity_id = pa.id
JOIN employee e ON al.employee_id = e.id
JOIN person p ON e.person_id = p.id

WHERE e.id = 1 AND ci.study_year = 2025

GROUP BY 
    cl.course_code,
    ci.id,
    cl.hp,
    ci.study_period,
    teacher_name;
   

-- QUERIE 4
SELECT 
    e.id AS employment_id,
    p.first_name || ' ' || p.last_name AS teacher_name,
    ci.study_period,
    COUNT(DISTINCT ci.id) AS number_of_courses


FROM course_instance ci
JOIN planned_activity pa ON pa.instance_id = ci.id
JOIN allocation al ON al.planned_activity_id = pa.id
JOIN employee e ON al.employee_id = e.id
JOIN person p ON e.person_id = p.id

WHERE ci.study_period = 'P2'

GROUP BY 
    employment_id,
    teacher_name,
    ci.study_period

HAVING COUNT(DISTINCT ci.id) > 5;
