
-- =============================================
-- Author    : Alpesh
-- ALTER date: 14-Jul-2012
-- Description:	
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_EMP_INOUT_RECORD_MANUAL] 
	 @Emp_ID		numeric(18)    
    ,@Cmp_Id		numeric(18)
    ,@Inout			numeric(18)
    ,@Today 		numeric(18)
    ,@IP_ADDRESS	VARCHAR(50)
	,@FileName		Varchar(100) = NULL	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	declare @New_In_Time Datetime  
	declare @New_Out_Time Datetime  
	declare @In_Time Datetime      
	declare @Out_Time Datetime      
	declare @s_time varchar(10)
	declare @e_time varchar(10)
	declare @IO_Tran_Id numeric(18)
	declare @Min_IO_Tran_Id	numeric(18)
	declare @Max_IO_Tran_Id	numeric(18) 

	Declare @Is_Night_Shift as numeric
	Set @Is_Night_Shift = 0		
		
	Declare @For_Date datetime

	--Added by Nimesh 21 April, 2015
	DECLARE @Shift_ID numeric(18,0);
		
	If @Today = 1
		Begin
			Set @For_Date = CONVERT(varchar(10),getdate(),120)
			Set @New_In_Time = @For_Date
			Set @New_Out_Time = @For_Date
			
			-- ADD Deepal 09-02-2021
			Declare @InOut_duration_Gap numeric 
			select @InOut_duration_Gap = ISNULL(Inout_Duration,300) from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID   
			-- END Deepal 09-02-2021			
			Select @In_Time = Min(In_Time),@Out_Time = Max(Out_Time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date	

			--Modified by Nimesh 21 April, 2015			
			SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_Id, @Emp_ID,@For_Date);
						
			SELECT	@s_time = Shift_St_Time, @e_time = Shift_End_Time 
			FROM	dbo.T0040_Shift_Master WITH (NOLOCK)
			WHERE	Cmp_Id = @Cmp_Id and Shift_Id=@Shift_ID
			--Select @s_time = Shift_St_Time, @e_time = Shift_End_Time From dbo.T0040_Shift_Master Where Cmp_Id = @Cmp_Id and Shift_Id=(Select Shift_Id From dbo.T0100_Emp_shift_detail Where Emp_Id = @Emp_ID And Cmp_Id = @Cmp_Id And For_Date=(Select Max(For_date) From dbo.T0100_Emp_shift_detail where Emp_Id=@Emp_ID And Cmp_Id=@Cmp_Id)) 
			--End Nimesh 
			
			if @s_time > @e_time
				Begin
					set @New_Out_Time = dateadd(d,1,@New_Out_Time)
					Set @Is_Night_Shift = 1
				End		
						
			--If @In_Time is null and @Inout = 0
			
			If @Inout = 0
				Begin
					set @New_In_Time = CONVERT(varchar(100),GETDATE(),120)
					--exec SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID,@Cmp_Id,@New_In_Time,@IP_ADDRESS,0,@Is_Night_Shift
					
					SELECT @In_Time=Max(IO_Datetime)  FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK) WHERE emp_ID=@emp_ID  
					And IO_Datetime < @New_In_Time 
					if isnull(datediff(s,@In_Time,@New_In_Time),0) > @InOut_duration_Gap or @In_Time is null						  
						BEGIN
								INSERT INTO T9999_MOBILE_INOUT_DETAIL    
									(IO_Tran_Id, Emp_ID, Cmp_ID, IO_Datetime, IMEI_No, In_Out_Flag, Latitude,Longitude
									,Location,Emp_Image,Reason,Approval_Status	
									,Approval_by,Approval_date,Approval_From_Mobile,Is_Verify,IsOffline	,Vertical_ID
									,SubVertical_ID	,ManagerComment	,R_Emp_ID) 
								VALUES
									(NULL,@Emp_ID,@Cmp_ID,@New_In_Time,'PAYROLL','I',null,null,NULL
									,@FileName,NULL, 0, 0,@For_Date,0,NULL,0,NULL,NULL,NULL,NULL)    
						END
				End
			
			--If @Out_Time is null and @Inout = 1	
			If @Inout = 1	
				Begin
					set @New_Out_Time = CONVERT(varchar(100),GETDATE(),120)
					--exec SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID,@Cmp_Id,@New_Out_Time,@IP_ADDRESS,1,@Is_Night_Shift

					INSERT INTO T9999_MOBILE_INOUT_DETAIL    
								(IO_Tran_Id, Emp_ID, Cmp_ID, IO_Datetime, IMEI_No, In_Out_Flag, Latitude,Longitude
								,Location,Emp_Image,Reason,Approval_Status	
								,Approval_by,Approval_date,Approval_From_Mobile,Is_Verify,IsOffline	,Vertical_ID,SubVertical_ID
								,ManagerComment	,R_Emp_ID) 
								VALUES
								(NULL,@Emp_ID,@Cmp_ID,@New_Out_Time,'PAYROLL','O',null,null,NULL,@FileName,NULL, 0, 0
								,@For_Date,0,NULL,0,NULL,NULL,NULL,NULL)
				End
						
			
		End
	Else
		Begin
			Set @For_Date = CONVERT(varchar(10),getdate(),120)
			Set @New_In_Time = @For_Date
			Set @New_Out_Time = @For_Date
			
						
			Select @In_Time = Min(In_Time),@Out_Time = Max(Out_Time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date	
			
			--Modified by Nimesh 21 April, 2015			
			SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_Id, @Emp_ID,@For_Date);
						
			SELECT	@s_time = Shift_St_Time, @e_time = Shift_End_Time 
			FROM	dbo.T0040_Shift_Master WITH (NOLOCK)
			WHERE	Cmp_Id = @Cmp_Id and Shift_Id=@Shift_ID
			--Select @s_time = Shift_St_Time, @e_time = Shift_End_Time From dbo.T0040_Shift_Master Where Cmp_Id = @Cmp_Id and Shift_Id=(Select Shift_Id From dbo.T0100_Emp_shift_detail Where Emp_Id = @Emp_ID And Cmp_Id = @Cmp_Id And For_Date=(Select Max(For_date) From dbo.T0100_Emp_shift_detail where Emp_Id=@Emp_ID And Cmp_Id=@Cmp_Id)) 
			--End Nimesh 
			
	
			if @s_time > @e_time
				Begin
					set @New_Out_Time = dateadd(d,1,@New_Out_Time)
					Set @Is_Night_Shift = 1
				End		
			
			--If @In_Time is null and @Inout = 0
			If @Inout = 0
				Begin
					set @New_In_Time = convert(varchar(11),@New_In_Time,120)+ @s_time
					--exec SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID,@Cmp_Id,@New_In_Time,@IP_ADDRESS,0,@Is_Night_Shift
					INSERT INTO T9999_MOBILE_INOUT_DETAIL    
									(IO_Tran_Id, Emp_ID, Cmp_ID, IO_Datetime, IMEI_No, In_Out_Flag, Latitude,Longitude
									,Location,Emp_Image,Reason,Approval_Status	
									,Approval_by,Approval_date,Approval_From_Mobile,Is_Verify,IsOffline	,Vertical_ID
									,SubVertical_ID	,ManagerComment	,R_Emp_ID) 
								VALUES
									(NULL,@Emp_ID,@Cmp_ID,@New_In_Time,'PAYROLL','I',null,null,NULL
									,@FileName,NULL, 0, 0,@For_Date,0,NULL,0,NULL,NULL,NULL,NULL)    

				End
				
			--If @Out_Time is null and @Inout = 1
			If @Inout = 1	
				Begin
					set @New_Out_Time = convert(varchar(11),@New_Out_Time,120)+ @e_time
					--exec SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID,@Cmp_Id,@New_Out_Time,@IP_ADDRESS,1,@Is_Night_Shift
					INSERT INTO T9999_MOBILE_INOUT_DETAIL    
							(IO_Tran_Id, Emp_ID, Cmp_ID, IO_Datetime, IMEI_No, In_Out_Flag, Latitude,Longitude
							,Location,Emp_Image,Reason,Approval_Status	
							,Approval_by,Approval_date,Approval_From_Mobile,Is_Verify,IsOffline	,Vertical_ID,SubVertical_ID
							,ManagerComment	,R_Emp_ID) 
							VALUES
							(NULL,@Emp_ID,@Cmp_ID,@New_Out_Time,'PAYROLL','O',null,null,NULL,@FileName,NULL, 0, 0
							,@For_Date,0,NULL,0,NULL,NULL,NULL,NULL)
				End
		End
	
END




