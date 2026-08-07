
/* **************************************************************************
서브쿼리(Sub Query)
- 쿼리안에서 select 쿼리를 사용하는 것.
- 메인 쿼리 - 서브쿼리

서브쿼리가 사용되는 구
 - select절, from절, where절, having절
 
서브쿼리의 종류
- 어느 구절에 사용되었는지에 따른 구분
    - 스칼라 서브쿼리 - select 절에 사용. 반드시 서브쿼리 결과가 1행 1열(값 하나-스칼라) 0행이 조회되면 null을 반환
    - 인라인 뷰 - from 절에 사용되어 테이블의 역할을 한다.
- 서브쿼리 조회결과 행수에 따른 구분
    - 단일행 서브쿼리 - 서브쿼리의 조회결과 행이 한행인 것.
    - 다중행 서브쿼리 - 서브쿼리의 조회결과 행이 여러행인 것.
- 동작 방식에 따른 구분
    - 비상관 서브쿼리 - 서브쿼리에 메인쿼리의 컬럼이 사용되지 않는다.
                메인쿼리에 사용할 값을 서브쿼리가 제공하는 역할을 한다.
    - 상관 서브쿼리 - 서브쿼리에서 메인쿼리의 컬럼을 사용한다. 
                            메인쿼리가 먼저 수행되어 읽혀진 데이터를 서브쿼리에서 조건이 맞는지 확인하고자 할때 주로 사용한다.

- 서브쿼리는 반드시 ( ) 로 묶어줘야 한다.
************************************************************************** */

-- 가장 최근에 가입한 고객과 같은 가입일시(customer.created_at)를 가진 고객을 조회
SELECT *
FROM customer
WHERE created_at = (
    SELECT MAX(created_at)
    FROM customer
);

-- 상품 평균 가격(product.price)보다 비싼 상품을 조회하시오
SELECT *
FROM product
WHERE price > (
    SELECT AVG(price)
    FROM product
);

-- 전체 고객의 평균 총 구매액(customer.total_spent)보다 총 구매액이 큰 고객을 조회하시오.
SELECT *
FROM customer
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM customer
);

-- 추천인이 있는 고객과 없는 고객간의 평균 총 결제금액(total_spent) 차이를 비교
select is_recommender, avg(total_spent) from (
	select if(recommender_id is null, '추천인 없음', '추천인 있음') as is_recommender, total_spent from customer
) t
group by is_recommender;

-- 추천을 가장 많이 한 고객의 id와 이름을 조회.  공동 1등이 여러명일 때 다 다나오도록 조회한다.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS recommend_count
FROM customer r
INNER JOIN customer c
    ON r.recommender_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM customer
        WHERE recommender_id IS NOT NULL
        GROUP BY recommender_id
    ) t
);

############# 다중행
-- 전체 주문의 평균 주문금액(orders.total_amount)보다 큰 주문을 한 고객의 정보를 조회하시오.
SELECT *
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount > (
        SELECT AVG(total_amount)
        FROM orders
    )
);

-- 최근 3개월 동안 주문한 고객 중에서 Gold 또는 VIP 등급 고객의 정보를 조회하시오.
SELECT
    customer_id,
    customer_name,
    grade,
    total_spent
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM orders 
    WHERE order_date >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
)
AND grade IN ('Gold', 'VIP')
ORDER BY customer_name ASC;



-- 고객(customer) 중 주문(orders)을 한번 이상 한/하지 않은 고객들을 조회.
select * from customer c
where  exists (select customer_id
               from orders
               where customer_id = c.customer_id);


select * from customer c
where not exists (select customer_id
               from orders
               where customer_id = c.customer_id);

-- 확인
-- select * from orders where customer_id  in (3 ,5, 11, 13, 16, 19, 22, 24)


--  제품(product) 중 한번 이상 주문된/안된 제품 정보 조회
select * from product p
where   not exists (select product_id
                from order_item
                where product_id = p.product_id);