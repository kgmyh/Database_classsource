-- ============================================
-- shop_db 실습용 샘플 데이터베이스 시드 스크립트
-- 사용법: psql -U postgres -d shop_db -f shop_db_seed.sql
-- ============================================

-- 기존 테이블 초기화 (재실행 대비, 자식 → 부모 순서로 삭제)
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;

-- ============================================
-- 테이블 생성 (DDL)
-- ============================================

CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category_id     INT REFERENCES categories(category_id),
    price           NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity  INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at      DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    customer_name   VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    city            VARCHAR(30),
    join_date       DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    employee_name   VARCHAR(50) NOT NULL,
    department      VARCHAR(30),
    manager_id      INT REFERENCES employees(employee_id),
    hire_date       DATE NOT NULL,
    salary          NUMERIC(10,2)
);

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    employee_id     INT REFERENCES employees(employee_id),
    order_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    status          VARCHAR(20) NOT NULL DEFAULT '결제완료'
                    CHECK (status IN ('결제완료','배송중','배송완료','취소'))
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id),
    product_id      INT NOT NULL REFERENCES products(product_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL
);

CREATE TABLE reviews (
    review_id       SERIAL PRIMARY KEY,
    product_id      INT NOT NULL REFERENCES products(product_id),
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    rating          SMALLINT CHECK (rating BETWEEN 1 AND 5),
    review_text     TEXT,
    review_date     DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ============================================
-- 샘플 데이터 입력 (DML)
-- ============================================

INSERT INTO categories (category_name) VALUES
('도서'), ('전자제품'), ('생활용품'), ('식품'), ('의류');

INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('무선 이어폰', 2, 89000, 45),
('블루투스 키보드', 2, 45000, 20),
('스탠드 조명', 3, 32000, 15),
('머그컵', 3, 12000, 100),
('원두커피 1kg', 4, 18000, 60),
('견과류 세트', 4, 25000, 0),
('SQL 첫걸음', 1, 22000, 30),
('데이터베이스 개론', 1, 27000, 12),
('면 티셔츠', 5, 19000, 50),
('후드 집업', 5, 42000, 8);

INSERT INTO customers (customer_name, email, phone, city, join_date) VALUES
('김민준', 'minjun@example.com', '010-1111-2222', '서울', '2024-01-15'),
('이서연', 'seoyeon@example.com', '010-2222-3333', '부산', '2024-02-20'),
('박도윤', 'doyoon@example.com', NULL, '서울', '2024-03-05'),
('최지우', 'jiwoo@example.com', '010-4444-5555', '대전', '2024-05-11'),
('정하은', 'haeun@example.com', '010-5555-6666', '서울', '2025-01-02');

INSERT INTO employees (employee_name, department, manager_id, hire_date, salary) VALUES
('강태호', '영업팀', NULL, '2020-03-01', 5200000),
('오유진', '영업팀', 1, '2021-07-15', 3800000),
('한지민', '영업팀', 1, '2022-02-10', 3600000),
('윤성민', '고객지원팀', NULL, '2020-11-01', 4900000);

INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
(1, 2, '2025-06-01', '배송완료'),
(2, 2, '2025-06-03', '배송완료'),
(1, 3, '2025-06-10', '배송중'),
(3, NULL, '2025-06-12', '결제완료'),
(4, 3, '2025-06-15', '취소'),
(5, 2, '2025-07-01', '배송완료');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 89000), (1, 4, 2, 12000),
(2, 7, 1, 22000), (2, 8, 1, 27000),
(3, 2, 1, 45000),
(4, 5, 3, 18000),
(5, 9, 2, 19000),
(6, 1, 1, 89000), (6, 3, 1, 32000);

INSERT INTO reviews (product_id, customer_id, rating, review_text, review_date) VALUES
(1, 1, 5, '음질이 정말 좋아요', '2025-06-05'),
(1, 5, 4, NULL, '2025-07-05'),
(7, 2, 5, '입문서로 최고입니다', '2025-06-08'),
(4, 1, 3, '무난해요', '2025-06-06'),
(9, 4, 2, '사이즈가 작게 나와요', '2025-06-20');
