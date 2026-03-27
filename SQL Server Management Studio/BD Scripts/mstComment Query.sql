--CREATE TABLE mstComment(
--    CommentID INT PRIMARY KEY IDENTITY(1,1),
--    Comment VARCHAR(200) NOT NULL,
--    CreatedAt DATETIME DEFAULT GETDATE(),
--ModifiedAt DateTime 
--);


select * from ArticleOnlineLog

select * from mstComment

--alter table ArticleOnlineLog alter column Comment Varchar(200)

--alter table ArticleOnlineLog add CommentID INT default 0



--INSERT INTO mstComment (Comment) 
--VALUES 
--('Inserted In DB'),
--('Solr Found Relevant'),
--('Removed Due To Publication Exclusion List'),
--('Removed Due To Publication Non News'),
--('Removed Due To Exists In DB'),
--('Solr Found Not Relevant'),
--('Solr Found Relevant'),
--('Solr Found Not Relevant (exception)'),
--('Diffbot Processed'),
--('Diffbot Failed'),
--('Diffbot Data Already Present In DB');