
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Hrms_RewardValues]
	 @RewardValues_Id		numeric(18,0) output
	,@Cmp_Id				numeric(18,0)  
	,@RewardValues_Name	    varchar(100)		
	,@tran_type				varchar(1) 
	,@User_Id				numeric(18,0) = 0
	,@IP_Address			varchar(30)= '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	 If Upper(@tran_type) ='I' or Upper(@tran_type) ='U'
		begin
			If exists(Select 1 from T0040_Hrms_RewardValues WITH (NOLOCK) where RewardValues_Name=@RewardValues_Name and RewardValues_Id<>@RewardValues_Id and cmp_id=@Cmp_Id)
				Begin
					Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
					Values (0,@Cmp_Id,0,'Duplicate entry of reward value name',0,'Duplicate name',GetDate(),'EmployeeReward')
					set @RewardValues_Id=0
					RETURN 
				End
		End
	If Upper(@tran_type) ='I'
		begin
			select @RewardValues_Id = isnull(max(RewardValues_Id),0) + 1 from T0040_Hrms_RewardValues WITH (NOLOCK)
			insert into T0040_Hrms_RewardValues
			(
				 RewardValues_Id
				,Cmp_Id	
				,RewardValues_Name
			)
			Values
			(
				 @RewardValues_Id
				,@Cmp_Id
				,@RewardValues_Name
			)
		End
	else if Upper(@tran_type) ='U'
		Begin
			Update  T0040_Hrms_RewardValues
			Set  RewardValues_Name = @RewardValues_Name
			Where RewardValues_Id = @RewardValues_Id
		End
	else if Upper(@tran_type) ='D'
		begin
				DELETE FROM T0040_Hrms_RewardValues WHERE RewardValues_Id = @RewardValues_Id	
		End
END
