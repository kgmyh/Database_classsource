-- 한줄 주석 (--공백 으로 시작)
/* block 주석 */

/*
Mysql Workbench
  - font 바꾸기 - edit/preferences -> font and color
  
  - SQL문 실행 - control + enter (cmd + enter)
*/
/*****************************************
Database 생성

CREATE DATABASE DB이름;
*****************************************/

create database testdb1;
create database testdb2;
create database testdb3;
 -- DB 여러개 만들고 권한 줄때 설명에서 이용.

  
-- DB 확인
show databases;
/**********************************************************************************************************
사용자 계정 생성
- create user 'username'@'host' identified by 'password'
  - usernamer과 host를 따로 작은 따옴표로 묶어준다.
  - host
    - localhost :로컬접속 계정
    - % : 원격 접속 계정

**********************************************************************************************************/
-- local 접속 계정
create user '사용자이름'@'localhost' identified by '패스워드';
-- 원격 접속 계정
create user '사용자이름'@'%' identified by '패스워드';
-- 등록된 사용자계정 조회
select user, host from mysql.user;

/********************************************************
 계정에 권한 부여
- GRANT 부여할 권한 ON 데이터베이스.테이블 TO 계정@host
- 데이터베이스와 테이블을 `*` 로 지정하면 모든 DB와 테이블에 적용된다.
- 주요 권한 목록
  - all privileges: 모든권한
  - 테이블의 데이터 관리: select, insert, update, delete
  - DB 객체 관리: create, drop, alter
  - 사용자관리: create user, drop user, grant option
********************************************************/
grant all privileges on *.* to playdata@localhost;
grant all privileges on *.* to playdata@'%';

-- 권한 조회

show grants for current_user(); -- 현재 계정
show grants for 'kgmyh'@'localhost'; -- 특정 계정(권한이 있어야 한다.)
-- grant 구문이 나온다. (grant usage on ... 이 먼저 나오는데  이것은 **존재하지만 아무런 권한도 부여하지 않는다**로 계정이 생기면 자동으로 만들어지는 권한이다.)

create database testdb;
use testdb;

/***********************************************************************************************************
테이블 생성
create table 테이블 이름 (컬럼명  데이터타입  [제약조건])

테이블 삭제
drop table [if exists] 삭제할테이블이름

------------------------------------------------------------------------------------------------------------
테이블: 회원 (member)
속성
id:        varchar(10)    primary key
password:  varchar(10)    not null (필수)
name:      varchar(30)    not null
point:     int            nullable
email:     varchar(100)   unique key
gender:    char(1)        not null, check key - 'm', 'f' 만 값으로 가진다.
age:       int            check key - 양수만 값으로 가진다.
join_date: timestamp      not null, 기본값-값 저장시 일시
***********************************************************************************************************/
-- 컬럼명   데이터타입   제약조건
create table member (
	 id  varchar(10)  primary key,
     password  varchar(10)  not null,
     name  varchar(50)  not null,
     point  int   default 1000,
     email  varchar(100)  unique,
     gender char(1) not null check(gender in ('m', 'f')), -- ***** check 대문자 'M'도 들어간다. 흠
     age int check(age > 0),
     join_date  timestamp  not null  default current_timestamp
);

desc member;
-- 테이블 삭제
drop table member;



/* *********************************************************************
INSERT 문 - 행 추가
구문
 - 한행추가 :
   - SQL은 기본적으로 한 행(한개의 데이터)씩 테이블에 추가한다.
   - INSERT INTO 테이블명 (컬럼 [, 컬럼]) VALUES (값 [, 값[])
   - 모든 컬럼에 값을 넣을 경우 컬럼 지정구문은 생략 할 수 있다.

************************************************************************ */

-- 한행 insert (데이터를 삽입)
insert into member values ('id-111', '1111', '홍길동', 3000, 'abc@a.com', 'm', 20, '2020-1-2 10:10:20');

insert into member (id, password, name,  join_date) 
				   values ('id-1', '1111', '홍길동',  '2020-05-20');

-- 모든 컬럼에 값을 다 넣을 경우 컬럼 지정하는 것은 생략가능
insert into member values ('id-2', '2222', '박영희', 2000, '2019-12-10');

-- 특정 컬럼에만 값을 넣을 경우 컬럼명을 지정해햐 한다.
-- point, join_date는 생략하면 default값이 들어간다.
insert into member (id, password, name)
			        values ('id-3', '3333', '김영수');

-- joint_date 는 not null이지만 안넣으면 설정된 default값이 들어간다. 단 null을 명시적으로 넣으면 에러.
insert into member (id, password, name)
				   values ('id-4', '3333', '김영수'); 

insert into member (id, password, name,  join_date)
				   values ('id-5', '3333', '김영수', null); -- null은 제약조건을 어겼으므로 에러 발생


insert into member values ('id-6', '3333', '박철우', null, '2010-10-10'); -- point는 not null이므로 정상처리





