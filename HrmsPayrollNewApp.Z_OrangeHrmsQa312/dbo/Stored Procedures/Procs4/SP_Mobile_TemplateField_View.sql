

-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 01/07/2023
-- Description:	Get the Template Field Data View for API
-- exec SP_Mobile_TemplateField_View 120,13
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_TemplateField_View] 
	@Cmp_ID numeric(18,0),
	@T_ID numeric(18,0),
	@Emp_Id numeric(18,0),
	@Response_Flag int
AS
BEGIN
		Select TR.ETR_Id,TM.T_ID,TF.Field_Name,TF.Field_Type,TR.Answer,TF.Sorting_No,TR.Emp_Id,TR.Response_Flag,
		CONVERT(VARCHAR(10), TR.Created_Date, 103) + ' '  + convert(VARCHAR(8), TR.Created_Date, 14) as Response_Created_Date		
		from T0100_Employee_Template_Response TR
		INNER JOIN T0050_Template_Field_Master TF on TF.F_ID = TR.F_Id
		INNER JOIN T0040_Template_Master TM on TM.T_ID = TR.T_ID
		where TM.T_ID = @T_ID
		and TM.Cmp_ID = @Cmp_ID
		and TR.Emp_Id = @Emp_Id
		and TR.Response_Flag = @Response_Flag
		order by TF.Sorting_No
		
		
		
	--	SELECT
	--	TR.ETR_Id,
	--	TR.Cmp_Id,
	--	TR.Emp_Id,
	--	TR.T_Id,
	--	TR.F_Id,
	--	TR.Answer,
	--	TR.Created_Date,
	--	1 AS GroupNumber
	--from T0100_Employee_Template_Response TR
	--	INNER JOIN T0050_Template_Field_Master TF on TF.F_ID = TR.F_Id
	--	INNER JOIN T0040_Template_Master TM on TM.T_ID = TR.T_ID
	--	where TM.T_ID = @T_ID
	--	and TM.Cmp_ID = @Cmp_ID and
	--	Tr.Emp_Id = @Emp_Id and
	--TR.Response_Flag=1 -- First group

	--UNION ALL

	--SELECT
	--	TR.ETR_Id,
	--	TR.Cmp_Id,
	--	TR.Emp_Id,
	--	TR.T_Id,
	--	TR.F_Id,
	--	TR.Answer,
	--	TR.Created_Date,
	--	2 AS GroupNumber
	--from T0100_Employee_Template_Response TR
	--	INNER JOIN T0050_Template_Field_Master TF on TF.F_ID = TR.F_Id
	--	INNER JOIN T0040_Template_Master TM on TM.T_ID = TR.T_ID
	--	where TM.T_ID = @T_ID
	--	and TM.Cmp_ID = @Cmp_ID and
	--	Tr.Emp_Id = @Emp_Id and
	--TR.Response_Flag = 2

	--ORDER BY GroupNumber, ETR_Id;


END
