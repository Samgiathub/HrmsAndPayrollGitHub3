



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_HEALTH]
	@Row_ID	numeric(18, 0)	output
	,@Cmp_ID	numeric(18, 0)	
	,@Resume_ID	numeric(18, 0)	
	,@Blood_group	varchar(20)	
	,@Height	varchar(20)	
	,@weight	varchar(20)	
	,@emp_file_name varchar(100)	
	,@file_name	varchar(100)	
	,@Trans_Type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @Trans_Type   = 'I'
		Begin
				If Exists(Select Row_ID From T0090_HRMS_RESUME_HEALTH  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Resume_ID = @Resume_ID)
					begin
						set @Row_ID = 0
					Return 
				end
				
				select @Row_ID= Isnull(max(Row_ID),0) + 1 	From T0090_HRMS_RESUME_HEALTH WITH (NOLOCK)
				
				INSERT INTO T0090_HRMS_RESUME_HEALTH
				                      (Row_ID
										,Cmp_ID
										,Resume_ID
										,Blood_group
										,Height
										,weight
										,emp_file_name
										,file_name
										)
				VALUES					(@Row_ID
										,@Cmp_ID
										,@Resume_ID
										,@Blood_group
										,@Height
										,@weight
										,@emp_file_name
										,@file_name)
		End
	Else if @Trans_Type  = 'U'
		begin
				If Exists(Select Row_ID From T0090_HRMS_RESUME_HEALTH  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Row_ID <> @Row_ID and Resume_ID = @Resume_ID)
					begin
						set @Row_ID = 0
						Return 
					end

				Update T0090_HRMS_RESUME_HEALTH
				set 
					Blood_group=@Blood_group
					,Height=@Height
					,weight=@weight
					,file_name=@file_name
					,emp_file_name=@emp_file_name
				where Row_ID = @Row_ID
				
		end
	Else if @Trans_Type  = 'D'
		begin
				Delete From T0091_HRMS_RESUME_HEALTH_DETAIL Where Row_ID= @Row_ID
				Delete From T0090_HRMS_RESUME_HEALTH Where Row_ID= @Row_ID
		end

	RETURN




