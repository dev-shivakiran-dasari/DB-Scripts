--select * from 
--drop table [Sheet1$]

select Domain as publication,dbo.GetFormat(ISNULL(totalvisits,0)) as publication_traffic,totalvisits as traffic_sort,
CASE 
    WHEN 
        CASE 
            WHEN L.TotalVisits LIKE '%M' THEN TRY_CAST(LEFT(L.TotalVisits, LEN(L.TotalVisits) - 1) AS FLOAT) * 1000000
            WHEN L.TotalVisits LIKE '%K' THEN TRY_CAST(LEFT(L.TotalVisits, LEN(L.TotalVisits) - 1) AS FLOAT) * 1000
            ELSE TRY_CAST(L.TotalVisits AS FLOAT)
        END < 500 
    THEN 'Yes' 
    ELSE 'No' 
END as Classifier_Reach_LessThan500	,

-- Classifier 4: Reach > 10000
CASE 
    WHEN 
        CASE 
            WHEN L.TotalVisits LIKE '%M' THEN TRY_CAST(LEFT(L.TotalVisits, LEN(L.TotalVisits) - 1) AS FLOAT) * 1000000
            WHEN L.TotalVisits LIKE '%K' THEN TRY_CAST(LEFT(L.TotalVisits, LEN(L.TotalVisits) - 1) AS FLOAT) * 1000
            ELSE TRY_CAST(L.TotalVisits AS FLOAT)
        END > 10000 
    THEN 'Yes' 
    ELSE 'No' 
END as Classifier_Reach_MoreThan10000
from [Sheet1$] l