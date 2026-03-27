select  * from ArticleOnlineLog with (NOLOCK) where Comment ='Removed Due To Domain Extension'


--ALTER TABLE ArticleOnlineLog_Shiv add  CommentID tinyint


--update ArticleOnlineLog_Shiv set CommentID=1 where Comment ='Inserted In DB'
--update ArticleOnlineLog_Shiv set CommentID=2 where Comment ='Solr Found Relevant'
--update ArticleOnlineLog_Shiv set CommentID=3 where Comment ='Removed Due To Publication Exclusion List'
--update ArticleOnlineLog_Shiv set CommentID=4 where Comment ='Removed Due To Publication Non News'
--update ArticleOnlineLog_Shiv set CommentID=5 where Comment ='Removed Due To Exists In DB'
--update ArticleOnlineLog_Shiv set CommentID=6 where Comment ='Solr Found Not Relevant'
--update ArticleOnlineLog_Shiv set CommentID=7 where Comment ='Solr Found Not Relevant (exception)'
--update ArticleOnlineLog_Shiv set CommentID=8 where Comment ='Diffbot Processed'
--update ArticleOnlineLog_Shiv set CommentID=9 where Comment ='Diffbot Failed'
--update ArticleOnlineLog_Shiv set CommentID=10 where Comment ='Diffbot Data Already Present In DB'

--update ArticleOnlineLog set CommentID=a.CommentID from mstComment a with (nolock)
--inner join ArticleOnlineLog b with (nolock) on a.Comment=b.Comment



1.Inserted In DB
2.Solr Found Relevant
3.Removed Due To Publication Exclusion List
4.Removed Due To Publication Non News
5.Removed Due To Exists In DB
6.Solr Found Not Relevant
7.Solr Found Not Relevant (exception)
8.Diffbot Processed
9.Diffbot Failed
10.Diffbot Data Already Present In DB