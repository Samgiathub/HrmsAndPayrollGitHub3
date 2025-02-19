

---------------------------------------------------------------------
--- Comp-off direct approval
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---------------------------------------------------------------------
CREATE PROCEDURE [dbo].[P_Auto_Approved_CompOff_Application]
 @Cmp_id numeric(18,0) = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @For_Date datetime	
	DECLARE @Cur_Cmp_ID NUMERIC(18,0)
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
	DECLARE @Compoff_App_ID as NUMERIC(18,0)
	DECLARE @S_Emp_ID as NUMERIC(18,0)
	set @Login_ID = 0
	set @Approval_date = Convert(date,GETDATE(),103)
	
	if @Cmp_id = 0
		set @Cmp_id = NULL
		
	DECLARE CompanyCursor cursor 
	for select cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=ISNULL(@Cmp_id,Cmp_Id) and IS_Active=1
	open CompanyCursor
		fetch next from CompanyCursor into @Cur_Cmp_ID 
		while @@FETCH_STATUS = 0
			begin
				select @Login_ID =  isnull(Login_ID,0) 
				from dbo.T0011_LOGIN WITH (NOLOCK) where cmp_ID = @Cur_Cmp_ID 
				and is_Default = 1 and login_Name like 'admin%'
		--------------------------------------------------------------------
		print @Cur_Cmp_ID
				Declare Auto_CompOff_Approval cursor for 
					select COA.Emp_ID,COA.Extra_Work_Date,COA.Extra_Work_Hours,Mobile_No,Work_Email, 
						EM.Alpha_Emp_Code,COA.Compoff_App_ID,COA.S_Emp_ID
					FROM T0100_CompOff_Application COA WITH (NOLOCK)
						inner join T0080_EMP_MASTER EM WITH (NOLOCK) on COA.Emp_ID = EM.Emp_ID				
					where Application_Status = 'P' and COA.Cmp_ID=@Cur_Cmp_ID  
				open Auto_CompOff_Approval
						fetch next from Auto_CompOff_Approval into @Emp_ID,@Extra_Work_Date,@Extra_Work_Hours,@Contact_No,@Email_ID,@Alpha_Emp_Code,@Compoff_App_ID,@S_Emp_ID
						while  @@FETCH_STATUS = 0 
							begin
									set @System_date = GETDATE()
									set @CompOff_Approval_ID = 0
									--select @Emp_ID,@Extra_Work_Date,@Extra_Work_Hours,@Contact_No,@Email_ID,@Alpha_Emp_Code,@Cur_Cmp_ID,@Login_ID
									exec P0120_COMPOFF_APPROVAL  @CompOff_Approval_ID output,@Compoff_App_ID,@Cur_Cmp_ID,@emp_ID,@S_Emp_ID,@Extra_Work_Date,@Approval_date,@Extra_Work_Hours,@Extra_Work_Hours,'A','','Auto Comp-Off Approval with job',@Contact_No,@Email_ID,@Login_ID,@System_date,'I'
									
									if  @CompOff_Approval_ID <= 0
									begin
										Insert Into dbo.T0080_Import_Log Values (0,@Cur_Cmp_ID,@Alpha_Emp_Code,'Can not successfully auto approved Comp-Off record',@Extra_Work_Date,'Require Manual Approval',GetDate(),'Auto Comp-Off Approval with job', '')
									end	
								fetch next from Auto_CompOff_Approval into @Emp_ID,@Extra_Work_Date,@Extra_Work_Hours,@Contact_No,@Email_ID,@Alpha_Emp_Code,@Compoff_App_ID,@S_Emp_ID  
							end
				close Auto_CompOff_Approval	
				deallocate Auto_CompOff_Approval	
		--------------------------------------------------------------------
			fetch next from CompanyCursor into @Cur_Cmp_ID 
			end
	close CompanyCursor
	deallocate CompanyCursor		
END
