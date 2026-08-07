CREATE TABLE emp(
    emp_id 		INT PRIMARY KEY,
    emp_name 	VARCHAR(20) NOT NULL,
    job 		VARCHAR(35) NOT NULL,
    mgr_id 		INT,
    hire_date 	DATE NOT NULL,
    salary 		DECIMAL(7,2),    
    comm_pct 	DECIMAL(2,2),
    dept_name 	VARCHAR(30)
);
