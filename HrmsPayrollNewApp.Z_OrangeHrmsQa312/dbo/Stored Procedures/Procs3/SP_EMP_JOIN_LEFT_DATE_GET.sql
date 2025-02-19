




CREATE PROCEDURE [dbo].[SP_EMP_JOIN_LEFT_DATE_GET]
	@Emp_Id		numeric,
	@Cmp_ID		numeric,
	@From_Date	Datetime,
	@To_Date	Datetime ,
	@Join_Date	Datetime = null output ,
	@Left_Date	Datetime = null output
	
AS
		Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	 
	 
	 Select @Join_Date = max(join_date)		From T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) where emp_id = @emp_Id and Cmp_ID = @Cmp_ID
	 and Left_date <= @To_Date
	 
	 If isnull(@Join_date,'') =''
		 Select @Join_date = max(join_date)  From T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) where emp_id = @emp_Id and Cmp_ID = @Cmp_ID

	 
	  Select @Left_Date = Left_Date From T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)  Where Emp_ID = @Emp_ID and Join_Date = @Join_Date
	 
	RETURN




