



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_JOBWORK_ALLOCATION]
		 @Row_ID numeric(18,0) output
		,@Cmp_ID numeric(18,0)
		,@Agency_ID numeric(18,0)
		,@Prj_ID numeric(18,0) 
		,@Work_ID numeric(18,0) 
		,@Start_Date datetime
		,@End_Date datetime	
		,@Work_Detail varchar(250)
		,@Submit_Date datetime
		,@Prj_Status char(1)
		,@Remark varchar(250)
		,@tran_type varchar(1)
 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		IF @Submit_Date = ''
		SET @Submit_Date  = NULL
		
		If @tran_type ='I' 
			begin
				If exists (Select Row_ID  from T0150_JOBWORK_ALLOCATION WITH (NOLOCK) Where Agency_ID = @Agency_ID and Prj_ID=  @Prj_ID and Cmp_ID = @Cmp_ID and Work_ID=@Work_ID ) 
					begin
						set @Row_ID=0
						return
					end
						select @Row_ID = isnull(max(Row_ID),0)+1 from T0150_JOBWORK_ALLOCATION WITH (NOLOCK)
						
						Insert into T0150_JOBWORK_ALLOCATION(Row_ID,Cmp_ID,Agency_ID,Prj_ID,Work_ID,Start_Date,End_Date,Work_Detail,Submit_Date,Prj_Status,Remark)
						 values(@Row_ID,@Cmp_ID,@Agency_ID,@Prj_ID,@Work_ID,@Start_Date,@End_Date,@Work_Detail,@Submit_Date,@Prj_Status,@Remark)
						Return @Row_ID
					end 
		Else if @tran_type ='U' 
			begin
			 if @Prj_Status = 'N'
				begin
						Update T0150_JOBWORK_ALLOCATION
					set Prj_Status= @Prj_Status,
						Agency_ID=@Agency_ID,
						Prj_ID=@Prj_ID,
						Work_ID=@Work_ID,
						Start_Date=@Start_Date,
						End_Date=@End_Date,
						Remark= @Remark
					where Row_ID=@ROW_ID
				end
				else if @Prj_Status = 'Y'
				 begin
					Update T0150_JOBWORK_ALLOCATION
					set Prj_Status= @Prj_Status,
						Agency_ID=@Agency_ID,
						Submit_Date= @Submit_Date,
						Remark= @Remark
					where Row_ID=@ROW_ID
				 end
			end
		
	else if @tran_type ='d' or @tran_type ='D'
			delete  from T0150_JOBWORK_ALLOCATION where Row_ID=@Row_ID
			

	RETURN




