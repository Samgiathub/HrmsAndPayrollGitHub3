

-- =============================================
-- Author:		<Author,,Ankit>
-- Create date: <Create Date,,22072016>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_EMP_TRAINEE_PROBATION_DELETE]
	 @Probation_Evaluation_ID		numeric(18, 0) output
	,@Tran_ID			numeric(18, 0)	
	,@Emp_ID			numeric(18, 0)
	,@Cmp_ID			numeric(18, 0)
	,@S_Emp_ID			Numeric(18, 0)
	,@Probation_Status		NUMERIC(18,0)	
	,@Evaluation_Date		Datetime
	,@Old_Probation_EndDate	Datetime
	,@New_Probation_EndDate	Datetime
	,@Flag_Trainee_Prob		Varchar(50) = '' 
	,@User_Id			numeric(18,0) = 0  
	,@IP_Address		varchar(30)= '' 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--Declare @Tran_ID Numeric
	DECLARE @Reason_Name		VARCHAR(100)
	Declare @Level_S_emp_id Numeric
	Declare @Rpt_Level tinyint 
	DECLARE @Increment_ID NUMERIC
	DECLARE @Reason_ID    NUMERIC
	
	SET @Increment_ID = 0
	SET @Reason_ID = 0
	
	--Set @Tran_ID =0
	SET @Reason_Name = ''
	SET @Level_S_emp_id =0
	set @Rpt_Level = 0
	
	IF @Probation_Evaluation_ID <> 0
		BEGIN
			SELECT @Probation_Status = Probation_Status,@Evaluation_Date = Evaluation_Date ,@Old_Probation_EndDate = Old_Probation_EndDate,@New_Probation_EndDate = New_Probation_EndDate
			From T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
			WHERE  Probation_Evaluation_ID = @Probation_Evaluation_ID
		END
		
	SELECT @Tran_ID = Tran_ID , @Reason_Name = Approval_Period_Type ,@Level_S_emp_id = S_EMp_ID 
	FROM  T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK)
	WHERE Emp_ID = @Emp_ID --and S_Emp_ID = @S_Emp_ID 
		and	Evaluation_Date = @Evaluation_Date  AND Old_Probation_EndDate = @Old_Probation_EndDate 
		AND New_Probation_EndDate = @New_Probation_EndDate
		AND Rpt_Level IN ( SELECT max(Rpt_Level) from T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK)
							where Emp_ID = @Emp_ID 
							and	Evaluation_Date = @Evaluation_Date  AND Old_Probation_EndDate = @Old_Probation_EndDate 
							AND New_Probation_EndDate = @New_Probation_EndDate
							and probation_status  = @Probation_Status )
	
	
							
	IF @S_Emp_ID = 0 AND @Probation_Evaluation_ID = 0
		BEGIN			
			IF EXISTS( SELECT 1 FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Tran_ID = @Tran_ID )
				BEGIN
					--DELETE FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL WHERE Emp_ID = @Emp_ID AND Tran_ID = @Tran_ID
					--DELETE FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL WHERE Emp_ID = @Emp_ID AND Tran_ID = @Tran_ID
					--DELETE FROM T0115_EMP_PROBATION_MASTER_LEVEL WHERE Emp_ID = @Emp_ID AND Tran_ID = @Tran_ID
					--Added by Mukti(15112018)start					
					DELETE AD
					FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL AD
					INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL PM ON AD.Tran_ID=PM.Tran_Id AND AD.Cmp_ID=PM.Cmp_id
					WHERE PM.Probation_Evaluation_ID=@Probation_Evaluation_ID AND PM.Cmp_id=@CMP_ID
					
					DELETE SD
					FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL SD
					INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL PM ON SD.Tran_ID=PM.Tran_Id AND SD.Cmp_ID=PM.Cmp_id
					WHERE PM.Probation_Evaluation_ID=@Probation_Evaluation_ID AND PM.Cmp_id=@CMP_ID
					
					DELETE FROM T0115_EMP_PROBATION_MASTER_LEVEL WHERE Emp_ID = @Emp_ID AND Probation_Evaluation_ID = @Probation_Evaluation_ID
					--Added by Mukti(15112018)end
				END
			
			IF EXISTS (SELECT 1 FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND Flag = @Flag_Trainee_Prob) AND @Probation_Evaluation_ID = 0
				BEGIN
					SELECT @Probation_Evaluation_ID = Probation_Evaluation_ID
					FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
					WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND  
						Probation_Evaluation_ID = ( SELECT MAX(Probation_Evaluation_ID) FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
														WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND Flag = @Flag_Trainee_Prob )
				END
			
			IF @Probation_Evaluation_ID <> 0
				BEGIN
					
					IF @Flag_Trainee_Prob = 'Probation' AND @Probation_Status = 0
						BEGIN
							UPDATE T0080_EMP_MASTER SET Is_On_Probation = 1, Emp_Confirm_Date = NULL
							WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
							
							SET @Reason_Name = 'Probation To Confirmation'
						END
					ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 0
						BEGIN
							UPDATE T0080_EMP_MASTER SET Is_On_Training = 1, Emp_Confirm_Date = NULL
							WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
							
							SET @Reason_Name = 'Training To Confirmation'
						END	
					ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 2
						BEGIN
							UPDATE T0080_EMP_MASTER 
							SET Is_On_Probation = 0, 
								Is_On_Training = 1
							WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
							
							SET @Reason_Name = 'Training To Probation'
						END	
					
					---- DELETE INCREMENT ENTRY
			 
					SET @Increment_ID = 0
					SET @Reason_ID = 0
					
					IF @Reason_Name <> ''
						SELECT @Reason_ID = Res_Id FROM T0040_Reason_Master WITH (NOLOCK) WHERE TYPE='Increment' AND Reason_Name = @Reason_Name
					
					SELECT @Increment_ID = Increment_ID FROM T0095_INCREMENT WITH (NOLOCK)
					WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID AND Reason_ID = @Reason_ID AND Increment_Effective_Date = @New_Probation_EndDate AND Increment_Comments LIKE '%- Auto Increment Entry%' 
					
					IF @Increment_ID <> 0
						Exec P0095_INCREMENT_DELETE @Increment_ID = @Increment_ID , @Emp_ID = @Emp_ID , @Cmp_ID = @Cmp_ID
					
					---- DELETE INCREMENT ENTRY
						
					Delete From T0100_EMP_PROBATION_SKILL_DETAIL WHERE  Emp_Prob_ID = @Probation_Evaluation_ID and Emp_ID  = @Emp_ID
					Delete From T0100_EMP_PROBATION_ATTRIBUTE_DETAIL WHERE  Emp_Prob_ID = @Probation_Evaluation_ID and Emp_ID  = @Emp_ID
					Delete From T0095_EMP_PROBATION_MASTER WHERE  Probation_Evaluation_ID = @Probation_Evaluation_ID and Emp_ID  = @Emp_ID
					
					UPDATE T0115_EMP_PROBATION_MASTER_LEVEL SET Probation_Evaluation_ID = 0 WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND Probation_Evaluation_ID = @Probation_Evaluation_ID 
					
				END
				
		END
	ELSE
		BEGIN		
			IF EXISTS( SELECT 1 FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID )
				BEGIN
					--SELECT @Tran_ID=Tran_Id from T0115_EMP_PROBATION_MASTER_LEVEL WHERE  Probation_Evaluation_ID = @Probation_Evaluation_ID and Emp_ID  = @Emp_ID
					PRINT 'mm'
					--DELETE FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL WHERE Emp_ID = @Emp_ID AND Tran_ID = @Tran_ID
					--DELETE FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL WHERE Emp_ID = @Emp_ID AND Tran_ID = @Tran_ID
					--Added by Mukti(15112018)start					
					DELETE AD
					FROM T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL AD
					INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL PM ON AD.Tran_ID=PM.Tran_Id AND AD.Cmp_ID=PM.Cmp_id
					WHERE PM.Probation_Evaluation_ID=@Probation_Evaluation_ID AND PM.Cmp_id=@CMP_ID
					
					DELETE SD
					FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL SD
					INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL PM ON SD.Tran_ID=PM.Tran_Id AND SD.Cmp_ID=PM.Cmp_id
					WHERE PM.Probation_Evaluation_ID=@Probation_Evaluation_ID AND PM.Cmp_id=@CMP_ID
					
					DELETE FROM T0115_EMP_PROBATION_MASTER_LEVEL WHERE Emp_ID = @Emp_ID AND Probation_Evaluation_ID = @Probation_Evaluation_ID
					--Added by Mukti(15112018)end
				END
			
			IF @Flag_Trainee_Prob = 'Probation' AND @Probation_Status = 0
				BEGIN
					UPDATE T0080_EMP_MASTER SET Is_On_Probation = 1, Emp_Confirm_Date = NULL
					WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
					
					SET @Reason_Name = 'Probation To Confirmation'
				END
			ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 0
				BEGIN
					UPDATE T0080_EMP_MASTER SET Is_On_Training = 1, Emp_Confirm_Date = NULL
					WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
					
					SET @Reason_Name = 'Training To Confirmation'
				END	
			ELSE IF @Flag_Trainee_Prob = 'Trainee' AND @Probation_Status = 2
				BEGIN
					UPDATE T0080_EMP_MASTER 
					SET Is_On_Probation = 0, 
						Is_On_Training = 1
					WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID
					
					SET @Reason_Name = 'Training To Probation'
				END	
			---- DELETE INCREMENT ENTRY
			 
			SET @Increment_ID = 0
			SET @Reason_ID = 0
			
			IF @Reason_Name <> ''
				SELECT @Reason_ID = Res_Id FROM T0040_Reason_Master WITH (NOLOCK) WHERE TYPE='Increment' AND Reason_Name = @Reason_Name

			-- Added by Divyaraj Kiri on 06/09/2024
			Declare @Increment_Effective_Date Datetime

			Select @Increment_Effective_Date = Increment_Effective_Date From T0095_INCREMENT WITH (NOLOCK)
			WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID AND Reason_ID = @Reason_ID AND Increment_Comments LIKE '%- Auto Increment Entry%' 
			
			-- Ended by Divyaraj Kiri on 06/09/2024

			SELECT @Increment_ID = Increment_ID FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Emp_ID = @Emp_ID AND Cmp_ID= @Cmp_ID AND Reason_ID = @Reason_ID AND Increment_Effective_Date = @Increment_Effective_Date 
			AND Increment_Comments LIKE '%- Auto Increment Entry%' 
			
			
			IF @Increment_ID <> 0
				Exec P0095_INCREMENT_DELETE @Increment_ID = @Increment_ID , @Emp_ID = @Emp_ID , @Cmp_ID = @Cmp_ID
			
			---- DELETE INCREMENT ENTRY
				
			Delete From T0100_EMP_PROBATION_SKILL_DETAIL WHERE  Emp_Prob_ID = @Probation_Evaluation_ID and Emp_ID  = @Emp_ID
			Delete From T0100_EMP_PROBATION_ATTRIBUTE_DETAIL WHERE  Emp_Prob_ID = @Probation_Evaluation_ID and Emp_ID  = @Emp_ID
			Delete From T0095_EMP_PROBATION_MASTER WHERE  Probation_Evaluation_ID = @Probation_Evaluation_ID and Emp_ID  = @Emp_ID
			
			UPDATE T0115_EMP_PROBATION_MASTER_LEVEL SET Probation_Evaluation_ID = 0 WHERE Emp_ID = @Emp_ID AND Probation_Status = @Probation_Status AND Probation_Evaluation_ID = @Probation_Evaluation_ID 
		END
			
		
	
END

