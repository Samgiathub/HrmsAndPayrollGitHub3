---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[SP_Import_Employee_Transfer]
	@Cmp_ID int,
	@Emp_Id int,
	@Effective_Date datetime,
	@Type varchar(50),
	@Grade varchar(50),
	@Branch varchar(50),
	@Designation varchar(50),
	@Emp_Type varchar(50) = '',
	@Department varchar(50),
	@Category varchar(50),
	@Emp_Manager_Code varchar(50),
	@Business_Segment varchar(50),
	@Vertical varchar(50),
	@Sub_Vertical varchar(50),
	@Sub_Branch varchar(50),
	@Salary_Cycle varchar(50),
	@Increment_Id int output,
	@Row_No int,
	@Log_Status int output,
	@Customer_Audit  tinyint = 0,   --Added By Jaina 08-09-2016
	@Sales_Code	varchar(20)	= '',		--Added By Ramiz 08-12-2016 ( If we want to Remove Sales Code , we Pass it as Blank , so I have not Added OLD Value in this Variable )
	@Cost_Center varchar(50) = ''	--Added By Ramiz 15/03/2017
	,@Reason nvarchar(500)  ---Added by ronakk 16072022
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
	
Set @Log_Status = 0

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
Declare @Manager_ID					int
declare @auto_vpf					char(1) 
Declare @Bank_Ac_no					varchar(20)
declare @Basic_Per					numeric(18,0)
declare @Calc_On					varchar(20)
Declare @AD_Rounding  INT
Declare @is_yearly_ctc tinyint
declare @Segment_ID numeric 
declare @Salary_Cycle_id			NUMERIC   
declare @Vertical_ID				NUMERIC    
declare @SubVertical_ID				NUMERIC    
declare @subBranch_ID				NUMERIC   
declare @Basic_Salary numeric(18,3)
declare @Gross_Salary numeric(18,3)
declare @CTC numeric(18,3)
Declare @center_Id as Numeric
declare @IS_CTC_Auto_Cal tinyint 
set @IS_CTC_Auto_Cal = 0
declare @Is_Changed_Grd_ID tinyint
set @Is_Changed_Grd_ID = 0


set @Vertical_ID = 0
set @SubVertical_ID	=0
set @subBranch_ID = 0
set @Basic_Salary = 0
set @Gross_Salary = 0
set @CTC = 0
set @Segment_ID = 0
set @Salary_Cycle_id = 0
set @is_yearly_ctc = 0
set @AD_Rounding = 0
set @Calc_On = ''
set @Basic_Per = 0
set @Bank_Ac_no = ''
set @auto_vpf = ''
set @Manager_ID = 0
set @Deputation_End_Date = null
set @Yearly_Bonus_Amount = 0
set @Login_ID = 0
set @Emp_Childran = 0
set @Emp_Late_Limit = ''
set @Late_Dedu_Type = ''
set @Emp_part_Time = 0
set @Fix_Salary = ''
set @Emp_PT = 0
set @Emp_Full_PF = ''
set @Emp_Late_Mark = ''
set @Old_Gross = 0
set @Old_Basic = 0
set @Increment_Amount = 0
set @Increment_Per = 0
set @Increment_Date	 =null
set @Division_ID = 0
set @Grd_ID	 = 0
set @Dept_ID = 0
set @Product_ID	=0
set @Desig_Id	=0
set @Type_ID	=0
set @Branch_ID	=0
set @Cat_Id		= 0
set @Bank_ID	=0
set @Currency_ID=0
set @Wages_Type	 = ''
set @Salary_Basis_On = ''
set @Payment_Mode	=''
set @Inc_Bank_AC_No	=''
set @Emp_OT	 =''
set @Emp_OT_Min_Limit =''
set @Emp_OT_Max_Limit =''
set @center_Id = 0
	
If @Basic_Salary is null
	set @Basic_Salary = 0

set @Manager_ID = 0		
		
	BEGIN TRY
				set @Increment_Date = getdate()			
				
								select  @Increment_Id = i.Increment_ID,@Grd_ID =I.Grd_ID,@Dept_ID =Dept_ID ,
								@Desig_Id = i.Desig_Id,@Type_ID =Type_ID,@Branch_ID=Branch_ID,@Cat_Id=i.Cat_Id,@Bank_ID=Bank_ID
								,@Currency_ID=Curr_ID,@Wages_Type=Wages_Type,@Salary_Basis_On=Salary_Basis_On,@Payment_Mode=Payment_Mode
								,@Inc_Bank_AC_No =Inc_Bank_AC_No,@Emp_OT=Emp_OT,@Emp_OT_Min_Limit=Emp_OT_Min_Limit,@Emp_OT_Max_Limit=Emp_OT_Max_Limit
								,@Increment_Per=Increment_Per,@Increment_Amount=Increment_Amount,@Old_Basic=Basic_salary,@Old_Gross=Gross_Salary
								,@Emp_Late_Mark=Emp_Late_mark,@Emp_Full_PF=Emp_Full_PF,@Emp_PT=Emp_PT
								,@Fix_Salary=Emp_Fix_Salary,@Emp_part_Time=Emp_part_Time,@Late_Dedu_Type=Late_Dedu_Type,@Emp_Late_Limit=Emp_Late_Limit
								,@Emp_PT_Amount=Emp_PT_Amount,@Emp_Childran=Emp_Childran,@Login_ID=Login_ID,@Yearly_Bonus_Amount = Yearly_Bonus_Amount
								,@Deputation_End_Date=Deputation_End_Date,@Basic_Per = gm.Basic_Percentage,@Calc_On=gm.Basic_Calc_On
								,@auto_vpf=Emp_Auto_Vpf,@Salary_Cycle_id = SalDate_id, @Segment_ID = Segment_ID,@Vertical_ID = Vertical_ID,@SubVertical_ID =SubVertical_ID,@subBranch_ID = subBranch_ID,@Basic_Salary = Basic_Salary,@CTC = CTC , @Gross_Salary = Gross_Salary -- Added By Gadriwala 07042014
								,@center_Id = Center_ID --Added By Ramiz on 15/03/2017
							from T0095_INCREMENT i WITH (NOLOCK) inner join 
							( select max(Increment_ID) Increment_ID ,Emp_ID from T0095_INCREMENT WITH (NOLOCK)	-- Ankit 11092014 for Same Date Increments 
								where increment_effective_Date <=@Effective_Date and emp_ID = @Emp_ID 
								group by emp_ID ) Q on i.emp_ID = Q.emp_ID and i.Increment_ID = q.Increment_ID inner join
								T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID = i.Grd_ID
									
					--------        All Fields ID Get------------------------------------------------------

						------------------------Added by ronakk 16072022 ------------------------------------------------


					  Declare @ResoneID int = 0		
					  if @Reason <> ''
						begin
						--Added  by ronakk 30012023
						 set @Reason =  REPLACE(@Reason,'amp;','')

							if Exists(select 1 from T0040_Reason_Master WITH (NOLOCK) where UPPER(Reason_Name) = UPPER(@Reason) )
								begin
									select @ResoneID = Res_Id from T0040_Reason_Master WITH (NOLOCK) where UPPER(Reason_Name) = UPPER(@Reason)
							    ENd
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Reason',@Effective_date,'Please Check Reason Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end




						-----------------------------End  by ronakk 16072022 ------------------------------------------




						 if @Grade <> '' 
						 begin
						 --Added  by ronakk 30012023
						 set @Grade =  REPLACE(@Grade,'amp;','')
							
							if exists (select  1 from T0040_GRADE_MASTER WITH (NOLOCK) where Upper(Grd_Name) = Upper(@Grade) and cmp_ID = @Cmp_ID)
							begin
								declare @Grd_new_ID numeric 
								SET @Grd_new_ID = 0	
								select @Grd_new_ID = Grd_ID  from T0040_GRADE_MASTER WITH (NOLOCK) where Upper(Grd_Name) = Upper(@Grade) and Cmp_ID = @Cmp_ID 
								if @Grd_new_ID <> @Grd_ID
								begin
									set @Is_Changed_Grd_ID = 1
								end	
								select  @Grd_ID = Grd_ID from T0040_GRADE_MASTER WITH (NOLOCK) where Upper(Grd_Name) = Upper(@Grade) and Cmp_ID = @Cmp_ID
									
							end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Grade Name',@Effective_date,'Please Check Grade Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
						 end
						 
						 if @Designation <> '' 
						 begin
						 --Added  by ronakk 30012023
						 set @Designation =  REPLACE(@Designation,'amp;','')
						
							if exists (select  1 from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Upper(Desig_Name) = Upper(@Designation) and cmp_ID = @Cmp_ID)
							begin
									
									select  @Desig_Id = Desig_ID from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Upper(Desig_Name) = Upper(@Designation) and Cmp_ID = @Cmp_ID
									
							end
							else
								begin
									
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Designation Name',@Effective_date,'Please Check Designation Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
						 end
						 
						 if @Emp_Type <> '' 
						 begin
						 --Added  by ronakk 30012023
						 set @Emp_Type =  REPLACE(@Emp_Type,'amp;','')
						

						
							if exists (select  1 from T0040_TYPE_MASTER  WITH (NOLOCK) where Upper(Type_Name) = Upper(@Emp_Type) and cmp_ID = @Cmp_ID)
							begin
									
									select  @Type_ID = Type_ID from T0040_TYPE_MASTER WITH (NOLOCK) where Upper(Type_Name) = Upper(@Emp_Type) and Cmp_ID = @Cmp_ID
									
							end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Emp_Type Name',@Effective_date,'Please Check Emp_Type Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
						 end
						 
						 if @Department <> '' 
						 begin
						  --Added  by ronakk 30012023
						 set @Department =  REPLACE(@Department,'amp;','')

							if exists (select  1 from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Upper(Dept_Name) = Upper(@Department) and Cmp_ID = @Cmp_ID)
								begin
									
									select  @Dept_ID = Dept_Id from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Upper(Dept_Name) = Upper(@Department) and Cmp_ID = @Cmp_ID
									
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Department Name',@Effective_date,'Please Check Department Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
						 end
						
						if @Branch <> ''
						begin
						   --Added by ronakk 30012023 
						   set @Branch =  REPLACE(@Branch,'amp;','')
						   
							if exists(select 1 from T0030_BRANCH_MASTER WITH (NOLOCK) where UPPER(Branch_Name) = UPPER(@Branch) and Cmp_ID = @Cmp_ID )
								begin
									select @Branch_ID = Branch_ID from T0030_BRANCH_MASTER WITH (NOLOCK) where UPPER(Branch_Name) = UPPER(@Branch) and Cmp_ID = @Cmp_ID 
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Branch Name',@Effective_date,'Please Check Branch Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
						end
						
						if @Category <> ''
						begin
						 --Added  by ronakk 30012023
						 set @Category =  REPLACE(@Category,'amp;','')

							if Exists(select 1 from T0030_CATEGORY_MASTER WITH (NOLOCK) where UPPER(Cat_Name) = UPPER(@Category) and cmp_ID = @Cmp_ID )
								begin
								select @Cat_Id = Cat_ID from T0030_CATEGORY_MASTER WITH (NOLOCK) where UPPER(Cat_Name) = UPPER(@Category) and cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Category Name',@Effective_date,'Please Check Category Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end
						
						if @Business_Segment <> ''
						begin
						--Added  by ronakk 30012023
						 set @Business_Segment =  REPLACE(@Business_Segment,'amp;','')

							if Exists(select 1 from T0040_Business_Segment WITH (NOLOCK) where UPPER(Segment_Name) = UPPER(@Business_Segment) and cmp_ID = @Cmp_ID )
								begin
								select @Segment_ID = Segment_ID from T0040_Business_Segment WITH (NOLOCK) where UPPER(Segment_Name) = UPPER(@Business_Segment) and cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Business Segment Name',@Effective_date,'Please Check Business Segment Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end
						
						if @Vertical <> ''
						begin
						--Added  by ronakk 30012023
						 set @Vertical =  REPLACE(@Vertical,'amp;','')

							if Exists(select 1 from T0040_Vertical_Segment WITH (NOLOCK) where UPPER(Vertical_Name) = UPPER(@Vertical) and cmp_ID = @Cmp_ID )
								begin
								select @Vertical_ID = Vertical_ID from T0040_Vertical_Segment WITH (NOLOCK) where UPPER(Vertical_Name) = UPPER(@Vertical) and cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Verical Name',@Effective_date,'Please Check Vertical Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end
						
						if @Sub_Vertical <> ''
						begin
						--Added  by ronakk 30012023
						 set @Sub_Vertical =  REPLACE(@Sub_Vertical,'amp;','')


							if Exists(select 1 from T0050_SubVertical WITH (NOLOCK) where UPPER(SubVertical_Name) = UPPER(@Sub_Vertical) and cmp_ID = @Cmp_ID )
								begin
								select @SubVertical_ID = SubVertical_ID from T0050_SubVertical WITH (NOLOCK) where UPPER(SubVertical_Name) = UPPER(@Sub_Vertical) and cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Sub-Verical Name',@Effective_date,'Please Check Sub-Verical Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end
						
						if @Sub_Branch <> ''
						begin
						--Added  by ronakk 30012023
						 set @Sub_Branch =  REPLACE(@Sub_Branch,'amp;','')
							if Exists(select 1 from T0050_SubBranch WITH (NOLOCK) where UPPER(SubBranch_Name) = UPPER(@Sub_Branch) and cmp_ID = @Cmp_ID )
								begin
								select @subBranch_ID = SubBranch_ID from T0050_SubBranch WITH (NOLOCK) where UPPER(SubBranch_Name) = UPPER(@Sub_Branch) and cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Sub-Branch Name',@Effective_date,'Please Check Sub-Branch Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end
						
						if @Salary_Cycle <> ''
						begin
						--Added  by ronakk 30012023
						 set @Salary_Cycle =  REPLACE(@Salary_Cycle,'amp;','')

							if Exists(select 1 from T0040_Salary_Cycle_Master WITH (NOLOCK) where UPPER(Name) = UPPER(@Salary_Cycle) and cmp_ID = @Cmp_ID )
								begin
									select @Salary_Cycle_id = Tran_Id from T0040_Salary_Cycle_Master WITH (NOLOCK) where UPPER(Name) = UPPER(@Salary_Cycle) and cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Salary Cycle Name',@Effective_date,'Please Check Salary Cycle Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end
						
						If @Emp_Manager_Code <> '' 
						begin
						
								if Exists(select 1 from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Manager_Code)
								begin
										
									select @Manager_ID = isnull(Emp_ID,0) from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Manager_Code 
									
								end
								else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Employee Manager Code',@Effective_date,'Please Check Employee Manager Code',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
						end
						
					  if @Cost_Center <> ''
						begin
						
						--Added  by ronakk 30012023
						 set @Cost_Center =  REPLACE(@Cost_Center,'amp;','')

							if Exists(select 1 from T0040_COST_CENTER_MASTER WITH (NOLOCK) where UPPER(Center_Name) = UPPER(@Cost_Center) and cmp_ID = @Cmp_ID )
								begin
									select @center_Id = Center_ID from T0040_COST_CENTER_MASTER WITH (NOLOCK) where UPPER(Center_Name) = UPPER(@Cost_Center) and cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with COST CENTER ',@Effective_date,'Please Check Cost Center Name',GetDate(),'Employee Transfer','')
								     set @Log_Status = 1
								end
							
						end


						----[BMA - Employee Join Date and Transfer on same date are Not Allow ] Ankit/Nimesh 30062016
						IF EXISTS(SELECT Emp_ID FROM T0095_INCREMENT WITH (NOLOCK) WHERE emp_id =@Emp_ID AND Increment_effective_Date = @effective_Date AND Is_Master_Rec = 1 AND Increment_Type = 'Joining'  )
							BEGIN
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Id,'Employee Can not be transfered on same Date of Join',@Effective_date,'Employee Can not be transfered on same Date of Join',GETDATE(),'Employee Transfer','')
							    SET @Log_Status = 1
							END
							
						IF @Log_Status = 1	
							RETURN;
						--
							
						 ----------------------------------------------------------------------------------
						
						declare @AD_ID numeric(18,3)
						declare @For_Date datetime
						declare @E_AD_Amount numeric(18,2)
						declare @E_AD_Percentage numeric(12,2)
						declare @E_AD_Flag char(1)
						declare @E_AD_Mode varchar(10)
						declare @E_AD_MAX_LIMIT numeric(18,3)
						declare @E_AD_YEARLY_AMOUNT numeric(18,3)
						Declare @Row_ID numeric
						
						set @AD_ID = 0 
						set @For_Date =  null 
						set @E_AD_Amount = 0
						set @E_AD_Percentage = 0
						set @E_AD_Flag = ''
						set @E_AD_Mode = ''
						set @E_AD_MAX_LIMIT = 0
						set @E_AD_YEARLY_AMOUNT = 0 
						set @Row_ID = 0
						
						-----------------Get in Cursor Previous Increment Allowance Deduduction if  Grade is Same -------------------------
						if @Is_Changed_Grd_ID = 0 
							begin
								Declare CurUpdateAD_Master cursor for 
								--select AD_ID,For_Date,E_AD_Flag,E_AD_Mode,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT 
								--from T0100_EMP_EARN_DEDUCTION where INCREMENT_ID = @Increment_Id
								
								--Commented Above Code and New Added By Ramiz on 01/06/2017 , as when it was not Order By at that time Special Allowance was Coming Incorrect.
								SELECT EED.AD_ID,EED.For_Date,EED.E_AD_Flag,EED.E_AD_Mode,EED.E_AD_PERCENTAGE,EED.E_AD_AMOUNT,EED.E_AD_MAX_LIMIT,EED.E_AD_YEARLY_AMOUNT 
								FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
								INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
								WHERE INCREMENT_ID = @INCREMENT_ID
								ORDER BY AD.AD_LEVEL
							end
						-----------------------------------------------------------------------------------
						
				if not exists(select Emp_ID from T0095_INCREMENT WITH (NOLOCK) where emp_id =@Emp_ID and Increment_effective_Date = @effective_Date )
						begin
							-- Insert Increment ---------------------------------
								set @Increment_Id = 0
																								
								EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_id,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Currency_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary
									,@Type,@Increment_Date,@effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Old_Basic,@Old_Gross,''
									,@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_part_Time,0,@Login_ID,@Yearly_Bonus_Amount,@Deputation_End_Date,@Manager_ID,1,0,@CTC,@Salary_Cycle_id = @Salary_Cycle_id
									,@auto_vpf=@auto_vpf, @Segment_ID = @Segment_ID,@Vertical_ID =@Vertical_ID,@SubVertical_ID =@SubVertical_ID,@subBranch_ID = @subBranch_ID -- Added by Gadriwala muslim 07042013						
									,@Customer_Audit=@Customer_Audit , @Sales_Code = @Sales_Code, @center_Id = @center_Id 
									,@Reason_ID=@ResoneID,@Reason_Name=@Reason --Added by ronakk 16072022
									--Added by Jaina 08-09-2016 --Sales Code Added By Ramiz on 08122016
									
								if @Is_Changed_Grd_ID = 0 
									begin
												---Insert Previous Allowance Deducation with new Increment ID							
										Open CurUpdateAD_Master
					
										fetch next from CurUpdateAD_Master into  @AD_ID,@For_Date,@E_AD_Flag,@E_AD_Mode,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_YEARLY_AMOUNT
											While @@FETCH_STATUS = 0 
											begin
											
													exec P0100_EMP_EARN_DEDUCTION @Row_Id output,@EMP_ID,@CMP_ID,@AD_ID,@Increment_Id,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,'I'	
													fetch next from CurUpdateAD_Master into  @AD_ID,@For_Date,@E_AD_Flag,@E_AD_Mode,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_YEARLY_AMOUNT
											end
										close CurUpdateAD_Master
										deallocate CurUpdateAD_Master
										----------------------------------------------------------
									end
								else
									begin
										---------Insert New Allowance Deducation  with Grade Wise ( Grade Changed )-----
											exec P0100_EMP_GRADEWISE_ALLOWANCE @cmp_ID,@Emp_Id,@Grd_ID,@Effective_Date,@Increment_Id
									end	
						end
				else
						begin
						
							IF  @Is_Changed_Grd_ID =  1 
								BEGIN
									--	Insert New Allowance Deducation  with Grade Wise ( Grade Changed )
									
									DELETE FROM T0100_EMP_EARN_DEDUCTION WHERE INCREMENT_ID = @Increment_Id AND CMP_ID = @Cmp_ID
									exec P0100_EMP_GRADEWISE_ALLOWANCE @cmp_ID,@Emp_Id,@Grd_ID,@Effective_Date,@Increment_Id
								END
							
								Update T0095_INCREMENT set Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary , ctc = @ctc,
								  Grd_ID = @Grd_ID,Dept_ID =@Dept_ID,
								Desig_Id=@Desig_Id, Cat_ID = @Cat_Id,Branch_ID = @Branch_ID,Segment_ID = @Segment_ID,Vertical_ID = @Vertical_ID,SubVertical_ID =@SubVertical_ID,
								subBranch_ID = @subBranch_ID,SalDate_id = @Salary_Cycle_id ,Type_ID = @Type_ID
								,Increment_Type = @Type , Sales_Code = @Sales_Code   --Sales Code Added By Ramiz on 08122016
								,Reason_ID =@ResoneID  --Added by ronakk 17072022
								where emp_id =@Emp_ID and increment_Effective_date = @Effective_date And Increment_ID = @Increment_Id
								
								-- Reporting Manager Update ----------------
								IF @Manager_ID IS NOT NULL
									BEGIN
									
										IF NOT EXISTS(SELECT Row_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND R_Emp_ID=@Manager_ID)
											BEGIN	
																
												EXEC P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@Manager_ID,'Direct','i',0,0,'',@Effective_Date
											END
										END		
										
								IF ISNULL(@Manager_ID,0) <> 0
										BEGIN
												DECLARE @RE_Emp_ID NUMERIC
												SET @RE_Emp_ID = 0
												
												SELECT @RE_Emp_ID = R_Emp_ID
												From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
													(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
													 WHERE Effect_Date<=@Effective_Date And Emp_ID = @Emp_ID
													 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
												WHERE ERD.Emp_ID = @Emp_ID
											
												UPDATE	T0080_Emp_Master 
													SET		emp_superior=@RE_Emp_ID
													WHERE	Emp_ID =@Emp_ID 
										END
								EXEC P0100_Emp_Manager_History 0,@Cmp_ID,@Emp_ID,@Increment_ID,@Manager_ID,@Effective_Date
								-- Reporting Manager Update ----------------
						end
						
					END TRY
						BEGIN CATCH
								
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,ERROR_MESSAGE(),@Effective_date,'Enter proper Employee Transfer Data',GetDate(),'Employee Transfer','')
									set @Log_Status = 1

						END CATCH;
		 
						
																	  
END
