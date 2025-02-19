

-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 29/06/2023
-- Description:	Get the Template Field Data for API
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_TemplateField_Data]
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(9),	
	@T_Id numeric(18,0),
	@From_Date nvarchar(20)='',
	@To_Date nvarchar(20)='',
	@Flag nvarchar(50),
	@Response_Flag int
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	DECLARE @Status AS TINYINT
	SET @STATUS = 0

	if @Flag = 'L'
	begin
		Select distinct TM.T_ID,TM.Template_Title + ' (' + cast(TR.Response_Flag as varchar) + ')' as  Template_Title,
		TM.Template_Instruction,convert(date,TR.Created_Date,103) as Created_Date,
		TR.Response_Flag
		from T0100_Employee_Template_Response TR
		INNER JOIN T0050_Template_Field_Master TF on TF.F_ID = TR.F_Id
		INNER JOIN T0040_Template_Master TM on TM.T_ID = TR.T_ID
		where TR.Cmp_ID = @Cmp_ID and TR.Emp_Id = @Emp_ID
		and	Convert(nvarchar,TR.Created_Date,103) between Convert(nvarchar,@From_Date,103) and convert(nvarchar,@To_Date,103)
		and TM.Is_Active=1
	end
	else if @Flag='F'
	begin
		Select TF.*,TM.Template_Title,TM.Template_Instruction,TM.EmpId,'' as Answer
		from T0050_Template_Field_Master TF
		INNER JOIN T0040_Template_Master TM on TM.T_ID = TF.T_ID
		where TM.Cmp_ID = @Cmp_ID
		and TM.T_ID = @T_Id
		--and	Convert(datetime,TM.CreatedDate,103) between Convert(datetime,@From_Date,103) and convert(datetime,@To_Date,103)
		--and	TM.CreatedDate between @From_Date and @To_Date
		and TM.Is_Active=1
		order by TF.Sorting_No
	end
	else if @Flag='C'
	begin
		WITH tmp AS
		(
			SELECT
				T_ID,Template_Title,Is_Active,
				LEFT(EmpId, CHARINDEX('#', EmpId + '#') - 1) EmpId,
				STUFF(EmpId, 1, CHARINDEX('#', EmpId+ '#'), '') b,
				Cmp_ID
			FROM T0040_Template_Master
			
			UNION all

			SELECT
				T_ID,Template_Title,Is_Active,
				LEFT(b, CHARINDEX('#', b + '#') - 1),
				STUFF(b, 1, CHARINDEX('#', b + '#'), ''),
				Cmp_ID
			FROM tmp
			WHERE
				b > ''
		)
		
		SELECT
			T_ID,Template_Title, EmpId
		FROM tmp
		where EmpId=@Emp_ID
		and Is_Active = 1
		and Cmp_ID = @Cmp_ID
		ORDER BY T_ID
		OPTION (MAXRECURSION 0);
	end
	else if @Flag='D'
	begin
		Delete from T0100_Employee_Template_Response 
		where Cmp_Id = @Cmp_ID and Emp_Id = @Emp_ID
		and T_Id = @T_Id
		and Response_Flag = @Response_Flag
		Select 'Successfully Deleted' 
		Return
	end
	else if @Flag='R'
	begin
		Select T_ID,Template_Title from T0040_Template_Master 
		where Is_Active = 1
		and Cmp_ID = @Cmp_ID
	end
