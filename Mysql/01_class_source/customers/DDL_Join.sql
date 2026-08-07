USE my_mall;
DROP TABLE order_item;
DROP TABLE orders;
DROP TABLE product;
DROP TABLE customer;


CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '고유 식별자 (기본키)',
    customer_name VARCHAR(50) NOT NULL COMMENT '이름',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '이메일 (LIKE 검색용)',
    phone VARCHAR(20) COMMENT '전화번호 (문자열 자르기 연습용)',
    gender CHAR(1) NOT NULL COMMENT '성별 (M, F 등 - Grouping 용)',
    job VARCHAR(50) COMMENT '직업',
    birth_date DATE NOT NULL COMMENT '생년월일 (날짜 연산 및 나이 계산용)',
    grade VARCHAR(20) NOT NULL DEFAULT 'Bronze' COMMENT '등급 (Bronze, Silver, Gold, VIP - Grouping 용)',
    total_spent DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT '총 결제금액 (숫자 함수 및 집계용)',
    reward_point INT DEFAULT 0 COMMENT '적립 포인트 (숫자 함수 및 조건부 집계용)',
    is_active BOOLEAN DEFAULT TRUE COMMENT '활성 계정 여부 (True/False 조건 검색용)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시 (연/월/일 추출용)',
    last_login DATETIME COMMENT '최근 로그인 일시 (NULL 처리 연습용)',
    recommender_id INT COMMENT '추천인 ID (NULL 처리 및 Self Join 연습용)',
    CHECK (gender IN ('M', 'F'))
) COMMENT='고객 정보 테이블';


CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '상품 고유 식별자 (기본키)',
    product_name VARCHAR(100) NOT NULL COMMENT '상품명',
    category VARCHAR(50) NOT NULL COMMENT '상품 카테고리 (예: 전자제품, 의류 등)',
    brand VARCHAR(50) COMMENT '브랜드명',
    price INT NOT NULL COMMENT '현재 판매 가격',
    stock_qty INT NOT NULL DEFAULT 0 COMMENT '재고 수량',
    status VARCHAR(20) NOT NULL DEFAULT 'ON_SALE' COMMENT '판매 상태 (ON_SALE, SOLD_OUT 등)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '상품 등록일시'
) COMMENT='상품 정보 테이블';


CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '주문 고유 식별자 (기본키)',
    customer_id INT NOT NULL COMMENT '주문한 고객의 ID',
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '주문 일시',
    order_status VARCHAR(20) NOT NULL DEFAULT 'PAID' COMMENT '주문 상태 (PAID, CANCELLED, SHIPPED 등)',
    payment_method VARCHAR(20) COMMENT '결제 수단 (CARD, CASH, TRANSFER 등)',
    shipping_address VARCHAR(255) COMMENT '배송 주소',
    total_amount INT NOT NULL DEFAULT 0 COMMENT '주문 총 금액 (order_item 합계)',
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
) COMMENT='주문 정보 테이블';


CREATE TABLE order_item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '주문 상세 고유 식별자 (기본키)',
    order_id INT NOT NULL COMMENT '주문 ID',
    product_id INT NOT NULL COMMENT '상품 ID',
    quantity INT NOT NULL DEFAULT 1 COMMENT '주문 수량',
    unit_price INT NOT NULL COMMENT '주문 시점의 상품 단가',
    line_amount INT NOT NULL DEFAULT 0 COMMENT '해당 주문의 총 금액 (수량 * 단가 - 할인)',
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id) REFERENCES product(product_id)
) COMMENT='주문 상세 테이블';