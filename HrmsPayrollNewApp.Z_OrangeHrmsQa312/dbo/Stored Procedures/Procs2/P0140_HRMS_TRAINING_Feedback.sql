




CREATE  PROCEDURE [dbo].[P0140_HRMS_TRAINING_Feedback] 
	 @Tran_feedback_ID		numeric(18,0) output
	,@Tran_emp_Detail_ID	numeric(18,0)
	,@cmp_id				numeric(18,0)
	,@is_attend				int
	,@Reason				varchar(500)
	,@emp_score				numeric(18,2)
	,@emp_comments			varchar(500)
	,@emp_suggestion		varchar(500)
	,@sup_score				numeric(18,2)
	,@sup_comments			varchar(500)
	,@sup_suggestion		varchar(500)
	,@login_id				numeric(18,0)
	,@emp_s_id				numeric(18,0)
	,@status				int
	,@Trans_Type            char(1)

AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


if @Tran_emp_Detail_ID = 0
set @Tran_emp_Detail_ID = null

if @cmp_id = 0
set @cmp_id = null

if @login_id =0 
 set @login_id = null
 
if @emp_s_id = 0
  set @emp_s_id=null

	If @Trans_Type  = 'I' 
		Begin
				If Exists(select Tran_feedback_ID From T0140_HRMS_TRAINING_Feedback WITH (NOLOCK) Where Tran_emp_Detail_ID = @Tran_emp_Detail_ID )
				begin
					set @Tran_feedback_ID = 0
					return 
				end 
			
			select @Tran_feedback_ID = Isnull(max(Tran_feedback_ID),0) + 1 From T0140_HRMS_TRAINING_Feedback WITH (NOLOCK)
			
			INSERT INTO T0140_HRMS_TRAINING_Feedback
			        (
						    Tran_feedback_ID
							,Tran_emp_Detail_ID
							,cmp_id
							,is_attend
							,Reason
							,emp_score
							,emp_comments
							,emp_suggestion
							,sup_score
							,sup_comments
							,sup_suggestion
							,emp_s_id
							,status
				    )
				VALUES     
					(		@Tran_feedback_ID
							,@Tran_emp_Detail_ID
							,@cmp_id
							,@is_attend
							,@Reason
							,@emp_score
							,@emp_comments
							,@emp_suggestion
							,@sup_score
							,@sup_comments
							,@sup_suggestion
							,@emp_s_id
							,@status
							
					)
		End
	Else if @Trans_Type = 'U'
 		begin
			If Exists(select Tran_feedback_ID From T0140_HRMS_TRAINING_Feedback WITH (NOLOCK) Where Tran_emp_Detail_ID=Tran_emp_Detail_ID
											and Tran_feedback_ID <> @Tran_feedback_ID )
				begin
					set @Tran_feedback_ID = 0
					return 
				end

				UPDATE    T0140_HRMS_TRAINING_Feedback
				SET          
								is_attend=@is_attend
								,Reason =@Reason
								,emp_score=@emp_score
								,emp_comments=@emp_comments
								,emp_suggestion=@emp_suggestion
								,sup_score=@sup_score
								,sup_comments=@sup_comments
								,sup_suggestion=@sup_suggestion
								,emp_s_id=@emp_s_id
								,status=@status
				where Tran_feedback_ID = @Tran_feedback_ID
		end
		Else if @Trans_Type = 'E'
 		begin
			If Exists(select Tran_feedback_ID From T0140_HRMS_TRAINING_Feedback WITH (NOLOCK) Where Tran_emp_Detail_ID=@Tran_emp_Detail_ID)
				begin
					select @Tran_feedback_ID=Tran_feedback_ID From T0140_HRMS_TRAINING_Feedback WITH (NOLOCK) Where Tran_emp_Detail_ID=@Tran_emp_Detail_ID
						UPDATE    T0140_HRMS_TRAINING_Feedback
						SET		is_attend=@is_attend
				                ,reason=@reason
								,sup_score=@sup_score
								,sup_comments=@sup_comments
								,sup_suggestion=@sup_suggestion
								,emp_s_id=@emp_s_id
								
							where Tran_feedback_ID = @Tran_feedback_ID
					return 
			   end

			select @Tran_feedback_ID = Isnull(max(Tran_feedback_ID),0) + 1 From T0140_HRMS_TRAINING_Feedback WITH (NOLOCK)
			
			INSERT INTO T0140_HRMS_TRAINING_Feedback
			        (
						    Tran_feedback_ID
							,Tran_emp_Detail_ID
							,cmp_id
							,is_attend
							,Reason
							,sup_score
							,sup_comments
							,sup_suggestion
							,emp_s_id
							,status
				    )
				VALUES     
					(		@Tran_feedback_ID
							,@Tran_emp_Detail_ID
							,@cmp_id
							,@is_attend
							,@Reason
							,@sup_score
							,@sup_comments
							,@sup_suggestion
							,@emp_s_id
							,@status
							
					)
		end
		Else if @Trans_Type = 'M'
 		begin
			/*If Exists(select Tran_feedback_ID From T0140_HRMS_TRAINING_Feedback  Where Tran_emp_Detail_ID=Tran_emp_Detail_ID
											and Tran_feedback_ID <> @Tran_feedback_ID )
				begin
					set @Tran_feedback_ID = 0
					return 
				end*/

				UPDATE    T0140_HRMS_TRAINING_Feedback
				SET				sup_score=@sup_score
								,sup_comments=@sup_comments
								,sup_suggestion=@sup_suggestion
								,emp_s_id=@emp_s_id
								
				where Tran_feedback_ID = @Tran_feedback_ID
		end
	Else If @Trans_Type = 'D'
		begin
				
				Delete From T0140_HRMS_TRAINING_Feedback Where Tran_feedback_ID = @Tran_feedback_ID 
		end

	RETURN
	



