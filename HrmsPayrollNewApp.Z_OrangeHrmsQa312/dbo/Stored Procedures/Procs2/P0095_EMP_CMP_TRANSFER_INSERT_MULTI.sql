




-- =============================================
-- Author:		<Ankit>
-- Create date: <24032014,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_EMP_CMP_TRANSFER_INSERT_MULTI]
	@Tran_Id		Numeric(18,0) Output
   ,@Old_Emp_ID		Numeric(18,0) 
   ,@Old_Cmp_ID		Numeric(18,0)
   ,@New_Cmp_ID		Numeric(18,0)
   ,@Increment_Effective_Date DateTime
   ,@tran_type		Char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
   Declare @New_Emp_Id	    Numeric(18, 0)
   Declare @Branch_ID		Numeric(18, 0)
   Declare @Cat_ID			Numeric(18, 0)
   Declare @Grd_ID			Numeric(18, 0)
   Declare @Dept_ID			Numeric(18, 0)
   Declare @Desig_Id		Numeric(18, 0)
   Declare @Type_ID			Numeric(18, 0)
   Declare @Shift_ID		Numeric(18, 0)
   Declare @Emp_Superior	Numeric(18)
   Declare @Vertical_ID		Numeric(18, 0) 
   Declare @Increment_ID	Numeric(18, 0)
   Declare @Basic_Salary	numeric(18, 2)
   Declare @Gross_Salary	numeric(18, 2)
   Declare @CTC				Numeric(18, 0) 
   Declare @Old_Weekoff_Day	Varchar(100)
   Declare @New_Weekoff_Day	Varchar(100) 
   Declare @New_Privilege	Numeric(18, 0)
   Declare @New_SubVertical_ID	Numeric(18, 0)
   Declare @New_Segment_ID		Numeric(18, 0)
   Declare @New_SubBranch_ID	Numeric(18, 0)
   Declare @New_Login_Alias		Varchar(100) 
   Declare @Old_Login_Alias		Varchar(100) 
   Declare @New_SalCycle_id		Numeric 
   Declare @Old_SalCycle_id		Numeric 
   Declare @Privilege_id		Numeric 

   Set @Old_SalCycle_id = 0
   Set @Privilege_id	= 0
   Set @Branch_ID		= 0	 
   Set @Cat_ID			= 0
   Set @Grd_ID			= 0
   Set @Dept_ID			= 0
   Set @Desig_Id		= 0
   Set @Type_ID			= 0
   Set @Shift_ID		= 0
   Set @Emp_Superior	= 0
   Set @Vertical_ID		= 0
   Set @Increment_ID	= 0
   Set @Basic_Salary	= 0
   Set @Gross_Salary	= 0
   Set @CTC				= 0
   Set @Old_Weekoff_Day	= ''
   Set @New_Weekoff_Day	= ''
   Set @New_Privilege	= 0
   Set @New_SubVertical_ID	= 0
   Set @New_Segment_ID		= 0
   Set @New_SubBranch_ID	= 0
   Set @New_Login_Alias		= ''
   Set @Old_Login_Alias		= ''
   Set @New_SalCycle_id		= 0
   
    Declare @Old_Branch_ID		numeric(18,0)
	Declare @Old_Cat_ID			numeric(18,0)
	Declare @Old_Grd_ID			numeric(18,0)
	Declare @Old_Dept_ID		numeric(18,0)
	Declare @Old_Desig_Id		numeric(18,0)
	Declare @Old_Type_ID		numeric(18,0)
	Declare @Old_Shift_ID		numeric(18,0)
	Declare @Old_Basic_Salary	numeric(18,2)
	Declare @Old_Gross_salary	numeric(22) 
	Declare @Old_CTC			Numeric(18,0)


	 
	If Exists(Select 1 From T0095_EMP_COMPANY_TRANSFER WITH (NOLOCK) Where Old_Cmp_Id = @Old_Cmp_ID And Old_Emp_Id = @Old_Emp_ID And Effective_Date = @Increment_Effective_Date )
		Begin
			Raiserror('@@Employee Same Effect date Is already exists.@@',16,2)				
			Return 
		End

		
   SELECT    --@Old_Branch_ID = Branch_ID, @Old_Cat_ID =Isnull(Cat_ID,0), @Old_Grd_ID = Grd_ID, @old_Dept_ID = isnull(Dept_ID,0), @old_Desig_Id = isnull(Desig_Id,0), @old_Type_ID = isnull(Type_ID,0), 
			 @Old_Basic_Salary= isnull(Basic_Salary,0), @Old_Gross_Salary = isnull(Gross_Salary,0),@Old_Basic_Salary= isnull(Basic_Salary,0),@Old_CTC= isnull(CTC,0)
   FROM      T0095_INCREMENT WITH (NOLOCK)
   Where	 Emp_ID = @Old_Emp_ID And Cmp_ID = @Old_Cmp_ID 
			 And Increment_ID = (Select MAX(Increment_ID) AS Increment_ID From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Old_Emp_ID And Cmp_ID = @Old_Cmp_ID )
	
	Declare @Branch_Name	varchar(250)
	Declare @Grd_Name		varchar(250)
	Declare @Desig_Name		varchar(250)
	Declare @Dept_Name		varchar(250)
	Declare @Shift_Name		varchar(250)
	Declare @Type_Name		varchar(250)
	Declare @Vertical_Name	varchar(250)
	Declare @SubVertical_Name	varchar(250)
	Declare @SubBranch_Name		varchar(250)
	Declare @Segment_Name		varchar(250)
	Declare @Privilege_Type		Varchar(50)
	Declare @Salcycle_Name		varchar(250)
	
	Declare @Alpha_Emp_Code	Varchar(50)
	Declare @LogDesc	Nvarchar(max)
	Declare @Login_ID	NUMERIC   
	Declare @Emp_Full_Name as varchar(250)
	
	set @Login_ID		= null  
	set @Alpha_Emp_Code	= ''
	set @LogDesc		= ''
	set @Emp_Full_Name	= ''
	Set @Salcycle_Name  = ''
	
	Select @Branch_Name = Branch_Name,@Grd_Name = Grd_Name,@Dept_Name = Dept_Name,@Desig_Name = Desig_Name,@Shift_Name = Shift_Name,@Type_Name = Type_Name,@Vertical_Name = Vertical_Name,@SubVertical_Name =  SubVertical_Name,@SubBranch_Name = SubBranch_Name,@Segment_Name  = Segment_Name  ,@Old_SalCycle_id = SalDate_id
		   ,@Alpha_Emp_Code = Alpha_Emp_Code,@Emp_Full_Name = Emp_Full_Name
	From	v0080_EMPloyee_MASTER
	Where	Emp_ID = @Old_Emp_ID And Cmp_ID = @Old_Cmp_ID 
	
	Select @Privilege_Type = PRIVILEGE_TYPE From V0090_EMP_PRIVILEGE_DETAILS where Cmp_ID = @Old_Cmp_ID And Emp_ID = @Old_Emp_ID
	SELECT @Salcycle_Name  = Name FROM T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Tran_Id = @Old_SalCycle_id And Cmp_id = @Old_Cmp_ID
	Select @Old_Login_Alias = Case when login_alias = '' then Login_Name ELSE login_alias END FROM T0011_LOGIN WITH (NOLOCK) Where Cmp_ID = @Old_Cmp_ID And Emp_ID = @Old_Emp_ID
	
	Select @Branch_ID = Branch_Id From T0030_BRANCH_MASTER WITH (NOLOCK) Where Upper(Branch_name) = Upper(@Branch_Name) And Cmp_ID = @New_Cmp_Id
	Select @Grd_ID = Grd_ID From T0040_GRADE_MASTER WITH (NOLOCK) Where UPPER(Grd_Name) = UPPER(@Grd_Name) And Cmp_ID = @New_Cmp_Id
	Select @Desig_Id = Desig_ID From T0040_DESIGNATION_MASTER WITH (NOLOCK) where UPPER(Desig_Name) = UPPER(@Desig_Name) And Cmp_ID = @New_Cmp_Id
	Select @Dept_ID = Dept_Id From T0040_DEPARTMENT_MASTER WITH (NOLOCK) where UPPER(Dept_Name) = UPPER(@Dept_Name) And Cmp_ID = @New_Cmp_Id
	Select @Shift_ID = Shift_ID From T0040_SHIFT_MASTER WITH (NOLOCK) where UPPER(Shift_Name)  =  UPPER(@Shift_Name) And Cmp_ID = @New_Cmp_Id
	Select @Type_ID = TYPE_ID From T0040_TYPE_MASTER WITH (NOLOCK) Where UPPER(Type_Name) = UPPER(@Type_Name) And Cmp_ID = @New_Cmp_Id
	Select @Vertical_ID = Vertical_ID From T0040_Vertical_Segment WITH (NOLOCK) Where UPPER(Vertical_Name) = UPPER(@Vertical_Name) And Cmp_ID = @New_Cmp_Id
	Select @New_SubVertical_ID = SubVertical_ID From T0050_SubVertical WITH (NOLOCK) Where UPPER(SubVertical_Name) = UPPER(@SubVertical_Name) And Cmp_ID = @New_Cmp_Id
	Select @New_SubBranch_ID = SubBranch_ID From T0050_SubBranch WITH (NOLOCK) Where UPPER(SubBranch_Name) = UPPER(@SubBranch_Name) And Cmp_ID = @New_Cmp_Id
	Select @New_Segment_ID = Segment_ID From T0040_Business_Segment WITH (NOLOCK) Where Upper(Segment_Name) = UPPER(@Segment_Name) And Cmp_ID = @New_Cmp_Id
	SELECT @New_SalCycle_id = Tran_Id FROM T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE UPPER(Name) = UPPER(@Salcycle_Name) And Cmp_id = @New_Cmp_ID

	
	
	If @Branch_ID = 0
		Begin
			--Raiserror('@@Employee Branch Not match In New Company.@@',16,2)				
			Set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Name='+ @Emp_Full_Name --+', Year='+cast(year(@Month_End_Date) as varchar)
			Exec Event_Logs_Insert 0,@Old_Cmp_ID,@Old_Emp_ID,@Login_ID,'Multi_Company_Transfer','Employee Branch Not match In New Company',@LogDesc,1,''
			Return -1	
		End
		
		
	If @Grd_ID = 0
		Begin
			---Raiserror('@@Employee grade Not match In New Company.@@',16,2)				
			Set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Name='+ @Emp_Full_Name --Date='+cast(MONTH(GETDATE()) as varchar)--+', Year='+cast(year(@Month_End_Date) as varchar)
			Exec Event_Logs_Insert 0,@Old_Cmp_ID,@Old_Emp_ID,@Login_ID,'Multi_Company_Transfer','Employee Grade Not match In New Company',@LogDesc,1,''
			Return -1	
		End	
		
	IF @Desig_Id = 0
		Begin
			--Raiserror('@@Employee Designation Not match In New Company.@@',16,2)
			Set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Name='+ @Emp_Full_Name--Date='+cast(MONTH(GETDATE()) as varchar)--+', Year='+cast(year(@Month_End_Date) as varchar)
			Exec Event_Logs_Insert 0,@Old_Cmp_ID,@Old_Emp_ID,@Login_ID,'Multi_Company_Transfer','Employee Designation Not match In New Company',@LogDesc,1,''
			Return -1	
		End
		
	If	@Shift_ID = 0
		Begin
			Select top 1 @Shift_ID = Shift_ID From T0040_SHIFT_MASTER WITH (NOLOCK) where Cmp_ID = @New_Cmp_Id
		End	
		
	If @Privilege_Type = 'ADMIN USER'
		Begin
			SELECT Top 1 @Privilege_id = Privilege_ID FROM T0020_PRIVILEGE_MASTER WITH (NOLOCK)where Privilege_Type = 0 and cmp_id = @New_Cmp_ID
		End
	Else --If @Privilege_Type = 'ESS USER'
		Begin	
			SELECT Top 1 @Privilege_id = Privilege_ID FROM T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Privilege_Type = 1 and cmp_id = @New_Cmp_ID
		End

	--Insert New Record In New Company
	Exec P0095_EMP_CMP_TRANSFER_INSERT @Tran_Id OUTPUT,@New_Emp_Id OUTPUT,@Old_Emp_ID,@New_Cmp_ID,@Old_Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Increment_Effective_Date,0,@Vertical_ID,@Increment_ID Output,@Old_Basic_Salary,@Old_Gross_salary,@Old_CTC,'','',@Privilege_id,'I',@New_SubVertical_ID,@New_Segment_ID,@New_SubBranch_ID,'',@Old_Login_Alias,@New_SalCycle_id,1
	
	--Old Employee Left Entry
	--Exec P0100_LEFT_EMP 0,@Old_Cmp_ID,@Old_Emp_ID,@Increment_Effective_Date,@Increment_Effective_Date,'Default Company Transfer','',0,'I',0,0,0,0,@Increment_Effective_Date,0,0
	
	--New Code for Left Date Added By Ramiz on 11/12/2017
	DECLARE @EMP_LEFT_DATE DATETIME
	SET @EMP_LEFT_DATE = DATEADD(DD , -1 , @Increment_Effective_Date)
	Exec P0100_LEFT_EMP 0,@Old_Cmp_ID,@Old_Emp_ID,@EMP_LEFT_DATE,@EMP_LEFT_DATE,'Default Company Transfer','',0,'I',0,0,0,0,@EMP_LEFT_DATE,0,0
	--ENDED--
	
	
	--''Leave Detail''--
	
	Declare @Leave_Id	   Numeric
	Declare @Old_Leave_Id  Numeric
	Declare @Old_Balance   Numeric(18,2)
	Declare @Leave_Name		varchar(250)
	Declare @CurTeam_Emp_Id numeric 
	declare @Leave_row_ID numeric 
	
	Set @Leave_row_ID = 0
	set @CurTeam_Emp_Id  = 0	
	
	Declare CusrLeave cursor for	                 
		select lt.Leave_ID From T0140_LEave_Transaction lt WITH (NOLOCK) inner join 
						(select max(For_Date)For_Date,Emp_ID,LEave_ID 
						  from T0140_LEave_Transaction WITH (NOLOCK)
						  where(emp_ID = @Old_Emp_ID And For_Date <=@Increment_Effective_Date) 
						  group by emp_ID,LeavE_ID )Q on lt.emp_ID =q.emp_ID and lt.leave_ID =q.leavE_ID and lt.for_Date =q.for_Date 
		Where lt.Emp_Id = @Old_Emp_ID And Cmp_Id = @Old_Cmp_Id 
				
		Open CusrLeave
			Fetch next from CusrLeave into @CurTeam_Emp_Id
			While @@fetch_status = 0                    
				Begin 
				 	Set @Leave_Id = 0
					Set @Old_Balance = 0
					Set @Leave_Name = ''
					
					Select @Leave_Name = Leave_Name From T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_ID = @CurTeam_Emp_Id And Cmp_ID = @Old_Cmp_ID
   				
	   				Select @Leave_Id = Leave_ID From T0040_LEAVE_MASTER WITH (NOLOCK) Where Upper(Leave_Name) = Upper(@Leave_Name) And Cmp_ID = @New_Cmp_Id
	   				Select @Old_Balance = Leave_Closing 
					From T0140_LEave_Transaction lt WITH (NOLOCK) inner join 
						(select max(For_Date)For_Date,Emp_ID,LEave_ID 
						  from T0140_LEave_Transaction WITH (NOLOCK)
						  where(Leave_ID = @CurTeam_Emp_Id And For_Date <=@Increment_Effective_Date And Emp_ID = @Old_Emp_ID) 
						  group by emp_ID,LeavE_ID )Q on lt.emp_ID =q.emp_ID and lt.leave_ID =q.leavE_ID and lt.for_Date =q.for_Date 
					Where lt.Emp_ID = @Old_Emp_ID and lt.Leave_ID = @CurTeam_Emp_Id And Cmp_Id = @Old_Cmp_Id 
			
				
	   				If @Leave_Id > 0 
	   					Begin
	   						Set @Leave_row_ID = @Leave_row_ID + 1
	   						
	   						Exec P0100_EMP_COMPANY_LEAVE_TRANSFER  0,0,@Tran_Id,@New_Cmp_ID,@New_Emp_Id,@Leave_ID,@Old_Balance,@Old_Emp_ID,@Old_Cmp_ID,@CurTeam_Emp_Id,@old_Balance,@Increment_Effective_Date,@Leave_row_ID,'I' 
						End
	   					
					fetch next from CusrLeave into @CurTeam_Emp_Id	
				End
		Close CusrLeave                    
	Deallocate CusrLeave

	--''Leave Detail''--
	
	--''Loan Detail''--
	
	Declare @Loan_Id		Numeric
	Declare @Old_Loan_Id	Numeric
	Declare @Loan_Name		Varchar(250)
	Declare @CurLoan_Id		Numeric 
	declare @Loan_row_ID numeric 
	
	Set @Loan_row_ID = 0
	set @CurLoan_Id  = 0	
	
	Declare CusrLoan cursor for	                 
		Select lt.Loan_ID From T0140_LOAN_TRANSACTION lt WITH (NOLOCK) inner join 
			(Select max(For_Date) For_Date,Emp_ID,Loan_ID from T0140_LOAN_TRANSACTION WITH (NOLOCK)
			where Emp_ID = @Old_Emp_ID  And For_Date <=@Increment_Effective_Date
			group by Emp_ID,Loan_ID) q on lt.Emp_ID=q.Emp_ID And lt.Loan_ID=q.Loan_ID and lt.For_Date=q.For_Date 
		Where lt.Emp_ID = @Old_Emp_ID
		order by loan_id desc
				
		Open CusrLoan
			Fetch next from CusrLoan into @CurLoan_Id
			While @@fetch_status = 0                    
				Begin 
				 	Set @Loan_Id = 0
					Set @Old_Balance = 0
					Set @Loan_Name = ''
					
					Select @Loan_Name = Loan_Name From T0040_LOAN_MASTER WITH (NOLOCK) Where Loan_ID = @CurLoan_Id And Cmp_ID = @Old_Cmp_ID
	   				
	   				Select @Loan_Id = Loan_ID From T0040_LOAN_MASTER WITH (NOLOCK) Where Upper(Loan_Name) = Upper(@Loan_Name) And Cmp_ID = @New_Cmp_Id
	   				
	   				Select @Old_Balance = Loan_Closing
					From T0140_LOAN_TRANSACTION lt WITH (NOLOCK) inner join 
						(Select max(For_Date) For_Date,Emp_ID,Loan_ID 
						From T0140_LOAN_TRANSACTION WITH (NOLOCK) where Emp_ID = @Old_Emp_ID And Loan_ID = @CurLoan_Id And For_Date <=@Increment_Effective_Date
						group by Emp_ID,Loan_ID) q on lt.Emp_ID=q.Emp_ID and lt.Loan_ID=q.Loan_ID and lt.For_Date=q.For_Date 
					Where lt.Emp_ID = @Old_Emp_ID And lt.Loan_ID = @CurLoan_Id

	   				If @Loan_Id > 0 
	   					Begin
	   						Set @Loan_row_ID = @Loan_row_ID + 1
	   						
	   						Exec P0100_EMP_COMPANY_LOAN_TRANSFER  0,0,@Tran_Id,@New_Cmp_ID,@New_Emp_Id,@Loan_Id,@Old_Balance,@Old_Emp_ID,@Old_Cmp_ID,@CurLoan_Id,@old_Balance,@Increment_Effective_Date,@Loan_row_ID,0,'I' 
						End
	   					
					fetch next from CusrLoan into @CurLoan_Id	
				End
		Close CusrLoan                    
	Deallocate CusrLoan

	--''Loan Detail''--
	
	--''Advance Detail''--
			Set @Old_Balance = 0
			
			Select @Old_Balance = Adv_closing
			From T0140_Advance_Transaction WITH (NOLOCK) 
			WHERE Adv_closing > 0 And Emp_id = @Old_Emp_ID AND Cmp_ID = @Old_Cmp_ID 
				AND For_date = (SELECT MAX(For_Date) FROM T0140_Advance_Transaction WITH (NOLOCK)
								WHERE emp_id = @Old_Emp_ID AND Cmp_ID = @Old_Cmp_ID AND For_Date <= @Increment_Effective_Date)

			If @Old_Balance > 0
				Begin
					Exec P0100_EMP_COMPANY_ADVANCE_TRANSFER 0,0,@Tran_Id,@New_Emp_Id,@New_Cmp_ID,@Increment_Effective_Date,@Old_Balance,@Old_Balance,@Old_Emp_ID,@Old_Cmp_ID,'I' 
				End
	--''Advance Detail''--
	
	--''Allowance/Deduction Detail''--
	
	Declare @AD_ID				Numeric
	Declare @AD_Name			Varchar(250)
	Declare @CurAD_Id			Numeric 
	Declare @E_AD_FLAG			Char(1)
	Declare @E_AD_MODE			Varchar(10)
	Declare @E_AD_PERCENTAGE	numeric(5,2)
	Declare @E_AD_AMOUNT		numeric(18,2)
	Declare @Old_AD_MODE		Varchar(10)
	Declare @EMP_GRADE			Numeric
	--Declare @Ad_Max_Limit		Numeric(18,2)
	--Declare @New_Basic			Numeric(18,2)
	--Declare @New_Gross			Numeric(18,2) 
	--Declare @New_CTC			numeric(18,2)
	
	Set @CurAD_Id	= 0
	
	DELETE FROM T0100_EMP_EARN_DEDUCTION WHERE EMP_ID = @New_Emp_Id AND INCREMENT_ID = @Increment_ID
	
	
	Declare CusrAllow cursor for	                 
		Select Ad_ID From V0100_EMP_EARN_DEDUCTION Where Emp_ID = @Old_Emp_ID
				
		Open CusrAllow
			Fetch next from CusrAllow into @CurAD_Id
			While @@fetch_status = 0                    
				Begin 
				 	
				 	Set @AD_ID				= 0
					Set @AD_Name			= ''
					Set @E_AD_FLAG			= ''
					Set @E_AD_MODE			= ''
					Set @E_AD_PERCENTAGE    = 0
					Set @E_AD_AMOUNT		= 0
					Set @Old_AD_MODE		= ''
					Set @EMP_GRADE			= 0
					
					
					Select @AD_Name = AD_NAME From T0050_AD_MASTER WITH (NOLOCK) Where AD_ID = @CurAD_Id And Cmp_ID = @Old_Cmp_ID
	   				
	   				Select @AD_ID = AD_ID , @E_AD_FLAG = AD_FLAG From T0050_AD_MASTER WITH (NOLOCK) Where Upper(AD_NAME) = Upper(@AD_Name) And Cmp_ID = @New_Cmp_Id
	   				
	   				Select @EMP_GRADE = New_Grd_ID From T0095_EMP_COMPANY_TRANSFER WITH (NOLOCK) Where Tran_Id = @Tran_Id
	   				
	   				Select @E_AD_MODE=AD_MODE
					From T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) Where cmp_id = @New_Cmp_ID And Ad_ID = @AD_ID And Grd_ID=@EMP_GRADE
					
	   				Select @E_AD_AMOUNT = E_AD_AMOUNT ,@E_AD_PERCENTAGE = E_AD_PERCENTAGE,@E_AD_FLAG = E_AD_FLAG,@Old_AD_MODE = E_AD_MODE
	   				From V0100_EMP_EARN_DEDUCTION 
	   				Where Emp_ID = @Old_Emp_ID And AD_ID = @CurAD_Id

	   				If @AD_ID > 0
	   					Begin
	   						Exec P0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION  0,@Tran_Id,@New_Emp_Id,@New_Cmp_ID,@AD_ID,@Increment_ID,@Increment_Effective_Date,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@Old_Emp_ID,@Old_Cmp_ID,@CurAD_Id,@Old_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,0,'I'
	   					End
	   					
					fetch next from CusrAllow into @CurAD_Id	
				End
		Close CusrAllow                    
	Deallocate CusrAllow

	--''Allowance/Deduction Detail''--
	
RETURN
