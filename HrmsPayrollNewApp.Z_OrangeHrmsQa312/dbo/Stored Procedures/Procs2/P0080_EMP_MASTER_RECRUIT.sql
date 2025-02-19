


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0080_EMP_MASTER_RECRUIT]
	@Emp_ID			numeric(18,0) output
   ,@Cmp_ID			numeric(18,0)
   ,@Branch_ID		numeric(18,0)
   ,@Cat_ID			numeric(18,0)
   ,@Grd_ID			numeric(18,0)
   ,@Dept_ID		numeric(18,0)
   ,@Desig_Id		numeric(18,0)
   ,@Type_ID		numeric(18,0)
   ,@Shift_ID		numeric(18,0)
   ,@Bank_ID		numeric(18,0)
   ,@Increment_ID	numeric(18,0) output
   ,@Emp_code		numeric(18,0)
   ,@Initial		varchar(10)
   ,@Emp_First_Name varchar(100)
   ,@Emp_Second_Name varchar(100)
   ,@Emp_Last_Name	varchar(100)
   ,@Curr_ID		numeric(18,0)
   ,@Date_Of_Join	datetime
   ,@SSN_No			varchar(30)
   ,@SIN_No			varchar(30)
   ,@Dr_Lic_No		varchar(30)
   ,@Pan_No			varchar(30)
   ,@Date_Of_Birth  DATETIME = null
   ,@Marital_Status varchar(20)
   ,@Gender			char(1)
   ,@Dr_Lic_Ex_Date DATETIME = NULL
   ,@Nationality	varchar(20)
   ,@Loc_ID			numeric(18,0)
   ,@Street_1		varchar(250)
   ,@City			varchar(30)
   ,@State			varchar(20)
   ,@Zip_code		varchar(20)
   ,@Home_Tel_no	varchar(30)
   ,@Mobile_No		varchar(30)
   ,@Work_Tel_No	varchar(30)
   ,@Work_Email		varchar(50)
   ,@Other_Email	varchar(50)
   ,@Present_Street varchar(250)
   ,@Present_City   varchar(30)
   ,@Present_State  varchar(30)
   ,@Present_Post_Box varchar(20)
   ,@Emp_Superior   numeric(18)
   ,@Basic_Salary	numeric(18,2)
   ,@Image_Name		varchar(100)
   ,@Wages_Type		varchar(10)
   ,@Salary_Basis_On varchar(10)
   ,@Payment_Mode	varchar(20)
   ,@Inc_Bank_AC_No	varchar(20)
   ,@Emp_OT			numeric(18)
   ,@Emp_OT_Min_Limit	varchar(10)
   ,@Emp_OT_Max_Limit	varchar(10)
   ,@Emp_Late_mark	Numeric(18)
   ,@Emp_Full_PF	Numeric(18)
   ,@Emp_PT			Numeric(18)
   ,@Emp_Fix_Salary	Numeric(18)
   ,@tran_type		char(1)
   ,@Gross_salary	numeric(22)=0
   ,@Tall_Led_Name varchar(250)
   ,@Religion varchar(50)
   ,@Height  varchar(50)
   ,@Mark_Of_Idetification varchar(250)
   ,@Dispencery varchar(50)
   ,@Doctor_name varchar(100)
   ,@DispenceryAdd varchar(250)
   ,@Insurance_No varchar(50)
   ,@Is_Gr_App tinyint
   ,@Is_Yearly_Bonus numeric(5, 2)
   ,@Yearly_Leave_Days numeric(7, 2)
   ,@Yearly_Leave_Amount numeric(7, 2)
   ,@Yearly_Bonus_Per numeric(5, 2)
   ,@Yearly_Bonus_Amount numeric(7, 2)
   ,@Emp_Late_Limit varchar(10)
   ,@Late_Dedu_Type varchar(10)
   ,@Emp_Part_Time  numeric(10)
   ,@Emp_Confirmation_date dateTime
   ,@Is_On_Probation numeric(1,0)
   ,@Tally_Led_ID numeric(18,0)
   ,@Blood_Group varchar(10)
   ,@Probation numeric(2,0)
   ,@enroll_No numeric(18,0)
   ,@Dep_Reminder tinyint=1
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Cat_ID = 0
		set @Cat_ID = null
    if @Dept_ID = 0
		set @Dept_ID = null 
	if @Desig_Id = 0
		set @Desig_Id = null
	if @Type_ID =0
		set @Type_ID= null
	if @Loc_ID =0
		set @Loc_ID = null
	if @Curr_ID =0
		set @Curr_ID = null
	if @Bank_ID =0
		set @Bank_ID = null
	if @Basic_Salary =0 
		set @Basic_Salary = null
		
	if  @Tally_Led_ID	 = 0
	 set @Tally_Led_ID	=null
	   
	if @Date_Of_Birth =  ''
		set  @Date_Of_Birth = null
	if @Dr_Lic_Ex_Date = ''
		set @Dr_Lic_Ex_Date = null
	if @Wages_Type = ''
		set @Wages_Type= 'Monthly'
	if @Salary_Basis_On =''
		set @Salary_Basis_On ='Day'
	if @Payment_Mode =''
		set @Payment_Mode= 'Cash'
	if @Inc_Bank_AC_No = ''
		set @Inc_Bank_AC_No = NULL
	if @Emp_OT_Min_Limit = ''
		set @Emp_OT_Min_Limit = NULL	
	if @Emp_OT_Max_Limit = ''
		set @Emp_OT_Max_Limit = NULL
	if @Emp_Superior = 0 
		set @Emp_Superior =NULL	
		
	if @Emp_Confirmation_date = '' 
	  set	@Emp_Confirmation_date=null
	if @Increment_ID= 0	
		set @Increment_ID= null
	if @Image_Name = ''
		Begin
			set @Image_Name = '0.jpg'	
		End
	Else		
		Begin
			set @Image_Name = REPLACE(@Image_Name,'?',''); --In App file not saving with ? symobol but in DB its saved so replace with blank
		End	--Added this code by Sumit and Ramiz for replacing unused character from image name error coming on Home page
				
		

	Declare @Emp_Full_Name as varchar(250)
	Declare @loginname as varchar(50)
	Declare @Domain_Name as varchar(50)
	Declare @old_Join_Date as datetime 
	Declare @Default_Weekof as varchar(50)	
	Declare @IS_OT As Numeric(18)
    Declare @IS_PT As Numeric(18)
    Declare @IS_PF As Numeric(18)
    Declare @IS_LATE_MARK As Numeric(18)
    declare @G_FOR_DATE as DATETIME	
    Declare @For_Date as DateTime
    set @For_Date =getdate()
    
    
    if @Emp_Code =0 
		begin
		
			select @Emp_code = isnull(max(Emp_Code),0) + 1 from T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID =@CMP_ID
		end
    
    
	Select @Domain_Name = Domain_Name From T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
	if substring(@Domain_Name,1,1) <> '@'	
		set @Domain_Name = '@' + @Domain_Name
	
	
	set @Emp_Full_Name = @Initial + '' + @Emp_First_Name + ' ' + @Emp_Second_Name + ' ' + @Emp_Last_Name 


						
	If @tran_type  = 'I'
		Begin
		     
		        
				If Exists(select Emp_ID From T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and Emp_code = @Emp_Code )
					begin
					
						set @Emp_ID = 0
						return  
					end
				
				select @Emp_ID = Isnull(max(Emp_ID),0) + 1 	From T0080_EMP_MASTER WITH (NOLOCK)
			
				
				INSERT INTO T0080_EMP_MASTER
				                      (Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name, 
				                      Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality, 
				                      Loc_ID, Street_1, City, State, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email,Emp_Superior, Basic_Salary, Image_Name,Emp_Full_Name,Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box,enroll_No,Blood_Group,Is_Gr_App,Is_Yearly_Bonus,Probation)
				VALUES     (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,@Emp_Last_Name,@Curr_ID,@Date_Of_Join,@SSN_No,@SIN_No,@Dr_Lic_No,@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,@Dr_Lic_Ex_Date,@Nationality,@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Emp_Superior,@Basic_Salary,@Image_Name,@Emp_Full_Name,'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@enroll_No,@Blood_Group,@Is_Gr_App,@Is_Yearly_Bonus,@Probation)
				
				
				select @Default_Weekof = Default_Holiday from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
				set @loginname = cast(@Emp_Code as varchar(10)) + @Domain_Name				  
				EXEC p0011_Login 0,@Cmp_Id,@loginname,'VuMs/PGYS74=',@Emp_ID,NULL,NULL,'I',2
				EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,'','',0
				
					select @G_FOR_DATE = max(for_date) from T0040_GENERAL_SETTING WITH (NOLOCK) where branch_id= @Branch_ID and for_date<= getdate()
				select @IS_OT = IS_OT ,@IS_PT = IS_PT ,@IS_PF= IS_PF ,@IS_LATE_MARK =IS_LATE_MARK from T0040_GENERAL_SETTING WITH (NOLOCK) where branch_id= @Branch_ID and for_date= @G_FOR_DATE
				EXEC P0095_INCREMENT_INSERT	@Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join output,@Date_OF_Join,@Payment_Mode,@Inc_Bank_AC_No,@IS_OT,@Emp_OT_Min_Limit,0,0,0,0,0,'',@IS_LATE_MARK,@IS_PF,@IS_PT,@Emp_Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_Part_Time,1,0,@Yearly_Bonus_Amount,Null,@Dep_Reminder,1
				
				
				If isnull(@Default_Weekof,'') <> ''
				
				EXEC P0100_WEEKOFF_ADJ 0,@Cmp_ID,@Emp_ID,@Date_Of_Join,@Default_Weekof,'','','','',0,'I'
				---exec P0100_EMP_GRADEWISE_ALLOWANCE @Cmp_ID,@Emp_ID,@Grd_ID,@Date_Of_Join,@Increment_ID
				EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@For_Date,null	
		End
	Else if @Tran_Type = 'U'
		begin
			
				If Exists(select Emp_ID From T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and Emp_code = @Emp_Code and Emp_ID <> @Emp_ID)
					begin
						set @Emp_ID = 0
						return  
					end
					
				
					select @old_Join_Date = DAte_of_join ,@Increment_ID = Increment_ID From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID
				
					
					UPDATE    T0080_EMP_MASTER
					SET              Cmp_ID = @Cmp_ID, Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, Desig_Id = @Desig_ID, 
										  Type_ID = @Type_ID, Shift_ID = @Shift_ID, Bank_ID = @Bank_ID, Emp_code = @Emp_code, Initial = @Initial ,Emp_First_Name = @Emp_First_Name, 
										  Emp_Second_Name = @Emp_Second_Name, Emp_Last_Name = @Emp_Last_Name, Curr_ID = @Curr_ID, Date_Of_Join = @Date_Of_Join, 
										  SSN_No = @SSN_No, SIN_No = @SIN_No, Dr_Lic_No = @Dr_Lic_No, Pan_No = @Pan_No, Date_Of_Birth = @Date_Of_Birth, 
										  Marital_Status = @Marital_Status, Gender = @Gender, Dr_Lic_Ex_Date = @Dr_Lic_Ex_Date, Nationality = @Nationality, Loc_ID = @Loc_ID, 
										  Street_1 = @Street_1, City = @City, State = @State, Zip_code = @Zip_code, Home_Tel_no = @Home_Tel_no, 
										  Mobile_No = @Mobile_No, Work_Tel_No = @Work_Tel_No, Work_Email = @Work_Email, Other_Email = @Other_Email, 
										  Emp_Superior=@Emp_Superior,Basic_Salary = @Basic_Salary,Emp_Full_Name  = @Emp_Full_Name,Present_Street=@Present_Street,Present_City=@Present_City,Present_State=@Present_State,Present_Post_Box=@Present_Post_Box  
										  ,enroll_No  = @enroll_No 
										  
									    ,Tally_Led_Name =  @Tall_Led_Name 
										,Religion=@Religion 
										,Height=@Height  
										,Emp_Mark_Of_Identification=@Mark_Of_Idetification 
										,Despencery=@Dispencery
									    ,Doctor_Name=@Doctor_name 
										,DespenceryAddress=@DispenceryAdd 
										,Insurance_No=@Insurance_No 
										,Is_Gr_App=@Is_Gr_App
										,Is_Yearly_Bonus=@Is_Yearly_Bonus
										,Yearly_Leave_Days=@Yearly_Leave_Days
										,Yearly_Leave_Amount =@Yearly_Leave_Amount
										,Yearly_Bonus_Per=@Yearly_Bonus_Per
										,Yearly_Bonus_Amount=@Yearly_Bonus_Amount
										,Emp_Confirm_Date = @Emp_Confirmation_date
										,Is_On_Probation =@Is_On_Probation
										,Tally_Led_ID=@Tally_Led_ID
										,Blood_Group=@Blood_Group
										,Probation=@Probation
										
					
					WHERE     (Emp_ID = @Emp_ID)
					
					set @loginname = cast(@Emp_Code as varchar(10))  +  @Domain_Name
					
					Update T0011_Login
					set Login_Name = @loginname
					   -- Branch_ID = @Branch_Id
					where Emp_ID = @Emp_ID 
					
					
					SET @Increment_ID  =ISNULL(@Increment_ID ,0)
					EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,@Old_Join_Date
					
					EXEC P0095_INCREMENT_INSERT	@Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join ,@Date_OF_Join,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,0,0,0,0,'',@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_Late_Limit,@Late_Dedu_type,@Emp_Part_Time,1,0,@Yearly_Bonus_Amount,Null,@Dep_Reminder,1
					
					Select @for_date = increment_effective_date from T0095_Increment WITH (NOLOCK) where Increment_ID=@Increment_ID
					
					EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@for_date,@Old_Join_Date
							                      
					
		   end
	Else If @Tran_Type = 'D'
		Begin 
			
			
			Update T0080_EMP_MASTER  Set Increment_ID = Null Where Emp_ID = @Emp_ID  
			
			Delete From T0090_EMP_CHILDRAN_DETAIL			Where		Emp_ID	= @Emp_ID 
			Delete From T0090_EMP_CONTRACT_DETAIL			Where		Emp_ID	= @Emp_ID 
			Delete From T0090_EMP_DEPENDANT_DETAIL			Where		Emp_ID	= @Emp_ID
			Delete From T0090_EMP_DOC_DETAIL				Where		Emp_ID  = @Emp_ID 
			Delete From T0090_EMP_EMERGENCY_CONTACT_DETAIL	Where		Emp_ID  = @Emp_ID 
			Delete From T0090_EMP_EXPERIENCE_DETAIL			Where		Emp_ID  = @Emp_ID 
			Delete From T0090_EMP_IMMIGRATION_DETAIL		Where		Emp_ID  = @Emp_ID 
			Delete From T0090_EMP_LANGUAGE_DETAIL			Where		Emp_ID  = @emp_ID 
			Delete From T0090_EMP_LICENSE_DETAIL			Where		Emp_ID  = @Emp_ID
			Delete From T0090_EMP_QUALIFICATION_DETAIL		Where		Emp_ID	= @Emp_ID
			Delete From T0090_EMP_REPORTING_DETAIL			Where		Emp_ID	= @Emp_ID
			Delete From T0090_EMP_SKILL_DETAIL				Where		Emp_ID	= @Emp_ID
			
			DELETE FROM T0110_EMP_LEFT_JOIN_TRAN			WHERE		EMP_ID	= @EMP_ID
			DELETE FROM T0100_EMP_EARN_DEDUCTION			WHERE		EMP_ID	= @EMP_ID
			DELETE FROM T0095_INCREMENT						WHERE		EMP_ID = @EMP_ID
			DELETE FROM T0100_WEEKOFF_ADJ					WHERE		EMP_ID = @EMP_ID
			DELETE FROM T0100_EMP_SHIFT_DETAIL				WHERE		EMP_ID = @EMP_ID
			DELETE FROM T0140_ADVANCE_TRANSACTION			WHERE		EMP_ID = @EMP_iD 
			DELETE FROM T0140_LOAN_TRANSACTION			WHERE		EMP_ID = @EMP_iD 
			DELETE FROM T0140_CLAIM_TRANSACTION			WHERE		EMP_ID = @EMP_iD 
			DELETE FROM T0140_LEAVE_TRANSACTION			WHERE		EMP_ID = @EMP_iD 
			
			Delete From T0011_Login							where		Emp_ID  = @Emp_ID
			DELETE FROM T0080_EMP_MASTER	WHERE     Emp_ID = @Emp_ID
		End

	

	RETURN




