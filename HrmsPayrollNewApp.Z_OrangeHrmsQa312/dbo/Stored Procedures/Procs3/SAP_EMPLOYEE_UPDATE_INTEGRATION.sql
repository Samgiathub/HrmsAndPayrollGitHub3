

---Exec SAP_EMPLOYEE_UPDATE_INTEGRATION 149,'SERVER\SQL08R2','ORANGE_HRMS'
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[SAP_EMPLOYEE_UPDATE_INTEGRATION]

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
set @FileName = 'E:\2_Employee_Update.csv'

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
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[SAP_EMPLOYEE_UPDATE]'') AND type in (N''U''))
Begin
Create Table '+@Database_Name+'.DBO.SAP_EMPLOYEE_UPDATE
(
[Alpha Emp Code]  Varchar(100)
,Branch_Name  Varchar(100)
,Grade  Varchar(100)
,Department  Varchar(100)
,Designation  Varchar(100)
)
END'
exec (@TbScript)

SET @SQL = 'xp_cmdshell '' bcp '+@Database_Name+'.dbo.SAP_EMPLOYEE_UPDATE IN '+ @FileName + ' -T -c -t, -S '+@Server_Name+' -T''';   

--select @SQL
DELETE from SAP_EMPLOYEE_UPDATE
EXEC(@SQL) 


Declare @Str_Xml  xml
set @Str_Xml =(select  * from dbo.SAP_EMPLOYEE_UPDATE 
where [Alpha Emp Code] Not Like '%Alpha%'
FOR XML AUTO, ELEMENTS xsinil, ROOT('NewDataSet'))
Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'dbo.SAP_EMPLOYEE_UPDATE','Sheet1OLE')

--select @Str_Xml

select 
isnull(Sheet1OLE.value('(Alpha_x0020_Emp_x0020_Code/text())[1]','Varchar(100)'),'') as Alpha_Emp_Code,
isnull(Sheet1OLE.value('(Branch_Name/text())[1]','Varchar(100)'),'') as Branch_Name,
isnull(Sheet1OLE.value('(Grade/text())[1]','Varchar(100)'),'') as Grade,
isnull(Sheet1OLE.value('(Department/text())[1]','Varchar(100)'),'') as Department,
isnull(Sheet1OLE.value('(Designation/text())[1]','Varchar(100)'),'') as Designation
into #Temptable from @Str_Xml.nodes('/NewDataSet/Sheet1OLE') as Temp(Sheet1OLE)

--select * from #Temptable

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
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,@w_error,0,'Error in Auto Import Data',GETDATE(),'Update Employee Master','') 
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


----------------

Declare @profile as varchar(50)
Declare @Server_link as varchar(50)
Declare @Profile_Email as varchar(Max)
set @Server_link =''
set @profile = ''
set @Profile_Email = ''
  
select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,''),@Profile_Email = ISNULL(Email_Id,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
         					  
if isnull(@profile,'') = ''
 begin
   select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,''),@Profile_Email = ISNULL(Email_Id,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0       					   
 end 

Declare @Cmp_Name  as varchar(50)
 
Declare @HREmail_ID nvarchar(4000)
Declare @HREmp_Name nvarchar(400)
Select @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Is_HR = 1)
Select @HREmp_Name =(Select Emp_Full_Name From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID in (SELECT TOP 1 Emp_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID= @Cmp_Id AND Is_HR = 1 ))

SET @Cmp_Name = (Select TOP 1 Cmp_Name From T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID)

--Branch_Name,Grade,Department,Designation


Select IDENTITY (INT, 1, 1) AS ID,C1,[Emp_Code],[Emp_Name],
--nullif(Branch_Name,'-') as Branch_Name
case When  Isnull(Branch_Name,'')='' THEN '-' ELSE Isnull(Branch_Name,'-') END  as Branch_Name
,case When  Isnull(Grade,'')='' THEN '-' ELSE Isnull(Grade,'-') END  as Grade
,case When  Isnull(Department,'')='' THEN '-' ELSE Isnull(Department,'-') END  as Department
,case When  Isnull(Designation,'')='' THEN '-' ELSE Isnull(Designation,'-') END  as Designation
---,Grade,Department,Designation
,[Status],Reason 
Into #ImportDATA
From (

Select 1 as C1,[Emp_Code], A.Emp_Full_Name as [Emp_Name],
Isnull(Branch_Name,'-') as Branch_Name
,Isnull(Grade,'-') as Grade
,Isnull(Department,'-') as Department
,Isnull(Designation,'-') as Designation,
'Success'as[Status],'-' as Reason From T0080_EMP_MASTER AS A WITH (NOLOCK)
Inner JOIN SAP_EMPLOYEE_UPDATE AS B On cast(A.Emp_code AS varchar(50)) = cast(B.[Alpha Emp Code] AS varchar(50))
Union ALL
select DISTINCT 2 as C1,C.[Emp_Code],C.Emp_Full_Name as [Emp_Name],
Branch_Name,Grade,Department,Designation,
'Failed'as[Status],Error_Desc as Reason  from T0080_Import_Log AS A WITH (NOLOCK)
Inner JOIN SAP_EMPLOYEE_UPDATE AS B On cast(A.Emp_code AS varchar(50)) = cast(B.[Alpha Emp Code] AS varchar(50))
INNER JOIN T0080_EMP_MASTER AS C WITH (NOLOCK) ON cast(A.Emp_code AS varchar(50)) = cast(C.Alpha_Emp_Code AS varchar(50))
) as Data Order BY C1

Declare  @TableHead varchar(max), @TableTail varchar(max)   

           		  Set @TableHead = '<html><head>' +
									  '<style>' +
									  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
									  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear All, </div>	<br/>					
								  								  
								  <table width="850" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle">
									 <table width="800" border="0" cellspacing="0" cellpadding="0">

									  <tr>
										<td colspan="2" width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Employee Update Status</td>
									  </tr>
										  
										  <tr>
											<td width="400" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 0px 0px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align: left; font-size: 12px; padding-left:20px;border-right:none;"><b>'+ @Cmp_Name +'</b></td>
											<td width="400" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 0px 10px 10px 0px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align: right; font-size: 12px; padding-right:20px;border-left:none;"><b>'+ CONVERT(varchar(20),GETDATE() - 1,106) +'</b></td>
										  </tr>
										 
								  </table>                                    
								  <table width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: bold; text-align: center;
									font-size: 12px;"><tr>' +
										  '<td bgcolor=#FFFFFF align=center><b>SrNo</b></td>' +
										  '<td align=center><b>Employee Code</b></td>' +
										  '<td align=center><b>Employee Name</b></td>' +
										  
										  '<td align=center><b>Branch</b></td>' +
										  '<td align=center><b>Grade</b></td>' +
										  '<td align=center><b>Department</b></td>' +
										  '<td align=center><b>Designation</b></td>' +

										  '<td align=center><b>Status</b></td>' +
										  '<td align=center><b>Reason</b></td>' 
									                                     
                  SET @TableTail = '</table></td></tr></table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT 	ID as [TD],
										[Emp_Code]  as [TD],
										[Emp_Name]  as [TD],
										[Branch_Name]  as [TD],
										[Grade] as [TD],
										[Department]  as [TD],
										[Designation]  as [TD],
										[Status]  as [TD],
										Reason  as [TD]
                                FROM    #ImportDATA 
                                ---where Cmp_ID = @Cmp_ID
                                ORDER BY  [Emp_Code] For XML raw('tr'), ELEMENTS) 
				  
				  Set @Body = replace(@Body,'<td>','<td align=''left''>')
           		  SELECT  @Body = @TableHead + @Body + @TableTail 

	IF isnull(@Body,'')<>''
	BEGIN		
		EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = 'sajid@orangewebtech.com', @subject = 'New Joining Status.', @body = @Body, @body_format = 'HTML',@copy_recipients ='' 
	END     
 
 --------------------
