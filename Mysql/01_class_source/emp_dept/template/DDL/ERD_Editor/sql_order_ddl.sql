

CREATE TABLE CUSTOMERS (
	cust_id 	 INT PRIMARY KEY COMMENT '고객_ID',
	cust_name 	 VARCHAR(20) NOT NULL COMMENT '고객_이름',
	address 	 VARCHAR(40) NOT NULL COMMENT '주소',
	postal_code  VARCHAR(10) NOT NULL COMMENT '우편번호',
	cust_email 	 VARCHAR(30) NOT NULL COMMENT '고객_이메일주소',
	phone_number VARCHAR(15) COMMENT '전화번호',
	gender 		 CHAR(1) COMMENT '성별',
	join_date 	 DATE NOT NULL COMMENT '가입일'
) COMMENT '고객';

CREATE TABLE PRODUCTS (
	product_id 	 INT PRIMARY KEY COMMENT '제품_ID',
	product_name VARCHAR(125) NOT NULL COMMENT '제품_이름',
	category	 VARCHAR(30) NOT NULL COMMENT '제품분류',
	maker		 VARCHAR(50) NOT NULL COMMENT '제조사',
	price		 INT NOT NULL COMMENT '제품가격'
) COMMENT '상품';

CREATE TABLE ORDERS (
	order_id 	 INT PRIMARY KEY COMMENT '주문_ID',
	order_date 	 DATE NOT NULL COMMENT '주문일',
	cust_id 	 INT NOT NULL COMMENT '고객_ID',
	order_status VARCHAR(20) NOT NULL COMMENT '주문상태',
	order_total  INT COMMENT '주문 총금액',
    CONSTRAINT fk_order_customer FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
) COMMENT '주문';


CREATE TABLE ORDER_ITEMS (
	order_item_id 	INT PRIMARY KEY COMMENT '주문상세_ID',
	sell_price 		INT NOT NULL COMMENT '판매가격',
	quantity 		INT NOT NULL COMMENT '수량',
	product_id 		INT COMMENT '제품_ID',
	order_id 		INT COMMENT '주문_ID',
    CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
) COMMENT '주문상세';
