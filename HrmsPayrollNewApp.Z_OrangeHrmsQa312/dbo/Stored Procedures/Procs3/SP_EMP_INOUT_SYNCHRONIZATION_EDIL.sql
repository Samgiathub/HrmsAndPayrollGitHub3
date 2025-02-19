


---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_EDIL]
	-- Add the parameters for the stored procedure here
	@CMP_ID NUMERIC
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	exec SP_EMP_INOUT_SYNCHRONIZATION_AUTO @CMP_ID
	
	Return
end
	
	/* Modify jignesh 18-Apr-2017----------------
	
	
	Declare @IO_Tran_ID_Device As Numeric 	
	Declare @Enroll_No As Numeric
	Declare @IO_DateTime As DateTime
	Declare @IP_Address As Varchar
	Declare @In_Out_Flag As Char
	Declare @IO_Tran_ID numeric(18,0)    
	Declare @Emp_Id As Numeric(18,0)
	Declare @For_Date Datetime
	Declare @In_Time Datetime 
	Declare @Out_Time Datetime
    
    Declare @Max_For_Date DAtetime
    --set @Emp_Id = 3
    --set @Enroll_No = 50627    
    Declare Emp_Cur Cursor For
    Select Emp_Id,Enroll_no from T0080_Emp_MAster where cmp_id = @cmp_id and enroll_no > 0 order by enroll_no
    Open Emp_Cur
    Fetch Next from Emp_Cur into @Emp_Id,@Enroll_No
    While @@FETCH_STATUS = 0
    begin
		
		select @Max_For_Date = MAX(For_Date) from T0150_EMP_INOUT_RECORD where Emp_ID = @Emp_Id 
		
		--if @Enroll_No is null
		--	set @Enroll_No = 0
		
		--if @Enroll_No = 0 
		--	begin
		--		Fetch Next from Emp_Cur into @Emp_Id,@Enroll_No	
		--		continue
		--	end
			
		DEclare Enroll_Cur Cursor For
		Select IO_DATETIME,IP_Address,In_Out_Flag from T9999_DEVICE_INOUT_DETAIL where Enroll_No = @Enroll_No and cmp_id = @cmp_id 
		and IO_DATEtime > isnull(@MAx_for_DATE,'01-01-1900')  order by enroll_no,io_tran_id,IO_Datetime
		Open Enroll_Cur
		Fetch Next from Enroll_Cur into @IO_DateTime,@IP_Address,@In_Out_Flag
		While @@FETCH_STATUS = 0
		begin
				set @For_Date = cast(@IO_DATETIME as varchar(11)) 
				
				select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record
				If @In_Out_Flag = 'I'    
				Begin 
					if Exists(select IO_Tran_ID from t0150_emp_inout_record where Emp_Id=@Emp_Id And In_time = @IO_DATETIME)
					Begin--changed by Falak on 24-MAY-2011
						Fetch next from Enroll_cur into @IO_Datetime,@IP_Address,@In_Out_Flag		
						continue;
					End   
					If Exists (select Max(out_time) From dbo.T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID And Out_time > @Io_Datetime And For_Date=@For_Date)
					Begin    
					Select @out_time=Max(out_time) From dbo.T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID And Out_time > @Io_Datetime and For_Date=@For_Date 
					If @out_time is null    
							Begin
							 
							 INSERT INTO dbo.T0150_EMP_INOUT_RECORD    
									(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App)    
							 VALUES (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','','',null,null, 0, 0)    
							End    
					Else    
						Begin    
						  select @In_time=In_time from dbo.T0150_EMP_INOUT_RECORD where Emp_ID=@Emp_ID and Out_Time=@out_time 
								if @In_time is null  
										 Begin  
										  Update dbo.T0150_EMP_INOUT_RECORD    
										  set  in_Time = @Io_Datetime 
										  where Emp_ID =@Emp_ID And Out_time=@out_time 
										 End  
								Else  
									 Begin  
										   INSERT INTO dbo.T0150_EMP_INOUT_RECORD    
												(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App)    
										 VALUES (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','','',null,null, 0,0)    
									End   
						End     
					End    
				End    
				else if @In_Out_Flag = 'O'    
				Begin    
					 if Exists(select IO_Tran_ID from t0150_emp_inout_record where Emp_Id=@Emp_Id And Out_Time=@IO_DATETIME )
					  Begin --changed by Falak on 24-MAY-2011
						Fetch next from Enroll_cur into @IO_Datetime,@IP_Address,@In_Out_Flag		
						continue;
					  End 
					 If Exists (Select Max(In_time) From dbo.T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID And In_time <  @Io_Datetime And For_Date=@For_Date)--And Out_Time is null )    
					 Begin    
						Select @In_Time=Max(In_time) From dbo.T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And In_time <  @Io_Datetime And For_Date=@For_Date-- And Out_Time is null )  
						If @In_Time is null    
						Begin    
							 INSERT INTO dbo.T0150_EMP_INOUT_RECORD
									(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App)    
							 VALUES (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@Io_Datetime,'','','',null,null, 0, 0)    
						End    
						Else
						Begin
							Select @Out_Time=Out_Time from dbo.T0150_EMP_INOUT_RECORD where Emp_ID=@Emp_ID and In_Time=In_Time 
							If @Out_Time is null  
								Begin  
								  Update dbo.T0150_EMP_INOUT_RECORD    
								  Set  Out_Time = @Io_Datetime
								  where Emp_ID =@Emp_ID And In_Time = @In_Time 
								 End  
							Else					
								Begin    
									  INSERT INTO dbo.T0150_EMP_INOUT_RECORD    
											  (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App)
									  VALUES  (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@Io_Datetime,'','','',null,null, 0, 0)
								End    						                  							   
						 End 
					 End   
					END
					
				 Update dbo.T0150_EMP_INOUT_RECORD     
				 Set  Duration = dbo.F_Return_Hours (datediff(s,In_time,Out_Time))      
				 Where Emp_ID =@Emp_ID  and not in_time  is null and not out_Time is null						           									
				
				Fetch next from Enroll_cur into @IO_Datetime,@IP_Address,@In_Out_Flag
			End
			close Enroll_cur
			deallocate Enroll_cur
		
		Fetch Next from Emp_Cur into @Emp_Id,@Enroll_No	
    End
    CLOSE Emp_cur
    deallocate Emp_cur
	
END

*/




