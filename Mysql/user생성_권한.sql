create user kgmyh@'%' identified by 'mptres';

grant all privileges on *.* to kgmyh@'%';



show databases;
select user();

select user, host from user;

drop user scott@localhost;

create user scott@'%' identified by 'tiger';

grant all privileges on *.* to scott@localhost;

-- grant all privileges on hr.* to scott@localhost;