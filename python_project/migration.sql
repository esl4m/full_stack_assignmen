CREATE TABLE sent_notifications
(
    a_shop_id  INT(11)   NOT NULL REFERENCES t_budgets (a_shop_id),
    a_month    DATE      NOT NULL,
    threshold  INT(3),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (a_shop_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

# making things work faster
CREATE INDEX a_month ON t_budgets (a_month, a_shop_id);
CREATE INDEX `a_online` ON t_shops (`a_online`);
CREATE INDEX `a_month` ON sent_notifications (`a_month`);
CREATE INDEX `threshold` ON sent_notifications (`threshold`);

# primary keys should be always unsigned
ALTER TABLE t_shops
    MODIFY a_id INT unsigned;
ALTER TABLE t_budgets
    MODIFY a_shop_id INT unsigned;
ALTER TABLE sent_notifications
    MODIFY a_shop_id INT unsigned;

# this too
ALTER TABLE t_budgets
    MODIFY a_budget_amount decimal(10, 2) unsigned;
ALTER TABLE t_budgets
    MODIFY a_amount_spent decimal(10, 2) unsigned;


INSERT INTO t_shops
    (a_id, a_name, a_online)
VALUES (9, 'Another Shop', 1),
       (10, 'Zooma', 1),
       (11, 'FooBar', 1),
       (12, 'Teddy Bear', 1);

INSERT INTO t_budgets
    (a_shop_id, a_month, a_budget_amount, a_amount_spent)
VALUES (2, '2020-08-01', 670.00, 715.64),
       (3, '2020-08-01', 890.00, 580.81),
       (4, '2020-08-01', 590.00, 754.93),
       (5, '2020-08-01', 870.00, 505.12),
       (6, '2020-08-01', 700.00, 912.30),
       (7, '2020-08-01', 990.00, 805.15),
       (8, '2020-08-01', 720.00, 504.25),
       (9, '2020-08-01', 730.00, 800),
       (10, '2020-08-01', 330.00, 12),
       (11, '2020-08-01', 330.00, 300),
       (12, '2020-08-01', 330.00, 400);

# init notifications, this part will reinit notifications if budget was payed, optimized without usage of JOINs. Won't hurt when there are millions of records.
INSERT INTO sent_notifications (a_shop_id, a_month, threshold)
SELECT shops.a_id AS `a_shop_id`, budgets.a_month AS `a_month`, '0' AS `threshold`
FROM t_shops as shops,
     t_budgets as budgets
WHERE shops.a_online = 1
  AND shops.a_id = budgets.a_shop_id
  AND YEAR(budgets.a_month) = YEAR(NOW())
  AND MONTH(budgets.a_month) = MONTH(NOW())
  AND NOT EXISTS(
        SELECT t_shops.a_id
        FROM t_shops,
             t_budgets,
             sent_notifications
        WHERE t_shops.a_id = sent_notifications.a_shop_id
          AND t_shops.a_id = t_budgets.a_shop_id
          AND YEAR(t_budgets.a_month) = YEAR(NOW())
          AND MONTH(t_budgets.a_month) = MONTH(NOW())
    );

# delete 1 month old notifications
DELETE
FROM sent_notifications
WHERE DATEDIFF(NOW(), a_month) > 31;