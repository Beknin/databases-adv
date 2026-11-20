use Front;

-- product.SizeID -> size.ID
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(s.ID) AS Совпадений,
    CAST(COUNT(s.ID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM product p
LEFT JOIN size s ON p.SizeID = s.ID
WHERE p.SizeID IS NOT NULL AND p.SizeID > 0;

-- bm_StorageOperations.ProductID -> product.id
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(p.id) AS Совпадений,
    CAST(COUNT(p.id) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_StorageOperations so
LEFT JOIN product p ON so.ProductID = p.id
WHERE so.ProductID IS NOT NULL AND so.ProductID > 0;

-- bm_StorageOperations.VendorID -> vendors.id
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(v.id) AS Совпадений,
    CAST(COUNT(v.id) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_StorageOperations so
LEFT JOIN vendors v ON so.VendorID = v.id
WHERE so.VendorID IS NOT NULL AND so.VendorID > 0;

-- bm_StorageOperations.ReasonID -> bm_ReasonDebit.ID
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(rd.ID) AS Совпадений,
    CAST(COUNT(rd.ID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_StorageOperations so
LEFT JOIN bm_ReasonDebit rd ON so.ReasonID = rd.ID
WHERE so.ReasonID IS NOT NULL AND so.ReasonID > 0;

-- journal.loginid -> personnel.personid
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(p.personid) AS Совпадений,
    CAST(COUNT(p.personid) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM journal j
LEFT JOIN personnel p ON j.loginid = CAST(p.personid AS varchar(13))
WHERE j.loginid IS NOT NULL AND j.loginid <> '' AND j.loginid <> '0';

-- bm_JournalBarnetDocs.TicketNumber -> journal.receiptn
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(j.receiptn) AS Совпадений,
    CAST(COUNT(j.receiptn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_JournalBarnetDocs bd
LEFT JOIN journal j ON bd.TicketNumber = j.receiptn
WHERE bd.TicketNumber IS NOT NULL AND bd.TicketNumber > 0;

-- bm_JournalBarnetDocs.PersonID -> personnel.personid
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(p.personid) AS Совпадений,
    CAST(COUNT(p.personid) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_JournalBarnetDocs bd
LEFT JOIN personnel p ON bd.PersonID = p.personid
WHERE bd.PersonID IS NOT NULL AND bd.PersonID > 0;

-- bm_BonusHistory.TicketNumber -> journal.receiptn
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(j.receiptn) AS Совпадений,
    CAST(COUNT(j.receiptn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_BonusHistory bh
LEFT JOIN journal j ON bh.TicketNumber = CAST(j.receiptn AS varchar(25))
WHERE bh.TicketNumber IS NOT NULL AND bh.TicketNumber <> '' AND bh.TicketNumber <> '0';

-- bm_PersonnelSecurity.PersonID -> personnel.personid
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(p.personid) AS Совпадений,
    CAST(COUNT(p.personid) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_PersonnelSecurity ps
LEFT JOIN personnel p ON ps.PersonID = p.personid
WHERE ps.PersonID IS NOT NULL AND ps.PersonID > 0;

-- bm_StorageOperations_Table.SourceID -> journal.transnumber
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(j.transnumber) AS Совпадений,
    CAST(COUNT(j.transnumber) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_StorageOperations_Table sot
LEFT JOIN journal j ON sot.SourceID = j.transnumber
WHERE sot.SourceID IS NOT NULL AND sot.SourceID > 0;

-- bm_StorageOperations_Table.ReasonID -> bm_ReasonDebit.ID
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(rd.ID) AS Совпадений,
    CAST(COUNT(rd.ID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_StorageOperations_Table sot
LEFT JOIN bm_ReasonDebit rd ON sot.ReasonID = rd.ID
WHERE sot.ReasonID IS NOT NULL AND sot.ReasonID > 0;

-- bm_JournalSessions.PersonID -> personnel.personid
SELECT 
    COUNT(*) AS Всего_записей,
    COUNT(p.personid) AS Совпадений,
    CAST(COUNT(p.personid) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Процент_совпадений
FROM bm_JournalSessions js
LEFT JOIN personnel p ON js.PersonID = p.personid
WHERE js.PersonID IS NOT NULL AND js.PersonID > 0;