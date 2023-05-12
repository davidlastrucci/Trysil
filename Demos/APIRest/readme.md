# Trysil API REST

## Company controller

<pre>
FServer.RegisterController&lt;TAPIReadWriteController&lt;TAPICompany&gt;&gt;('/company');
</pre>

## Methods

|HTTP Method|URI|Trysil|Database|LazyEntity|LazyList|
|-|-|-|-|-|-|
|GET|/company/?|Get&lt;TAPICompany&gt;|SELECT|Yes|Yes|
|GET|/company|SelectAll&lt;TAPICompany&gt;|SELECT|Yes|No|
|POST|/company|Insert&lt;TAPICompany&gt;|INSERT|||
|PUT|/company|Update&lt;TAPICompany&gt;|UPDATE|||
|DELETE|/company/?/?|Delete&lt;TAPICompany&gt;|DELETE|||
|POST|/company/select|Select&lt;TAPICompany&gt;|SELECT|Yes|No|
|GET|/company/find/?|Get&lt;TAPICompany&gt;|SELECT|No|No|
|GET|/company/createnew|CreateEntity&lt;TAPICompany&gt;||||
