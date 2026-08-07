-- GUIDE AUTO COMMIT 설정
-- 현재 AutoCommit 값 확인
-- 상태 조회
-- # ON/OFF
show variables like 'AUTOCOMMIT';

-- AutoCommit 설정
SET AUTOCOMMIT = True;

-- AutoCommit 해제: **연결할 때 마다 설정.**
SET AUTOCOMMIT = False;

-- Mysql workbench 설정에서 바꾸기
-- Preference > SQL Editor > SQL Excution > 두번째 체크박스: New Connection Autocommit 어쩌구 체크 해제 (이건 영구적으로 바꾸는 것 같다.)



-- update/delete 잘 되게 하려면
-- -  Preference > SQL Editor 맨아래 Safe updates (reject UPDATE .....) 이거 체크 해제한다. 
--  - 이거 한번에 여러행이 삭제, 수정되는 것을 툴 차원에서 막아 두는 것이다.
--   =====> connection 다시 연결필요하다.
/*
결론
1. @@autocommit 확인
2. SET AUTOCOMMIT = False; 변경 (이거 재 연결하면 원래대로 복귀된다. - 지금 세션에서만 바꾸기)
3. Preference > SQL Editor 맨아래 Safe updates (reject UPDATE .....) 이거 체크 해제 (이건 한번만 하면된다.) 
4. 재 연결: File > Close Connection tab 하고 다시 연결한다.
*/







/* *********************************************************************
INSERT 문 - 행 추가
구문
 - 한행추가 :
   - INSERT INTO 테이블명 (컬럼 [, 컬럼]) VALUES (값 [, 값[])
   - 모든 컬럼에 값을 넣을 경우 컬럼 지정구문은 생략 할 수 있다.

 - 조회결과(select)를 INSERT 하기 (subquery 이용)
   - INSERT INTO 테이블명 (컬럼 [, 컬럼])  SELECT 구문
	 - INSERT할 컬럼과 조회한(subquery) 컬럼의 개수와 타입이 맞아야 한다.
	 - 모든 컬럼에 다 넣을 경우 컬럼 설정은 생략할 수 있다.

G: 한행 추가 시
   PK  중복시 에러나는 것.
   FK  에러나는 것 실습. 
************************************************************************ */
insert into emp (emp_id, emp_name, job_id, mgr_id, 
                 hire_date, salary, comm_pct, dept_id)
          values (1000, '홍길동', 'IT_PROG', 120, 
                 '2019-07-15', 5000, 0.1, 60);
select * from emp where emp_id > 1000;
-- 모든 컬럼에 값을 넣을 경우 컬럼선택은 생략 가능. - 값의 순서: 테이블 생성시 지정한 컬럼순.
-- NULL : null값
-- DATE: '년/월/일' 
insert into emp values (1100, '박철수', NULL, 120, 
                 curdate(), 5000, 0.1, NULL);  

-- ###안되는 것들 이것 저것 연습 ###########

-- salary: NOT NULL 제약 조건 => 반드시 값이 들어가야 한다.
desc emp;
insert into emp (emp_id, emp_name, hire_date) values (1300, '이순신', '2010/10/05');

-- salary 정수부: 5자리, => 7자리 (데이터 크기가 컬럼의 크기보다 크면 에러)
insert into emp (emp_id, emp_name, hire_date, salary) 
values (1300, '이순신이순신', '2010/10/05', 100000);

-- 제약조건: primary key(기본키) 컬럼에 같은 값을 insert 못함.
--         foreign key (외래키) 컬럼에는 반드시 부모테이블의 primary key 컬럼에 있는 
--         값들만 넣을 수 있다.
insert into emp (emp_id, emp_name, hire_date, salary, dept_id) 
values (1300, '이순신이순신', '2010/10/05', 10000, 400);-- 400 없는 것. );


-- SELECT를 이용한 INSERT
drop table emp_copy;
create table emp_copy(
    emp_id int,
    emp_name varchar(20),
    salary decimal(7, 2)
);

insert into emp_copy (emp_id, emp_name, salary) 
select emp_id, emp_name, salary
from   emp
where  job_id = 'FI_ACCOUNT';

select * from emp_copy;

-- 모든 컬럼에 다 넣을 경우 컬럼 지정은 생략 가능.
insert into emp_copy
select emp_id, emp_name, salary
from   emp
where  dept_id = 50;

select * from emp_copy;
insert into emp_copy (emp_id, emp_name) -- salary는 null
	select emp_id, emp_name -- , salary
	from   emp
	where  dept_id = 30;

-- TODO 부서별 직원의 급여에 대한 통계 테이블 생성. 
-- emp의 다음 조회결과를 insert. 집계: 합계, 평균, 최대, 최소, 분산, 표준편차
drop table salary_stat;
create table salary_stat(
    dept_id    int,
    salary_sum decimal(15,2),
    salary_avg decimal(10, 2),
    salary_max decimal(7,2),
    salary_min decimal(7,2),
    salary_var decimal(20,2),
    salary_stddev decimal(7,2)
);

insert into salary_stat
select dept_id,
       sum(salary),
       round(avg(salary), 2),
       max(salary),
       min(salary),
       round(variance(salary),2),
       round(stddev(salary),2)
from   emp
group by dept_id
order by 1;

select * from salary_stat;


-- GUIDE AUTO COMMIT 설정
-- 현재 AutoCommit 값 확인
-- 상태 조회
-- # -- 1: auto commit, 0: manual commit
SELECT @@AUTOCOMMIT;

-- AutoCommit 설정
SET AUTOCOMMIT = 1;

-- AutoCommit 해제: **연결할 때 마다 설정.**
SET AUTOCOMMIT = 0;

-- update/delete 잘 되게 하려면
-- -  Preference > SQL Editor 맨아래 Safe updates (reject UPDATE .....) 이거 체크 해제한다. 
--  - 이거 한번에 여러행이 삭제, 수정되는 것을 툴 차원에서 막아 두는 것이다.
--   =====> connection 다시 연결필요하다.
/*
결론
1. @@autocommit 확인e
2. set autocommit = 0  변경 (이거 재 연결하면 1로 복귀된다. - 지금 세션에서만 바꾸기)
3. Preference > SQL Editor 맨아래 Safe updates (reject UPDATE .....) 이거 체크 해제 (이건 한번만 하면된다.) 
4. 재 연결: File > Close Connection tab 하고 다시 연결한다.
*/


-- Preference > SQL Editor > SQL Excution > 두번째 체크박스: New Connection Autocommit 어쩌구 체크 해제 (이건 영구적으로 바꾸는 것 같다.)

/*
 Auto commit 설정을 해제.
 commit: insert, delete, update 된 데이터를 실제 물리 디비에 영구적으로 적용.
 */
select @@autocommit; 
-- 1: auto commit   - I/U/D 쿼리가 실행되면 바로 적용
-- 0: manual commit - I/U/D 쿼리가 실행되도 바로 적용하지 않고 commit 명령을 직접
-- 					  실행해야 적용된다.
--     - commit; -> 적용, rollback; -> 마지막 commit 상태로 복원.

/* *********************************************************************
UPDATE : 테이블의 컬럼의 값을 수정
UPDATE 테이블명
SET    변경할 컬럼 = 변경할 값  [, 변경할 컬럼 = 변경할 값]
[WHERE 제약조건]

 - UPDATE: 변경할 테이블 지정
 - SET: 변경할 컬럼과 값을 지정
 - WHERE: 변경할 행을 선택. 
************************************************************************ */
-- GUIDE : safe update 모드 끄기 : Preference > SQL Editor 맨아래 > safe update 끄기 (여러행 update시 에러 발생시킨다.)


-- ######################## 주의: set  절의 변경값은  subquery 사용못한다. where절은 가능.

-- 직원 ID가 200인 직원의 급여를 5000으로 변경
update  emp
set		salary = 5000
where   emp_id = 200;

rollback; -- 마지막 commit 이후 변경한 내용을 처음 상태로 돌린다.
commit;  -- 지금까지 한 작업을 DB에 적용한다.


-- 직원 ID가 200인 직원의 급여를 10% 인상한 값으로 변경.
update	emp
set		salary=salary*1.1
where	emp_id = 200;

-- 부서 ID가 100인 직원의 커미션 비율을 0.2로 salary는 3000을 더한 값으로, 상사_id는 100 변경.
select * from emp where dept_id = 100;
update  emp
set		comm_pct = 0.2
		, salary = salary + 3000
		, mgr_id = 100
where   dept_id = 100;
commit;


-- 부서 ID가 100인 직원의 커미션 비율을 null 로 변경.
update  emp
set		comm_pct = null
where   dept_id = 100;


-- TODO: 부서 ID가 100인 직원들의 급여를 100% 인상
select * from emp where dept_id = 100;

update  emp
set		salary = salary * 2
where   dept_id = 100;


-- TODO: IT 부서의 직원들의 급여를 3배 인상
select * from emp where dept_id = 60;
update   emp
set      salary = salary * 3
where    dept_id = (select dept_id 
                    from dept 
                    where dept_name = 'IT');

-- TODO: EMP 테이블의 모든 데이터를 MGR_ID는 NULL로 HIRE_DATE 는 현재일시로 COMM_PCT는 0.5로 수정.
update emp
set    mgr_id = null,
	   hire_date = curdate(), 
       comm_pct = 0.5;
rollback;    
select * from emp;
rollback;
/* *********************************************************************
DELETE : 테이블의 행을 삭제
구문 
 - DELETE FROM 테이블명 [WHERE 제약조건]
   - WHERE: 삭제할 행을 선택
************************************************************************ */

-- 전체 삭제
delete from emp;
select * from emp;
rollback;

-- 부서테이블에서 부서_ID가 200인 부서 삭제
select * from dept where dept_id = 200;

delete from dept 
where  dept_id = 200;

-- 부서테이블에서 부서_ID가 10인 부서 삭제
/*
--자식 테이블에서 참조하는 행은 삭제할 수 없다. 
-- 참조하는 자식테이블의 행을 삭제하거나 참조컬럼의 값을 NULL로 바꾼뒤 삭제한다.
*/
update  emp
set     dept_id = null
where   dept_id = 10;

rollback;
select * from emp where dept_id =10;

delete from dept 
where  dept_id = 10;

select * from dept where dept_id = 10;







-- TODO: 부서 ID가 없는 직원들을 삭제
select * from emp where dept_id is null;
delete from emp where dept_id is null;

-- TODO: 담당 업무(emp.job_id)가 'SA_MAN'이고 급여(emp.salary) 가 
-- 12000 미만인 직원들을 삭제.  #### G: emp_id 를 mgr_id로 참조되고 있다.
update emp
set    mgr_id = null
where  emp_id in (select emp_id 
                 from emp 
                 where mgr_id in (148, 149)); -- 참조하고 있는 값들을 null로 변경

delete from emp
where  job_id = 'SA_MAN'
and    salary < 12000;

select * from emp
where  job_id = 'SA_MAN'
and    salary < 12000;
rollback;
select * from emp where mgr_id in (148, 149);

-- TODO: comm_pct 가 null이고 job_id 가 IT_PROG인 직원들을 삭제
select * from emp where comm_pct is  null and job_id = 'IT_PROG';

delete from emp
where comm_pct is null
and   job_id = 'IT_PROG';

rollback;

drop table emp2;
create table emp2
as
select * from emp;



delete from emp2;
select * from emp2;
rollback;
/*
truncate table 테이블명; => DDL문.자동커밋.
-> 전체 데이터를 삭제 (delete from 테이블명)
-> rollback을 이용해 복구가 안된다.
*/
truncate table emp2;
select * from emp2;
rollback;


