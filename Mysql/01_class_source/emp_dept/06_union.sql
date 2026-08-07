/* ****************************************************
집합 연산자 (결합 쿼리)
- 둘 이상의 select 결과를 합치는 연산
- 구문
 select문  집합연산자 select문 [집합연산자 select문 ...] [order by 정렬컬럼 정렬방식]

-연산자
  - UNION: 두 select 결과를 하나로 결합한다. 단 중복되는 행은 제거한다. 
  - UNION ALL : 두 select 결과를 하나로 결합한다. 중복되는 행을 포함한다. 
   
 - 규칙
  - 연산대상 select 문의 컬럼 수가 같아야 한다. 
  - 연산대상 select 문의 컬럼의 타입이 같아야 한다.
  - 연산 결과의 컬럼이름은 첫번째 (왼쪽) select문의 것을 따른다.
  - order by 절은 구문의 마지막에 넣을 수 있다.
*******************************************************/

-- emp 테이블의 salary 최대값와 salary 최소값, salary 평균값 조회
select  '최대값' as Label, max(salary) as "집계결과" from emp
union all
select '최소값', min(salary) from emp
union all
select '평균값', round(avg(salary), 2) from emp
order by 2; -- 집합연산을 끝낸 결과에대한 정렬.
-- ------------------------

select * from emp where dept_id in (10, 20)
union all -- 합집합:중복된 것도 모두 나온다.
select * from emp where dept_id in (20, 30);

select * from emp where dept_id in (10, 20)
union -- 합집합: 중복된 것은 하나만 나온다.
select * from emp where dept_id in (20, 30);

-- full outer join 정의
select  * from emp e left join dept d on e.dept_id = d.dept_id
union
select  * from emp e right join dept d on e.dept_id = d.dept_id;


-- GUIDE with rollup 구현 
-- emp 테이블에서 업무별(emp.job_id) 급여 합계와 전체 직원의 급여합계를 조회.
select job_id, sum(salary) 급여합계 from emp group by job_id
union
select '총급여액', sum(salary) from emp
order by 1;






