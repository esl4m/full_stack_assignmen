SELECT *, round((budgets.a_amount_spent / budgets.a_budget_amount * 100), 2) AS percentage,
       floor(round((budgets.a_amount_spent / budgets.a_budget_amount) * 100) / 50) -
       sent_notifications.threshold AS `target_score`
FROM t_shops as shops,
     t_budgets as budgets,
     sent_notifications
WHERE shops.a_online = 1
  AND shops.a_id = budgets.a_shop_id
  AND YEAR(budgets.a_month) = YEAR(NOW())
  AND MONTH(budgets.a_month) = MONTH(NOW())
  AND round((budgets.a_amount_spent / budgets.a_budget_amount) * 100) > 50
  AND sent_notifications.a_shop_id = shops.a_id
  AND YEAR(sent_notifications.a_month) = YEAR(NOW())
  AND MONTH(sent_notifications.a_month) = MONTH(NOW())
  AND (floor(round((budgets.a_amount_spent / budgets.a_budget_amount) * 100) / 50) - sent_notifications.threshold) >
      0;