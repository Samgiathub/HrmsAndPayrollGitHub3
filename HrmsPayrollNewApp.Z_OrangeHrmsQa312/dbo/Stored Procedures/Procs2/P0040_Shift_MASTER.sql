  
  
CREATE PROCEDURE [dbo].[P0040_Shift_MASTER]  
   @Shift_ID   numeric(18,0) output  
  ,@Cmp_ID   numeric(18,0)  
  ,@Shift_Name  varchar(100)  
  ,@Shift_St_Time  varchar(10)  
  ,@Shift_End_Time varchar(10)  
  ,@Shift_Dur   varchar(10)  
  ,@F_St_Time   varchar(10)=''  
  ,@F_End_Time  varchar(10)=''  
  ,@F_Duration  varchar(10)=''  
  ,@S_St_Time   varchar(10)=''  
  ,@S_End_Time  varchar(10)=''  
  ,@S_Duration  varchar(10)=''  
  ,@T_St_Time   varchar(10)=''  
  ,@T_End_Time  varchar(10)=''  
  ,@T_Duration  varchar(10)=''  
  ,@tran_type   varchar(1)  
  ,@Inc_Auto_Shift    tinyint=0   
  ,@Is_Half_Day tinyint = 0  
  ,@Week_Day varchar(10) = ''  
  ,@Half_St_Time varchar(10) = ''  
  ,@Half_End_Time varchar(10) = ''  
  ,@Half_Dur varchar(10) = ''  
  ,@Half_min_duration varchar(10) = ''  
  ,@User_Id numeric(18,0) = 0  
        ,@IP_Address varchar(30)= '' --Add By Paras 13-10-2012  
        ,@Is_Split_Shift tinyint = 0 --Add By Paras 08-08-2013  
        ,@Is_Training_Shift tinyint = 0 --Add By Paras 08-08-2013  
        ,@Split_Shift_Rate numeric(18,2) = 0 --Add By Paras 09 aug 2013  
        ,@Split_Shift_Ratio numeric(18,2) = 0 --Add By Hardik 12/08/2013  
        ,@DeduHour_SecondBreak tinyint = 0 --Ankit 12112013  
  ,@DeduHour_ThirdBreak tinyint = 0 --Ankit 12112013  
  ,@Auto_Shift_Group tinyint = 0 --Added By Jimit 03022018  
  ,@Shift_WeekDay_OT_Rate Numeric(5,4) = 0 --Added By Jimit 23102108  
  ,@Shift_WeekOff_OT_Rate Numeric(5,4) = 0 --Added By Jimit 23102108  
  ,@Shift_Holiday_OT_Rate Numeric(5,4) = 0 --Added By Jimit 23102108  
  ,@Is_Inactive tinyint = 0  
  ,@pInActive_Date Datetime = '' 
  ,@IsNightShift tinyint = 0 
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
    
	    set @Shift_Name = dbo.fnc_ReverseHTMLTags(@Shift_Name)  --added by mansi 061021
  Declare @For_Date varchar(11)  
  Declare @St_Time  DAtetime   
  Declare @End_Time Datetime   
  set @For_Date = '01-jan-2009'  
    
  if @pInActive_Date = '' or @pInActive_Date = '1900-01-01 00:00.000' or @Is_Inactive = 0  
   Set @pInActive_Date = NULL  
    
declare @OldValue as  varchar(max)  
declare @OldShiftName as varchar(100)  
declare @OldShift_St_Time as varchar(10)  
declare @OldShift_End_Time as varchar(10)  
declare  @OldShift_Dur  as varchar(10)  
declare  @OldF_St_Time as  varchar(10)  
declare  @OldF_End_Time as  varchar(10)  
declare  @OldF_Duration as  Varchar(10)  
declare  @OldS_St_Time  as varchar(10)   
declare  @OldS_End_Time  as varchar(10)   
declare  @OldS_Duration  as varchar(10)   
declare  @OldT_St_Time  as varchar(10)   
declare  @OldT_End_Time  as varchar(10)  
declare  @OldT_Duration  as varchar(10)  
declare  @OldInc_Auto_Shift  as varchar(1)  
declare  @OldIs_Half_Day  as varchar(1)   
declare  @OldWeek_Day  as varchar(10)   
declare  @OldHalf_St_Time  as varchar(10)   
declare  @OldHalf_End_Time  as varchar(10)   
declare  @OldHalf_Dur  as varchar(10)   
declare  @OldHalf_min_duration  as varchar(10)   
  
set @OldValue =''  
set @OldShiftName = ''  
set @OldShift_St_Time = ''  
set @OldShift_End_Time = ''  
set  @OldShift_Dur  = ''  
set  @OldF_St_Time = ''  
set  @OldF_End_Time = ''  
set  @OldF_Duration = ''  
set  @OldS_St_Time  = ''  
set  @OldS_End_Time = ''   
set  @OldS_Duration  = ''   
set  @OldT_St_Time  = ''  
set  @OldT_End_Time  = ''  
set  @OldT_Duration  = ''  
set  @OldInc_Auto_Shift  = ''  
set  @OldIs_Half_Day  = ''   
set  @OldWeek_Day = ''  
set  @OldHalf_St_Time = ''  
set  @OldHalf_End_Time = ''  
set  @OldHalf_Dur  = ''   
set  @OldHalf_min_duration  = ''  
  
  
  
  if @Shift_Dur =''  
   Begin  
     set @St_Time  = cast (@For_Date  + ' ' + @Shift_St_Time  as Datetime)  
     set @End_Time  = cast (@For_Date  + ' ' + @Shift_End_Time  as Datetime)  
     if @St_Time  > @End_Time   
      set  @End_Time  = dateadd(d,1, @End_Time )  
  
     set @Shift_Dur = dbo.F_Return_Hours_From_Date(@St_Time,@End_Time)  
   end  
    
  --If isnull(@F_St_Time,'') = ''  
  -- set @F_St_Time = null  
  --If isnull(@F_St_Time,'') = ''  
  -- set @F_St_Time = null  
  --If isnull(@F_Duration,'') = ''  
  -- set @F_Duration = null  
  
  --If isnull(@S_St_Time,'') = ''  
  -- set @S_St_Time = null  
  --If isnull(@S_St_Time,'') = ''  
  -- set @S_St_Time = null  
  --If isnull(@S_Duration,'') = ''  
  -- set @S_Duration = null  
  
  --If isnull(@T_St_Time,'') = ''  
  -- set @T_St_Time = null  
  --If isnull(@T_St_Time,'') = ''  
  -- set @T_St_Time = null  
  --If isnull(@T_Duration,'') = ''  
  -- set @T_Duration = null  
  
  If isnull(@F_St_Time,'') = ''  
   set @F_St_Time = @Shift_St_Time  --Ankit 10032014  
  If isnull(@F_End_Time,'') = ''  
   set @F_End_Time = @Shift_End_Time --Ankit 10032014  
  If isnull(@F_Duration,'') = ''  
   set @F_Duration = @Shift_Dur  --Ankit 10032014  
  
  If isnull(@S_St_Time,'') = ''  
   set @S_St_Time = null  
  If isnull(@S_End_Time,'') = ''  
   set @S_End_Time = null  
  If isnull(@S_Duration,'') = ''  
   set @S_Duration = null  
  
  If isnull(@T_St_Time,'') = ''  
   set @T_St_Time = null  
  If isnull(@T_End_Time,'') = ''  
   set @T_End_Time = null  
  If isnull(@T_Duration,'') = ''  
   set @T_Duration = null  
     
     
  if not @F_St_Time is null and  not @F_end_Time is null  
   begin  
     set @St_Time  = cast (@For_Date  + ' ' + @F_St_Time  as Datetime)  
     set @End_Time  = cast (@For_Date  + ' ' + @F_end_Time  as Datetime)  
     if @St_Time  > @End_Time   
      set  @End_Time  = dateadd(d,1, @End_Time )  
           
    set @F_Duration = dbo.F_Return_Hours_From_Date(@St_Time,@End_Time )  
   end  
  
  if not @S_St_Time is null and  not @S_end_Time is null  
   Begin  
     set @St_Time  = cast (@For_Date  + ' ' + @S_St_Time  as Datetime)  
     set @End_Time  = cast (@For_Date  + ' ' + @S_end_Time  as Datetime)  
     if @St_Time  > @End_Time   
      set  @End_Time  = dateadd(d,1, @End_Time )  
           
    set @S_Duration = dbo.F_Return_Hours_From_Date(@St_Time,@End_Time )  
   end  
  
  if not @T_St_Time is null and  not @T_end_Time is null  
   begin  
     set @St_Time  = cast (@For_Date  + ' ' + @T_St_Time  as Datetime)  
     set @End_Time  = cast (@For_Date  + ' ' + @T_end_Time  as Datetime)  
     if @St_Time  > @End_Time   
      set  @End_Time  = dateadd(d,1, @End_Time )  
      
    set @T_Duration  = dbo.F_Return_Hours_From_Date(@St_Time,@End_Time )  
   end  
  
  
  if @tran_type ='I'   
   begin  
     If Exists(select Shift_ID From T0040_Shift_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Shift_Name = @Shift_Name)  
       Begin  
        set @Shift_ID = 0  
        return 0  
       End  
     
     select @Shift_ID = isnull(max(Shift_ID),0) + 1 from T0040_Shift_MASTER WITH (NOLOCK)  
       
     INSERT INTO T0040_SHIFT_MASTER  
                           (Shift_ID, Cmp_ID, Shift_Name, Shift_St_Time, Shift_End_Time, Shift_Dur, F_St_Time, F_End_Time, F_Duration, S_St_Time, S_End_Time, S_Duration,   
                           T_St_Time, T_End_Time, T_Duration,Inc_Auto_Shift,Is_Half_Day,Week_Day,Half_St_Time,Half_End_Time,Half_Dur,Half_min_duration,Is_Split_Shift,Is_Training_Shift,Split_Shift_Rate,Split_Shift_Ratio,DeduHour_SecondBreak, DeduHour_ThirdBreak,Auto_Shift_Group  
            ,Shift_WeekDay_OT_Rate,Shift_WeekOff_OT_Rate,Shift_Holiday_OT_Rate,Is_InActive,InActive_Date,IsNightShift) --Add By paras08/08/2013  
     VALUES     (@Shift_ID,@Cmp_ID,@Shift_Name,@Shift_St_Time,@Shift_End_Time,@Shift_Dur, @F_St_Time, @F_End_Time, @F_Duration, @S_St_Time, @S_End_Time, @S_Duration,@T_St_Time, @T_End_Time, @T_Duration,@Inc_Auto_Shift,@Is_Half_Day,@Week_Day,@Half_St_Time,
@Half_End_Time,@Half_Dur,@Half_min_duration,@Is_Split_Shift,@Is_Training_Shift,@Split_Shift_Rate,@Split_Shift_Ratio,@DeduHour_SecondBreak, @DeduHour_ThirdBreak,@Auto_Shift_Group  
        ,@Shift_WeekDay_OT_Rate,@Shift_WeekOff_OT_Rate,@Shift_Holiday_OT_Rate,@Is_Inactive,@pInActive_Date,@IsNightShift)  
       
     --Ankit 10032014  
     Exec P0050_Shift_Detail 0,@Shift_ID,@Cmp_ID,1,24,0,1,0,0,'I',0,0,0,0,0  
     --Ankit 10032014  
       
     --Add By PAras 13-10-2012  
     set @OldValue = 'New Value' + '#'+ 'Shift Name :' +ISNULL( @Shift_Name,'') + '#' + 'Shift Start Time :' + ISNULL( @Shift_St_Time ,'') + '#' + 'Shift End Time :' + ISNULL(@Shift_End_Time,'')  + '#' + 'Shift Duration :' + ISNULL( @Shift_Dur,'') + '#' +
 'F St Time :' + ISNULL( @F_St_Time,'') + ' #'+ ' F End Time :' + ISNULL(@F_End_Time,'') + ' #'+ 'F Duration :' + ISNULL( @F_Duration,'') + ' #'+ 'S St Time :' + ISNULL(@S_St_Time,'')  + ' #'+ 'S End Time :' +ISNULL( @S_End_Time,'') + '#' + 'S Duration :'
 + ISNULL( @S_Duration,'') + '#' + 'T St Time :' + ISNULL(@T_St_Time,'')  + '#' + ' T End Time :' + ISNULL( @T_End_Time,'') + '#' + 'T Duration:' + ISNULL( @T_Duration,'') + ' #'+ 'Inc Auto Shift:' + CAST(ISNULL(@Inc_Auto_Shift,0)as varchar(1)) + ' #'+ 'I
s Half Day:' + CAST(ISNULL( @Is_Half_Day,0)as varchar(1)) + ' #'+ 'Week Day :' + ISNULL(@Week_Day,'')  + ' #' + 'Half St Time :' +ISNULL( @Half_St_Time,'') + '#' + 'Half End Time :' + ISNULL( @Half_End_Time,'') + '#' + 'Half Dur :' + ISNULL(@Half_Dur,'') 
 + '#' + ' Half min duration :' + ISNULL( @Half_min_duration,'') + '#' + 'Night Shift :' + Cast(@IsNightShift as Char(2))  + '#' 
     --  
    end   
 else if @tran_type ='U'   
    begin  
     If Exists(select Shift_ID From T0040_Shift_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Shift_Name = @Shift_Name   
             and Shift_ID <> @Shift_ID)  
       Begin  
        set @Shift_ID = 0  
        return 0  
       End  
                     --Add By PAras 13-10-2012  
                     select @OldShiftName =ISNULL(Shift_Name,'') ,@OldShift_St_Time  =ISNULL(Shift_St_Time,''),@OldShift_End_Time  =isnull(Shift_End_Time,0),@OldShift_Dur  =isnull(Shift_Dur,0),@OldF_St_Time =isnull(F_St_Time,0),@OldF_End_Time  =isnull(F_End_Time,0),@OldF_Duration  = isnull(F_Duration,''),@OldS_St_Time  =isnull(S_St_Time ,0),@OldS_End_Time  =ISNULL(S_End_Time,'') ,@OldS_Duration  =ISNULL(S_Duration,''),@OldT_St_Time  =isnull(T_St_Time,0),@OldT_End_Time  =isnull(T_End_Time,0),@OldT_Duration =isnull(T_Duration,0),@OldInc_Auto_Shift =CAST(isnull(Inc_Auto_Shift,0)as varchar(1)),@OldIs_Half_Day  =CAST(isnull(Is_Half_Day,'')as varchar(1)),@OldWeek_Day  =isnull(Week_Day ,0),@OldHalf_St_Time  =ISNULL(Half_St_Time,'') ,@OldHalf_End_Time  =ISNULL(Half_End_Time,''),@OldHalf_Dur  =isnull(Half_Dur,0),@OldHalf_min_duration  =isnull(Half_min_duration,0) From dbo.T0040_SHIFT_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Shift_ID = @Shift_ID  
                       
     UPDATE    T0040_SHIFT_MASTER  
     SET              Shift_Name = @Shift_Name, Shift_St_Time = @Shift_St_Time, Shift_End_Time = @Shift_End_Time, Shift_Dur = @Shift_Dur, F_St_Time =@F_St_Time,   
                           F_End_Time = @F_End_Time, F_Duration =@F_Duration, S_St_Time =@S_St_Time, S_End_Time =@S_End_Time, S_Duration =@S_Duration, T_St_Time =@T_St_Time, T_End_Time =@T_End_Time, T_Duration =@T_Duration,Inc_Auto_Shift=@Inc_Auto_Shift, 
 
                           Is_Half_Day=@Is_Half_Day,Week_Day=@Week_Day,Half_St_Time=@Half_St_Time,Half_End_Time=@Half_End_Time,Half_Dur=@Half_Dur,Half_min_duration=@Half_min_duration,  
                           Is_Split_Shift=@Is_Split_Shift, --Add By Paras 08/08/2013  
                           Is_Training_Shift=@Is_Training_Shift, --Add By Paras 08/08/2013  
                           Split_Shift_Rate=@Split_Shift_Rate, --Add By Paras 09 aug 2013  
                           Split_Shift_Ratio = @Split_Shift_Ratio,  
                           DeduHour_SecondBreak = @DeduHour_SecondBreak,  
                           DeduHour_ThirdBreak = @DeduHour_ThirdBreak,  
                           Auto_Shift_Group = @Auto_Shift_Group,  
            Shift_WeekDay_OT_Rate = @Shift_WeekDay_OT_Rate,  
            Shift_WeekOff_OT_Rate = @Shift_WeekOff_OT_Rate,  
            Shift_Holiday_OT_Rate = @Shift_Holiday_OT_Rate,  
            Is_Inactive = @Is_Inactive,  
            InActive_Date = @pInActive_Date  
			,IsNightShift = @IsNightShift
     WHERE     (Shift_ID = @Shift_ID)  
       
      set @OldValue = 'old Value' + '#'+ 'Shift Name :' + @OldShiftName  + '#' + 'Shift End Time :' + @OldShift_End_Time   + '#' + 'Shift_Dur :' + @OldShift_Dur + '#' + 'F St Time :' +@OldF_St_Time   + '#' + 'F End Time :' + @OldF_End_Time  + ' #'+ 'F Dur
ation :' + @OldF_Duration  + ' #'+ 'S St Time :' + @OldS_St_Time  + ' #'+ 'S End Time :' + @OldS_End_Time    + ' #' +  'S Duration :' + @OldS_Duration  + '#' + 'T St Time :' + @OldT_St_Time  + '#' + 'T End Time:' + @OldT_End_Time + '#' + 'T Duration :' +@OldT_Duration   + '#' + 'Inc Auto Shift :' + @OldInc_Auto_Shift  + ' #'+ 'Is Half Day :' + @OldIs_Half_Day  + ' #'+ 'Week Day :' + @OldWeek_Day  + ' #'+ 'Half St Time:' + @OldHalf_St_Time    + ' #' + 'Half End Time:' + @OldHalf_End_Time+ '#' + 'Half Dur :
' + @OldHalf_Dur  + '#' + 'Half min duration :' + @OldHalf_min_duration + '#' + 'Night Shift :' + Cast(@IsNightShift as Char(2)) + '#'+ 'New Value' + '#'+ 'Shift Name :' +ISNULL( @Shift_Name,'') + '#' + 'Shift End Time :' + ISNULL( @Shift_End_Time,'') + '#' + 'Shift_Dur :' + ISNULL(@Shift_Dur,'') + '#' + 'F St Time :' +ISNULL(@F_St_Time,'') + '#' + 'F 
End Time :' +ISNULL( @F_End_Time,'')+ ' #'+ 'F Duration :' +ISNULL(@F_Duration,'') + ' #'+ 'S St Time :' + ISNULL( @S_St_Time,'') + ' #'+ 'S End Time  :' + ISNULL(@S_End_Time,'')  + ' #' + 'S Duration :' +ISNULL( @S_Duration,'') + '#' + 'T St Time :' + ISNULL( @T_St_Time,'') + '#' + 'T End Time :' + ISNULL(@T_End_Time,'')  + '#' + 'T Duration :' +ISNULL( @T_Duration,'') + '#' + 'Inc Auto Shift :' +CAST(ISNULL( @Inc_Auto_Shift,0)as varchar(1)) + ' #'+ 'Is Half Day :' + cast(ISNULL(@Is_Half_Day,0)as varchar
(1)) + ' #'+ 'Week Day :' + ISNULL( @Week_Day,'') + ' #'+ 'Half St Time:' + ISNULL(@Half_St_Time,'')  + ' #' +'Half End Time :' +ISNULL( @Half_End_Time,'') + '#' + 'Half Dur:' + ISNULL( @Half_Dur,'') + '#' + 'Half min duration :' + ISNULL(@Half_min_duration,'') + '#' + 'Night Shift :' + Cast(@IsNightShift as Char(2)) + '#'
       
     -----------  
    end  
 else if @tran_type ='D'   
  begin  
     select @OldShiftName =ISNULL(Shift_Name,'') ,@OldShift_St_Time  =ISNULL(Shift_St_Time,''),@OldShift_End_Time  =isnull(Shift_End_Time,0),@OldShift_Dur  =isnull(Shift_Dur,0),@OldF_St_Time =isnull(F_St_Time,0),@OldF_End_Time  =isnull(F_End_Time,0),@OldF_Duration  = isnull(F_Duration,''),@OldS_St_Time  =isnull(S_St_Time ,0),@OldS_End_Time  =ISNULL(S_End_Time,'') ,@OldS_Duration  =ISNULL(S_Duration,''),@OldT_St_Time  =isnull(T_St_Time,0),@OldT_End_Time  =isnull(T_End_Time,0),@OldT_Duration =isnull(T_Duration,0),@OldInc_Auto_Shift =CAST(isnull(Inc_Auto_Shift,0)as varchar(1)),@OldIs_Half_Day  =CAST(isnull(Is_Half_Day,'')as varchar(1)),@OldWeek_Day  =isnull(Week_Day ,0),@OldHalf_St_Time  =ISNULL(Half_St_Time,'') ,@OldHalf_End_Time  =ISNULL(Half_End_Time,''),
@OldHalf_Dur  =isnull(Half_Dur,0),@OldHalf_min_duration  =isnull(Half_min_duration,0) From dbo.T0040_SHIFT_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Shift_ID = @Shift_ID  
   DELETE FROM T0050_SHIFT_DETAIL  WHERE     (Shift_ID = @Shift_ID)     
   DELETE FROM T0040_SHIFT_MASTER  WHERE     (Shift_ID = @Shift_ID)  
     
  set @OldValue = 'New Value' + '#'+ 'Shift Name :' +ISNULL(@OldShiftName,'') + '#' + 'Shift St Time :' + ISNULL( @OldShift_St_Time,'') + '#' + 'Shift End Time :' + ISNULL(@OldShift_End_Time,'')  + '#' + '"Shift Dur :' + ISNULL( @OldShift_Dur,'') + '#' + 
'F St Time :' + ISNULL( @OldF_St_Time,'') + ' #'+ ' F End Time :' + ISNULL(@OldF_End_Time,'') + ' #'+ 'F Duration :' + ISNULL( @OldF_Duration,'') + ' #'+ 'S St Time :' + ISNULL(@OldS_St_Time,'')  + ' #'+ 'S End Time :' +ISNULL( @OldS_End_Time,'') + '#' + 
'S Duration :' + ISNULL( @OldS_Duration,'') + '#' + 'T St Time :' + ISNULL(@OldT_St_Time,'')  + '#' + ' T End Time :' + ISNULL( @OldT_End_Time,'') + '#' + 'T Duration:' + ISNULL( @OldT_Duration,'') + ' #'+ 'Inc Auto Shift:' + CAST(ISNULL(@OldInc_Auto_Shift,0)as varchar(1)) + ' #'+ 'Is Half Day:' + CAST(ISNULL( @OldIs_Half_Day,0)as varchar(1)) + ' #'+ 'Week Day :' + ISNULL(@OldWeek_Day,'')  + ' #' + 'Half St Time :' +ISNULL( @OldHalf_St_Time,'') + '#' + 'Half End Time :' + ISNULL( @OldHalf_End_Time,'') + '
#' + 'Half Dur :' + ISNULL(@OldHalf_Dur,'')  + '#' + ' Half min duration :' + ISNULL( @OldHalf_min_duration,'') + '#' + 'Night Shift :' + Cast(@IsNightShift as Char(2)) + '#'      
  end  
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Shift Master',@OldValue,@Shift_ID,@User_Id,@IP_Address  
 RETURN  
  
  
  
  