
CREATE PROCEDURE [dbo].[DEPENDENT_SAVED_DETAILS]
@cmp_id numeric
,@emp_id numeric

As
Begin

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET ARITHABORT ON;

declare @ins_cap as varchar(500) = ''
declare @emp_row as varchar(500) = ''
declare @emp_dependentid as varchar = ''


		select @ins_cap=Ins_Cmp_name,@emp_row = Emp_Dependent_ID
		from T0090_EMP_INSURANCE_DETAIL where Cmp_ID = @cmp_id and Emp_ID = @emp_id

		set @emp_dependentid = REPLACE(@emp_row,'#',',')

		Select distinct cd.Emp_id,Row_Id,cd.Cmp_ID,Name,Gender,Date_Of_Birth,C_Age,Relationship,
		Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height,Weight from T0090_EMP_CHILDRAN_DETAIL CD
		inner join T0090_EMP_INSURANCE_DETAIL ID
		on cd.Emp_ID = id.Emp_Id
		where cd.Cmp_ID = @cmp_id and cd.Emp_Id = @emp_id
		and Cast(Row_ID as numeric) in (Cast(@emp_dependentid as numeric))
		and Ins_Cmp_name = @ins_cap

End