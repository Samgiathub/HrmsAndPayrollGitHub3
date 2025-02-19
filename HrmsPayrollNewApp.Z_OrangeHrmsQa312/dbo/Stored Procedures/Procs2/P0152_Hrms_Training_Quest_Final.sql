

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0152_Hrms_Training_Quest_Final]
	   @Tran_Id					numeric(18,0) output
      ,@Cmp_Id					numeric(18,0)
      ,@Training_Que_ID			numeric(18,0)
      ,@Training_Apr_Id			numeric(18,0)
      ,@Training_Id				numeric(18,0)
      ,@Marks					numeric(18,2)
      ,@Tran_Type               varchar(1)
      ,@User_Id numeric(18,0) = 0 -- added By Mukti 19082015
      ,@IP_Address varchar(30)= '' -- added By Mukti 19082015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 --Added By Mukti 18082015(start)
	declare @OldValue as varchar(max)
	declare @OldMarks varchar(20)
 --Added By Mukti 18082015(end)
BEGIN
	if UPPER(@Tran_Type)= 'I'
		begin
			if not exists(select 1 from t0152_Hrms_Training_Quest_Final WITH (NOLOCK) where cmp_id = @Cmp_Id and training_apr_id = @Training_Apr_Id and Training_Que_ID=@Training_Que_ID and Tran_Id <> @Tran_Id)
				begin
					select @Tran_Id = isnull(MAX(Tran_Id),0)+1 from t0152_Hrms_Training_Quest_Final WITH (NOLOCK)
					insert into t0152_Hrms_Training_Quest_Final
					(
					   Tran_Id					
					  ,Cmp_Id				
					  ,Training_Que_ID			
					  ,Training_Apr_Id			
					  ,Training_Id				
					  ,Marks				
					)
					values
					(
					  @Tran_Id					
					  ,@Cmp_Id				
					  ,@Training_Que_ID			
					  ,@Training_Apr_Id			
					  ,@Training_Id				
					  ,@Marks
					)
			--Added By Mukti 18082015(start)
		    set @OldValue = 'New Value' + '#'+ 'Training Question ID :' + cast(Isnull(@Training_Que_ID,0) as varchar(10)) + '#' + 
											   'Training Approval ID :' + cast(Isnull(@Training_Apr_Id,0) as varchar(10)) + '#' + 
											   'Training ID :' + cast(Isnull(@Training_Id,0) as varchar(10)) + '#' + 
											   'Marks :' + cast(Isnull(@Marks,0) as varchar(10))
		    --Added By Mukti 18082015(end)
				end
			Else
				begin
					set @Tran_Id=0
					return @Tran_Id
				end
		end
	Else if UPPER(@Tran_Type)= 'U'
		begin
			if not exists(select 1 from t0152_Hrms_Training_Quest_Final WITH (NOLOCK) where cmp_id = @Cmp_Id and training_apr_id = @Training_Apr_Id and Training_Que_ID=@Training_Que_ID and Tran_Id <> @Tran_Id)
				begin
			--Added By Mukti 18082015(start)
					select @Oldmarks = marks from t0152_Hrms_Training_Quest_Final WITH (NOLOCK) where tran_id = @Tran_Id
			--Added By Mukti 18082015(end)
			
					Update	t0152_Hrms_Training_Quest_Final
					set		marks = @marks
					where	tran_id = @Tran_Id
					
			--Added By Mukti 18082015(start)
		    set @OldValue = 'Old Value' + '#'+ 'Training Question ID :' + cast(Isnull(@Training_Que_ID,0) as varchar(10)) + '#' + 
											   'Training Approval ID :' + cast(Isnull(@Training_Apr_Id,0) as varchar(10)) + '#' + 
											   'Training ID :' + cast(Isnull(@Training_Id,0) as varchar(10)) + '#' + 
											   'Marks :' + cast(Isnull(@OldMarks,'') as varchar(10)) + '#' + 
						    'New Value' + '#'+ 'Training Question ID :' + cast(Isnull(@Training_Que_ID,0) as varchar(10)) + '#' + 
											   'Training Approval ID :' + cast(Isnull(@Training_Apr_Id,0) as varchar(10)) + '#' + 
											   'Training ID :' + cast(Isnull(@Training_Id,0) as varchar(10)) + '#' + 
											   'Marks :' + cast(Isnull(@Marks,0) as varchar(10))
		    --Added By Mukti 18082015(end)
				end
			Else
				begin
					set @Tran_Id=0
					return @Tran_Id
				end
		End
	Else if UPPER(@Tran_Type)= 'D'
		begin
			--Added By Mukti 18082015(start)
					select @Oldmarks = marks from t0152_Hrms_Training_Quest_Final WITH (NOLOCK) where tran_id = @Tran_Id
			--Added By Mukti 18082015(end)
			
			delete from t0152_Hrms_Training_Quest_Final where tran_id = @Tran_Id
			
			--Added By Mukti 18082015(start)
		    set @OldValue = 'Old Value' + '#'+ 'Training Question ID :' + cast(Isnull(@Training_Que_ID,0) as varchar(10)) + '#' + 
											   'Training Approval ID :' + cast(Isnull(@Training_Apr_Id,0) as varchar(10)) + '#' + 
											   'Training ID :' + cast(Isnull(@Training_Id,0) as varchar(10)) + '#' + 
											   'Marks :' + cast(Isnull(@OldMarks,'') as varchar(10))
		    --Added By Mukti 18082015(end)
		end
	 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Training Plan Ques.',@OldValue,@Tran_Id,@User_Id,@IP_Address
END

