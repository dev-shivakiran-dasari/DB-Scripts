select ROW_NUMBER() OVER (ORDER BY (SELECT Tweet_Date)) AS number, '1874342718236668285' as Tweet_ConversationID,Tweet_Text,Tweet_ID,Tweet_RepliedToTweetID,0 as TwitterID,'' as Tweet_Url,Tweet_Date
into #TweetsData
from LinkTweet T with (nolock) 
INNER JOIN LinkTweet_Detail TD with (nolock) ON TD.LTID=T.LTID
INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID 
INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
WHERE e.EventID=10 AND t.Tweet_Date >= '2025-01-01 00:00:00' AND t.Tweet_Date <= '2025-03-02 00:00:00'
AND Tweet_ConversationID = '1874342718236668285'
order by number asc
 
--select * from #TweetsData
 
select Tweet_ID as cat_id,Tweet_text as cat_name,Tweet_RepliedToTweetID as parent_id into #TweetsDataFinal  from #TweetsData
 
--select * from #TweetsDataFinal
 
;WITH cat_tree AS (
  SELECT cat_id, cat_name, parent_id,
         1 AS level, CAST('1' AS varchar(90)) AS path
    FROM #TweetsDataFinal
   WHERE parent_id IS NULL
  UNION ALL
  SELECT c.cat_id, c.cat_name, c.parent_id,
      ct.level + 1,
      CAST(ct.path+'.'+CAST(
       (row_number() OVER (ORDER BY ct.cat_id)) AS varchar) AS varchar(90))
    FROM #TweetsDataFinal c
    JOIN cat_tree ct ON c.parent_id = ct.cat_id)
 
--SELECT * FROM cat_tree
--ORDER BY path asc
--option (maxrecursion 0);

SELECT cat_id, cat_name, parent_id, path as Hierarchy_Order into #path FROM cat_tree
ORDER BY path asc

;WITH Hierarchy_CTE AS (
    SELECT cat_id, cat_name, parent_id,
        Hierarchy_Order,
        CAST('<r><n>' + REPLACE(Hierarchy_Order, '.', '</n><n>') + '</n></r>' AS XML) AS xml_data
    FROM #path
)
SELECT 
cat_id, cat_name, parent_id,
    Hierarchy_Order
FROM Hierarchy_CTE
ORDER BY 
    (
        SELECT STRING_AGG(FORMAT(CAST(x.value('.', 'int') AS INT), 'D10'), '.')
        FROM xml_data.nodes('/r/n') AS T(x)
    );

 
 
drop table #TweetsData,#TweetsDataFinal,#path