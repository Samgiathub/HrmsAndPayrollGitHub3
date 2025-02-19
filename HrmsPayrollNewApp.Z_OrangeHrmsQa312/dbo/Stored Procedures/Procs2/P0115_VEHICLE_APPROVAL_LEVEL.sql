
CREATE PROCEDURE [dbo].[P0115_VEHICLE_APPROVAL_LEVEL]
	@Tran_ID int OUTPUT,
	@Vehicle_App_ID int,
	@Cmp_ID numeric(18, 0),
	@Emp_ID numeric(18, 0),
	@Vehicle_ID int,
	@Manufacture_Year int,
	@Max_Limit float,
	@Initial_Emp_Contribution float,
	@Vehicle_Cost float,
	@Employee_Share float,
	@Attachment varchar(5000),
	@Vehicle_Appr_Status varchar(25),
	@Approval_Date datetime,
	@Approval_Amount float,
	@S_Emp_ID numeric(18, 0),
	@Comments varchar(5000),
	@Rpt_level int,		
	@Vehicle_Model varchar(500),
	@Vehicle_Manufacture varchar(500),
	@Vehicle_Option VARCHAR(100),
	@User_Id numeric(18,0) = 0,
    @IP_Address varchar(30)= '',
	@Tran_Type char
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL
	
	If UPPER(@Tran_Type) = 'I'
		Begin			
			IF Exists(Select 1 From T0115_VEHICLE_APPROVAL_LEVEL WITH (NOLOCK) Where Emp_ID=@Emp_ID and Vehicle_App_ID=@Vehicle_App_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)			
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End		
			Insert Into T0115_VEHICLE_APPROVAL_LEVEL
			(Vehicle_App_ID, Cmp_ID, Vehicle_ID , Emp_ID, Manufacture_Year,Max_Limit,Initial_Emp_Contribution,Vehicle_Cost,Employee_Share,Attachment,Vehicle_Appr_Status,Approval_Date,Approval_Amount,S_Emp_ID,Comments,Rpt_level,Vehicle_Model,Vehicle_Manufacture ,Transaction_By,Transaction_Date,Vehicle_Option)
			Values 
			(@Vehicle_App_ID, @Cmp_ID, @Vehicle_ID, @Emp_ID, @Manufacture_Year,@Max_Limit,@Initial_Emp_Contribution,@Vehicle_Cost,@Employee_Share,@Attachment,@Vehicle_Appr_Status,@Approval_Date,@Approval_Amount,@S_Emp_ID,@Comments,@Rpt_level,@Vehicle_Model,@Vehicle_Manufacture ,@User_Id,getdate(),@Vehicle_Option)
			
		End
	ELSE IF @tran_type ='D'
		BEGIN	
			DELETE FROM dbo.T0115_VEHICLE_APPROVAL_LEVEL where Tran_ID = @Tran_ID
			DELETE FROM dbo.T0120_VEHICLE_APPROVAL where Vehicle_App_ID = @Vehicle_App_ID

			--IF NOT EXISTS (SELECT 1 FROM T0115_VEHICLE_APPROVAL_LEVEL  WHERE Vehicle_App_ID = @Vehicle_App_ID)
			--BEGIN
				UPDATE    T0100_VEHICLE_APPLICATION  
				SET        App_status =  'P'  
				WHERE     Vehicle_App_ID =@Vehicle_App_ID
			--END
		END
END


