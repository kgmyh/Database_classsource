
/*
WITH RECURSIVE cte_name AS (
    -- ① Anchor Query (기준 쿼리)  재귀의 시작점
    SELECT ...

    UNION ALL -- Anchor 결과 + Recursive 결과를 누적

    -- ② Recursive Query (재귀 쿼리)- 자기 자신(cte_name)을 다시 참조. 이전 단계 결과를 이용해 다음 단계를 확장
    SELECT ...
    FROM table
    JOIN cte_name ON ...
)
SELECT * FROM cte_name;

#  작동 방식
1. Anchor Query 실행
2. 결과를 **임시 테이블(CTE)**에 저장
3. Recursive Query 실행
4. 새로 나온 결과를 다시 CTE에 추가
5. 더 이상 새 행이 안 나오면 종료
*/



CREATE TABLE category (
  id          BIGINT PRIMARY KEY,
  name        VARCHAR(200) NOT NULL,
  parent_id   BIGINT NULL,
  depth       INT NOT NULL,         -- 0:대, 1:중, 2:소 (옵션)
  sort_order  INT NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_category_parent
    FOREIGN KEY (parent_id) REFERENCES category(id),
  CONSTRAINT uq_category_parent_name
    UNIQUE (parent_id, name)        -- 같은 부모 아래 이름 중복 방지(정책에 따라)
);

CREATE INDEX idx_category_parent ON category(parent_id);
CREATE INDEX idx_category_depth  ON category(depth);


# Insert
## depth = 0 (대분류)
INSERT INTO category (id, name, parent_id, depth, sort_order)
VALUES
  (1, '패션', NULL, 0, 1),
  (2, '전자제품', NULL, 0, 2);

## depth = 1 (중분류)
INSERT INTO category (id, name, parent_id, depth, sort_order)
VALUES
  (10, '남성의류', 1, 1, 1),
  (11, '여성의류', 1, 1, 2),

  (20, '컴퓨터', 2, 1, 1),
  (21, '모바일', 2, 1, 2);

## depth = 2 (소분류)

INSERT INTO category (id, name, parent_id, depth, sort_order)
VALUES
  (100, '셔츠', 10, 2, 1),
  (101, '자켓', 10, 2, 2),

  (110, '원피스', 11, 2, 1),
  (111, '블라우스', 11, 2, 2),

  (200, '노트북', 20, 2, 1),
  (201, '데스크탑', 20, 2, 2),

  (210, '스마트폰', 21, 2, 1),
  (211, '태블릿', 21, 2, 2);

## depth = 3 (세부 분류 – 재귀 연습용)
INSERT INTO category (id, name, parent_id, depth, sort_order)
VALUES
  (1000, '반팔셔츠', 100, 3, 1),
  (1001, '긴팔셔츠', 100, 3, 2);


SELECT id, name, parent_id, depth
FROM category
ORDER BY depth, parent_id, sort_order;

SELECT id, name, parent_id, depth
FROM category
where parent_id = 1;


## 특정 카테고리의 하위 전체 조회
WITH RECURSIVE tree AS (
    SELECT id, name, parent_id, depth
    FROM category
    WHERE id = 10   -- 남성의류

    UNION ALL

    SELECT c.id, c.name, c.parent_id, c.depth
    FROM category c   -- c: 하위, t: 상위 (먼저 조회된 것)
    JOIN tree t ON c.parent_id = t.id
)
SELECT * FROM tree;

## 리프 노드(자식 없는 카테고리) 찾기
SELECT c.*
FROM category c
LEFT JOIN category child ON child.parent_id = c.id
WHERE child.id IS NULL;

## 조상 방향 탐색 (자식 → 부모)
WITH RECURSIVE ancestors AS (
    SELECT id, name, parent_id, depth
    FROM category
    WHERE id = 1000   -- 반팔셔츠

    UNION ALL

    SELECT p.id, p.name, p.parent_id, p.depth
    FROM category p
    JOIN ancestors a ON a.parent_id = p.id
)
SELECT * FROM ancestors;

## depth 제한 재귀 (안전 장치)
WITH RECURSIVE tree AS (
    SELECT id, name, parent_id, depth
    FROM category
    WHERE id = 1

    UNION ALL

    SELECT c.id, c.name, c.parent_id, c.depth
    FROM category c
    JOIN tree t ON c.parent_id = t.id
    WHERE t.depth < 2
)
SELECT * FROM tree;


;

with recursive tree as (
   select id, name, parent_id, depth
   from category
   where id = 1
   
   union all
   
   select c.id, c.name, c.parent_id, c.depth
   from  category as c join tree as t on c.parent_id = t.id
   where c.depth <= 1
)
select * from tree;





with recursive tree as (
 select * from category where id = 2
 
 union all
 
 select c.* from category c join tree t on c.parent_id = t.id
)
select * from tree;
