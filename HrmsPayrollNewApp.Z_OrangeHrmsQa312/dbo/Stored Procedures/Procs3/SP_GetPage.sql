CREATE PROCEDURE [dbo].[SP_GetPage]  
  @Items_Per_Page numeric(9)  
 ,@Page_No numeric(9)  
 ,@Select_Fields varchar(MAX)  
 ,@From varchar(MAX)  
 ,@Where varchar(MAX)=null  
 ,@OrderBy varchar(MAX)=null  
AS  
 SET NOCOUNT ON   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON   
   
 BEGIN TRY  
     
  DECLARE @RecordCount INT  
    
  DECLARE @QUERY NVARCHAR(MAX)    
  
  IF IsNull(@Where,'') = ''  
   SET @Where = ' 1 = 1 '  
    
  IF(UPPER(LEFT(@From,1))='T')  
   SET @From = @From  --+ ' WITH (NOLOCK) '  --Comment by Jaina 10-11-2020 Because in some page passout view and inner query for binding. so it's generate error  
  ELSE  
   SET @From = @From  
  
  SET @QUERY = 'SELECT @RecordCount = COUNT(1)  
       FROM ' + @From + '  
       WHERE ' + @Where  
         
  exec sp_executesql @QUERY, N'@RecordCount INT OUTPUT', @RecordCount output  
    
  DECLARE @COLS VARCHAR(MAX)  
    
  SET @QUERY = 'SELECT TOP 0 ' + @Select_Fields + '   
       INTO #COLS  
       FROM ' + @From + '  
       WHERE ' + @Where + '; '  
    
  SET @QUERY = @QUERY + 'SELECT  @COLS = COALESCE(@COLS + '','', '''') + QUOTENAME(NAME)   
          FROM tempdb.sys.columns where object_id=object_id(''tempdb..#COLS'');'  
  
    
         
  exec sp_executesql @QUERY, N'@COLS VARCHAR(MAX) OUTPUT', @COLS output  
    
  print @QUERY  
  
    
  DECLARE @FROM_REC VARCHAR(10)   
  DECLARE @TO_REC VARCHAR(10)  
  IF (@Items_Per_Page > 0 AND @Page_No > 0)  
   BEGIN  
    SET @FROM_REC = ((@Page_No - 1) * @Items_Per_Page) + 1  
    SET @TO_REC = (CAST(@FROM_REC AS INT) + @Items_Per_Page)  - 1   
   END  
  ELSE  
   BEGIN  
    SET @FROM_REC = 0  
    SET @TO_REC = @RecordCount  
   END  
    
  SET @QUERY = 'SELECT ' + @COLS + '  
       FROM  (SELECT ROW_NUMBER() OVER (ORDER BY ' + @OrderBy + ') AS IDX_R_ID, ' + @Select_Fields + '    
         FROM ' + @From + '  
         WHERE ' + @Where + ') T  
       WHERE   IDX_R_ID BETWEEN ' + @FROM_REC + ' AND ' + @TO_REC + ' ORDER BY IDX_R_ID;'  
    
    
  --set @QUERY = @QUERY + 'SELECT ' + @Select_Fields + ' FROM #PAGE WHERE ROW_ID BETWEEN ' + @FROM_REC + ' AND ' + @TO_REC + ' ORDER BY ROW_ID'  
    
  EXEC(@QUERY);  
    
    
  select @RecordCount As Total_Records  
 END TRY  
 BEGIN CATCH  
  EXEC [SP_GetPage_OLD] @Items_Per_Page = @Items_Per_Page, @Page_No = @Page_No, @Select_Fields = @Select_Fields, @From = @From, @Where = @Where, @OrderBy = @OrderBy   
 END CATCH
