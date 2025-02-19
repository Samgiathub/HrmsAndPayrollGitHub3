

-- =============================================
-- Author:		<Author,,Jimit Soni>
-- Create date: <Create Date,,01-03-2019>
-- Description:	<Description,,For Importing Increment Application>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Import_Increment_Allow_Deduction_Data]
	 @CMP_ID AS NUMERIC 
	,@EMP_ID AS NUMERIC
	,@APP_ID AS NUMERIC(18,0)
	,@FOR_DATE AS DATETIME
	,@ALLOW_TYPE AS NVARCHAR(100)
	,@AMOUNT AS NUMERIC(18,5) 
	,@ROW_NO AS NUMERIC
	,@LOG_STATUS AS NUMERIC OUTPUT
	,@GUID	VARCHAR(2000) = '' 
AS
BEGIN
	BEGIN TRY
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


    SET @LOG_STATUS = 0
				
				DECLARE @ROW_ID AS NUMERIC(18,0)
				DECLARE @AD_ID AS NUMERIC
				DECLARE @E_AD_FLAG AS CHAR(1)
				DECLARE @E_AD_MODE AS VARCHAR(10)
				DECLARE @E_AD_PERCENTAGE AS NUMERIC(18,5)
				DECLARE @E_AD_MAX_LIMIT AS  NUMERIC
				DECLARE @E_AD_AMOUNT AS NUMERIC(18,2)
				DECLARE @HAS_SEL_GRADE AS NUMERIC
				DECLARE @EMP_GRADE AS NUMERIC
				DECLARE @AD_VALID AS NUMERIC		
				DECLARE @TEMP_E_AD_AMOUNT NUMERIC(18,2)
				DECLARE @IS_YEARLY TINYINT
				DECLARE @NOT_EFFECT_ON_BASIC_CALCULATION TINYINT

				
				SET @IS_YEARLY = 0
				SET @NOT_EFFECT_ON_BASIC_CALCULATION = 0
		
				SET @HAS_SEL_GRADE = 0			
				SET @TEMP_E_AD_AMOUNT = 0.0
				
				DECLARE @ALPHA_EMP_CODE	VARCHAR(50)
				SELECT @ALPHA_EMP_CODE = ALPHA_EMP_CODE FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @EMP_ID
				
				
				SELECT 	@EMP_GRADE = ISNULL(I.GRD_ID,0)
				FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
						(
							SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 
							FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID INNER JOIN 
									(
										SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
										FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
												T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID	
										WHERE	I3.INCREMENT_EFFECTIVE_DATE <= @FOR_DATE AND I3.CMP_ID = @CMP_ID 
										GROUP BY I3.EMP_ID  
									) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID																																			
							GROUP BY I2.EMP_ID
						) I1 ON I1.EMP_ID = I.EMP_ID AND I1.INCREMENT_ID=I.INCREMENT_ID INNER JOIN
				T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.GRD_ID = I.GRD_ID
					
				set @Allow_Type = Rtrim(@Allow_Type)				
				set @Allow_Type = ltrim(@Allow_Type)
							
				
				SELECT	@AD_ID=AD_ID,@E_AD_FLAG=AD_FLAG,
						@IS_YEARLY = IS_YEARLY , @NOT_EFFECT_ON_BASIC_CALCULATION = NOT_EFFECT_ON_BASIC_CALCULATION
				FROM	T0050_AD_MASTER WITH (NOLOCK)
				WHERE	AD_NAME = @ALLOW_TYPE AND CMP_ID = @CMP_ID
				
				IF ISNULL(@AD_ID,0) = 0 
					BEGIN
						INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Allowance details date does not exists.',GETDATE(),'Verify allowance details with allowance master',GETDATE(),'Increment Application',@GUID)
						SET @LOG_STATUS = 1
					END 
				
				SELECT @E_AD_MODE=AD_MODE ,@E_AD_MAX_LIMIT=ISNULL(AD_MAX_LIMIT,0) ,@E_AD_PERCENTAGE=AD_PERCENTAGE	
				FROM T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_ID = @AD_ID AND GRD_ID=@EMP_GRADE
	
				if @AD_ID > 0
					begin
						
						Select @HAS_SEL_GRADE = COUNT(*) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) Where cmp_id = @Cmp_Id and Ad_ID = @AD_ID
						
						if @HAS_SEL_GRADE > 0 
							begin
								Select @AD_VALID = COUNT(*) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) Where cmp_id = @Cmp_Id and Ad_ID = @AD_ID and Grd_ID = @EMP_GRADE				
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
										if EXISTS(SELECT AD_TRAN_ID FROM T0100_INCREMENT_APP_EARN_DEDUCTION WITH (NOLOCK)
												WHERE cmp_ID = @CMP_ID AND Emp_ID = @EMP_ID  AND AD_ID=@AD_ID AND App_ID=@App_ID)
											Begin
												Delete FROM T0100_INCREMENT_APP_EARN_DEDUCTION
												WHERE cmp_ID = @CMP_ID AND Emp_ID = @EMP_ID  AND AD_ID=@AD_ID AND App_ID=@App_ID
											end
								
										if @is_yearly = 1 and @Not_Effect_on_Basic_Calculation = 1
												BEGIN
												
													DECLARE @BASIC_CALC_ON  NVARCHAR(20)
													DECLARE @BASIC_PER  NUMERIC(18,2)
													DECLARE @YALLOW_AMOUNT  NUMERIC(18,2)
													DECLARE @YEARLY_SETTING TINYINT
													DECLARE @BASIC_VAL NUMERIC(18,2)
													DECLARE @CTC_INC NUMERIC(18,2)
													DECLARE @BRANCH_ID NUMERIC
													DECLARE @AD_ROUNDING INT
													
													SET @BASIC_CALC_ON = ''
													SET @YALLOW_AMOUNT  = 0
													SET @YEARLY_SETTING = 0
													SET @BASIC_VAL = 0 
													SET @CTC_INC  = 0
													
													
													SELECT	@CTC_INC = CTC,@BRANCH_ID = BRANCH_ID 
													FROM	T0100_INCREMENT_APPLICATION WITH (NOLOCK)
													WHERE	APP_ID=@APP_ID AND EMP_ID = @EMP_ID
													
													SELECT	@AD_ROUNDING = AD_ROUNDING 
													FROM	DBO.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND BRANCH_ID=@BRANCH_ID AND
															FOR_DATE =
															(
																SELECT	MAX(FOR_DATE) 
																FROM	T0040_GENERAL_SETTING  WITH (NOLOCK)
																WHERE	BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID
															)
													
													SELECT  @BASIC_CALC_ON = ISNULL(BASIC_CALC_ON,''),@BASIC_PER =BASIC_PERCENTAGE  
													FROM	T0040_GRADE_MASTER WITH (NOLOCK)
													WHERE	GRD_ID= @EMP_GRADE AND CMP_ID = @CMP_ID	
													
													
													
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
																		
																	update T0100_INCREMENT_APPLICATION set Basic_Salary = @basic_val where App_ID = @App_ID
																	update T0080_EMP_MASTER set Basic_Salary = @basic_val where Emp_ID = @Emp_Id
																		
																End
															
														end
												END	
												
												If @Amount >=0 
													Begin
														exec P0100_INCREMENT_APP_EARN_DEDUCTION @Row_Id output,@EMP_ID,@CMP_ID,@AD_ID,@App_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,'I'
																								--@Row_Id output,@Cmp_ID,@Emp_ID,@AD_ID,@App_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,'I'
													End
												Else
													Begin
														Select @Row_ID = Ad_Tran_Id From T0100_INCREMENT_APP_EARN_DEDUCTION WITH (NOLOCK) Where AD_ID = @AD_ID And App_ID = @App_ID
												
														If @Row_ID > 0 
															exec P0100_INCREMENT_APP_EARN_DEDUCTION @Row_Id output,@EMP_ID,@CMP_ID,@AD_ID,@App_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,'D'
													End
										
									
									end
							
						END TRY
						BEGIN CATCH
							IF	ERROR_MESSAGE() LIKE '%Special Allowance Calculate Wrong%'	
								BEGIN
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,REPLACE(ERROR_MESSAGE(),'@@',''),@For_Date,REPLACE(ERROR_MESSAGE(),'@@',''),GetDate(),'Increment Application',@GUID)
									set @Log_Status = 1
								END
							ELSE
								BEGIN			
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,ERROR_MESSAGE(),@For_Date,'Enter proper Allowance data,Check value is in % or Rs. in Allowance master',GetDate(),'Increment Application',@GUID)
									set @Log_Status = 1
								END

						END CATCH;


					end
				else
					begin
						
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,'Allowance Name Problem',@For_Date,'Enter proper Allowance name',GetDate(),'Increment Application',@GUID)
						set @Log_Status = 1
								
					end
		
		END TRY
			BEGIN CATCH
							
				
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,ERROR_MESSAGE(),@For_Date,'Enter proper Allowance data',GetDate(),'Increment Application',@GUID)
				set @Log_Status = 1

			END CATCH;

END


