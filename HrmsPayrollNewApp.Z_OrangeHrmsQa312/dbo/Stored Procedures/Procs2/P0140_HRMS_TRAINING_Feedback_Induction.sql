
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_HRMS_TRAINING_Feedback_Induction]
	 @Tran_Feedback_ID		NUMERIC(18,0) OUTPUT
	,@Tran_Emp_Detail_Id	NUMERIC(18,0)
	,@Cmp_Id				NUMERIC(18,0)
	,@Is_Attend				INT
	,@Reason				VARCHAR(500)
	,@Emp_Score				NUMERIC(18,2)
	,@Sup_Score				NUMERIC(18,2)
	,@Sup_Comments			VARCHAR(500)
	,@Sup_Suggestion		VARCHAR(500)
	,@Emp_s_Id				NUMERIC(18,0)
	,@Status				INT
	,@Training_ID			Numeric(5,0)
	,@Induction_Training_Type tinyint
	,@Trans_Type			CHAR(1)
	,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= ''
AS

	declare @OldValue as varchar(max)
	declare @OldTran_Emp_Detail_Id	VARCHAR(20)
	declare @OldIs_Attend			VARCHAR(20)
	declare @OldReason				VARCHAR(500)
	declare @OldEmp_Score			VARCHAR(20)
	declare @OldSup_Score			VARCHAR(20)
	declare @OldSup_Comments		VARCHAR(500)
	declare @OldSup_Suggestion		VARCHAR(500)
	declare @OldEmp_s_Id			VARCHAR(20)
	declare @OldStatus				VARCHAR(50)

BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @Tran_emp_Detail_ID = 0
		Set @Tran_emp_Detail_ID = null

	If @cmp_id = 0
		Set @cmp_id = null
 
	If @emp_s_id = 0
		Set @emp_s_id=null

	DECLARE @Passing_Criteria as NUMERIC(5,2)
	Set @Passing_Criteria = 0

	Declare @Passing_Flag as tinyint
	Set @Passing_Flag = 0
	
	If Upper(@Trans_Type) ='I' 
		Begin
			Select @Tran_Feedback_ID = isnull(max(Tran_Feedback_ID),0) + 1 from dbo.T0140_HRMS_TRAINING_Feedback_New WITH (NOLOCK)
			
			Insert Into T0140_HRMS_TRAINING_Feedback_Induction 
					  (Tran_Feedback_ID
					  ,Tran_Emp_Detail_Id
					  ,Cmp_Id
					  ,Is_Attend
					  ,Reason
					  ,Emp_Score
					  ,Sup_Score
					  ,Sup_Comments
					  ,Sup_Suggestion
					  ,Emp_s_Id
					  ,Status
					  ,Training_ID
					  ,Induction_Training_Type)
				VALUES
					(@Tran_Feedback_ID
					,@Tran_Emp_Detail_Id
					,@Cmp_Id
					,@Is_Attend
					,@Reason
					,@Emp_Score
					,@Sup_Score
					,@Sup_Comments
					,@Sup_Suggestion
					,@Emp_s_Id
					,@Status
					,@Training_ID
					,@Induction_Training_Type)


				 Select @Passing_Criteria = Training_MCP From T0040_Hrms_Training_master WITH (NOLOCK) Where Training_id = @Training_ID and Cmp_Id = @Cmp_Id
				 If @Passing_Criteria > 0	
					BEGIN
						IF @Emp_Score >= @Passing_Criteria
							BEGIN
								Set @Passing_Flag = 1
							End
						Else
							BEGIN
								Set @Passing_Flag = 2
							End
					END
				Else
					Begin
						Set @Passing_Flag = 1
					End

				IF @Induction_Training_Type = 1 
					BEGIN 
					   
						Update T0050_EMP_WISE_CHECKLIST
							Set Passing_Flag = @Passing_Flag,
								Tran_Feedback_ID = @Tran_Feedback_ID
						Where Emp_ID = @Tran_Emp_Detail_Id and Training_ID = @Training_ID 
					END
				Else If @Induction_Training_Type = 2
					BEGIN
						Update T0050_Emp_Wise_Fun_Checklist
							Set Passing_Flag = @Passing_Flag,
								Tran_Feedback_ID = @Tran_Feedback_ID
						Where Emp_ID = @Tran_Emp_Detail_Id and Training_ID = @Training_ID 
					END
		
			
			    set @OldValue = 'New Value' + '#'+ 'Tran_Emp_Detail_Id:' + cast(Isnull(@Tran_Emp_Detail_Id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'Is Attend:' + cast(Isnull(@Is_Attend,0) as varchar(25)) + '#' + 
													'Reason:' + cast(Isnull(@Reason,'') as varchar(500)) + '#' + 
													'Emp Score:' + cast(Isnull(@Emp_Score,0) as varchar(25)) + '#' + 
													'Sup Score:' + cast(Isnull(@Sup_Score,0) as varchar(25)) + '#' + 
													'Sup Comments:' + cast(Isnull(@Sup_Comments,'') as varchar(500)) + '#' + 
													'Sup Suggestion:' + cast(Isnull(@Sup_Suggestion,'') as varchar(500)) + '#' + 
													'Emp_s_Id:' + cast(Isnull(@Emp_s_Id,0) as varchar(25)) + '#' + 
													'Status:' + cast(Isnull(@Status,0) as varchar(25))
			
				exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Feedback/Ques.',@OldValue,@Tran_Feedback_ID,@User_Id,@IP_Address
			
		End
	Else If UPPER(@Trans_Type) = 'E' or  UPPER(@Trans_Type) = 'U'
		Begin

			Select @Passing_Criteria = Isnull(Training_MCP,0) From T0040_Hrms_Training_master WITH (NOLOCK) Where Training_id = @Training_ID and Cmp_Id = @Cmp_Id
				
			If @Passing_Criteria > 0	
				BEGIN
					IF @Emp_Score >= @Passing_Criteria
						BEGIN
							Set @Passing_Flag = 1
						END
					Else
						BEGIN
							Set @Passing_Flag = 2
						END
				END
			Else
				BEGIN
					Set @Passing_Flag = 1
				END	

			If Exists(select Tran_Feedback_ID From T0140_HRMS_TRAINING_Feedback_Induction WITH (NOLOCK) Where Tran_emp_Detail_ID=@Tran_Emp_Detail_Id and Training_ID = @Training_ID)
				begin
						select @Tran_Feedback_ID = Tran_Feedback_ID From T0140_HRMS_TRAINING_Feedback_Induction WITH (NOLOCK) Where Tran_emp_Detail_ID=@Tran_Emp_Detail_Id and Training_ID = @Training_ID
				
						select @OldIs_Attend = Is_Attend
									,@OldReason = Reason
									,@OldSup_Score = Sup_Score
									,@OldSup_Comments = Sup_Comments
									,@OldSup_Suggestion = Sup_Suggestion
									,@OldEmp_s_Id=Emp_s_Id
									,@OldEmp_Score = Emp_Score
						from T0140_HRMS_TRAINING_Feedback_Induction WITH (NOLOCK) where Tran_Feedback_ID = @Tran_Feedback_ID
				
				
							UPDATE T0140_HRMS_TRAINING_Feedback_Induction
								SET  Is_Attend = @Is_Attend
									,Reason = @Reason
									,Emp_Score = @Emp_Score
									,Sup_Score = @Sup_Score
									,Sup_Comments = @Sup_Comments
									,Sup_Suggestion = @Sup_Suggestion
									,Emp_s_Id=@Emp_s_Id
									,Last_attempt_score = Case When @OldEmp_Score <> '' Then Cast(@OldEmp_Score as NUMERIC(18,2)) Else 0 End
									,Training_attempt_count = Training_attempt_count + 1
							where Tran_Feedback_ID = @Tran_Feedback_ID

							IF @Induction_Training_Type = 1 
								BEGIN 
									Update T0050_EMP_WISE_CHECKLIST
										Set Passing_Flag = @Passing_Flag,
											Tran_Feedback_ID = @Tran_Feedback_ID,
											Training_attempt_count = Isnull(Training_attempt_count,0) + 1
									Where Emp_ID = @Tran_Emp_Detail_Id and Training_ID = @Training_ID 
								END
							Else If @Induction_Training_Type = 2
								BEGIN
									Update T0050_Emp_Wise_Fun_Checklist
										Set Passing_Flag = @Passing_Flag,
											Tran_Feedback_ID = @Tran_Feedback_ID,
											Training_attempt_count = Isnull(Training_attempt_count,0) + 1
									Where Emp_ID = @Tran_Emp_Detail_Id and Training_ID = @Training_ID 
								END
						
			
							set @OldValue = 'Old Value' + '#'+ 'Tran_Emp_Detail_Id:' + cast(Isnull(@Tran_Emp_Detail_Id,0) as varchar(25)) + '#' + 
															'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
															'Is Attend:' + cast(Isnull(@OldIs_Attend,'') as varchar(25)) + '#' + 
															'Reason:' + cast(Isnull(@OldReason,'') as varchar(500)) + '#' + 
															'Emp Score:' + cast(Isnull(@OldEmp_Score,'') as varchar(25)) + '#' + 
															'Sup Score:' + cast(Isnull(@OldSup_Score,'') as varchar(25)) + '#' + 
															'Sup Comments:' + cast(Isnull(@OldSup_Comments,'') as varchar(500)) + '#' + 
															'Sup Suggestion:' + cast(Isnull(@OldSup_Suggestion,'') as varchar(500)) + '#' + 
															'Emp_s_Id:' + cast(Isnull(@OldEmp_s_Id,'') as varchar(25)) + '#' + 
															'Status:' + cast(Isnull(@Status,0) as varchar(25)) + '#' + 
										'New Value' + '#'+ 'Tran_Emp_Detail_Id:' + cast(Isnull(@Tran_Emp_Detail_Id,0) as varchar(25)) + '#' + 
															'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
															'Is Attend:' + cast(Isnull(@Is_Attend,0) as varchar(25)) + '#' + 
															'Reason:' + cast(Isnull(@Reason,'') as varchar(500)) + '#' + 
															'Emp Score:' + cast(Isnull(@Emp_Score,0) as varchar(25)) + '#' + 
															'Sup Score:' + cast(Isnull(@Sup_Score,0) as varchar(25)) + '#' + 
															'Sup Comments:' + cast(Isnull(@Sup_Comments,'') as varchar(500)) + '#' + 
															'Sup Suggestion:' + cast(Isnull(@Sup_Suggestion,'') as varchar(500)) + '#' + 
															'Emp_s_Id:' + cast(Isnull(@Emp_s_Id,0) as varchar(25)) + '#' + 
															'Status:' + cast(Isnull(@Status,0) as varchar(25))
													
						exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Feedback/Ques. Induction',@OldValue,@Tran_Feedback_ID,@User_Id,@IP_Address
		
					return 
			   end

			select @Tran_Feedback_ID = Isnull(max(Tran_Feedback_ID),0) + 1 From T0140_HRMS_TRAINING_Feedback_Induction WITH (NOLOCK)
			Insert Into T0140_HRMS_TRAINING_Feedback_Induction 
					  (Tran_Feedback_ID
					  ,Tran_Emp_Detail_Id
					  ,Cmp_Id
					  ,Is_Attend
					  ,Reason
					  ,Emp_Score
					  ,Sup_Score
					  ,Sup_Comments
					  ,Sup_Suggestion
					  ,Emp_s_Id
					  ,Status
					  ,Training_ID
					  ,Induction_Training_Type
					  ,Training_attempt_count)
				VALUES
					(@Tran_Feedback_ID
					,@Tran_Emp_Detail_Id
					,@Cmp_Id
					,@Is_Attend
					,@Reason
					,@Emp_Score
					,@Sup_Score
					,@Sup_Comments
					,@Sup_Suggestion
					,@Emp_s_Id
					,@Status
					,@Training_ID
					,@Induction_Training_Type
					,1)

					

				IF @Induction_Training_Type = 1 
					BEGIN 
						Update T0050_EMP_WISE_CHECKLIST
							Set Passing_Flag = @Passing_Flag,
								Tran_Feedback_ID = @Tran_Feedback_ID,
								Training_attempt_count = Isnull(Training_attempt_count,0) + 1
						Where Emp_ID = @Tran_Emp_Detail_Id and Training_ID = @Training_ID 
					END
				Else If @Induction_Training_Type = 2
					BEGIN
						Update T0050_Emp_Wise_Fun_Checklist
							Set Passing_Flag = @Passing_Flag,
								Tran_Feedback_ID = @Tran_Feedback_ID,
								Training_attempt_count = Isnull(Training_attempt_count,0) + 1
						Where Emp_ID = @Tran_Emp_Detail_Id and Training_ID = @Training_ID 
					END
					
			--Added By Mukti 19082015(start)
			    set @OldValue = 'New Value' + '#'+ 'Tran_Emp_Detail_Id:' + cast(Isnull(@Tran_Emp_Detail_Id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'Is Attend:' + cast(Isnull(@Is_Attend,0) as varchar(25)) + '#' + 
													'Reason:' + cast(Isnull(@Reason,'') as varchar(500)) + '#' + 
													'Emp Score:' + cast(Isnull(@Emp_Score,0) as varchar(25)) + '#' + 
													'Sup Score:' + cast(Isnull(@Sup_Score,0) as varchar(25)) + '#' + 
													'Sup Comments:' + cast(Isnull(@Sup_Comments,'') as varchar(500)) + '#' + 
													'Sup Suggestion:' + cast(Isnull(@Sup_Suggestion,'') as varchar(500)) + '#' + 
													'Emp_s_Id:' + cast(Isnull(@Emp_s_Id,0) as varchar(25)) + '#' + 
													'Status:' + cast(Isnull(@Status,0) as varchar(25))

				exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Feedback/Ques. Induction',@OldValue,@Tran_Feedback_ID,@User_Id,@IP_Address
		--Added By Mukti 19082015(end)   
		End
	Else If UPPER(@Trans_Type) = 'D'	
		begin
			--Added By Mukti 19082015(end) 
					select @OldIs_Attend = Is_Attend
								,@OldReason = Reason
								,@OldSup_Score = Sup_Score
								,@OldSup_Comments = Sup_Comments
								,@OldSup_Suggestion = Sup_Suggestion
								,@OldEmp_s_Id=Emp_s_Id
					from T0140_HRMS_TRAINING_Feedback_Induction WITH (NOLOCK) where Tran_Feedback_ID = @Tran_Feedback_ID
			--Added By Mukti 19082015(end) 
			
			Declare @Feedback_ID as numeric
			Declare @Training_Apr_ID as numeric
			Declare @Training_App_ID as numeric
			
			/*select @Feedback_ID=Tran_Feedback_ID from T0140_HRMS_TRAINING_Feedback_New where Tran_Emp_Detail_Id=@Tran_Emp_Detail_Id and Cmp_Id=@Cmp_Id
			select @Training_Apr_ID=Training_Apr_ID from T where Tran_Emp_Detail_Id=@Tran_Emp_Detail_Id and Cmp_Id=@Cmp_Id
			
			Delete from T0160_HRMS_Training_Questionnaire_Response 
				   where Training_Apr_ID = @Training_Apr_ID  
				   
			Delete from T0150_HRMS_TRAINING_Answers 
				   where  Training_Apr_ID = @Training_Apr_ID  
			 
			delete from T0150_HRMS_TRAINING_Answers where Tran_Feedback_Id=@Feedback_ID
			delete from T0140_HRMS_TRAINING_Feedback_New where Tran_Feedback_Id=@Feedback_ID
			
			Delete from T0150_EMP_Training_INOUT_RECORD 
				   where  Training_Apr_ID = @Training_Apr_ID  
				   
			update T0120_HRMS_TRAINING_APPROVAL Set Apr_Status = 0
			Where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID 
			
			select @Training_App_ID = Training_App_ID from T0120_HRMS_TRAINING_APPROVAL 
			where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID
						
			update T0100_HRMS_TRAINING_APPLICATION Set App_Status = 0
			Where cmp_id = @cmp_id and Training_App_ID = @Training_App_ID */
			
			--Added By Mukti 19082015(start)
			    set @OldValue = 'Old Value' + '#'+ 'Tran_Emp_Detail_Id:' + cast(Isnull(@Tran_Emp_Detail_Id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'Is Attend:' + cast(Isnull(@OldIs_Attend,'') as varchar(25)) + '#' + 
													'Reason:' + cast(Isnull(@OldReason,'') as varchar(500)) + '#' + 
													'Emp Score:' + cast(Isnull(@Emp_Score,0) as varchar(25)) + '#' + 
													'Sup Score:' + cast(Isnull(@OldSup_Score,'') as varchar(25)) + '#' + 
													'Sup Comments:' + cast(Isnull(@OldSup_Comments,'') as varchar(500)) + '#' + 
													'Sup Suggestion:' + cast(Isnull(@OldSup_Suggestion,'') as varchar(500)) + '#' + 
													'Emp_s_Id:' + cast(Isnull(@OldEmp_s_Id,'') as varchar(25)) + '#' + 
													'Status:' + cast(Isnull(@Status,0) as varchar(25))	

			exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Feedback/Ques. Induction',@OldValue,@Tran_Feedback_ID,@User_Id,@IP_Address
		--Added By Mukti 19082015(end)
		end
END


