use my_mall;

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
/* ****************************************
-- INNER JOIN
FROM  테이블a INNER JOIN 테이블b ON 조인조건 

- inner는 생략 할 수 있다.
**************************************** */

-- customer_id가 1인 고객의 정보와 그 고객의 주문 정보를 조회
select c.*, o.*
from customer c join orders o on c.customer_id = o.customer_id
where c.customer_id = 1;

-- 10번 주문(orders.order_id)의 주문 일자(order.order_date), 주문고객이름(customer.customer_name), 주문 고객의 전화번호 조회(customer.phone)
explain
select c.customer_name, c.phone, o.order_id, o.order_date
from customer c join orders o on c.customer_id = o.customer_id
where o.order_id = 10;

-- 주문 상태(orders.order_status)가 PAID인 주문자 ID(customer.customer_id), 주문자 이름(customer.customer_name), 주문일자(order.order_date), 배송지 주소(order.shipping_address), 총 구매액(order.total_amount) 를 조회
select c.customer_id, c.customer_name, o.order_date, o.shipping_address, o.total_amount
from orders o join customer c on o.customer_id = c.customer_id
where o.order_status = 'PAID';

-- 주문 상태(orders.order_status)가 PAID인 주문자 ID(customer.customer_id), 주문자 이름(customer.customer_name), 주문일자(order.order_date), 배송지 주소(order.shipping_address), 총 구매액(order.total_amount) 
-- 주문 제품의 정보를 조회
select c.customer_id, c.customer_name, o.order_date, o.shipping_address, o.total_amount,
       oi.*
from orders o join customer c on o.customer_id = c.customer_id
			  join order_item oi on o.order_id = oi.order_id
where o.order_status = 'PAID';

-- 주문 상태(orders.order_status)가 PAID인 주문자 ID(customer.customer_id), 주문자 이름(customer.customer_name), 주문일자(order.order_date), 배송지 주소(order.shipping_address), 총 구매액(order.total_amount) 
-- 
-- 주문 제품의 주문수량(order_item.quantity), 판매가격(order_item.unit_price)
-- 제품 이름(product.product_name), 가격(product.price), 재고수량(product.stock_qty)을 조회
select c.customer_id, c.customer_name, o.order_date, o.shipping_address, o.total_amount,
       oi.quantity, oi.unit_price, oi.line_amount, p.product_name, p.price, p.stock_qty
from orders o join customer c on o.customer_id = c.customer_id
			  join order_item oi on o.order_id = oi.order_id
              join product p on oi.product_id = p.product_id
where o.order_status = 'PAID';


-- 제품ID(product.product_id)가 1인 제품이 얼마나 팔렸는지 조회
-- select sum(quantity)
select * 
from   product p join order_item oi on p.product_id = oi.product_id
where p.product_id = 1;

-- 2026-01-05일에 주문된 상품의 이름, 가격, 재고량를 조회
select o.order_id, p.product_name, p.price, p.stock_qty
from   orders o join order_item oi on o.order_id = oi.order_id
				join product p on p.product_id = oi.product_id
where o.order_date >= '2026-01-05 00:00:00' 
and   o.order_date < '2026-01-06 00:00:00'; # 나노초까지 있기 때문에 between보다는 <= > 로 조회


/* ****************************************************
Self 조인
- 물리적으로 하나의 테이블을 두개의 테이블처럼 조인하는 것.
**************************************************** */
-- 다음 고객 정보를 조회. 고객 ID, 고객이름, 추천자 ID, 추천자 이름.
select c.customer_id, c.customer_name,
	   r.customer_id "추천자 ID", r.customer_name "추천자 이름"
from customer c join customer r on c.recommender_id = r.customer_id;


-- 추천을 가장 많이 한 고객의 id와 이름을 조회
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS recommend_count
FROM customer r -- 추천인 ID
INNER JOIN customer c -- 추천인 이름
    ON r.recommender_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY 3 DESC
LIMIT 1;




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
-- 제품 정보를 조회. 제품 이름.... 
-- 10, 21 번 제품이 판매가 안됨.
select p.product_id, p.product_name, sum(quantity) "총판매수량"
from product p left join order_item oi on p.product_id = oi.product_id
group by p.product_id, p.product_name
order by 1;

-- 제품 분류(product.category)별 총 주문개수(order_item.quantity)를 조회
select p.category, ifnull(sum(oi.quantity), 0) "총 주문개수"
from   product p left join order_item oi on p.product_id = oi.product_id
group by p.category
order by 2;


-- 제품 ID(product.product_id)가 10인 제품이 2026년 1월에 몇 건 주문 되었는지 조회
-- (10은 주문된 적이 없는 제품)
select p.product_id, ifnull(sum(oi.quantity), 0) "총 주문개수"
from   product p left join order_item oi on p.product_id = oi.product_id  -- inner join하면 아예 안나온다.
where p.product_id = 10
group by p.category
