<p align="center">
  <img width="300" height="292" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil.png" title="Trysil - Operation ORM">
</p>

# Trysil
> **Trysil**<br>
> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

### Getting started

In this example we will see how to:

- [Design database](https://github.com/davidlastrucci/Trysil/blob/master/Docs/DesignDatabase.md)
- [Define entity](https://github.com/davidlastrucci/Trysil/blob/master/Docs/DefineEntity.md)
- [Use Trysil](https://github.com/davidlastrucci/Trysil/blob/master/Docs/UseTrysil.md)

Don't write code like this:

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

Write this:

<pre>
LInvoice := Session.Get<TInvoice>(1);  
ShowMessage(
  Format('Invoice No: %d, Customer: %s, Country: %s',  [
    Invoice.InvoiceNo,
    Invoice.Customer.Name,
    Invoice.Customer.Country.Name]));
</pre>

**Enjoy!**

---
<p>
  <a href="https://www.lastrucci.net/">
    <img width="400" height="100" src="https://www.lastrucci.net/images/badge.small.png" title="https://www.lastrucci.net/">
  </a>
</p>
