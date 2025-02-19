

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_GENERATE_FROM_DAT_FILE_G_And_D]  
 @Path as varchar(max) = 'D:\Orangeattn' --Assign the folder path where all the .dat files are located  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
BEGIN  
 --This is to configure the xp_cmdshell command.  
 IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'xp_cmdshell' AND value=1) BEGIN  
  
  --configuring xp command  
  EXEC sp_configure 'show advanced option', 1  
  RECONFIGURE  
  
  
  EXEC sp_configure 'xp_cmdshell', 1  
  RECONFIGURE  
 END  
   
 --Creating table for ERROR LOG  
 IF (OBJECT_ID('tempdb..##Err') IS NULL)  
  Create Table ##Err(NAME_ONLY Varchar(256), Error Varchar(1000), ErrType tinyint);  
 ELSE  
  TRUNCATE TABLE ##Err  
        
 DECLARE @FILE_PATH Varchar(1000),  
   @Cmd Varchar(1000);  
    
  
 --Retrieving information from the given path above  
 --how many .dat files are exist in given folder path  
 IF (OBJECT_ID('tempdb..#TMP_DIR') IS NULL)  
  CREATE TABLE #TMP_DIR(FILE_FOLDER Varchar(250), depth int, IsFile bit)  
 ELSE  
  TRUNCATE TABLE #TMP_DIR;  
  
  
 --To execute the sp command  
 DECLARE @SQL VARCHAR(max);  
  
 TRUNCATE TABLE #TMP_DIR  
  
 SET @SQL = 'xp_dirtree '''  + @Path + ''', 1, 1';  
 INSERT INTO #TMP_DIR   
 EXEC(@SQL);  
  
 --Reading each file exist in the directory  
 DECLARE @FILE_NAME Varchar(max),  
   @NAME_ONLY Varchar(256);  
  
 --creating temp table to read .dat file    
 IF (OBJECT_ID('tempdb..#TMP_DAT') IS NULL)  
  CREATE TABLE #TMP_DAT(VALUE VARCHAR(max));   
    
 --To hold the record from .Dat file  
 DECLARE @Record CHAR(16),  
   @Date varchar(16),  
   @Enroll_No Char(8),  
   @Cmp_ID Numeric(18,0),  
   @Emp_ID Numeric(18,0);  
  
    
 DECLARE curFile CURSOR FOR  
 SELECT FILE_PATH, NAME_ONLY  
 FROM (SELECT (@Path + '\' + FILE_FOLDER) As FILE_PATH, FILE_FOLDER As NAME_ONLY
   FROM #TMP_DIR   
   WHERE IsFile=1 ANd FILE_FOLDER LIKE '%.Dat' AND FILE_FOLDER NOT LIKE '%_Success.Dat') T  
 ORDER BY NAME_ONLY ASC   
 --SELECT FILE_PATH, NAME_ONLY  
 --FROM (SELECT (@Path + '\' + FILE_FOLDER) As FILE_PATH, FILE_FOLDER As NAME_ONLY,   
 --    Cast(('20' + SUBSTRING(FILE_FOLDER, 5, 2) + '-' + SUBSTRING(FILE_FOLDER, 3, 2) + '-' + SUBSTRING(FILE_FOLDER, 1, 2)) AS DateTime) AS FILE_DATE  
 --  FROM #TMP_DIR   
 --  WHERE IsFile=1 ANd FILE_FOLDER LIKE '%.Dat' AND FILE_FOLDER NOT LIKE '%_Success.Dat') T  
 --ORDER BY FILE_DATE ASC   
   
  
 OPEN curFile  
 FETCH NEXT FROM curFile INTO @FILE_NAME, @NAME_ONLY  
 WHILE (@@FETCH_STATUS = 0) BEGIN    
  TRUNCATE TABLE #TMP_DAT;  
  
  SET @SQL = 'BULK INSERT #TMP_DAT FROM ''' + @FILE_NAME + ''' WITH ( ROWTERMINATOR =''\n'')';  
  print @SQL   
  EXEC(@SQL);  
    
  DECLARE curData CURSOR FOR   
  SELECT * FROM #TMP_DAT   
    
  OPEN curData  
  FETCH NEXT FROM curData INTO @Record  
  WHILE (@@FETCH_STATUS = 0) BEGIN     
   BEGIN TRY  
    IF (LEN(@Record) = 16) BEGIN  
       
     --Generating Date from @Record First 8 digit of record (ddMMHHmm)  
     SET @Date = Cast(YEAR(getDate()) As Varchar) + '-' + SUBSTRING(@Record, 3,2) + '-' + SUBSTRING(@Record, 1,2) + ' ' + SUBSTRING(@Record, 5,2) + ':' + SUBSTRING(@Record, 7,2)  
       
     --Getting Enroll_No from @Record //Last 6 digit of Record  
     SET @Enroll_No = RIGHT(@Record, 8);  
                      
     SET @Emp_ID = NULL;  
     SELECT @Cmp_ID=Cmp_ID,@Emp_ID=Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Enroll_No=@Enroll_No  
       
     IF (ISNULL(@Emp_ID,0) <> 0) BEGIN  
      EXEC P9999_DEVICE_INOUT_DETAIL_INSERT @Enroll_No, @Date, '0'  
        
      EXEC SP_EMP_INOUT_SYNCHRONIZATION @Emp_ID, @Cmp_ID, @Date,'0';   
     END ELSE  
      INSERT INTO ##Err Values(@NAME_ONLY, @Record, 2)       
      
    END ELSE IF (LEN(@Record) > 0) BEGIN  
     INSERT INTO ##Err Values(@NAME_ONLY, @Record, 4)  
    END  
   END TRY  
   BEGIN CATCH  
    INSERT INTO ##Err Values(@NAME_ONLY, @Record, 4)     
   END CATCH  
     
   FETCH NEXT FROM curData INTO @Record  
  END  
  CLOSE curData;  
  DEALLOCATE curData;  
    
  --xp_cmdshell 'ren E:\Nimesh\task\071014.Dat 071014_Renamed.Dat'  
  SET @SQL = 'xp_cmdshell ''ren ' + @FILE_NAME + ' ' + REPLACE(@NAME_ONLY, '.Dat', '_Success.Dat') + '''';  
  EXEC(@SQL)  
    
  --Generating Error Log if thrown any during the import process  
  If EXISTS(SELECT 1 FROM ##Err) BEGIN    
   --Generating Headers  
   If EXISTS(SELECT 1 FROM ##Err WHERE ErrType=2)  
    INSERT INTO ##Err Values(@NAME_ONLY, '*********** Enroll No not matched in Payroll ***********', 1)     
      
   If EXISTS(SELECT 1 FROM ##Err WHERE ErrType=4)  
    INSERT INTO ##Err Values(@NAME_ONLY, '*********** Records not in a proper format ***********', 3)     
  
        
   SET @FILE_PATH = @Path + '\' + REPLACE(@NAME_ONLY, '.Dat', '_Error.txt');  
   SET @SQL = 'Select Error FROM ##Err WHERE NAME_ONLY=''' + @NAME_ONLY + ''' Order By ErrType';  
   SET @Cmd = 'bcp "' + @SQL + '" queryout "' + @FILE_PATH + '" -T -c'  
   EXEC master..XP_CMDSHELL @cmd  
     
   TRUNCATE TABLE ##Err;  
  END   
    
  FETCH NEXT FROM curFile INTO @FILE_NAME, @NAME_ONLY  
 END  
 CLOSE curFile;  
 DEALLOCATE curFile;  
END
