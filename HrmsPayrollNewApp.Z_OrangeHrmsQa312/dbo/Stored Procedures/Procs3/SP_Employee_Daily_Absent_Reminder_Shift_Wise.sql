
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_Absent_Reminder_Shift_Wise]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS 
BEGIN   

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      SET @DATE = CAST(GETDATE() AS varchar(11))
      
      
       
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
     CREATE table #Temp (
	Cmp_Id Numeric,
	Emp_Id numeric,
	Emp_Code varchar(100),
	Emp_Name varchar(200),
	Desig_Name varchar(100),
	Dept_Name Varchar(100),
	For_Date Datetime,
	Status varchar(10),
	Branch_name varchar(100)
) 
            
		--Insert Into #Temp
		--	(Emp_ID,Emp_code,Emp_name,Status) 
			 
		--	exec SP_TODAYS_PRESENT_GET @Cmp_ID=1,@branch_ID=0,@Todate=cast(getdate() as varchar(11)),@Type='X'
            
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

            
	 INSERT    INTO #Temp
     exec [SP_Get_Present_Absent_Emp_List] @cmp_id_Pass,@DATE
     
     -- Added by rohit on 15072013
     Alter  table #Temp
     Add  Shift_Id numeric(3,0);  --Updated by Nimesh from numeric(2,0) 21 May 2015

	/*Commented by Nimesh 21 May 2015
update #temp
set Shift_id = QA1.Shift_id
from #temp inner join
(select Esd.Shift_id,Esd.Emp_id,For_date from T0100_Emp_Shift_Detail as ESD inner join
(select Emp_ID,MAX(For_date) as MAX_For_date from T0100_Emp_Shift_Detail  where for_date <= @DATE group by Emp_ID) Q1 on
ESD.Emp_id = Q1.Emp_ID and esd.For_Date = q1.MAX_For_date) QA1 on
#temp.Emp_id = QA1.Emp_ID
   
   --Where D.For_Date = @DATE 
   */
   
	--Added by Nimesh 21 May, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Declare @constraint varchar(max);
	Select @constraint = COALESCE(@constraint + '#', @constraint) + Cast(Emp_Id As Varchar) From #Temp

	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @cmp_id_Pass, NULL, @DATE, @constraint

	--Updating default shift id
	update	#temp
	set		Shift_id = QA1.Shift_id
	from	#temp inner join
			(select Esd.Shift_id,Esd.Emp_id,For_date from T0100_Emp_Shift_Detail as ESD WITH (NOLOCK) inner join
			(select Emp_ID,MAX(For_date) as MAX_For_date from T0100_Emp_Shift_Detail WITH (NOLOCK)
				where for_date <= @DATE group by Emp_ID) Q1 on
			ESD.Emp_id = Q1.Emp_ID and esd.For_Date = q1.MAX_For_date) QA1 on
			#temp.Emp_id = QA1.Emp_ID

	--Added by Nimesh 21 April, 2015
	Update	#Temp
	SET		Shift_ID = R.R_ShiftID
	FROM	#Rotation R
	WHERE	Emp_Id=R_EmpID  AND R_DayName='Day' + CAST(DATEPART(d, @DATE) As Varchar) AND 
			R_Effective_Date = (Select Max(R_Effective_Date) FROM #Rotation R1 WHERE R_EmpID=Emp_Id AND R1.R_Effective_Date <= @DATE)

	--Updating Shift ID from Employee Shift Detail if defined where Shift_Type = 0 and exist in Employee Shift Detail
	UPDATE	#Temp 
	SET		Shift_ID=ESD.Shift_ID
	FROM	(#Temp D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
			FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@cmp_id_Pass,Cmp_ID) AND For_Date = @DATE) ESD ON
			D.Emp_Id=ESD.Emp_ID AND ESD.For_Date=@DATE) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Shift_ID=SM.Shift_ID AND SM.Cmp_ID=@cmp_id_Pass
	WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
				WHERE R_DayName = 'Day' + CAST(DATEPART(d, @DATE) As Varchar) AND R_Effective_Date<=@DATE
				GROUP BY R.R_EmpID) 
			
   --Updating Shift ID from Employee Shift Detail if defined where Shift_Type = 1 and not exist in Employee Shift Detail
	UPDATE	#Temp 
	SET		Shift_ID=ESD.Shift_ID
	FROM	(#Temp D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
			FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@cmp_id_Pass,Cmp_ID) AND For_Date = @DATE) ESD ON
			D.Emp_Id=ESD.Emp_ID AND ESD.For_Date=@DATE) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Shift_ID=SM.Shift_ID AND SM.Cmp_ID=@cmp_id_Pass
	WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
				WHERE R_DayName = 'Day' + CAST(DATEPART(d, @DATE) As Varchar) AND R_Effective_Date<=@DATE
				GROUP BY R.R_EmpID) 
	--End Nimesh

declare @Sh_Id numeric
Declare @shift_Id numeric

set @Sh_id = DATEPART(hh,GETDATE())

 CREATE table #Shift_Cons 
 (      
  Shift_ID numeric  
 )      
     

Insert Into #Shift_Cons  
select shift_id from dbo.T0040_SHIFT_MASTER WITH (NOLOCK) where cast(left(Shift_St_Time,2) as numeric(2,0))  <= @Sh_id and cast(left(Shift_St_Time,2) as numeric(2,0)) >= @Sh_id - 2

	Delete #Temp Where Status <> 'A' or shift_id not in (select Shift_id from #Shift_Cons )
	-- ended by rohit on 15072013


	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	Declare @Branch as varchar(255)
	
	declare Cur_Company cursor for                    
		select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin     
				
				declare Cur_Branch cursor for                    
				select  Branch_Name as Branch from T0030_Branch_master WITH (NOLOCK) 
				where Cmp_id = @Cmp_Id order by Branch_name
				open Cur_Branch                      
				fetch next from Cur_Branch into @Branch
				while @@fetch_status = 0                    
				begin     
			
					SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
					FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
					Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1

					Select @ECount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id and branch_name = @branch

					  ---ALTER dynamic template for Employee.				
					  Declare  @TableHead varchar(max),
							   @TableTail varchar(max)   
       					  Set @TableHead = '<html><head>' +
										  '<style>' +
										  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
										  '</style>' +
										  '</head>' +
										  '<body>
										  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
										  Dear ' + @HR_Name + ' </div>	<br/>					
										  
										  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
										  <tr>
											 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
												<tr>
												<td height="9" align="center" valign="middle" ></td>
												</tr>
											  <tr>
												<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Absent Report ( ' + @Date + ') for ' + @Branch + ' </td>
											  </tr>
												  <tr>
													<td height="4" align="center" valign="middle"></td>
												  </tr>
												  <tr>
													<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Absent Employees : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
												  </tr>
												  <tr>
													<td height="8" align="center" valign="middle"></td>
												  </tr>
										  </table>
			                                
										  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
											border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
											color: #000000; text-decoration: none; font-weight: normal; text-align: left;
											font-size: 12px;">' +
												  '<tr border="1"><td align=center><span style="font-size:small"><b>Code</b></span></td>' +
												  '<td align=center><b><span style="font-size:small">Employee Name</span></b></td>' +
												  '<td align=center><b><span style="font-size:small">Department</span></b></td>' +
												  '<td align=center><b><span style="font-size:small">Designation</span></b></td>' +
												  '<td align=center><b><span style="font-size:small">Status</span></b></td>'
												                                     
						  SET @TableTail = '</table></body></html>';                  	
						  DECLARE @Body AS VARCHAR(MAX)
						  SET @Body = ( SELECT  
												emp_Code  as [TD],
												Emp_name  as [TD],
												Isnull(Dept_Name,'-') as [TD],
												Isnull(Desig_Name,'-') as [TD],
												Status As [TD]
										FROM    #Temp
										WHERE   Cmp_ID = @Cmp_Id and Isnull(Branch_name,'') = @Branch ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
			                         


							   --if (@HREmail_ID <> '')
							   -- BEGIN
							   --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
			                       
							   -- END
							
			       			
       					  SELECT  @Body = @TableHead + @Body + @TableTail  
			       		  
       					  Declare @subject as varchar(100)           
       					  Set @subject = 'Absent Report ( ' + @Date + ' ) ( ' + @Branch + ')'
			       		  
			       		    Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end  		 	           			              

					--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange1', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = 'Rohit@orangewebtech.com'  
						EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email  
					--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = @subject, @body = @Body, @body_format = 'HTML'

					Set @HREmail_ID = ''
					Set @HR_Name = ''
					Set @ECount = 0
			
			
			fetch next from Cur_Branch into @Branch
			end                    
			close Cur_Branch
			deallocate Cur_Branch
			
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End


