---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[UPDATE_EMP_INOUT_RECORD]   
  @IO_Tran_Id numeric(18)   
 ,@Emp_ID  numeric(18)      
    ,@Cmp_Id  numeric(18)  
    ,@Sup_Comment   varchar(100)  
    ,@Approved  varchar(1)   
    ,@Is_Cancel_Late_In tinyint  
    ,@Is_Cancel_Early_Out tinyint   
    ,@Half_Full_day_Manager varchar(20) = '' -- added by mitesh on 26/03/2012  
    ,@In_Date_Time DATETIME = NULL   
    ,@Out_Date_Time DATETIME = NULL   
AS  
BEGIN  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
 declare @Half_Full_day varchar(20)  
 declare @New_In_Time Datetime    
 declare @New_Out_Time Datetime    
 declare @In_Time Datetime        
 declare @Out_Time Datetime        
 declare @tempDt Datetime    
 declare @tempDt2 Datetime   
 declare @s_time varchar(10)  
 declare @e_time varchar(10)  
 declare @diff numeric(18,2)  
 declare @Max_IO_Tran_Id numeric(18)   
 declare @Is_Default_In tinyint  
 declare @Is_Default_Out tinyint  
   
 declare @hrs numeric(18,2)  
 declare @min numeric(18,0)  
 declare @tmpTotal numeric(18,2)  
   
 Declare @For_Date datetime  
 declare @diff_Sec numeric(18,2) --Alpesh 1-Aug-2012  
 declare @dt datetime --Alpesh 1-Aug-2012  
   
 -- Added by rohit on 15072013  
  declare @WeekDay varchar(10)  
 declare @HalfStartTime varchar(10)  
 declare @HalfEndTime varchar(10)  
 declare @HalfDuration varchar(10)  
 declare @HalfDayDate varchar(500)  
 declare @HalfMinDuration varchar(10)  
   
 Declare @Apr_Date Datetime --Ankit 22082014  
 Set  @Apr_Date = GETDATE()  
  
-- ended by rohit on 15072013  
-- set @Is_Cancel_Late_In = 1 --Added by rohit as per guidance by hasmukhbhai for tradebull case out time not update when only tick cancel late in on 24082013  
-- set @Is_Cancel_Early_Out = 1  --Added by rohit as per guidance by hasmukhbhai for tradebull case out time not update when only tick cancel late in on 24082013  
 set @Is_Default_In = 0   
 set @Is_Default_Out = 0  
    
 
	If ((SELECT count(1) FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
								T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN							  
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
								T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@For_Date))
								AND [MONTH] = MONTH(EOMONTH(@For_Date))
						WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @Emp_ID) > 0)
	BEGIN
		Raiserror('@@ Attendance Lock for this Period. @@',16,2)
		return -1								
	END

	Declare @forDate as Date = NULL
	SELECT @forDate = cast(For_Date as Date) FROM   T0150_EMP_INOUT_RECORD where IO_Tran_Id = @IO_Tran_Id and Emp_id = @Emp_ID and Cmp_Id = @Cmp_Id

	If ((SELECT count(1) FROM T0150_EMP_INOUT_RECORD E 
	inner join T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID 
	WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @Emp_ID and IO_Tran_Id = @IO_Tran_Id and @forDate between From_Date and To_Date) > 0)
	BEGIN
		Raiserror('@@ Attendance Lock for this Period. @@',16,2)
		return -1								
	END


 
 Select @New_In_Time = For_Date, @New_Out_Time = For_Date, @For_Date=For_Date, @Half_Full_day = Half_Full_day, @In_Time = In_Time   
 from dbo.t0150_Emp_Inout_Record WITH (NOLOCK) where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id  


 ---added by mansi start 071021
  Select @In_Date_Time=In_Date_Time,@Out_Date_Time=Out_Date_Time
  from dbo.t0150_Emp_Inout_Record WITH (NOLOCK) where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id  

Select * Into  #TEMP_EMP_INOUT_RECORD From T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID=@Emp_ID and For_Date Between @New_In_Time -3 And @New_In_Time+3  


 
 --------- End ------  
  
    
 ---- Modify By Jignesh 27-Apr-2020---  
 --Select @Max_IO_Tran_Id = max(IO_Tran_Id) from T0150_EMP_INOUT_RECORD where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 --Emp_ID=@Emp_ID and For_Date=@New_In_Time  
   
 --Select @Out_Time=Out_Time from T0150_EMP_INOUT_RECORD where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 --Emp_ID=@Emp_ID and For_Date=@New_In_Time  
 --and IO_Tran_Id=@Max_IO_Tran_Id  
   
 Select @Max_IO_Tran_Id = max(IO_Tran_Id) from #TEMP_EMP_INOUT_RECORD where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 Emp_ID=@Emp_ID and For_Date=@New_In_Time  
 
 Select @Out_Time=Out_Time from #TEMP_EMP_INOUT_RECORD where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 Emp_ID=@Emp_ID and For_Date=@New_In_Time  
 and IO_Tran_Id=@Max_IO_Tran_Id  

 -------- End ----------  

    
 --Modified by Nimesh 21 May, 2015   
 DECLARE @Shift_ID numeric(18,0);  
   
  
 /*CODE FOR AUTOSHIFT*/   
 IF @IN_TIME IS NOT NULL  
  SET @Shift_ID = dbo.fn_get_AutoShiftID(@Emp_ID, @In_Time)  
 ELSE  
  SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_Id, @Emp_ID, @For_Date);  
   
   
 SELECT @s_time = SM.Shift_St_Time, @e_time = SM.Shift_End_Time   
   ,@WeekDay=isnull(SM.Week_Day,0),@HalfStartTime=isnull(SM.Half_St_Time,0),@HalfEndTime= isnull(SM.Half_End_Time,0),@HalfDuration=isnull(SM.Half_Dur,0),@HalfMinDuration=isnull(SM.Half_min_duration,0)  -- Added by rohit on 15072013  
 FROM dbo.T0040_Shift_Master as SM WITH (NOLOCK)  
 WHERE SM.Shift_ID=@Shift_ID --Cmp_Id = @Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013   
   
 /*Commented by Nimesh 22 April, 2015    
 Select @s_time = SM.Shift_St_Time, @e_time = SM.Shift_End_Time   
 ,@WeekDay=isnull(SM.Week_Day,0),@HalfStartTime=isnull(SM.Half_St_Time,0),@HalfEndTime= isnull(SM.Half_End_Time,0),@HalfDuration=isnull(SM.Half_Dur,0),@HalfMinDuration=isnull(SM.Half_min_duration,0)  -- Added by rohit on 15072013  
 From dbo.T0040_Shift_Master as SM Where --Cmp_Id = @Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013   
 Shift_Id=(Select Shift_Id From dbo.T0100_Emp_shift_detail Where Emp_Id = @Emp_ID --And Cmp_Id = @Cmp_Id  -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 And For_Date=(Select Max(For_date) From dbo.T0100_Emp_shift_detail where Emp_Id=@Emp_ID --And Cmp_Id=@Cmp_Id -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 AND For_Date <= @For_Date))   
 Comment Ended*/  
   
   
  
-- Added By rohit For Half Day Shift on 15072013  
 exec dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@For_Date,@For_Date,0,@HalfDayDate output    
   
 If @halfdayDate <> ''  
 begin   
   
 set @s_time = @HalfStartTime   
 set @e_time = @HalfEndTime  
   
 end  
 
   
 if Exists (Select Sal_Tran_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date <=@For_Date and isnull(Cutoff_Date,Month_End_Date) >=@For_Date and emp_id=@Emp_ID and isnull(is_Monthly_Salary,0)=1)  
 begin  
  Raiserror('@@This Months Salary Exists@@',16,2)  
  return -1  
 end  
 

 if @s_time > @e_time  
  Begin    
   set @New_Out_Time = dateadd(d,1,@New_Out_Time)  
   set @Out_Date_Time =  dateadd(d,1,@Out_Date_Time) --Added By Jimit 09082019 as per mantis bug 9223     
  End    
     
 set @tempDt = @New_In_Time  
 set @tempDt2 = @New_Out_Time  
 set @diff = DATEDIFF(hh,(convert(varchar(11),@tempDt,120)+@s_time),(convert(varchar(11),@tempDt2,120)+@e_time))  
 set @diff = @diff/2   
 set @hrs = @diff - @diff % 2  
 set @diff_Sec = (DATEDIFF(ss,(convert(varchar(11),@tempDt,120)+@s_time),(convert(varchar(11),@tempDt2,120)+@e_time)))/2 --Alpesh 1-Aug-2012  
   
 if @diff % 2 = 1  
  set @min = 0  
 else  
  set @min = (@diff % 2)*60  
      
 if @Half_Full_day_Manager = ''  
 begin  
  set @Half_Full_day_Manager = @Half_Full_day   
 end  
   


 if @Half_Full_day = 'Second Half'  
  begin  

   set @tmpTotal = convert(numeric(18,2),replace(@s_time,':','.')) + @diff  
   --select @tmpTotal,@diff,@min  
   if (@tmpTotal >= 24)  
    Begin  
     set @s_time=convert(varchar(5),convert(varchar,convert(int,@tmpTotal-24))+':'+convert(varchar(2),@min))       
     set @New_In_Time = dateadd(d,1,@New_In_Time)  
    End  
   else  
    Begin 

     --set @s_time = convert(varchar(10),convert(numeric(18,2),replace(@s_time,':','.')) + @diff)    
     --set @s_time = replace(@s_time,'.',':')  
       
     --Alpesh 1-Aug-2012  
     set @dt = convert(varchar(11),@For_Date,120)+ @s_time  
     -- Comment and Add by rohit on 13072013  
     --set @s_time = cast(SUBSTRING(convert(varchar,DATEADD(ss,@diff_sec,@dt)),13,5) as varchar)  
     set @s_time = cast((convert(varchar(5),DATEADD(ss,@diff_sec,@dt),108)) as varchar)  
     -- Ended by rohit on 13072013  
    End  
  end  

  
   
 if @In_Time is null and @In_Date_Time is null  
  begin  
   --------Chk to cancel Late In----------  
   --if @Is_Cancel_Late_In = 1   
   -- begin   
     
     ----**Below code Comment By Ankit For Night shift In and out Time problem After Discussion with hardikbhai --23012015  
       
     --if @s_time > @e_time  
     -- BEGIN  
     --  set @New_In_Time = dateadd(dd,-1,convert(varchar(11),@New_In_Time,120))+ @s_time  
   
     -- END        --else  
     -- set @New_In_Time = convert(varchar(11),@New_In_Time,120)+ @s_time  

     set @New_In_Time = convert(varchar(11),@New_In_Time,120)+ @s_time  
        
     set @Is_Default_In = 1  
       
     
     
   -- end  
   --else  
   -- begin  
   --  set @New_In_Time =  @In_Time  
   --  set @Is_Default_In = 0  
   -- end      
  end  
 else  
  begin  

     --print @In_Date_Time        ---mansi
   ---- modify by jignesh 17-Apr-2020  
   ----set @New_In_Time =  @In_Time  
   set @New_In_Time=IsNull(@In_Time,@In_Date_Time)  
  
   If @In_Time Is not null  
    set @Is_Default_In = 0  
   Else  
    set @Is_Default_In = 1  
  end  
    
 if @Half_Full_day = 'First Half'  
 begin   
  --set @e_time =  convert(varchar(10),convert(numeric(18,2),replace(@s_time,':','.')) + @diff)  
  --set @e_time = replace(@e_time,'.',':')  

  --Alpesh 1-Aug-2012  
  set @dt = convert(varchar(11),@For_Date,120)+ @s_time  
  -- Comment and Add by rohit on 13072013  
  --set @e_time = cast(SUBSTRING(convert(varchar,DATEADD(ss,@diff_sec,@dt)),13,5) as varchar)  
  set @e_time = cast((convert(varchar(5),DATEADD(ss,@diff_sec,@dt),108)) as varchar)  
  -- Ended by rohit on 13072013  
 end  
   
 if @Out_Time is null and @Out_Date_Time is null  
  begin   

   --------Chk to cancel Late In----------  
   --if @Is_Cancel_Early_Out = 1   
   -- begin    

     set @New_Out_Time = convert(varchar(11),@New_Out_Time,120)+ @e_time  
     set @Is_Default_Out = 1     
      
   -- end  
   --else  
   -- begin  
   --  set @New_Out_Time=@Out_Time  
   --  set @Is_Default_Out = 0  
   -- end  
  end  
 else  
  begin    
   set @New_Out_Time=IsNull(@Out_Time,@Out_Date_Time)  
  
   If @Out_Time Is not null  
    set @Is_Default_Out = 0  
   Else  
    set @Is_Default_Out = 1  
  end  
   
 If @Approved = 'A'   
  Begin    
  --select * from T0150_EMP_INOUT_RECORD Where IO_Tran_Id = @IO_Tran_Id And Cmp_Id=@Cmp_Id   

    
  DECLARE @Old_In_Time AS DATETIME  
  DECLARE @Old_Out_Time AS DATETIME  
    
  SELECT @Old_In_Time = In_Time  
    ,@Old_Out_Time = Out_Time FROM dbo.T0150_EMP_INOUT_RECORD AS teir WITH (NOLOCK)  
  WHERE IO_Tran_Id = @IO_Tran_ID  
	
  --select @New_Out_Time,@Old_In_Time,@Out_Date_Time  
  IF @In_Date_Time IS NOT NULL --and @In_Time is not null   --Added by Jaina 01-04-2017  -- Commented by Hardik 20/08/2019 as Chocolate room has query where In Time is null so giving error of Out time should greter than In Time  

	 UPDATE dbo.T0150_EMP_INOUT_RECORD   
	   SET In_Date_Time = Case WHEN @Half_Full_day = 'Full Day' Then @In_Date_Time Else @New_In_Time End   --change by Jaina 08-03-2017  
	 WHERE IO_Tran_Id = @IO_Tran_ID  

	 

	
  IF @Out_Date_Time IS NOT NULL --and @Out_Time is not null --Added by Jaina 01-04-2017 -- Commented by Hardik 20/08/2019 as Chocolate room has query where In Time is null so giving error of Out time should greter than In Time  

        
      	--UPDATE dbo.T0150_EMP_INOUT_RECORD   
     	--SET Out_Date_Time = Case WHEN @Half_Full_day = 'Full Day' 
     	--Then @Out_Date_Time Else @New_Out_Time End    --change by Jaina 08-03-2017  
   	--WHERE IO_Tran_Id = @IO_Tran_ID      	   
	 
	 UPDATE dbo.T0150_EMP_INOUT_RECORD   
     	 SET Out_Date_Time = Case WHEN @Half_Full_day = 'Full Day' Then @Out_Date_Time Else @New_Out_Time End    --change by Jaina 08-03-2017  
  	 WHERE IO_Tran_Id = @IO_Tran_ID  
       
  if @Old_In_Time is null and @Old_Out_Time is not null  -- Added by rohit for if both punch in outtime on 24062016  
  begin  
   if @Old_Out_Time < @New_In_Time  
   begin  
    set  @New_In_Time = dateadd(mi,-1,@Old_Out_Time)  
   end  
  end  


    
  Update dbo.T0150_EMP_INOUT_RECORD set    
    In_Time = @New_In_Time  
   ,Sup_Comment = @Sup_Comment  
  -- ,Chk_By_Superior = 1  
   ,Is_Cancel_Late_In = @Is_Cancel_Late_In  
   ,Is_Default_In = @Is_Default_In   
   ,Half_Full_day = @Half_Full_day_Manager  
   ,Duration = dbo.F_Return_Hours (datediff(s,@New_In_Time,Out_Time))     
   ,Apr_Date = @Apr_Date         
  Where IO_Tran_Id = @IO_Tran_Id --And Cmp_Id=@Cmp_Id -- Comment By rohit For Attendance regularization Approved for different Company on 2462013   
  
  

  --IF @Is_Cancel_Late_In = 0 --commented by Mukti(09092016)after discussion with Hardikbhai to get Attendance regularization record  
  BEGIN  
   DECLARE @New_In_Time_Temp AS DATETIME   
     
   SET @New_In_Time_Temp = @New_In_Time  
    
   --SELECT @New_In_Time = In_Date_Time  
   --FROM dbo.T0150_EMP_INOUT_RECORD AS teir   
   --WHERE IO_Tran_Id = @IO_Tran_ID  
     
   IF @New_In_Time IS NOT NULL   
    BEGIN   
      
     Update dbo.T0150_EMP_INOUT_RECORD set    
       --In_Time = ISNULL(In_Date_Time,@New_In_Time)  
       In_Time = @New_In_Time  
       ,Duration = dbo.F_Return_Hours (datediff(s,@New_In_Time,Out_Time))            
     Where IO_Tran_Id = @IO_Tran_ID  
  
     Update dbo.T0150_EMP_INOUT_RECORD set    
       In_Date_Time =  isnull(@Old_In_Time,@New_In_Time)   --Change by Jaina 09-03-2017  
     Where IO_Tran_Id = @IO_Tran_Id   
    END   
   SET @New_In_Time = @New_In_Time_Temp   
  END  
  
  
  

   
  declare @Max_In_Time datetime  
  Select @Max_In_Time = In_Time from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where IO_Tran_Id=@Max_IO_Tran_Id  
   


  if @Max_In_Time >= @New_Out_Time  
   set @New_Out_Time = dateadd(minute,1,@Max_In_Time)     

    --Select @Max_IO_Tran_Id,@Max_In_Time ,@New_Out_Time
	--
    --
	--select Out_Time,* from T0150_EMP_INOUT_RECORD  Where Out_Time = @New_Out_Time
	--
	--select Out_Time,* from T0150_EMP_INOUT_RECORD  Where IO_Tran_Id = @Max_IO_Tran_Id

  Update dbo.T0150_EMP_INOUT_RECORD set    
    --Out_Time = ISNULL(Out_Date_Time, @New_Out_Time)  
    Out_Time = @New_Out_Time
	,
	Is_Cancel_Early_Out = @Is_Cancel_Early_Out  
    ,Is_Default_Out = @Is_Default_Out  
    --,Chk_By_Superior = 1  
    ,Half_Full_day = @Half_Full_day_Manager  
    ,Duration = dbo.F_Return_Hours (datediff(s,In_Time,@New_Out_Time))     
    ,Apr_Date = @Apr_Date     
  Where IO_Tran_Id = @Max_IO_Tran_Id --And Cmp_Id=@Cmp_Id -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
 
-- return

  --Commented by Hardik 01/07/2015 as giving error in Night Shift Employee, who's in-out is blank  
  /*Commented Again by Nimesh on 27-Jan-2017 (Shift [24/01/2017]: 23:30 To 07:30 and Regularize for 25-01-2017 || In Time: 24-01-2017 11:30 To 25-01-2017 07:30 && 25-01-2017 No Punch)   
  --IF @Is_Cancel_Late_In = 0 --commented by Mukti(09092016) after discussion with Hardikbhai to get Attendance regularization record  
   BEGIN  
    DECLARE @New_Out_Time_Temp AS DATETIME   
      
    SET @New_Out_Time_Temp = @New_Out_Time  
     
    SELECT @New_Out_Time = Out_Date_Time  
    FROM dbo.T0150_EMP_INOUT_RECORD AS teir   
    WHERE IO_Tran_Id = @IO_Tran_ID  
      
    IF @New_Out_Time IS NOT NULL   
     BEGIN   
      Update dbo.T0150_EMP_INOUT_RECORD set    
        Out_Time = ISNULL(Out_Date_Time,@New_Out_Time)  
        ,Duration = dbo.F_Return_Hours (datediff(s,@New_In_Time,Out_Time))            
      Where IO_Tran_Id = @IO_Tran_ID  
  
      Update dbo.T0150_EMP_INOUT_RECORD set    
        Out_Date_Time = @Old_Out_Time  
        ,Duration = dbo.F_Return_Hours(datediff(s,In_Time,Out_Time))            
      Where IO_Tran_Id = @IO_Tran_Id   
     END   
    SET @New_Out_Time = @New_Out_Time_Temp   
   END  
     
  */  
  --Update dbo.T0150_EMP_INOUT_RECORD set    
  -- Chk_By_Superior = 1  
  --Where IO_Tran_Id = @IO_Tran_Id And Cmp_Id=@Cmp_Id   
  
  
  

	--Put for making all Chk_By_Superior=1 for same date. so it shows proper entry in Attedance_reg admin side.  
	Update dbo.T0150_EMP_INOUT_RECORD set    
	 Chk_By_Superior = 1  
	 , Half_Full_day = @Half_Full_day_Manager  
	Where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
	Emp_ID=@Emp_ID and For_Date=@For_Date   

  
  

  if @Sup_Comment = 'Approved from API' -- added by Niraj(06062022)
  Begin
	Select 'Attendance Detail For Selected Employee is Updated.' as Result
  END
 End  
 Else If @Approved = 'R'   
 Begin   
   
  Update dbo.T0150_EMP_INOUT_RECORD set   
   Sup_Comment = @Sup_Comment  
   ,Chk_By_Superior = 2   
   ,Apr_Date = @Apr_Date   
  Where --Cmp_Id=@Cmp_Id and -- Comment By rohit For Attendance regularization Approved for different Company on 2462013  
  Emp_ID=@Emp_ID and For_Date=@For_Date   
  --Where IO_Tran_Id = @IO_Tran_Id And Cmp_Id=@Cmp_Id  

  
 End   
   
END
