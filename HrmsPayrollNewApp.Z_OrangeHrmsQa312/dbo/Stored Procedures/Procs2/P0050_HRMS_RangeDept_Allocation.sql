
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_HRMS_RangeDept_Allocation]
	 @RangeDept_ID		as numeric(18,0) output
	,@Cmp_ID			as numeric(18,0)
	,@Range_ID			as numeric(18,0) = null
	,@Range_Type		as int	= null
	,@Dept_ID			as numeric(18,0) = null
	,@Percent_Allocate  as numeric(18,2) = null
	,@Effective_Date	as datetime = null --19 sep 2016
	,@tran_type			varchar(1) 
	,@User_Id			numeric(18,0)	= 0
	,@IP_Address		varchar(30)		= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as varchar(max)
set @OldValue = ''

	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			If @Percent_Allocate = null
				begin
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Score is not Properly Inserted',0,'Enter Score',GetDate(),'Appraisal')										
					Return
				end	
		End
If Upper(@tran_type) ='I'
		begin
			select @RangeDept_ID = isnull(max(RangeDept_ID),0) + 1 from T0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
			Insert into T0050_HRMS_RangeDept_Allocation
			(
				 RangeDept_ID
				,Cmp_ID
				,Range_ID
				,Range_Type
				,Dept_ID
				,Percent_Allocate
				,Effective_Date --19 sep 2016
			)
			Values
			(
				 @RangeDept_ID
				,@Cmp_ID
				,@Range_ID
				,@Range_Type
				,@Dept_ID
				,@Percent_Allocate
				,@Effective_Date --19 sep 2016
			)
		End	
Else If  Upper(@tran_type) ='U' 
	Begin
		  Update T0050_HRMS_RangeDept_Allocation
		  Set    Percent_Allocate	= @Percent_Allocate,
				 Effective_Date     = @Effective_Date --19 sep 2016
		  Where  RangeDept_ID = @RangeDept_ID and Cmp_ID = @Cmp_ID
	End
Else If  Upper(@tran_type) ='D'
	Begin
		DELETE FROM T0050_HRMS_RangeDept_Allocation WHERE RangeDept_ID = @RangeDept_ID
	End	
END

----------------------------

