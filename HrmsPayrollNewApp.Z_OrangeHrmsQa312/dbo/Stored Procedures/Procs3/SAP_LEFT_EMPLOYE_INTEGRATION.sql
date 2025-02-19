

---Exec SAP_LEFT_EMPLOYE_INTEGRATION 149,'SERVER\SQL08R2','ORANGE_HRMS'
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[SAP_LEFT_EMPLOYE_INTEGRATION]

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
set @FileName = 'E:\4_Left_Employee.csv'

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
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[SAP_LEFT_EMPLOYE]'') AND type in (N''U''))
Begin
Create Table '+@Database_Name+'.DBO.SAP_LEFT_EMPLOYE
(
Alpha_Emp_Code  Varchar(100)
,Left_Date  datetime
,Reg_Accept_Date  datetime
,Left_Reason  Varchar(100)
,Is_Terminate tinyint
,Uniform_Return  tinyint
,Exit_Interview tinyint
,Notice_period tinyint
,Is_Death tinyint
,[Replace Reporting Manager]  VARCHAR(50)
,Left_Reason_PF VARCHAR(100)
,Left_Reason_PF2 VARCHAR(100)
)
END'
	
exec (@TbScript)
SET @SQL = 'xp_cmdshell '' bcp '+@Database_Name+'.dbo.SAP_LEFT_EMPLOYE IN '+ @FileName + ' -T -c -t, -S '+@Server_Name+' -T''';   

--select @SQL
DELETE from SAP_LEFT_EMPLOYE
EXEC(@SQL) 

Declare @Str_Xml  xml
set @Str_Xml =(select  * from dbo.SAP_LEFT_EMPLOYE 
--where [Alpha Emp Code] Not Like '%Alpha%'
FOR XML AUTO, ELEMENTS xsinil, ROOT('NewDataSet'))
Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'dbo.SAP_LEFT_EMPLOYE','Sheet1OLE')

select 
isnull(Sheet1OLE.value('(Alpha_Emp_Code/text())[1]','Varchar(100)'),'') as Alpha_Emp_Code,
isnull(Sheet1OLE.value('(Left_Date/text())[1]','Varchar(100)'),'') as Left_Date,
isnull(Sheet1OLE.value('(Reg_Accept_Date/text())[1]','Varchar(100)'),'') as Reg_Accept_Date,
isnull(Sheet1OLE.value('(Left_Reason/text())[1]','Varchar(100)'),'') as Left_Reason,
isnull(Sheet1OLE.value('(Is_Terminate/text())[1]','Varchar(100)'),'') as Is_Terminate,
isnull(Sheet1OLE.value('(Uniform_Return/text())[1]','Varchar(100)'),'') as Uniform_Return,
isnull(Sheet1OLE.value('(Exit_Interview/text())[1]','Varchar(100)'),'') as Exit_Interview,
isnull(Sheet1OLE.value('(Notice_period/text())[1]','Varchar(100)'),'') as Notice_period,
isnull(Sheet1OLE.value('(Is_Death/text())[1]','Varchar(100)'),'') as Is_Death,
isnull(Sheet1OLE.value('(Replace_x0020_Reporting_x0020_Manager/text())[1]','Varchar(100)'),'') as Replace_Reporting_Manager,
isnull(Sheet1OLE.value('(Left_Reason_PF/text())[1]','Varchar(100)'),'') as Left_Reason_PF,
isnull(Sheet1OLE.value('(Left_Reason_PF2/text())[1]','Varchar(100)'),'') as Left_Reason_PF2
into #Temptable from @Str_Xml.nodes('/NewDataSet/Sheet1OLE') as Temp(Sheet1OLE)

Select * from #Temptable
------- XXXXX------
Return

Declare @Alpha_Emp_Code	 as varchar(100)
Declare @Branch_Name	  as varchar(100)
Declare @Grade	  as varchar(100)
Declare @Department	  as varchar(100)
Declare @Designation  as varchar(100)

SET @Row_No =1

declare curXml cursor for 
		select Alpha_Emp_Code	,Branch_Name,Grade,Department,Designation  from #Temptable
	    
	    open curXml                        
		fetch next from curXml into @Alpha_Emp_Code	,@Branch_Name,@Grade,@Department,@Designation 
		while @@fetch_status >= 0 
		Begin                     
		
	    BEGIN TRY
		
		IF ISNULL(@Branch_Name,'') <>''
		BEGIN
			EXEC [P0080_EMP_MASTER_UPDATE_IMPORT]	@Cmp_ID	=@Cmp_ID,@Alpha_Emp_Code=@Alpha_Emp_Code,@Column_Name='Branch_Name',@Column_Value=@Branch_Name,@tran_type='U' ,@GUID='' ,@User_Id= 0 ,@IP_Address = 'Auto Import'
		END
		
		IF ISNULL(@Grade,'')  <>''
		BEGIN
			EXEC [P0080_EMP_MASTER_UPDATE_IMPORT]	@Cmp_ID	=@Cmp_ID,@Alpha_Emp_Code=@Alpha_Emp_Code,@Column_Name='Grade',@Column_Value=@Grade,@tran_type='U' ,@GUID='' ,@User_Id= 0 ,@IP_Address = 'Auto Import'
		END
		
		IF ISNULL(@Department,'')  <>''
		BEGIN
			EXEC [P0080_EMP_MASTER_UPDATE_IMPORT]	@Cmp_ID	=@Cmp_ID,@Alpha_Emp_Code=@Alpha_Emp_Code,@Column_Name='Department',@Column_Value=@Department,@tran_type='U' ,@GUID='' ,@User_Id= 0 ,@IP_Address = 'Auto Import'
		END
				
		IF ISNULL(@Designation,'')  <>''
		BEGIN
			EXEC [P0080_EMP_MASTER_UPDATE_IMPORT]	@Cmp_ID	=@Cmp_ID,@Alpha_Emp_Code=@Alpha_Emp_Code,@Column_Name='Designation',@Column_Value=@Designation,@tran_type='U' ,@GUID='' ,@User_Id= 0 ,@IP_Address = 'Auto Import'
		END
		      	
		END TRY
		
		BEGIN CATCH 
			DECLARE @w_error VARCHAR(200) 
			SET @w_error= NULL

			SET @w_error = error_message()
			IF @w_error is not NULL 
				BEGIN
					SET @HasResult = cast(@Alpha_Emp_Code as varchar(100)) + ','				
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@w_error,0,'Error in Auto Import Data',GETDATE(),'Left_Employee','') 
				End   
		END CATCH

		ABC:
				IF IsNull(@HasResult,'') <> ''
					SET @Log_Status = @Log_Status + @HasResult
			
			SET @Row_No =@Row_No+1
			FETCH NEXT FROM curXml INTO @Alpha_Emp_Code	,@Branch_Name,@Grade,@Department,@Designation 
	   END  
	CLOSE curXml                      
	DEALLOCATE curXml

