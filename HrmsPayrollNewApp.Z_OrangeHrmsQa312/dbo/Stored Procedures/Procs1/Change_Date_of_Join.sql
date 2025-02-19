

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Change_Date_of_Join]
	@Cmp_ID as Numeric,
	@Emp_Code as Varchar(20),
	@New_DOJ  as datetime,
	@Old_DOJ as datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		--Declare @Emp_Code as varchar(100)
		--Declare @DOJ as datetime
		--Declare @Old_DOJ As Datetime
		--Declare @cmp_Id as numeric

		--Set @Emp_Code = '394'
		--Set @DOJ = '11-Feb-2013'
		--Set @Old_DOJ = '11-Dec-2013'
		--set @Cmp_id = 2
		
		Declare @Emp_Id  as Numeric
		Select @Emp_Id = Emp_ID From T0080_EMP_MASTER WITH (NOLOCK) Where Alpha_Emp_Code = @Emp_Code And Cmp_Id = @Cmp_Id


		Update T0080_EMP_MASTER Set Date_Of_Join = @New_DOJ Where Emp_ID = @Emp_Id
		Update T0110_EMP_LEFT_JOIN_TRAN Set Join_Date = @New_DOJ Where Emp_ID = @Emp_Id And Join_Date = @Old_DOJ
		Update T0095_INCREMENT Set Increment_Effective_Date = @New_DOJ Where Emp_ID = @Emp_Id And Increment_Effective_Date = @Old_DOJ
		Update T0100_WEEKOFF_ADJ Set For_Date = @New_DOJ Where Emp_ID = @Emp_Id And For_Date = @Old_DOJ
		Update T0100_EMP_SHIFT_DETAIL Set For_Date = @New_DOJ Where Emp_ID = @Emp_Id And For_Date = @Old_DOJ

		Select Date_Of_Join, * from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_Id
		Select Join_Date, * from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) Where Emp_ID = @Emp_Id
		Select Increment_Effective_Date, * from T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_Id
		Select For_Date,* from T0100_WEEKOFF_ADJ WITH (NOLOCK) Where Emp_ID = @Emp_Id
		Select For_Date,* from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) Where Emp_ID = @Emp_Id
END

