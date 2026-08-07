/* ********************************************************************************
조인(JOIN) 이란
- 2개 이상의 테이블에 있는 컬럼들을 합쳐서 가상의 테이블을 만들어 조회하는 방식을 말한다.
 	- 소스테이블 : 내가 먼저 읽어야 한다고 생각하는 테이블
	- 타겟테이블 : 소스를 읽은 후 소스에 조인할 대상이 되는 테이블
 
- 각 테이블을 어떻게 합칠지를 표현하는 것을 조인 연산이라고 한다.
    - 조인 연산에 따른 조인종류
        - Equi join , non-equi join
- 조인의 종류
    - Inner Join 
        - 양쪽 테이블에서 조인 조건을 만족하는 행들만 합친다. 
    - Outer Join
        - 한쪽 테이블의 행들을 모두 사용하고 다른 쪽 테이블은 조인 조건을 만족하는 행만 합친다. 조인조건을 만족하는 행이 없는 경우 NULL을 합친다.
        - 종류 : Left Outer Join,  Right Outer Join, Full Outer Join
    - Cross Join
        - 두 테이블의 곱집합을 반환한다. 
******************************************************************************** */        
/* **********************
GUIDE: 크로스조인
SELECT * 
  FROM t1 CROSS JOIN t2;
* **********************/
select e.emp_name, d.dept_name
from emp e cross join dept d;


/* ****************************************
-- INNER JOIN
FROM  테이블a INNER JOIN 테이블b ON 조인조건 

- inner는 생략 할 수 있다.
**************************************** */
-- 직원의 ID(emp.emp_id), 이름(emp.emp_name), 입사년도(emp.hire_date), 소속부서이름(dept.dept_name)을 조회
select  emp.emp_id, emp.emp_name, emp.hire_date, dept.dept_name
from    emp inner join dept on emp.dept_id = dept.dept_id;

select  e.emp_id, e.emp_name, e.hire_date, 
        d.dept_name
from    emp e inner join dept d on e.dept_id = d.dept_id;
-- emp e : e 테입블이름의 별칭(alias)


-- 직원의 ID(emp.emp_id)가 100인 직원의 직원_ID(emp.emp_id), 이름(emp.emp_name), 입사년도(emp.hire_date), 소속부서이름(dept.dept_name)을 조회.
select  e.emp_id, e.emp_name, e.hire_date, d.dept_name
from    emp e join dept d on e.dept_id = d.dept_id
where   e.emp_id = 100;

-- 직원_ID(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary), 담당업무명(job.job_title), 소속부서이름(dept.dept_name)을 조회
select  e.emp_id, e.emp_name, e.salary,
        j.job_title,
        d.dept_name
from    emp e join job j on e.job_id = j.job_id 
              join dept d on e.dept_id = d.dept_id;


-- 부서_ID(dept.dept_id)가 30인 부서의 이름(dept.dept_name), 위치(dept.loc), 그 부서에 소속된 직원의 이름(emp.emp_name)을 조회.
select  d.dept_id, d.dept_name, d.loc, 
        e.emp_name
from    dept d join emp e on d.dept_id = e.dept_id
where   d.dept_id = 30;

-- 직원의 ID(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary), 급여등급(salary_grade.grade) 를 조회. 급여 등급 오름차순으로 정렬
select  e.emp_id, e.emp_name, e.salary,
        concat(s.grade,' 등급') grade
from    emp e join salary_grade s on e.salary between s.low_sal and s.high_sal; -- non equi join


-- TODO 직원 id(emp.emp_id)가 200번대(200 ~ 299)인 직원들의  
-- 직원_ID(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary), 소속부서이름(dept.dept_name), 부서위치(dept.loc)를 조회. 직원_ID의 내림차순으로 정렬.
select e.emp_id, e.emp_name, e.salary, d.dept_name, d.loc
from   emp e join dept d on e.dept_id = d.dept_id
where  e.emp_id between 200 and 299
order by e.emp_id desc;


-- TODO 업무(emp.job_id)가 'FI_ACCOUNT'인 직원의 ID(emp.emp_id), 이름(emp.emp_name),
-- 업무(emp.job_id), 소속부서이름(dept.dept_name), 부서위치(dept.loc)를 조회. 직원_ID의 내림차순으로 정렬.
select  e.emp_id, e.emp_name, e.job_id, d.dept_name, d.loc
from    emp e join dept d on e.dept_id = d.dept_id
where   e.job_id = 'FI_ACCOUNT'
order by e.emp_id desc;


-- TODO 커미션을(emp.comm_pct) 받는 직원들의 직원_ID(emp.emp_id), 이름(emp.emp_name),
-- 급여(emp.salary), 커미션비율(emp.comm_pct), 소속부서이름(dept.dept_name), 부서위치(dept.loc)를 조회. 직원_ID의 내림차순으로 정렬.
select e.emp_id, e.emp_name, e.salary, e.comm_pct, d.dept_name, d.loc
from   emp e join dept d on e.dept_id = d.dept_id
where  e.comm_pct is not null
order by e.emp_id desc;

-- TODO 'New York'에 위치한(dept.loc) 부서의 부서_ID(dept.dept_id), 부서이름(dept.dept_name), 위치(dept.loc), 
-- 그 부서에 소속된 직원_ID(emp.emp_id), 직원 이름(emp.emp_name), 업무(emp.job_id)를 조회. 
select   d.dept_id, d.dept_name, d.loc,
         e.emp_id, e.emp_name, e.job_id
from     dept d join emp e on d.dept_id = e.dept_id
-- from       emp e join dept d on e.dept_id = d.dept_id
where    d.loc='New York';


-- TODO 직원_ID(emp.emp_id), 이름(emp.emp_name), 업무_ID(emp.job_id), 업무명(job.job_title) 를 조회.
select  e.emp_id, e.emp_name, e.job_id, j.job_title
from    emp e join job j on e.job_id = j.job_id;
      
      
-- TODO: 직원 ID 가 200 인 직원의 직원_ID(emp.emp_id), 이름(emp.emp_name), 
-- 급여(emp.salary), 담당업무명(job.job_title), 소속부서이름(dept.dept_name)을 조회              
select  e.emp_id, e.emp_name, e.salary, 
        j.job_title, d.dept_name
from    emp e join job j on e.job_id = j.job_id 
              join dept d on e.dept_id = d.dept_id
where   e.emp_id = 200;              

-- TODO: 'Shipping' 부서의 부서명(dept.dept_name), 위치(dept.loc), 
-- 소속 직원의 이름(emp.emp_name), 업무명(job.job_title)을 조회. 직원이름 내림차순으로 정렬
select  d.dept_name, d.loc, e.emp_name, j.job_title
from    dept d join emp e on d.dept_id = e.dept_id
               join job j on j.job_id = e.job_id
where   d.dept_name = 'Shipping'
order by e.emp_name desc;


-- TODO: 'San Francisco' 에 근무(dept.loc)하는 직원의 id(emp.emp_id), 
-- 이름(emp.emp_name), 입사일(emp.hire_date)를 조회 입사일은 'yyyy년 mm월 dd일' 형식으로 출력
select e.emp_id, e.emp_name, date_format(e.hire_date, '%Y년 %m월 %d일') hire_date
from   emp e join dept d on e.dept_id = d.dept_id
where  d.loc = 'San Francisco';


-- TODO 부서별 급여(salary)의 평균을 조회. 부서이름(dept.dept_name)과 급여평균을 출력. 급여 평균이 높은 순서로 정렬. 

-- select dept_id, avg(salary) from emp group by dept_id;
select  d.dept_name, round(avg(salary), 2) as 평균급여
from    emp e join dept d on e.dept_id = d.dept_id
group by d.dept_name
order by 2 desc;



-- TODO 직원의 ID(emp.emp_id), 이름(emp.emp_name), 업무명(job.job_title), 
-- 급여(emp.salary), 급여등급(salary_grade.grade), 소속부서명(dept.dept_name)을 조회. 등급 내림차순으로 정렬
select e.emp_id, e.emp_name, j.job_title, e.salary, s.grade, d.dept_name
from   emp e join job j on e.job_id = j.job_id
             join dept d on e.dept_id = d.dept_id
             join salary_grade s on e.salary between s.low_sal and s.high_sal
order by s.grade desc;


-- TODO salary 등급(salary_grade.grade)이 1인 직원들이 부서별로 몇명있는지 조회. 직원수가 많은 부서 순서대로 정렬.

select  dept_name, count(*) 직원수
from    emp e join salary_grade s on e.salary between s.low_sal and s.high_sal
              join dept d on e.dept_id = d.dept_id
where   s.grade = 1 
group by dept_name
order by 2 desc;


/* ****************************************************
Self 조인
- 물리적으로 하나의 테이블을 두개의 테이블처럼 조인하는 것.
**************************************************** */
-- 직원 ID가 101인 직원의 직원의 ID(emp.emp_id), 이름(emp.emp_name), 상사이름(emp.emp_name)을 조회

select  e.emp_id, e.emp_name 직원이름, 
        m.emp_name 상사이름
from    emp e join emp m on e.mgr_id = m.emp_id
where   e.emp_id = 101;





/* ****************************************************************************
외부 조인 (Outer Join)
- 불충분 조인
    - 조인 연산 조건을 만족하지 않는 행도 포함해서 합친다
종류
 left  outer join: 구문상 소스 테이블이 왼쪽
 right outer join: 구문상 소스 테이블이 오른쪽
 full outer join:  둘다 소스 테이블 (Mysql은 지원하지 않는다. - union 연산을 이용해서 구현)

- 구문
from 테이블a [LEFT | RIGHT] OUTER JOIN 테이블b ON 조인조건
- OUTER는 생략 가능.

**************************************************************************** */


-- 직원의 id(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary), 부서명(dept.dept_name), 부서위치(dept.loc)를 조회. 
-- 부서가 없는 직원의 정보도 나오도록 조회. dept_name의 내림차순으로 정렬한다.

select  e.emp_id, e.emp_name, e.salary, d.dept_name, d.loc
from emp e left outer join dept d on e.dept_id = d.dept_id
where e.emp_id in (100, 175, 178, 183, 185); -- 부서 id가 null 인 직원들.



select d.dept_id, d.dept_name, d.loc, e.emp_name, e.hire_date
from emp e right outer join dept d on e.dept_id = d.dept_id
where d.dept_id in (260, 270, 10, 60); -- 260, 270 번 부서는 직원이 없다.


-- full outer join -- union을 이용
select  e.emp_id, e.emp_name, e.salary, d.dept_name, d.loc
from emp e left outer join dept d on e.dept_id = d.dept_id
UNION
select  e.emp_id, e.emp_name, e.salary, d.dept_name, d.loc
from emp e right outer join dept d on e.dept_id = d.dept_id;


-- 모든 직원의 id(emp.emp_id), 이름(emp.emp_name), 부서_id(emp.dept_id)를 조회하는데
-- 부서_id가 80 인 직원들은 부서명(dept.dept_name)과 부서위치(dept.loc) 도 같이 출력한다. (부서 ID가 80이 아니면 null이 나오도록)
-- **Guide**: 이거 하고 나니까 언제 where절에 넣고 언제 from(조인)으로 넣는지 헷깔려 한다.
--       	 소스는 어짜피 다 붙으므로 어디에 넣든 상관이 없다. (그래서 inner join은 상관 없다. 그리고 아래 예제들은 다 where 에 넣는다. ) 
--       	 타겟에 대한 조건일 경우 이 상황을 생각해 봐야 한다. (그 조건(dept_id=80) 을 제외하고도 나와야 하면 조인 조건으로 그 조건만 조회할 것이면 where 조건으로 넣는다.

select  e.emp_id,
		e.emp_name,
		e.dept_id,
		d.dept_name,
		d.loc
from    emp e left join dept d on e.dept_id = d.dept_id and d.dept_id=80
-- where   d.dept_id = 80
order by d.dept_id desc;

        
-- TODO: 직원_id(emp.emp_id)가 100, 110, 120, 130, 140인 
--  직원의 ID(emp.emp_id),이름(emp.emp_name), 업무명(job.job_title) 을 조회. 업무명이 없을 경우 '미배정' 으로 조회
-- GUIDE: select * from emp where emp_id in (100, 110, 120, 130, 140);

select  e.emp_id, 
		e.emp_name,
		ifnull(j.job_title, '미배정') job_title
from    emp e left join job j on e.job_id = j.job_id 
where   e.emp_id in (100,110,120,130,140);		


-- TODO: 부서 ID(dept.dept_id), 부서이름(dept.dept_name)과 그 부서에 속한 직원들의 수를 조회. 직원이 없는 부서는 0이 나오도록 조회하고 직원수가 많은 부서 순서로 조회.
-- count(*) : 행수
-- GUIDE: count(*): 행을 수를 세므로 직원이 없어도 1이나온다.(부서정보로 행들이 한개는 조회되므로) 그래서 컬럼명을 넣어야 한다.

select  d.dept_id, d.dept_name, count(e.emp_id) 직원수 -- 내가 세려고 하는 데이터 테이블의 PK로 count
from    dept d left join emp e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
order by 3 desc;


-- TODO: EMP 테이블에서 부서_ID(emp.dept_id)가 90 인 모든 직원들의 id(emp.emp_id), 이름(emp.emp_name), 상사이름(emp.emp_name), 입사일(emp.hire_date)을 조회. 
-- 입사일은 yyyy/mm/dd 형식으로 출력

-- select * from emp where mgr_id is null; -- GUIDE 상사가 없는 직원이 있으므로 left join

select  e.emp_id, 
		e.emp_name "직원이름",
		m.emp_name "상사이름",
		date_format(e.hire_date, '%Y/%m/%d') "입사일"
from    emp e left join emp m on e.mgr_id = m.emp_id
where   e.dept_id = 90;

-- e:직원, m:상사

-- TODO 2003년~2005년 사이에 입사한 모든 직원의 id(emp.emp_id), 이름(emp.emp_name), 업무명(job.job_title), 급여(emp.salary), 입사일(emp.hire_date),
-- 상사이름(emp.emp_name), 상사의입사일(emp.hire_date), 소속부서이름(dept.dept_name), 부서위치(dept.loc)를 조회.

select  e.emp_id,	
		e.emp_name,
		j.job_id,
		e.salary,
		e.hire_date,
		m.emp_name "상사이름",
		m.hire_date "상사입사일",
		d.dept_name,
		d.loc
from    emp e left join job j on e.job_id = j.job_id
		      left join emp m on e.mgr_id = m.emp_id -- 상사
			  left join dept d on e.dept_id = d.dept_id
where   year(e.hire_date) between 2003 and 2005
order by hire_date;


-- TODO: New York(dept.loc) 에 있는 부서의 직원들의 업부명(job.job_title)을 조회 
--  job + emp(낀것) + dept

select j.job_title
from   dept d left join emp e on d.dept_id = e.dept_id
			  left join job j on e.job_id = j.job_id
where  d.loc = 'New York';


select  e.emp_id, 
		d.*,  -- dept의 모든 컬럼을 조회.
        j.job_title, 
        m.emp_name "상사이름"
from    emp e left join job j on e.job_id = j.job_id
              left join dept d on e.dept_id = d.dept_id
              left join emp m on e.mgr_id = m.emp_id     -- m: 상사, e: 직원
where   year(e.hire_date) between 2003 and 2005;





























