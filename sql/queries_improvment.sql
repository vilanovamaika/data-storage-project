-- QUERIES SCRIPT
-- NAME : Maika Vilanova Almagia
-- GROUP NUMBER : 56

-- QUERY 1: 

SELECT 
    cl.course_code,
    ci.id AS instance_id,
    cl.hp,
    ci.study_period,
    ci.num_students,

    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor ELSE 0 END), 0) AS lecture_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor ELSE 0 END), 0) AS tutorial_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN pa.planned_hours * ta.factor ELSE 0 END), 0) AS lab_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor ELSE 0 END), 0) AS seminar_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Others' THEN pa.planned_hours * ta.factor ELSE 0 END), 0) AS other_overhead_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Administration' THEN pa.planned_hours * ta.factor ELSE 0 END), 0) AS admin_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Examination' THEN pa.planned_hours * ta.factor ELSE 0 END), 0) AS exam_hours,
    COALESCE(SUM(pa.planned_hours * ta.factor), 0) AS total_hours

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.id
LEFT JOIN planned_activity pa ON pa.instance_id = ci.id      
LEFT JOIN teaching_activity ta ON pa.activity_id = ta.id     

WHERE ci.study_year = 2025
GROUP BY 
    cl.course_code,
    ci.id,
    cl.hp,
    ci.study_period,
    ci.num_students;


-- QUERY 2: 
SELECT 
    cl.course_code,
    ci.id AS instance_id,
    cl.hp,
    COALESCE(p.first_name || ' ' || p.last_name, 'Non assigné') AS teacher_name,
    COALESCE(j.job_title, 'N/A') AS Designation,

    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS lecture_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS tutorial_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS lab_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS seminar_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Others' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS other_overhead_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Administration' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS admin_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Examination' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS exam_hours,
    COALESCE(SUM(al.allocated_hours * ta.factor), 0) AS total_hours

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.id
JOIN planned_activity pa ON pa.instance_id = ci.id
JOIN teaching_activity ta ON pa.activity_id = ta.id
LEFT JOIN allocation al ON al.planned_activity_id = pa.id    
LEFT JOIN employee e ON al.employee_id = e.id                
LEFT JOIN person p ON e.person_id = p.id                     
LEFT JOIN job_title j ON e.job_id = j.id                     

WHERE cl.course_code = 'IV1351'
GROUP BY 
    cl.course_code,
    ci.id,
    cl.hp,
    teacher_name,
    Designation;


-- QUERY 3:
SELECT 
    cl.course_code,
    ci.id AS instance_id,
    cl.hp,
    ci.study_period,
    p.first_name || ' ' || p.last_name AS teacher_name,

    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS lecture_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS tutorial_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS lab_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS seminar_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Others' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS other_overhead_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Administration' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS admin_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Examination' THEN al.allocated_hours * ta.factor ELSE 0 END), 0) AS exam_hours,
    COALESCE(SUM(al.allocated_hours * ta.factor), 0) AS total_hours

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



-- QUERY 4: 

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
    e.id,
    teacher_name,
    ci.study_period

HAVING COUNT(DISTINCT ci.id) > 5;