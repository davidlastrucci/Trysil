<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Dark.png">
    <img img width="300" height="107" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Light.png" alt="Trysil - Delphi ORM" title="Trysil - Delphi ORM">
  </picture>
</p>

> **Trysil**<br>
> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

### Don't write code like this

<pre>
Query.Sql.Text :=
  'SELECT ' +
  'I.ID AS InvoiceID, I.Number, ' +
  'C.ID AS CustomerID, C.Name AS CustomerName, ' +
  'N.ID AS CountryID, N.Name AS CountryName ' +
  'FROM Invoices AS I ' +
  'INNER JOIN Customers AS C ON C.ID = I.CustomerID ' +
  'INNER JOIN Countries AS N ON N.ID = C.CountryID ' +
  'WHERE I.ID = :InvoiceID'
Query.ParamByName('InvoiceID').AsInteger := 1;  
Query.Open;  

ShowMessage(
  Format('Invoice No: %d, Customer: %s, Country: %s', [
  Query.FieldByName('Number').AsInteger,  
  Query.FieldByName('CustomerName').AsString,  
  Query.FieldByName('CountryName').AsString]));
</pre>

---

Make With ❤ @davidlastrucci<br>
[https://www.lastrucci.net/](https://www.lastrucci.net)
