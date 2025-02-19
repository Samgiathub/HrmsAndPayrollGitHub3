---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_EMP_PROBATION_MASTER_Backup_Divyaraj_02082024]
	 @Probation_Evaluation_ID		NUMERIC(18,0)	OUTPUT
	,@Emp_ID						NUMERIC(18,0)
	,@Cmp_ID						NUMERIC(18,0)
	,@Probation_Status				NUMERIC(18,0)	
	,@Evaluation_Date				DATETIME
	,@Extend_Period					NUMERIC(18,2)
	,@Old_Probation_Period			NUMERIC(18,2)
	,@Old_Probation_EndDate			DATETIME
	,@New_Probation_EndDate			DATETIME
	,@Major_Strength				NVARCHAR(1500)
	,@Major_Weakness				NVARCHAR(1500)
	,@Appraiser_Remarks				NVARCHAR(500)
	,@Appraisal_Reviewer_Remarks	NVARCHAR(500)
	,@Supervisor_ID					NUMERIC(18,0)
	,@Tran_Type						CHAR(1) 
	,@Flag_Trainee_Prob				VARCHAR(15) = 'Probation'	--Ankit 21122015
	,@Req_Training					VARCHAR(Max) = ''			--Ankit 21122015
	,@Final_Approver				INTEGER = 0		--Ankit 23122015
	,@Is_Fwd_Leave_Rej				INTEGER = 0		--Ankit 23122015
	,@Rpt_Level						INTEGER = 0		--Ankit 23122015
	,@SkillString				    NVARCHAR(MAX)	= ''	--Ankit 23122015
	,@AttrString					NVARCHAR(MAX)	= ''	--Ankit 23122015
	,@Approval_Period_Type			VARCHAR(50)		= ''	--Ankit 28122015
	,@Emp_Type_Id					NUMERIC(18,0)   =  0	--Ankit 30122015
	,@Final_Review					NUMERIC(18,0)  --Mukti(02122017) 0 for Quaterly,Six Monthly,1 for Final
	,@Review_Type					Varchar(15)	   --Mukti(02122017)Quaterly,Six Monthly
	,@Is_Self_Rating				INTEGER = 0	   --Mukti(04092018)	
	,@Tran_ID						INTEGER = 0	OUTPUT
	,@Attach_Docs					varchar(max)
	,@Confirmation_date				datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	/* 
	Employee Approval Status - T0095_EMP_PROBATION_MASTER Probation Status Below As Entry Type
	
	--For Probation 
		0 : Confirm
		1 : Extend Probation
		2 : Quarterly/Six Monthly Review 	
		5 : Draft
	--For Trainee
		0 : Confirm
		1 : Extend Training
		2 : Probation
		3 : Quarterly/Six Monthly Review
	*/
	--SET @Tran_Type = 'Q'
	
	DECLARE @ID			INT
	DECLARE @Score		NUMERIC(18,2)
	--DECLARE @Tran_id	NUMERIC(18,0)
	SET @ID = 0
	SET @Score = 0
	SET @Tran_ID = 0
	
	IF @Extend_Period = 0
		SET @Extend_Period = NULL
	
	IF @Major_Strength = ''
		SET @Major_Strength = NULL 
	
	IF @Major_Weakness = ''
		SET @Major_Weakness = NULL
		
	IF @Appraiser_Remarks = ''
		SET @Appraiser_Remarks = NULL
		
	IF @Appraisal_Reviewer_Remarks = ''
		SET @Appraisal_Reviewer_Remarks = NULL
	
	IF ISNULL(@Emp_Type_Id,0) = 0
		SET @Emp_Type_Id = NULL
	IF @Review_Type = ''
		SET @Review_Type= 'Final'
	
	Declare @Tr_Pro_Month Numeric
	Declare @Branchid Numeric
	DECLARE @Status CHAR(1)
	DECLARE @Row_Id	NUMERIC
	DECLARE @Is_Probation_Month_Days TINYINT
	DECLARE @Is_Trainee_Month_Days TINYINT
	DECLARE @Trainee_Review AS VARCHAR(20)
	DECLARE @PROBATION_Review AS VARCHAR(20)
	DECLARE @Old_Probation_EndDate1 DATETIME
	DECLARE @Date_Of_Join DATETIME
	
	SET @Tr_Pro_Month = 0
	set @Branchid = 0
	SET @Is_Probation_Month_Days = 0
	SET @Is_Trainee_Month_Days = 0
	
	SELECT	@Branchid = I1.BRANCH_ID
	FROM	T0095_INCREMENT I1 WITH (NOLOCK)
			INNER JOIN (  SELECT MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						  FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
							(	SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								FROM	T0095_INCREMENT I3 WITH (NOLOCK) WHERE	I3.Increment_Effective_Date <= @Evaluation_Date and I3.Emp_ID = @Emp_ID
								GROUP BY I3.Emp_ID
							)	I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						  WHERE	I2.Cmp_ID = @Cmp_Id AND I2.Emp_ID = @Emp_ID GROUP BY I2.Emp_ID
						) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
	WHERE	I1.Cmp_ID=@Cmp_Id and I1.Emp_ID = @Emp_ID											
	
	SELECT @Date_Of_Join=Date_Of_Join FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID=@EMP_ID
	
	set @Old_Probation_EndDate1=@Date_Of_Join
	
	SELECT @Old_Probation_Period = ISNULL(Old_Probation_Period,0) + ISNULL(@Old_Probation_Period  ,0),
		   @Old_Probation_EndDate1=ISNULL(Old_Probation_EndDate,@Date_Of_Join)
	FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
	WHERE Emp_ID = @Emp_ID AND  
		Probation_Evaluation_ID = (SELECT MAX(Probation_Evaluation_ID) FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
								   WHERE Emp_ID = @Emp_ID AND Flag = @Flag_Trainee_Prob )
			
	SET @Old_Probation_Period=DATEDIFF(DAY,ISNULL(@Old_Probation_EndDate1,@Date_Of_Join),@Old_Probation_EndDate)+1							
		PRINT @Old_Probation_Period
		PRINT @Old_Probation_EndDate1
		PRINT @Date_Of_Join
		PRINT @Old_Probation_EndDate
		
	IF UPPER(@Tran_Type) = 'I'
		BEGIN		
			IF @Is_Self_Rating = 1
				BEGIN
					IF EXISTS(SELECT 1 FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Self_Rating = 1 AND New_Probation_EndDate = @New_Probation_EndDate AND S_Emp_Id = @Supervisor_ID AND Rpt_Level = @Rpt_Level AND Probation_Evaluation_ID = 0)
						BEGIN
							UPDATE T0115_EMP_PROBATION_MASTER_LEVEL
							SET Major_Strength=@Major_Strength,
								Probation_Status=@Probation_Status
							WHERE Emp_ID=@Emp_ID AND Is_Self_Rating = 1 AND New_Probation_EndDate = @New_Probation_EndDate AND Probation_Evaluation_ID = 0
							
							SELECT @Tran_id=TRAN_ID FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Self_Rating = 1 AND New_Probation_EndDate = @New_Probation_EndDate AND Probation_Evaluation_ID = 0
						END
					ELSE
						BEGIN
							IF EXISTS(SELECT 1 FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND New_Probation_EndDate = @New_Probation_EndDate AND S_Emp_Id = @Supervisor_ID AND Rpt_Level = @Rpt_Level)
							BEGIN
								SELECT @Tran_ID
								RETURN 
							END

							SELECT @Tran_id = ISNULL(MAX(Tran_ID),0) + 1  FROM T0115_EMP_PROBATION_MASTER_LEVEL  WITH (NOLOCK)
							SET @Status = 'A'	
								
							INSERT INTO T0115_EMP_PROBATION_MASTER_LEVEL
									(Tran_Id, Emp_ID, Cmp_ID, Probation_Status, Evaluation_Date, Extend_Period,Old_Probation_Period, Old_Probation_EndDate, New_Probation_EndDate, 
										Major_Strength, Major_Weakness,Appraiser_Remarks, Appraisal_Reviewer_Remarks, S_Emp_ID,Flag,Training_ID,Rpt_Level,System_Datetime,Status,Approval_Period_Type,Emp_Type_Id,Final_Review,Review_Type,Is_Self_Rating,Attach_Docs
										,Confirmation_date
										)
							VALUES	(@Tran_id, @Emp_ID, @Cmp_ID, @Probation_Status, @Evaluation_Date, @Extend_Period,@Old_Probation_Period, @Old_Probation_EndDate, @New_Probation_EndDate, 
										@Major_Strength, @Major_Weakness,@Appraiser_Remarks, @Appraisal_Reviewer_Remarks, @Supervisor_ID,@Flag_Trainee_Prob, @Req_Training,@rpt_Level,GETDATE(),@Status,@Approval_Period_Type,@Emp_Type_Id,@Final_Review,@Review_Type,@Is_Self_Rating,@Attach_Docs
										,@Confirmation_date
										)					
						END
						
						
					IF ISNULL(@SkillString,'') <> ''
						BEGIN							
							SET @Row_Id = 0
							DECLARE CurrSkill CURSOR FOR
								SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM  dbo.Split(@SkillString,'#')
							OPEN CurrSkill
							FETCH NEXT FROM CurrSkill INTO @ID,@Score
							WHILE @@FETCH_STATUS = 0
								BEGIN	
								PRINT @ID		
								PRINT @Score						
									IF EXISTS(SELECT 1 FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL WITH (NOLOCK) WHERE Emp_Id=@EMP_ID AND Skill_ID=@ID AND Tran_ID=@Tran_id)								
										BEGIN
											UPDATE T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL 
											SET Skill_Rating=@Score
											WHERE Emp_Id=@EMP_ID AND Skill_ID=@ID AND Tran_ID=@Tran_id
										END
									ELSE
										BEGIN
											SELECT @Row_Id = ISNULL(MAX(Row_ID),0) + 1  FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL WITH (NOLOCK)
											INSERT INTO T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL(Row_ID, Cmp_ID, Emp_ID, Skill_Rating, Skill_ID, Tran_ID,Final_Review,Review_Type)
											VALUES (@Row_Id, @Cmp_ID, @Emp_ID, @Score, @ID, @Tran_id, @Final_Review, @Review_Type)									
										END										
									FETCH NEXT FROM  CurrSkill INTO @ID,@Score
								END
							CLOSE CurrSkill
							DEALLOCATE CurrSkill	
						END
						
					IF ISNULL(@AttrString,'') <> ''
					BEGIN
						DECLARE CurrAttr CURSOR FOR
							SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM  dbo.Split(@AttrString,'#')
						OPEN CurrAttr
						FETCH NEXT FROM CurrAttr INTO @ID,@Score
						WHILE @@FETCH_STATUS = 0
							BEGIN	
									IF EXISTS(SELECT 1 FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL WITH (NOLOCK) WHERE Emp_Id=@EMP_ID AND Attribute_ID=@ID AND Tran_ID=@Tran_id)								
										BEGIN
											UPDATE T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL 
											SET Attr_Rating=@Score
											WHERE Emp_Id=@EMP_ID AND Attribute_ID=@ID AND Tran_ID=@Tran_id
										END
									ELSE
										BEGIN														
											SELECT @Row_Id = ISNULL(MAX(Row_ID),0) + 1  FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL WITH (NOLOCK)
																				
											INSERT INTO T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL(Row_ID, Cmp_ID, Emp_ID, Attr_Rating, Attribute_ID, Tran_ID,Final_Review,Review_Type)
											VALUES (@Row_Id, @Cmp_ID, @Emp_ID, @Score, @ID, @Tran_id,@Final_Review,@Review_Type)									
										END
								FETCH NEXT FROM CurrAttr INTO @ID,@Score
							END
						CLOSE CurrAttr
						DEALLOCATE CurrAttr
					END
					
					RETURN	
				END				
			ELSE IF @Supervisor_ID <> 0
				BEGIN					
					IF EXISTS(SELECT 1 FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND New_Probation_EndDate = @New_Probation_EndDate AND S_Emp_Id = @Supervisor_ID AND Rpt_Level = @Rpt_Level)
						BEGIN
							SELECT @Tran_ID
							RETURN 
						END
					
					SELECT @Tran_id = ISNULL(MAX(Tran_ID),0) + 1  FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK)
					
					print @Emp_ID
					SET @Status = 'A'	
						
					INSERT INTO T0115_EMP_PROBATION_MASTER_LEVEL
							(Tran_Id, Emp_ID, Cmp_ID, Probation_Status, Evaluation_Date, Extend_Period,Old_Probation_Period, Old_Probation_EndDate, New_Probation_EndDate, 
								Major_Strength, Major_Weakness,Appraiser_Remarks, Appraisal_Reviewer_Remarks, S_Emp_ID,Flag,Training_ID,Rpt_Level,System_Datetime,Status,Approval_Period_Type,Emp_Type_Id,Final_Review,Review_Type,Is_Self_Rating,Attach_Docs
								,Confirmation_date
								)
					VALUES	(@Tran_id, @Emp_ID, @Cmp_ID, @Probation_Status, @Evaluation_Date, @Extend_Period,@Old_Probation_Period, @Old_Probation_EndDate, @New_Probation_EndDate, 
								@Major_Strength, @Major_Weakness,@Appraiser_Remarks, @Appraisal_Reviewer_Remarks, @Supervisor_ID,@Flag_Trainee_Prob, @Req_Training,@rpt_Level,GETDATE(),@Status,@Approval_Period_Type,@Emp_Type_Id,@Final_Review,@Review_Type,@Is_Self_Rating,@Attach_Docs
								,@Confirmation_date
								)					
					
				END
		
		--select @Final_Approver,@Is_Fwd_Leave_Rej
			IF @Final_Approver = 1 --AND @Is_Fwd_Leave_Rej = 0
				BEGIN
				print 'k'
					SELECT @Probation_Evaluation_ID = ISNULL(MAX(Probation_Evaluation_ID),0) + 1 FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
					
					IF @Flag_Trainee_Prob = 'Probation' AND @Probation_Status = 0
						BEGIN
							UPDATE T0080_EMP_MASTER SET Is_On_Probation = 0
							, Emp_Confirm_Date = @Confirmation_date --@New_Probation_EndDate
							WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
						END
					ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 0
						BEGIN
							UPDATE T0080_EMP_MASTER SET Is_On_Training = 0
							, Emp_Confirm_Date =@Confirmation_date --@New_Probation_EndDate
							WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
						END	
					ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 2
						BEGIN
							UPDATE T0080_EMP_MASTER 
							SET Is_On_Probation = 1, --Emp_Confirm_Date = @New_Probation_EndDate,
								Is_On_Training = 0
							WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
						END	
					
					IF EXISTS (SELECT 1 FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND New_Probation_EndDate=@New_Probation_EndDate AND Evaluation_Date = @Evaluation_Date AND Flag = @Flag_Trainee_Prob)
						BEGIN
							SET @Probation_Evaluation_ID=0
							RETURN
						END
					
					IF EXISTS (SELECT 1 FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND Flag = @Flag_Trainee_Prob)
						BEGIN
							SELECT @Old_Probation_Period = Old_Probation_Period + ISNULL(Extend_Period  ,0)
							FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
							WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND  
								Probation_Evaluation_ID = ( SELECT MAX(Probation_Evaluation_ID) FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
																WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND Flag = @Flag_Trainee_Prob )
						END
					
					INSERT INTO T0095_EMP_PROBATION_MASTER
							(Probation_Evaluation_ID, Emp_ID, Cmp_ID, Probation_Status, Evaluation_Date, Extend_Period,Old_Probation_Period, Old_Probation_EndDate, New_Probation_EndDate, 
								Major_Strength, Major_Weakness,Appraiser_Remarks, Appraisal_Reviewer_Remarks, Supervisor_ID,Flag,Training_ID,Approval_Period_Type,Emp_Type_Id,Final_Review,Review_Type,Attach_Docs
								,Confirmation_date
								)
					VALUES	(@Probation_Evaluation_ID, @Emp_ID, @Cmp_ID, @Probation_Status, @Evaluation_Date, @Extend_Period,@Old_Probation_Period, @Old_Probation_EndDate, @New_Probation_EndDate, 
								@Major_Strength, @Major_Weakness,@Appraiser_Remarks, @Appraisal_Reviewer_Remarks, @Supervisor_ID,@Flag_Trainee_Prob, @Req_Training,@Approval_Period_Type,@Emp_Type_Id,@Final_Review,@Review_Type,@Attach_Docs
								,@Confirmation_date
								)
					
					
					UPDATE T0115_EMP_PROBATION_MASTER_LEVEL SET Probation_Evaluation_ID = @Probation_Evaluation_ID WHERE Emp_ID = @Emp_ID and Old_Probation_EndDate = @Old_Probation_EndDate --AND Probation_Status = @Probation_Status
					UPDATE T0115_EMP_PROBATION_MASTER_LEVEL SET Probation_Evaluation_ID = @Probation_Evaluation_ID WHERE Emp_ID = @Emp_ID AND Probation_Status = 0 and Is_Self_Rating=1 and Old_Probation_EndDate = @Old_Probation_EndDate --Mukti(12092018)
				END
				
			----Skill & Attribute Insert ---
			--SELECT 555, @SkillString
			--SELECT LEFT(DATA,CHARINDEX('@',DATA)-1),Data FROM  dbo.Split(@SkillString,'#')
			--SELECT RIGHT(DATA,LEN(DATA)-CHARINDEX('@',DATA)) FROM  dbo.Split(@SkillString,'#')
						
			IF ISNULL(@SkillString,'') <> ''
				BEGIN					
					SET @Row_Id = 0
					DECLARE CurrSkill CURSOR FOR
						SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM  dbo.Split(@SkillString,'#')
					OPEN CurrSkill
					FETCH NEXT FROM CurrSkill INTO @ID,@Score
					WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @Supervisor_ID <> 0
								BEGIN
								print @Tran_id
									SELECT @Row_Id = ISNULL(MAX(Row_ID),0) + 1  FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL WITH (NOLOCK)
																		
									INSERT INTO T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL(Row_ID, Cmp_ID, Emp_ID, Skill_Rating, Skill_ID, Tran_ID,Final_Review,Review_Type)
									VALUES (@Row_Id, @Cmp_ID, @Emp_ID, @Score, @ID, @Tran_id, @Final_Review, @Review_Type)									
							--select 111,* from T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL
								END
								
							IF @Final_Approver = 1
								BEGIN								
									EXEC P0100_EMP_PROBATION_SKILL_DETAIL @Prob_Skill_ID = 0,@Cmp_ID = @Cmp_ID , @Emp_ID = @Emp_ID,@Skill_Rating = @Score,@Skill_ID = @ID,@Emp_Prob_ID = @Probation_Evaluation_ID, @Tran_Type = 'I',@Final_Review =@Final_Review,@Review_Type=@Review_Type,@Strength='',@Other_Factors='',@Remarks='',@Supervisor_ID=@Supervisor_ID,@Final_Approver=@Final_Approver
								END	
							
							FETCH NEXT FROM  CurrSkill INTO @ID,@Score
						END
					CLOSE CurrSkill
					DEALLOCATE CurrSkill	
				END
				
			SET @ID = 0 
			SET @Score = 0
			SET @Row_Id = 0
			
			IF ISNULL(@AttrString,'') <> ''
				BEGIN
					DECLARE CurrAttr CURSOR FOR
						SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM  dbo.Split(@AttrString,'#')
					OPEN CurrAttr
					FETCH NEXT FROM CurrAttr INTO @ID,@Score
					WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @Supervisor_ID <> 0
								BEGIN
									SELECT @Row_Id = ISNULL(MAX(Row_ID),0) + 1  FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL WITH (NOLOCK)
																		
									INSERT INTO T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL(Row_ID, Cmp_ID, Emp_ID, Attr_Rating, Attribute_ID, Tran_ID,Final_Review,Review_Type)
									VALUES (@Row_Id, @Cmp_ID, @Emp_ID, @Score, @ID, @Tran_id,@Final_Review,@Review_Type)									
								END
									
							IF @Final_Approver = 1
								BEGIN
									EXEC P0100_EMP_PROBATION_ATTRIBUTE_DETAIL @Prob_Attr_ID = 0,@Cmp_ID = @Cmp_ID , @Emp_ID = @Emp_ID,@Attr_Rating = @Score,@Attr_ID = @ID,@Emp_Prob_ID = @Probation_Evaluation_ID, @Tran_Type = 'I',@Final_Review =@Final_Review,@Review_Type=@Review_Type
								END
							
							FETCH NEXT FROM CurrAttr INTO @ID,@Score
						END
					CLOSE CurrAttr
					DEALLOCATE CurrAttr
				END
			----Skill & Attribute Insert ---	
				
			
			------Auto Increment			
			IF @Final_Approver = 1 AND @Probation_Evaluation_ID <> 0 AND (@Probation_Status = 0 OR (@Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 2))
				BEGIN
					
					DECLARE @Increment_Id		NUMERIC
					DECLARE @maxIncrement_Id	NUMERIC
					DECLARE @MaxAD_Tran_ID		NUMERIC
					DECLARE @Reason_ID			NUMERIC
					DECLARE @Reason_Name		VARCHAR(100)
					
					SET @Increment_Id  = 0
					SET @maxIncrement_Id = 0
					SET @MaxAD_Tran_ID = 0
					SET @Reason_ID = 0
					SET @Reason_Name = ''
					
					IF @Flag_Trainee_Prob = 'Probation' AND @Probation_Status = 0
						BEGIN
							SET @Reason_Name = 'Probation To Confirmation'
						END
					ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 0
						BEGIN
							SET @Reason_Name = 'Training To Confirmation'
						END	
					ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 2
						BEGIN
							SET @Reason_Name = 'Training To Probation'							
						END
						
					SELECT @Reason_ID = Res_Id FROM T0040_Reason_Master WITH (NOLOCK) WHERE TYPE='Increment' AND Reason_Name = @Reason_Name
					
					IF	@Reason_ID = 0
						EXEC [P0040_Reason_Master] @Reason_ID OUTPUT ,@Cmp_ID,@Reason_Name,'I',1,'Increment',''	
					
					declare @lSalaryCycleDate datetime,@lday int,@lnewdate varchar(50)
					select top 1 @lSalaryCycleDate = Sal_St_Date from T0040_GENERAL_SETTING where Cmp_ID = @Cmp_ID and Branch_ID = @Branchid order by Gen_ID desc
					select @lday = DAY(@lSalaryCycleDate)

					--select @lnewdate = convert(varchar,YEAR(GETDATE())) + '-' + convert(varchar,MONTH(GETDATE())) + '-' + CONVERT(varchar,@lday)

					-- added by deepal on 07092023
					--select @lnewdate,@lday,@New_Probation_EndDate
					if @lday > 1
					begin
							select @lnewdate = convert(varchar,YEAR(GETDATE())) + '-' + convert(varchar,MONTH(GETDATE())) + '-' + CONVERT(varchar,@lday) --comment by deepal for Story 26251
							--select @lnewdate
					end
					else
					begin
						if DAY(@Confirmation_date) > 15 
							set  @lnewdate =  DATEADD(month, DATEDIFF(month, 0, @Confirmation_date) + 1, 0)  --@New_Probation_EndDate
						ELSe
							set  @lnewdate =  DATEADD(month, DATEDIFF(month, 0, @Confirmation_date), 0)  --@New_Probation_EndDate
					end
					-- added by deepal on 07092023


					--IF NOT EXISTS(SELECT 1 FROM T0095_INCREMENT WITH (NOLOCK) WHERE Reason_ID=@Reason_ID AND Increment_Effective_Date=@Confirmation_date)
					IF NOT EXISTS(SELECT 1 FROM T0095_INCREMENT WITH (NOLOCK) WHERE Reason_ID=@Reason_ID AND Increment_Effective_Date=@lnewdate and  Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID)
					BEGIN	
						SELECT @Increment_Id =  MAX(Increment_ID) FROM T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
						SELECT @maxIncrement_Id =  MAX(Increment_ID) + 1 FROM T0095_INCREMENT WITH (NOLOCK)
						SELECT @MaxAD_Tran_ID = MAX(AD_TRAN_ID) + 1 FROM dbo.T0100_EMP_EARN_DEDUCTION	WITH (NOLOCK)				
					
						INSERT INTO T0095_INCREMENT
						(Increment_ID,Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,Type_ID,Bank_ID,Curr_ID,Wages_Type,Salary_Basis_On,Basic_Salary,Gross_Salary,Increment_Type,Increment_Date,Increment_Effective_Date,Payment_Mode,
							Inc_Bank_AC_No,Emp_OT,Emp_OT_Min_Limit,Emp_OT_Max_Limit,Increment_Per,Increment_Amount,Pre_Basic_Salary,Pre_Gross_Salary,Increment_Comments,Emp_Late_mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,
							Emp_Late_Limit,Emp_PT_Amount,Emp_Childran,Is_Master_Rec,Login_ID,System_Date,Yearly_Bonus_Amount,Deputation_End_Date,Is_Deputation_Reminder,Appr_Int_ID,CTC,Emp_Early_mark,Early_Dedu_Type,Emp_Early_Limit,Emp_Deficit_mark,
							Deficit_Dedu_Type,Emp_Deficit_Limit,Center_ID,Emp_WeekDay_OT_Rate,Emp_WeekOff_OT_Rate,Emp_Holiday_OT_Rate,Is_Metro_City,Pre_CTC_Salary,Incerment_Amount_gross,Incerment_Amount_CTC,Increment_Mode,is_physical,SalDate_id,Emp_Auto_Vpf,
							Segment_ID,Vertical_ID,SubVertical_ID,subBranch_ID,Monthly_Deficit_Adjust_OT_Hrs,Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,Bank_Branch_Name,Bank_Branch_Name_Two,Reason_ID,Reason_Name)
						SELECT @maxIncrement_Id,Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,@Emp_Type_Id,Bank_ID,Curr_ID,Wages_Type,Salary_Basis_On,Basic_Salary,Gross_Salary,'Increment'/*Increment_Type*/,/*@Confirmation_date*/getdate()/*Increment_Date*/,/*@Confirmation_date*/@lnewdate/*Increment_Effective_Date*/,Payment_Mode,
							Inc_Bank_AC_No,Emp_OT,Emp_OT_Min_Limit,Emp_OT_Max_Limit,Increment_Per,0,Basic_Salary/*Pre_Basic_Salary*/,Gross_Salary/*Pre_Gross_Salary*/,@Reason_Name + ' - Auto Increment Entry' /*Increment_Comments*/,Emp_Late_mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,
							Emp_Late_Limit,Emp_PT_Amount,Emp_Childran, 0 /*Is_Master_Rec*/,Login_ID,GETDATE()/*System_Date*/,Yearly_Bonus_Amount,Deputation_End_Date,Is_Deputation_Reminder,Appr_Int_ID,CTC,Emp_Early_mark,Early_Dedu_Type,Emp_Early_Limit,Emp_Deficit_mark,
							Deficit_Dedu_Type,Emp_Deficit_Limit,Center_ID,Emp_WeekDay_OT_Rate,Emp_WeekOff_OT_Rate,Emp_Holiday_OT_Rate,Is_Metro_City,CTC /*Pre_CTC_Salary*/,Incerment_Amount_gross,Incerment_Amount_CTC,Increment_Mode,is_physical,SalDate_id,Emp_Auto_Vpf,
							Segment_ID,Vertical_ID,SubVertical_ID,subBranch_ID,Monthly_Deficit_Adjust_OT_Hrs,Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,Bank_Branch_Name,Bank_Branch_Name_Two ,@Reason_ID,@Reason_Name
						FROM T0095_INCREMENT WITH (NOLOCK)
						WHERE Increment_ID = @Increment_Id AND Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
					
						UPDATE T0080_Emp_Master
						SET Increment_Id =@maxIncrement_Id	
						WHERE Emp_ID =@Emp_ID 	
					
						--update by chetan 29112017 because when add field in allowance then give error here
						INSERT INTO T0100_EMP_EARN_DEDUCTION(AD_TRAN_ID,CMP_ID,EMP_ID,AD_ID,INCREMENT_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT,It_Estimated_Amount,Is_Calculate_Zero)
						--INSERT INTO T0100_EMP_EARN_DEDUCTION
						SELECT 
							 ROW_NUMBER() OVER (ORDER BY EED.AD_ID) + @MaxAD_Tran_ID AS AD_TRAN_ID,EED.CMP_ID,EED.EMP_ID,EED.AD_ID,@maxIncrement_Id /*INCREMENT_ID*/,@New_Probation_EndDate/*eed.FOR_DATE*/,E_AD_FLAG,E_AD_MODE,
							 CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN
								CASE WHEN Qry1.E_AD_PERCENTAGE IS NULL THEN eed.E_AD_PERCENTAGE ELSE Qry1.E_AD_PERCENTAGE END 
							 ELSE
								eed.E_AD_PERCENTAGE END AS E_AD_PERCENTAGE,
							 CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN
								CASE WHEN Qry1.E_Ad_Amount IS NULL THEN eed.E_AD_Amount ELSE Qry1.E_Ad_Amount END 
							 ELSE
								eed.e_ad_Amount END AS E_Ad_Amount,
							 E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT,It_Estimated_Amount,EED.Is_Calculate_Zero
						FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
							   dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
								( SELECT EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
									FROM T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
									( SELECT MAX(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
										WHERE Emp_Id = @Emp_Id AND Cmp_ID= @Cmp_ID AND For_date <= GETDATE() GROUP BY Ad_Id 
									 ) Qry ON Eedr.For_Date = Qry.For_Date AND Eedr.Ad_Id = Qry.Ad_Id 
								) Qry1 ON eed.AD_ID = qry1.ad_Id AND EEd.EMP_ID = Qry1.EMP_ID
						WHERE EED.EMP_ID = @emp_id AND EED.Cmp_ID= @Cmp_ID AND eed.increment_id = @Increment_Id AND Adm.AD_ACTIVE = 1
								AND CASE WHEN Qry1.ENTRY_TYPE IS NULL THEN '' ELSE Qry1.ENTRY_TYPE END <> 'D'
					
						UNION 
					
						SELECT TRAN_ID,CMP_ID,EMP_ID,EED.AD_ID,@maxIncrement_Id,@New_Probation_EndDate,E_AD_FLAG,E_AD_MODE,
								E_AD_Percentage,E_AD_Amount,
							E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT,0 AS It_Estimated_Amount,0 as Is_Calculate_Zero
						FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
							( SELECT MAX(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
								WHERE Emp_Id  = @Emp_Id AND Cmp_ID= @Cmp_ID AND For_date <= GETDATE() GROUP BY Ad_Id 
							) Qry ON EED.For_Date = Qry.For_Date AND EED.Ad_Id = Qry.Ad_Id
						WHERE emp_id = @emp_id AND Cmp_ID= @Cmp_ID AND EEd.ENTRY_TYPE = 'A'
							AND EED.Increment_ID = @Increment_Id
					END
					else
					begin
						update T0095_INCREMENT set Type_ID = @Emp_Type_Id where Reason_ID=@Reason_ID AND Increment_Effective_Date=@lnewdate
					end
				END			
			------Auto Increment
			
			--For Display Save Message on Page
			IF @Final_Approver = 0
				SET @Probation_Evaluation_ID = @Tran_id				
			
		END
	ELSE IF UPPER(@Tran_Type) = 'D' --Added by Mukti(10092018)
		BEGIN		
		--print @Probation_Evaluation_ID	
			DELETE FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL WHERE Tran_ID=@Probation_Evaluation_ID
			DELETE FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL WHERE Tran_ID=@Probation_Evaluation_ID
			DELETE FROM T0115_EMP_PROBATION_MASTER_LEVEL WHERE Tran_Id=@Probation_Evaluation_ID
		END	
END


