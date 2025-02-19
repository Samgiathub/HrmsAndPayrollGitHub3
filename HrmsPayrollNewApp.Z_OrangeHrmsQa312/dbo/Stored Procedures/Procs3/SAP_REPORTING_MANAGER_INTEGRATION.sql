


---Exec SAP_REPORTING_MANAGER_INTEGRATION 149,'SERVER\SQL08R2','ORANGE_HRMS'
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[SAP_REPORTING_MANAGER_INTEGRATION]

@Cmp_ID As numeric,
@Server_Name as Varchar(100),
@Database_Name as Varchar(100),
@Log_Status Varchar(max)  = 0 OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Server_Name ='' OR @Database_Name =''
BEGIN
	Return
ENd

Declare @FileName as varchar(50)
declare @SQL as varchar(max)
set @FileName = 'E:\3_REPORTING_MANAGER.csv'

BEGIN  
 --This is to configure the xp_cmdshell command.  
 IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'xp_cmdshell' AND value=1) BEGIN  
  
  --configuring xp command  
  EXEC sp_configure 'show advanced option', 1  
  RECONFIGURE  
  
  EXEC sp_configure 'xp_cmdshell', 1  
  RECONFIGURE  
END  
END  


DECLARE @HasResult Varchar(max) 
Declare @Row_No				NUMERIC(18,0)

Declare @TbScript as Varchar(3000)

SET @TbScript =
'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[SAP_REPORTING_MANAGER]'') AND type in (N''U''))
Begin
Create Table '+@Database_Name+'.DBO.SAP_REPORTING_MANAGER
(
[Alpha Emp Code]  Varchar(100)
,Current_Sup_Code  Varchar(100)
,New_Manager Varchar(100)
,Company_Name_of_New_manager  Varchar(100)
,Effective_Date Datetime
)
END'
		
exec (@TbScript)
SET @SQL = 'xp_cmdshell '' bcp '+@Database_Name+'.dbo.SAP_REPORTING_MANAGER IN '+ @FileName + ' -T -c -t, -S '+@Server_Name+' -T''';   

--select @SQL
DELETE from SAP_REPORTING_MANAGER
EXEC(@SQL) 

Declare @Str_Xml  xml
set @Str_Xml =(select  * from dbo.SAP_REPORTING_MANAGER 
--where [Alpha Emp Code] Not Like '%Alpha%'
FOR XML AUTO, ELEMENTS xsinil, ROOT('NewDataSet'))
Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'dbo.SAP_REPORTING_MANAGER','Sheet1OLE')

SELECT 
isnull(Sheet1OLE.value('(Alpha_x0020_Emp_x0020_Code/text())[1]','Varchar(100)'),'') as Alpha_Emp_Code,
isnull(Sheet1OLE.value('(Current_Sup_Code/text())[1]','Varchar(100)'),'') as Current_Sup_Code,
ISNULL(Sheet1OLE.value('(New_Manager/text())[1]','Varchar(100)'),'') as New_Manager,
ISNULL(Sheet1OLE.value('(Company_Name_of_New_manager/text())[1]','Varchar(100)'),'') as Company_Name_of_New_manager,
ISNULL(Sheet1OLE.value('(Effective_Date/text())[1]','Varchar(100)'),'') as Effective_Date
INTO #Temptable from @Str_Xml.nodes('/NewDataSet/Sheet1OLE') as Temp(Sheet1OLE)

---Select * from #Temptable
---- XXXXX---

Declare @Alpha_Emp_Code	 as varchar(100)
Declare @Current_Sup_Code	  as varchar(100)
Declare @New_Manager	  as varchar(100)
Declare @Company_Name_of_New_manager	  as varchar(100)
Declare @Effective_Date  as datetime



SET @Row_No =1

declare curXml cursor for 
		select Alpha_Emp_Code,Current_Sup_Code,New_Manager,Company_Name_of_New_manager,Effective_Date  from #Temptable
	    
	    open curXml                        
		fetch next from curXml into @Alpha_Emp_Code	,@Current_Sup_Code,@New_Manager,@Company_Name_of_New_manager,@Effective_Date 
		while @@fetch_status >= 0 
		Begin                     
		
	    BEGIN TRY
		
			SELECT @ALPHA_EMP_CODE
				      	
		END TRY
		
		BEGIN CATCH 
			DECLARE @w_error VARCHAR(200) 
			SET @w_error= NULL

			SET @w_error = error_message()
			IF @w_error is not NULL 
				BEGIN
					SET @HasResult = cast(@Alpha_Emp_Code as varchar(100)) + ','				
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@w_error,0,'Error in Auto Import Data',GETDATE(),'REPORTING_MANAGER','') 
				End   
		END CATCH

		ABC:
				IF IsNull(@HasResult,'') <> ''
					SET @Log_Status = @Log_Status + @HasResult
			
			SET @Row_No =@Row_No+1
			FETCH NEXT FROM curXml INTO @Alpha_Emp_Code	,@Current_Sup_Code,@New_Manager,@Company_Name_of_New_manager,@Effective_Date
	   END  
	CLOSE curXml                      
	DEALLOCATE curXml

