

CREATE PROCEDURE [dbo].[SP_EMP_WEEKOFF_HOLIDAY_DATE_GET]
 @Emp_Id        numeric 
,@Cmp_ID        numeric
,@From_Date         Datetime
,@To_Date       Datetime
,@Join_Date     Datetime = null
,@Left_Date     Datetime = null
,@Is_Cancel_Weekoff     NUMERIC(1,0)
,@strHoliday_Date   varchar(Max)
,@varWeekOff_Date   varchar(max)= null output 
,@varHoliday_Date   varchar(max)= null output 
,@Cancel_WeekOff    numeric(5,1) output 
,@Use_Table     tinyint =0
,@Is_FNF    tinyint =0
,@Is_Leave_Cal tinyint = 0
,@varCancelWeekOff_Date     varchar(max)= '' output -- add by mitesh for roster on 13052013
AS
    Set Nocount on 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    SET ARITHABORT ON

     
 
    Declare @dtAdjDate as datetime
    set @Cancel_WeekOff = 0
    
    Declare @TempFor_Date   DateTime
    Declare @WeekOff    Varchar(100)
    Declare @Effe_weekoff   Varchar(100)
    Declare @Temp_weekoff   Varchar(100)
    Declare @Effe_Date  Datetime
    Declare @Weekoff_Day_Value varchar(100)
    Declare @Eff_Weekoff_Day_Value varchar(100)
    Declare @Weekoff_Value  numeric(3,1)
    Declare @Var_All_H_Date varchar(max)
    Declare @Pre_Date_WeekOff datetime 
    Declare @Next_Date_WeekOff  Datetime 
    Declare @Alt_W_Name         Varchar(100)
    Declare @Alt_W_Full_Day_cont    varchar(50)
    Declare @Alt_W_Half_Day_cont    varchar(50)
    Declare @varCount               varchar(3)
    Declare @IS_P_Comp          tinyint
    DECLARE @Branch_Id  Numeric
    DECLARE @genral_Cancel_Weekoff tinyint
    DECLARE @Allowed_Full_WeekOff_MidJoining tinyint
    
    Declare @Temp_Alt_W_Name            Varchar(100)
    Declare @Temp_Alt_W_Full_Day_cont   varchar(50)
    Declare @Temp_Alt_W_Half_Day_cont   varchar(50) --Added by Sumit on 06/10/2016 after discssion with Hardik Bhai and Nimesh Bhai
    
    Set @Effe_weekoff = ''
                            
    set @varWeekOff_Date = ''
    set @Weekoff_Day_Value =''
    set @Eff_Weekoff_Day_Value =''
    set @Weekoff_Value = 0
    set @genral_Cancel_Weekoff = 0
    set @Branch_Id = 0
    set @Temp_Alt_W_Name=''
    set @Temp_Alt_W_Full_Day_cont=''
    set @Temp_Alt_W_Half_Day_cont=''
    
    DECLARE @genral_Cancel_Holiday tinyint
    Declare @H_From_Date    Datetime 
    Declare @H_To_Date      Datetime 
    Declare @Date_Diff      numeric 
    Declare @For_Date       datetime
    Declare @Is_Half        tinyint
    Declare @H_Days         numeric(3,1)
    Declare @Is_Cancel      tinyint
    --DECLARE @Branch_Id_Temp  Numeric
    DECLARE @is_Fix varchar
    
    set @varHoliday_Date = ''
    set @Is_Cancel =0
    --set @Branch_Id_Temp =0 
    set @genral_Cancel_Holiday = 0
    set @is_Fix = 'N'
    
    Declare @T_Weekoff Table 
     (
        Weekoff_Data    varchar(100) 
     )
     
     Declare @T_W_Count  Table
        ( 
            W_NAme      varchar(20),
            W_Count     int default 0
         )
    
    /*The following logic has been added by Nimesh on 07-Nov-2016*/
    /*If Holiday is continue after month end or there is a weekoff on next day of month end then it should be taken to check the sandwich policy*/
    SET @From_Date = DATEADD(d, -7, @From_Date)
    SET @To_Date = DATEADD(d, 7, @To_Date)
    
    insert into @T_W_Count  select 'Sunday' ,0
    insert into @T_W_Count  select 'Monday' ,0
    insert into @T_W_Count  select 'Tuesday' ,0
    insert into @T_W_Count  select 'Wednesday' ,0
    insert into @T_W_Count  select 'Thursday' ,0
    insert into @T_W_Count  select 'Friday' ,0
    insert into @T_W_Count  select 'Saturday' ,0
    
    if @Is_FNF = 0
        Begin
            
            If isnull(@join_Date,'') = ''
                Begin
                    exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output
                End

            If isnull(@Left_Date,'') <> '' 
                begin
                    If @Left_Date < @Join_Date  
                        set @Left_Date = null   
                end
        End
    else
        Begin       
            select @left_Date = Emp_Left_Date from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id
            If isnull(@join_Date,'') = ''
                Begin
                    Declare @Temp_Left_Date     Datetime
                    set @Temp_Left_Date =   @Left_Date
                    exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output
                    set @Left_Date=@Temp_Left_Date 
                End
    
        End 
        
     -- Changed by Gadriwala Muslim 03102015
    select @Branch_Id = Branch_ID from dbo.T0095_Increment EI inner join
    (
        select max(Increment_ID) as Increment_ID from dbo.T0095_Increment  WITH (NOLOCK) 
        where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
    )  Qry on EI.Increment_ID = Qry.Increment_ID
     where Emp_ID = @emp_ID and cmp_ID = @cmp_ID
     
     -- Changed by Gadriwala Muslim 03102015
    select @Allowed_Full_WeekOff_MidJoining = Allowed_Full_WeekOf_MidJoining , @genral_Cancel_Weekoff = Is_Cancel_Weekoff, @genral_Cancel_Holiday = Is_Cancel_Holiday   
    from dbo.T0040_GENERAL_SETTING GS  WITH (NOLOCK) inner join
    (
        select max(For_Date) as For_Date from dbo.T0040_GENERAL_SETTING   WITH (NOLOCK) 
        where For_Date <= @From_Date  and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id
     ) Qry on GS.for_Date = qry.For_Date 
     where  Branch_ID = @Branch_Id
    
    --Added by hardik 06/10/2012
    DECLARE  @WeekOfMonth varchar(5)
    Set @WeekOfMonth=0
    
                Declare curWeekOff cursor fast_forward for -- Changed by gadriwala Muslim 03102015
                    select Weekoff_Day, 
                    case when @Allowed_Full_WeekOff_MidJoining =1 then @From_Date  else AWD.For_Date  end as For_Date
                    ,Weekoff_Day_Value ,isnull(Alt_W_Name,'') ,isnull(Alt_W_Full_Day_cont,'') ,isnull(Alt_W_Half_Day_cont,'') 
                    ,isnull(IS_P_Comp,0)
                    from dbo.T0100_WEEKOFF_ADJ AWD WITH (NOLOCK)  inner join (select max(for_Date) as for_date 
                    from dbo.T0100_WEEKOFF_ADJ WITH (NOLOCK)  where Emp_ID = @Emp_ID and cmp_ID = @Cmp_ID and for_Date <= @To_Date ) qry  on AWD.For_Date = Qry.for_date 
                    where Emp_id = @Emp_ID and cmp_ID = @cmp_ID and Weekoff_Day <> 'N' 
                
                
            open curWeekOff
                fetch next from curWeekOff into @WeekOff ,@Effe_Date,@Weekoff_Day_Value,@Alt_W_Name,@Alt_W_Full_day_Cont,@Alt_W_Half_Day_Cont,@IS_P_Comp
                while @@fetch_status = 0
                    begin
                    
                    

                        select @WeekOff =  dbo.F_Weekoff_Day(@WeekOff)
                        set @TempFor_Date = @From_Date
                        set @Temp_weekoff = @WeekOff
                        set @Temp_Alt_W_Name=@Alt_W_Name                    
                        set @Temp_Alt_W_Full_Day_cont=@Alt_W_Full_day_Cont
                        set @Temp_Alt_W_Half_Day_Cont=@Alt_W_Half_Day_Cont
                        
                        Delete from @T_Weekoff 
                        insert into @T_Weekoff 
                        Select data from dbo.Split(@Weekoff_Day_Value,'#')

                        while @TempFor_Date <= @To_Date                         
                            begin
                                
                                if @Effe_Date > @From_Date and @TempFor_Date < @Effe_Date 
                                    begin
                                        
                                        -- Changed by Gadriwala Muslim 03102015  ( Max(For_Date) inner join )
                                        select @Effe_weekoff = Weekoff_Day  ,@Eff_Weekoff_Day_Value = Weekoff_day_Value 
                                        ,@Alt_W_Name = isnull(Alt_W_Name,'') ,@Alt_W_Full_Day_cont = isnull(Alt_W_Full_Day_cont,'') ,@Alt_W_Half_Day_cont = isnull(Alt_W_Half_Day_cont,'') 
                                                ,@IS_P_Comp = isnull(IS_P_Comp,0)
                                        From dbo.T0100_WEEKOFF_ADJ WAD WITH (NOLOCK)  inner join (
                                        select max(for_Date) as for_date from dbo.T0100_WEEKOFF_ADJ WITH (NOLOCK)  
                                        where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and for_Date <= @TempFor_Date 
                                        ) Qry on Qry.for_date = WAD.For_Date  
                                        where Emp_id = @Emp_ID and Cmp_ID = @Cmp_ID and Weekoff_Day <> 'N' 
                                        
                                        
                                        select @WeekOff = dbo.F_Weekoff_Day(@Effe_weekoff)
                                                                                
                                        Delete from @T_Weekoff 
                                        insert into @T_Weekoff 
                                        Select data from dbo.Split(@Eff_Weekoff_Day_Value,'#')                                          

                                    end
                                else
                                    begin   
                                        set @WeekOff = @Temp_weekoff
                                        set @Alt_W_Name=@Temp_Alt_W_Name
                                        set @Alt_W_Full_day_Cont=@Temp_Alt_W_Full_Day_cont
                                        set @Alt_W_Half_Day_Cont=@Temp_Alt_W_Half_Day_Cont --Added by Sumit on 06/10/2016
                                    end                         
                                
                                set @Var_All_H_Date =  isnull(@strHoliday_Date,'') + '' + @WeekOff                              
                                
                                            
                                exec dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @TempFor_Date,@Var_All_H_Date,@Pre_Date_WeekOff output,@Next_Date_WeekOff output                                
                                
                                select @Weekoff_Value = isnull(replace(Weekoff_Data,datename(dw,@TempFor_Date),''),1) from @T_Weekoff where charindex(datename(dw,@TempFor_Date) ,Weekoff_Data,0) > 0                                               
                                
                                if isnull(@Weekoff_Value,0) =0
                                    set @Weekoff_Value = 1
                                    
                                if @Alt_W_Name <> '' and charindex(@Alt_W_Name,datename(dw,@TempFor_Date),0) >0 
                                    begin
                                        Select  @varCount = W_Count  From @T_W_Count Where W_Name = @Alt_W_Name
                                        
                                        set @varCount = '#' + @varCount   + '#'

                                        --added by Hardik 21/09/2012
                                        --SET @WeekOfMonth = DATEDIFF(week, DATEADD(MONTH, DATEDIFF(MONTH, 0, @TempFor_Date), 0), @TempFor_Date) +1
                                        SET @WeekOfMonth = ((DAY(@TempFor_Date) - 1)  / 7) + 1--((Day(@TempFor_Date)-1 )/7) + 1
                                
                                        --if @Alt_W_Full_day_Cont <> '' and charindex(@varCount,@Alt_W_Full_day_Cont,0) >0
                                        if @Alt_W_Full_day_Cont <> '' and charindex(@WeekOfMonth,@Alt_W_Full_day_Cont,0) >0
                                            begin 
                                                set @Weekoff_Value =1                                               
                                            end                                                                         
                                        else if @Alt_W_Half_day_Cont <> '' and charindex(@WeekOfMonth,@Alt_W_Half_day_Cont,0) >0                                                                                        
                                            begin                                       
                                                set @Weekoff_Value =0.5                                                 
                                            end
                                        else
                                            begin                                           
                                                set @Weekoff_Value =0 
                                            end
                                    end         
                                    
                                    declare @cnt_leave_pre_next_weekoff numeric(5,1)
                                    declare @temp_cnt_leave_pre_next_weekoff numeric(5,1)
                                    declare @chk_leave_setting_for_leave_as_weekoff as tinyint
                                
                                    set @cnt_leave_pre_next_weekoff = 0
                                    set @temp_cnt_leave_pre_next_weekoff = 0
                                    set @chk_leave_setting_for_leave_as_weekoff = 0
                                
                                IF charindex(datename(dw,@TempFor_date) ,@WeekOff,0) > 0  And case when @Allowed_Full_WeekOff_MidJoining =1 then @From_Date  else @Join_Date  end <=@TempFor_date AND @Weekoff_Value > 0 --@Weekoff_Value > 0 --Ankit/Hardikbhai--02022016
                                    Begin       
                                                set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11)) 
                                    End 
                                            
                                    set @TempFor_Date = dateadd(d,1,@TempFor_Date)
                            end
                            
                            
                            
                        fetch next from curWeekOff into @WeekOff ,@Effe_Date,@Weekoff_Day_Value,@Alt_W_Name,@Alt_W_Full_day_Cont,@Alt_W_Half_Day_Cont,@IS_P_Comp
                    end                                         
            close curWeekOff
            deallocate curWeekOff   
        
           
        -- Holiday
        

  -- Commented by Gadriwala Muslim  Duplicate Loop  create  03102015 
        
    --select @Branch_Id_Temp = Branch_ID from dbo.T0095_Increment EI inner join
    --(
    --  select max(Increment_ID) as Increment_ID from dbo.T0095_Increment  
    --  where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
    --) Qry on  Qry.Increment_ID = EI.Increment_ID
    --where  Emp_ID = @Emp_Id and cmp_ID = @cmp_ID
    
    --select @genral_Cancel_Holiday = Is_Cancel_Holiday 
    --from dbo.T0040_GENERAL_SETTING GS inner join
    --(
    --  select max(For_Date) as For_Date from dbo.T0040_GENERAL_SETTING  
    --  where For_Date <= @To_Date  and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_Id_Temp
    -- )
    --where Branch_ID = @Branch_Id_Temp
        

            
     DECLARE @strHolidayALL varchar(Max)

    declare curHoliday cursor fast_forward for
            SELECT DISTINCT CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_FROM_DATE,
                CAST(CAST(DATENAME(DAY,H_TO_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_TO_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_TO_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_TO_DATE,
                ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
            FROM T0040_HOLIDAY_MASTER  WITH (NOLOCK) 
                WHERE CMP_ID=@CMP_ID AND IS_FIX = 'Y' AND ISNULL(IS_OPTIONAL,0)= 0 AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@BRANCH_ID) AND
                    @FROM_DATE <= 
                        CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) 
                    AND 
                    @TO_DATE >= 
                        CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME)
        UNION ALL
            SELECT DISTINCT  CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_FROM_DATE,
                CAST(CAST(DATENAME(DAY,H_TO_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_TO_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_TO_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS H_TO_DATE,
                ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
            FROM T0040_HOLIDAY_MASTER WITH (NOLOCK)  WHERE CMP_ID=@CMP_ID AND HDAY_ID IN (SELECT HDAY_ID FROM T0120_OP_HOLIDAY_APPROVAL  WITH (NOLOCK) 
            WHERE CMP_ID=@CMP_ID AND EMP_ID=@EMP_ID AND OP_HOLIDAY_APR_STATUS='A')
        UNION ALL
            SELECT DISTINCT  H_FROM_DATE , H_TO_DATE ,ISNULL(IS_HALF,0) ,ISNULL(IS_P_COMP,0) , IS_FIX 
            FROM T0040_HOLIDAY_MASTER  WITH (NOLOCK) 
            WHERE CMP_ID=@CMP_ID AND H_FROM_DATE >= @FROM_DATE AND H_TO_DATE <= @TO_DATE AND ISNULL(IS_OPTIONAL,0)=0 AND IS_FIX = 'N'
            AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@BRANCH_ID)
     
    open curHoliday
        fetch next from curHoliday into @H_From_Date,@H_To_Date,@Is_Half,@Is_P_Comp,@is_Fix
        while @@fetch_status = 0
            begin                           
                                
                If @H_From_Date < @From_Date
                    set @For_Date = @From_Date
                else
                    set @For_Date = @H_From_Date
                    
                If @H_To_Date > @To_Date      --Add BY hasmukh 22 11 2011 when holiday from date 24/10/2011 to 02/11/2011 then holiday result was worng before
                    set @H_To_Date = @To_Date
                else
                    set @H_To_Date = @H_To_Date
                
                 if @Is_Half  = 1
                    set @H_Days = 0.5
                 else
                    set @H_Days = 1
                    
                
                
                While @For_Date <=  @To_Date and @For_Date <= @H_To_Date
                begin                         
                        set  @varWeekOff_Date = @varWeekOff_Date + ';' + cast(@For_date as varchar(11))
                        SET @strHolidayALL = ISNULL(@strHolidayALL + ';','') + cast(@For_date as varchar(11))
                        Set @For_Date = dateadd(d,1,@For_Date)
                end 
                Fetch next from curHoliday into @H_From_Date,@H_To_Date,@Is_Half,@Is_P_Comp,@is_Fix
            end
    close curHoliday    
    deallocate curHoliday   

        ---Hardik 08/01/2014
        Declare @for_date_roster as datetime
        Declare @Is_Cancel_WO_Roster tinyint
            
        Declare curWeekOffRoster cursor for -- Changed by Gadriwala Muslim 03102015
            SELECT  for_date,is_Cancel_WO  FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK)  WHERE FOR_DATE >= @From_Date AND FOR_DATE <= @To_Date and Emp_id = @Emp_Id  and cmp_ID = @cmp_ID         
        open curWeekOffRoster
        fetch next from curWeekOffRoster into @for_date_roster,@Is_Cancel_WO_Roster
            while @@fetch_status = 0
                begin
                
                IF @Is_Cancel_WO_Roster = 1
                    Begin
                        if CHARINDEX(cast(@for_date_roster as varchar(11)),@varWeekOff_Date)>0  AND CHARINDEX(cast(@for_date_roster as varchar(11)),@strHolidayALL) < 1 
                            Begin
                                Set @varWeekOff_Date = REPLACE(@varWeekOff_Date,';' + cast(@for_date_roster as varchar(11)),'')
                            end
                    End     
                ELSE
                    BEGIN       
                        set  @varWeekOff_Date = @varWeekOff_Date + ';' + cast(@for_date_roster as varchar(11))
                    END

                    fetch next from curWeekOffRoster into @for_date_roster,@Is_Cancel_WO_Roster
                End
        close curWeekOffRoster
        deallocate curWeekOffRoster
            
    set @StrHoliday_Date=@varHoliday_Date
    

    
    RETURN 




