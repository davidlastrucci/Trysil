# Trysil API REST

|HTTP Method|URI|Trysil|Database|LazyEntity|LazyList|
|-|-|-|-|-|-|
|GET|/T/?|Get&lt;T&gt;|SELECT|Yes|Yes|
|GET|/T|SelectAll&lt;T&gt;|SELECT|Yes|No|
|POST|/T|Insert&lt;T&gt;|INSERT|||
|PUT|/T|Update&lt;T&gt;|UPDATE|||
|DELETE|/T/?/?|Delete&lt;T&gt;|DELETE|||
|POST|/T/select|Select&lt;T&gt;|SELECT|Yes|No|
|GET|/T/find/?|Get&lt;T&gt;|SELECT|No|No|
|GET|/T/createnew|CreateEntity&lt;T&gt;|none|||
