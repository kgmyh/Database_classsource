/* ***********************************************************************************
테이블 생성
- 구문
create table 테이블 이름(
  컬럼 설정
)
컬럼 설정
- 컬럼명   데이터타입  [default 값]  [제약조건] 
- 데이터타입
- default : 기본값. 값을 입력하지 않을 때 넣어줄 기본값.

제약조건 설정 
- primary key (PK): 행식별 컬럼. NOT NULL, 유일값(Unique)
- unique Key (uk) : 유일값을 가지는 컬럼. null을 가질 수있다.
- not null (nn)   : 값이 없어서는 안되는 컬럼.
- check key (ck)  : 컬럼에 들어갈 수 있는 값의 조건을 직접 설정.
- foreign key (fk): 다른 테이블의 primary key 컬럼의 값만 가질 수 있는 컬럼. 
                    다른 테이블을 참조할 때 사용하는 컬럼.

- 컬럼 레벨 설정
    - 컬럼 설정에 같이 설정
- 테이블 레벨 설정
    - 컬럼 설정 뒤에 따로 설정
	- 기본 구문 : [constraint 제약조건이름] 제약조건타입(지정할컬럼명) 
- 테이블 제약 조건 조회
    - select * from information_schema.table_constraints;

    
테이블 삭제
- 구문
DROP TABLE 테이블이름;
DROP TABLE IF EXISTS 테이블이름;

- 제약조건 해제
   SET FOREIGN_KEY_CHECKS = 0;
- 제약조건 설정
   SET FOREIGN_KEY_CHECKS = 1;   
*********************************************************************************** */
SET FOREIGN_KEY_CHECKS = 1;
-- 컬럼레벨 제약조건 설정
drop table if exists parent_tb;
create table parent_tb(
    no       int          primary key,
    name     varchar(50)   not null, -- not null은 컬럼 레벨로 설정.
    email    varchar(100) unique, 
    gender   char(1) not null check(gender in ('M', 'F')), -- 대소문자는 안가린다. 흠흠흠.
	create_at timestamp  default current_timestamp  -- 기본값:current_timestamp 등록일자 , type은 timestamp로 해야 한다.
);
select * from information_schema.table_constraints where table_name = 'parent_tb'; -- 제약 조건 확인

insert into parent_tb (no, name, email, gender)  -- 이렇게 넣으면 auto_increment는 다음 번호부터 추가된다. (101,102,...)values (100, '이름1', 'a@a.com', 'M');

insert into parent_tb (no, name, birthday, email, gender) 
values (101, '이름2', null, 'b@b.com', 'F');

insert into parent_tb (no, name, birthday, email, gender) 
values (102, '이름2', null, 'b@b.com', 'F');-- email은 UK

insert into parent_tb (no, name, birthday, email, gender) 
values (104, '이름2', null, 'd@b.com', 'a');-- gender: check (M, F) -- 대소문잔 안가리네.



-- 테이블 레벨의 제약조건 설정.
drop table child_tb;
create table child_tb(
    no 			int   auto_increment, -- PK, auto_increment: 자동증가.
    jumin_num 	char(14), -- UK
    age 		int not null,-- CK(10~90)
    parent_no 	int,   -- FK
    constraint child_pk primary key(no), -- #####  PK는 우리가 준 이름이 적용안됨.
    constraint child_jumin_uk unique(jumin_num),
    constraint child_age_ck check(age between 10 and 90),
    -- constraint child_parent_fk foreign key(parent_no) references parent_tb
    -- constraint child_parent_fk foreign key(parent_no) references parent_tb on delete set null 
    -- on delete set null: 부모 테이블의 참조 행이 삭제되면 null로 값을 변경.
    constraint child_parent_fk foreign key(parent_no) references parent_tb(no) on delete cascade
    -- on delete cascade : 부모 테이블의 참조 행이 삭제 되면 자식의 행도 같이 삭제.
);
select * from parent_tb;
insert into child_tb values(100, '851102-1010101', 30, 104);
insert into child_tb values(101, null, 30, 101);
insert into child_tb values(102, null, 30, 101);-- UK경우 null은 여러개 넣을 수 있다.
insert into child_tb values(103, null, 5, 100);-- age: 10~90사이
insert into child_tb values(104, null, 30, 200);-- FK: 200은 parent_tb에 없는 값.

delete from parent_tb where no = 104;  -- on cascade이므로 자식도 같이 삭제된다.

/* ************************************************************
*  constraint name 안주고 만들기
*************************************************************** */
create table child_tb2(
   no  int  auto_increment, -- PK, auto_increment: 자동증가. ========= 이거 설정해도 원하는 값 명시적으로 넣을 수는 있다.
   jumin_no char(14) not null, -- UK
   age  int not null, -- CK (0이상)
   parent_no int, -- FK (parent_tb의 no컬럼 참조)
   primary key(no),
   unique(jumin_no),
   check(age > 0), -- check(age between 10 and 50)
   foreign key(parent_no) references parent_tb(no)
);

-- TODO
-- 출판사(publisher) 테이블
-- 컬럼명                 | 데이터타입        | 제약조건        
-- publisher_no 		| int  			| primary key, 자동증가
-- publisher_name 		| varchar(50)   | not null 
-- publisher_address 	| varchar(100)  |
-- publisher_tel 		| varchar(20)   | not null


-- 책(book) 테이블
-- 컬럼명 		   | 데이터타입            | 제약 조건         |기타 
-- isbn 		   | varchar(13),       | primary key
-- title 		   | varchar(50) 		| not null 
-- author 		   | varchar(50) 		| not null 
-- page 		   | int 		 		| not null, check key-0이상값
-- price 		   | int 		 		| not null, check key-0이상값 
-- publish_date   | timestamp 			| not null, default-current_timestamp(등록시점 일시)
-- publisher_no   | int 		        | not null, Foreign key-publisher



drop table book;
drop table publisher;

-- 출판사 테이블
create table publisher(
    publisher_no 		int  auto_increment not null,
    publisher_name 		varchar(50) not null,
    publisher_address 	varchar(100), 
    publisher_tel 		varchar(20) not null,
    constraint publisher_pk primary key(publisher_no)
);
-- 책 테이블
create table book(
    isbn 		 varchar(13),
    title 		 varchar(50) not null,
    author 		 varchar(50) not null,
    page 		 int 		 not null,
    price 		 int 		 not null,
    publish_date timestamp default current_timestamp  not null,
    publisher_no int 		 not null,
    constraint book_pk primary key(isbn),
    constraint book_price_ck check(price >= 0),
    constraint book_page_ck  check(page >=0),
    constraint book_publisher_fk foreign key(publisher_no) references publisher(publisher_no)
);



/* ************************************************************************************
ALTER : 테이블 수정

컬럼 관련 수정

- 컬럼 추가
  ALTER TABLE 테이블이름 ADD COLUMN 추가할 컬럼설정 [,ADD COLUMN 추가할 컬럼설정]
  
- 컬럼 수정
  ALTER TABLE 테이블이름 MODIFY COLUMN 수정할컬럼명 타입 null설정 [, MODIFY COLUMN 수정할컬럼명 타입 null설정]
	- 숫자/문자열 컬럼은 크기를 늘릴 수 있다.
		- 크기를 줄일 수 있는 경우 : 열에 값이 없거나 모든 값이 줄이려는 크기보다 작은 경우
	- 데이터가 모두 NULL이면 데이터타입을 변경할 수 있다. (단 CHAR<->VARCHAR 는 가능.)
	- null 설정을 생략하면 nullable이 된다.

- 컬럼 삭제	
  ALTER TABLE 테이블이름 DROP COLUMN 컬럼이름 [CASCADE CONSTRAINTS]
    - CASCADE CONSTRAINTS : 삭제하는 컬럼이 Primary Key인 경우 그 컬럼을 참조하는 다른 테이블의 Foreign key 설정을 모두 삭제한다.
	- 한번에 하나의 컬럼만 삭제 가능.
	


- 컬럼 이름 바꾸기
  ALTER TABLE 테이블이름 RENAME COLUMN 원래이름 TO 바꿀이름;

**************************************************************************************  
제약 조건 관련 수정
-제약조건 추가
  ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건 설정

- 제약조건 삭제
  ALTER TABLE 테이블명 DROP CONSTRAINT 제약조건이름
  PRIMARY KEY 제거: ALTER TABLE 테이블명 DROP PRIMARY KEY 
	- CASECADE : 제거하는 Primary Key를 Foreign key 가진 다른 테이블의 Foreign key 설정을 모두 삭제한다.

- NOT NULL <-> NULL 변환은 컬럼 수정을 통해 한다.
   - ALTER TABLE 테이블명 MODIFY COLUMN 컬럼명 타입 NOT NULL  
   - ALTER TABLE 테이블명 MODIFY COLUMN 컬럼명 NULL
************************************************************************************ */
-- customers/orders 테이블의 구조만 복사한 테이블 생성(not null을 제외한 제약 조건은 copy가 안됨)
create table cust
as
select * from customers where 1=0;
-- orders -> order
create table ord
as
select * from orders where 1=0;
desc cust;



-- 제약조건 추가 - desc cust;로 확인
-- CUST: pk
alter table cust add constraint cust_pk primary key(cust_id);
alter table ord  add constraint ord_cust_fk foreign key(cust_id) references cust(cust_id);

-- 컬럼 추가
alter table cust add column (age2 int default 0 not null);
desc cust;
-- 컬럼 수정
desc cust;
alter table cust modify column cust_name varchar(20) null,
				 modify column address varchar(40) null, 
                 modify column postal_code varchar(10) null,
                 modify column phone_number varchar(15) not null;

alter table cust modify column cust_name varchar(100);
desc cust;
-- 컬럼 이름 변경
alter table cust rename column age to cust_age;

-- 컬럼 삭제
alter table cust drop column cust_age;



select * from information_schema.table_constraints -- where table_name = '이름';
-- ########## TODO: add constraint 이름 에서 이거 생략가능한지?

-- TODO: emp 테이블의 구조만 복사해서 emp2를 생성 (이후 TODO 문제들은 emp2 테이블을 가지고 한다.)
drop table emp2;
create table emp2 
as
select * from emp where 1 = 0;


-- TODO: gender 컬럼을 추가: type char(1)
alter table emp2 add column gender char(1);


-- TODO: email, jumin_num 컬럼 추가 
--   email varchar(100),  not null  
--   jumin_num char(14), null 허용 unique
alter table emp2 add column email varchar(100) not null,
                 add column jumin_num char(14)  unique;


-- TODO: emp_id 를 primary key 로 변경
alter table emp2 add primary key(emp_id);

  
-- TODO: gender 컬럼의 M, F 저장하도록  제약조건 추가
alter table emp2 add constraint emp2_gender_ck check(gender in ('M', 'F'));

 
-- TODO: salary 컬럼에 0이상의 값들만 들어가도록 제약조건 추가
alter table emp2 add constraint emp2_salary_ck check(salary >= 0);

-- TODO: email 컬럼에 unique 제약조건 추가.
alter table emp2 add constraint emp2_email_uk unique(email);


-- TODO: emp_name 의 데이터 타입을 varchar(100) 으로 변환
alter table emp2 modify column emp_name varchar(100);


-- TODO: job_id를 not null 컬럼으로 변경
alter table emp2 modify column job_id varchar(30) not null;


-- TODO: job_id  를 null 허용 컬럼으로 변경
alter table emp2 modify job_id varchar(30) null;


-- TODO: 위에서 지정한 emp_email_uk 제약 조건을 제거
alter table emp2 drop constraint emp2_email_uk;


-- TODO: 위에서 지정한 emp_salary_ck 제약 조건을 제거
alter table emp2 drop constraint emp2_salary_ck;


-- TODO: gender 컬럼제거
alter table emp2 drop column gender;


-- TODO: email 컬럼 제거
alter table emp2 drop column email;



select * from information_schema.table_constraints 
where table_name = 'emp2'