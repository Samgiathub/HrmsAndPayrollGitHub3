

---Exec SAP_NEW_JOINING_INTEGRATION 149,'SERVER\SQL08R2','ORANGE_HRMS'
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[SAP_NEW_JOINING_INTEGRATION]

@Cmp_ID As numeric,
@Server_Name as Varchar(100),
@Database_Name as Varchar(100)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Server_Name ='' OR @Database_Name =''
BEGIN
	Return
ENd


-------------- Create Table ---------------
Declare @TbScript as Varchar(4000)
SET @TbScript = 'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[New_Joining_Import]'') AND type in (N''U''))
Begin
CREATE TABLE ' +@Database_Name+'.[dbo].[New_Joining_Import](
	[Emp Code] [decimal](18, 0) NULL,
	[Initial Name] [nvarchar](255) NULL,
	[First Name] [nvarchar](255) NULL,
	[Second Name] [nvarchar](255) NULL,
	[Last Name] [nvarchar](255) NULL,
	[Branch] [nvarchar](255) NULL,
	[Grade] [nvarchar](255) NULL,
	[Department] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Designation] [nvarchar](255) NULL,
	[TYPE] [nvarchar](255) NULL,
	[General Shift] [nvarchar](255) NULL,
	[BANK NAME] [nvarchar](255) NULL,
	[CURR NAME] [nvarchar](255) NULL,
	[DOJ] [datetime] NULL,
	[Pan No] [nvarchar](255) NULL,
	[Esic No] [nvarchar](255) NULL,
	[PF no] [nvarchar](255) NULL,
	[DOB] [datetime] NULL,
	[MARITAL STATUS] [decimal](18, 0) NULL,
	[GENDER] [nvarchar](255) NULL,
	[NATIONALITY] [nvarchar](255) NULL,
	[LOCATION] [nvarchar](255) NULL,
	[ADDRESS] [nvarchar](255) NULL,
	[CITY] [nvarchar](255) NULL,
	[STATE] [nvarchar](255) NULL,
	[POST BOX] [nvarchar](255) NULL,
	[Tel No] [nvarchar](255) NULL,
	[MOBILE NO] [nvarchar](255) NULL,
	[Work Tel No] [nvarchar](255) NULL,
	[Work Email] [nvarchar](255) NULL,
	[Other Email] [nvarchar](255) NULL,
	[ADDRESS1] [nvarchar](255) NULL,
	[CITY1] [nvarchar](255) NULL,
	[State1] [nvarchar](255) NULL,
	[Post Box1] [nvarchar](255) NULL,
	[SALARY] [decimal](18, 0) NULL,
	[Gross_Salary] [decimal](18, 0) NULL,
	[CTC] [decimal](18, 0) NULL,
	[Wages_Type] [nvarchar](255) NULL,
	[Salary_Basis_On] [nvarchar](255) NULL,
	[Payment_Mode] [nvarchar](255) NULL,
	[Emp_Bank_Ac_No] [nvarchar](255) NULL,
	[Emp_OT] [nvarchar](255) NULL,
	[Min limit] [datetime] NULL,
	[Max Limit] [datetime] NULL,
	[Late Mark] [datetime] NULL,
	[Full PF] [nvarchar](255) NULL,
	[Prof# Tax] [nvarchar](255) NULL,
	[Fix Salary] [nvarchar](255) NULL,
	[Blood_Group] [nvarchar](255) NULL,
	[Enroll_No] [nvarchar](255) NULL,
	[Father_Name] [nvarchar](255) NULL,
	[Bank_IFSC_NO] [nvarchar](255) NULL,
	[Confirmation_Date] [nvarchar](255) NULL,
	[Probation] [nvarchar](255) NULL,
	[Old_Ref_No] [nvarchar](255) NULL,
	[Alpha_Code] [nvarchar](255) NULL,
	[Emp_Superior] [decimal](18, 0) NULL,
	[Is_LWF] [nvarchar](255) NULL,
	[Weekday_OT_Rate] [nvarchar](255) NULL,
	[Weekoff_OT_Rate] [nvarchar](255) NULL,
	[Holiday_OT_Rate] [nvarchar](255) NULL,
	[Business Segment] [nvarchar](255) NULL,
	[Vertical] [nvarchar](255) NULL,
	[sub_Vertical] [nvarchar](255) NULL,
	[Group of Joining] [nvarchar](255) NULL,
	[sub_Branch] [nvarchar](255) NULL,
	[Salary_Cycle] [nvarchar](255) NULL,
	[Company Full PF] [decimal](18, 0) NULL,
	[Pay_Scale_Name] [nvarchar](255) NULL,
	[Customer_Audit] [nvarchar](255) NULL
) ON [PRIMARY]
END'
exec (@TbScript)
---------------------------------------------



Declare @FileName as varchar(50)
declare @SQL as varchar(max)
set @FileName = 'E:\1_Employee_New_Joining.csv'

---bcp ace.dbo.New_Joining_Import in C:\1_Employee_New_Joining.csv -c -t, -S 192.168.1.44 -T

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

---SET @SQL = 'xp_cmdshell '' bcp Orange_HRMS.dbo.New_Joining_Import IN '+ @FileName + ' -T -c -t, -S SERVER\SQL08R2 -T''';   
SET @SQL = 'xp_cmdshell '' bcp '+@Database_Name+'.dbo.New_Joining_Import IN '+ @FileName + ' -T -c -t, -S '+@Server_Name+' -T''';   

--select @SQL
DELETE from New_Joining_Import
EXEC(@SQL) 

---xp_cmdshell ' bcp ORANGE_HRMS.dbo.New_Joining_Import IN E:\1_Employee_New_Joining.csv -T -c -t,'
Declare @Str_Xml  xml
set @Str_Xml =(select  * from dbo.New_Joining_Import FOR XML AUTO, ELEMENTS xsinil, ROOT('NewDataSet'))
Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'dbo.New_Joining_Import','Sheet1OLE')

EXEC P0080_EMP_MASTER_IMPORT_NEW @Cmp_ID=@Cmp_ID ,@Log_Status = 0 ,@Str_Xml =@Str_Xml,@User_Id= 0, @IP_Address = 'Auto Import' 

--select * from New_Joining_Import
---Return

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

Select IDENTITY (INT, 1, 1) AS ID,C1,[Emp_Code],[Emp_Name],[Status],Reason 
Into #ImportDATA
From (

Select 1 as C1,[Emp_Code], B.[First Name] as [Emp_Name],'Success'as[Status],'-' as Reason From T0080_EMP_MASTER AS A WITH (NOLOCK)
Inner JOIN New_Joining_Import AS B On cast(A.Emp_code AS varchar(50)) = cast(B.[Emp Code] AS varchar(50))

Union ALL
select DISTINCT 2 as C1,[Emp_Code],B.[First Name]  as [Emp_Name],'Failed'as[Status],Error_Desc as Reason  from T0080_Import_Log AS A WITH (NOLOCK) Inner JOIN New_Joining_Import AS B On cast(A.Emp_code AS varchar(50)) = cast(B.[Emp Code] AS varchar(50))
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
										<td colspan="2" width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">New Joining Status</td>
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
										  '<td align=center><b>Status</b></td>' +
										  '<td align=center><b>Reason</b></td>' 
									                                     
                  SET @TableTail = '</table></td></tr></table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT 	ID as [TD],
										[Emp_Code]  as [TD],
										[Emp_Name]  as [TD],
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
 
 

