use front;
go

-- dim_ranges
select ID, sizeid, portionrate from [size]

select 'insert into dim_ranges(external_id, name, factor) values ('
    + cast(ID as varchar) + ','''
    + sizeid + ''','
    + cast(portionrate as varchar) + ');'
from [size]


-- personnel_security_access
select securityaccessid, description from securityaccess

select 'insert into personnel_security_access(external_id, description) values ('
    + cast(securityaccessid as varchar) + ','''
    + description + ''');'
from securityaccess


-- journal_types
select ID, JournalName from bm_JournalType

select 'insert into journal_types(external_id, name) values ('
    + cast(ID as varchar) + ','''
    + JournalName + ''');'
from bm_JournalType


-- journal_document_types
select ID, Description, JournalID, IsParent from bm_JournalTypeDocuments

select 'insert into journal_document_types(external_id, description, journal_id, is_parent) values ('
    + cast(ID as varchar) + ','''
    + Description + ''','
    + cast(JournalID as varchar) + ','
    + cast(IsParent as varchar) + ');'
from bm_JournalTypeDocuments


-- trans_types
select transtypeid, transgroupid, PreviewGroupType, description from transtype

select 'insert into trans_types(external_id, group_id, group_type_preview, description) values ('
    + cast(transtypeid as varchar) + ','
    + cast(isnull(transgroupid, 0) as varchar) + ','''
    + PreviewGroupType + ''','''
    + isnull(description, '') + ''');'
from transtype


-- storage_operation_types
select ID, Description, Factor from bm_StorageOperationsType

select 'insert into storage_operation_types(external_id, description, factor) values ('
    + cast(ID as varchar) + ','''
    + Description + ''','
    + cast(Factor as varchar) + ');'
from bm_StorageOperationsType


-- storages
select id, description, ResponsibleID from storages

select 'insert into storages(external_id, description, responsible_id) values ('
    + cast(id as varchar) + ','''
    + description + ''','
    + cast(ResponsibleID as varchar) + ');'
from storages


-- personnel
select personid, lastname, firstname, middlename, password, securityaccess from personnel

select 'insert into personnel(external_id, lastname, firstname, middlename, password, security_access) values ('
    + cast(personid as varchar) + ','''
    + lastname + ''','''
    + firstname + ''','''
    + middlename + ''','''
    + password + ''','
    + cast(securityaccess as varchar) + ');'
from personnel


-- vendors
select id, firstname, birthday, countryid, IsUse from vendors

select 'insert into vendors(external_id, name, birthday, country_id, is_use) values ('
    + cast(id as varchar) + ','''
    + firstname + ''','''
    + convert(varchar, birthday, 121) + ''','
    + cast(countryid as varchar) + ','
    + cast(IsUse as varchar) + ');'
from vendors


-- products
select id, description, vendorid, IsUse, CategoryID, SizeID from product

select 'insert into products(external_id, name, vendor_id, is_use, category_id, size_id) values ('
    + cast(id as varchar) + ','''
    + description + ''','
    + cast(vendorid as varchar) + ','
    + cast(IsUse as varchar) + ','
    + cast(CategoryID as varchar) + ','
    + cast(SizeID as varchar) + ');'
from product


-- document_headers
select ID, JournalID, ShiftID, DocumentNumber, DocumentTypeID, PersonID from bm_JournalBarnetDocs

select 'insert into document_headers(external_id, journal_id, shift_id, document_number, document_type_id, person_id) values ('
    + cast(ID as varchar) + ','
    + cast(JournalID as varchar) + ','
    + cast(ShiftID as varchar) + ','
    + cast(DocumentNumber as varchar) + ','
    + cast(DocumentTypeID as varchar) + ','
    + cast(PersonID as varchar) + ');'
from bm_JournalBarnetDocs


-- journal
select ID, JournalID, DocumentNumber, Amount, TaxedAmount, Comments, PersonID, TicketNumber from bm_JournalBarnetDocs

select 'insert into journal(external_id, trans_type, receipt_number, price, amount, description, employee_id, trans_number) values ('
    + cast(ID as varchar) + ','
    + cast(JournalID as varchar) + ','
    + cast(DocumentNumber as varchar) + ','
    + cast(Amount as varchar) + ','
    + cast(TaxedAmount as varchar) + ','''
    + Comments + ''','
    + cast(PersonID as varchar) + ','
    + cast(isnull(TicketNumber, 0) as varchar) + ');'
from bm_JournalBarnetDocs


-- journal_details
select ID, SourceID, ProductID, BludoID, sBrutto, Count, TicketNumber, SizeID, StorageID from bm_Journal_Details

select 'insert into journal_details(external_id, source_id, product_id, dish_id, weight_brutto, count, ticket_number, size_id, storage_id) values ('
    + cast(ID as varchar) + ','
    + cast(SourceID as varchar) + ','
    + cast(ProductID as varchar) + ','
    + cast(BludoID as varchar) + ','''
    + sBrutto + ''','
    + cast(Count as varchar) + ','
    + cast(TicketNumber as varchar) + ','
    + cast(SizeID as varchar) + ','
    + cast(StorageID as varchar) + ');'
from bm_Journal_Details


-- storage_operations
select ID, DocumentID, OperationID, SourceID, BludoID, ProductID, VendorID, StorageID, RangeID, Price, PriceCost, Count, Amount, Taxed, TaxedAmount from bm_StorageOperations

select 'insert into storage_operations(external_id, document_id, operation_id, source_id, dish_id, product_id, vendor_id, storage_id, size_id, price, price_cost, count, amount, taxed, taxed_amount) values ('
    + cast(ID as varchar) + ','
    + cast(DocumentID as varchar) + ','
    + cast(OperationID as varchar) + ','
    + cast(SourceID as varchar) + ','
    + cast(BludoID as varchar) + ','
    + cast(ProductID as varchar) + ','
    + cast(VendorID as varchar) + ','
    + cast(StorageID as varchar) + ','
    + cast(RangeID as varchar) + ','
    + cast(Price as varchar) + ','
    + cast(PriceCost as varchar) + ','
    + cast(Count as varchar) + ','
    + cast(Amount as varchar) + ','
    + cast(Taxed as varchar) + ','
    + cast(TaxedAmount as varchar) + ');'
from bm_StorageOperations


-- pricelist
select id, DocumentID, basecost, groupid, productid from pricelist

select 'insert into pricelist(external_id, document_id, base_cost, group_id, product_id) values ('
    + cast(id as varchar) + ','
    + cast(DocumentID as varchar) + ','
    + cast(basecost as varchar) + ','
    + cast(groupid as varchar) + ','
    + cast(productid as varchar) + ');'
from pricelist