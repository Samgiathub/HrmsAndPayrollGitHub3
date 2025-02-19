
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG]    
 @EMP_ID NUMERIC ,    
 @CMP_ID NUMERIC ,    
 @IO_DATETIME DATETIME ,    
 @IP_ADDRESS VARCHAR(50),  
 @Verify_Mode numeric(18,0) ,
 @Is_Night_Shift Numeric 
   
AS    
 	SET NOCOUNT ON;     -- Added by rohit for process lock on 19102016
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT OFF;  
	SET ANSI_WARNINGS OFF;   

if isnull(@Verify_Mode,0)=0 
	set @Verify_Mode = 0


     
 Declare @Inout_Type varchar(5)    
 Declare @Master_Slave varchar(5)   
     
 Declare @For_Date Datetime     
 Declare @varFor_Date varchar(22)     
     
 Declare @In_Time Datetime     
 Declare @Out_Time Datetime     
 Declare @IO_Tran_ID numeric(18,0)    
     
 set @For_Date = cast(@IO_DATETIME as varchar(11))    
 set @varFor_Date = cast(@IO_DATETIME as varchar(11))    
     
 --select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID     
 
	declare @Shift_St_Sec as numeric       
	declare @Shift_En_sec as numeric    
	declare @Shift_St_Time as varchar(10)      
	declare @Shift_End_Time as varchar(10)         
	Declare @Shift_Id_N as numeric
	Declare @Shift_End_DateTime as datetime      
	Declare @Shift_ST_DateTime as datetime			
	Declare @Temp_Month_Date as datetime
	Declare @Temp_Date as datetime
 
	Declare @InOut_duration_Gap numeric    --Added by Mihir 06/03/2012
	select @InOut_duration_Gap = ISNULL(Inout_Duration,300) from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID   --Added by Mihir 06/03/2012
     
	--If Multiple punch has been received withing a minim gap between two punch then it should not be considered 
	if Exists(select IO_Tran_ID from t0150_emp_inout_record WITH (NOLOCK)
			where ((In_time = @IO_DATETIME AND @Verify_Mode = 0) OR (Out_Time=@IO_DATETIME AND @Verify_Mode = 1)) And Emp_Id=@Emp_Id )    
		Return  
   
      
    select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record WITH (NOLOCK)
     
	Exec SP_CURR_T0100_EMP_SHIFT_GET @EMP_ID,@Cmp_ID,@varFor_Date,@Shift_St_Time output,@Shift_End_Time output,Null,null,null,null,null,@Shift_Id_N output      
        
	set @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)      
	set @Shift_En_Sec = dbo.F_Return_Sec(@Shift_End_Time)      

	if @Shift_St_Sec > @Shift_En_Sec       
		set @Is_Night_Shift = 1
	else      
		set @Is_Night_Shift = 0

   if  exists(select IP_Address from T0040_IP_MASTER WITH (NOLOCK) where IP_Address=@IP_Address and (Device_No > 200 or Is_Canteen=1))
		begin
			 return
		end --Added by Sumit on 25012017 For Canteen Punch should not Inserting in In Out Table
   
  Begin  
	
	
	
	if @Verify_Mode = 0   
		Begin    
			-- Comment by Prakash Patel on 17-Dec-2015
			--If @Is_Night_Shift = 1  --- @Is_Night_Shift = 0 THEN NOT SAVE IN T0150_EMP_INOUT_RECORD 
			--	BEGIN	
				
				 
				select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And In_time <  @Io_Datetime 

				if isnull(datediff(s,@In_Time,@IO_DATETIME),0) > @InOut_duration_Gap or @In_Time is null						  
					BEGIN
					 /*Added StatusFlag By Deepali07102021 for Mobile inout entry*/

						INSERT INTO T0150_EMP_INOUT_RECORD    
							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, 
								In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App, StatusFlag)    
						VALUES
							(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','','',null,null, 0, 0,'M')    
				END
				
			--	END
		End    
	else if @Verify_Mode = 1    
		Begin    
			
			Declare @Last_Out_Time as datetime --Hardik 25/02/2016
			if Exists (select 1  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID And In_time <  @Io_Datetime and  For_Date= @For_Date   )--And Out_Time is null )    
				Begin   
					
					--Hardik 25/02/2016
					Select @Last_Out_Time =Out_Time  from T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)
					where emp_ID=@emp_ID  
					And EIO.In_Time = (Select Max(In_Time) From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_Id =@Emp_Id And For_Date <= @Io_Datetime)

				
					If @Is_Night_Shift = 1 or @Last_Out_Time is null
						begin
							select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And In_time <  @Io_Datetime -- and  For_Date=@For_Date-- And Out_Time is null )  
						end
					Else
						begin
							select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And For_Date =  @For_Date -- and  For_Date=@For_Date-- And Out_Time is null )  
						end

					
					if @In_Time is null    
						Begin    
						 /*Added StatusFlag By Deepali07102021 for Mobile inout entry*/

						
							INSERT INTO T0150_EMP_INOUT_RECORD    
							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, 
								In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App,StatusFlag)    
							VALUES 
							(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@Io_Datetime,'','','',null,null, 0, 0,'M')    
						End    
					else    
						select @Out_Time=Out_Time from t0150_Emp_Inout_record WITH (NOLOCK) where Emp_ID=@Emp_ID and In_Time=@In_Time
						

						if @Out_Time is null and isnull(datediff(s,@Out_Time,@IO_DATETIME),0) < @InOut_duration_Gap and isnull(datediff(HH,@Out_Time,@IO_DATETIME),0) < 20
							Begin  
							
								Update T0150_EMP_INOUT_RECORD    
								set  Out_Time = @Io_Datetime
								where Emp_ID =@Emp_ID  and In_Time  = @In_Time--and ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))  
							End  
						else if not @Out_Time is null and isnull(datediff(s,@Out_Time,@IO_DATETIME),0) < @InOut_duration_Gap
							Begin  
								
								Update T0150_EMP_INOUT_RECORD    
								set  Out_Time = @Io_Datetime
								where Emp_ID =@Emp_ID  and In_Time  = @In_Time--and ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))  
							End 
						else  
							Begin    
							 /*Added StatusFlag By Deepali07102021 for Mobile inout entry*/

								INSERT INTO T0150_EMP_INOUT_RECORD    
								(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason,
									Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App,StatusFlag)    
								VALUES
								 (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@Io_Datetime,'','','',null,null, 0, 0,'M')    
							End    
					End   
			Else
				Begin   
				
					--Hardik 25/02/2016
						Select @Last_Out_Time =Out_Time  from T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)
						where emp_ID=@emp_ID  And EIO.In_Time = (Select Max(In_Time) From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_Id =@Emp_Id And For_Date <= @Io_Datetime)

				
						If @Is_Night_Shift = 1 or @Last_Out_Time is null
							select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And In_time <=  @Io_Datetime and For_Date =  dateadd(day,-1,@For_Date)
						Else
							select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And For_Date =  @For_Date 
						
							
						if Day(@In_Time) <> Day(@IO_DateTime) AND @Is_Night_Shift = 0 AND DATEDIFF(HH,@In_Time,@IO_DATETIME) > 14 -- Changed from 10 to 14 for PSB Loan Case by Hardik 25/08/2020
							select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And For_Date =  @For_Date 
												
						select @Out_Time=Out_Time from t0150_Emp_Inout_record WITH (NOLOCK) where Emp_ID=@Emp_ID and In_Time=@In_Time

						If not @In_Time Is null And DATEDIFF(HH,@In_Time,@IO_DATETIME) < 26 and isnull(datediff(s,@Out_Time,@IO_DATETIME),0) < @InOut_duration_Gap
							Begin  
								Update T0150_EMP_INOUT_RECORD    
								set  Out_Time = @Io_Datetime
								where Emp_ID =@Emp_ID  and In_Time  = @In_Time--and ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))  
							End  
						else  
							Begin 
							 /*Added StatusFlag By Deepali07102021 for Mobile inout entry*/

								INSERT INTO T0150_EMP_INOUT_RECORD    
								(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason,
									Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,Late_Calc_Not_App,StatusFlag)    
								VALUES
								 (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@Io_Datetime,'','','',null,null, 0, 0,'M')    
							End    
					End   
		End    
      /*if Exists (select Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null  And In_time <  @Io_Datetime and isnull(Master_Slave,0)=1 And (For_Date=@For_Date  OR (For_Date=dateadd(d,-1,@For_Date))))  
       Begin     
       select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null And In_time <  @Io_Datetime  and isnull(Master_Slave,0)=1 and (For_Date=@For_Date OR (For_Date=dateadd(d,-1,@For_Date)))  
       if @In_Time is not null  
        Begin  
        Update T0150_EMP_INOUT_RECORD    
           set  Out_Time = @Io_Datetime ,Out_IP_Address=@Ip_Address   
           where Emp_ID =@Emp_ID  and In_Time  = @In_Time and isnull(Master_Slave,0)=1 and ((For_Date=@For_Date) OR (For_Date=dateadd(d,-1,@For_Date)))     
        End  
       else  
        Begin  
        INSERT INTO T0150_EMP_INOUT_RECORD    
          (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
          Late_Calc_Not_App,Master_Slave,In_IP_Address,Out_IP_Address)    
         VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','','',null,null, 0, 0,1,@Ip_Address,'')      
        End   
       End  */  
       
		Update T0150_EMP_INOUT_RECORD Set In_Time = NULL
		Where In_Time = '1900-01-01 00:00:00.000' and Emp_ID =@Emp_ID
		
        Update T0150_EMP_INOUT_RECORD Set  Out_Time = NULL
		Where Out_Time = '1900-01-01 00:00:00.000' and Emp_ID =@Emp_ID
        
         Update T0150_emp_inout_Record     
         set  Duration = dbo.F_Return_Hours (datediff(s,In_time,Out_Time))      
         where Emp_ID =@Emp_ID and  in_time  is not null and  out_Time is not null  --and ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))  
		 And Duration <> dbo.F_Return_Hours (datediff(s,In_time,Out_Time)) -- Added by Hardik 17/09/2020 for chiripal as Update Trigger giving error
  End   
   
     
     
   
 RETURN    
    
  
  
  
  





