CREATE DATABASE MY_MALL;

USE MY_MALL;

DROP TABLE customer;
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,     		 -- 고유 식별자 (기본키)
    customer_name VARCHAR(50) NOT NULL,             		 -- 이름
    email VARCHAR(100) NOT NULL UNIQUE,             		 -- 이메일 (LIKE 검색용)
    phone VARCHAR(20),                       		 -- 전화번호 (문자열 자르기 연습용)
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),	 -- 성별 ('M', 'F' 등 - Grouping 용)
    job    VARCHAR(50),                                      -- 직업
    birth_date DATE NOT NULL,                      			 -- 생년월일 (날짜 연산 및 나이 계산용)
    grade VARCHAR(20) NOT NULL DEFAULT 'Bronze',             -- 등급 ('Bronze', 'Silver', 'Gold', 'VIP' - Grouping 용)
    total_spent INT NOT NULL DEFAULT 0,    	 -- 총 결제금액 (숫자 함수 및 집계용)
    reward_point INT DEFAULT 0,                           		 -- 적립 포인트 (숫자 함수 및 조건부 집계용)
    is_active BOOLEAN DEFAULT TRUE,                 	  	 -- 활성 계정 여부 (True/False 조건 검색용)    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 			 -- 가입일시 (연/월/일 추출용)
    last_login DATETIME,                       		         -- 최근 로그인 일시 (NULL 처리 연습용)
    recommender_id INT                     		 		     -- 추천인 ID (NULL 처리 및 추후 Self Join 연습용)
);

-- CONSTRAINT chk_customer_gender CHECK (gender IN ('Male', 'Female'))

-- 기존 데이터와 동일
INSERT INTO Customer 
(customer_name, email, phone, gender, job, birth_date, grade, total_spent, reward_point, is_active, created_at, last_login, recommender_id)
VALUES
('김민수', 'chulsoo@gmail.com', '010-1111-1111', 'M', 'Engineer', '1990-05-10', 'Gold', 2829000, 5000, TRUE, '2023-01-15 10:00:00', '2026-03-20 09:00:00', NULL),
('이영희', 'younghee@naver.com', '010-2222-2222', 'F', 'Teacher', '1985-08-20', 'Silver', 290000, 1200, TRUE, '2023-03-10 14:30:00', '2026-03-22 12:10:00', 1),
('박민수', 'minsu@kakao.com', '010-3333-3333', 'M', NULL, '1995-12-01', 'Bronze', 0, 0, TRUE, '2024-01-01 08:00:00', NULL, 1),
('최지은', 'jieun@gmail.com', '010-4444-4444', 'F', 'Designer', '1992-03-15', 'VIP', 8393000, 15000, TRUE, '2022-11-05 16:00:00', '2026-03-18 20:00:00', NULL),
('정우성', 'woosung@outlook.com', '010-5555-5555', 'M', 'Actor', '1972-07-07', 'Bronze', 0, 0, FALSE, '2021-05-01 11:00:00', '2025-12-01 10:00:00', NULL),

('한지민', 'jimin@naver.com', '010-6666-6666', 'F', 'Actress', '1982-11-05', 'VIP', 4620000, 8000, TRUE, '2022-09-10 09:00:00', '2026-03-21 11:00:00', 4),
('강동원', 'dongwon@gmail.com', '010-7777-7777', 'M', 'Actor', '1981-01-18', 'Silver', 756000, 2000, TRUE, '2023-06-01 13:00:00', '2026-02-28 08:00:00', NULL),
('김태희', 'taehee@kakao.com', '010-8888-8888', 'F', 'Model', '1983-04-25', 'Gold', 2273000, 7000, TRUE, '2023-07-15 10:30:00', NULL, 4),
('유재석', 'jaesuk@gmail.com', '010-9999-9999', 'M', 'MC', '1972-08-14', 'VIP', 12415000, 30000, TRUE, '2020-01-01 09:00:00', '2026-03-23 07:00:00', 1),
('아이유', 'iu@naver.com', '010-1010-1010', 'F', 'Singer', '1993-05-16', 'Silver', 3085000, 18000, TRUE, '2021-03-03 12:00:00', '2026-03-19 18:00:00', NULL),

('홍길동', 'hong@test.com', '010-1111-2222', 'M', NULL, '1999-01-01', 'Bronze', 0, 0, TRUE, '2025-01-01 00:00:00', NULL, NULL),
('김영수', 'yskim@gmail.com', '010-2222-3333', 'M', 'Student', '2000-02-02', 'Silver', 683000, 100, TRUE, '2025-02-01 10:00:00', '2026-03-01 10:00:00', 11),
('박영희', 'yhpark@naver.com', '010-3333-4444', 'F', 'Student', '2001-03-03', 'Bronze', 0, 0, TRUE, '2025-02-10 11:00:00', NULL, 11),
('이민호', 'minho@gmail.com', '010-4444-5555', 'M', 'Actor', '1987-06-22', 'Gold', 2906000, 9000, TRUE, '2022-12-12 12:00:00', '2026-03-15 13:00:00', NULL),
('태연', 'taeyeon@kakao.com', '010-5555-6666', 'F', 'Singer', '1994-10-10', 'Bronze', 250000, 8500, TRUE, '2023-02-14 14:00:00', '2026-03-10 15:00:00', 14),

('정형돈', 'don@naver.com', '010-6666-7777', 'M', 'Comedian', '1978-02-15', 'Bronze', 0, 0, TRUE, '2023-05-05 10:00:00', NULL, NULL),
('윤하', 'yoonha@gmail.com', '010-7777-8888', 'F', 'Singer', '1988-05-01', 'VIP', 2693000, 3000, TRUE, '2023-08-08 08:00:00', '2026-03-05 09:00:00', 16),
('전지현', 'jihyun@outlook.com', '010-8888-9999', 'F', 'Actress', '1981-10-30', 'VIP', 4875000, 25000, TRUE, '2021-01-01 09:00:00', '2026-03-22 11:00:00', 11),
('공유', 'yu@gmail.com', '010-9999-0000', 'M', 'Actor', '1979-02-16', 'Bronze', 0, 0, TRUE, '2022-04-01 10:00:00', NULL, 18),
('손흥민', 'heungmin@naver.com', '010-1212-1212', 'M', 'Athlete', '1992-07-08', 'VIP', 12706000, 35000, TRUE, '2020-06-01 07:00:00', '2026-03-23 06:00:00', NULL),

('김연아', 'yuna@kakao.com', '010-1313-1313', 'F', 'Athlete', '1990-09-05', 'VIP', 1923000, 40000, TRUE, '2020-02-02 10:00:00', '2026-03-23 10:00:00', 20),
('박보검', 'bogum@gmail.com', '010-1414-1414', 'M', 'Actor', '1993-06-16', 'Bronze', 0, 0, TRUE, '2022-08-08 12:00:00', NULL, 21),
('김고은', 'goeun@naver.com', '010-1515-1515', 'F', 'Actress', '1991-07-02', 'Gold', 3619000, 1500, TRUE, '2023-09-01 13:00:00', '2026-03-01 14:00:00', NULL),
('조정석', 'jungseok@gmail.com', '010-1616-1616', 'M', 'Actor', '1980-12-26', 'Bronze', 0, 0, FALSE, '2023-03-03 09:00:00', '2025-11-11 11:00:00', NULL),
('배수지', 'suzy2@kakao.com', '010-1717-1717', 'F', NULL, '1994-10-10', 'Silver', 866000, 150, TRUE, '2025-03-01 10:00:00', NULL, NULL);
