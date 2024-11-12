ALTER USER hr IDENTIFIED BY Oracle123# ACCOUNT UNLOCK;
SELECT username, account_status FROM dba_users WHERE username = 'HR';
EXIT;
