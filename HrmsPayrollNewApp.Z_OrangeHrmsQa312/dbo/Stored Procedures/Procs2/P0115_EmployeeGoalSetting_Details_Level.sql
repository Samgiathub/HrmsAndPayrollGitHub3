


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_EmployeeGoalSetting_Details_Level]
	   @Tran_Id		numeric(18,0)
      ,@Cmp_Id		numeric(18,0)
      ,@Emp_Id		numeric(18,0)
      ,@Emp_GoalSetting_Detail_Id	numeric(18,0)
      ,@EGS_Level_Id numeric(18,0)
      ,@KRA			nvarchar(500)
      ,@KPI			nvarchar(500)
      ,@Target		nvarchar(500)
      ,@Weight		numeric(18,0)
      ,@Rpt_Level	tinyint
      ,@tran_type		varchar(1) =null
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
	BEGIN
		if @EGS_Level_Id =0
			BEGIN
				select @EGS_Level_Id = max(EGS_Level_Id) from t0110_EmployeeGoalSetting_Approval WITH (NOLOCK)
				where rpt_level= @Rpt_Level and emp_id= @emp_id
			END
		select @Tran_Id = isnull(max(Tran_Id),0)+1 from T0115_EmployeeGoalSetting_Details_Level WITH (NOLOCK)
		
			INSERT INTO  T0115_EmployeeGoalSetting_Details_Level
				(
				  Tran_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,Emp_GoalSetting_Detail_Id
				  ,EGS_Level_Id
				  ,KRA
				  ,KPI
				  ,[Target]
				  ,[Weight]
				  ,Rpt_Level
				)VALUES
				(
				   @Tran_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Emp_GoalSetting_Detail_Id
				  ,@EGS_Level_Id
				  ,@KRA
				  ,@KPI
				  ,@Target
				  ,@Weight
				  ,@Rpt_Level
				)
		END
	Else IF UPPER(@tran_type)='U'
		BEGIN
			UPDATE  T0115_EmployeeGoalSetting_Details_Level
			SET  [KRA]	=	@KRA,
				 [KPI]	=	@KPI,	
				 [Target] = @Target,
				 [Weight] = @Weight		
			WHERE Tran_Id = @Tran_Id
		END
	Else if UPPER(@tran_type)='D'
		BEGIN
			Delete from T0115_EmployeeGoalSetting_Details_Level where Tran_Id = @Tran_Id
		END
END


