<p align="center">
  <img width="300" height="115" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil.png" title="Trysil - Operation ORM">
</p>

# Trysil Attributes
> **Trysil**<br>
> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

## Class attributes
### TTable
##### Parameters
- **Name**: Table name on database

------------

### TSequence
#### Parameters
- **Name**: Sequence name on database

------------

### TRelation
#### Parameters
- **TableName**: Related table name on database
- **ColumnName**: Related column name name on database
- **IsCascade**: define if relation is cascade

------------

### TInsertEventAttribute
#### Parameters
- **EventClass**: Event Class

------------

### TUpdateEventAttribute
#### Parameters
- **EventClass**: Event Class

------------

### TDeleteEventAttribute
#### Parameters
- **EventClass**: Event Class

------------

## Field attributes
### TPrimaryKey
#### Parameters
- *None*

------------

### TColumn
#### Parameters
- **Name**: Column name on database

------------

### TDetailColumn
#### Parameters
- **ColumnName**: Master column name on database
- **DetailColumnName**: Detail column name on database

------------

### TVersionColumn
#### Parameters
- *None*

---
<p>
  <a href="https://www.lastrucci.net/">
    <img width="400" height="100" src="https://www.lastrucci.net/images/badge.small.png" title="https://www.lastrucci.net/">
  </a>
</p>
