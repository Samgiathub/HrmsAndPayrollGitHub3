


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <30/09/2015>
-- Description:	<Auto CompOFf Approval when Pre-CompOff Approval >
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Auto_Approved_CompOff_Leave]
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	Declare @Cur_Emp_ID numeric(18,0)
	Declare @Cur_Cmp_ID numeric(18,0)
	Declare @Cur_From_Date datetime
	Declare @Cur_To_Date datetime
	Declare @cur_For_Date datetime
	Declare @cmp_ID numeric(18,0)
	Declare @From_Date datetime
	Declare @To_Date datetime
	Declare @CompOff_Approval_ID Numeric 
    Declare @Emp_ID Numeric  
    Declare @Extra_Work_Date DateTime  
    Declare @Extra_Work_Hours Varchar(10)
    Declare @Contact_No Varchar(30)
    Declare @Email_ID Varchar(150)
    Declare @Alpha_Emp_Code as nvarchar(100)
	Declare @Approval_date as datetime
	Declare @System_date as datetime
	Declare @Login_ID as integer	
	set @Login_ID = 0
	set @From_Date = Convert(date,DATEADD(D,-7,GETDATE()),103)
	set @To_Date = Convert(date,DATEADD(D,-1,GETDATE()),103)
	set @Approval_date = Convert(date,GETDATE(),103)
	
	CREATE TABLE #Emp_table
	(
		Emp_ID numeric(18,0),
		For_Date datetime
		
	)
	CREATE TABLE #CompOff_OT_Auto
	(
		CompOff_Tran_ID			numeric,
		Cmp_ID					numeric,
		Emp_ID					numeric,
		Branch_ID				numeric,
		For_Date				datetime,
		Shift_Hours				varchar(2000),
		Working_Hour			varchar(2000),
		Actual_Worked_Hrs       varchar(2000),
		OT_Hour					varchar(2000),
		In_Time_Actual			nvarchar(8),
		Out_Time_Actual         nvarchar(8),
		Is_Editable				tinyint,
		DayFlag					varchar(5),
		Application_Status		varchar(10),
		CompOff_Days			numeric(18,2)
		
	)
	
	declare CompanyCursor cursor 
	for select CM.cmp_ID from T0010_COMPANY_MASTER CM  WITH (NOLOCK)
	inner join T0040_SETTING AD WITH (NOLOCK) on  CM.Cmp_Id = AD.Cmp_Id 
	and  AD.Setting_Name = 'Auto CompOff Approval' 
	and AD.Setting_Value = 1
	
	open CompanyCursor
		fetch next from CompanyCursor into @cmp_ID 
		while @@FETCH_STATUS = 0
			begin
			
			delete from #Emp_table
			delete from #CompOff_OT_Auto

		select @Login_ID =  isnull(Login_ID,0) 
		from dbo.T0011_LOGIN WITH (NOLOCK) where cmp_ID = @cmp_ID 
		and is_Default = 1 and login_Name like 'admin%'
	
				Declare getEmplist cursor for
				select  EMP_ID,From_Date,To_Date from T0120_PreCompOff_Approval  WITH (NOLOCK)
				where From_Date>= @From_Date and  To_Date <= @To_Date 
					and cmp_ID = @cmp_ID and Approval_Status = 'A'
			open getEmplist	
					fetch next from getEmplist into @cur_emp_ID,@Cur_From_date,@Cur_To_Date
			 while @@FETCH_STATUS = 0
				begin	
						exec getAllDaysBetweenTwoDate @Cur_From_date,@Cur_To_Date
												
						insert into #Emp_table(Emp_ID,For_Date)
						select @Cur_Emp_ID,test1 from test1
							
					fetch next from getEmplist into @cur_emp_ID,@Cur_From_date,@Cur_To_Date
				end
			close getEmplist
			deallocate 	getEmplist

		---------------------------------------------------------------------
		-- Get Comp-Off Applicable dates
		---------------------------------------------------------------------
		Declare getCompOffList cursor for
			select  emp_ID from #Emp_table Group by emp_ID
		open getcompOffList	
			fetch next from getcompOfflist into @cur_emp_ID
			 while @@FETCH_STATUS = 0
				begin
				
						Exec GET_Applicable_Working_Date_For_CompOff @cmp_id,0,@cur_emp_ID,@To_Date,'','',0,1
						
					fetch next from getcompOfflist into  @cur_emp_ID
				end	 
		close getcompOffList
		deallocate getcompOfflist
		
		---------------------------------------------------------------------
		--- Comp-off direct approval
		---------------------------------------------------------------------
   		
		Declare Auto_CompOff_Approval cursor for 
			select COA.Emp_ID,COA.For_Date,OT_Hour,Mobile_No,Work_Email, EM.Alpha_Emp_Code from #CompOff_OT_Auto COA 
			inner join T0080_EMP_MASTER EM  WITH (NOLOCK) on COA.Emp_ID = EM.Emp_ID
			Inner join #Emp_table ET on ET.Emp_ID = COA.Emp_ID and ET.For_Date = COA.For_Date
			where Application_Status = '-'  order by COA.Emp_ID,COA.For_Date 
		open Auto_CompOff_Approval
				fetch next from Auto_CompOff_Approval into @Emp_ID,@Extra_Work_Date,@Extra_Work_Hours,@Contact_No,@Email_ID,@Alpha_Emp_Code
				while  @@FETCH_STATUS = 0 
					begin
							set @System_date = GETDATE()
						    set @CompOff_Approval_ID = 0
							exec P0120_COMPOFF_APPROVAL  @CompOff_Approval_ID output,0,@cmp_ID,@emp_ID,0,@Extra_Work_Date,@Approval_date,@Extra_Work_Hours,@Extra_Work_Hours,'A','','Auto Comp-Off Approval with job',@Contact_No,@Email_ID,@Login_ID,@System_date,'I'
						   
						   if  @CompOff_Approval_ID <= 0
								begin
									Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Alpha_Emp_Code,'Can not successfully auto approved Comp-Off record',@Extra_Work_Date,'Require Manual Approval',GetDate(),'Auto Comp-Off Approval with job', '')
								end	
								 
						fetch next from Auto_CompOff_Approval into @Emp_ID,@Extra_Work_Date,@Extra_Work_Hours,@Contact_No,@Email_ID,@Alpha_Emp_Code   
					end
		close Auto_CompOff_Approval	
		deallocate Auto_CompOff_Approval	
		--------------------------------------------------------------------
			fetch next from CompanyCursor into @cmp_ID 
			end
	close CompanyCursor
	deallocate CompanyCursor		
	
END

