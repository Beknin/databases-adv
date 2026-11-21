use front;
go

-- dim_ranges
select ID, sizeid, portionrate from [size]
order by ID;

select 'insert into dim_ranges(external_id, name, factor) values ('
    + cast(ID as varchar) + ','''
    + replace(isnull(sizeid, ''), '''', '''''') + ''','
    + cast(isnull(portionrate, 0) as varchar) + ');'
from [size]
order by ID;


-- products
select id, description, vendorid, CategoryID, SizeID from product
order by id;

select 'insert into products(external_id, name, vendor_id, category_id, size_id) values ('
    + cast(id as varchar) + ','''
    + replace(isnull(description, ''), '''', '''''') + ''','
    + cast(isnull(vendorid, 0) as varchar) + ','
    + cast(isnull(CategoryID, 0) as varchar) + ','
    + cast(isnull(SizeID, 0) as varchar) + ');'
from product
order by id;


-- vendors
select id, firstname, countryid from vendors
order by id;

select 'insert into vendors(external_id, name, country_id) values ('
    + cast(id as varchar) + ','''
    + replace(isnull(firstname, ''), '''', '''''') + ''','
    + cast(isnull(countryid, 0) as varchar) + ');'
from vendors
order by id;


-- personnel
select personid, lastname, firstname, middlename from personnel
order by personid;

select 'insert into personnel(external_id, lastname, firstname, middlename) values ('
    + cast(personid as varchar) + ','''
    + replace(isnull(lastname, ''), '''', '''''') + ''','''
    + replace(isnull(firstname, ''), '''', '''''') + ''','''
    + replace(isnull(middlename, ''), '''', '''''') + ''');'
from personnel
order by personid;


-- journal_types
select ID, JournalName from bm_JournalType
order by ID;

select 'insert into journal_types(external_id, name) values ('
    + cast(ID as varchar) + ','''
    + replace(isnull(JournalName, ''), '''', '''''') + ''');'
from bm_JournalType
order by ID;


-- journal_document_types
select ID, Description, JournalID, IsParent from bm_JournalTypeDocuments
order by ID;

select 'insert into journal_document_types(external_id, description, journal_id, is_parent) values ('
    + cast(ID as varchar) + ','''
    + replace(isnull(Description, ''), '''', '''''') + ''','
    + cast(isnull(JournalID, 0) as varchar) + ','
    + cast(isnull(IsParent, 0) as varchar) + ');'
from bm_JournalTypeDocuments
order by ID;


-- storages
select id, description, ResponsibleID from storages
order by id;

select 'insert into storages(external_id, description, responsible_id) values ('
    + cast(id as varchar) + ','''
    + replace(isnull(description, ''), '''', '''''') + ''','
    + cast(isnull(ResponsibleID, 0) as varchar) + ');'
from storages
order by id;


-- trans_types
select transtypeid, transgroupid, description from transtype
order by transtypeid;

select 'insert into trans_types(external_id, group_id, description) values ('
    + cast(transtypeid as varchar) + ','
    + cast(isnull(transgroupid, 0) as varchar) + ','''
    + replace(isnull(description, ''), '''', '''''') + ''');'
from transtype
order by transtypeid;


-- debit_reasons
select ID, ParentID, Description from bm_ReasonDebit
order by ID;

select 'insert into debit_reasons(external_id, parent_id, description) values ('
    + cast(ID as varchar) + ','
    + case when isnull(ParentID, 0) = 0 then 'null'
           else cast(ParentID as varchar) end + ','''
    + replace(isnull(Description, ''), '''', '''''') + ''');'
from bm_ReasonDebit
order by ID;


-- categories
select id, ParentID, description from category
order by id;

select 'insert into categories(external_id, parent_id, description) values ('
    + cast(id as varchar) + ','
    + case when isnull(ParentID, 0) = 0 then 'null'
           else cast(ParentID as varchar) end + ','''
    + replace(isnull(description, ''), '''', '''''') + ''');'
from category
order by id;


-- payment_types
select paymenttypeid, description from paymenttype
order by paymenttypeid;

select 'insert into payment_types(external_id, description) values ('
    + cast(paymenttypeid as varchar) + ','''
    + replace(isnull(description, ''), '''', '''''') + ''');'
from paymenttype
order by paymenttypeid;