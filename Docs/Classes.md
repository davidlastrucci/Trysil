<p align="center">
  <img width="300" height="115" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil.png" title="Trysil - Operation ORM">
</p>

# Trysil classes
> **Trysil**<br>
> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

## / Trysil
### Trysil.Attributes
- TNamedAttribute: TCustomAttribute
- TTableAttribute: TNamedAttribute
- TSequenceAttribute: TNamedAttribute
- TPrimaryKeyAttribute: TCustomAttribute
- TColumnAttribute: TNamedAttribute
- TDetailColumnAttribute: TCustomAttribute
- TVersionColumnAttribute: TCustomAttribute
- TRelationAttribute: TCustomAttribute
### Trysil.Cache
- TTCache<K,V>
- TTCacheEx<K,V>: TTCache<K,V>
### Trysil.Classes
- TTListEnumerator<T>
### Trysil.Context.Abstract
- TTAbstractContext
### Trysil.Context
- TTContext: TTAbstractContext
### Trysil.Exceptions
- ETInvalidOperationException: EInvalidOpException
- ETException: Exception
- ETDataTypeException: ETException
### Trysil.Filter
- TTFilterTop
- TTFilter
### Trysil.Generics.Collections
- TTPredicate<T>
- ITEnumerator<T>
- ITEnumerable<T>
- TTEnumerator<T>: ITEnumerator<T>
- TTEnumerable<T>: ITEnumerable<T>
- TTList<T>: TList<T>
- TTObjectList<T>: TObjectList<T>
### Trysil.IdentityMap
- TTEntityIdentityMap: TTCache<TTPrimaryKey, TObject>
- TTIdentityMap: TTCacheEx<PTypeInfo, TTEntityIdentityMap>
### Trysil.Lazy
- TTAbstractLazy<T>
- TTLazy<T>: TTAbstractLazy<T>
- TTLazyList<T>: TTAbstractLazy<T>
### Trysil.Mapping
- TTColumnMap
- TTColumnsMap
- TTDetailColumnMap
- TTDetailColumnsMap
- TTRelationMap
- TTRelationsMap
- TTTableMap
- TTMapper
### Trysil.Metadata
- TTColumnMetadata
- TTColumnsMetadata
- TTTableMetadata
- TTMetadataProvider
- TTMetadata
### Trysil.Provider
- TTProvider
### Trysil.Resolver
- TTResolver
### Trysil.Rtti
- TTValue
- TTValueHelper
- TTRttiMember
- TTRttiField: TTRttiMember
- TTRttiProperty: TTRttiMember
### Trysil.Session
- TTSessionState
- TTSession<T>
### Trysil.Sync
- TTCriticalSection
### Trysil.Types
- TTPrimaryKey
- TTVersion
- TTNullable<T>
## / Trysil / Data
### Trysil.Data.Columns
- TTDataColumn
- TTDataStringColumn: TTDataColumn
- TTDataIntegerColumn: TTDataColumn
- TTDataLargeIntegerColumn: TTDataColumn
- TTDataDoubleColumn: TTDataColumn
- TTDataBooleanColumn: TTDataColumn
- TTDataDateTimeColumn: TTDataColumn
- TTDataGuidColumn: TTDataColumn
- TTDataBlobColumn: TTDataColumn
- TTDataColumnFactory
- TTDataColumnRegister
### Trysil.Data
- TTDataReader
- TTDataAbstractCommand
- TTDataInsertCommand: TTDataAbstractCommand
- TTDataUpdateCommand: TTDataAbstractCommand
- TTDataDeleteCommand: TTDataAbstractCommand
- TTDataConnection: TTMetadataProvider
## / Trysil / Data / FireDAC
### Trysil.Data.FireDAC.Common
### Trysil.Data.FireDAC.Parameters
- TTDataParameter
- TTDataStringParameter: TTDataParameter
- TTDataIntegerParameter: TTDataParameter
- TTDataLargeIntegerParameter: TTDataParameter
- TTDataDoubleParameter: TTDataParameter
- TTDataBooleanParameter: TTDataParameter
- TTDataDateTimeParameter: TTDataParameter
- TTDataGuidParameter: TTDataParameter
- TTDataBlobParameter: TTDataParameter
- TTDataParameterFactory
- TTDataParameterRegister
### Trysil.Data.FireDAC
- TTDataFireDACConnectionPool
### Trysil.Data.FireDAC.SqlServer
- TTDataSqlServerConnection: TTDataConnection
- TTDataSqlServerDataReader: TTDataReader
- TTDataSqlServerDataInsertCommand: TTDataInsertCommand
- TTDataSqlServerDataUpdateCommand: TTDataUpdateCommand
- TTDataSqlServerDataDeleteCommand: TTDataDeleteCommand
### Trysil.Data.FireDAC.SqlServer.SqlSyntax
- TTDataSqlServerSequenceSyntax
- TTDataSqlServerSelectCountSyntax
- TTDataSqlServerAbstractSyntax
- TTDataSqlServerSelectSyntax: TTDataSqlServerAbstractSyntax
- TTDataSqlServerMetadataSyntax: TTDataSqlServerSelectSyntax
- TTDataSqlServerCommandSyntax: TTDataSqlServerAbstractSyntax
- TTDataSqlServerInsertSyntax: TTDataSqlServerCommandSyntax
- TTDataSqlServerUpdateSyntax: TTDataSqlServerCommandSyntax
- TTDataSqlServerDeleteSyntax: TTDataSqlServerCommandSyntax
## / Trysil.UI
### Trysil.Vcl.ListView
- TTListViewHelper
- TTListItem<T>: TListItem
- TTListViewColumn
- TTListViewColumns
- TTRttiListViewProperties
- TTRttiListView<T>
- TTListViewOnItemChanged<T>
- TTListViewOnCompare<T>
- TTListView<T>: TCustomListView

---
<p>
  <a href="https://www.lastrucci.net/">
    <img width="400" height="100" src="https://www.lastrucci.net/images/badge.small.png" title="https://www.lastrucci.net/">
  </a>
</p>
