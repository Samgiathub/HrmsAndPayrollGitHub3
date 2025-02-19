




CREATE PROCEDURE [DBO].[SP_EMP_INOUT_SYNCHRONIZATION_OLD]    
 @EMP_ID NUMERIC ,    
 @CMP_ID NUMERIC ,    
 @IO_DATETIME DATETIME ,    
 @IP_ADDRESS VARCHAR(50)    
AS    
 SET NOCOUNT ON     
     
 Declare @In_Time Datetime     
 Declare @Out_Time Datetime     
 Declare @For_Date Datetime     
 Declare @varFor_Date varchar(22)     
 Declare @F_In_Time datetime     
 Declare @F_Out_Time Datetime     
 Declare @S_In_Time datetime     
 Declare @S_Out_Time Datetime     
 Declare @T_In_Time datetime     
 Declare @T_Out_Time Datetime     
    
    
 Declare @Shift_st_Time  Datetime     
 Declare @Shift_End_Time  datetime     
 Declare @F_Shift_In_Time Datetime     
 Declare @F_Shift_End_Time datetime     
 Declare @S_Shift_in_Time datetime     
 Declare @S_shift_end_Time datetime     
 Declare @T_Shift_In_Time datetime     
 Declare @T_Shift_End_Time datetime     
 declare @IO_Tran_ID   numeric     
 set @For_Date = cast(@IO_DATETIME as varchar(11))    
 set @varFor_Date = cast(@IO_DATETIME as varchar(11))    
     
 select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID     
 
 Declare @InOut_duration_Gap numeric    --Added by Mihir 06/03/2012
 select @InOut_duration_Gap = ISNULL(Inout_Duration,300) from T0010_COMPANY_MASTER where Cmp_Id = @CMP_ID   --Added by Mihir 06/03/2012
				
	
	    
 if Exists(select IO_Tran_ID from t0150_emp_inout_record where In_time = @IO_DATETIME OR Out_Time=@IO_DATETIME And Emp_Id=@Emp_Id)
		Begin
			Return
		End  
 if not @In_time is null and @In_Time > isnull(@Out_Time,'01-01-1900') and datediff(s,@In_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@In_Time,@IO_DATETIME) >0    
  begin    
   Update T0150_emp_inout_Record     
   set  In_Time = @IO_DATETIME    
     ,Duration = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,Out_Time))      
   where In_Time = @In_Time and Emp_ID=@emp_ID    
   return     
  end    
 else if not @Out_Time is null and @Out_Time > @In_Time and datediff(s,@Out_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@Out_Time,@IO_DATETIME) >0    
  begin    
   Update T0150_emp_inout_Record     
   set  Out_Time = @IO_DATETIME    
     ,Duration = dbo.F_Return_Hours (datediff(s,In_Time,@IO_DATETIME))      
   where Out_Time = @Out_Time and Emp_ID=@emp_ID    
   return     
  end    
      
  exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date,null,@F_Shift_In_Time output ,@F_Shift_End_Time output,@S_Shift_in_Time output ,@S_shift_end_Time output,@T_Shift_In_Time output ,@T_Shift_End_Time output , @Shift_st_Time output ,@Shift_end_Time output
  
     
  if @S_Shift_in_Time ='1900-01-01 00:00:00.000'    
   set @S_Shift_in_Time = null    
  if @S_Shift_End_Time ='1900-01-01 00:00:00.000'    
   set @S_Shift_End_Time = null    
      
  if @T_Shift_In_Time ='1900-01-01 00:00:00.000'    
   set @T_Shift_In_Time = null    
    
  if @T_Shift_End_Time ='1900-01-01 00:00:00.000'    
   set @T_Shift_End_Time = null    
          
  set @F_Shift_In_Time =  @varFor_Date + ' ' + @F_Shift_In_Time    
  set @F_Shift_End_Time = @varFor_Date + ' ' + @F_Shift_End_Time    
  set @S_Shift_in_Time = @varFor_Date + ' ' + @S_Shift_in_Time    
  set @S_shift_end_Time = @varFor_Date + ' ' + @S_shift_end_Time    
  set @T_Shift_In_Time = @varFor_Date + ' ' + @T_Shift_In_Time     
  set @T_Shift_End_Time = @varFor_Date + ' ' + @T_Shift_End_Time    
  set @Shift_end_Time = @varFor_Date + ' ' + @Shift_end_Time    
  set @Shift_st_Time = @varFor_Date + ' ' + @Shift_st_Time    
      
  select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record    
      
  if not exists(select emp_ID from T0150_emp_inout_Record Where For_Date =@For_Date and emp_Id=@emp_ID )    
   begin   
   	if @Io_Datetime <@F_Shift_End_Time and datediff(s,@Io_Datetime,@F_Shift_End_Time) <3600 or ( datediff(s,@Io_Datetime,@F_Shift_End_Time) <0 and datediff(s,@Io_Datetime,@F_Shift_End_Time)>-3600)    
     begin    
      INSERT INTO T0150_EMP_INOUT_RECORD    
             (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
             Late_Calc_Not_App)    
      VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','',@Ip_Address,null,null, 0, 0)    
     end    
    else if @Io_Datetime < @F_Shift_End_Time     
     begin    
      INSERT INTO T0150_EMP_INOUT_RECORD    
             (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,              Late_Calc_Not_App)    
      VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','',@Ip_Address,null,null, 0, 0)    
     end    
    else if @Io_Datetime <@S_Shift_End_Time and  datediff(s,@Io_Datetime,@S_Shift_End_Time) <3600 or ( datediff(s,@Io_Datetime,@S_Shift_End_Time) <0 and datediff(s,@Io_Datetime,@S_Shift_End_Time)>-3600)    
     begin    
      INSERT INTO T0150_EMP_INOUT_RECORD    
             (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
             Late_Calc_Not_App)    
      VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@Io_Datetime,'','',@Ip_Address,null,null, 0, 0)    
     end    
    else if @Io_Datetime < @S_Shift_End_Time     
     begin    
      INSERT INTO T0150_EMP_INOUT_RECORD    
             (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
             Late_Calc_Not_App)    
      VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','',@Ip_Address,null,null, 0, 0)    
     end     
         
        
   end    
     
   else if @S_Shift_In_time is null   
        
      begin    
   select @In_Time = In_time from T0150_emp_inout_Record Where For_Date =@For_Date and emp_Id=@emp_ID and Out_time is null and In_time < @Io_Datetime    
        
    Update T0150_EMP_INOUT_RECORD    
     set  Out_Time = @Io_Datetime    
     where Emp_ID =@Emp_ID and for_Date = @for_Date and In_Time  = @In_Time     
  End   
         
     
  else if not @S_Shift_in_Time is null and @Io_Datetime < @S_Shift_in_Time  and exists( select emp_ID from T0150_emp_inout_Record Where For_Date =@For_Date and emp_Id=@emp_ID and Out_time is null and In_Time < @Io_Datetime)    
   begin    
    select @In_Time = In_time from T0150_emp_inout_Record Where For_Date =@For_Date and emp_Id=@emp_ID and Out_time is null and In_time < @Io_Datetime    
        
    Update T0150_EMP_INOUT_RECORD    
    set  Out_Time = @Io_Datetime    
    where Emp_ID =@Emp_ID and for_Date = @for_Date and In_Time  = @In_Time    
   end    
  else if not @S_Shift_in_Time is null and @Io_Datetime < @S_Shift_in_Time  and @Out_Time > @In_Time     
   begin    
     INSERT INTO T0150_EMP_INOUT_RECORD    
            (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
            Late_Calc_Not_App)    
     VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','',@Ip_Address,null,null, 0, 0)    
        
   end    
  else if not @S_Shift_in_Time is null     
   begin    
    if @Io_Datetime <@S_Shift_End_Time and datediff(s,@Io_Datetime,@S_Shift_End_Time) <3600 or ( datediff(s,@Io_Datetime,@S_Shift_End_Time) <0 and datediff(s,@Io_Datetime,@S_Shift_End_Time)>-3600)    
     begin    
      INSERT INTO T0150_EMP_INOUT_RECORD    
             (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
             Late_Calc_Not_App)    
      VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@Io_Datetime,'','',@Ip_Address,null,null, 0, 0)    
     end    
    else if @In_Time > @S_Shift_in_Time and  @Io_Datetime < @S_Shift_End_Time and exists(select Emp_ID from T0150_EMP_INOUT_RECORD Where emp_ID=@Emp_ID and for_Date =@For_Date and Out_Time is null and In_Time =@In_Time )    
     begin    
          
      Update T0150_EMP_INOUT_RECORD    
      set Out_Time =@Io_Datetime    
      where Emp_ID=@Emp_ID and For_Date =@For_Date and In_Time =@In_time    
     end    
    else if @Io_Datetime < @S_Shift_End_Time     
     begin    
          
      INSERT INTO T0150_EMP_INOUT_RECORD    
             (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
             Late_Calc_Not_App)    
      VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','',@Ip_Address,null,null, 0, 0)    
     end    
    else if @Io_Datetime > @S_Shift_End_Time and @In_Time >@Out_Time and exists(select Emp_ID from T0150_EMP_INOUT_RECORD where Emp_Id=@emp_ID and For_Date=@for_Date and In_time =@In_Time and out_Time is null)    
     begin    
      Update T0150_EMP_INOUT_RECORD    
      set Out_Time =@Io_Datetime    
      where Emp_ID=@Emp_ID and For_Date =@For_Date and In_Time =@In_time    
     end     
    else    
     begin    
      INSERT INTO T0150_EMP_INOUT_RECORD    
             (IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count,     
             Late_Calc_Not_App)    
      VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@Io_Datetime,null,'','',@Ip_Address,null,null, 0, 0)    
     end      
         
   end    
     
   Update T0150_emp_inout_Record     
   set  Duration = dbo.F_Return_Hours (datediff(s,In_time,Out_Time))      
   where Emp_ID =@Emp_ID and For_Date =@For_Date and not in_time  is null and not out_Time is null    
     
 RETURN    
    
    
    

