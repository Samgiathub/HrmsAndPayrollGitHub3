



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_FINAL_SCORE]
	@STATE_ID AS NUMERIC output,
	@CMP_ID AS NUMERIC,
	@STATE_NAME AS VARCHAR(100),
	@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin
				If Exists(Select State_ID From T0020_STATE_MASTER  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and State_Name = @State_Name)
					begin
						set @STATE_ID = 0
						Return 
					end
				
				select @State_ID = Isnull(max(state_id),0) + 1 	From T0020_STATE_MASTER WITH (NOLOCK)
				
				INSERT INTO T0020_STATE_MASTER
				                      (State_ID, Cmp_ID, State_Name)
				VALUES     (@State_ID, @Cmp_ID, @State_Name)
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select State_ID From T0020_STATE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and State_Name = @State_Name and State_ID <> @State_ID)
					begin
						set @STATE_ID = 0
						Return 
					end

				Update T0020_STATE_MASTER
				set STate_Name = @State_Name
				where State_ID = @State_ID
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0020_STATE_MASTER Where State_ID = @State_ID
		end

	RETURN




