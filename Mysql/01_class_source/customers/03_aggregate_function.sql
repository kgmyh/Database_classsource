/* **************************************************************************
집계(Aggregation) 함수와 GROUP BY, HAVING
************************************************************************** */

/* ******************************************************************************************
# 집계함수, 그룹함수, 다중행 함수

- 인수(argument)는 컬럼.
  - sum(): 전체합계
  - avg(): 평균
  - min(): 최소값
  - max(): 최대값
  - stddev(): 표준편차
  - variance(): 분산
  - count(): 개수
        - 인수: 
            - 컬럼명: null을 제외한 값들의 개수.
            -  *: 총 행수 - null과 관계 없이 센다.
  - count(distinct 컬럼명): 고유값의 개수.
  
- count(*) 를 제외한 모든 집계함수들은 null을 제외하고 집계한다. 
	- (avg, stddev, variance는 주의)
	- avg(), variance(), stddev()은 전체 개수가 아니라 null을 제외한 값들의 평균, 분산, 표준편차값이 된다.=>avg(ifnull(컬럼, 0))
- 문자타입/일시타입: max(), min(), count()에만 사용가능
	- 문자열 컬럼의 max(): 사전식 배열에서 가장 마지막 문자열, min()은 첫번째 문자열. 
	- 일시타입 컬럼은 오래된 값일 수록 작은 값이다.

******************************************************************************************* */
-- 전체 고객 수를 조회
select count(*) from customer;

-- 모든 고객의 reward_point 의 총합계, 평균, 표준편차, 분산, 최소값, 최대값을 조회.
select  sum(reward_point) "총합계",
		avg(reward_point) "평균",
        round(stddev(reward_point), 2) "표준편차",
        variance(reward_point) "분산",
        max(reward_point) "최대값",
        min(reward_point) "최소값"
from customer;


-- 가장 최근, 오래전에 가입한 고객의 가입일자를 조회.
select max(created_at) "최근가입일", min(created_at) "가장오래된 가입일" from customer;

-- 추천인이 있는 고객 수를 조회
select count(recommender_id) from customer;

/* **************
group by 절
- 특정 컬럼(들)의 값별로 행들을 나누어 집계할 때 기준컬럼을 지정하는 구문. (~~별 ~~에대한 집계 에서 ~~별의 컬럼을 지정할 하는 절.)
	- 예) 업무별 급여평균. 부서-업무별 급여 합계. 성별 나이평균
- 구문
  - group by 컬럼명 [, 컬럼명]
    - 컬럼명
      - 집계를 위해 group으로 묶어줄 기준 컬럼명을 지정한다.
      - select절에 기준컬럼을 지정한 경우 컬럼 순번(1부터 시작)으로 지정할 수있다.
      - 지정한 기준 컬럼(들)이 같은 값을 가지는 행들이 같은 그룹으로 묶인다.
      - 같은 그룹으로 묶인 행들의 값을 기준으로 집계한다.
      - 기준 컬럼은 범주형 컬럼을 사용한다. 부서별 급여 평균 => 부서컬럼, 성별 급여 합계 => 성별컬럼
	- group by 절은 select의 where 절 다음에 기술한다.
	- select 절의 컬럼은 group by 에서 선언한 기준 컬럼들만 집계함수와 같이 올 수 있다.
	
****************/
-- 직업(job)별 고객 수를 조회
select job, count(customer_id) "고객수" from customer
group by job
order by 2 desc;

-- 각 grade에 어떤 직업의 고객이 몇 명 있는지 조회
select grade, job, count(customer_id) "고객수" from customer
group by grade, job
order by 1;

-- grade 별 고객 총 구매액(total_spent)의 평균과 표준편차를 조회
select  grade, 
		format(avg(total_spent), 2) "총 구매액 평균", 
        format(stddev(total_spent), 2) "총 구매액 표준편차"
from customer
group by grade;

-- 성별 총 구매액 평균을 조회
select gender "성별", avg(total_spent) "총 구매액 평균" from customer
group by gender;

-- 가입 년도 별 reward_point의 총액과 평균을 조회
select year(created_at) "가입년도",
	   sum(reward_point) "포인트 총액",
       avg(reward_point) "포인트 평균"
from   customer
group by year(created_at)
order by 1;

-- Grade가 'VIP'인 고객들의 가입 년도별 총 구매액의 평균과 고객수를 조회?
select  year(created_at) "가입년도",
        avg(total_spent) "총 구매액 평균",
        count(customer_id) "고객수"
from    customer
where   grade = 'VIP'
group by year(created_at);

-- 성별, grade별 총 구매액 평균을 조회
select gender "성별", grade, avg(total_spent) "총 구매액 평균" from customer
group by gender, grade
order by 1;



select recommender_id, format(avg(total_spent), 2) "총 결제금액 평균" from customer
group by recommender_id;
/* **************************************************************
having 절
- group by 로 나뉜 그룹을 filtering 하기 위한 조건을 정의하는 구문.
- group by 다음 order by 전에 온다.
- 구문
    `having 제약조건`
    - 연산자는 where절의 연산자를 사용한다. 
    - 피연산자는 집계함수(의 결과) 
      - ex) having avg(salary) > 5000
		
- where절은 행을 filtering한다.
  having절은 group by 로 묶인 그룹들을 filtering한다.		
************************************************************** */

-- 2명이상이 있는 직업군(job) 별 총 구매액의 평균과 reward_point의 평균 조회
select job, avg(total_spent) "총구매액 평균", avg(reward_point) "point 평균", count(customer_id)
from customer
group by job
having count(customer_id) >= 2;

-- total_spent의 평균이 1,000,000 이상인 grade의 총 고객 수
select grade, count(customer_id) as "고객수", avg(total_spent)
from customer
group by grade
having avg(total_spent) > 1000000;

-- 활성 계정(is_active = true) 인 고객들 중 grade 별 남/녀 고객 수를 조회. 단 고객 수가 3명이상인 그룹만 조회

select grade, gender, count(customer_id) "고객수"
from   customer
where is_active = true
group by grade, gender
having count(customer_id) >= 3
order by 1;

select * from customer;

