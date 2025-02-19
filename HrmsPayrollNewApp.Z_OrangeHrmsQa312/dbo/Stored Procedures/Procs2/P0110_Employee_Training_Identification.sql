
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_Employee_Training_Identification] 
	 @cmp_id				numeric(18, 0)	
	,@Alpha_Emp_Code		varchar(250)
	,@Training_Name		    varchar(500)
	,@Training_Year		    varchar(10)
	,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= ''
    ,@Row_No int
    ,@Log_Status Int = 0 Output    
    ,@GUID Varchar(2000) = ''
AS  

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

begin	

	DECLARE @Emp_Training_ID AS NUMERIC(18,0)
	declare @Emp_id Numeric(18,0)
	declare @Emp_name varchar(250)
	declare @is_left char(2)
	set @Emp_id=0
	declare @Training_id Numeric(18,0)
	set @Training_id=0
	
 
	   select @Emp_id = emp_id,@Emp_name=Emp_Full_Name,@is_left=Emp_Left from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
	   select @Training_id = isnull(Training_id,0) from T0040_Hrms_Training_master WITH (NOLOCK) where Training_name = @Training_Name and Cmp_ID = @cmp_id 
	   	
	   if @Emp_id=0
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Enter proper Employee code',0,'Enter proper Employee code',GetDate(),'Training Identification Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		
		if @is_left='Y'
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee already left',0,'Employee already left',GetDate(),'Training Identification Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		
		if @Training_id=0
			begin
				Set @Training_id = 0
				Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Training Name does not exist',0,'Enter proper Training Name',GetDate(),'Training Identification Import',@GUID)						
				Set @Log_Status=1
				return
			end	 	
		
		if exists(select Emp_Training_ID from T0110_Employee_Training_Identification WITH (NOLOCK)  where Emp_ID = @Emp_ID and Training_Year=@Training_Year and Training_ID=@Training_ID and Cmp_ID = @cmp_id)
			begin
				Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Already exist Employee for this Training-' + @Training_name,0,'This Employee already exist for this Training',GetDate(),'Training Identification Import',@GUID)						
				Set @Log_Status=1
				return
			end	 	
		
		
		select @Emp_Training_ID = Isnull(max(Emp_Training_ID),0) + 1  From T0110_Employee_Training_Identification WITH (NOLOCK) 
		INSERT INTO T0110_Employee_Training_Identification  
                        (  Emp_Training_ID
							,Emp_ID
							,cmp_id
							,Training_ID
							,Training_Year							
							)  
         		VALUES     (
         					@Emp_Training_ID
							,@Emp_ID
							,@cmp_id
							,@Training_ID
							,@Training_Year	
							)
	END	
RETURN
  
  


