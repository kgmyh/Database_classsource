/* *************************************
SQL: 대소문자 구분 안함. (값은 구분)

SELECT 기본 구문 - 연산자, 컬럼 별칭
select 컬럼명, 컬럼명 [, .....]  => 조회할 컬럼 지정. *: 모든 컬럼
from   테이블명                 => 조회할 테이블 지정.

컬럼명 [as 별칭] => 테이블에서 컬럼명의 값들을 조회한 뒤 그 결과를 별칭으로 지정한 컬럼반환한다. 별칭에 컬럼명으로 못 사용하는 문자(공백,특수문자들)를 쓸 경우 " "로 감싼다. 
distinct 컬럼명 => 중복된 결과를 제거한다.

*************************************** */
desc emp; 
-- 실행: control+enter
-- EMP 테이블의 모든 컬럼의 모든 항목을 조회.
SELECT emp_id, 
       job, 
       emp_name, 
       mgr_id, 
       hire_date, 
       salary, 
       comm_pct, 
       dept_name 
from  emp;

select * from emp;

-- EMP 테이블의 직원 ID(emp_id), 직원 이름(emp_name), 업무(job) 컬럼의 값을 조회.
select  emp_id, emp_name, job
from 	emp;

-- EMP 테이블의 업무(job) 어떤 값들로 구성되었는지 조회. - 동일한 값은 하나씩만 조회되도록 처리.
-- select distinct 컬럼명[, ..]
select distinct job from emp;

-- EMP 테이블의 부서명(dept_name)이 어떤 값들로 구성되었는지 조회 - 동일한 값은 하나씩만 조회되도록 처리.
select distinct dept_name
from emp;

select distinct job, dept_name
from emp
order by 2;

-- EMP 테이블에서 emp_id는 직원ID, emp_name은 직원이름, hire_date는 입사일, salary는 급여, dept_name은 소속부서 별칭으로 조회한다.
-- select 컬럼 as 별칭(alias)
--  컬럼에서 조회한 것을 별칭으로 보여줘.

select  emp_id as 직원ID, 
        emp_name as 직원이름, 
        hire_date as 입사일, 
        salary as 급여, 
        dept_name as 부서이름
from emp;

--  as는 생략가능
select emp_id 직원ID
       ,emp_name 직원이름
       ,hire_date 입사일
       ,salary 급여
       ,dept_name 소속부서
from   emp;    
--  별칭에 컬럼명으로 못사용하는 문자(공백)를 쓸 경우 " "로 감싼다. 
select emp_id as "직원 ID"
       ,emp_name  "직원 이름"
       ,hire_date as 입사일
       ,salary as 급여
       ,dept_name as "소속 부서"
from   emp; 

select salary * 20 as "20개월급여"
from emp;

select sum(salary) as 총급여
from emp;

/* **************************************
연산자 
- 산술 연산자 
	- +, -, *, /, %, mod, div (몫 연산)
- date/time/datetime 는 +, - 가 가능함.
	- date/time/datetime을 정수로 변환한 뒤 계산한다.
    - +, - : 마지막 항목(date:일, time: 초, datetime: 초)의 값을 +/- => 계산 결과가 정수형으로 반환된다. (ex:20100102)
- 여러개 값을 합쳐 문자열로 반환
	- concat(값, 값, ...) #####GUIDE: 더 자세한 것은 함수에서
- 피연산자가 null인경우 결과는 null
- 연산은 그 컬럼의 모든 값들에 일률적으로 적용된다.
- 같은 컬럼을 여러번 조회할 수 있다.
************************************** */

select 20, 20+10, 20-10, 20*5, 20/3, 20%3, 20 div 3, round(20/3, 2);

-- now: sql문 실행시점의 일시.=>type: datetime
select '2020-01-02' - 2; -- 2018을 반환.

select cast(cast('2020-01-05' as date) -2 as date) ;
select cast(cast('10:20:15' as time) - 2 as time);
select now()-10, now();
-- datetime 타입으로 변환
select  cast(now() + 3 as datetime), 
		cast(now() - 3 as datetime), 
        now(), 
        cast(now()+10 as datetime);

--  datetime - datetime: 몇 초 차이
select now() -cast('2022-04-16 14:05:00' as datetime);

-- 문자열 합치기 
select concat(30, '세') ;
select concat('$',5000);
select concat(30, '세', 'a', 'b'

--  null과 number, date를 연산하면 결과는  null. 붙이는 경우에도 null을 붙이면 결과는 null
select 10 + null ;  
select now() + null;  
select concat('hello', null);

-- select salary, salary, salary from emp;
-- EMP 테이블에서 직원의 이름(emp_name), 급여(salary) 그리고  급여 + 1000 한 값을 조회.
;
select	emp_name
		,salary
		,salary + 1000  --  피연산자가 컬럼인 경우 행단위 연산.
from emp;        


-- ## 15분
--  TODO: EMP 테이블의 업무(job)이 어떤 값들로 구성되었는지 조회 - 동일한 값은 하나씩만 조회되도록 처리
select distinct job from emp;

-- TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary), 커미션_PCT(comm_pct), 급여에 커미션_PCT를 곱한 값을 조회.
select   emp_id, emp_name, salary, comm_pct
         ,salary*comm_pct as 커미션 -- 같은 행끼리 계산.
from emp;        


-- TODO:  EMP 테이블에서 급여(salary)을 연봉으로 조회. (곱하기 12)
select salary "월급", salary *12 "연봉"
from emp;

-- TODO: EMP 테이블에서 직원이름(emp_name)과 급여(salary)을 조회. 급여 앞에 $를 붙여 조회.
select  emp_name
        , concat('$',salary) as "salary"
from  emp;         



/* *************************************
where 절을 이용한 행 선택 

****** 주의 : mysql - 대소문자 안가린다. select * from emp where emp_name = 'steven'; Steven 조회된다.
            대소문자 구별하게 하려면 컬럼명 앞에 BINARY를 붙인다.
				where BINARY emp_name = 'Steven' and BINARY job_id='aD_PRES';
************************************* */
-- EMP 테이블에서 직원_ID(emp_id)가 110인 직원의 이름(emp_name)과 부서명(dept_name)을 조회
select   emp_id
         ,emp_name
         ,dept_name
from    emp  
where   emp_id = 110;  
 
-- EMP 테이블에서 'Sales' 부서에 속하지 않은 직원들의 ID(emp_id), 이름(emp_name),  부서명(dept_name)을 조회.
-- select * from emp;
select emp_id, emp_name, dept_name
from emp
where  dept_name <> 'Sales';
-- where   dept_name != 'Sales'; --    !=, <> : 같은않은 행


-- EMP 테이블에서 급여(salary)가 $10,000를 초과인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select  emp_id, emp_name, salary
from    emp
where   salary > 10000;
-- where salary >= 10000;
-- where salary < 5000;
-- where salary <= 4400;

 
-- EMP 테이블에서 커미션비율(comm_pct)이 0.2~0.3 사이인 직원의 ID(emp_id), 이름(emp_name), 커미션비율(comm_pct)을 조회.
select  emp_id, emp_name, comm_pct
from    emp
where   comm_pct between 0.2 and 0.3;


-- EMP 테이블에서 커미션을 받는 직원들 중 커미션비율(comm_pct)이 0.2~0.3 사이가 아닌 직원의 ID(emp_id), 이름(emp_name), 커미션비율(comm_pct)을 조회.
select  emp_id, emp_name, comm_pct
from    emp
where   comm_pct not between 0.2 and 0.3;

select job from emp;
-- EMP 테이블에서 업무(job)가 'IT_PROG' 거나 'ST_MAN' 인 직원의  ID(emp_id), 이름(emp_name), 업무(job)을 조회.
select  emp_id, emp_name, job
from    emp
where   job in ('IT_PROG', 'ST_MAN', 'FI_MGR');



-- EMP 테이블에서 업무(job)가 'IT_PROG' 나 'ST_MAN' 가 아닌 직원의  ID(emp_id), 이름(emp_name), 업무(job)을 조회.
select  emp_id, emp_name, job
from    emp
where   job not in ('IT_PROG', 'ST_MAN', 'FI_MGR');-- in <-> not in



-- EMP 테이블에서 직원 이름(emp_name)이 S로 시작하는 직원의  ID(emp_id), 이름(emp_name)을 조회.
select  emp_id, emp_name
from    emp
where emp_name like 'S%';
-- where emp_name like '%und%';
-- where  emp_name like 'S_%'; -- S로시작. 최소 2글자.
--  XXX 로 시작하는 : xxx%
--  XXX 로 끝나는 :  %xxx
--  xxx 가 들어간 :   %xxx%
--  글자수 : _

-- EMP 테이블에서 직원 이름(emp_name)이 S로 시작하지 않는 직원의  ID(emp_id), 이름(emp_name)을 조회
select  emp_id, emp_name
from emp
where   emp_name not like 'S%';

-- EMP 테이블에서 직원 이름(emp_name)이 en으로 끝나는 직원의  ID(emp_id), 이름(emp_name)을 조회
select emp_id, emp_name
from emp
where emp_name like '%en';

-- EMP 테이블에서 직원 이름(emp_name)의 세 번째 문자가 “e”인 모든 사원의 이름을 조회
select emp_name
from emp
where emp_name like '__e%';

--  EMP 테이블에서 직원의 이름에 '%' 가 들어가는 직원의 ID(emp_id), 직원이름(emp_name) 조회
-- %나 _  자체를 검색하는 문자(상수)로 사용할 경우.  특수문자%, 특수문자_. 특수문자는 escape 다음에 지정.
### -- escape '특수문자'   특수문자뒤에 %나 _ 는 조회할 값임을 표시.(like의 패턴문자가 아니라)
select  emp_id, emp_name
from    emp
where  emp_name like '%#%%' escape '#'; -- # 뒤에 오는 것은 검색조건문자다 란 표시로 사용.  
-- ##########***** escape구문 안쓰고 `\` 해도 됨(mysql은 된다.)
-- where  emp_name like '%#%#_%' escape '#'; -- %_가 포함된
--  like 에서 %, _ (패턴문자) 앞에 특수 문자를 붙이면 %, _ 자체 문자를 가리킨다. 
-- 특수 문자를 escape 다음에 지정한다.


-- EMP 테이블에서 부서명(dept_name)이 null인 직원의 ID(emp_id), 이름(emp_name), 부서명(dept_name)을 조회.

select  emp_id, emp_name, dept_name
from emp
where   dept_name is null; --  null을 비교 할때는 = 로 하면 안된다. 컬럼 is null 사용.


-- 부서명(dept_name) 이 NULL이 아닌 직원의 ID(emp_id), 이름(emp_name), 부서명(dept_name) 조회
select  emp_id, emp_name, dept_name
from emp
where   dept_name is not null;


-- ##### 1시간ㅑ
-- TODO: EMP 테이블에서 업무(job)가 'IT_PROG'인 직원들의 모든 컬럼의 데이터를 조회. 
select * from emp
where  job='IT_PROG';

-- TODO: EMP 테이블에서 업무(job)가 'IT_PROG'가 아닌 직원들의 모든 컬럼의 데이터를 조회. 
select * from emp
-- where  job != 'IT_PROG';
where job <> 'IT_PROG';

-- TODO: EMP 테이블에서 이름(emp_name)이 'Peter'인 직원들의 모든 컬럼의 데이터를 조회
select * from emp
where emp_name = 'Peter';
-- where  binary emp_name = 'peter';

-- TODO: EMP 테이블에서 급여(salary)가 $10,000 이상인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id, emp_name, salary
from emp
where salary >= 10000;


-- TODO: EMP 테이블에서 급여(salary)가 $3,000 미만인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id, emp_name, salary
from emp
where salary < 3000;


-- TODO: EMP 테이블에서 급여(salary)가 $3,000 이하인 직원의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select emp_id, emp_name, salary
from emp
where salary <= 3000;


-- TODO: 급여(salary)가 $4,000에서 $8,000 사이에 포함된 직원들의 ID(emp_id), 이름(emp_name)과 급여(salary)를 조회
select  emp_id, emp_name, salary
from    emp
where  salary  between 4000 and 8000;
-- where   salary >=4000
--   and    salary <= 8000;

-- TODO: 급여(salary)가 $4,000에서 $8,000 사이에 포함되지 않는 모든 직원들의  ID(emp_id), 이름(emp_name), 급여(salary)를 표시
select  emp_id, emp_name, salary
from    emp
where  salary  not between 4000 and 8000; -- 4001 and 7999 -- 4000, 8000 포함시.


-- TODO: EMP 테이블에서 2007년 이후 입사한 직원들의  ID(emp_id), 이름(emp_name), 입사일(hire_date)을 조회.
-- 참고: date/datatime에서 년도만 추출: year(값)
select  emp_id
        , emp_name
        , hire_date
from   emp
where year(hire_date) >= 2007;
-- where cast(hire_date as year) >= 2007 -- year년도 타입으로 변환후 숫자와 비료 가능(문자로도)
-- where hire_date >= '2007-01-01'  # 암시적으로 변환되어 처림된다. 이렇게 세가지 정도 있겠다.

-- TODO: EMP 테이블에서 2004년에 입사한 직원들의 ID(emp_id), 이름(emp_name), 입사일(hire_date)을 조회.
select  emp_id, emp_name, hire_date
from    emp
where  year(hire_date) = 2004;
-- where  hire_date between '2004-01-01' and '2004-12-31';



-- TODO: EMP 테이블에서 2005년 ~ 2007년 사이에 입사(hire_date)한 직원들의 ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date)을 조회.
select emp_id, emp_name, job, hire_date
from   emp
-- where  hire_date between '2005-01-01' and '2007-12-31';
where year(hire_date) between 2005 and 2007;

-- TODO: EMP 테이블에서 직원의 ID(emp_id)가 110, 120, 130 인 직원의  ID(emp_id), 이름(emp_name), 업무(job)을 조회
select emp_id, emp_name, job
from emp
-- where emp_id = 110 or  emp_id=120 or  emp_id=130;
where emp_id in (110, 120, 130);

-- TODO: EMP 테이블에서 부서(dept_name)가 'IT', 'Finance', 'Marketing' 인 직원들의 ID(emp_id), 이름(emp_name), 부서명(dept_name)을 조회.
select emp_id, emp_name, dept_name
from emp
where  dept_name in ('IT', 'Finance', 'Marketing');

-- TODO: EMP 테이블에서 'Sales' 와 'IT', 'Shipping' 부서(dept_name)가 아닌 직원들의 ID(emp_id), 이름(emp_name), 부서명(dept_name)을 조회.
select  emp_id, emp_name, dept_name from emp
where   dept_name not in ('Sales', 'IT', 'Shipping');



-- TODO EMP 테이블에서 업무(job)에 'SA'가 들어간 직원의 ID(emp_id), 이름(emp_name), 업무(job)를 조회
select emp_id, emp_name, job 
from emp
where  job like '%SA%';


-- TODO: EMP 테이블에서 업무(job)가 'MAN'로 끝나는 직원의 ID(emp_id), 이름(emp_name), 업무(job)를 조회
select emp_id, emp_name, job
from emp
where job LIKE '%MAN';

-- TODO. EMP 테이블에서 커미션이 없는(comm_pct가 null인)  모든 직원의 ID(emp_id), 이름(emp_name), 급여(salary) 및 커미션비율(comm_pct)을 조회
SELECT  emp_id, emp_name, salary, comm_pct
from emp
where  comm_pct is null;

-- TODO: EMP 테이블에서 커미션을 받는 모든 직원의 ID(emp_id), 이름(emp_name), 급여(salary) 및 커미션비율(comm_pct)을 조회
SELECT  emp_id, emp_name, salary, comm_pct
from emp
where   comm_pct is not null;


-- TODO: EMP 테이블에서 상사 ID(mgr_id)가 없는(상사가 없는) 직원의 ID(emp_id), 이름(emp_name), 업무(job), 상사 ID(mgr_id)를 조회
select   emp_id, emp_name, job, mgr_id
from emp
where  mgr_id is null;

-- TODO : EMP 테이블에서 연봉(salary * 12) 이 200,000 이상인 직원들의 모든 정보를 조회.
select * from emp
where salary*12 > 200000;


/* *************************************
 WHERE 조건이 여러개인 경우
 AND OR
 
 참 and 참 -> 참: 조회 결과 행
 거짓 or 거짓 -> 거짓: 조회 결과 행이 아님.
 
 연산 우선순위 : and > or
 
 where 조건1 and 조건2 or 조건3
 1. 조건 1 and 조건2
 2. 1결과 or 조건3
 
 or를 먼저 하려면 where 조건1 and (조건2 or 조건3)
 **************************************/
 select * from emp;
 
--  EMP 테이블에서 업무(job)가 'SA_REP' 이고 급여(salary)가 $9,000인 직원의 직원의 ID(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 조회.
select emp_id, emp_name, job, salary
from emp
where job = 'SA_REP'
 and  salary = 9000;

--  EMP 테이블에서 업무(job)가 'FI_ACCOUNT' 거나 급여(salary)가 $8,000 이상인 직원의 ID(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 조회.
select  emp_id, emp_name, job, salary
from    emp
where   job='FI_ACCOUNT'
 or     salary >= 8000;


select  emp_id, emp_name, job, salary
from    emp
where   not (job='FI_ACCOUNT' or  salary >= 8000);
-- FI_ACCUNT거나 8000 이상이 아닌 것.


-- TODO: EMP 테이블에서 부서(dept_name)가 'Sales'이고 업무(job)가 'SA_MAN'이고 급여가 $13,000 이하인 
-- 직원의 ID(emp_id), 이름(emp_name), 업무(job), 급여(salary), 부서(dept_name)를 조회
select  emp_id, emp_name, job, salary, dept_name
from    emp
where   dept_name = 'Sales'
and     job='SA_MAN'
and     salary <= 13000;


-- TODO: EMP 테이블에서 업무(job)에 'MAN'이 들어가는 직원들 중에서 부서(dept_name)가 'Shipping' 이고 2005년이후 입사한 
-- 직원들의  ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date),부서(dept_name)를 조회
select  emp_id, emp_name, job, hire_date, dept_name
from    emp
where   job like '%MAN%'
and     dept_name = 'Shipping'
and     year(hire_date) >= 2005;
-- and     hire_date >= '2005-01-01';


-- TODO: EMP 테이블에서 입사년도가 2004년인 직원들과 (입사년도와 상관없이) 급여가 $20,000 이상인 
--  직원들의 ID(emp_id), 이름(emp_name), 입사일(hire_date), 급여(salary)를 조회.
select  emp_id, emp_name, hire_date, salary
from    emp
where year(hire_date) = 2004
-- where   hire_date between '2004-01-01' and '2004-12-31'
or      salary >=20000;

-- TODO : EMP 테이블에서, 부서이름(dept_name)이  'Executive'나 'Shipping' 이면서 급여(salary)가 6000 이상인 사원의 모든 정보 조회. 
select *
FROM emp
where   dept_name IN ('Executive', 'Shipping')
and     salary >= 6000;

-- TODO: EMP 테이블에서 업무(job)에 'MAN'이 들어가는 직원들 중에서 부서이름(dept_name)이 'Marketing' 이거나 'Sales'인 
-- 직원의 ID(emp_id), 이름(emp_name), 업무(job), 부서(dept_name)를 조회
select  emp_id, emp_name, job, dept_name
from    emp
where   job like '%MAN%'
and     dept_name in ('Marketing', 'Sales');


-- TODO: EMP 테이블에서 업무(job)에 'MAN'이 들어가는 직원들 중 급여(salary)가 $10,000 이하이 거나 200년년 이전에 입사한 
--  직원의 ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date), 급여(salary)를 조회

--  연산자 우선순위: AND > OR (and의 우선순위가 높다)
select emp_id, emp_name, job, hire_date, salary
from emp
where job like '%MAN%'
and   (salary <= 10000
or    hire_date <= '2005-12-31');
--  업무에 MAN이 들어가고 salary가 10,000이하인 직원이거나 hire_date가 2008년 이후인 직원
-- where job like '%MAN%'
-- and   salary <= 10000
-- or    hire_date >= '2008-01-01';

/* *******************************************************************
order by를 이용한 정렬
- order by절은 select문의 마지막에 온다.
- order by 정렬기준컬럼 정렬방식 [, ...]
    - 정렬기준컬럼 지정 단위: 컬럼이름, 컬럼의순번(select절의 선언 순서), **GUIDE: mysql은 별칭으로 정렬안된다.****
     select salary, hire_date from emp ...
	 에서 salary 컬럼 기준 정렬을 설정할 경우. 
     order by salary 또는 1
    - 정렬방식
        - ASC : 오름차순, 기본방식(생략가능)
        - DESC : 내림차순
		
문자열 오름차순 : 숫자 -> 대문자 -> 소문자 -> 한글     
Date 오름차순 : 과거 -> 미래
null 오름차순 : null이 먼저 나온다.  GUIDE: 오라클은 반대.

ex)
order by salary asc, emp_id desc
- salary로 전체 정렬을 하고 salary가 같은 행은 emp_id로 정렬.
******************************************************************* */

--  직원들의 전체 정보를 직원 ID(emp_id)가 큰 순서대로 정렬해 조회
select * from emp
order by emp_name;--  asc;
-- order by emp_name desc;


--  직원들의 id(emp_id), 이름(emp_name), 업무(job), 급여(salary)를 
--  업무(job) 순서대로 (A -> Z) 조회하고 업무(job)가 같은 직원들은 급여(salary)가 높은 순서대로 2차 정렬해서 조회.
select  emp_id, emp_name, job, salary
from emp
-- order by job, salary desc;
order by 3, 4 desc;

-- 부서명을 부서명(dept_name)의 오름차순으로 정렬해 조회하시오.
select dept_name 부서명 from emp
-- order by dept_name;
-- order by 1 desc;
order by 부서명;

-- TODO: 급여(salary)가 $5,000을 넘는 직원의 ID(emp_id), 이름(emp_name), 급여(salary)를 급여가 높은 순서부터 조회
select  emp_id, emp_name, salary
from    emp
where   salary > 5000
order by 3 desc;-- salary desc;


-- TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 업무(job), 입사일(hire_date)을 입사일(hire_date) 순서로 조회.
select emp_id, emp_name, job, hire_date
from emp
order by hire_date;


-- TODO: EMP 테이블에서 ID(emp_id), 이름(emp_name), 급여(salary), 입사일(hire_date)을
-- 급여(salary) 오름차순으로 정렬하고 급여(salary)가 같은 경우는 먼저 입사한(hire_date) 순서로 정렬.
select emp_id, emp_name, salary, hire_date
from emp
-- order by salary , hire_date;
order by 3, 4;