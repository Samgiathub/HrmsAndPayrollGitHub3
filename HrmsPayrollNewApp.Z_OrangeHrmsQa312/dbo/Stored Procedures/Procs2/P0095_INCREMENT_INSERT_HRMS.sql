



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_INCREMENT_INSERT_HRMS]
	 @Increment_ID	numeric(18, 0) output
	,@Emp_ID	numeric(18, 0)
	,@Cmp_ID	numeric(18, 0)
	,@Appr_Int_ID	numeric(18, 0)
	,@Increment_Effective_Date	datetime 
	,@Increment_Amount	 numeric(18, 2)
	,@Increment_Amt_Gross numeric(18, 2)
	,@App_Status tinyint
	,@Status  tinyint  --Ripal 16July2014
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Status  = 0 OR @Status = 2  --Status added by Ripal 23July2014 Added by Ripal 16July2014
Begin
	Update dbo.t0090_hrms_appraisal_initiation set 
		t0090_hrms_appraisal_initiation.Status=@App_Status 
		where Appr_Int_ID=@Appr_Int_ID
	
	Update dbo.t0090_hrms_appraisal_initiation_detail set 
		Is_Accept=@Status
		where Emp_ID=@Emp_ID And  Appr_Int_ID=@Appr_Int_ID
	 
	Return
End

	set nocount on 
	If @Increment_Amt_Gross = 0
		set @Increment_Amt_Gross = null 	
	declare @Branch_ID	numeric(18, 0)
	declare @Cat_ID	numeric(18, 0)
	declare @Grd_ID	numeric(18, 0)
	declare @Dept_ID	numeric(18, 0)
	declare @Desig_Id	numeric(18, 0)
	declare @Type_ID	numeric(18, 0)
	declare @Bank_ID	numeric(18, 0)
	declare @Curr_ID	numeric(18, 0)
	declare @Wages_Type	varchar(10)
	declare @Salary_Basis_On	varchar(10)
	declare @Basic_Salary	numeric(18, 2)
	declare @Gross_Salary	numeric(18, 2)
	declare @Increment_Type	varchar(30)
	declare @Increment_Date	datetime
	declare @Payment_Mode	varchar(20)
	declare @Inc_Bank_AC_No	varchar(20)
	declare @Emp_OT	numeric(18, 0)
	declare @Emp_OT_Min_Limit	varchar(10)
	declare @Emp_OT_Max_Limit	varchar(10)
	declare @Increment_Per	numeric(18, 2)
	declare @Pre_Basic_Salary	numeric(18, 2)
	declare @Pre_Gross_Salary	numeric(18, 2)
	declare @Increment_Comments	varchar(250)
	declare @Emp_Late_mark	Numeric
	declare @Emp_Full_PF	Numeric
	declare @Emp_PT	Numeric
	declare @Emp_Fix_Salary	Numeric
	declare @Emp_Late_Limit  varchar(10)
    declare @Late_Dedu_type  varchar(10)
    declare @Emp_part_Time numeric(1,0)
	declare @Is_Master_Rec		tinyint 	-- Define this parameter in only Insert statement
	declare @Login_ID			numeric(18)
	declare @Yearly_Bonus_Amount numeric(22,2)
	declare @Deputation_End_Date datetime
	declare @Dep_Reminder tinyint
	declare @Is_Emp_Master tinyint
	
		
	
	set @Increment_Type='Increment'
	set 	@Increment_Date=getdate()
	set @Is_Emp_Master=0
	
	select @Branch_ID=Branch_ID,@Cat_ID=Cat_ID,@Grd_ID=Grd_ID,@Dept_ID=Dept_ID,@Desig_Id=Desig_Id,@Type_ID=Type_ID,@Bank_ID=Bank_ID,@Curr_ID=Curr_ID,
	@Wages_Type=Wages_Type,@Salary_Basis_On=Salary_Basis_On,@Basic_Salary=Basic_Salary,@Gross_Salary=Gross_Salary,@Payment_Mode=Payment_Mode,
	@Inc_Bank_AC_No=Inc_Bank_AC_No,@Emp_OT=Emp_OT,		
	@Emp_OT_Min_Limit=Emp_OT_Min_Limit,
	@Emp_OT_Max_Limit=Emp_OT_Max_Limit,
	@Increment_Per=Increment_Per,
	@Pre_Basic_Salary=Basic_Salary,
	@Pre_Gross_Salary=Gross_Salary,
	@Increment_Comments=Increment_Comments,
	@Emp_Late_mark=Emp_Late_mark,
	@Emp_Full_PF=Emp_Full_PF,
	@Emp_PT=Emp_PT,
	@Emp_Fix_Salary=Emp_Fix_Salary,
	@Emp_Late_Limit=Emp_Late_Limit,
    @Late_Dedu_type =Late_Dedu_type,
    @Emp_part_Time=Emp_part_Time,
	@Login_ID=Login_ID,
	@Yearly_Bonus_Amount=Yearly_Bonus_Amount,
	@Deputation_End_Date=Deputation_End_Date,
	@Dep_Reminder=is_Deputation_Reminder
	 from dbo.V0095_INCREMENT_HRMS where Emp_ID=@Emp_ID and Cmp_id=@Cmp_ID
	And  Increment_ID in (select Max(Increment_ID) from dbo.T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID)
	
	set @Basic_Salary=isnull(@Increment_Amount,0)+ isnull(@Pre_Basic_Salary,0)
	set @Gross_Salary=isnull(@Increment_Amt_Gross,0)+isnull(@Pre_Gross_Salary,0)
	
	if @Deputation_End_Date = ''  
		SET @Deputation_End_Date  = NULL 

	if @Emp_OT_Max_Limit ='0:' or @Emp_OT_Max_Limit ='00:' or @Emp_OT_Max_Limit ='0'
		set @Emp_OT_Max_Limit ='00:00'
	
	if @Emp_OT_Min_Limit ='0:' or @Emp_OT_Min_Limit ='00:' or @Emp_OT_Min_Limit ='0'
		set @Emp_OT_Min_Limit ='00:00'
		
	If @Dept_ID = 0
		set @Dept_ID = null 
	   If @Desig_Id = 0
		set @Desig_Id = null 
	IF @Cat_ID = 0
		set @Cat_ID = null	
	IF @Bank_ID = 0
		set @Bank_ID= null
	IF @Type_ID = 0
		SET @Type_ID = NULL
	IF @Curr_ID = 0
		set @Curr_ID = null	
	
	if @Login_ID =0
		set @Login_ID = null
		
	Declare @PT_Amount			numeric 
	Declare @AD_Other_Amount	numeric 
	Declare @Max_Increment_ID	numeric 
	Declare @Max_Shift_ID numeric
	
	set @PT_Amount = 0
	
	if @Emp_PT = 1
		begin
				Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from dbo.T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
				set @AD_Other_Amount = @Basic_Salary + isnull(@AD_Other_Amount,0)
				
			Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Increment_effective_Date,@AD_Other_Amount,@PT_Amount output,'',@Branch_ID
		end
	
	
	If Isnull(@Increment_ID,0) = 0
		begin
			
				IF EXISTS(Select Increment_ID From dbo.T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_ID and Increment_effective_Date= @Increment_effective_Date )
					Begin
						--Raiserror('Same Date Entry Exists',16,2)
					
						Return
					End
					
				else if Exists(Select Increment_ID From dbo.T0095_INCREMENT  WITH (NOLOCK) Where Emp_ID = @Emp_ID and Increment_effective_Date > @Increment_effective_Date)
					begin
					
						--Raiserror('Max Date Entry Exists',16,2)
						return
					end
				
				select @Increment_ID = isnull(max(Increment_ID),0) + 1 From dbo.T0095_INCREMENT WITH (NOLOCK)
				
				INSERT INTO dbo.T0095_INCREMENT
				                      (Increment_ID,Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,Type_ID,Bank_ID,Curr_ID,Wages_Type,Salary_Basis_On,Basic_Salary,Gross_Salary,Increment_Type,Increment_Date,Increment_Effective_Date,Payment_Mode,Inc_Bank_AC_No,Emp_OT,Emp_OT_Min_Limit,Emp_OT_Max_Limit,Increment_Per,Increment_Amount,Pre_Basic_Salary,Pre_Gross_Salary,Increment_Comments,Emp_Late_mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_PT_Amount,Is_Master_Rec,Login_ID,System_Date,Yearly_Bonus_Amount,Deputation_End_Date,Appr_Int_ID)
							VALUES	  (@Increment_ID,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary,@Increment_Type,@Increment_Date,@Increment_Effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Pre_Basic_Salary,@Pre_Gross_Salary,@Increment_Comments,@Emp_Late_mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@PT_Amount,@Is_Master_Rec,@Login_ID,getdate(),@Yearly_Bonus_Amount,@Deputation_End_Date,@Appr_Int_ID)
				    
				
		end
	else 
		begin
				If Exists (select Emp_ID From dbo.T0095_INCREMENT WITH (NOLOCK) Where Increment_ID =@Increment_ID and isnull(Is_Master_Rec,0) = 1 )
					begin 
						if isnull(@Is_Emp_Master,0)=1
							Begin
										UPDATE    dbo.T0095_INCREMENT
									SET       Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
											  Desig_Id = @Desig_Id, Type_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
											  Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, Increment_Type = @Increment_Type, 
											  Increment_Date = @Increment_Date, Increment_Effective_Date = @Increment_Effective_Date, Payment_Mode = @Payment_Mode, 
											  Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary, 
											  Increment_Comments =@Increment_Comments ,Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
											  Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
											  Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
											  Login_ID = @Login_ID,System_Date =getdate(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Is_Deputation_Reminder=@Dep_Reminder
									WHERE     Increment_ID = @Increment_ID  and Emp_ID = @Emp_ID
							End 
						else
							BEgin
												UPDATE    dbo.T0095_INCREMENT
											SET       Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
													  Desig_Id = @Desig_Id, Type_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
													  Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, Increment_Type = @Increment_Type, 
													  Increment_Date = @Increment_Date, Increment_Effective_Date = @Increment_Effective_Date, Payment_Mode = @Payment_Mode, 
													  Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary, 
													  Increment_Comments =@Increment_Comments ,Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
													  Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
													  Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
													  Login_ID = @Login_ID,System_Date =getdate(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Deputation_End_Date=@Deputation_End_Date,Is_Deputation_Reminder=@Dep_Reminder
											WHERE     Increment_ID = @Increment_ID  and Emp_ID = @Emp_ID
							End	
						
					end
				else
					begin

						select @Increment_Effective_Date = Increment_Effective_Date  , @Increment_Date = Increment_Date From dbo.T0095_INCREMENT WITH (NOLOCK) Where Increment_ID =@Increment_ID

						Select @Pre_Basic_Salary = Basic_Salary ,@Pre_Gross_Salary = Gross_Salary 
								from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join (select Emp_ID ,max(Increment_Effective_Date)Increment_Effective_Date From dbo.T0095_INCREMENT WITH (NOLOCK)
																	where Emp_ID =@Emp_ID and Increment_Effective_Date < @Increment_Effective_Date group by Emp_ID )q on
																		I.Emp_ID= q.Emp_ID and i.Increment_Effective_Date = q.Increment_Effective_Date
						
						Set 	@Increment_Amount = @Basic_Salary - @Pre_Basic_Salary
						if  isnull(@Is_Emp_Master,0)=1
							BEgin
												UPDATE    dbo.T0095_INCREMENT
										SET       Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
												  Desig_Id = @Desig_Id, Type_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
												  Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary,Payment_Mode = @Payment_Mode, 
												  Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary ,
												  Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
												  Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
												  Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
												  Login_ID = @Login_ID,System_Date =getdate(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Is_Deputation_Reminder=@Dep_Reminder
										WHERE     Increment_ID = @Increment_ID  and Emp_ID = @Emp_ID
							End
						else
							Begin
													UPDATE    dbo.T0095_INCREMENT
											SET       Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
													  Desig_Id = @Desig_Id, Type_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
													  Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary,Payment_Mode = @Payment_Mode, 
													  Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary ,
													  Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
													  Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
													  Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
													  Login_ID = @Login_ID,System_Date =getdate(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Deputation_End_Date=@Deputation_End_Date,Is_Deputation_Reminder=@Dep_Reminder
											WHERE     Increment_ID = @Increment_ID  and Emp_ID = @Emp_ID
							End
							
							
						
					end
				
		end
	
Declare @AD_TRAN_ID Numeric(18,0)  
Declare @AD_ID Numeric(18,0)
Declare @E_AD_FLAG char(1)
Declare @E_AD_MODE varchar(10)
Declare @E_AD_PERCENTAGE numeric(5,2)  
Declare @E_AD_AMOUNT numeric(18,2)
Declare @E_AD_MAX_LIMIT numeric(18,0)
Declare CURALLODEDUCTION cursor for                      

select AD_ID,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT  from dbo.T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where emp_id=@emp_id And Cmp_id=@Cmp_id And increment_id in(select Max(increment_id) from dbo.T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where emp_id=@emp_id And Cmp_id=@Cmp_id group by emp_id)
 open CURALLODEDUCTION                        
	fetch next from CURALLODEDUCTION into @AD_ID,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT
		while @@fetch_status = 0                      
		begin     
				SELECT @AD_TRAN_ID = Isnull(max(AD_TRAN_ID),0) + 1 From dbo.T0100_EMP_EARN_DEDUCTION WITH (NOLOCK)
   				EXEC P0100_EMP_EARN_DEDUCTION @AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@Increment_ID,@Increment_Effective_Date,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,'I'
   				
   				
	fetch next from CURALLODEDUCTION into @AD_ID,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT
   end                      
 close CURALLODEDUCTION                      
deallocate CURALLODEDUCTION   
	
		Select @Max_Increment_ID = Increment_ID From dbo.T0095_INCREMENT I WITH (NOLOCK) inner join
		(select Max(Increment_Effective_Date)Increment_Effective_Date ,Emp_ID From dbo.T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@Emp_ID group by emp_ID)Q on
		i.Emp_ID= q.Emp_ID  and i.Increment_Effective_Date =q.Increment_Effective_Date
		
		Update	dbo.T0080_Emp_Master 
		set		Increment_Id =@Max_Increment_ID
		Where	Emp_ID =@Emp_ID 
		
		Update	dbo.T0100_EMP_EARN_DEDUCTION 
		SET		FOR_DATE = @Increment_Effective_Date
		WHERE	Emp_ID = @Emp_ID and Increment_Id = @Increment_ID
		
		
		
		Update dbo.t0090_hrms_appraisal_initiation set t0090_hrms_appraisal_initiation.Status=@App_Status where Appr_Int_ID=@Appr_Int_ID --on jan 23 2013
		
		Update dbo.t0090_hrms_appraisal_initiation_detail set Increment_ID=@Increment_ID,Is_Accept=@Status  --Change by Ripal 16July2014
		 where Emp_ID=@Emp_ID And  Appr_Int_ID=@Appr_Int_ID
		
	RETURN
  



