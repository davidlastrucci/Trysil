# Trysil API REST

|HTTP Method|URI|Trysil|Database|LazyEntity|LazyList|
|-|-|-|-|-|-|
|GET|/?|Get&lt;T&gt;|SELECT|Yes|Yes|
|GET|/|SelectAll&lt;T&gt;|SELECT|Yes|No|
|POST|/|Insert&lt;T&gt;|INSERT|||
|PUT|/|Update&lt;T&gt;|UPDATE|||
|DELETE|/?/?|Delete&lt;T&gt;|DELETE|||
|POST|/select|Select&lt;T&gt;|SELECT|Yes|No|
|GET|/find/?|Get&lt;T&gt;|SELECT|No|No|
|GET|/createnew|CreateEntity&lt;T&gt;|none|||
