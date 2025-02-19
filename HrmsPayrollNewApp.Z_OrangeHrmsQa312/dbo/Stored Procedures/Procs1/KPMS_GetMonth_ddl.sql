CREATE PROCEDURE [dbo].[KPMS_GetMonth_ddl]
(
@Cmp_Id INT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

Declare @lmonthResult varchar(max) =''
Declare @lGoalSheetResult varchar(max) =''

			SELECT @lmonthResult = '<option value="0"> -- Select -- </option>'
			SELECT @lmonthResult = @lmonthResult + '<option value="'+ CONVERT(VARCHAR,Fin_Month_ID) + '"> '+Month_Name+'</option>'
			FROM KPMS_Finance_Year_Months  

		    SELECT @lGoalSheetResult = '<option value="0"> -- Select -- </option>'
			SELECT @lGoalSheetResult = @lGoalSheetResult + '<option value="'+ CONVERT(VARCHAR,GS_Id) + '"> '+GS_SheetName+'</option>'
			FROM KPMS_T0100_Goal_Setting WHERE Cmp_Id = @Cmp_Id

	SELECT @lmonthResult AS Month_Name,@lGoalSheetResult as GoalSheetResult 
	
END
