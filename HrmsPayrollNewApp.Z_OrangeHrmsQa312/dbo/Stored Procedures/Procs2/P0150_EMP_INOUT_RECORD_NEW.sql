



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_EMP_INOUT_RECORD_NEW]
	  @IO_Tran_Id		numeric(18) output
     ,@Emp_ID			numeric(18)
     ,@Cmp_Id			numeric(18)  
     ,@For_Date			datetime
     ,@In_Time			Datetime
     ,@Out_Time			Datetime
     ,@Duration			varchar(10)
     ,@Reason			varchar(10)
     ,@Ip_Address		varchar(50)
	 ,@tran_type		char(1)
	 ,@Skip_Count		numeric = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Out_Time = ''
		SET @Out_Time  = NULL
	IF @Duration = ''
		SET @Duration = NULL
	IF @Reason = ''
		SET @Reason = NULL
	
	Declare @Pre_In_Time as datetime
	Declare @Pre_Out_Time as datetime
	Declare @Pre_Skip_Count as Numeric 
	set @Pre_Skip_Count = 0
	
	set @For_Date = cast(cast(@For_Date as varchar(11)) as smalldatetime)
		
		If @tran_type ='I' 
			begin
					If exists (Select IO_Tran_Id  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and For_Date=  @For_Date and In_Time >= @In_Time) 
					begin
						set @IO_Tran_Id=0
						return
					end
		
					Select @IO_Tran_Id= isnull(max(IO_Tran_Id),0) + 1  from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
					
					Insert Into T0150_EMP_INOUT_RECORD(IO_Tran_Id,Emp_ID,Cmp_ID,For_Date,In_Time,Out_Time,Duration,Reason,Ip_Address)
					values(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@In_Time,@Out_Time,dbo.F_Return_Hours(@Duration),@Reason,@Ip_Address)
					
			end
		else if @tran_type ='U' 
			begin
			
				select @Pre_In_Time  = Max(In_Time) From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID 
				select @Pre_Out_Time  = Max(Out_Time) From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID 
				
				Select @Pre_Skip_Count = Isnull(Skip_Count,0) From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and Out_Time = @Pre_Out_Time
				
				
				If Exists(Select In_Time From T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID = @Emp_ID and In_Time = @Pre_In_Time and Out_Time is null ) and Isnull(@Pre_In_Time ,'') <> '' 
					Begin
						If not Exists(Select In_Time From T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID = @Emp_ID and For_Date = @For_date and Isnull(Skip_Count,0)>=1)
							Begin
								set @Skip_Count = @Pre_Skip_Count + @Skip_Count		
							end
						
						Update T0150_EMP_INOUT_RECORD 
						Set  Out_Time = @Out_Time,
							 Duration = dbo.F_Return_Hours(@Duration),
							 Reason = @Reason ,
							 Skip_Count = @Skip_Count
						where Emp_ID= @Emp_ID  and In_Time = @Pre_In_Time 
						
					End
				else if Isnull(@Pre_In_Time ,'') <> '' 
					Begin
						set @IO_Tran_Id = -1
						Return 
					End
				else 
					Begin
						set @IO_Tran_Id = -2
						Return 
					End
			end	

	RETURN




