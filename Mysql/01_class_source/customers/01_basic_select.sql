use my_mall;


/* *************************************
SQL: 대소문자 구분 안함. (값은 구분)

SELECT 기본 구문 - 연산자, 컬럼 별칭
select 컬럼명, 컬럼명 [, .....]  => 조회할 컬럼 지정. *: 모든 컬럼
from   테이블명                 => 조회할 테이블 지정.

컬럼명 [as 별칭] => 테이블에서 컬럼명의 값들을 조회한 뒤 그 결과를 별칭으로 지정한 컬럼반환한다. 별칭에 컬럼명으로 못 사용하는 문자(공백,특수문자들)를 쓸 경우 " "로 감싼다. 
distinct 컬럼명 => 중복된 결과를 제거한다.

*************************************** */

select * from customer where grade = 'vip';

-- CUSTOMER 테이블의 모든 컬럼의 모든 항목을 조회.
select customer_id, customer_name, email, phone, gender, job, birth_date,
grade, total_spent, reward_point, is_active, created_at, last_login, recommender_id from customer;

select * from customer;


-- 성별의 범주값을 확인하시오.
select distinct gender from customer;

-- 직업의 범주값을 확인하시오.
select distinct job from customer;


-- customer_id는 고객 ID, customer_name은 고객 이름, phone는 전화번호로 결과를 조회하시오.
select customer_id as "고객 ID",
       customer_name as "고객 이름",
       phone as "전화번호"
from   customer;       


/* **************************************
연산자 
- 산술 연산자 
	- +, -, *, /, %, mod, div (몫 연산)
- 여러개 값을 합쳐 문자열로 반환
	- concat(값, 값, ...)
- 피연산자가 null인 경우 결과는 null
- 연산은 그 컬럼의 모든 값들에 일률적으로 적용된다.
- 같은 컬럼을 여러번 조회할 수 있다.
************************************** */

-- 모든 고객의 이름과 총 결제금액의 10% 값을 조회하시오.
select customer_id, total_spent, total_spent * 1.1 from customer;

-- 모든 고객의 이름과 포인트를 2배로 만든 값 "리워드 이벤트"라는 이름으로 조회하시오.
select  customer_name, 
		reward_point, 
        reward_point * 2 as "리워드 이벤트" 
from customer;

-- 총 결제금액의 5%를 계산하여 cashback이라는 이름으로 조회하시오.
select total_spent,
	   total_spent * 0.05 as "cashback"
from customer;

/* *************************************
where 절을 이용한 행 선택 

주의 : mysql은 비교시 대소문자를 가리지 않는다.
      ex) where grade = 'VIP' -> 'vip', 'VIP', 'Vip' 모두 조회된다.
     대소문자 구별해서 비교하게 하려면 컬럼명 앞에 BINARY를 붙인다.
	  ex)  where binary grade = 'VIP'
************************************* */


-- 여성 고객 조회
SELECT * FROM customer WHERE gender = 'F';

-- 회원 등급이 'VIP'인 고객의 이름과 이메일을 조회하시오.
select customer_name, email from customer where grade = 'VIP';
-- select * from customer where grade = 'vip';

-- 회원 등급이 'VIP'가 아닌 고객을 조회하시오.
select * from customer where grade != 'VIP';

-- 직업이 'Actor'인 고객의 이름, 직업, 총 결제금액을 조회하시오.
select customer_name, job, total_spent 
from customer where job = 'Actor';


-- 직업이 'Student'가 아닌 고객의 이름과 직업을 조회하시오
select customer_name, job from customer where job != 'Student';-- #Null은 안나옴. or job is null;

-- 활성 계정(is_active = TRUE)인 고객만 조회하시오.
select * from customer where is_active = True;
select * from customer where is_active = 1;


-- 적립 포인트가 0인 고객의 이름과 포인트를 조회하시오.
select customer_name, format(reward_point, 3) from customer where reward_point=0;

-- 총 결제금액이 0인 고객을 조회하시오.
select * from customer where total_spent = 0;

-- 총 결제금액이 1,000,000 이상인 고객의 이름과 총 결제금액을 조회하시오.
select customer_name, total_spent from customer where total_spent > 1000000 order by 2 desc;

-- 적립 포인트가 5000 이상인 고객을 조회하시오.
select * from customer where reward_point > 5000;

-- 최근 로그인 일시가 '2026-03-20 00:00:00' 이후인 고객을 조회하시오.

-- 적립 포인트가 1000 이하 10000 이상인 고객의 이름과 포인트를 조회하시오.

# Between
-- 총 결제금액이 500000 이상 2000000 이하인 고객을 조회하시오.

-- 생년월일이 '1990-01-01' 부터 '1999-12-31' 사이인 고객을 조회하시오.

-- 가입일시가 '2023-01-01'부터 '2023-12-31' 사이인 고객을 조회하시오.

# IN
-- 회원 등급이 'Gold' 또는 'VIP'인 고객을 조회하시오.

-- 직업이 'Actor', 'Singer', 'Athlete' 중 하나인 고객을 조회하시오 


# LIKE
-- 이름이 '김'으로 시작하는 고객을 조회하시오.


-- 이름에 '지'가 포함된 고객을 조회하시오.

-- 이메일이 gmail.com으로 끝나는 고객을 조회하시오. 

-- 이메일이 15글자이고 gmail.com으로 끝나는 고객을 조회하시오.
select customer_name, email from customer where email like '_____@gmail.com'; -- _ : 5개


# NULL
-- 직업이 입력되지 않은 고객을 조회하시오
select * from customer where job is null;


-- 최근 로그인 일시가 있는/없는 고객을 조회하시오.
select * from customer where last_login is null;

-- 추천있는 있는/없는 고객을 조회하시오.
select * from customer where recommender_id is  null;


/* ******************************************
 WHERE 조건이 여러개인 경우 AND 나 OR 로 조건들을 묶어준다.
 
 AND: 두 조건이 모두 True인 행만 조회
 OR: 두 조건 중 하나이상이 True인 행을 조회
 
 연산 우선순위: AND > OR
 	where 조건1 and 조건2 or 조건3
	  1. 조건 1 and 조건2
	  2. 1결과 or 조건3
 
 or를 먼저 하려면 where 조건1 and (조건2 or 조건3)
 *******************************************/

-- 여성이면서 VIP 등급인 고객을 조회하시오.
select * from customer where gender = 'F' and grade='VIP';

-- 직업이 'Actor'이고 총 결제금액이 2000000 이상인 고객을 조회하시오.

-- 활성 계정이면서 적립 포인트가 5000 이상인 고객을 조회하시오.

-- 90년생 중 남성 중 VIP 고객을 조회하시오.
select * from customer where gender = 'M' and birth_date between '1990-01-01' and '2000-12-31' and grade='VIP';

-- 총 결제금액이 5,000,000 이상이거나 적립 포인트가 200,000 이상인 고객을 조회하시오.
select * from customer where total_spent > 5000000 or reward_point > 200000;



-- 회원 등급이 'Gold' 또는 'VIP'이면서, 총 결제금액이 2,000,000 이상인 고객을 조회하시오.
select * from customer where grade in ('GOLD', 'VIP') and total_spent > 2000000;


-- 성별이 'F'이고, 직업이 'Singer' 또는 'Athlete'인 고객을 조회하시오.
select * from customer
-- where gender = 'F' and job in ('Singer', 'Athlete')
where gender = 'F' and (job = 'Singer' or job =  'Athlete');  -- ( ) 묶어주는 문제. 안묶으면 손흥민이 나온다.


-- 직업이 NULL이 아니고, 총 결제금액이 500000 이상인 고객을 조회하시오.


-- 비활성 계정이면서 총 결제금액이 1000000 이상인 고객을 조회하시오.


/* *******************************************************************
order by를 이용한 정렬
- order by절은 select문의 마지막 구문으로 온다.
- order by 정렬기준컬럼 정렬방식 [, ...]
    - 정렬기준컬럼 지정 단위: 컬럼이름, 컬럼의순번(select절의 선언 순서)
     `select salary, hire_date from emp` 에서 salary 컬럼을 기준으로 정렬할 경우 `order by salary` 또는 `order by 1` 로 작성할 수있다.
	 
    - 정렬방식
        - ASC : 오름차순(ascending), 기본방식(생략가능)
        - DESC : 내림차순(descending)
		
문자열 오름차순 : 숫자 -> 대문자 -> 소문자 -> 한글 (유니코드 순서)
Date 오름차순 : 과거 -> 미래
null은 오름차순일 때 가장 먼저 나온다.

ex)
order by salary asc, emp_id desc
- salary로 전체 정렬을 하고 salary가 같은 행은 emp_id로 정렬.
******************************************************************* */

-- 총 결제금액 오름/내림 차순대로 조회하시오.
select * from customer
order by total_spent;

-- 이름 순서대로 조회하세요.
select * from customer order by customer_name desc;

-- 가입 일자 최신 순서대로 조회하세요.
select * from customer order by created_at desc;

