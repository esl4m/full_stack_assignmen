Hello. Thank you for this interesting riddle.
Here is my solution.
# TL;DR
I took the liberty of putting everything in docker, so you dont have to handle SQL server setup.
Just copy, paste and run:
```
cd /tmp;
git clone git@github.com:wansiedler/full_stack_assignmen.git;
cd ./full_stack_assignmen/docker;
docker-compose up --build --detach 
sleep 10 # wait till mysql becomes sane 
docker-compose run python_project
```

Cleanup:
```
cd /tmp/full_stack_assignmen/docker
docker-compose down --volumes
docker-compose rm
cd /tmp
rm /tmp/full_stack_assignmen
```
============================================

OR If You dont have git, docker or docker-compose:
 
```
cd /tmp;
git clone git@github.com:wansiedler/full_stack_assignmen.git;
cd ./full_stack_assignmen/python_project;
pip install mysql-connector-python
./main.py
```
# DB choice
I chose MySQL as a simple SQL server. 
Migrations are in the `migrations.sql` file.
I also added indexing and made some indexes INT unsigned (as it should be always unsigned).


# Additional thoughts
I assume this script is going to be executed on a daily basis by cron or celery and it going to assess budgets for the current month only.
That is why we are not selecting offline shops, shops with 0 budget and quotas from the past months. (see `SELECT.sql`)

### Does your solution avoid sending duplicate notifications?
In order to prevent notification duplications I created a third table `sent_notifications`.
It is going to be cleared every 31 day.

### How does your solution handle a budget change after a notification has already been sent?
The procedure of budget update should be tied to to the initialisation and update of the sent_notifications table. (see `migrations.sql`)
and `SELECT.sql` algorithm:
etc.
```(floor(round((budgets.a_amount_spent / budgets.a_budget_amount) * 100) / 50) - sent_notifications.threshold) > 0;```
 