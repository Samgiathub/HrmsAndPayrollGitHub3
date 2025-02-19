

 ---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Employee_Transport_Registration]

	@Transport_Reg_ID numeric(18,0) OUTPUT,
	@Emp_ID numeric(18,0),
	@Route_ID numeric(18,0),
	@Pickup_ID numeric(18,0),
	@Vehicle_ID numeric(18,0),
	@Designation_ID numeric(18,0),
	@Transport_Status int,
	@Transport_Type char(1),
	@Effective_Date datetime,
	@Cmp_ID numeric(18,0),
	@Login_ID numeric(18,0),
	@Trans_Type char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Trans_Type = 'I'
	BEGIN
			--IF EXISTS (SELECT Transport_Reg_ID FROM T0040_Employee_Transport_Registration WHERE Emp_ID = @Emp_ID )
		SELECT @Transport_Reg_ID = ISNULL(MAX(Transport_Reg_ID),0) + 1 FROM T0040_Employee_Transport_Registration WITH (NOLOCK)
		
		INSERT INTO T0040_Employee_Transport_Registration(Transport_Reg_ID,Emp_ID,Route_ID,Pickup_ID,Vehicle_ID,Designation_ID,
		Transport_Status,Transport_Type,Effective_Date,Cmp_ID,Created_By,Created_Date)VALUES(@Transport_Reg_ID,@Emp_ID,@Route_ID,
		@Pickup_ID,@Vehicle_ID,@Designation_ID,@Transport_Status,@Transport_Type,@Effective_Date,@Cmp_ID,@Login_ID,GETDATE())
	END
ELSE IF @Trans_Type = 'D'
	BEGIN
		DELETE FROM T0040_Employee_Transport_Registration WHERE Transport_Reg_ID = @Transport_Reg_ID
	END
