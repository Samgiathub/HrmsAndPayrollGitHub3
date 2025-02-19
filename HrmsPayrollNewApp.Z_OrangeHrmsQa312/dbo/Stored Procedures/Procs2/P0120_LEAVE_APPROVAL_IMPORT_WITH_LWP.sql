



---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_LEAVE_APPROVAL_IMPORT_WITH_LWP]
    @CMP_ID numeric(18,0)
   ,@EMP_CODE numeric(18,0)
   ,@Leave_Name varchar(50)    
   ,@From_Date datetime
   ,@Leave_Period numeric(18,1) 
   ,@LEave_Assign varchar(15)  
   ,@APPROVAL_COMMENTS varchar(250)
   ,@LOGIN_ID numeric(18,0)   
   ,@Is_Import int
   ,@TRAN_TYPE as varchar(1)
   ,@Row_No int = 0
   ,@Log_Status Int = 0 Output
   ,@CancelWOHO tinyint = 0
   ,@AllowLWP	tinyint = 0
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
    

If @AllowLWP = 1
	Begin  
	  DECLARE @LEAVE_APPLICATION_ID AS NUMERIC(18,0)
	  DECLARE @LEAVE_APPROVAL_ID AS NUMERIC(18,0)
	  DECLARE @S_EMP_ID NUMERIC(18,0)
	  DECLARE @EMP_ID NUMERIC(18,0)
	  Declare @APPROVAL_STATUS char(1)
	  Declare @To_Date datetime
	  Declare @Leave_ID numeric(18,0)
	  Declare @Leave_negative_Allow tinyint
	  Declare @System_Date As DateTime
	  Declare @Leave_Balance numeric(18,2)
	  Declare @LWP_Leave_Name varchar(50)    

	  Set @System_Date=GetDate()  
	  SET @S_EMP_id =0
	  SET @LEAVE_APPROVAL_ID=0  
	  SET @APPROVAL_STATUS ='A'
	  
	   SET @LEAVE_APPLICATION_ID = NULL  
	 
	   
		Select @Leave_ID = isnull(Leave_ID,0),@Leave_negative_Allow = Leave_negative_Allow from T0040_Leave_Master WITH (NOLOCK) where cmp_id = @Cmp_ID and Leave_Name = @Leave_Name
		Select @EMP_ID= isnull(EMP_ID,0),@S_EMP_id = Emp_Superior FROM t0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_CODE=@EMP_CODE and cmp_id = @cmp_id
		Select @LWP_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where cmp_id = @Cmp_ID and Leave_Code='LWP' 
		
		Select @Leave_Balance = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)
		where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where for_date < @From_Date and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
		and Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id
		
		
			   
		 If @Leave_Id Is Null
			Set @Leave_Id = 0
			
		IF @EMP_ID is null
			Set @EMP_ID = 0
	    		
		If @Leave_Balance is null
			set @Leave_Balance = 0	
			
		If @Leave_Period is null
			set @Leave_Period = 0	
	    
	  
	  
		If @Leave_Balance - @Leave_Period <= 0 and @Leave_negative_Allow <> 1
			Begin
				declare @tmp numeric(18,2)
				declare @main numeric(18,2)
				declare @lwp numeric(18,2)
				
				if (@Leave_Balance % 1) > 0.5
					begin
						set @tmp = FLOOR(@Leave_Balance) + 0.5
					end
				else
					begin
						set @tmp = @Leave_Balance
					end	
					
				set @lwp = ABS(@tmp - @Leave_Period)
				set @main = @Leave_Period - @lwp				
								
				If @main > 0
					begin	
											
						exec [P0120_LEAVE_APPROVAL_IMPORT] @CMP_ID,@EMP_CODE,@Leave_Name,@From_Date,@main,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@Is_Import,@TRAN_TYPE,@Row_No,@Log_Status,@CancelWOHO
					end
					
				If @lwp > 0
					begin
						Declare @Tmp_Date datetime
						
						If @main > 0
							begin
								CREATE table #leave_detail(
									From_Date datetime,
									End_Date datetime,
									Period numeric(18,2),
									leave_Date nvarchar(max), 
									StrWeekoff_Date nvarchar(max), 
									StrHoliday_Date nvarchar(max)
								)
									
										
								insert into #leave_detail
								exec dbo.Calculate_Leave_End_Date @CMP_ID,@EMP_ID,@Leave_ID,@From_Date,@main,'E',@CancelWOHO
								
								select @Tmp_Date=dateadd(d,1,End_Date) from #leave_detail 
								
								Delete from #leave_detail
								
								insert into #leave_detail
								exec dbo.Calculate_Leave_End_Date @CMP_ID,@EMP_ID,@Leave_ID,@Tmp_Date,1,'E',@CancelWOHO
								
								select @Tmp_Date=End_Date from #leave_detail 
																
							end
						Else
							begin
								set @Tmp_Date = @From_Date
							end
						
						
						exec [P0120_LEAVE_APPROVAL_IMPORT] @CMP_ID,@EMP_CODE,@LWP_Leave_Name,@Tmp_Date,@lwp,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@Is_Import,@TRAN_TYPE,@Row_No,@Log_Status,@CancelWOHO
					end
			End
		Else
			Begin
				exec [P0120_LEAVE_APPROVAL_IMPORT] @CMP_ID,@EMP_CODE,@Leave_Name,@From_Date,@Leave_Period,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@Is_Import,@TRAN_TYPE,@Row_No,@Log_Status,@CancelWOHO
			End
	End
Else
	Begin
		exec [P0120_LEAVE_APPROVAL_IMPORT] @CMP_ID,@EMP_CODE,@Leave_Name,@From_Date,@Leave_Period,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@Is_Import,@TRAN_TYPE,@Row_No,@Log_Status,@CancelWOHO
	End  
 RETURN  
  
  
  

