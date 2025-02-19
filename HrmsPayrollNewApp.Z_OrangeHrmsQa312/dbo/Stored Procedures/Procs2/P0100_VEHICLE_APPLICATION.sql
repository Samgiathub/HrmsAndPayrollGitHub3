---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_VEHICLE_APPLICATION]
		 @Vehicle_App_ID	numeric(18, 0) OUTPUT		
		,@Cmp_ID	numeric(18, 0)
		,@Emp_ID	numeric(18, 0)
		,@Vehicle_ID	numeric(18, 0)
		,@Manufacture_Year INT
		,@Max_Limit		FLOAT
		,@Vehicle_App_Date	datetime
		,@Initial_Emp_Contribution FLOAT
		,@Vehicle_Cost FLOAT
		,@Employee_Share FLOAT	 	
		,@Attachment varchar(max)
		,@App_status varchar(25)	
		,@Vehicle_Model varchar(500)
		,@Vehicle_Manufacture varchar(500)
		,@Vehicle_Option VARCHAR(100)
		,@tran_type  Varchar(1) 		
		,@User_Id numeric(18,0) = 0 
		,@IP_Address varchar(30)= '' 
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if @tran_type ='I' 
			begin
				If exists(select 1 From dbo.T0100_VEHICLE_APPLICATION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Vehicle_ID = @Vehicle_ID and App_Status <> 'R')
					BEGIN
							Set @Vehicle_App_ID = 0
									RAISERROR('Vehicle Request already Exist',16,2)
									RETURN 
					END
			ELSE
			BEGIN			
				INSERT INTO dbo.T0100_VEHICLE_APPLICATION
							(Cmp_ID
								,Emp_ID
								,Vehicle_ID
								,Manufacture_Year
								,Max_Limit
								,Initial_Emp_Contribution
								,Vehicle_Cost
								,Employee_Share
								,Attachment
								,App_Status
								,Vehicle_App_Date
								,Vehicle_Model
								,Vehicle_Manufacture 
								,Transaction_By
								,Transaction_Date		
								,Vehicle_Option
								)
							VALUES      
							(@Cmp_ID
								,@Emp_ID
								,@Vehicle_ID								
								,@Manufacture_Year
								,@Max_Limit
								,@Initial_Emp_Contribution
								,@Vehicle_Cost
								,@Employee_Share
								,@Attachment
								,@App_Status
								,@Vehicle_App_Date	
								,@Vehicle_Model
								,@Vehicle_Manufacture 
								,@User_Id
								,getdate()	
								,@Vehicle_Option
								)
					set @Vehicle_App_ID = @@IDENTITY
					return
			END 
	END
	else if @tran_type ='U' 
				begin				
					if exists(select Vehicle_App_ID from T0115_VEHICLE_APPROVAL_LEVEL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Vehicle_App_ID=@Vehicle_App_ID and Emp_ID=@Emp_ID)
						begin					
							RAISERROR (N'Vehicle Approval - Reference Exist.', 16, 2); 
							RETURN					
						end

						UPDATE    dbo.T0100_Vehicle_APPLICATION
						SET		 Vehicle_ID =@Vehicle_ID
								,Vehicle_App_Date=@Vehicle_App_Date								
								,Manufacture_Year=@Manufacture_Year
								,Max_Limit=@Max_Limit
								,Initial_Emp_Contribution=@Initial_Emp_Contribution
								,Vehicle_Cost=@Vehicle_Cost
								,Employee_Share=@Employee_Share
								,Attachment=@Attachment
								,App_Status =@App_Status 
								,Vehicle_Model=@Vehicle_Model
								,Vehicle_Manufacture =@Vehicle_Manufacture
								,Transaction_By = @User_Id
								,Transaction_Date = getdate() 
								,Vehicle_Option=@Vehicle_Option
							where Vehicle_App_ID = @Vehicle_App_ID
			End
	else if @tran_type ='D'
	begin
		if exists(select @Vehicle_App_ID from T0115_VEHICLE_APPROVAL_LEVEL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Vehicle_App_ID=@Vehicle_App_ID and Emp_ID=@Emp_ID)
					begin					
						RAISERROR (N'Vehicle Approval - Reference Exist.', 16, 2); 
						RETURN					
					end

		IF EXISTS(SELECT 1 FROM T0110_VEHICLE_REGISTRATION_DETAILS WITH (NOLOCK) WHERE Vehicle_App_ID=@Vehicle_App_ID)
				BEGIN
						RAISERROR (N'Vehicle Registration - Reference Exist.', 16, 2); 
						RETURN					
				END

		DELETE FROM dbo.T0100_Vehicle_APPLICATION where Vehicle_App_ID = @Vehicle_App_ID
	
	end
	
RETURN




