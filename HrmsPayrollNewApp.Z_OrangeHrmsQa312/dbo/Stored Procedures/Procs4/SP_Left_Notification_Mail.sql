


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 28-11-2016
-- Description:	Send Notification of Left Employee Details depends details to HR Manager.
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Left_Notification_Mail] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Left_Date Datetime
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	IF Object_ID('tempdb..#BranchHODManager') is not null
		Begin
			drop table #BranchHODManager
		End
	
	Create Table #BranchHODManager
	(
	   Cmp_ID Numeric(18,0),
	   Emp_ID Numeric(18,0),
	   Branch_Dept_ID Numeric(18,0),
	   Effective_Date Datetime,
	   Flag Char(1) -- B For Branch Manager H For HOD (Head of Department)
	)
	
	IF Object_ID('tempdb..#SchemeDetails') is not null
		Begin
			drop table #SchemeDetails
		End
	
	Create Table #SchemeDetails
	(
	   Cmp_ID Numeric(18,0),
	   Emp_ID Numeric(18,0),
	   Scheme_Type Varchar(100),
	   Scheme_Name Varchar(100),
	   Report_Level Varchar(10)
	)
	
	IF Object_ID('tempdb..#ReportManager') is not null
		Begin
			drop table #ReportManager
		End
		
	Create Table #ReportManager
	(
		Cmp_ID Numeric(18,0),
		Emp_ID Numeric(18,0),
		Effective_Date Datetime
	)
	
	if Object_ID('tempdb..#HRAccountEmail') is not null
		Begin
			drop table #HRAccountEmail
		End
		
	Create Table #HRAccountEmail
	(
		Dept_Name Varchar(100),
		Branch_id_multi Varchar(500),
		Branch_id_multi_Name Varchar(500)
	)
	Declare @HREmail_ID As Varchar(100)
	set @HREmail_ID = ''
	Select @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Is_HR = 1)
	
	Insert into #HRAccountEmail(Dept_Name,Branch_id_multi,Branch_id_multi_Name)
	SELECT	'Accountant' as Department,Branch_id_multi,'' FROM	T0011_LOGIN  L  WITH (NOLOCK) WHERE	Is_Accou = 1 and L.Cmp_ID  = @Cmp_ID and L.Emp_ID = @Emp_ID 
	Union ALL
	SELECT	'HR' as Department,Branch_id_multi,'' FROM	T0011_LOGIN  L WITH (NOLOCK)  WHERE	Is_HR = 1 and L.Cmp_ID  = @Cmp_ID  and L.Emp_ID = @Emp_ID 
	Union ALL
	SELECT	'Travel Desk' as Department,Branch_id_multi,'' FROM	T0011_LOGIN  L  WITH (NOLOCK) WHERE	Travel_Help_Desk = 1 and L.Cmp_ID  = @Cmp_ID  and L.Emp_ID = @Emp_ID 
	Union ALL
	SELECT	'IT' as Department,Branch_id_multi,'' FROM	T0011_LOGIN  L  WITH (NOLOCK) WHERE	IS_IT = 1 and L.Cmp_ID  = @Cmp_ID  and L.Emp_ID = @Emp_ID 
	
	Declare @Dept_Name As Varchar(100) 
	Declare @Branch_id_multi As Varchar(300) 
	Declare @Branch_Name_multi As Varchar(300) 
	
	
	DECLARE CurEmail CURSOR FOR 
	SELECT Dept_Name,Branch_id_multi FROM #HRAccountEmail
	
	OPEN CurEmail
	FETCH NEXT FROM CurEmail INTO @Dept_Name,@Branch_id_multi
	WHILE @@FETCH_STATUS = 0
		BEGIN	
			
			SET @Branch_Name_multi = NULL;
			
			if @Branch_id_multi = ''
				Set @Branch_id_multi = NULL
				
			IF isnull(@Branch_id_multi,'') <> '' 
				begin				
					SELECT	@Branch_Name_multi = COALESCE(@Branch_Name_multi + ',','') + ISNULL(Branch_Name,'') 
					FROM	T0030_BRANCH_MASTER WITH (NOLOCK)
							INNER JOIN dbo.Split (@Branch_id_multi,',') ON Data = Branch_ID	
				END
			ELSE
				BEGIN
					SET @Branch_Name_multi = 'All'
				END
			
			UPDATE	#HRAccountEmail 
			SET		Branch_id_multi_Name = isnull(@Branch_Name_multi ,'')
			WHERE	Dept_Name = @Dept_Name 
			
			FETCH NEXT FROM CurEmail INTO @Dept_Name,@Branch_id_multi
		END
	CLOSE CurEmail	
	DEALLOCATE CurEmail	
	
	Insert INTO #BranchHODManager(Cmp_ID,Emp_ID,Branch_Dept_ID,Effective_Date,Flag)
	Select T.Cmp_id,T.Emp_id,T.branch_id,T.Effective_Date,'B' FROM T0095_MANAGERS T WITH (NOLOCK)
	Inner JOIN 
	(
		Select branch_id,MAX(Effective_Date) as Eff_Date FROM T0095_MANAGERS WITH (NOLOCK) Where Cmp_id = @Cmp_ID  
		GROUP BY branch_id
	) As qry
	ON T.branch_id = qry.branch_id and T.Effective_Date = qry.Eff_Date
    Where Cmp_id = @Cmp_ID and T.Emp_id = @Emp_ID
	
	Insert INTO #BranchHODManager(Cmp_ID,Emp_ID,Branch_Dept_ID,Effective_Date,Flag)
	Select DM.Cmp_id,DM.Emp_id,DM.Dept_Id,DM.Effective_Date,'H' FROM T0095_Department_Manager DM WITH (NOLOCK)
	Inner JOIN
	(
		Select Dept_Id,Max(Effective_Date) as Eff_Date  FROM T0095_Department_Manager WITH (NOLOCK) Where Cmp_id = @Cmp_ID 
		Group By Dept_Id
	)as qry
	ON DM.Dept_Id = qry.Dept_Id and DM.Effective_Date = qry.Eff_Date
	Where DM.Cmp_id = @Cmp_ID and DM.Emp_id = @Emp_ID
	
	--Select * From #BranchHODManager
	
	Insert into #SchemeDetails(Cmp_ID,Emp_ID,Scheme_Type,Scheme_Name,Report_Level)
	SELECT SD.Cmp_Id,SD.App_Emp_ID,SM.Scheme_Type,SM.Scheme_Name,
	(Case When SD.Rpt_Level = 1 THEN 'First' When SD.Rpt_Level = 2 THEN 'Second' When SD.Rpt_Level = 3 THEN 'Third' When SD.Rpt_Level = 4 THEN 'Fourth' When SD.Rpt_Level = 5 THEN 'Fifth' END)
	FROM T0050_Scheme_Detail SD WITH (NOLOCK)
	INNER Join T0040_Scheme_Master SM WITH (NOLOCK)
	ON SM.Scheme_Id = SD.Scheme_Id
	Where SD.App_Emp_ID = @Emp_ID and SD.Cmp_Id = @Cmp_ID
	
	--Select * From #SchemeDetails
	
	INSERT INTO #ReportManager(Cmp_ID,Emp_ID,Effective_Date)
	SELECT ERD.Cmp_ID,ERD.Emp_ID,ERD.Effect_Date
	FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
	INNER JOIN 
		(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
		 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
		 WHERE Effect_Date <= GETDATE() --And Emp_ID = @Emp_ID
		 GROUP BY emp_ID
		) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = ERD.Emp_ID AND Emp_Left <> 'Y'	--ADDED BY RAMIZ ON 22/01/2018
	WHERE ERD.R_Emp_ID = @Emp_ID
	
	Declare  @TableHead varchar(max)
	Declare  @TableHead1 varchar(max)
	Declare  @TableHead2 varchar(max)
	Declare  @TableHead3 varchar(max)
	Declare  @TableHead4 varchar(max)
	Declare  @TableHead5 varchar(max)
	
	Declare  @TableFooter varchar(max)
	Declare  @TableFooter1 varchar(max)
	Declare  @TableFooter2 varchar(max)
	Declare  @TableFooter3 varchar(max)
	Declare  @TableFooter5 varchar(max)
	
	Declare @Cmp_Name Varchar(500)
	Select @Cmp_Name = Cmp_Name From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_Id = @Cmp_ID
	
	Declare @Emp_Code varchar(100)
	Declare @Employee_Name Varchar(500)
	Select @Emp_Code = Alpha_Emp_Code,@Employee_Name = Emp_Full_Name From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_Id = @Cmp_ID
	
	DECLARE @Chk_HRAccount_Count Numeric(5,0)
	DECLARE @Chk_BranchHOD_Count Numeric(5,0)
	DECLARE @Chk_SchemeDetails_Count Numeric(5,0)
	DECLARE @Chk_ReportManager_Count Numeric(5,0)
		
	SET @Chk_HRAccount_Count = 0
	SET @Chk_BranchHOD_Count = 0
	SET @Chk_SchemeDetails_Count = 0
	SET @Chk_ReportManager_Count = 0

	Select @Chk_HRAccount_Count = Count(1) From #HRAccountEmail
	Select @Chk_BranchHOD_Count = Count(1) From #BranchHODManager
	Select @Chk_SchemeDetails_Count = Count(1) From #SchemeDetails
	Select @Chk_ReportManager_Count = Count(1) From #ReportManager
	
	
	
	if @Chk_HRAccount_Count = 0 and @Chk_BranchHOD_Count = 0 and @Chk_SchemeDetails_Count = 0 and @Chk_ReportManager_Count = 0
		Begin
			return 
		End
		
	Set @TableHead = '<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid;
    padding-left: 1ex">
    <table style="background-color: #edf7fd; border-collapse: collapse; border: 1px solid #b0daff"
        align="center" cellpadding="5px" width="100%">
        <tbody>
            <tr>
                <td colspan="9">
                    Hello,
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    Employee Name : ' + @Emp_Code + '-' + @Employee_Name + ' is left on Date : ' + CONVERT(varchar(11),@Left_Date,103) + '. 
                </td>
            </tr>
            <tr>
				<td colspan="9">
					'+ @Employee_Name + ' is exist in below mentioned list.
				</td>
            </tr>
            <tr>
                <td colspan="9">
                    So kindly Change or Replace Left Employee Name and assign New Employee.
                </td>
            </tr>
  <tr>
                <td colspan="9">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <th colspan="9" style="color: #3f628e; font-weight: bold" align="left">
                                    Branch Manager
                                </th>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Branch Name</b>
                                </td>
                                <td  style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Effective Date</b>
                                </td>
                            </tr>'
    Set @TableFooter = '</tbody></table></td></tr>'  
          
    Set @TableHead1 = '<tr>
                <td colspan="9">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <th colspan="9" style="color: #3f628e; font-weight: bold" align="left">
                                    HOD
                                </th>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Department Name</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Effective Date</b>
                                </td>
                            </tr>'
    Set @TableFooter1 = '</tbody></table></td></tr>'
            
	Set @TableHead2 = '<tr>
                <td colspan="9">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5" border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <td colspan="9" style="color: #3f628e; font-weight: bold">
                                    Assign Scheme Details:
                                </td>
                            </tr>
                            <tr>
                            <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" >
                                    <b>Scheme Type</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Scheme Name</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                     align="center">
                                    <b>Scheme Level</b>
                                </td>
                            </tr>'
    Set @TableFooter2 = '</tbody></table></td></tr>'
            
    Set @TableHead3 = '<tr>
                <td colspan="9">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <td colspan="9" style="color: #3f628e; font-weight: bold">
                                    Reporting Manager of Employee
                                </td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" width="20%">
                                    <b>Alpha Emp Code</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" width="20%">
                                    <b>Employee Name</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" nowrap="" width="15%">
                                    <b>Designation</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Effective Date</b>
                                </td>
                            </tr>'
    Set @TableFooter3 = '</tbody></table></td></tr>' 
    
    Set @TableHead4 ='<tr>
                <td colspan="9">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td colspan="9" style="color: #757677" align="left">
                    Thank you,<br>
                    HR Department
                </td>
            </tr>
            <tr>
                <td colspan="9" align="right">
                    <span style="font-family: arial; font-size: 11px; color: rgb(93,93,93)">Powered by&nbsp;</span><span>'+ @Cmp_Name + '</span>
                </td>
            </tr>
        </tbody>
    </table>
</blockquote>' 

    Set @TableHead5 = '<tr>
                <td colspan="9">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <th colspan="9" style="color: #3f628e; font-weight: bold" align="left">
                                    HR/Account Details
                                </th>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Designation</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Branch Name</b>
                                </td>
                            </tr>'
    Set @TableFooter5 = '</tbody></table></td></tr>'

    DECLARE @Body AS VARCHAR(MAX)
    
                  SET @Body = ( SELECT  
									BM.Branch_Name  as [tdc],
									Convert(nvarchar(11), B.Effective_Date, 113)  as [tdc]	
                                FROM    #BranchHODManager B Inner JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)
                                ON BM.Branch_ID = B.Branch_Dept_ID
                                Where Flag = 'B'
                                For XML raw('tr'), ELEMENTS) 
                             
         
      SET @body = REPLACE(@body, '<tdc>', '<td style="text-align:center;border:1px solid #b0daff;">')  
      SET @body = REPLACE(@body, '</tdc>', '</td>')  
      
      DECLARE @Body1 AS VARCHAR(MAX)
      
				Set @Body1 = ( SELECT  
									DM.Dept_Name  as [tdc],
									Convert(nvarchar(11), B.Effective_Date, 113)  as [tdc]	
                                FROM    #BranchHODManager B Inner JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)
                                ON DM.Dept_Id = B.Branch_Dept_ID
                                Where Flag = 'H'
                                For XML raw('tr'), ELEMENTS)
      
      SET @Body1 = REPLACE(@Body1, '<tdc>', '<td style="text-align:center;border:1px solid #b0daff;">')  
      SET @Body1 = REPLACE(@Body1, '</tdc>', '</td>') 
      
      DECLARE @Body2 AS VARCHAR(MAX)
      
				Set @Body2 = ( SELECT  
									SD.Scheme_Type  as [tdc],
									SD.Scheme_Name  as [tdc],
									SD.Report_Level	as [tdc]
                                FROM    #SchemeDetails SD
                                Order By SD.Scheme_Type
                                For XML raw('tr'), ELEMENTS)
                                
      SET @Body2 = REPLACE(@Body2, '<tdc>', '<td style="text-align:center;border:1px solid #b0daff;">')  
      SET @Body2 = REPLACE(@Body2, '</tdc>', '</td>') 
      
      DECLARE @Body3 AS VARCHAR(MAX)
				
                Set @Body3 = (  Select EM.Alpha_Emp_Code as [tdc],
									EM.Emp_Full_Name as [tdc],
									DM.Desig_Name as [tdc],
									Convert(nvarchar(11), RM.Effective_Date, 113)  as [tdc] 
									From #ReportManager RM 
									Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON RM.Emp_ID = EM.Emp_ID
									LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = EM.Desig_Id
									WHERE (Emp_Left = 'N' OR Emp_Left_Date is null)
									ORDER BY EM.Alpha_Emp_Code  
                                FOR XML RAW('tr'),ELEMENTS)
      
      SET @Body3 = REPLACE(@Body3, '<tdc>', '<td style="text-align:center;border:1px solid #b0daff;">')  
      SET @Body3 = REPLACE(@Body3, '</tdc>', '</td>')   
      
      DECLARE @Body4 AS VARCHAR(MAX)
      
      Set @Body4 = (  Select Dept_Name as [tdc],
									@Branch_Name_multi as [tdc]
									From #HRAccountEmail
                                FOR XML RAW('tr'),ELEMENTS)
      
      SET @Body4 = REPLACE(@Body4, '<tdc>', '<td style="text-align:center;border:1px solid #b0daff;">')  
      SET @Body4 = REPLACE(@Body4, '</tdc>', '</td>')  
      
                                
      SELECT  @Body = isnull(@TableHead,'') + isnull(@Body,'') + isnull(@TableFooter,'') + isnull(@TableHead1,'') + ISNULL(@Body1,'') + isnull(@TableFooter1,'')  + isnull(@TableHead2,'') + ISNULL(@Body2,'') + isnull(@TableFooter2,'')  + isnull(@TableHead3,'') + ISNULL(@Body3,'') + isnull(@TableFooter3,'') +  isnull(@TableHead5,'') + ISNULL(@Body4,'') + isnull(@TableFooter5,'') + ISNULL(@TableHead4,'')                 
	
	  Declare @profile as varchar(50)
				  set @profile = ''
				  declare @server_link as varchar(500)
				  
				  select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link  from t9999_Reminder_Mail_Profile where cmp_id = @Cmp_Id
				  
				  
				  if isnull(@profile,'') = ''
				  begin
					select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link from t9999_Reminder_Mail_Profile where cmp_id = 0
				  end
		IF EXISTS(SELECT 1 FROM msdb.dbo.sysmail_profile WHERE NAME=@profile)
			BEGIN
				IF	@HREmail_ID <> '' AND ISNULL(@HREmail_ID,'') <> ''  --added By Jimit 15112017
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = 'Replace Left Employee Notification', @body = @Body, @body_format = 'HTML',@copy_recipients = '',@blind_copy_recipients = ''
				ELSE IF ISNULL(@HREmail_ID,'') = ''
					PRINT 'HR is not selected.'
				
					--EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = 'ramiz@orangewebtech.com', @subject = 'Replace Left Employee Notification', @body = @Body, @body_format = 'HTML',@copy_recipients = '',@blind_copy_recipients = ''
			
			END			
			
END

