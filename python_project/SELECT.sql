SELECT
       shops.a_id,
       shops.a_name,
       budgets.a_month,
       budgets.a_budget_amount,
       budgets.a_amount_spent,
       round((budgets.a_amount_spent / budgets.a_budget_amount * 100), 2)                                         AS `percentage`,
       sent_notifications.threshold,
       floor(round((budgets.a_amount_spent / budgets.a_budget_amount) * 100) / 50) - sent_notifications.threshold AS `target_score`
FROM t_shops as shops,
     t_budgets as budgets,
     sent_notifications
WHERE shops.a_online = 1                               # online only

  AND shops.a_id = budgets.a_shop_id
  AND YEAR(budgets.a_month) = YEAR(NOW())              # current budget year
  AND MONTH(budgets.a_month) = MONTH(NOW())            # current budget month
  AND round((budgets.a_amount_spent / budgets.a_budget_amount) * 100) > 50

  AND shops.a_id = sent_notifications.a_shop_id
  AND YEAR(sent_notifications.a_month) = YEAR(NOW())   # current notification month
  AND MONTH(sent_notifications.a_month) = MONTH(NOW()) # current notification year

  AND (floor(round((budgets.a_amount_spent / budgets.a_budget_amount) * 100) / 50) - sent_notifications.threshold) > 0 # threshold we are using to select the right shops
;