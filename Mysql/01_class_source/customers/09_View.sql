use my_mall;

-- 전체 JOIN view 생성

# GUIDE 컬럼명이 중복되면 안된다. 그럴 때는 alias를 준다.
create or replace view order_info_view
as
select c.customer_id, c.customer_name, c.email, c.phone, c.gender, c.birth_date, c.grade, c.total_spent, c.reward_point, c.is_active, c.created_at, c.last_login, c.recommender_id,
       o.order_id, o.order_date, o.order_status, o.payment_method, o.shipping_address, o.total_amount,
       oi.order_item_id, oi.quantity, oi.unit_price, oi.line_amount,
       p.product_id, p.product_name, p.category, p.brand, p.price, p.stock_qty, p.status, p.created_at as product_created_at
from customer c left join orders o on c.customer_id = o.customer_id
                left join order_item oi on o.order_id = oi.order_id
                left join product p on oi.product_id = p.product_id;

select * from order_info_view;

-- 1번 고객이 주문한 내역
select * from order_info_view
where customer_id = 1;







-- 없으면 만들고 있으면 제거하고 다시 생성
create or replace view emp_dept_view
as
select e.emp_id, e.emp_name, e.hire_date, e.salary, e.comm_pct, d.dept_id, d.dept_name, d.loc
from emp e inner join  dept d on e.dept_id = d.dept_id
where e.job_id is not null;


select *
from emp_dept_view;


insert into emp_dept_view 
(emp_id, emp_name, hire_date, salary, comm_pct, dept_id, dept_name, loc)
values(700, '홍길동', '2000-10-10', 30000, null, 90, 'Executive', 'Seattle');

-- View 생성
create view high_salary_emp
as
select emp_id, emp_name, salary from emp
where salary > 10000 
order by salary desc;

select * from high_salary_emp;

-- View 수정
alter view high_salary_emp
as
select emp_id, emp_name, salary, hire_date from emp
where salary > 10000 
order by salary desc;

select * from high_salary_emp;

-- View를 통해 값 변경 - View에서 조회한 테이블의 규칙에 맞아야 한다.
-- insert
insert into high_salary_emp (emp_id, emp_name, salary, hire_date) values (901, '이순신', 15000, '2000-10-10');
-- UPDATE 
-- 가능하다. 
update high_salary_emp set emp_name = 'James Lon' where emp_id = 901;
select * from emp where emp_id = 901; -- 테이블 update 됨

-- View 정의 확인
show create VIEW high_salary_emp;

-- view 삭제
drop view high_salary_emp;

-- with check option
-- view를 통해 insert/update 할 경우 변경되는 값이 view에서 보이는 조건의 데이터야 한다. 는 옵션
create or replace view test_dept
as
select * from dept where dept_id < 500 -- ;
-- with check option;
;

select * from test_dept;

insert into test_dept values ( 702, '기획2부', '서울'); -- (with check option 전: 들어간다. 후: 안들어간다.)
select * from test_dept; -- 단 view를 통해 보이지 않는다.
select * from dept order by dept_id desc;


-- 집계 (집계 View는 insert안됨)
create or replace view vm_salary_agg_by_dept
as
select d.dept_id, d.dept_name, 
       round(avg(e.salary), 2) "평균급여", round(std(e.salary)) "급여 표준편차", min(e.salary) "최소급여", max(e.salary) "최대급여",
       count(e.emp_id) "직원수"
from emp e left join dept d on e.dept_id = d.dept_id
group by d.dept_id, d.dept_name
order by 1;

select * from vm_salary_agg_by_dept;

/*
- insert는 실제 테이블로 들어가는 것이므로 테이블의 insert 조건에 맞아야 한다.
    - 위의 test_emp의 경우 view의 컬럼 3개 이외에 emp 테이블에 not null 컬럼이 있으므로 view를 통한 insert가 안된다.
- join 을 통해 둘 이상의 테이블로 부터 조회한 View는 insert를 할 수 없다.
*/

SHOW FULL TABLES WHERE Table_type = 'VIEW'