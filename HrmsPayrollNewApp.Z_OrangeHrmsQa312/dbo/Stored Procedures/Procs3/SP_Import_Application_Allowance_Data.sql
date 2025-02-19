-- =============================================
-- Author:		<Author,,Jimit Soni>
-- Create date: <Create Date,,01-03-2019>
-- Description:	<Description,,For Increment Application>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Import_Application_Allowance_Data]
	@CMP_ID						NUMERIC, 
	@EMP_ID						NUMERIC,
	@EMP_NAME					NVARCHAR(50),
	@Branch_Name				VARCHAR(30),
	@INCREMENT_EFFECTIVE_DATE	DATETIME,
	@INCREMENT_TYPE				VARCHAR(30),
	@ENTRY_TYPE					VARCHAR(30) = '',
	@GRADE						VARCHAR(50) = '',
	@DESIGNATION				VARCHAR(50) = '',
	@DEPARTMENT					VARCHAR(50) = '',
	@BASIC_SALARY				NUMERIC(18,2),
	@GROSS_SALARY				NUMERIC(18,2),
	@REASON_NAME				VARCHAR(500) = '', 
	@APP_ID						NUMERIC OUTPUT,
	@ROW_NO						NUMERIC,
	@LOG_STATUS					NUMERIC OUTPUT,
	@CTC						NUMERIC(18,2),
	@GUID						VARCHAR(2000) = '' ,
	@BandName					VARCHAR(50) = '',--Added by ronakk 18052023
	@Remark						VARCHAR(50) = '' --Added by ronakk 18052023
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
		SET @LOG_STATUS = 0

		IF @BASIC_SALARY IS NULL
			SET @BASIC_SALARY = 0

		DECLARE @INCREMENT_DATE				DATETIME
		DECLARE @DIVISION_ID				NUMERIC
		DECLARE @GRD_ID						NUMERIC
		DECLARE @DEPT_ID					NUMERIC
		DECLARE @PRODUCT_ID					NUMERIC
		DECLARE @DESIG_ID					NUMERIC
		DECLARE @TYPE_ID					NUMERIC
		DECLARE @BRANCH_ID					NUMERIC
		DECLARE @CAT_ID						NUMERIC
		DECLARE @BANK_ID					NUMERIC
		DECLARE @CURRENCY_ID				NUMERIC
		DECLARE @WAGES_TYPE					VARCHAR(10)
		DECLARE @SALARY_BASIS_ON			VARCHAR(10) 
		DECLARE @PAYMENT_MODE				VARCHAR(20) 
		DECLARE @INC_BANK_AC_NO				VARCHAR(50)
		DECLARE @EMP_OT						VARCHAR(1)  
		DECLARE @EMP_OT_MIN_LIMIT			VARCHAR(10) 
		DECLARE @EMP_OT_MAX_LIMIT			VARCHAR(10)	 
		DECLARE @INCREMENT_PER				NUMERIC(18,2) 
		DECLARE @INCREMENT_AMOUNT			NUMERIC(18,2)
		DECLARE @OLD_BASIC					NUMERIC(18,2)
		DECLARE @OLD_GROSS					NUMERIC(18,2) 
		DECLARE @OLD_CTC					NUMERIC(18,2) 
		
		DECLARE @EMP_LATE_MARK				CHAR(1) 
		DECLARE @EMP_FULL_PF				CHAR(1) 
		DECLARE @EMP_PT						TINYINT
		DECLARE @FIX_SALARY					CHAR(1)
		DECLARE @EMP_PART_TIME				NUMERIC(1,0)
		DECLARE @LATE_DEDU_TYPE				VARCHAR(10)
		DECLARE @EMP_LATE_LIMIT				VARCHAR(10)
		DECLARE @EMP_PT_AMOUNT				NUMERIC(18,2)
		DECLARE @EMP_CHILDRAN				NUMERIC 
		DECLARE @LOGIN_ID					NUMERIC(18)
		DECLARE @YEARLY_BONUS_AMOUNT		NUMERIC(22,2)
		DECLARE	@DEPUTATION_END_DATE		DATETIME
		DECLARE @AUTO_VPF					CHAR(1) 

 
		DECLARE @BANK_AC_NO					VARCHAR(20)
		DECLARE @BASIC_PER					NUMERIC(18,0)
		DECLARE @CALC_ON					VARCHAR(20)
		DECLARE @AD_ROUNDING  INT
		DECLARE @IS_YEARLY_CTC TINYINT
		DECLARE @SALARY_CYCLE_ID			NUMERIC  
		DECLARE @VERTICAL_ID				NUMERIC 
		DECLARE @SUBVERTICAL_ID				NUMERIC 
		DECLARE @SUBBRANCH_ID				NUMERIC	
		DECLARE @CENTER_ID					NUMERIC	
		DECLARE @SEGMENT_ID					NUMERIC	
		DECLARE @FIX_OT_HOUR_RATE_WD		NUMERIC	
		DECLARE @FIX_OT_HOUR_RATE_WO_HO		NUMERIC	
		DECLARE @ALPHA_EMP_CODE VARCHAR(500) 
		DECLARE @REASON_ID					NUMERIC

		SET @SALARY_CYCLE_ID  = 0    
		SET @VERTICAL_ID	  = 0	 
		SET @SUBVERTICAL_ID	  = 0	 
		SET @SUBBRANCH_ID	  = 0	 
		SET @ALPHA_EMP_CODE = 0
		SET @REASON_ID = 0

		
		--Added by ronakk 16052023
		Declare @Sales_Code VARCHAR(20) = ''
		Declare @Physical_Percent NUMERIC(18,2) = 0 
		Declare @Piece_TransSalary TinyInt = 0  
		Declare @Band_Id numeric(18,0)  = 0  
		Declare @Is_PMGKY TINYINT = 0   
		Declare @Is_PFMem TINYINT = 0  
		--End by ronakk 16052023



			IF @INCREMENT_EFFECTIVE_DATE IS NULL
				BEGIN
					INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Effective/joning date does not exists.',GETDATE(),'Verify effective/joning date',GETDATE(),'Increment Application',@GUID)
					SET @LOG_STATUS = 1
				END
			
			IF @INCREMENT_TYPE IS NULL
				BEGIN
					INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Increment type date does not exists.',CONVERT(VARCHAR(11),@INCREMENT_EFFECTIVE_DATE,103),'Verify increment type',GETDATE(),'Increment Application',@GUID)
					SET @LOG_STATUS = 1
				END
				
			IF @ENTRY_TYPE IS NULL
				BEGIN
					INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Entry type date does not exists.',CONVERT(VARCHAR(11),@INCREMENT_EFFECTIVE_DATE,103),'Verify entry type',GETDATE(),'Increment Application',@GUID)
					SET @LOG_STATUS = 1
				END

			SET @IS_YEARLY_CTC = 0

			SELECT @IS_YEARLY_CTC = CAST(ISNULL(SETTING_VALUE,0) AS TINYINT) FROM T0040_SETTING WITH (NOLOCK) WHERE SETTING_NAME = 'IS_YEARLY_CTC' AND CMP_ID = @CMP_ID 
			
			SELECT @ALPHA_EMP_CODE = ALPHA_EMP_CODE FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @EMP_ID		
			

			IF (OBJECT_ID('TEMPDB..#TMPSCHEME') IS NULL)
				CREATE TABLE #TMPSCHEME(SCHEME VARCHAR(128))

		
	
			IF NOT EXISTS (Select 1 from T0095_EMP_SCHEME S WITH (NOLOCK) inner JOIN T0050_Scheme_Detail D WITH (NOLOCK) ON D.Scheme_Id = S.Scheme_ID and S.Cmp_ID = D.Cmp_Id 
						   where Type = 'Increment'  and S.Cmp_Id = @Cmp_ID and S.emp_Id = @Emp_ID and D.Rpt_Level = 1 	 
							and S.Effective_Date In(Select MAX(M.Effective_Date) FROM T0095_EMP_SCHEME M WITH (NOLOCK)
							where M.Type = 'Increment'  and M.Cmp_Id = @Cmp_ID and M.emp_Id = @Emp_ID AND M.Effective_Date <= @INCREMENT_EFFECTIVE_DATE))
			  BEGIN					
					INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Increment Application Scheme does not exists.',CONVERT(VARCHAR(11),@INCREMENT_EFFECTIVE_DATE,103),'assign increment application scheme',GETDATE(),'Increment Application',@GUID)
					SET @LOG_STATUS = 2
					RETURN
				END
				
				BEGIN TRY
						SET @INCREMENT_DATE = GETDATE()

						SELECT 	@GRD_ID =I.GRD_ID,@DEPT_ID =DEPT_ID ,
								@DESIG_ID = I.DESIG_ID,@TYPE_ID =TYPE_ID,@BRANCH_ID=BRANCH_ID,@CAT_ID=I.CAT_ID,@BANK_ID=BANK_ID
								,@CURRENCY_ID=CURR_ID,@WAGES_TYPE=WAGES_TYPE,@SALARY_BASIS_ON=SALARY_BASIS_ON,@PAYMENT_MODE=PAYMENT_MODE
								,@INC_BANK_AC_NO =INC_BANK_AC_NO,@EMP_OT=EMP_OT,@EMP_OT_MIN_LIMIT=EMP_OT_MIN_LIMIT,@EMP_OT_MAX_LIMIT=EMP_OT_MAX_LIMIT
								,@INCREMENT_PER=INCREMENT_PER,@INCREMENT_AMOUNT=INCREMENT_AMOUNT,@OLD_BASIC=BASIC_SALARY,@OLD_GROSS=GROSS_SALARY,@OLD_CTC = CTC
								,@EMP_LATE_MARK=ISNULL(EMP_LATE_MARK,0),@EMP_FULL_PF=EMP_FULL_PF,@EMP_PT=EMP_PT
								,@FIX_SALARY=EMP_FIX_SALARY,@EMP_PART_TIME=EMP_PART_TIME,@LATE_DEDU_TYPE=LATE_DEDU_TYPE,@EMP_LATE_LIMIT=EMP_LATE_LIMIT
								,@EMP_PT_AMOUNT=EMP_PT_AMOUNT,@EMP_CHILDRAN=EMP_CHILDRAN,@LOGIN_ID=LOGIN_ID,@YEARLY_BONUS_AMOUNT = YEARLY_BONUS_AMOUNT
								,@DEPUTATION_END_DATE=DEPUTATION_END_DATE,@BASIC_PER = GM.BASIC_PERCENTAGE,@CALC_ON=GM.BASIC_CALC_ON
								,@AUTO_VPF=EMP_AUTO_VPF,@SALARY_CYCLE_ID = SALDATE_ID,@VERTICAL_ID = VERTICAL_ID,@SUBVERTICAL_ID =SUBVERTICAL_ID,@SUBBRANCH_ID = SUBBRANCH_ID 
								,@CENTER_ID=CENTER_ID,@SEGMENT_ID=SEGMENT_ID,@FIX_OT_HOUR_RATE_WD=FIX_OT_HOUR_RATE_WD,@FIX_OT_HOUR_RATE_WO_HO=FIX_OT_HOUR_RATE_WO_HO		
								,@Sales_Code=Sales_Code, @Physical_Percent= Physical_Percent,@Piece_TransSalary=Is_Piece_Trans_Salary --Added by ronakk 16052023
								,@Band_Id = Band_Id, @Is_PMGKY= Is_Pradhan_Mantri, @Is_PFMem = Is_1time_PF_Member --Added by ronakk 16052023

							FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
							(
								SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 
								FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID INNER JOIN 
										(
											SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
													T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID	
											WHERE	I3.INCREMENT_EFFECTIVE_DATE <= @INCREMENT_EFFECTIVE_DATE AND I3.CMP_ID = @CMP_ID 
													and I3.Emp_Id = @Emp_Id
											GROUP BY I3.EMP_ID  
										) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID																																			
								GROUP BY I2.EMP_ID
							) I1 ON I1.EMP_ID = I.EMP_ID AND I1.INCREMENT_ID=I.INCREMENT_ID INNER JOIN
									T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.GRD_ID = I.GRD_ID
						
								
						SELECT	@AD_ROUNDING = AD_ROUNDING 
						FROM	DBO.T0040_GENERAL_SETTING WITH (NOLOCK)
						WHERE	CMP_ID=@CMP_ID AND BRANCH_ID=@BRANCH_ID AND
								FOR_DATE =
								( 
									SELECT MAX(FOR_DATE) 
									FROM   T0040_GENERAL_SETTING WITH (NOLOCK)
									WHERE  BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID
								)
					
						
						IF ISNULL(@IS_YEARLY_CTC,0) = 1
							BEGIN
								IF @AD_ROUNDING = 1
									BEGIN 
										SET @CTC = ISNULL(ROUND(@CTC / 12,0),0)
									END
								ELSE
									BEGIN
										SET @CTC = @CTC / 12
									END
							END
						
						IF @BASIC_SALARY = 0
							BEGIN 
								IF @CALC_ON = 'CTC'
									BEGIN
										IF @AD_ROUNDING = 1
											BEGIN 
												SET @BASIC_SALARY = ISNULL(ROUND((@CTC * @BASIC_PER)/100,0),0)
											END
										ELSE
											BEGIN 
												SET @BASIC_SALARY = ISNULL((@CTC * @BASIC_PER)/100,0)
											END
									END	
								ELSE IF @CALC_ON = 'GROSS' 
									BEGIN
										IF @AD_ROUNDING = 1
											BEGIN
												SET @BASIC_SALARY = ISNULL(ROUND((@GROSS_SALARY * @BASIC_PER)/100,0),0)
											END
										ELSE
											BEGIN
												SET @BASIC_SALARY = ISNULL((@GROSS_SALARY * @BASIC_PER)/100,0)
											END
									END
							END			
																			
												
						IF ISNULL(@VERTICAL_ID,0) = 0 
							SET @VERTICAL_ID = 0
						IF ISNULL(@SUBVERTICAL_ID,0) = 0 
							SET @SUBVERTICAL_ID = 0
						IF ISNULL(@SUBBRANCH_ID,0) = 0
							SET @SUBBRANCH_ID = 0
						IF ISNULL(@SALARY_CYCLE_ID,0) = 0
						 SET @SALARY_CYCLE_ID = 0
						 
						
						 IF @GRADE <> '' 
						 BEGIN
							 --Added  by ronakk 18052023
							set @GRADE =  REPLACE(@GRADE,'amp;','')
							IF EXISTS (SELECT  1 FROM T0040_GRADE_MASTER WITH (NOLOCK)  WHERE UPPER(GRD_NAME) = UPPER(@GRADE) AND CMP_ID = @CMP_ID)
							BEGIN
									SELECT  @GRD_ID = GRD_ID FROM T0040_GRADE_MASTER WITH (NOLOCK) WHERE UPPER(GRD_NAME) = UPPER(@GRADE) AND CMP_ID = @CMP_ID
							END
							ELSE
								BEGIN
									INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE /*@EMP_ID*/ ,'Problem with grade name',CONVERT(VARCHAR(11),@INCREMENT_EFFECTIVE_DATE,103),'Please check grade name',GETDATE(),'Increment Application',@GUID)
								     SET @LOG_STATUS = 1
								END
						 END
						 
						 IF @DESIGNATION <> '' 
						 BEGIN

							 --Added  by ronakk 18052023
							set @DESIGNATION =  REPLACE(@DESIGNATION,'amp;','')
						
							IF EXISTS (SELECT  1 FROM T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE UPPER(DESIG_NAME) = UPPER(@DESIGNATION) AND CMP_ID = @CMP_ID)
							BEGIN
									
									SELECT  @DESIG_ID = DESIG_ID FROM T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE UPPER(DESIG_NAME) = UPPER(@DESIGNATION) AND CMP_ID = @CMP_ID
									
							END
							ELSE
								BEGIN
									INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE /*@EMP_ID*/,'Problem with designation name',CONVERT(VARCHAR(11),@INCREMENT_EFFECTIVE_DATE,103),'Please check designation name',GETDATE(),'Increment Application',@GUID)
								     SET @LOG_STATUS = 1
								END
						 END
						
						IF @DEPARTMENT <> '' 
						 BEGIN
						  --Added  by ronakk 18052023
							set @DEPARTMENT =  REPLACE(@DEPARTMENT,'amp;','')
							IF EXISTS (SELECT  1 FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE UPPER(DEPT_NAME) = UPPER(@DEPARTMENT) AND CMP_ID = @CMP_ID)
								BEGIN
									
									SELECT  @DEPT_ID = DEPT_ID FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE UPPER(DEPT_NAME) = UPPER(@DEPARTMENT) AND CMP_ID = @CMP_ID
									
								END
							ELSE
								BEGIN
									INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE /*@EMP_ID*/ ,'Problem with department name',CONVERT(VARCHAR(11),@INCREMENT_EFFECTIVE_DATE,103),'Please check department name',GETDATE(),'Increment Application',@GUID)
								     SET @LOG_STATUS = 1
								END
						 END
						
						if @Branch_Name <> ''
						 begin
						  --Added  by ronakk 18052023
							set @Branch_Name =  REPLACE(@Branch_Name,'amp;','')
							if exists (select  1 from T0030_BRANCH_MASTER WITH (NOLOCK) where Upper(Branch_Name) = Upper(@Branch_Name) and Cmp_ID = @Cmp_ID)
								begin									
									select  @Branch_ID = Branch_ID from T0030_BRANCH_MASTER WITH (NOLOCK) where Upper(Branch_Name) = Upper(@Branch_Name) and Cmp_ID = @Cmp_ID
								end
							else
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/ ,'Problem with Branch Name',CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Branch Name',GetDate(),'Increment Application',@GUID)
								     set @Log_Status = 1
								end
						 end

						IF @REASON_NAME <> '' 
						 BEGIN
						 --Added  by ronakk 18052023
							set @REASON_NAME =  REPLACE(@REASON_NAME,'amp;','')
							IF EXISTS (SELECT  1 FROM T0040_REASON_MASTER WITH (NOLOCK) WHERE UPPER(REASON_NAME) = UPPER(@REASON_NAME))
								BEGIN
									
									SELECT  @REASON_ID = RES_ID FROM T0040_REASON_MASTER WITH (NOLOCK) WHERE UPPER(REASON_NAME) = UPPER(@REASON_NAME)
									
								END
							ELSE
								BEGIN
									INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE /*@EMP_ID*/ ,'Problem with reason name',CONVERT(VARCHAR(11),@INCREMENT_EFFECTIVE_DATE,103),'Please check reason name',GETDATE(),'Increment Application',@GUID)
								     SET @LOG_STATUS = 1
								END
						 END
						 

							
						IF @GROSS_SALARY = 0
							BEGIN
								SET @GROSS_SALARY = @OLD_GROSS
							END
						
						IF @BASIC_SALARY > 0 
							SET @INCREMENT_AMOUNT = @BASIC_SALARY - @OLD_BASIC
							
						IF @OLD_BASIC > 0 
							SET @INCREMENT_PER  = ROUND(ISNULL(@INCREMENT_AMOUNT,0) * 100 /@OLD_BASIC,2)
						ELSE IF @BASIC_SALARY > 0
							SET @INCREMENT_PER =100				
							
							
						DECLARE @ALLOW_DEDU_ID NUMERIC 
						DECLARE @MODE VARCHAR(10)
						DECLARE @AMOUNT NUMERIC 
						DECLARE @PERCENTAGE NUMERIC (18,2)
						DECLARE @MAX_UPPER	NUMERIC
						DECLARE @FLAG VARCHAR(1)
						DECLARE @ROW_ID NUMERIC 
						DECLARE @MONTH NUMERIC 
						set @APP_ID = 0
						
						  DECLARE @ALLOW_SAME_DATE_INCREMENT TINYINT	
						  DECLARE @ALLOW_SAME_DATE_INCREMENT_FLAG TINYINT
						  SET @ALLOW_SAME_DATE_INCREMENT  = 0
						  SET @ALLOW_SAME_DATE_INCREMENT_FLAG = 0
						  
						  SELECT @ALLOW_SAME_DATE_INCREMENT = ISNULL(SETTING_VALUE,0) 
						  FROM T0040_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND SETTING_NAME LIKE 'Allow same date Increment'

						  IF EXISTS(SELECT App_ID FROM dbo.T0100_INCREMENT_APPLICATION WITH (NOLOCK)
									WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0
								BEGIN
									SET @Allow_Same_Date_Increment_flag = 1
								END

						
						if @Increment_Type <> 'Joining' And UPPER(@Entry_Type) = UPPER('New') AND @Allow_Same_Date_Increment_flag = 0
							begin 						
									begin
																						
											EXEC P0100_INCREMENT_APPLICATION @APP_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_id,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Currency_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary
												,@Increment_Type,@Increment_Date,@Increment_effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Old_Basic,@Old_Gross,''
												,@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_part_Time,0,@Login_ID,@Yearly_Bonus_Amount,@Deputation_End_Date,0,1,0,@CTC,@Pre_CTC_Salary = @Old_CTC,@Increment_Mode = 1,@Salary_Cycle_id = @Salary_Cycle_id,@auto_vpf=@auto_vpf,@Vertical_ID =@Vertical_ID,@SubVertical_ID =@SubVertical_ID,@subBranch_ID = @subBranch_ID 
												,@Center_ID=@Center_ID,@Segment_ID=@Segment_ID,@Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO 
												,@Reason_ID = @Reason_ID,@Reason_Name = @Reason_Name,@Remarks = @Remark --Added by ronakk 18052023
												,@Sales_Code=@Sales_Code,@Physical_Percent= @Physical_Percent,@Piece_TransSalary=@Piece_TransSalary,@Band_Id =  @Band_Id,@Is_PMGKY = @Is_PMGKY,@Is_PFMem =@Is_PFMem --Added by ronakk 16052023
											--Update T0080_EMP_MASTER set Basic_Salary = @Basic_Salary  WHERE APP_ID = @APP_ID
											
										end	
--								
														
							end
						else
							if (exists(select Emp_ID from T0100_INCREMENT_APPLICATION WITH (NOLOCK)
										where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date And Increment_Type = 'Joining') And (@Increment_Type = 'Joining'))
								or (exists(select Emp_ID from T0100_INCREMENT_APPLICATION WITH (NOLOCK) where emp_id =@Emp_ID and Increment_effective_Date = @Increment_effective_Date And Increment_Type <> 'Joining') And (@Increment_Type <> 'Joining'))
							
							begin
							   	
							   	if @Increment_Type = 'Joining' 
							   		Begin
							   			DECLARE @Sal_Count Numeric(10,0)
							   			Set @Sal_Count = 0
							   			Select @Sal_Count = COUNT(1) From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID		
										if @Sal_Count > 0 
											Begin
												Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code ,'Employee Salary Exists you can not update Employee joining details',CONVERT(varchar(11),@Increment_Effective_date,103),'Employee Salary Exists you can not update Employee joining details',GetDate(),'Increment Application',@GUID)
												set @Log_Status = 1
											End
							   		End 
							   	
							   	
								Declare @PT_Amount			numeric 
								Declare @AD_Other_Amount	numeric 
								Declare @Max_Increment_ID	numeric 
								Declare @Max_Shift_ID numeric
								Declare @Current_Date datetime
								
								set @Current_Date = getdate()
								set @PT_Amount = 0
								
								
								Select	@APP_ID = I.APP_ID 
								from	T0100_INCREMENT_APPLICATION i WITH (NOLOCK)
										INNER JOIN (SELECT MAX(APP_ID) APP_ID, Emp_ID FROM T0100_INCREMENT_APPLICATION WITH (NOLOCK)
													WHERE increment_effective_Date <= @Increment_Effective_Date AND emp_ID = @Emp_ID 
													GROUP BY emp_ID
												) Q 
									ON i.emp_ID = Q.emp_ID AND i.APP_ID = q.APP_ID 
								Where I.Emp_ID =@Emp_ID and Increment_effective_Date = @Increment_effective_Date 
								
								if @Emp_PT = 1
									begin
								
											Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0100_INCREMENT_APP_EARN_DEDUCTION WITH (NOLOCK)
											where APP_ID=@APP_ID and E_AD_Flag ='I'
											set @AD_Other_Amount = @Basic_Salary + isnull(@AD_Other_Amount,0)
											
										Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@AD_Other_Amount,@PT_Amount output,'',@Branch_ID
									end
								
								Update T0100_INCREMENT_APPLICATION set Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary , ctc = @ctc, 
								Increment_Amount = @Basic_Salary - isnull(Pre_Basic_Salary,0),  
								Emp_PT_Amount = @PT_Amount, Grd_ID = @Grd_ID,Dept_ID =@Dept_ID,Desig_Id=@Desig_Id,
								Reason_ID = @Reason_ID,Reason_Name=@Reason_Name
								where emp_id =@Emp_ID and increment_Effective_date = @Increment_Effective_date And APP_ID = @APP_ID
								
								--Update T0080_EMP_MASTER set Basic_Salary = @Basic_Salary   
								--WHERE APP_ID = @APP_ID       
								
								Delete  FROM T0100_INCREMENT_APP_EARN_DEDUCTION WHERE APP_ID = @APP_ID
							end
							
			END TRY
			BEGIN CATCH
							
				
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@alpha_Emp_Code /*@Emp_Id*/ ,ERROR_MESSAGE(),CONVERT(varchar(11),@Increment_Effective_date,103),'Please Check Increment Type,Basic Salary or Gross Salary data',GetDate(),'Increment Application',@GUID)
				set @Log_Status = 1

			END CATCH;
	RETURN
