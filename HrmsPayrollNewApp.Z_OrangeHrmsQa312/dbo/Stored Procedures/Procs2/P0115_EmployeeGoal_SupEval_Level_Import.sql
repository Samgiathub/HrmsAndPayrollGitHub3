



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_EmployeeGoal_SupEval_Level_Import]
	 @Cmp_Id				numeric(18,0)
	,@FinancialYr			varchar(30)
	,@Emp_code				varchar(30)
	,@ReviewType			varchar(50)
	,@YearEnd_NormalRating 	varchar(12) =null
	,@Final_PromoRecommend  varchar(5)=null
    ,@User_Id				numeric(18,0)
    ,@IP_Address			varchar(30)=''
    ,@Row_No				numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @temp_data TABLE
	(	
		 Emp_Id				NUMERIC(18,0)
		,Emp_code			VARCHAR(50)
		,Emp_GoalEval_Id	VARCHAR(50)
		,error_messge		VARCHAR(500)
		,error_Row			NUMERIC(18,0)
	)
	
	DECLARE @year	VARCHAR(15)
	DECLARE @Emp_ID	NUMERIC(18,0)
	DECLARE @Review_Type Int	
	DECLARE @Emp_GoalSetting_Review_Id NUMERIC(18,0)
	DECLARE @YearEndNormalRating VARCHAR(12)
	DECLARE @FinalPromoRecommend BIT	 
	

	---validations start
	IF @FinancialYr=''
		BEGIN
			INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Financial Year is required',0)
			INSERT INTO dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Financial Year is required',0,'Enter Financial Year',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
			SELECT * FROM  @temp_data
			RETURN
		END	
	ELSE
		BEGIN 	
			SET @year= LEFT(@FinancialYr, charindex('-', @FinancialYr) - 1)
		END
		
	IF @Emp_Code=''
		BEGIN
			INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Employee Code is required',0)
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
			SELECT * FROM  @temp_data
			RETURN
		end	
	ELSE 
		BEGIN
			IF EXISTS(SELECT Emp_ID FROM  T0080_EMP_MASTER WITH (NOLOCK) WHERE upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
				BEGIN
					SELECT @Emp_Id=emp_id FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
				END	
			ELSE
				BEGIN
					INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Employee Code is invalid',0)
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Employee Code is invalid',0,'Enter Valid Employee Code',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
					SELECT * FROM  @temp_data
					RETURN
				END
		END
	
	IF @ReviewType=''
		BEGIN
			INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Review Type is required',0)
			INSERT INTO dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Review Type is required',0,'Enter Review Type',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
			SELECT * FROM  @temp_data
			RETURN
		END	
	ELSE
		BEGIN
			SET @Review_Type= CASE WHEN @ReviewType = 'Final' THEN 2 WHEN @ReviewType ='Interim' THEN 1 END
		END
	
	IF ISNULL(@YearEnd_NormalRating,'') ='' AND ISNULL(@Final_PromoRecommend,'') =''
		BEGIN
			INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Final Year End Normalized Rating  is required',0)
			INSERT INTO dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Final Year End Normalized Rating  is required',0,'Enter Normalized Rating',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
			SELECT * FROM  @temp_data
			RETURN
		END	
	ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM	T0030_HRMS_RATING_MASTER WITH (NOLOCK) WHERE  Cmp_ID=@cmp_id AND Rate_Value = @YearEnd_NormalRating )
				BEGIN
					SET @YearEndNormalRating= @YearEnd_NormalRating
				END
			ELSE	
				BEGIN
					INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Final Year End Normalized Rating  is incorrect',0)
					INSERT INTO dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Final Year End Normalized Rating  is incorrect',0,'Enter correct Normalized Rating',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
					SELECT * FROM  @temp_data
					RETURN
				END
		END
	
	IF ISNULL(@Final_PromoRecommend,'') <>''
		BEGIN 
			SET @FinalPromoRecommend= CASE WHEN @Final_PromoRecommend = 'Yes' 
											  THEN 1 WHEN @Final_PromoRecommend = 'No' THEN 0 ELSE NULL
										      END
				
			IF (@FinalPromoRecommend IS NULL )
				BEGIN 
					SET @FinalPromoRecommend = NULL
					INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Promotion Recommend  can be either Yes or No',0)
					INSERT INTO dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Promotion Recommend  can be either Yes or No',0,'Enter correct recommendation',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
					SELECT * FROM  @temp_data
					RETURN
				END
			--Else
			--	BEGIN
			--		SET @FinalPromoRecommend= CASE WHEN @Final_PromoRecommend = 'Yes' 
			--								  THEN 1 WHEN @Final_PromoRecommend = 'No' THEN 0 
			--							      END
			--	END				
		END
	
	IF ISNULL(@Emp_ID,0)<> 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) where FinYear = @year and Review_Type = @Review_Type and Emp_Id = @Emp_ID)
				BEGIN
					INSERT INTO @temp_data (Emp_Id,Emp_code,Emp_GoalEval_Id,error_messge,error_Row) values(0,'',0,'Employee Goal Evaluation details does not exists',0)
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Employee Goal Evaluation details does not exists',0,'Add Employee Goal Evaluation Details',GetDate(),'Final Normalized Rating(Employee Goal Evaluation)','')						
					SELECT * FROM  @temp_data
					RETURN
				END	
			ELSE
				BEGIN
					SELECT @Emp_GoalSetting_Review_Id = Emp_GoalSetting_Review_Id FROM T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) WHERE FinYear = @year and Review_Type = @Review_Type and Emp_Id = @Emp_ID					
				END		
		END	
	---validations end	
	
	IF (@Emp_GoalSetting_Review_Id>0)
		BEGIN  
			IF NOT EXISTS(SELECT 1 FROM T0100_EmployeeGoal_SupEval WITH (NOLOCK) WHERE Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id)
				BEGIN
					INSERT INTO T0100_EmployeeGoal_SupEval 
					(
						 SupEval_Id
						,Cmp_Id
						,Emp_Id
						,Emp_GoalSetting_Review_Id
						,YearEnd_NormalRating
						,Final_PromoRecommend
					)VALUES
					(
						0
						,@Cmp_Id
						,@Emp_ID
						,@Emp_GoalSetting_Review_Id
						,@YearEndNormalRating
						,@FinalPromoRecommend
					)
				END
			ELSE 
				BEGIN
					UPDATE T0100_EmployeeGoal_SupEval
					SET 
						 Emp_GoalSetting_Review_Id  = @Emp_GoalSetting_Review_Id
						,YearEnd_NormalRating	    = @YearEndNormalRating
						,Final_PromoRecommend	    = @FinalPromoRecommend
					Where Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id
				END
		END
END

