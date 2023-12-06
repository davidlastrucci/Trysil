<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Dark.png">
    <img img width="300" height="107" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Light.png" alt="Trysil - Delphi ORM" title="Trysil - Delphi ORM">
  </picture>
</p>

> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

### Run Simple Demo

Trysil it's an ORM for Delphi (for **Microsoft SQL Server**, **Firebird**, **PostgreSQL** and **SQLite**).

For run demo project in **Demos/Simple** folder, you have to do:

- Create a SQL Server database and execute the script [Demo.sql](https://github.com/davidlastrucci/Trysil/blob/master/Demos/Simple/Sql/Demo.sql) in **Demos/Simple/Sql** folder
- Edit the [Demo.config.json](https://github.com/davidlastrucci/Trysil/blob/master/Demos/Simple/Demo.config.json) file in **Demos\\Simple** folder for change connection to SQL Server database
- Copy the [Demo.config.json](https://github.com/davidlastrucci/Trysil/blob/master/Demos/Simple/Demo.config.json) in **\$(Platform)\\\$(Config)** folder (the executable folder)

**Demo.config.json (OS authentication)**
<pre>
{
  "connections": [
    {
      "name": "Test",
      "server": "YourServer",
      "databasename": "YourDatabaseName"
    }
  ]
}
</pre>

**Demo.config.json (Database authentication)**
<pre>
{
  "connections": [
    {
      "name": "Test",
      "server": "YourServer",
      "username": "YourUsername",
      "password": "YourPassword",
      "databasename": "YourDatabaseName"
    }
  ]
}
</pre>

Alternatively you can use the sample project located in the **Demos/Simple.SQLite** folder.

---

Make With ❤ @davidlastrucci<br>
[https://www.lastrucci.net/](https://www.lastrucci.net)
