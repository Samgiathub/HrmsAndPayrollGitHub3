---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_VEHICLE_APPROVAL]
	@Vehicle_Apr_ID int OUTPUT,
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
	@Appr_Status varchar(25),
	@Approval_Date datetime,
	@Approval_Amount float,
	@S_Emp_ID numeric(18, 0),
	@Comments varchar(5000),
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

IF @Vehicle_App_ID=0
	SET @Vehicle_App_ID= NULL;

	IF @tran_type ='I' 			
			BEGIN			
				Insert Into T0120_VEHICLE_APPROVAL
				(Vehicle_App_ID, Cmp_ID, Vehicle_ID , Emp_ID, Manufacture_Year,Max_Limit,Initial_Emp_Contribution,Vehicle_Cost,Employee_Share,Attachment,Approval_Status,Approval_Date,Approval_Amount,S_Emp_ID,Comments,Transaction_By,Transaction_Date,Vehicle_Model,Vehicle_Manufacture,Vehicle_Option)
				Values 
				(@Vehicle_App_ID, @Cmp_ID, @Vehicle_ID, @Emp_ID, @Manufacture_Year,@Max_Limit,@Initial_Emp_Contribution,@Vehicle_Cost,@Employee_Share,@Attachment,@Appr_Status,@Approval_Date,@Approval_Amount,@S_Emp_ID,@Comments,@User_Id,getdate(),@Vehicle_Model,@Vehicle_Manufacture,@Vehicle_Option)
				
				UPDATE    T0100_VEHICLE_APPLICATION  
				SET        App_status = @Appr_Status  
				WHERE     Vehicle_App_ID = @Vehicle_App_ID

				set @Vehicle_App_ID = @@IDENTITY
				return
			END 	
	ELSE IF @tran_type ='U' 
				begin
						UPDATE   dbo.T0120_VEHICLE_APPROVAL
						SET		 Vehicle_ID =@Vehicle_ID										
								,Manufacture_Year=@Manufacture_Year
								,Max_Limit=@Max_Limit
								,Initial_Emp_Contribution=@Initial_Emp_Contribution
								,Vehicle_Cost=@Vehicle_Cost
								,Employee_Share=@Employee_Share
								,Attachment=@Attachment
								,Approval_Status =@Appr_Status 
								,Comments=@Comments
								,Vehicle_Model=@Vehicle_Model
								,Vehicle_Manufacture =@Vehicle_Manufacture
								,Transaction_By = @User_Id
								,Transaction_Date = getdate() 
								,Vehicle_Option=@Vehicle_Option
							where Vehicle_Apr_ID = @Vehicle_Apr_ID

						UPDATE    T0100_VEHICLE_APPLICATION  
						SET        App_status = @Appr_Status  
						WHERE     Vehicle_App_ID = @Vehicle_App_ID
			End
	ELSE IF @tran_type ='D'
		BEGIN
			UPDATE    T0100_VEHICLE_APPLICATION  
			SET        App_status =  'P'  
			WHERE     Vehicle_App_ID =@Vehicle_App_ID

			IF EXISTS(SELECT 1 FROM T0110_VEHICLE_REGISTRATION_DETAILS WITH (NOLOCK) WHERE Vehicle_App_ID=@Vehicle_App_ID)
				BEGIN
						RAISERROR (N'Vehicle Registration - Reference Exist.', 16, 2); 
						RETURN					
				END
			
				DELETE FROM dbo.T0115_VEHICLE_APPROVAL_LEVEL where Vehicle_App_ID = @Vehicle_App_ID
				DELETE FROM dbo.T0120_VEHICLE_APPROVAL where Vehicle_App_ID = @Vehicle_App_ID
		END
	
RETURN




