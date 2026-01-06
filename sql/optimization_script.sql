-- OPTIMIZATION SCRIPT FOR HIGHER GRADE
-- NAME : Maika Vilanova Almagia
-- GROUP NUMBER : 56

-- BASE TABLE INDEXES
CREATE INDEX IF NOT EXISTS idx_ci_year ON course_instance(study_year);
CREATE INDEX IF NOT EXISTS idx_ci_period ON course_instance(study_period);
CREATE INDEX IF NOT EXISTS idx_cl_code ON course_layout(course_code);

CREATE INDEX IF NOT EXISTS idx_pa_instance ON planned_activity(instance_id);
CREATE INDEX IF NOT EXISTS idx_al_pa ON allocation(planned_activity_id);
CREATE INDEX IF NOT EXISTS idx_al_emp ON allocation(employee_id);

--  Materialized view for the high-frequency workload (teachers > N courses)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_teacher_courses_per_period AS
SELECT
  e.id AS employment_id,
  ci.study_period,
  COUNT(DISTINCT ci.id) AS number_of_courses
FROM course_instance ci
JOIN planned_activity pa ON pa.instance_id = ci.id
JOIN allocation al ON al.planned_activity_id = pa.id
JOIN employee e ON al.employee_id = e.id
GROUP BY e.id, ci.study_period;

CREATE UNIQUE INDEX IF NOT EXISTS mv_teacher_courses_per_period_uq
ON mv_teacher_courses_per_period (employment_id, study_period);

REFRESH MATERIALIZED VIEW mv_teacher_courses_per_period;
