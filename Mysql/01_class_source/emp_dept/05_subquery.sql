-- *************** inline view는 subquery에 테이블 별칭을 반드시 넣어야 함.
from (select xxxx) TB
/* **************************************************************************
서브쿼리(Sub Query)
- 쿼리안에서 select 쿼리를 사용하는 것.
- 메인 쿼리 - 서브쿼리

서브쿼리가 사용되는 구
 - select절, from절, where절, having절
 
서브쿼리의 종류
- 어느 구절에 사용되었는지에 따른 구분
    - 스칼라 서브쿼리 - select 절에 사용. 반드시 서브쿼리 결과가 1행 1열(값 하나-스칼라) 0행이 조회되면 null을 반환
    - 인라인 뷰 - from 절에 사용되어 테이블의 역할을 한다.
서브쿼리 조회결과 행수에 따른 구분
    - 단일행 서브쿼리 - 서브쿼리의 조회결과 행이 한행인 것.
    - 다중행 서브쿼리 - 서브쿼리의 조회결과 행이 여러행인 것.
동작 방식에 따른 구분
    - 비상관(비연관) 서브쿼리 - 서브쿼리에 메인쿼리의 컬럼이 사용되지 않는다.
                메인쿼리에 사용할 값을 서브쿼리가 제공하는 역할을 한다.
    - 상관(연관) 서브쿼리 - 서브쿼리에서 메인쿼리의 컬럼을 사용한다. 
                            메인쿼리가 먼저 수행되어 읽혀진 데이터를 서브쿼리에서 조건이 맞는지 확인하고자 할때 주로 사용한다.

- 서브쿼리는 반드시 ( ) 로 묶어줘야 한다.
************************************************************************** */
-- 직원_ID(emp.emp_id)가 120번인 직원과 같은 업무(emp.job_id)를 하는 직원의 id(emp_id),이름(emp.emp_name), 업무(emp.job_id), 급여(emp.salary) 조회
select job_id from emp where emp_id = 120;-- ST_MAN
select * from emp where job_id = 'ST_MAN';

select * from emp 
where job_id = (select job_id from emp where emp_id = 120);
-- subquery는 ( ) 로 묶어줘야 한다.

-- 직원_id(emp.emp_id)가 115번인 직원과 같은 업무(emp.job_id)를 하고 같은 부서(emp.dept_id)에 속한 직원들을 조회하시오.
select  job_id, dept_id from emp where emp_id = 115;
select * from emp where job_id='PU_MAN' and dept_id = 30;

-- pair 방식 서브쿼리.  두개 이상 컬럼 비교해도 된다.
select * from emp
where (job_id, dept_id)  = (select  job_id, dept_id from emp where emp_id = 115);

select * from emp
where (job_id, dept_id) = ('PU_MAN', 30); -- MySQL에서는 된는데 오라클에서는 pair방식은 subquery 일 경우만 가능하다.

-- 직원들 중 급여(emp.salary)가 전체 직원의 평균 급여보다 적은 직원들의 id(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary)를 조회. 
select avg(salary) from emp;
select emp_id, emp_name, salary from emp where salary < 6517.906542;

select emp_id, emp_name, salary
from   emp
where  salary < (select avg(salary) from emp)
order by salary desc;



-- 부서직원들의 평균이 전체 직원의 평균(emp.salary) 이상인 부서의 이름(dept.dept_name), 평균 급여(emp.salary) 조회.
-- 평균급여는 소숫점 2자리까지 나오고 통화표시($)와 단위 구분자 출력
select  d.dept_name, 
		concat('$', format(a.avg, 2)) as "평균급여"
from (
	select  dept_id, 
			avg(salary) as "avg"
	from    emp
	group by dept_id
	having avg(salary) > (select avg(salary) from emp)
	order by 2
	) a left join dept d on a.dept_id = d.dept_id;

---------- OR
select dept_name, concat('$', format(sal, 2))
from (
	select d.dept_name, avg(salary) sal
	from   emp e left join dept d on e.dept_id = d.dept_id
	group by d.dept_name
	having  avg(salary) > (select avg(salary) from emp)
	order by 2
) t;    
-- GUIDE1: order by 하면 concat() 이 문자열이 되어 정렬이 잘 안됨(문자열 기준이므로 9000이 10000 보다 뒤에 나옴.) 그래서 inline view 사용.
-- GUIDE2: inline view에는 테이블 별칭을 반드시 넣어줘야 한다.



-- TODO: 직원의 ID(emp.emp_id)가 145인 직원보다 많은 연봉을 받는 직원들의 이름(emp.emp_name)과 급여(emp.salary) 조회.급여가 큰 순서대로 조회
select  emp_name, salary
from    emp
where   salary > (select salary 
                  from emp 
                  where emp_id=145)
order by salary desc;


-- TODO: 직원의 ID(emp.emp_id)가 150인 직원과 업무(emp.job_id)와 상사(emp.mgr_id)가 같은 직원들의 
-- id(emp.emp_id), 이름(emp.emp_name), 업무(emp.job_id), 상사(emp.mgr_id) 를 조회
select  emp_id, emp_name, job_id, mgr_id
from    emp
where   (job_id, mgr_id) = (select job_id, mgr_id
                            from emp
                            where emp_id=150);

-- TODO : EMP 테이블에서 직원 이름이(emp.emp_name)이  'John'인 직원들 중에서 
-- 급여(emp.salary)가 가장 높은 직원의 salary(emp.salary)보다 많이 받는 직원들의 id(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary)를 조회.

select  emp_id, emp_name, salary
from    emp
where   salary > (select max(salary) 
                  from emp 
                  where emp_name='John')
order by 1  ;

-- TODO: 급여(emp.salary)가장 많이 받는 직원이 속한 부서의 이름(dept.dept_name), 위치(dept.loc)를 조회.
select  d.dept_name, d.loc
from    dept d left join emp e on d.dept_id = e.dept_id
where     e.salary = (select max(salary) from emp);

-- OR
select  dept_name, loc
from    dept
where   dept_id = (select dept_id 
				   from emp
                   where salary = (select max(salary) 
								   from emp))

-- TODO: 급여(emp.salary)를 제일 많이 받는 직원들의 이름(emp.emp_name), 부서명(dept.dept_name), 급여(emp.salary) 조회. 
-- 급여는 앞에 $를 붙이고 단위구분자 , 를 출력
select  e.emp_name, d.dept_name,
		concat('$', format(e.salary, 2)) salary
from    emp e left join dept d on e.dept_id = d.dept_id
where    e.salary = (select max(salary) from emp);

-- TODO: 30번 부서(emp.dept_id) 의 평균 급여(emp.salary)보다 급여가 많은 직원들의 모든 정보를 조회.
select  *
from   emp
where salary > (select avg(salary) 
                from emp 
                where dept_id = 30)
order by salary ;


-- TODO: 전체 직원들 중 담당 업무 ID(emp.job_id) 가 'ST_CLERK'인 직원들의 평균 급여보다 적은 급여를 받는 직원들의 모든 정보를 조회. 
-- 단 업무 ID가 'ST_CLERK'이 아닌 직원들만 조회. 

select * from emp where job_id != 'ST_CLERK' or job_id is null; -- 안나오는 것 확인(null인애들)

select  *
from    emp
where   (job_id != 'ST_CLERK'
OR      job_id is null)
and     salary < (select avg(salary)
				  from emp
				  where job_id = 'ST_CLERK');  

select  *
from    emp
where   ifnull(job_id, 'none') != 'ST_CLERK'  -- ifnull 사용해도됨.
and     salary < (select avg(salary)
				  from emp
				  where job_id = 'ST_CLERK');  				  
-- GUIDE: JOB_ID가 null인것 도 나와야함. (OR      job_id is null 안하면 안나옴. job_id != 'ST_CLERK' 여기서 걸려서)
select * from emp where job_id != 'ST_CLERK' 하면 job_id가 null인 것도 안나온다. null은 is not null, is null 로만 비교되므로.

-- TODO: EMP 테이블에서 업무(emp.job_id)가 'IT_PROG' 인 직원들의 평균 급여보다 더 많은 급여를 받는 
-- 직원들의 id(emp.emp_id), 이름(emp.emp_name), 급여(emp.salary)를 급여 내림차순으로 조회.
select  emp_id
		, emp_name
		, salary
from    emp
where   salary >  (select avg(salary)
				   from  emp
				   where job_id = 'IT_PROG')
order by salary desc;


-- TODO: 전체 직원들 중 'IT' 부서(dept.dept_name)의 직원중 가장 많은 급여를 받는 직원보다 더 많이 받는  
-- 직원의 ID(emp.emp_id), 이름(emp.emp_name), 입사일(emp.hire_date), 부서 ID(emp.dept_id), 급여(emp.salary) 조회
-- 입사일은 "yyyy년 mm월 dd일" 형식으로 출력
-- G: 서브쿼리 조인
select  emp_id
		, emp_name
        , date_format(hire_date, '%Y년 %m월 %d일') hiredate
        , dept_id 
        , salary
from    emp
where   salary > (select max(e.salary)
				  from emp e, dept d
				  where  e.dept_id = d.dept_id
				  and    d.dept_name = 'IT')
order by salary;      



/* ----------------------------------------------
 다중행 서브쿼리
 - 서브쿼리의 조회 결과가 여러행인 경우
 - where절 에서의 연산자
	- in
	- 비교연산자 any : 조회된 값들 중 하나만 참이면 참 (where 컬럼 > any(서브쿼리) )
	- 비교연산자 all : 조회된 값들 모두와 참이면 참 (where 컬럼 > all(서브쿼리) )
------------------------------------------------*/
-- 'Alexander' 란 이름(emp.emp_name)을 가진 관리자(emp.mgr_id)의 
-- 부하 직원들의 ID(emp_id), 이름(emp_name), 업무(job_id), 입사년도(hire_date-년도만출력), 급여(salary)를 조회
select * from emp where emp_name = 'Alexander'; -- 알렉산더가 두명 

select emp_id, emp_name, job_id, year(hire_date) hire_year, salary, mgr_id
from   emp
where  mgr_id in (select emp_id 
                  from emp
                  where emp_name = 'Alexander'); -- 다중행(알렉산더가 2명이므로)이어서 = 은 안된다.


-- 직원 ID(emp.emp_id)가 101, 102, 103 인 직원들 보다 급여(emp.salary)를 많이 받는 직원의 모든 정보를 조회.
select   *   from emp
where  salary > (select max(salary) 
                 from emp 
                 where emp_id in (101, 102, 103));

where  salary > all ( select salary
					 from emp
					 where emp_id in (101, 102, 103));

-- 직원 ID(emp.emp_id)가 101, 102, 103 인 직원들 중 급여가 가장 적은 직원보다 급여를 많이 받는 직원의 모든 정보를 조회.
select * from emp
where salary > any (select salary
                   from emp
                   where emp_id in (101,102,103))
order by salary;

where salary > (select min(salary) 
                from emp
                where emp_id in (101, 102, 103));


-- TODO : 부서 위치(dept.loc) 가 'New York'인 부서에 소속된 직원의 ID(emp.emp_id), 
--        이름(emp.emp_name), 부서_id(emp.dept_id) 를 sub query를 이용해 조회.
select dept_id from dept where loc='New York';

select emp_id, emp_name, dept_id
from emp
where dept_id in (select dept_id 
                  from dept
                  where loc='New York');
                  
-- TODO : 최대 급여(job.max_salary)가 6000이하인 업무를 담당하는  직원(emp)의 모든 정보를 sub query를 이용해 조회.
select * from job where max_salary<6000;

select *
from   emp
where  job_id in (select job_id
                  from  job
                  where max_salary < 6000);

-- TODO: 전체 직원들중 부서_ID(emp.dept_id)가 20인 부서의 모든 직원들 보다 급여(emp.salary)를 많이 받는 
-- 직원들의 정보를  sub query를 이용해 조회.
select salary from emp where dept_id = 20;
select  *
from   emp
where  salary > all (select salary from emp where dept_id = 20);
-- where  salary > (select max(salary) from emp where dept_id = 20);

-- TODO: 부서별 급여의 평균중 가장 적은 부서의 평균 급여보다 보다 많이 받는 직원들의 이름, 급여, 업무를 서브쿼리를 이용해 조회
-- GUIDE: select min(avg(salary)) from emp group by dept_id order by 1; -- 이거 안된다. min(avg) 안되넹.

select  *
from   emp
where  salary >any (select avg(salary) from emp group by dept_id) order by salary;


-- TODO: 업무 id(job_id)가 'SA_REP' 인 직원들중 가장 많은 급여를 받는 직원보다 
-- 많은 급여를 받는 직원들의 이름(emp_name), 급여(salary), 업무(job_id) 를 subquery를 이용해 조회.
select   emp_name, salary, job_id
from     emp E
where    salary > all (select salary
					   from emp
					   where job_id = 'SA_REP');


/* *************************************************************************************************
인라인 뷰(Inline View)
- from절에 서브쿼리를 사용하는 것.
- 서브쿼리 결과를 테이블처럼 사용할 수 있다.
* *************************************************************************************************/

-- 중복된 데이터 조회 (emp_duplicated.csv 를 import 후 - 스키마의 Table에 import data 메뉴이용)
select * from (
	select emp_id, emp_name, job, count(*) as count
	from emp_duplicated 
	group by 1, 2, 3
)  t
where count > 1

/* *************************************************************************************************
상관(연관) 쿼리
- 메인쿼리문 테이블의 값을 where절의 subquery에서 참조한다.
	- 메인 쿼리의 where실행에서 한 행씩 조회 대상인지 검사하면서 subquery가 실행되는데 이때 현재 검사중인 그 행의 컬럼값을 subquery가 사용한다.
* *************************************************************************************************/
-- 부서별(DEPT)에서 급여(emp.salary)를 가장 많이 받는 
-- 직원들의 id(emp.emp_id), 이름(emp.emp_name), 연봉(emp.salary), 소속부서ID(dept.dept_id) 조회

-- G: SELECT MAX(salary) FROM emp WHERE dept_id = "Outer 쿼리에서의 조회한 현재 dept_id". 이 설명부터 시작한다.
/* 999999999999999999999999999999999999999 */

select *
from  emp e
where salary   = (select max(salary) 
				  from emp 
				  where ifnull(dept_id, 0) = ifnull(e.dept_id, 0))   -- dept_id는  null을 가질 수 있기 때문에 ifnull() 로 변환해서 비교한다. null = null은 안나옴.
order by dept_id;
select dept_id, max(salary) from emp group by dept_id;

-- GUIDE: 아래처럼 pair 방식 사용해도 됨. IN 연산자로 조회 (= 로하면 안됨)
SELECT *
FROM emp
WHERE (dept_id, salary) in (SELECT dept_id, MAX(salary) FROM emp GROUP BY dept_id) order by dept_id;

/* **************************************************************************************
EXISTS, NOT EXISTS 연산자 (상관(연관)쿼리와 같이 사용된다)
-- 서브쿼리의 결과를 만족하는 값이 존재하는지 여부를 확인하는 조건. 
-- 조건을 만족하는 행이 여러개라도 한행만 있으면 더이상 검색하지 않는다.

- 보통 데이터테이블의 값이 이력테이블(Transaction TB)에 있는지 여부를 조회할 때 사용된다.
	- 메인쿼리: 데이터테이블
	- 서브쿼리: 이력테이블
	- 메인쿼리에서 조회할 행이 서브쿼리의 테이블에 있는지(또는 없는지) 확인
	
고객(데이터) 주문(이력) -> 특정 고객이 주문을 한 적이 있는지 여부
장비(데이터) 대여(이력) -> 특정 장비가 대여 된 적이 있는지 여부
************************************************************************************* */
 

-- 직원이 한명이상 있는 부서의 부서ID(dept.dept_id)와 이름(dept.dept_name), 위치(dept.loc)를 조회
select dept_id, dept_name, loc
from   dept d
where  exists (select emp_id from emp where dept_id = d.dept_id)
order by 1;


-- #####  GUIDE: 설명할 때 
/*
select * from dept 먼저 한뒤
select emp_id from emp where dept_id = 여기들어갈값 에서  select * from dept 한것의 id를 넣어가며 설명. 
*/

-- 직원이 한명도 없는 부서의 부서ID(dept.dept_id)와 이름(dept.dept_name), 위치(dept.loc)를 조회
select dept_id, dept_name, loc
from   dept d
where  not exists (select emp_id from emp where dept_id = d.dept_id)
order by 1;

-- 부서(dept)에서 연봉(emp.salary)이 13000이상인 한명이라도 있는 부서의 부서ID(dept.dept_id)와 이름(dept.dept_name), 위치(dept.loc)를 조회
select dept_id, dept_name, loc
from   dept d
where  exists(select emp_id from emp
              where dept_id = d.dept_id
              and   salary >= 13000);



/* ******************************
TODO 문제 
주문 관련 테이블들 이용.
******************************* */
use shopping;
-- TODO: 고객(customers) 중 주문(orders)을 한번 이상 한 고객들을 조회.
select * from customers c
where  exists (select cust_id
               from orders
               where cust_id = c.cust_id);

-- TODO: 고객(customers) 중 주문(orders)을 한번도 하지 않은 고객들을 조회.
select * from customers c
where  not exists (select cust_id
               from orders
               where cust_id = c.cust_id);

-- TODO: 제품(products) 중 한번이상 주문된 제품 정보 조회
select * from products p
where   exists (select product_id
                from order_items
                where product_id = p.product_id);

-- TODO: 제품(products)중 주문이 한번도 안된 제품 정보 조회
select * from products p
where   not exists (select product_id
                from order_items
                where product_id = p.product_id);








