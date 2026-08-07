/* ***********************************************
단일행 함수: 
	- 행별로 처리하는 함수. 문자/숫자/날짜/변환 함수 
	- 단일행은 select, where절에 사용가능
다중행 함수: 
	- 여러행을 묶어서 한번에 처리하는 함수 => 집계함수, 그룹함수라고 한다.
	- 다중행은 where절에는 사용할 수 없다. (sub query 이용) 
* ***********************************************/

/* ***************************************************************************************************************
# 함수 
- 문자열관련 함수
 char_length(v) - v의 글자수 반환
 concat(v1, v2[, ..]) - 값들을 합쳐 하나의 문자열로 반환
 format(숫자, 소수부 자릿수) - 정수부에 단위 구분자 "," 를 표시하고 지정한 소수부 자리까지만 문자열로 만들어 반환
 upper(v), lower(v) - v를 모두 대문자/소문자 로 변환
 insert(기준문자열, 위치, 길이, 삽입문자열): 위치기준으로 변경. 기준문자열의 위치(1부터 시작)에서부터 길이까지 지우고 삽입문자열을 넣는다.
 replace(기준문자열, 원래문자열, 바꿀문자열): 문자열기준으로 변경. 기준문자열의 원래문자열을 바꿀문자열로 바꾼다.
 left(기준문자열, 길이), right(기준문자열, 길이): 기준문자열에서 왼쪽(left), 오른쪽(right)의 길이만큼의 문자열을 반환한다.
 substring(기준문자열, 시작위치, 길이): 기준문자열에서 시작위치부터 길이 개수의 글자 만큼 잘라서 반환한다. 길이를 생략하면 마지막까지 잘라낸다.
 substring_index(기준문자열, 구분자, 개수): 기준문자열을 구분자를 기준으로 나눈 뒤 개수만큼 반환. 개수: 양수 – 앞에서 부터 개수,  음수 – 뒤에서 부터 개수만큼 반환
 ltrim(문자열), rtrim(문자열), trim(문자열): 문자열에서 왼쪽(ltrim), 오른쪽(rtrim), 양쪽(trim)의 공백을 제거한다. 중간공백은 유지
 trim(방향  제거할문자열  from 기준문자열): 기준문자열에서 방향에 있는 제거할문자열을 제거한다.
								   방향: both (앞,뒤), leading (앞), trailing (뒤)
 lpad(기준문자열, 길이, 채울문자열), rpad(기준문자열, 길이, 채울문자열): 기준문자열을 길이만큼 늘린 뒤 남는 길이만큼 채울문자열로 왼쪽(lpad), 오른쪽(rpad)에 채운다. 기준문자열 글자수가 길이보다 많을 경우 나머지는 자른다.
 substring_index(문자열, 구분자, 구분자 개수): SUBSTRING_INDEX는 문자열을 구분자를 기준으로 나눈 뒤, 왼쪽 또는 오른쪽에서부터 구분자를 몇 개까지 포함할지를 지정하여 부분 문자열을 반환하는 함수. 양수일때는 왼쪽, 음수일 때는 왼쪽 에서부터 부분 문자열을 가져온다.

*************************************************************************************************************** */

-- 이름이 3글자가 아닌 고객을 조회하시오.
select * from customer where char_length(customer_name) != 3;

-- 전화번호 뒷자리가 '1111'인 고객을 조회하시오.
select * from customer where phone_number like '%1111';
select * from customer where RIGHT(phone_number, 4) = '1111';
select RIGHT(phone_number, 4) from customer;

-- 이메일 주소의 도메인과 계정을 분리해서 조회
select  substring_index(email, '@', 1) as "이메일 계정",
		substring_index(email, '@', -1) as "이메일 도메인"
from    customer;

-- 총 구매액을 세자리 단위로 ',' 단위 구분자를 넣어 조회하고 뒤에 "원"을 붙여 조회.
select concat(format(total_spent, 0), '원') as "총구매액" from customer;

/* **************************************************************************

- 숫자관련 함수
 abs(값): 절대값 반환
 round(값, 자릿수): 자릿수이하에서 반올림 (양수 - 실수부, 음수 - 정수부, 기본값: 0-0이하에서 반올림이므로 정수로 반올림)
 truncate(값, 자릿수): 자릿수이하에서 절삭-버림(자릿수: 양수 - 실수부, 음수 - 정수부, 기본값: 0)
 ceil(값): 값보다 큰 정수중 가장 작은 정수. 소숫점 이하 올린다. 
 floor(값): 값보다 작은 정수중 가장 작은 정수. 소숫점 이하를 버린다. 내림
 sign(값): 숫자 n의 부호를 정수로 반환(1-양수, 0, -1-음수)
 mod(n1, n2): n1 % n2

************************************************************************** */

select reward_point / 3.6, ceil(reward_point / 3.6), floor(reward_point / 3.6), round(reward_point / 3.6, 2) from customer;

-- 각 고객들의 총구매 액(total_spent)와 적립 포인트(reward_point) 간의 차이를 조회
select total_spent, reward_point, total_spent - reward_point from customer;



/* ***************************************************************************************************************
- 날짜관련 함수
 
 now(): 현재 datetime
 curdate(): 현재 date
 curtime(): 현재 time
 year(날짜), month(날짜), day(날짜): 날짜 또는 일시의 년, 월, 일 을 반환한다.
 hour(시간), minute(시간), second(시간), microsecond(시간): 시간 또는 일시의 시, 분, 초, 밀리초를 반환한다.
 date(), time(): datetime 에서 날짜(date), 시간(time)만 추출한다.
 
 날짜 연산
 adddate/subdate(DATETIME/DATE/TIME,  INTERVAL 값  단위)
 	- 날짜에서 특정 일시만큼 더하고(add) 빼는(sub) 함수.
    - 단위: MICROSECOND, SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, QUARTER(분기-3개월), YEAR
 
 datediff(날짜1, 날짜2): 날짜1 – 날짜2한 일수를 반환
 timediff(시간1, 시간2): 시간1-시간2 한 시간을 계산해서 반환 (뺀 결과를 시:분:초 로 반환)
 timestampdiff(계산단위, 시작일시, 끝일시) - 계산 단위에 맞춰 계산한 기간을 반환. 끝일시 - 시작일시
 
 dayofweek(날짜): 날짜의 요일을 정수로 반환 (1: 일요일 ~ 7: 토요일)

 date_format(일시, 형식문자열): 일시를 원하는 형식의 문자열로 반환
*************************************************************************************************************** */
select now(), curdate(), curtime();

select date(now());  -- datetime -> 날짜만추출
select time(now());  -- datetime -> 시간만추출

-- 가입일시에서 날짜, 시간만 조회.
select date(created_at), time(created_at) from customer;

-- 오후에 가입한 사람들 조회
select customer_id, customer_name, created_at from customer
where time(created_at) < '12:00:00';

-- 2023년에 가입한 고객을 조회하시오.
select * from customer where year(created_at) = 2023;

-- 2025년 이후에 가입한 고객을 조회하시오.
select * from customer where created_at >= '2025-01-01 00:00:00';
select * from customer where year(created_at) >= 2025;

-- 5월 생인 고객들을 조회하시오.
select * from customer where month(birth_date) = 5;

-- 각 주문이 오늘 기준으로 몇일 전에 한 것인지 조회하시요.
select order_id, concat(datediff(now(), order_date), '일') as "주문후 경과일자" from orders;

-- 고객들의 나이를 조회하시오.
select customer_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) as "나이" from customer;

-- 마지막 로그인 후 몇일이 지났는지 조회하시오.
select DATEDIFF(NOW(), last_login) as "days_since_last_login"
from customer;


/* *************************************************************************************
함수 - 조건 처리함수
ifnull (기준컬럼(값), 기본값): 기준컬럼(값)이 NULL값이면 기본값을 출력하고 NULL이 아니면 기준컬럼 값을 출력
if (조건수식, 참, 거짓): 조건수식이 True이면 참을 False이면 거짓을 출력한다.
************************************************************************************* */

-- 고객의 이름(customer_name)과 추천인 ID(recommender_id)를 조회한다. 추천인 ID가 없을 경우 "없음" 이라고 출력되도록 한다.
select customer_id, ifnull(recommender_id, '추천인 없음') "recommander_id" from customer;

-- 활성 여부(is_active)가 True이면 "활성화고객", False이면 "비활성화고객"으로 출력되도록 조회
select is_active, if(is_active, '활성화고객', '비활성화고객') as "is active" from customer;

-- 성별(gender)를 "남성", "여성"으로 출력.
select gender, if(gender = 'M', '남성', '여성') "gender2" from customer;


/* *************************************
CASE 문
case문 동등비교
case 컬럼 when 비교값 then 출력값
              [when 비교값 then 출력값]
              [else 출력값]
              end
              
case문 조건문
case when 조건 then 출력값
       [when 조건 then 출력값]
       [else 출력값]
       end
************************************* */

-- 총 구매량(total_spent) 1,000,000 원 이상이면 1등급, 미만이면 2등급 으로 출력되도록 조회하시오.
select customer_name, format(total_spent,0) as "total_spent",
	   case when total_spent >= 1000000 then '1등급' else '2등급' end as "total spent grade"
from customer;


-- grade 높은 순서대로 조회하세요.(Bronze -> Silver -> Gold -> VIP)
select customer_id, customer_name, grade from customer
order by case grade when 'Bronze' then 1 when 'Silver' then 2 when 'Gold' then 3 when 'VIP' then 4 end;