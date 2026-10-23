# Remote MySQL

The backend now activates `dev,remote-db` by default. `remote-db` overrides only the MySQL connection while keeping the existing development settings available. The host, port, database, and application account default to the verified remote database; set the password in the process environment before starting the backend:

```powershell
$env:MYSQL_USERNAME = "youlai_app"
$env:MYSQL_PASSWORD = "<database-password>"
mvn spring-boot:run
```

For a packaged JAR, set the same environment variables and run:

```powershell
java -jar target/youlai-boot-tenant.jar
```

The application profile does not contain credentials. Use a dedicated application account with access only to `youlai_admin_tenant`; reserve the database administrator account for schema setup.

## Schema setup

Check the target database before importing any SQL. `sql/youlai_admin_tenant.sql` is a full bootstrap script and contains `DROP TABLE` statements for the application's tables. Run it only against a confirmed empty/new database. Do not use it to refresh an existing installation.

After the base schema exists, `sql/extensions/marketing.sql` creates the four marketing tables and adds menu and role grants. It uses `CREATE TABLE IF NOT EXISTS` and `INSERT IGNORE`; inspect existing menu IDs and grants before applying it to an installation that has been customized.

The workstation now reaches `101.34.52.78:3306`; the MySQL greeting reports server version `5.7.44-log`, and the user reports that client login succeeds. SSH is reachable, but no key is authorized for the attempted account. Keep port 3306 and the database account restricted to trusted source IPs.

To import from the workstation with the MySQL CLI, run it from this repository directory, enter the password at the prompt, then execute the two `source` commands in order:

```powershell
Set-Location D:\练习\codex\有来前后端\youlai-boot-tenant
mysql --host=101.34.52.78 --port=3306 --user=youlai_app --password
```

At the `mysql>` prompt:

```sql
source sql/youlai_admin_tenant.sql
source sql/extensions/marketing.sql
```

The user confirmed that `youlai_admin_tenant` is a new, empty database, so the base bootstrap is authorized for this target. After both scripts complete, start the backend with both `dev,remote-db` profiles and verify its health endpoint and anonymous marketing-space API before connecting the admin UI.
