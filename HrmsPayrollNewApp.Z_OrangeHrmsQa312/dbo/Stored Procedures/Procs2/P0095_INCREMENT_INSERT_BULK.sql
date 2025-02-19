


-- =============================================
-- Author:		<Ankit>
-- Create date: <30052014,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_INCREMENT_INSERT_BULK]
    @Increment_ID				NUMERIC(18,0) OUTPUT,
	@Cmp_ID						Numeric, 
	@Emp_Id						Numeric, 
	@Increment_Effective_Date	Datetime,
	@Increment_Mode				Varchar(30),
	@Increment_Basic			Numeric(18,2),
	@Increment_Gross			Numeric(18,2),
	@Increment_CTC				Numeric(18,2),
	@ReasonID					Numeric(5,0) = 0,
	@ReasonName				    Varchar(200) = '',
	@tran_type					Varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


If @Increment_Basic is null
	set @Increment_Basic = 0


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
Declare @Old_CTC					numeric(18,2) 
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
Declare @auto_vpf					char(1) 
Declare @Bank_Ac_no					varchar(20)
Declare @Basic_Per					numeric(18,0)
Declare @Calc_On					varchar(20)
Declare @AD_Rounding				INT
Declare @is_yearly_ctc				tinyint
Declare @Salary_Cycle_id			NUMERIC    
Declare @Vertical_ID				NUMERIC 
Declare @SubVertical_ID				NUMERIC 
Declare @subBranch_ID				NUMERIC	
Declare @Increment_Type	varchar(30)
Declare @Basic_Add_Amt  numeric(18,2)
Declare @Gross_Add_Amt	numeric(18,2)	
Declare @Old_Increment_ID Numeric
Declare @Old_Emp_AD_Amount numeric(18,2)
Declare @New_CTC		Numeric(18,2)
Declare @Increment_Mode_New	TINYINT 
Declare @Incerment_Amount_gross	NUMERIC(18,2) 
Declare @Incerment_Amount_CTC	NUMERIC(18,2) 
Declare @Increment_Basic_Temp	Numeric(18,2)
Declare @Increment_Diff_CTC		Numeric(18,2)

set @Increment_Basic_Temp = ISNULL(@Increment_Basic,0)

set @Increment_Diff_CTC = 0
set @Increment_Mode_New = 0
SET  @Incerment_Amount_gross	= 0
SET  @Incerment_Amount_CTC	 = 0
set @Salary_Cycle_id  = 0    
set @Vertical_ID	  = 0	 
set @SubVertical_ID	  = 0	 
set @subBranch_ID	  = 0	 
Set @Increment_Type = 'Increment'
Set @Basic_Add_Amt = 0
Set @Gross_Add_Amt = 0
Set @Old_Increment_ID = 0
Set @Old_Emp_AD_Amount = 0
Set @New_CTC = 0

if @ReasonName = ''
	Set @ReasonName = NULL
		
	  DECLARE @Allow_Same_Date_Increment TINYINT		--Ankit 17022015
	  SET @Allow_Same_Date_Increment  = 0
	  
	  SELECT @Allow_Same_Date_Increment = Isnull(Setting_Value,0) 
	  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID And Setting_Name like 'Allow Same Date Increment'

		
	  IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT WITH (NOLOCK)  WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0
		BEGIN
			RAISERROR('@@Duplicate Date Entry Does Not Allow@@',16,2)
			RETURN
		END
		
		Set @is_yearly_ctc = 0
		Select @is_yearly_ctc = cast(isnull(setting_value,0) as tinyint) from T0040_SETTING WITH (NOLOCK) where setting_name = 'IS_YEARLY_CTC' and cmp_id = @Cmp_ID -- added by mitesh on 24/04/2012 for yearly ctc
			
			If isnull(@is_yearly_ctc,0) = 1
				Begin
					If @AD_Rounding = 1
						Begin 
							SET @Increment_CTC = ISNULL(ROUND(@Increment_CTC / 12,0),0)
						End
					Else
						Begin
							SET @Increment_CTC = @Increment_CTC / 12
						End
				End
				
			set @Increment_Date = getdate()
			Set @Increment_Diff_CTC = @Increment_CTC
			Select 	@Grd_ID =I.Grd_ID,@Dept_ID =Dept_ID ,
					@Desig_Id = i.Desig_Id,@Type_ID =Type_ID,@Branch_ID=Branch_ID,@Cat_Id=i.Cat_Id,@Bank_ID=Bank_ID
					,@Currency_ID=Curr_ID,@Wages_Type=Wages_Type,@Salary_Basis_On=Salary_Basis_On,@Payment_Mode=Payment_Mode
					,@Inc_Bank_AC_No =Inc_Bank_AC_No,@Emp_OT=Emp_OT,@Emp_OT_Min_Limit=Emp_OT_Min_Limit,@Emp_OT_Max_Limit=Emp_OT_Max_Limit
					,@Increment_Per=Increment_Per,@Increment_Amount=Increment_Amount,@Old_Basic=Basic_salary,@Old_Gross=Gross_Salary,@Old_CTC = CTC
					,@Emp_Late_Mark=Emp_Late_mark,@Emp_Full_PF=Emp_Full_PF,@Emp_PT=Emp_PT
					,@Fix_Salary=Emp_Fix_Salary,@Emp_part_Time=Emp_part_Time,@Late_Dedu_Type=Late_Dedu_Type,@Emp_Late_Limit=Emp_Late_Limit
					,@Emp_PT_Amount=Emp_PT_Amount,@Emp_Childran=Emp_Childran,@Login_ID=Login_ID,@Yearly_Bonus_Amount = Yearly_Bonus_Amount
					,@Deputation_End_Date=Deputation_End_Date,@Basic_Per = gm.Basic_Percentage,@Calc_On=gm.Basic_Calc_On
					,@auto_vpf=Emp_Auto_Vpf,@Salary_Cycle_id = SalDate_id,@Vertical_ID = Vertical_ID,@SubVertical_ID =SubVertical_ID,@subBranch_ID = subBranch_ID -- Added By Gadriwala 07042014
					,@Old_Increment_ID = I.Increment_ID
			From T0095_INCREMENT i WITH (NOLOCK) inner join 
				( select max(Increment_ID) increment_ID ,Emp_ID from T0095_INCREMENT WITH (NOLOCK) -- Ankit 11092014 for Same Date Increment
					where increment_effective_Date <=@Increment_Effective_Date and emp_ID = @Emp_ID 
					group by emp_ID ) Q on i.emp_ID = Q.emp_ID and i.increment_ID = q.increment_ID inner join
					T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID = i.Grd_ID
			
					
			SELECT @AD_Rounding = AD_Rounding FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
			AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
							  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)

		    IF @Increment_Mode = '%'
				Begin
					Set @Increment_Mode_New = 0
					
					--IF @Increment_Basic > 0
						Begin
							set @Increment_Amount = @Increment_Basic
								
							Set @Basic_Add_Amt = ( @Old_Basic * @Increment_Basic ) / 100
							Set @Increment_Basic  = @Old_Basic + @Basic_Add_Amt
						End
					--If @Increment_Gross > 0
						Begin
							set @Incerment_Amount_gross = @Increment_Gross
							
							Set @Gross_Add_Amt = (@Old_Gross * @Increment_Gross) / 100
							Set @Increment_Gross  = @Old_Gross + @Gross_Add_Amt
						End
						
					IF 	@Increment_CTC <> 0
						Begin
							Declare @CTC_Add_Amt Numeric(18,2)
							Set @CTC_Add_Amt = 0
							
							Set @CTC_Add_Amt = (@Old_CTC * @Increment_CTC) / 100
							Set @Incerment_Amount_CTC  = @Old_CTC + @CTC_Add_Amt
							
						End	
						
				End
			Else If @Increment_Mode = 'Amt'
				Begin
					Set @Increment_Mode_New = 1
					
					IF @Increment_Basic <> 0
						Begin
							Set @Increment_Amount = @Increment_Basic
								
							Set @Basic_Add_Amt = @Old_Basic + @Increment_Basic
							Set @Increment_Basic  = @Basic_Add_Amt
						End
					
					If @Increment_Gross <> 0
						Begin	
							set @Incerment_Amount_gross = @Increment_Gross
							
							Set @Gross_Add_Amt = @Old_Gross + @Increment_Gross
							Set @Increment_Gross  = @Gross_Add_Amt
						End
					
					IF 	@Increment_CTC <> 0
						Begin
							Set @Incerment_Amount_CTC = @Increment_CTC + ISNULL(@Old_CTC,0)
						End	
				End


			If @Increment_Basic_Temp = 0 --@Increment_Basic = 0
				Begin 
					If @Calc_On = 'CTC' and @Basic_Per >0 
						begin
							
							If @AD_Rounding = 1
								Begin 
									Set @Increment_Basic =  isnull(Round(( (@Incerment_Amount_CTC) * @Basic_Per)/100,0),0)
								End
							Else
								Begin 
									Set @Increment_Basic =  isnull(((@Incerment_Amount_CTC) * @Basic_Per)/100,0)
								ENd
							
							--Set @Incerment_Amount_CTC =  @Increment_CTC
							
							--If @AD_Rounding = 1
							--	Begin 
							--		Set @Increment_Basic =  isnull(Round(( (@Increment_CTC + @Old_CTC) * @Basic_Per)/100,0),0)
							--	End
							--Else
							--	Begin 
							--		Set @Increment_Basic =  isnull(((@Increment_CTC + @Old_CTC) * @Basic_Per)/100,0)
							--	ENd
						end	
					Else if @Calc_On = 'Gross' and @Basic_Per >0
						begin
							If @AD_Rounding = 1
								Begin
									set @Increment_Basic = isnull(Round((@Increment_Gross * @Basic_Per)/100,0),0)
								End
							Else
								Begin
									set @Increment_Basic = isnull((@Increment_Gross * @Basic_Per)/100,0)
								End
						end
					Else
						Begin
							set @Increment_Basic = @Old_Basic
						End
						
					Set @Increment_CTC = @Incerment_Amount_CTC--@Increment_CTC + @Old_CTC
				End			
																
			If ISNULL(@Vertical_ID,0) = 0 
				set @Vertical_ID = 0
			if ISNULL(@SubVertical_ID,0) = 0 
				set @SubVertical_ID = 0
			if ISNULL(@subBranch_ID,0) = 0
				set @subBranch_ID = 0
			if ISNULL(@Salary_Cycle_id,0) = 0
				set @Salary_Cycle_id = 0
			 
			if @Increment_Gross = 0
				begin
					Set @Increment_Gross = @old_Gross
				end
			
			--If @Increment_Basic > 0 
			--	set @Increment_Amount = @Increment_Basic - @Old_Basic
				
			If @Old_Basic > 0 
				set @Increment_Per  = round(Isnull(@Increment_Amount,0) * 100 /@Old_Basic,2)
			Else if @Increment_Basic > 0
				set @Increment_Per =100				
				
			--Added by Gadriwala Muslim 12102014 - Start	
				Declare @Basic_Salary_Upper_Rounding numeric  
				Declare @Basic_Salary_Rounding_Amount numeric(18,2)
			    set @Basic_Salary_Upper_Rounding = 0  
				set @Basic_Salary_Rounding_Amount = 0
				Select @Basic_Salary_Upper_Rounding = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK)
				where Cmp_ID=@Cmp_ID and Setting_Name='Bulk Increment Basic Salary Upper Rouning'
	 
			IF @Basic_Salary_Upper_Rounding > 0 
				begin
					if  (@Increment_Basic % @Basic_Salary_Upper_Rounding)  > 0
						begin
							set  @Basic_Salary_Rounding_Amount =  @Basic_Salary_Upper_Rounding - (@Increment_Basic % @Basic_Salary_Upper_Rounding)
							set  @Increment_Basic =  @Increment_Basic + @Basic_Salary_Rounding_Amount
							set	 @Increment_Amount =  @Increment_Amount + @Basic_Salary_Rounding_Amount
						end
				end	
			--Added by Gadriwala Muslim 12102014 - End	
			
			Declare @allow_Dedu_ID numeric 
			Declare @Mode varchar(10)
			declare @Amount numeric 
			Declare @Percentage numeric (18,2)
			Declare @max_Upper	numeric
			
				set @Increment_ID = 0
				
				Declare @EntType Numeric
				SET @EntType = 0
					
				--IF @Increment_Type <> 'Joining' 
				--	BEGIN
				--		IF UPPER(@Entry_Type) = UPPER('Update')
				--			SET @EntType = 1
				--	END
										
			If not exists(select Emp_ID from T0095_INCREMENT WITH (NOLOCK) where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date  And @EntType = 1)
				Begin 						
					If @Increment_Type <> 'Joining'
						Begin
							--Insert Increment
							EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_id,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Currency_ID,@Wages_Type,@Salary_Basis_On,@Increment_Basic,@Increment_Gross
								,@Increment_Type,@Increment_Date,@Increment_effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Old_Basic,@Old_Gross,''
								,@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_part_Time,0,@Login_ID,@Yearly_Bonus_Amount,@Deputation_End_Date,0,1,0,@CTC = @Increment_CTC,@Pre_CTC_Salary = @Old_CTC,@Incerment_Amount_gross = @Incerment_Amount_gross ,@Incerment_Amount_CTC = @Increment_Diff_CTC,@Increment_Mode = @Increment_Mode_New,@Salary_Cycle_id = @Salary_Cycle_id,@auto_vpf=@auto_vpf,@Vertical_ID =@Vertical_ID
								,@SubVertical_ID =@SubVertical_ID,@subBranch_ID = @subBranch_ID,@Reason_ID = @ReasonID,@Reason_Name= @ReasonName
							
							Update T0080_EMP_MASTER set Basic_Salary = @Increment_Basic   WHERE Increment_Id = @Increment_Id
							
							--Insert Employee Earn/Dedu 
							Declare @CurAD_Id	Numeric 
							Declare @CurrAD_Amount Numeric(18,2)
							Declare @CurrAD_Per Numeric(18,5)-- Changed by Gadriwala Muslim 19032015
							Declare @Allow_Name as nvarchar(100)
							
							Set @CurAD_Id	= 0
							Set @CurrAD_Amount = 0
							Set @CurrAD_Per = 0
							
							CREATE TABLE #tblAllow
								(
								  row_id NUMERIC(18) IDENTITY(1,1) ,
								  Emp_id NUMERIC(18) ,
								  Increment_id NUMERIC(18) ,
								  AD_ID NUMERIC(18) ,
								  E_AD_Percentage NUMERIC(12, 5) ,
								  E_Ad_Amount NUMERIC(12, 5) ,
								)
								
							----Start-- Revised Salary get Allow/Dedu Detail --Ankit 11092014
		
							INSERT  INTO #tblAllow
									SELECT  EED.EMP_ID ,@Old_Increment_Id AS Increment_id ,EED.AD_ID ,
											Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End As E_AD_Percentage,
											Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount
									FROM    dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
											INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID LEFT OUTER JOIN
											( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
												From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
												( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
													Where Emp_Id = @Emp_Id
													And For_date <= @Increment_Effective_Date 
												 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
											) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID
									WHERE   EEd.emp_id = @Emp_Id AND Adm.AD_ACTIVE = 1
											And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
											And INCREMENT_ID = @Old_Increment_Id
			                        
									Union ALL
			                        
									SELECT  EED.EMP_ID ,@Old_Increment_Id AS Increment_id ,EED.AD_ID ,
											E_AD_Percentage ,E_AD_Amount
									FROM    dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK)
											INNER JOIN ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
													Where Emp_Id = @Emp_Id And For_date <= @Increment_Effective_Date 
													Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id 
											INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID
											--INNER JOIN dbo.T0080_EMP_MASTER AS EM ON EED.Emp_ID = EM.Emp_ID
			                        
									WHERE   EED.EMP_ID = @Emp_Id AND Adm.AD_ACTIVE = 1 And EEd.ENTRY_TYPE = 'A'
								
			                    ----End-- Revised Salary get Allow/Dedu Detail --Ankit 11092014	   

															
							Declare CusrAllow cursor for	                 
								--Select Ad_ID,E_Ad_Amount,E_AD_Percentage From T0100_EMP_EARN_DEDUCTION Where Emp_ID = @Emp_Id And Increment_Id = @Old_Increment_Id
								Select Ad_ID,E_Ad_Amount,E_AD_Percentage From #tblAllow Where Emp_ID = @Emp_Id And Increment_Id = @Old_Increment_Id
								
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
							
						End	
						
				End
			Else
				Begin					
					Declare @PT_Amount			numeric 
					Declare @AD_Other_Amount	numeric 
					Declare @Max_Increment_ID	numeric 
					Declare @Max_Shift_ID numeric
					Declare @Current_Date datetime
					
					Set @Current_Date = getdate()
					Set @PT_Amount = 0
					
					--Select @Increment_Id=Increment_Id from T0095_INCREMENT 
					--Where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date
					
					Select @Increment_Id = I.Increment_ID from T0095_INCREMENT i WITH (NOLOCK)
						INNER JOIN (SELECT MAX(Increment_ID) Increment_ID, Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE increment_effective_Date <= @Increment_Effective_Date AND emp_ID = @Emp_ID 
										GROUP BY emp_ID
									) Q 
						ON i.emp_ID = Q.emp_ID AND i.Increment_ID = q.Increment_ID 
					Where I.Emp_ID =@Emp_ID and Increment_effective_Date = @Increment_effective_Date 
					
					If @Emp_PT = 1
						Begin
								Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
								set @AD_Other_Amount = @Increment_Basic + isnull(@AD_Other_Amount,0)
								
							Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@AD_Other_Amount,@PT_Amount output,'',@Branch_ID
						End
					
					Update T0095_INCREMENT set Basic_Salary = @Increment_Basic, Gross_Salary = @Increment_Gross , ctc = @Increment_CTC, Emp_PT_Amount = @PT_Amount, Grd_ID = @Grd_ID,Dept_ID =@Dept_ID,Desig_Id=@Desig_Id,Reason_ID = @ReasonID,Reason_Name= @ReasonName where emp_id =@Emp_ID and increment_Effective_date = @Increment_Effective_date
					Update T0080_EMP_MASTER set Basic_Salary = @Increment_Basic   WHERE Increment_Id = @Increment_Id       
					
				End
				
			
	RETURN
