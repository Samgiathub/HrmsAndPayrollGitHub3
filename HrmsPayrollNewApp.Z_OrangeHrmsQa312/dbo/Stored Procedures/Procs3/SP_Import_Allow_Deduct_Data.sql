CREATE PROCEDURE [dbo].[SP_Import_Allow_Deduct_Data]
	 @Cmp_Id as numeric 
	,@Emp_Id as numeric
	,@Increment_Id as Numeric(18,0)
	,@For_Date as datetime
	,@Allow_Type as nvarchar(100)
	,@Amount as numeric(18,5) -- Changed by Gadriwala Muslim 19032015
	,@Row_No as numeric
	,@Log_Status as numeric output
	,@GUID	Varchar(2000) = '' --Added by nilesh patel 
	,@IP_Address varchar(30)= '' --Added By Mukti 01072016
AS
	
	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	BEGIN TRY
	
				Set @Log_Status = 0
				
				Declare @Row_ID as Numeric(18,0)
				Declare @AD_ID as numeric
				Declare @E_AD_FLAG as char(1)
				Declare @E_AD_MODE as varchar(10)
				Declare @E_AD_PERCENTAGE as numeric(18,5)-- Changed by Gadriwala Muslim 19032015
				Declare @E_AD_MAX_LIMIT as  numeric
				Declare @E_AD_AMOUNT as numeric(18,2)
				Declare @HAS_SEL_GRADE as numeric
				Declare @EMP_GRADE as numeric
				Declare @AD_VALID as numeric		
				Declare @Temp_E_AD_Amount Numeric(18,2)
				declare @is_yearly tinyint
				declare @Not_Effect_on_Basic_Calculation tinyint
				
				
				
				set @is_yearly = 0
				set @Not_Effect_on_Basic_Calculation =0
		
				Set @HAS_SEL_GRADE = 0			
				set @Temp_E_AD_Amount = 0.0
				
				DECLARE @Alpha_Emp_Code	VARCHAR(50)
				SELECT @Alpha_Emp_Code = Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_Id
				
				--Select @EMP_GRADE=Grd_ID from T0080_EMP_MASTER where Cmp_ID = @Cmp_Id and Emp_ID = @Emp_Id
				-- Changed By Gadriwala Muslim 26052014
				select 	@EMP_GRADE =isnull(I.Grd_ID,0) from T0095_INCREMENT i inner join	-- Ankit 11092014 for Same Date Increment
							( select max(increment_ID) increment_ID ,Emp_ID from T0095_INCREMENT WITH (NOLOCK)
								where increment_effective_Date <=@For_Date and emp_ID = @Emp_ID 
								group by emp_ID ) Q on i.emp_ID = Q.emp_ID and i.increment_ID = q.increment_ID inner join
								T0040_GRADE_MASTER gm on gm.Grd_ID = i.Grd_ID
					
				set @Allow_Type = Rtrim(@Allow_Type)				
				set @Allow_Type = ltrim(@Allow_Type)
				
				
				
				select @AD_ID=AD_ID,@E_AD_FLAG=AD_FLAG,--@E_AD_MODE=AD_MODE,@E_AD_PERCENTAGE=AD_PERCENTAGE,@E_AD_MAX_LIMIT=AD_MAX_LIMIT, 
						@is_yearly = Is_Yearly , @Not_Effect_on_Basic_Calculation = Not_Effect_on_Basic_Calculation
				from T0050_AD_MASTER WITH (NOLOCK) Where AD_NAME = @Allow_Type and Cmp_ID = @Cmp_Id
				
				if isnull(@AD_ID,0) = 0 
					begin
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code,'Allowance Details Date Does Not Exists.',GETDATE(),'Verify Allowance Details With Allowance Master',GetDate(),'Earn\Ded Data',@GUID)
						set @Log_Status = 1
					end 
				
				Select @E_AD_MODE=AD_MODE ,@E_AD_MAX_LIMIT=isnull(AD_MAX_LIMIT,0) ,@E_AD_PERCENTAGE=AD_PERCENTAGE	--Ankit 06012014
				From T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) Where cmp_id = @Cmp_Id and Ad_ID = @AD_ID and Grd_ID=@EMP_GRADE
				
				-- Added by nilesh patel on 08042016 For Percentage Validation (For Import Allowance Details) -- Start
				if @E_AD_MODE = '%' 
					Begin
						if @Amount > 999.99
							Begin
								Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,''+ @Allow_Type + '('+ @Alpha_Emp_Code + ')',@For_Date,'Enter valid data in allowance percentage',GetDate(),'Earn\Ded Data',@GUID)
								Exec P0095_INCREMENT_DELETE @Increment_ID,@Emp_Id,@Cmp_Id
								set @Log_Status = 2
								Return
							End
					End
				-- Added by nilesh patel on 08042016 For Percentage Validation (For Import Allowance Details)  -- End
				
				if @AD_ID > 0
					begin
						
						Select @HAS_SEL_GRADE = COUNT(*) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) Where cmp_id = @Cmp_Id and Ad_ID = @AD_ID
						
						if @HAS_SEL_GRADE > 0 
							begin
								if @Amount >= 0
								begin
									Select @AD_VALID = COUNT(*) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) Where cmp_id = @Cmp_Id and Ad_ID = @AD_ID and Grd_ID = @EMP_GRADE				
								end
								else
								begin
									SET @AD_VALID = 1
								end
							end
						else
							begin
								SET @AD_VALID = 1
							end

						BEGIN TRY
								if @E_AD_MODE = '%'
									begin
										SET @E_AD_PERCENTAGE = @Amount
										SET @E_AD_AMOUNT = 0			
									end
								else
									begin
										SET @E_AD_AMOUNT = @Amount
										SET @E_AD_PERCENTAGE = 0
									end
								
								set @Row_ID = 0
									
								if @AD_VALID > 0
									begin		
										if EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @CMP_ID AND Emp_ID = @EMP_ID  AND AD_ID=@AD_ID AND INCREMENT_ID=@Increment_Id)
											Begin
												Delete FROM T0100_EMP_EARN_DEDUCTION WHERE cmp_ID = @CMP_ID AND Emp_ID = @EMP_ID  AND AD_ID=@AD_ID AND INCREMENT_ID=@Increment_Id
											end
								
										if @is_yearly = 1 and @Not_Effect_on_Basic_Calculation = 1
												BEGIN
												
													Declare @Basic_Calc_On  nvarchar(20)
													Declare @Basic_Per  numeric(18,2)
													Declare @YAllow_amount  numeric(18,2)
													Declare @Yearly_Setting tinyint
													Declare @basic_val numeric(18,2)
													Declare @ctc_inc numeric(18,2)
													Declare @branch_id numeric
													Declare @AD_Rounding int
													
													set @Basic_Calc_On = ''
													set @YAllow_amount  = 0
													set @Yearly_Setting = 0
													set @basic_val = 0 
													set @ctc_inc  = 0
													
													
													select	@ctc_inc = CTC,@branch_id = Branch_ID from T0095_INCREMENT WITH (NOLOCK) where Increment_ID = @Increment_Id and Emp_ID = @Emp_Id
													
													SELECT @AD_Rounding = AD_Rounding FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
														AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
														WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
													
													Select  @Basic_Calc_On = isnull(Basic_Calc_On,''),@Basic_Per =Basic_Percentage  from T0040_Grade_Master WITH (NOLOCK) where Grd_ID= @EMP_GRADE and Cmp_ID = @Cmp_Id	
													
													
													
													if @Basic_Calc_On = 'CTC'
														begin															
															select @YAllow_amount = isnull(sum(E_AD_YEARLY_AMOUNT),0) from t0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where ad_id in (select AD_ID from t0050_ad_master WITH (NOLOCK) where not_effect_on_basic_calculation = 1 and ad_id in ( select distinct ad_id from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where  Grd_ID= @EMP_GRADE and Cmp_ID= @Cmp_Id) and Cmp_ID=@Cmp_Id) and emp_id = @Emp_Id																	
															
															select @Yearly_Setting = cast(isnull(setting_value,0) as tinyint) from T0040_SETTING WITH (NOLOCK) where setting_name = 'IS_YEARLY_CTC' and cmp_id = @Cmp_Id
															set @YAllow_amount = isnull(@YAllow_amount,0) + isnull(@Amount,0)												
															
															if @Yearly_Setting = 1
																Begin
																	if @AD_Rounding = 1
																		begin
																			set @basic_val =   isnull(Round(((@Basic_Per * ((@ctc_inc * 12) - @YAllow_amount))/100)/12,0),0)
																		end
																	else
																		begin
																			set @basic_val =   isnull(((@Basic_Per * ((@ctc_inc * 12) - @YAllow_amount))/100)/12,0)
																		end
																		
																	update T0095_INCREMENT set Basic_Salary = @basic_val where Increment_ID = @Increment_Id
																	update T0080_EMP_MASTER set Basic_Salary = @basic_val where Emp_ID = @Emp_Id
																		
																End
															
														end
												END	
												
												If @Amount >=0 or @Amount = -1
													Begin
													
														exec P0100_EMP_EARN_DEDUCTION @Row_Id output,@EMP_ID,@CMP_ID,@AD_ID,@Increment_Id,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,'I','',@Emp_Id,@IP_Address
													End
												Else
													Begin
														Select @Row_ID = Ad_Tran_Id From T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) Where AD_ID = @AD_ID And INCREMENT_ID = @Increment_Id
												
														If @Row_ID > 0 
															exec P0100_EMP_EARN_DEDUCTION @Row_Id output,@EMP_ID,@CMP_ID,@AD_ID,@Increment_Id,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,'D','',@Emp_Id,@IP_Address
													End
										
										--select @Temp_E_AD_Amount = Sum(ISNULL(E_AD_AMOUNT,0)) from T0100_EMP_EARN_DEDUCTION EED Inner Join T0050_AD_MASTER AD On EED.AD_ID = AD.AD_ID
										--	where AD.AD_FLAG = 'I' And AD.AD_NOT_EFFECT_SALARY = 0 and AD.AD_PART_OF_CTC = 1 and EED.EMP_ID = @Emp_Id and EED.CMP_ID = @Cmp_Id
											
										--Update T0095_INCREMENT set Gross_salary = Basic_salary + @Temp_E_AD_Amount where INCREMENT_ID=@Increment_Id AND Emp_ID = @EMP_ID
										
									end
								Else
									Begin										
										Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,''+ @Allow_Type + '('+ @Alpha_Emp_Code + ')',@For_Date,'Assign Grade in Allowance Master  ' + @Allow_Type ,GetDate(),'Earn\Ded Data',@GUID)
									End
							
						END TRY
						BEGIN CATCH
							IF	ERROR_MESSAGE() LIKE '%Special Allowance Calculate Wrong%'	--Ankit 11122015--
								BEGIN
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,REPLACE(ERROR_MESSAGE(),'@@',''),@For_Date,REPLACE(ERROR_MESSAGE(),'@@',''),GetDate(),'Earn\Ded Data',@GUID)
									set @Log_Status = 1
								END
							ELSE
								BEGIN			
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,ERROR_MESSAGE(),@For_Date,'Enter proper Allowance data,Check value is in % or Rs. in Allowance master',GetDate(),'Earn\Ded Data',@GUID)
									set @Log_Status = 1
								END

						END CATCH;


					end
				else
					begin
						
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Allowance Name Problem',@For_Date,'Enter proper Allowance name',GetDate(),'Earn\Ded Data',@GUID)
						set @Log_Status = 1
								
					end
		
		END TRY
			BEGIN CATCH
							
				
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,ERROR_MESSAGE(),@For_Date,'Enter proper Allowance data',GetDate(),'Earn\Ded Data',@GUID)
				set @Log_Status = 1

			END CATCH;

	RETURN
