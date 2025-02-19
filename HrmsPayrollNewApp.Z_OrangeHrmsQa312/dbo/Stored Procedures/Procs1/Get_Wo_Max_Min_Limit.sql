

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Wo_Max_Min_Limit]
	@Emp_Id as numeric(18,0)
	,@Cmp_Id as numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
		Declare @Branch_Id as numeric
		
		Select @Branch_Id = ISNULL(Branch_ID,0) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_Id
			AND Increment_Id = (  --Changed by Hardik 10/09/2014 for Same Date Increment
			select MAX(Increment_Id) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_Id)
			
			
		--Select MinWODays,MaxWODays from T0040_GENERAL_SETTING where Branch_ID = @Branch_Id  ''Modified By Ramiz on 15092014
		Select MinWODays,MaxWODays from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Branch_ID =@Branch_Id 
		and For_date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Branch_ID =@Branch_Id)
END


