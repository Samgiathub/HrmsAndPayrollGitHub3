
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[F_GET_OPTIONAL_HOLIDAY_BRANCH_LIMIT]
(
@Cmp_Id AS NUMERIC,
@EMP_ID as NUMERIC,
@HDay_ID as NUMERIC
)
RETURNS char(1)
AS
BEGIN	
	declare @branch_id as numeric(18,0)
	declare @Max_Limit as numeric(18,0)=0
	declare @count_emp as numeric(18,0)=0
	declare @flag char(1)
	
		select @branch_id=Branch_ID from V0080_EMP_MASTER_INCREMENT_GET where Emp_ID=@EMP_ID and Cmp_ID=@Cmp_Id
		
		select @Max_Limit=OH.Max_Limit from T0050_Optional_Holiday_Limit OH WITH (NOLOCK)
		inner join T0040_HOLIDAY_MASTER HM WITH (NOLOCK) on OH.Hday_ID=HM.Hday_ID
		where OH.Branch_ID=@branch_id and HM.Hday_ID=@HDay_ID

		select @count_emp=COUNT(OH.Op_Holiday_Apr_ID) from T0120_Op_Holiday_Approval OH WITH (NOLOCK)
		inner join V0080_EMP_MASTER_INCREMENT_GET EI on OH.Emp_ID=EI.Emp_ID
		inner join T0040_HOLIDAY_MASTER HM WITH (NOLOCK) on OH.Hday_ID=HM.Hday_ID
		where OH.Cmp_ID=@Cmp_Id and Op_Holiday_Apr_Status='A' and EI.Branch_ID=@branch_id and HM.Hday_ID=@HDay_ID
		
		--print @Max_Limit
		IF ISNULL(@Max_Limit,0) > 0 and ISNULL(@count_emp,0) > 0
		BEGIN
			IF 	ISNULL(@Max_Limit,0) > ISNULL(@count_emp,0)
				set @flag = 0
			ELSE
				set @flag = 1
		END
	RETURN @flag
END




