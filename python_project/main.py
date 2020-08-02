#!/usr/bin/env python
from datetime import datetime
import mysql.connector as db

my_db = db.connect(
    # host="localhost",
    host="db",
    user="db",
    passwd="db"
)

my_cursor = my_db.cursor()


def initialize_db():
    """
    initialising DB
    """
    my_cursor.execute("DROP DATABASE IF EXISTS db")
    my_cursor.execute("CREATE DATABASE IF NOT EXISTS db")
    my_cursor.execute("USE db")
    print('DB intitialized')


def structure_and_repopulate_db():
    """
    structure and data import
    """
    with open('db.sql', encoding="utf-8") as f:
        commands = f.read().strip().split(';')
    commands = [command.strip() for command in commands]
    for command in commands:
        my_cursor.execute(command)
    my_db.commit()
    print('Source structure created, data repopulated')


def add_migrations():
    """
    migration
    """
    with open('migration.sql', encoding="utf-8") as f:
        commands = f.read().strip().split(';')
    commands = [command.strip() for command in commands]
    for command in commands:
        my_cursor.execute(command)
    my_db.commit()
    print('Data migrated')


def prepare_db():
    print("==================================================================================================================")
    initialize_db()
    structure_and_repopulate_db()
    add_migrations()


def get_online_shops_with_budgets():
    """
    get all budgets for every shop
    """

    with open('SELECT.sql', encoding="utf-8") as f:
        sql = f.read().strip()
    my_cursor.execute(sql)
    desc = my_cursor.description
    column_names = [col[0] for col in desc]
    shops = [
        dict(zip(column_names, row)) for row in my_cursor.fetchall()
    ]
    return shops


def notify_shop(threshold, shop_id, shop_name, month_of_budget, monthly_budget, monthly_expenditure, percentage):
    """
    notify the shop

    To simulate notifying a shop you may print a message to stdout.
    The message should include the current date, the shop ID, the current month's budget and the expenditure to date in absolute terms as well as as a percentage of the budget.
    """
    date_today = datetime.today().date().strftime("%d.%m.%Y")
    month_and_year = f"{month_of_budget:%-m}/{month_of_budget:%y}"
    print(
        f"| {date_today}\n"
        f"| '{shop_name}' has exceeded {threshold}% of it's budget quota by " + "{:.2f}%".format(percentage - threshold) +
        f" and spent {monthly_expenditure}$ in {month_of_budget:%B} ({month_and_year}) with monthly budget "
        f"of total {monthly_budget} |")

    sql = f"UPDATE sent_notifications SET threshold={threshold} WHERE a_shop_id={shop_id}"
    my_cursor.execute(sql)
    my_db.commit()


def set_offline(shop_id):
    """
    set the shop offline
    """
    sql = f"UPDATE t_shops SET a_online = '0' WHERE a_id = {shop_id}"
    my_cursor.execute(sql)
    my_db.commit()


def check_budgets_of_all_shops():
    """
    main check functions

    Notifying shops when their monthly expenditure reaches certain threshold.
    Once they reach 100% of the current month's budget, the shops should be notified again and set to _offline_.
    """
    shops = get_online_shops_with_budgets()
    for shop in shops:
        print(shop)
        shop_id = shop['a_id']
        shop_name = shop['a_name']
        is_online = shop['a_online']
        month_of_budget = shop['a_month']
        monthly_budget = float(shop['a_budget_amount'])
        monthly_expenditure = shop['a_amount_spent']
        percentage = shop['percentage']

        # We want to notify shops when they reach 50% of the current month's budget.
        if percentage > 50:
            notify_shop(threshold=50, shop_id=shop_id, shop_name=shop_name, month_of_budget=month_of_budget, monthly_budget=monthly_budget, monthly_expenditure=monthly_expenditure, percentage=percentage)
            print("--------------------------------------------------------------------------------------------------------------------------------")
        # Once they reach 100% of the current month's budget, the shops should be notified again and set to _offline_.
        if percentage > 100:
            notify_shop(threshold=100, shop_id=shop_id, shop_name=shop_name, month_of_budget=month_of_budget, monthly_budget=monthly_budget, monthly_expenditure=monthly_expenditure, percentage=percentage)
            # Shops that need to go _offline_ according to the rules in the previous section should be marked as such in the database.
            set_offline(shop_id=shop_id)
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    if not shops:
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print("+All notifications are sent. Is Dobby a free elf now?+")
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    run()


def display_main_menu():
    """
    display main menu
    """

    print("================================================== MENU ==========================================================")
    print('  1. (Re)check budgets for all shops')
    print('  2. Exit')


def run():
    """
    main function
    """
    display_main_menu()
    n = int(input("Enter option : "))
    if n == 1:
        print("==================================================================================================================")
        check_budgets_of_all_shops()
    elif n == 2:
        print('----- Thank You. ByBy. -----')
    else:
        run()


if __name__ == '__main__':
    prepare_db()
    run()
    my_cursor.close()
