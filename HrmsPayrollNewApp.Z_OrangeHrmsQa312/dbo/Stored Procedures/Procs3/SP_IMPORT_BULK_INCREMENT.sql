
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IMPORT_BULK_INCREMENT]
	@Cmp_ID						numeric, 
	@Alpha_Emp_Code				varchar(30),
	@Emp_Name					nvarchar(50),
	@Increment_Effective_Date	Datetime,
	@Increment_Mode				varchar(30),
	@Basic_Salary				numeric(18,2),
	@Gross_Salary				numeric(18,2),
	@CTC						numeric(18,2),
	@Row_No						numeric,
	@Log_Status					numeric output,
	@GUID						Varchar(2000) = '' --Added by nilesh patel on 16062016
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Set @Log_Status = 0

If @Basic_Salary is null
	set @Basic_Salary = 0
Declare @Increment_Id				Numeric
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
Declare @Old_Gross					numeric(18,2) 
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
declare @Salary_Cycle_id			NUMERIC     
declare @Vertical_ID				NUMERIC 
declare @SubVertical_ID				NUMERIC 
declare @subBranch_ID				NUMERIC	
Declare	@Emp_Id			numeric
Declare @Increment_Type	varchar(30)
Declare @Basic_Add_Amt  numeric(18,2)
Declare @Gross_Add_Amt	numeric(18,2)	
Declare @Old_Increment_ID Numeric
Declare @Old_Emp_AD_Amount numeric(18,2)
Declare @Increment_Mode_New	TINYINT 
Declare @Incerment_Amount_gross	NUMERIC(18,2) 
Declare @Incerment_Amount_CTC	NUMERIC(18,2) 
Declare @Old_CTC					numeric(18,2) 
DECLARE @Allow_Same_Date_Increment TINYINT--added by chetan 100817


set  @Increment_Mode_New	 = 0
set  @Incerment_Amount_gross	= 0
set  @Incerment_Amount_CTC	 = 0
SET @Allow_Same_Date_Increment  = 0

	set @Salary_Cycle_id  = 0   
	set @Vertical_ID	  = 0	
	set @SubVertical_ID	  = 0	
	set @subBranch_ID	  = 0	

	Set @Increment_Type = 'Increment'
	Set @Emp_Id = 0
	Set @Basic_Add_Amt = 0
	Set @Gross_Add_Amt = 0
	Set @Old_Increment_ID = 0
	Set @Old_Emp_AD_Amount = 0
			
			Set @Emp_Id = 0
			Select @Emp_Id = Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and Alpha_Emp_Code = @Alpha_Emp_Code
			
			SELECT @Allow_Same_Date_Increment = Isnull(Setting_Value,0) 
			FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID And Setting_Name like 'Allow Same Date Increment'
			
			
			if isnull(@Emp_Id,0) = 0
				Begin
					SET @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Employee Code Does not Exists',GETDATE(),'Enter Correct Employee Code.',GetDate(),'Bulk Increment',@GUID)
					RETURN
				End
			
			if @Increment_Effective_Date IS NULL
				Begin
					SET @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Increment Effective Date Does not Exists',GETDATE(),'Enter Correct Increment Effective Date.',GetDate(),'Bulk Increment',@GUID)
					RETURN
				End
			--Ronakb261223
			IF EXISTS(SELECT Increment_Effective_Date FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0  
            BEGIN  
			SET @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Same Date Entry Exists',GETDATE(),'Select Another Effective Date.',GetDate(),'Bulk Increment',@GUID)
					RETURN
           ---RAISERROR('@@Same Date Entry Exists@@',16,2)  
           RETURN  
           END
			IF @Increment_Mode = '%' 
				Begin
					if @Basic_Salary >= 100
						Begin
							SET @Log_Status = 1
							INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Increment Mode is Percentage(%),Enter Allowance Amount in Percentage:(Basic)',GETDATE(),'Increment Mode is Percentage(%),Enter Allowance Amount in Percentage:(Basic).',GetDate(),'Bulk Increment',@GUID)
							RETURN
						End 
						
					if @Gross_Salary >= 100
						Begin
							SET @Log_Status = 1
							INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Increment Mode is Percentage(%),Enter Allowance Amount in Percentage:(Gross Salary)',GETDATE(),'Increment Mode is Percentage(%),Enter Allowance Amount in Percentage:(Gross Salary).',GetDate(),'Bulk Increment',@GUID)
							RETURN
						End 
						
					if @CTC >= 100
						Begin
							SET @Log_Status = 1
							INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Increment Mode is Percentage(%),Enter Allowance Amount in Percentage:(CTC)',GETDATE(),'Increment Mode is Percentage(%),Enter Allowance Amount in Percentage:(CTC).',GetDate(),'Bulk Increment',@GUID)
							RETURN
						End  
				End 
			
			set @is_yearly_ctc = 0
			select @is_yearly_ctc = cast(isnull(setting_value,0) as tinyint) from T0040_SETTING WITH (NOLOCK) where setting_name = 'IS_YEARLY_CTC' and cmp_id = @Cmp_ID -- added by mitesh on 24/04/2012 for yearly ctc
			
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
				BEGIN TRY
						set @Increment_Date = getdate()

						Select 	@Grd_ID =I.Grd_ID,@Dept_ID =Dept_ID ,
								@Desig_Id = i.Desig_Id,@Type_ID =Type_ID,@Branch_ID=Branch_ID,@Cat_Id=i.Cat_Id,@Bank_ID=Bank_ID
								,@Currency_ID=Curr_ID,@Wages_Type=Wages_Type,@Salary_Basis_On=Salary_Basis_On,@Payment_Mode=Payment_Mode
								,@Inc_Bank_AC_No =Inc_Bank_AC_No,@Emp_OT=Emp_OT,@Emp_OT_Min_Limit=Emp_OT_Min_Limit,@Emp_OT_Max_Limit=Emp_OT_Max_Limit
								,@Increment_Per=Increment_Per,@Increment_Amount=Increment_Amount,
								@Old_Basic= Case When Q.Increment_Date = @Increment_Effective_Date Then i.Pre_Basic_Salary Else i.Basic_Salary END,  --- Change condition by Hardik 17/08/2015 for havmor, they are importing same sheet multi times and record got changed every time
								@Old_Gross = Case When Q.Increment_Date = @Increment_Effective_Date Then i.Pre_Gross_Salary Else Gross_Salary END  --- Change condition by Hardik 17/08/2015 for havmor, they are importing same sheet multi times and record got changed every time
								,@Emp_Late_Mark=Emp_Late_mark,@Emp_Full_PF=Emp_Full_PF,@Emp_PT=Emp_PT
								,@Fix_Salary=Emp_Fix_Salary,@Emp_part_Time=Emp_part_Time,@Late_Dedu_Type=Late_Dedu_Type,@Emp_Late_Limit=Emp_Late_Limit
								,@Emp_PT_Amount=Emp_PT_Amount,@Emp_Childran=Emp_Childran,@Login_ID=Login_ID,@Yearly_Bonus_Amount = Yearly_Bonus_Amount
								,@Deputation_End_Date=Deputation_End_Date,@Basic_Per = gm.Basic_Percentage,@Calc_On=gm.Basic_Calc_On
								,@auto_vpf=Emp_Auto_Vpf,@Salary_Cycle_id = SalDate_id,@Vertical_ID = Vertical_ID,@SubVertical_ID =SubVertical_ID,@subBranch_ID = subBranch_ID -- Added By Gadriwala 07042014
								,@Old_Increment_ID = Increment_ID ,
								@Old_CTC = Case When Q.Increment_Date = @Increment_Effective_Date Then i.Pre_CTC_Salary Else i.CTC END  --- Change condition by Hardik 17/08/2015 for havmor, they are importing same sheet multi times and record got changed every time
						From T0095_INCREMENT i WITH (NOLOCK) inner join 
							( select max(increment_Effective_Date) Increment_Date ,Emp_ID from T0095_INCREMENT WITH (NOLOCK)
								where increment_effective_Date <=@Increment_Effective_Date and emp_ID = @Emp_ID 
								group by emp_ID ) Q on i.emp_ID = Q.emp_ID and i.increment_Effective_Date = q.increment_date inner join
								T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID = i.Grd_ID
						
								
						SELECT @AD_Rounding = AD_Rounding FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
						AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
										  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)

						Set @Increment_Amount = 0
						
						IF @Increment_Mode = '%'
							Begin
								Set @Increment_Mode_New = 0
								
								If @Basic_Salary <> 0
									Begin
										set @Increment_Amount = @Basic_Salary
						
										Set @Basic_Add_Amt = ( @Old_Basic * @Basic_Salary ) / 100
										Set @Basic_Salary  = @Old_Basic + @Basic_Add_Amt
									End
								If @Gross_Salary <> 0
									Begin	
										set @Incerment_Amount_gross = @Gross_Salary

										Set @Gross_Add_Amt = (@Old_Gross * @Gross_Salary) / 100
										Set @Gross_Salary  = @Gross_Add_Amt + @Old_Gross
									
									End
							End
						Else If @Increment_Mode = 'Amt'
							Begin
								Set @Increment_Mode_New = 1
								
								IF @Basic_Salary <> 0
									Begin
										Set @Increment_Amount = @Basic_Salary
										
										Set @Basic_Add_Amt = @Old_Basic + @Basic_Salary
										Set @Basic_Salary  = @Basic_Add_Amt
									End
								If @Gross_Salary <> 0
									Begin
										set @Incerment_Amount_gross = @Gross_Salary
									
										Set @Gross_Add_Amt = @Old_Gross + @Gross_Salary
										Set @Gross_Salary  = @Gross_Add_Amt
									End	
							End
						
						If @Basic_Salary = 0
							Begin 
								if @Calc_On = 'CTC' And @Basic_Per > 0
									begin
										Set @Incerment_Amount_CTC =  @CTC
										
										If @AD_Rounding = 1
											Begin 
												set @Basic_Salary = isnull(Round(((@CTC + @Old_CTC ) * @Basic_Per)/100,0),0)
											End
										Else
											Begin 
												set @Basic_Salary = isnull(((@CTC + @Old_CTC ) * @Basic_Per)/100,0)
											ENd
									end	
								else if @Calc_On = 'Gross' And @Basic_Per > 0
									begin
									
										If @AD_Rounding = 1
											Begin
												set @Basic_Salary = isnull(Round((@Gross_Salary * @Basic_Per)/100,0),0)
											End
										Else
											Begin
												set @Basic_Salary = isnull((@Gross_Salary  * @Basic_Per)/100,0)
											End
									end
								Else
									Begin
										set @Basic_Salary = @Old_Basic
									End
								Set @CTC = @CTC + @Old_CTC
									
							End			

						
						if ISNULL(@Vertical_ID,0) = 0 
							set @Vertical_ID = 0
						if ISNULL(@SubVertical_ID,0) = 0 
							set @SubVertical_ID = 0
						if ISNULL(@subBranch_ID,0) = 0
							set @subBranch_ID = 0
						if ISNULL(@Salary_Cycle_id,0) = 0
							set @Salary_Cycle_id = 0
						 
						if @Gross_Salary = 0
							begin
								Set @Gross_Salary = @old_Gross
							end
						
						--If @Basic_Salary > 0 
						--	set @Increment_Amount = @Basic_Salary - @Old_Basic
							
						--if @Old_BAsic > 0 
						--	set @Increment_Per  = round(Isnull(@Increment_Amount,0) * 100 /@Old_Basic,2)
						--else if @Basic_Salary > 0
						--	set @Increment_Per =100				
							
							
						declare @allow_Dedu_ID numeric 
						Declare @Mode varchar(10)
						declare @Amount numeric 
						Declare @Percentage numeric (18,2)
						declare @max_Upper	numeric
						declare @Flag varchar(1)
						declare @Row_ID numeric 
						Declare @Month numeric 
						set @Increment_ID = 0
												
						If not exists(select Emp_ID from T0095_INCREMENT WITH (NOLOCK) where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date and @Allow_Same_Date_Increment = 0)
							Begin 						
								
									if @Increment_Type <> 'Joining'
										begin
																						
											--EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_id,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Currency_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary
											--	,@Increment_Type,@Increment_Date,@Increment_effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Old_Basic,@Old_Gross,''
											--	,@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_part_Time,0,@Login_ID,@Yearly_Bonus_Amount,@Deputation_End_Date,0,1,0,@CTC,@Salary_Cycle_id = @Salary_Cycle_id,@auto_vpf=@auto_vpf,@Vertical_ID =@Vertical_ID,@SubVertical_ID =@SubVertical_ID,@subBranch_ID = @subBranch_ID -- Added by Gadriwala muslim 07042013						

											EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_id,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Currency_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary
											,@Increment_Type,@Increment_Date,@Increment_effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Old_Basic,@Old_Gross,''
											,@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_part_Time,0,@Login_ID,@Yearly_Bonus_Amount,@Deputation_End_Date,0,1,0,@CTC = @CTC,@Pre_CTC_Salary = @Old_CTC,@Incerment_Amount_gross = @Incerment_Amount_gross ,@Incerment_Amount_CTC = @Incerment_Amount_CTC,@Increment_Mode = @Increment_Mode_New,@Salary_Cycle_id = @Salary_Cycle_id,@auto_vpf=@auto_vpf,@Vertical_ID =@Vertical_ID,@SubVertical_ID =@SubVertical_ID,@subBranch_ID = @subBranch_ID
										
											
											
											Update T0080_EMP_MASTER set Basic_Salary = @Basic_Salary   WHERE Increment_Id = @Increment_Id
											
											Declare @CurAD_Id	Numeric 
											Declare @CurrAD_Amount Numeric(18,2)
											Declare @CurrAD_Per Numeric(18,2)
											Declare @Allow_Name as nvarchar(100)
									
											Set @CurAD_Id	= 0
											Set @CurrAD_Amount = 0
											Set @CurrAD_Per = 0
											
											Declare CusrAllow cursor for	                 
												Select E.Ad_ID,E_Ad_Amount,E_AD_Percentage From T0100_EMP_EARN_DEDUCTION E WITH (NOLOCK) INNER JOIN T0050_AD_MASTER A WITH (NOLOCK) on E.AD_ID=A.AD_ID
												Where Emp_ID = @Emp_Id And Increment_Id = @Old_Increment_Id
												ORDER by A.AD_LEVEL
											Open CusrAllow
													Fetch next from CusrAllow into @CurAD_Id,@CurrAD_Amount,@CurrAD_Per
													While @@fetch_status = 0                    
													Begin 
													
														Select @Allow_Name = Ad_Name From T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = @Cmp_ID And AD_ID = @CurAD_Id
														
														If @CurrAD_Per > 0 
															Begin
																Exec SP_Import_Allow_Deduct_Data @Cmp_ID,@Emp_Id,@Increment_Id,@Increment_Effective_Date,@Allow_Name,@CurrAD_Per,0,0
															End
														Else
															Begin
																Exec SP_Import_Allow_Deduct_Data @Cmp_ID,@Emp_Id,@Increment_Id,@Increment_Effective_Date,@Allow_Name,@CurrAD_Amount,0,0
															End
														
														fetch next from CusrAllow into @CurAD_Id,@CurrAD_Amount,@CurrAD_Per	
													End
												Close CusrAllow                    
											Deallocate CusrAllow
											
											Exec Update_Gross_Amount @Cmp_ID,@Emp_Id,@Increment_Id
											Exec Update_PT_Amount @Cmp_ID,@Emp_Id,@Increment_Id
											
										end	
									else
										begin
											
											Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Problem with Increment Type',@Increment_effective_Date,'Enter proper Increment Type,May be it is Increment of Employee',GetDate(),'Bulk Increment',@GUID)
											set @Log_Status = 1
								
										end
										
														
							end
						Else
							Begin					
								
								Declare @PT_Amount			numeric 
								Declare @AD_Other_Amount	numeric 
								Declare @Max_Increment_ID	numeric 
								Declare @Max_Shift_ID numeric
								Declare @Current_Date datetime
								
								set @Current_Date = getdate()
								set @PT_Amount = 0
								
								select @Increment_Id=Increment_Id from T0095_INCREMENT WITH (NOLOCK)
								where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date
						
								if @Emp_PT = 1
									begin
								
											Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
											set @AD_Other_Amount = @Basic_Salary + isnull(@AD_Other_Amount,0)
											
										Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@AD_Other_Amount,@PT_Amount output,'',@Branch_ID
									end
								
								Update T0095_INCREMENT set Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary , ctc = @ctc, Incerment_Amount_gross = @Incerment_Amount_gross,Emp_PT_Amount = @PT_Amount, Grd_ID = @Grd_ID,Dept_ID =@Dept_ID,Desig_Id=@Desig_Id where emp_id =@Emp_ID and increment_Effective_date = @Increment_Effective_date 
								Update T0080_EMP_MASTER set Basic_Salary = @Basic_Salary   WHERE Increment_Id = @Increment_Id       
								
							end
							
			END TRY
			BEGIN CATCH
							
				
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,ERROR_MESSAGE(),@Increment_Effective_date,'Please Check Increment Increment Mode,Basic Salary or Gross Salary data',GetDate(),'Bulk Increment',@GUID)
				set @Log_Status = 1

			END CATCH;
	RETURN

