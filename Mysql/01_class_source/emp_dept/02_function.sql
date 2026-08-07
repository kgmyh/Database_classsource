/* ***********************************************
단일행 함수 : 행별로 처리하는 함수. 문자/숫자/날짜/변환 함수 
	- 단일행은 selec, where절에 사용가능
다중행 함수 : 여러행을 묶어서 한번에 처리하는 함수 => 집계함수, 그룹함수라고 한다.
	- 다중행은 where절에는 사용할 수 없다. (sub query 이용) 
* ***********************************************/

/* ***************************************************************************************************************
함수 - 문자열관련 함수
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
 lpad(기준문자열, 길이, 채울문자열), rpad(기준문자열, 길이, 채울문자열): 기준문자열을 길이만큼 늘린 뒤 남는 길이만큼 채울문자열로 왼쪽(lpad), 오른쪽(rpad)에 채운다.
													      기준문자열 글자수가 길이보다 많을 경우 나머지는 자른다.
 *************************************************************************************************************** */
select char_length('가나다라'), char_length('abc1234');-- 글자수
select upper('abcDE'), lower('ABCde');
select format(123456789.98765, 3); -- 반올림 ( 음수는 0과 동일)
select format(123456789, 0);-- 정수-> 자릿수는 반드시 넣어야 한다.

select concat('홍길동', '님'), concat('\\', 3000); --원 표시.
select concat('나이 ', 20, '세'); -- 여러개 넣을 수 있다. 

select insert('abcdefghijklmn', 2, 5, '안녕하세요'); -- 2번째 부터 5글자를 안녕하세요로 변경(변경이다)
select replace('aaabbbcccdddeee', 'aaa', 'AAA');

select left('aaabbbcccdddeee', 5) as "v"; -- 쵠쪽에서 지정한 개수 글자만 반환(잘라내기)
select right('aaabbbcccdddeee', 5);
select substring('aaabbbcccdddeee', 4, 3); -- 4번째 부터 3글자
select substring('aaabbbcccdddeee', 4); -- 4번째 부터 끝까지
select substring_index('aaa-bbb-ccc-ddd-eee', '-', 3); --  기준문자열을 구분자를 기준으로 나눈 뒤 개수만큼 반환. 파이썬 SPLIT처럼 나누는게 아니다. 그 문자열을 반환. 다 가져오려면 개수를 크개잡아라. 개수 생략 안됨.
-- 문자열을 '-' 구분자를 기준으로 나눴을때 앞에서 3개를 반환 ('aaa-bbb-ccc' 를 반환)
select substring_index('aaa-bbb-ccc-ddd-eee', '-', -2); -- 02; 뒤에서 2개

select trim('    aaa   '), char_length(trim('    aaa    ')); -- 좌우 공백 제거
select rtrim('      aaa      ') as "b";
select ltrim('      aaa      ') as "b";
select trim(both '-' from '------------aaaa-------------') as "b";
--     어디에있는것  지울문자열  from  대상문자열
select trim(leading '-+' from '-+-+-+-+aaaa-+-+-+-+') as "b";
select trim(trailing '-+' from '-+-+-+-+aaaa-+-+-+-+') as "b";
-- 어디있는것: both(앞뒤), leading(앞), trailing(뒤)

select lpad('test', 10, ' ') as "b"; 
-- 10글자로 맞춘다. 모자랄 경우 왼쪽(lpad)에 ' '을 붙인다.
select rpad('test', 10, ' '), char_length(rpad('test', 10, ' ')) as "b"; 
-- 10글자로 맞춘다. 모자랄 경우 오른쪽(lpad)에 ' '을 붙인다.
select lpad(3, 2, '0');  -- ----------- ** 대상은 문자열이 아니어도 된다.**
select rpad('testaa',3, '-'); -- 3글자로 짜른다. **모자라면 채우고 넘치면 버린다.**

-- 함수 안에서 함수를 호출하는 경우: 안쪽 함수를 먼저 실행하고 그 결과를 넣어 바깥쪽 함수 실행.
select char_length(trim('     a      ')) A;

-- EMP 테이블에서 직원의 이름(emp_name)을 모두 대문자, 소문자, 이름 글자수를 조회
select  upper(emp_name) 대문자이름,
        lower(emp_name) 소문자이름,
        char_length(emp_name) 글자수
from emp;        


--  TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary),부서(dept_name)를 조회. 
--  단 직원이름(emp_name)은 모두 대문자, 부서(dept_name)는 모두 소문자로 출력.
select  emp_id,
        upper(emp_name) emp_name,
        salary,
        lower(dept_name) dept_name
from emp;        


-- TODO: EMP 테이블에서 직원의 이름(emp_name)이 PETER인 직원의 모든 정보를 조회하시오.(emp_name의 값들의 대소문자와 상관없이 조회)
select * from emp
-- where upper(emp_name) = 'PETER';
where lower(emp_name)='peter';



-- TODO: 직원 이름(emp_name) 의 자릿수를 15자리로 맞추고 15자가 안되는 이름의 경우  공백을 앞에 붙여 조회. 
select lpad(emp_name, 15, ' ') as name 
from emp;


    
--  TODO: EMP 테이블에서 이름(emp_name)이 10글자 이상인 직원들의 이름(emp_name)과 이름의 글자수 조회
select emp_name, length(emp_name)
from emp
where char_length(emp_name) >= 10;


-- 공백빼고 -- char_length(replace(emp_name, ' ', ''))

/* **************************************************************************

함수 - 숫자관련 함수
 abs(값): 절대값 반환
 round(값, 자릿수): 자릿수이하에서 반올림 (양수 - 실수부, 음수 - 정수부, 기본값: 0-0이하에서 반올림이므로 정수로 반올림)
 truncate(값, 자릿수): 자릿수이하에서 절삭-버림(자릿수: 양수 - 실수부, 음수 - 정수부, 기본값: 0)
 ceil(값): 값보다 큰 정수중 가장 작은 정수. 소숫점 이하 올린다. 
 floor(값): 값보다 작은 정수중 가장 작은 정수. 소숫점 이하를 버린다. 내림
 sign(값): 숫자 n의 부호를 정수로 반환(1-양수, 0, -1-음수)
 mod(n1, n2): n1 % n2

************************************************************************** */
select truncate(178.999, 2), round(178.999, 2);
select round(1.234, 2);
-- ceil, floor : 결과는 정수.
select ceil(50.123) 올림,
       floor(50.789) 내림;

select round(50.12),
       round(50.79),
       round(50.1234, 2),-- 소수점 2자리 이하
       round(50.1278, 2);
       
select round(12345, -1),-- 10단위 이하에서 반올림
       round(12378, -2); -- 100단위 이하에서 반올림
;
--  자릿수: 0 (단단위-기본값) , 음수->실수부, 양수->정수부
select truncate(1234.56, -2), -- 두자리 정수이므로 3부터 버린다.
       truncate(1234.56, -1),
       truncate(1234.56, 0),
       truncate(1234.56, 1),
       truncate(1234.56, 2);  
       
select sign(-10), sign(0), sign(10);

-- TODO: EMP 테이블에서 각 직원에 대해 직원ID(emp_id), 이름(emp_name), 급여(salary) 그리고 15% 인상된 급여(salary)를 조회하는 질의를 작성하시오.
-- (단, 15% 인상된 급여는 올림해서 정수로 표시하고, 별칭을 "SAL_RAISE"로 지정.)
select emp_id, emp_name, salary,
       ceil(salary * 1.15) SAL_RAISE
from emp;        

-- TODO: 위의 SQL문에서 인상 급여(sal_raise)와 급여(salary) 간의 차액을 추가로 조회 
-- (직원ID(emp_id), 이름(emp_name), 15% 인상급여, 인상된 급여와 기존 급여(salary)와 차액)
select emp_id, emp_name, salary,
       ceil(salary * 1.15) SAL_RAISE,
       ceil(salary * 1.15) - salary "차액"
from emp;


--  TODO: EMP 테이블에서 커미션이 있는 직원들의 직원_ID(emp_id), 이름(emp_name), 커미션비율(comm_pct), 커미션비율(comm_pct)을 8% 인상한 결과를 조회.
-- (단 커미션을 8% 인상한 결과는 소숫점 이하 2자리에서 반올림하고 별칭은 comm_raise로 지정)
select emp_id, emp_name, comm_pct,
       round(comm_pct * 1.08, 2) comm_raise,
       truncate(comm_pct * 1.08, 2)  comm_raise2
from emp 
where comm_pct is not null;        

select cast('2020-10-02' as datetime) - 2;

/* ***************************************************************************************************************
함수 - 날짜관련 계산 및 함수
date/time/datetime: +, - 사용 =>  산술연산 -> 정수로 변환한 다음에 계산.

now(): 현재 datetime
curdate(): 현재 date
curtime(): 현재 time
year(날짜), month(날짜), day(날짜): 날짜 또는 일시의 년, 월, 일 을 반환한다.
hour(시간), minute(시간), second(시간), microsecond(시간): 시간 또는 일시의 시, 분, 초, 밀리초를 반환한다.
date(), time(): datetime 에서 날짜(date), 시간(time)만 추출한다.

날짜 연산
adddate/subdate(DATETIME/DATE/TIME,  INTERVAL 값  계산할대상단위)
	날짜에서 특정 일시만큼 더하고(add) 빼는(sub) 함수.
    계산할대상단위: MICROSECOND, SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, QUARTER(분기-3개월), YEAR

datediff(날짜1, 날짜2): 날짜1 – 날짜2한 일수를 반환
timediff(시간1, 시간2): 시간1-시간2 한 시간을 계산해서 반환 (뺀 결과를 시:분:초 로 반환)
timestampdiff(계산할대상단위, 시작일시, 끝일시) - 계산할대상단위 조합은 안된다. 

dayofweek(날짜): 날짜의 요일을 정수로 반환 (1: 일요일 ~ 7: 토요일)

date_format(일시, 형식문자열): 일시를 원하는 형식의 문자열로 반환
*************************************************************************************************************** */
-- 실행시점의 일/시를 조회 함수
select now();  -- 일시 -> datetime
select curdate(); -- 날짜 -> date
select curtime(); -- 시간 -> time

-- 날짜 타입에서 년 월 일 조회
select year(now()), month(now()), day(curdate());
-- 시간 타입에서 시 분 초 조회
select hour(now()), minute(curtime()),
       second(curtime()), microsecond(now());
select date(now()); -- datetime -> date
select time(now()); -- datetime -> time

-- 특정 간격만큼 지난 일시를 조회
select adddate(curtime(), interval 2 minute);
select adddate(now(), interval 2 year);
select adddate(now(), interval 3 day);
select adddate(now(), interval 3 quarter);

select subdate(curdate(), interval 2 year); -- 2년 전
select adddate(curdate(), interval -2 year);

select adddate(now(), interval -3 day);
select adddate(now(), interval -3 day);

SELECT adddate(CURTIME(), INTERVAL 1 HOUR);
SELECT adddate(CURTIME(), INTERVAL -1 HOUR);

select adddate(now(), interval '3:30' HOUR_MINUTE);
select adddate(now(), interval '-5/1' YEAR_MONTH); -- 년도는 빼고 월은 더하고식은 안되는 것 같다.

-- timestampdiff ######################## 확인필요 ========> 조합은 안됨
select timestampdiff(day, '2021/01/10 11:22:21', now()); 앞에서 뒤까지 얼마나 지났는지.

select datediff(curdate(), '2023-08-30'); -- curdate - 2023/8/30 일수 차이
select datediff('2023-08-30', curdate()); -- 앞의 것이 과거==>음수
select timediff(curtime(), '11:20:10'); 
					-- curtime - '11:20:10'  차이가나는 시간:분:초 를 반환

select date_format(now(), '%Y년 %m월 %d일 %H시 %i분 %s초 %W %p');
-- 2023년 09월 01일 11시 44분 55초 AM Friday

-- TODO: EMP 테이블에서 부서이름(dept_name)이 'IT'인 직원들의 '입사일(hire_date)로 부터 10일전', 입사일, '입사일로 부터 10일 후' 의 날짜를 조회. 
-- select adddate(hire_date, interval -10 day), hire_date, adddate(hire_date, interval 10 day)
select subdate(hire_date, interval 10 day), hire_date, adddate(hire_date, interval 10 day)
from emp
where dept_name = 'IT';


-- TODO: 부서가 'Purchasing' 인 직원의 이름(emp_name), 입사 6개월전과 입사일(hire_date), 6개월후 날짜를 조회.
select  subdate(hire_date, interval 6 month), 
        hire_date, 
        adddate(hire_date, interval 6 month)
from emp
where dept_name='Purchasing';

-- TODO ID(emp_id)가 200인 직원의 이름(emp_name), 입사일(hire_date)를 조회. 입사일은 yyyy년 mm월 dd일 형식으로 출력.
select emp_name, date_format(hire_date, '%Y년 %m월 %d일') hire_date from emp;

--  TODO: 각 직원의 이름(emp_name), 근무 개월수 (입사일에서 현재까지의 달 수)를 계산하여 조회. 근무개월수 내림차순으로 정렬.
select emp_name,
       timestampdiff(day, hire_date, curdate()) as "근무일수", 
	   datediff(curdate(), hire_date) as "근무일수2",
	   timestampdiff(month, hire_date, curdate()) "근무개월수",
	   timestampdiff(year, hire_date, curdate()) "근무년수"
	   
from emp
order by 3 desc;


-- TODO: ID(emp_id)가 100인 직원이 입사한 요일을 조회
select dayofweek(hire_date) as "입사요일", 
	   case dayofweek(hire_date) when 1 then "일요일"
							     when 2 then "월요일"
                                 when 3 then "화요일"
                                 when 4 then "수요일"
                                 when 5 then "목요일"
                                 when 6 then "금요일"
                                 when 7 then "토요일"
       end as "입사요일 2"
from  emp;  
-- where emp_id = 100; -- 확인차 주석 (다른 요일들도 잘 바뀌었는지 확인차)

select dayofweek(hire_date) as "입사요일", 
       substring('일월화수목금토', dayofweek(hire_date), 1) as "입사요일2",
       concat(substring('일월화수목금토', dayofweek(hire_date), 1), '요일') as "입사요일3"
from   emp
-- where emp_id = 100;



/* *************************************************************************************
함수 - 조건 처리함수
ifnull (기준컬럼(값), 기본값): 기준컬럼(값)이 NULL값이면 기본값을 출력하고 NULL이 아니면 기준컬럼 값을 출력
if (조건수식, 참, 거짓): 조건수식이 True이면 참을 False이면 거짓을 출력한다.
nullif(컬럼1, 컬럼2): 컬럼1과 컬럼2가 같으면 NULL을 반환, 다르면 컬럼1을 반환
coalesce(ex1, ex2, ex3, .....) ex1 ~ exn 중 null이 아닌 첫번째 값 반환. null값을 다른 값으로 변경할 때 이용하면 좋다.
  - coalesce(dept_name, '부서 미배치') as dept_name
************************************************************************************* */


select ifnull(comm_pct, 0) from emp;
select ifnull(comm_pct, '없음') from emp;
--  기본값으로 comm_pct 타입의 값만 지정한다.
select * from emp
where  ifnull(comm_pct, 0) <> 0;
-- where  comm_pct is not null;

select if(comm_pct is null, '없음', '있음') from emp;
select if(comm_pct is null, '없음', comm_pct) from emp; -- 있으면 comm_pct값 출력 

select nullif(10, 10);
select nullif(10, 5);

-- select nullif(2010년판매개수컬럼, 2011년판매개수컬럼) from 판매테이블; -- nullif 가상예제

-- Guide: coalesce() 예 (이건 수업안함)
select coalesce(null, null, 10, 20, 30);
select emp_id, comm_pct, mgr_id,
       coalesce(comm_pct, mgr_id)
from emp
where emp_id in (150, 100, 101);


-- TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 업무(job), 부서(dept_name)을 조회. 부서가 없는 경우 '부서미배치'를 출력.
select  emp_id, emp_name, job,
        ifnull(dept_name, '부서미배치') dept_name
from emp;
-- where  dept_name is null;

-- TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary), 커미션 (salary * comm_pct)을 조회. 커미션이 없는 직원은 0이 조회되록 한다.
select  emp_id,
		emp_name,
        format(salary, 2) as "salary",
        comm_pct,
        format(salary * ifnull(comm_pct, 0), 2)  as "commission",
        format(ifnull(salary * comm_pct, 0), 2)  as "commission2"
from    emp;


/***********************************************
함수 - 타입변환함수
cast(값 as 변환할타입)
convert(값, 변환할타입)

변환가능 타입
  - BINARY: binary 데이터로 변환 (blob)
  - SIGNED: 부호있는 정수(64bit)
  - UNSIGNED: 부호없는 정수(64bit)
  - DECIMAL: 실수
  - CHAR: 문자열 타입 
  - DATE: 날짜 
  - TIME: 시간
  - DATATIME: 날짜시간 타입
	- 정수를 날짜, 시간타입으로 변환할 때는 양수만 가능. (음수는 NULL 반환)
***********************************************/
-- 시간을 정수형태로 변환   
select cast(now() as signed);  -- 20230830233517
select convert(now(), signed);

-- 숫자를 날짜로 변환
select cast(20201123 as date);
select cast(102034 as time);
select cast(1023 as time);  -- 00:10:23 으로 반환

-- 숫자를 문자열로 변환
select cast(2020 as char);

select '2000' + '3000'; -- 자동 변환 후 계산됨.

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

/*
if dept_name==null:
    return '부서없음'
elif dept_name=='IT':
    return '전산실'
elif dept_name=='Finance':
    return '회계부'
else:
    return dept_name    
*/
select  case  dept_name  when 'IT' then '전산실' 
			             when 'Finance' then '회계부'
                         when 'Sales' then '영업부'
                         else ifnull(dept_name, '부서없음') --  원래값을 리턴
                         end as "부서명"
from emp;
						 
 
/*
널처리 위처럼 하거나 
또는 ifnull이용해 미리 바꾼다.
case ifnull(dept_name, '부서없음')  when 'IT' then '전산실'
                       when 'Finance' then '회계부'sel
                       else dept_name
*/

select  case when dept_name is null then '부서없음'
             else dept_name end "부서"
from emp
order by 1 desc;  


-- EMP테이블에서 급여와 급여의 등급을 조회하는데 급여 등급은 10000이상이면 '1등급', 10000미만이면 '2등급' 으로 나오도록 조회
select  salary,
        case when salary >= 10000 then '1등급'
             else '2등급'
        end "급여등급"
from emp
order by 1;        

-- TODO: EMP 테이블에서 업무(job)이 'AD_PRES'거나 'FI_ACCOUNT'거나 'PU_CLERK'인 직원들의 ID(emp_id), 이름(emp_name), 업무(job)을 조회.  
-- 업무(job)가 'AD_PRES'는 '대표', 'FI_ACCOUNT'는 '회계', 'PU_CLERK'의 경우 '구매'가 출력되도록 조회
select  job,
        case job when 'AD_PRES' then '대표' 
                 when 'FI_ACCOUNT' then '회계'
                 when 'PU_CLERK' then '구매' 
                 else '기타'
        end  JOB2

from    emp
where   job in ('AD_PRES', 'FI_ACCOUNT', 'PU_CLERK');


-- TODO: EMP 테이블에서 부서이름(dept_name)과 급여 인상분을 조회.
-- 급여 인상분은 부서이름이 'IT' 이면 급여(salary)에 10%를 'Shipping' 이면 급여(salary)의 20%를 'Finance'이면 30%를 나머지는 0을 출력

select  dept_name, salary,
        case dept_name when 'IT' then salary * 0.1 
                       when 'Shipping' then salary * 0.2
                       when 'Finance' then salary * 0.3
                       else 0
        end as 급여인상분
from emp
order by 3 desc;        

-- TODO: EMP 테이블에서 직원의 ID(emp_id), 이름(emp_name), 급여(salary), 인상된 급여를 조회한다. 
-- 단 급여 인상율은 급여가 5000 미만은 30%, 5000이상 10000 미만는 20% 10000 이상은 10% 로 한다.
select  emp_id, emp_name, salary,
        case when salary<5000 then salary*0.3
             -- when salary<5000 and dept_name='IT' then salary*0.3
             when salary between 5000 and 9999 then salary * 0.2
             -- when salary >= 10000
             else salary * 0.1
        end "인상된 급여"
from emp;        


--  case 를 이용한 정렬
--  직원들의 모든 정보를 조회한다. 단 정렬은 업무(job)가 
-- 'ST_CLERK', 'IT_PROG', 'PU_CLERK', 'SA_MAN' 순서대로 먼저나오도록 한다. (나머지 JOB은 상관없음)
select * 
from emp
order by case job when 'ST_CLERK' then 1 
				  when 'IT_PROG' then 2 
                  when 'PU_CLERK' then 3
                  when 'SA_MAN' then 4 
                  else job end asc;



