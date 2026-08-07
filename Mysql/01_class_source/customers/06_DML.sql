/* *********************************************************************
UPDATE : 테이블의 컬럼의 값을 수정
UPDATE 테이블명
SET    변경할 컬럼 = 변경할 값  [, 변경할 컬럼 = 변경할 값]
[WHERE 제약조건]

 - UPDATE: 변경할 테이블 지정
 - SET: 변경할 컬럼과 값을 지정
 - WHERE: 변경할 행을 선택. 
************************************************************************ */

-- 고객 ID(customer_id)가 1인 고객의 total_spent를 5000으로 변경
update customer
set total_spent = 5000
where  customer_id = 1;

-- 고객 ID(customer_id)가 1인 고객의 total_spent을 총 구매액(orders의 total_amount 합계)로 변경
update customer
set total_spent = (select sum(total_amount) from orders where customer_id = 1)
where customer_id = 1;


-- 전체 고객의 적립 포인트(reward_point)를 두배 늘려준다.
update customer
set reward_point = reward_point * 2;



-- 모든 적립 포인트(reward_point)를 total_spent의 1% 로 변경한다.
update customer
set reward_point = total_spent * 0.01;

-- 고객 ID(customer_id)가 2인 고객의 직업(job)과 recommender_id를 null로 변경
update customer
set job = null, recommender_id = null
where customer_id = 2;

/* *********************************************************************
DELETE : 테이블의 행을 삭제
구문 
 - DELETE FROM 테이블명 [WHERE 제약조건]
   - WHERE: 삭제할 행을 선택
************************************************************************ */

SET AUTOCOMMIT=FALSE;
SELECT @@AUTOCOMMIT; -- 0: FALSE, 1: TRUE

-- 고객 ID가 1인 고객정보를 삭제한다. 
-- (외래키 때문에 삭제 안됨)
delete from customer where customer_id = 1;

-- 주문 아이템 ID(order_item_id)가 1인 정보를 삭제.
delete from order_item where order_item_id = 1;
-- rollback; # 되돌려 지는 것 확인

-- 주문량이 1이고 총 가격(line_amount)가 50000 이하인 주문 아이템 삭제
delete from order_item where quantity = 1 and line_amount <= 50000;

