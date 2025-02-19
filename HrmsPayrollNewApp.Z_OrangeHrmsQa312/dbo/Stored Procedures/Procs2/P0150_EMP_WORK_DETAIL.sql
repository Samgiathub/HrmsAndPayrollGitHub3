



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_EMP_WORK_DETAIL]
	  @Work_Tran_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Emp_ID numeric(18,0)
	 ,@Work_ID numeric(18,0)
	 ,@Prj_ID numeric(18,0)
	 ,@Work_Date datetime
	 ,@Time_From varchar(50)
	 ,@Time_To varchar(50)
	 ,@Duration varchar(50)
	 ,@Description varchar(400)
	 ,@tran_type char
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		If @tran_type ='I' 
			begin
				If exists (Select Work_Tran_ID  from T0150_EMP_WORK_DETAIL WITH (NOLOCK) Where Emp_ID = @Emp_ID and Prj_ID=  @Prj_ID and Cmp_ID = @Cmp_ID and Work_ID=@Work_ID and Work_Date=@Work_Date) 
					begin
					
						delete  from T0150_EMP_WORK_DETAIL where Work_Tran_ID = @Work_Tran_ID 
						Select @Work_Tran_ID = isnull(max(Work_Tran_ID),0) + 1  from T0150_EMP_WORK_DETAIL WITH (NOLOCK)
						Insert Into T0150_EMP_WORK_DETAIL(Work_Tran_ID,Emp_ID,Cmp_ID,Prj_ID,Work_ID,Time_From,Time_To,Duration,Work_Date,Description)
						values(@Work_Tran_ID,@Emp_ID,@Cmp_ID,@Prj_ID,@Work_ID,@Time_From,@Time_To,@Duration,@Work_Date,@Description)
					end
				else
					begin
						Select @Work_Tran_ID = isnull(max(Work_Tran_ID),0) + 1  from T0150_EMP_WORK_DETAIL WITH (NOLOCK)
						Insert Into T0150_EMP_WORK_DETAIL(Work_Tran_ID,Emp_ID,Cmp_ID,Prj_ID,Work_ID,Time_From,Time_To,Duration,Work_Date,Description)
						values(@Work_Tran_ID,@Emp_ID,@Cmp_ID,@Prj_ID,@Work_ID,@Time_From,@Time_To,@Duration,@Work_Date,@Description)
					end		
			end
		else if @tran_type ='U' 
			begin
					
				Update T0150_EMP_WORK_DETAIL 
				Set 
					Prj_ID=@Prj_ID,
					Work_ID=@Work_ID,
					Time_From=@Time_From,
					Time_To=@Time_To,
					Duration=@Duration,
					Description=@Description
				
			end	
	Else If @tran_type ='D'
			Begin
				delete  from T0150_EMP_WORK_DETAIL where Work_Tran_ID = @Work_Tran_ID 

			End

	RETURN




