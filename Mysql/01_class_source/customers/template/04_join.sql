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

-- customer_id가 1인 고객의 정보와 그 고객의 주문 정보(order)를 조회


-- 10번 주문(orders.order_id)의 주문 일자(order.order_date), 주문고객이름(customer.customer_name), 주문 고객의 전화번호 조회(customer.phone)


-- 주문 상태(orders.order_status)가 PAID인 주문자 ID(customer.customer_id), 주문자 이름(customer.customer_name), 주문일자(order.order_date), 배송지 주소(order.shipping_address), 총 구매액(order.total_amount) 를 조회


-- 주문 상태(orders.order_status)가 PAID인 주문자 ID(customer.customer_id), 주문자 이름(customer.customer_name), 주문일자(order.order_date), 배송지 주소(order.shipping_address), 총 구매액(order.total_amount) 
-- 주문 제품의 정보를 조회



-- 주문 상태(orders.order_status)가 PAID인 주문자 ID(customer.customer_id), 주문자 이름(customer.customer_name), 주문일자(order.order_date), 배송지 주소(order.shipping_address), 총 구매액(order.total_amount) 
-- 주문 제품의 주문수량(order_item.quantity), 판매가격(order_item.unit_price)
-- 제품 이름(product.product_name), 가격(product.price), 재고수량(product.stock_qty)을 조회



-- 제품ID(product.product_id)가 1인 제품이 얼마나 팔렸는지 조회


-- 2026-01-05일에 주문된 상품의 이름, 가격, 재고량를 조회



/* ****************************************************
Self 조인
- 물리적으로 하나의 테이블을 두개의 테이블처럼 조인하는 것.
**************************************************** */
-- 다음 고객 정보를 조회. 고객 ID(customer_id), 고객이름(customer_name), 추천자 ID(customer_id), 추천자 이름(customer_name).


-- 추천을 가장 많이 한 고객의 id(customer_id)와 이름(customer_name)을 조회



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


-- 제품 분류(product.category)별 총 주문개수(order_item.quantity)를 조회



-- 제품 ID(product.product_id)가 10인 제품이 2026년 1월에 몇 건 주문 되었는지 조회


