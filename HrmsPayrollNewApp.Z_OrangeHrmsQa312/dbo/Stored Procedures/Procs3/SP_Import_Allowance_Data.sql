
CREATE PROCEDURE [dbo].[SP_Import_Allowance_Data]
	@Cmp_ID						numeric, 
	@Emp_Id						numeric,
	@Emp_Name					nvarchar(50),
	@Branch_Name				varchar(50),
	@Increment_Effective_Date	Datetime,
	@Increment_Type				varchar(30),
	@Entry_Type					varchar(30) = '',
	@Grade						varchar(50) = '',
	@Designation				varchar(50) = '',
	@Department					varchar(50) = '',
	@Basic_Salary				numeric(18,2),
	@Gross_Salary				numeric(18,2),
	@Reason_Name				varchar(500) = '', 
	@Increment_Id				numeric output,
	@Row_No						numeric,
	@Log_Status					numeric output,
	@CTC						numeric(18,2),
	@GUID						Varchar(2000) = '', 
	@Remarks					varchar(500) = '', 
	@User_Id					numeric(18,2) = 0,
	@IP_Address					varchar(100) = ''
AS

	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
Set @Log_Status = 0

Set @Department = dbo.fnc_ReverseHTMLTags(@Department)
Set @Designation = dbo.fnc_ReverseHTMLTags(@Designation)
Set @Branch_Name = dbo.fnc_ReverseHTMLTags(@Branch_Name)
Set @Increment_Type = dbo.fnc_ReverseHTMLTags(@Increment_Type)
Set @Grade = dbo.fnc_ReverseHTMLTags(@Grade)

If @Basic_Salary is null
	set @Basic_Salary = 0

Declare @Increment_Date				Datetime
Declare @Division_ID				numeric
Declare @Grd_ID						numeric
Declare @Dept_ID					numeric
Declare @Product_ID					numeric
Declare @Desig_Id					numeric
Declare @Type_ID					numeric
Declare @Branch_ID					numeric
Declare @Cat_Id						numeric
Declare @Bank_ID					numeric
Declare @Currency_ID				numeric
Declare @Wages_Type					varchar(10)
Declare @Salary_Basis_On			varchar(10) 
Declare @Payment_Mode				varchar(20) 
Declare @Inc_Bank_AC_No				varchar(50)
Declare @Emp_OT						varchar(1)  
Declare @Emp_OT_Min_Limit			varchar(10) 
Declare @Emp_OT_Max_Limit			varchar(10)	 
Declare @Increment_Per				numeric(18,2) 
Declare @Increment_Amount			numeric(18,2)
Declare @Old_Basic					numeric(18,2)
declare @Old_Gross					numeric(18,2) 
Declare @Old_CTC					numeric(18,2) 
--Declare @Increment_Comments			varchar(250)
Declare @Emp_Late_Mark				char(1) 
Declare @Emp_Full_PF				char(1) 
Declare @Emp_PT						tinyint
Declare @Fix_Salary					char(1)
Declare @Emp_part_Time				numeric(1,0)
Declare @Late_Dedu_Type				varchar(10)
Declare @Emp_Late_Limit				varchar(10)
Declare @Emp_PT_Amount				numeric(18,2)
Declare @Emp_Childran				numeric 
Declare @Login_ID					numeric(18)
Declare @Yearly_Bonus_Amount		numeric(22,2)
Declare	@Deputation_End_Date		datetime
declare @auto_vpf					char(1) 

 
Declare @Bank_Ac_no					varchar(20)
declare @Basic_Per					numeric(18,0)
declare @Calc_On					varchar(20)
Declare @AD_Rounding  INT
Declare @is_yearly_ctc tinyint
declare @Salary_Cycle_id			NUMERIC    -- Added By Gadriwala 07042014
declare @Vertical_ID				NUMERIC 	   -- Added By Gadriwala 07042014
declare @SubVertical_ID				NUMERIC 	   -- Added By Gadriwala 07042014	
declare @subBranch_ID				NUMERIC	   -- Added By Gadriwala 07042014
declare @Center_ID					NUMERIC		--ADDED BY NIMESH 20 MAY, 2015
DECLARE @Segment_ID					NUMERIC		--ADDED BY NIMESH 20 MAY, 2015
DECLARE @Fix_OT_Hour_Rate_WD		NUMERIC		--ADDED BY NIMESH 20 MAY, 2015
DECLARE @Fix_OT_Hour_Rate_WO_HO		NUMERIC		--ADDED BY NIMESH 20 MAY, 2015
Declare @alpha_Emp_Code Varchar(500) --Added by nilesh patel on 11082015 
Declare @Reason_ID					numeric
set @Salary_Cycle_id  = 0    -- Added By Gadriwala 07042014
set @Vertical_ID	  = 0	   -- Added By Gadriwala 07042014
set @SubVertical_ID	  = 0	   -- Added By Gadriwala 07042014	
set @subBranch_ID	  = 0	   -- Added By Gadriwala 07042014
set @alpha_Emp_Code = 0
Set @Reason_ID = 0


Declare @Sales_Code VARCHAR(20) = ''
Declare @Physical_Percent NUMERIC(18,2) = 0 
Declare @Piece_TransSalary TinyInt = 0  
Declare @Band_Id numeric(18,0)  = 0  
Declare @Is_PMGKY TINYINT = 0   
Declare @Is_PFMem TINYINT = 0  

 declare @OldValue as  varchar(max)   
 Declare @String as varchar(max)  
 declare @Tran_Type Char(1)  
 set @String =''  
 set @OldValue = ''  

			if @Increment_Effective_Date IS NULL
				begin
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code,'Effective/Joning Date Does Not Exists.',GETDATE(),'Verify Effective/Joning Date',GetDate(),'Earn\Ded Data',@GUID)
					set @Log_Status = 1
				end
			
			If @Increment_Type IS NULL
				begin
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code,'Increment Type Date Does Not Exists.',CONVERT(varchar(11),@Increment_Effective_date,103),'Verify Increment Type',GetDate(),'Earn\Ded Data',@GUID)
					set @Log_Status = 1
				end
				
			If @Entry_Type IS NULL
				begin
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code,'Entry Type Date Does Not Exists.',CONVERT(varchar(11),@Increment_Effective_date,103),'Verify Entry Type',GetDate(),'Earn\Ded Data',@GUID)
					set @Log_Status = 1
				end

			set @is_yearly_ctc = 0

			select @is_yearly_ctc = cast(isnull(setting_value,0) as tinyint) from T0040_SETTING WITH (NOLOCK) where setting_name = 'IS_YEARLY_CTC' and cmp_id = @Cmp_ID -- added by mitesh on 24/04/2012 for yearly ctc
			
			Select @alpha_Emp_Code = Alpha_Emp_Code From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_Id
			
			--Comment by Jaina 27-09-2017
			--if isnull(@is_yearly_ctc,0) = 1
			--	begin
			--		If @AD_Rounding = 1
			--			Begin 
			--				SET @CTC = ISNULL(ROUND(@CTC / 12,0),0)
			--			End
			--		Else
			--			Begin
			--				SET @CTC = @CTC / 12
			--			End
			--	end
				BEGIN TRY
						set @Increment_Date = getdate()

						select 	@Grd_ID =I.Grd_ID,@Dept_ID =Dept_ID ,
								@Desig_Id =i.Desig_Id,@Type_ID =Type_ID,@Branch_ID=Branch_ID,@Cat_Id=i.Cat_Id,@Bank_ID=Bank_ID
								,@Currency_ID=Curr_ID,@Wages_Type=Wages_Type,@Salary_Basis_On=Salary_Basis_On,@Payment_Mode=Payment_Mode
								,@Inc_Bank_AC_No =Inc_Bank_AC_No,@Emp_OT=Emp_OT,@Emp_OT_Min_Limit=Emp_OT_Min_Limit,@Emp_OT_Max_Limit=Emp_OT_Max_Limit
								,@Increment_Per=Isnull(Increment_Per,0),@Increment_Amount=Isnull(Increment_Amount,0),@Old_Basic=Isnull(Basic_salary,0),@Old_Gross=Isnull(Gross_Salary,0),@Old_CTC = Isnull(CTC,0)
								,@Emp_Late_Mark=isnull(Emp_Late_mark,0),@Emp_Full_PF=Emp_Full_PF,@Emp_PT=Emp_PT
								,@Fix_Salary=Emp_Fix_Salary,@Emp_part_Time=Emp_part_Time,@Late_Dedu_Type=Late_Dedu_Type,@Emp_Late_Limit=Emp_Late_Limit
								,@Emp_PT_Amount=Emp_PT_Amount,@Emp_Childran=Emp_Childran,@Login_ID=Login_ID,@Yearly_Bonus_Amount = Yearly_Bonus_Amount
								,@Deputation_End_Date=Deputation_End_Date,@Basic_Per = gm.Basic_Percentage,@Calc_On=gm.Basic_Calc_On
								,@auto_vpf=Emp_Auto_Vpf,@Salary_Cycle_id = SalDate_id,@Vertical_ID = Vertical_ID,@SubVertical_ID =SubVertical_ID,@subBranch_ID = subBranch_ID -- Added By Gadriwala 07042014
								,@Center_ID=Center_ID,@Segment_ID=Segment_ID,@Fix_OT_Hour_Rate_WD=Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO=Fix_OT_Hour_Rate_WO_HO		--ADDED BY NIMESH 20 MAY 2015
								,@Sales_Code=Sales_Code, @Physical_Percent= Physical_Percent,@Piece_TransSalary=Is_Piece_Trans_Salary --Added by ronakk 16052023
								,@Band_Id = Band_Id, @Is_PMGKY= Is_Pradhan_Mantri, @Is_PFMem = Is_1time_PF_Member --Added by ronakk 16052023


								--,@Reason_ID = I.Reason_ID
							from T0095_INCREMENT i WITH (NOLOCK) inner join 
							( select max(Increment_ID) Increment_ID ,Emp_ID from T0095_INCREMENT WITH (NOLOCK)
								where increment_effective_Date <=@Increment_Effective_Date and emp_ID = @Emp_ID 
								group by emp_ID ) Q on i.emp_ID = Q.emp_ID and i.Increment_ID = q.Increment_ID inner join
								T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID = i.Grd_ID
						
								
						SELECT @AD_Rounding = AD_Rounding FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
						AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
										  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
					
						--Added by Jaina 27-09-2017	
						if isnull(@is_yearly_ctc,0) = 1
							begin
								If @AD_Rounding = 1
									Begin 
										SET @CTC = ISNULL(ROUND(@CTC / 12,0),0)
									End
								Else
									Begin
										SET @CTC = @CTC / 12
									End
							end
							
						If @Basic_Salary = 0
							Begin 
								if @Calc_On = 'CTC'
									begin
										If @AD_Rounding = 1
											Begin 
												set @Basic_Salary = isnull(Round((@CTC * @Basic_Per)/100,0),0)
											End
										Else
											Begin 
												set @Basic_Salary = isnull((@CTC * @Basic_Per)/100,0)
											ENd
									end	
								else if @Calc_On = 'Gross' 
									begin
										If @AD_Rounding = 1
											Begin
												set @Basic_Salary = isnull(Round((@Gross_Salary * @Basic_Per)/100,0),0)
											End
										Else
											Begin
												set @Basic_Salary = isnull((@Gross_Salary * @Basic_Per)/100,0)
											End
									end
							End			

						-- Added by Hardik 17/09/2018 for Corona
						Declare @Min_Basic_Applicable tinyint
						Declare @Min_Basic Numeric(18,5)

						Set @Min_Basic_Applicable = 0
						Set @Min_Basic = 0

						Select @Min_Basic_Applicable = Setting_Value  from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID  and Setting_Name ='Min. basic rules applicable'
						Select @Min_Basic = Isnull(min_basic,0)  from T0040_GRADE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Grd_Id = @Grd_Id

						IF @Min_Basic_Applicable = 1 And @Min_Basic > 0 And @Basic_Salary < @Min_Basic
							BEGIN
								Set @Basic_Salary = @Min_Basic
							END	
						
						-- Ended by Hardik 17/09/2018 for Corona	
																			
						--if @Basic_Salary = 0
						--	begin
						--		Set @Basic_Salary = @Old_Basic
						--	end
						-- added By Gadriwala 07042014
						
						if ISNULL(@Vertical_ID,0) = 0 
							set @Vertical_ID = 0
						if ISNULL(@SubVertical_ID,0) = 0 
							set @SubVertical_ID = 0
						if ISNULL(@subBranch_ID,0) = 0
							set @subBranch_ID = 0
						if ISNULL(@Salary_Cycle_id,0) = 0
						 set @Salary_Cycle_id = 0
						 
						-----------------------------
							-- Gadriwala Muslim 24/05/2014 - Start
						 if @Grade <> '' 
						 begin

						 	--Added  by ronakk 01032023
							set @Grade =  REPLACE(@Grade,'amp;','')
							
							if exists (select 1 from T0040_GRADE_MASTER WITH (NOLOCK) where Upper(Grd_Name) = Upper(@Grade) and cmp_ID = @Cmp_ID)
							begin
									select  @Grd_ID = Grd_ID from T0040_GRADE_MASTER WITH (NOLOCK) where Upper(Grd_Name) = Upper(@Grade) and Cmp_ID = @Cmp_ID
							end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/ ,'Problem with Grade Name',CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Grade Name',GetDate(),'Earn\Ded Data',@GUID)
								     set @Log_Status = 1
								end
						 end
						 
						 if @Designation <> '' 
						 begin
						--Added  by ronakk 01032023
							set @Designation =  REPLACE(@Designation,'amp;','')
							if exists (select  1 from T0040_DESIGNATION_MASTER  WITH (NOLOCK) where Upper(Desig_Name) = Upper(@Designation) and cmp_ID = @Cmp_ID)
							begin
									
									select  @Desig_Id = Desig_ID from T0040_DESIGNATION_MASTER  WITH (NOLOCK) where Upper(Desig_Name) = Upper(@Designation) and Cmp_ID = @Cmp_ID
									
							end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/,'Problem with Designation Name',CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Designation Name',GetDate(),'Earn\Ded Data',@GUID)
								     set @Log_Status = 1
								end
						 end
						if @Department <> '' 
						 begin
						 	--Added  by ronakk 01032023
							set @Department =  REPLACE(@Department,'amp;','')

							if exists (select  1 from T0040_DEPARTMENT_MASTER  WITH (NOLOCK) where Upper(Dept_Name) = Upper(@Department) and Cmp_ID = @Cmp_ID)
								begin
									
									select  @Dept_ID = Dept_Id from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Upper(Dept_Name) = Upper(@Department) and Cmp_ID = @Cmp_ID
									
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/ ,'Problem with Department Name',CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Department Name',GetDate(),'Earn\Ded Data',@GUID)
								     set @Log_Status = 1
								end
						 end
						 
						if @Reason_Name <> '' 
						 begin

						  	--Added  by ronakk 01032023
							set @Reason_Name =  REPLACE(@Reason_Name,'amp;','')

							if exists (select  1 from T0040_Reason_Master WITH (NOLOCK) where Upper(Reason_Name) = Upper(@Reason_Name))
								begin
									
									select  @Reason_ID = Res_Id from T0040_Reason_Master WITH (NOLOCK) where Upper(Reason_Name) = Upper(@Reason_Name)
									
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/ ,'Problem with Reason Name',CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Reason Name',GetDate(),'Earn\Ded Data',@GUID)
								     set @Log_Status = 1
								end
						 end
						 -- Gadriwala Muslim 24/05/2014 - End
						
						if @Branch_Name <> ''  --Added by Mukti(17082017)
						 begin
						  	--Added  by ronakk 01032023
							set @Branch_Name =  REPLACE(@Branch_Name,'amp;','')

							if exists (select  1 from T0030_BRANCH_MASTER WITH (NOLOCK) where Upper(Branch_Name) = Upper(@Branch_Name) and Cmp_ID = @Cmp_ID)
								begin									
									select  @Branch_ID = Branch_ID from T0030_BRANCH_MASTER WITH (NOLOCK) where Upper(Branch_Name) = Upper(@Branch_Name) and Cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/ ,'Problem with Branch Name',CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Branch Name',GetDate(),'Earn\Ded Data',@GUID)
								     set @Log_Status = 1
								end
						 end

						If @Log_Status = 1
							RETURN

							
						if @Gross_Salary = 0
							begin
								Set @Gross_Salary = @old_Gross
							end
						
						If @Basic_Salary > 0 
							set @Increment_Amount = @Basic_Salary - @Old_Basic
							
						if @Old_BAsic > 0 
							set @Increment_Per  = round(Isnull(@Increment_Amount,0) * 100 /@Old_Basic,2)
						else if @Basic_Salary > 0
							set @Increment_Per =100				
							
							
						declare @allow_Dedu_ID numeric 
						Declare @Mode varchar(10)
						declare @Amount numeric 
						Declare @Percentage numeric (18,2)
						declare @max_Upper	numeric
						declare @Flag varchar(1)
						declare @Row_ID numeric 
						Declare @Month numeric 
						set @Increment_ID = 0
						
						  --DECLARE @Allow_Same_Date_Increment TINYINT		--Ankit 17022015
						  --Declare @Allow_Same_Date_Increment_flag TINYINT
						  --SET @Allow_Same_Date_Increment  = 0
						  --SET @Allow_Same_Date_Increment_flag = 0
						  
						  --SELECT @Allow_Same_Date_Increment = Isnull(Setting_Value,0) 
						  --FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID And Setting_Name like 'Allow Same Date Increment'

						  --IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT  WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0
								--BEGIN
								--	SET @Allow_Same_Date_Increment_flag = 1
								--END

						--if not exists(select Emp_ID from T0095_INCREMENT where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date) And (@Increment_Type <> 'Joining' And UPPER(@Entry_Type) = UPPER('New'))
						
						if @Increment_Type <> 'Joining' And UPPER(@Entry_Type) = UPPER('New') --AND @Allow_Same_Date_Increment_flag = 0
							begin 						
									--Declare @IS_REG as numeric
									--select @IS_REG =COUNT(*) from T0095_INCREMENT where emp_id =@Emp_ID and Increment_Type = 'Joining'
--									if @Increment_Type <> 'Joining' And UPPER(@Entry_Type) = UPPER('New')
										begin
											
											if @Login_ID = 0 
											Begin
												Select @Login_ID = Login_Id from T0011_LOGIN where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
											End
													
											EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_id,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Currency_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary
												,@Increment_Type,@Increment_Date,@Increment_effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Old_Basic,@Old_Gross,''
												,@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_part_Time,0,@Login_ID,@Yearly_Bonus_Amount,@Deputation_End_Date,0,1,0,@CTC,@Pre_CTC_Salary = @Old_CTC,@Increment_Mode = 1,@Salary_Cycle_id = @Salary_Cycle_id,@auto_vpf=@auto_vpf,@Vertical_ID =@Vertical_ID,@SubVertical_ID =@SubVertical_ID,@subBranch_ID = @subBranch_ID -- Added by Gadriwala muslim 07042013						
												,@Center_ID=@Center_ID,@Segment_ID=@Segment_ID,@Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO --ADDED BY NIMESH 20 MAY 2015
												,@Reason_ID = @Reason_ID,@Reason_Name = @Reason_Name,@no_of_chlidren = @Emp_Childran,@Remarks = @Remarks
												,@Sales_Code=@Sales_Code,@Physical_Percent= @Physical_Percent,@Piece_TransSalary=@Piece_TransSalary,@Band_Id =  @Band_Id,@Is_PMGKY = @Is_PMGKY,@Is_PFMem =@Is_PFMem --Added by ronakk 16052023
											
											Update T0080_EMP_MASTER set Basic_Salary = @Basic_Salary   WHERE Increment_Id = @Increment_Id
											
										end	
--									else
--										begin
											
--											Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Increment Type',@Increment_effective_Date,'Enter proper Increment Type,May be it is Increment of Employee',GetDate(),'Earn\Ded Data')
--											set @Log_Status = 1
--								
--										end
										
														
							end
						else
							if (exists(select Emp_ID from T0095_INCREMENT WITH (NOLOCK) where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date And Increment_Type = 'Joining') And (@Increment_Type = 'Joining'))
								or (exists(select Emp_ID from T0095_INCREMENT WITH (NOLOCK) where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date And Increment_Type <> 'Joining') And (@Increment_Type <> 'Joining'))
							
							begin
							   	--Added by nilesh patel on 16052016 --Start
								
							   	if @Increment_Type = 'Joining' 
							   		Begin
							   			DECLARE @Sal_Count Numeric(10,0)
							   			Set @Sal_Count = 0
							   			Select @Sal_Count = COUNT(1) From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID		
										if @Sal_Count > 0 
											Begin
												Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code ,'Employee Salary Exists. You can not update Employee joining details',CONVERT(varchar(11),@Increment_Effective_date,103),'Employee Salary Exists you can not update Employee joining details',GetDate(),'Earn\Ded Data',@GUID)
												set @Log_Status = 1
											End
							   		End 
							   	--Added by nilesh patel on 16052016 --End
							   	
								Declare @PT_Amount			numeric 
								Declare @AD_Other_Amount	numeric 
								Declare @Max_Increment_ID	numeric 
								Declare @Max_Shift_ID numeric
								Declare @Current_Date datetime
								
								set @Current_Date = getdate()
								set @PT_Amount = 0
								
								Select @Increment_Id = I.Increment_ID from T0095_INCREMENT i WITH (NOLOCK)
									INNER JOIN (SELECT MAX(Increment_ID) Increment_ID, Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)
													WHERE increment_effective_Date <= @Increment_Effective_Date AND emp_ID = @Emp_ID 
													GROUP BY emp_ID
												) Q 
									ON i.emp_ID = Q.emp_ID AND i.Increment_ID = q.Increment_ID 
								Where I.Emp_ID =@Emp_ID and Increment_effective_Date = @Increment_effective_Date 

								
								IF EXISTS(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_Id And @Increment_Effective_Date < Month_End_Date) And @Increment_ID > 0 And @INCREMENT_TYPE <> 'Joining'
									IF EXISTS(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID =@Emp_Id And Increment_ID >= @Increment_Id) And @Increment_ID > 0
										BEGIN
											Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code ,'Employee Salary Exists, you cannot update Increment Details',CONVERT(varchar(11),@Increment_Effective_date,103),'Employee Salary Exists you cannot update Increment details',GetDate(),'Earn\Ded Data',@GUID)
											set @Log_Status = 1
										END

								IF EXISTS(SELECT 1 from T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Increment_ID > @Increment_ID) And @Increment_Id > 0 And @INCREMENT_TYPE <> 'Joining'
									BEGIN
										Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code ,'Next Increment Exists, you cannot update Employee Increment',CONVERT(varchar(11),@Increment_Effective_date,103),'Next Increment Exists, you cannot update Employee Increment',GetDate(),'Earn\Ded Data',@GUID)
										set @Log_Status = 1
									END

								If @Log_Status = 1
									RETURN
								
								if @Emp_PT = 1
									begin
										Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
										set @AD_Other_Amount = @Basic_Salary + isnull(@AD_Other_Amount,0)
											
										Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@AD_Other_Amount,@PT_Amount output,'',@Branch_ID
									end

								 set @Tran_Type = 'U'
								 exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output  
								 set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max)) 								
																								
								 Update T0095_INCREMENT set Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary , ctc = @ctc, 
								 Increment_Amount = @Basic_Salary - isnull(Pre_Basic_Salary,0),  
								 Emp_PT_Amount = @PT_Amount, Grd_ID = @Grd_ID,Dept_ID =@Dept_ID,Desig_Id=@Desig_Id,
								 Reason_ID = @Reason_ID,Reason_Name=@Reason_Name,Branch_ID=@Branch_ID,
								 Emp_Childran = @Emp_Childran,Remarks = @Remarks
								 where emp_id =@Emp_ID and increment_Effective_date = @Increment_Effective_date And Increment_Id = @Increment_Id
								 
								 exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output  
								 set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))  
								
								 Update T0080_EMP_MASTER set Basic_Salary = @Basic_Salary   WHERE Increment_Id = @Increment_Id       
								
								 Delete  FROM T0100_EMP_EARN_DEDUCTION WHERE INCREMENT_ID = @Increment_Id	
							
								 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Increment',@OldValue,@Emp_ID,@User_Id,@IP_Address,1 

							end

							
			END TRY
			BEGIN CATCH
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/ ,ERROR_MESSAGE(),CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Increment Type,Basic Salary or Gross Salary data',GetDate(),'Earn\Ded Data',@GUID)
				set @Log_Status = 1
			END CATCH;
	RETURN
	

	

