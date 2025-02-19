
CREATE PROCEDURE [dbo].[SP_ATTENDANCE_DASHBOARD]   
 -- Add the parameters for the stored procedure here  
  @CMP_ID   NUMERIC,  
  @FROM_DATE  DATETIME,  
  @TO_DATE   DATETIME,  
  @EMP_ID   NUMERIC,  
  @CONSTRAINT  VARCHAR(MAX),  
  @REPORT_FOR VARCHAR(50) = ''  
AS  

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 	


 DECLARE @Leave_Count NUMERIC(9,3)  
  
   CREATE table #ATT_MUSTER_EXCEL   
 (   
  EMP_ID  NUMERIC ,   
  CMP_ID  NUMERIC,  
  FOR_DATE DATETIME,  
  STATUS  VARCHAR(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  LEAVE_COUNT NUMERIC(5,2),  
  WO_HO  VARCHAR(3) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  STATUS_2 VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  ROW_ID  NUMERIC ,  
  WO_HO_DAY NUMERIC(3,2) DEFAULT 0,  
  P_DAYS  NUMERIC(5,2) DEFAULT 0,  
  A_DAYS  NUMERIC(5,2) DEFAULT 0 ,  
  JOIN_DATE DATETIME DEFAULT NULL,  
  LEFT_DATE DATETIME DEFAULT NULL,  
  GATE_PASS_DAYS NUMERIC(18,2) DEFAULT 0,  -- ADDED BY GADRIWALA MUSLIM 07042015  
  LATE_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0, -- ADDED BY GADRIWALA MUSLIM 07042015  
  EARLY_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0, -- ADDED BY GADRIWALA MUSLIM 07042015  
  EMP_CODE    VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  EMP_FULL_NAME  VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  BRANCH_ADDRESS VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  COMP_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  BRANCH_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  DEPT_NAME  VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  GRD_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  DESIG_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  P_FROM_DATE  DATETIME,  
  P_TO_DATE DATETIME,  
  BRANCH_ID NUMERIC(18,0),  
  DESIG_DIS_NO NUMERIC(18,2) DEFAULT 0,          ---ADDED JIMIT 31082015   
  SUBBRANCH_NAME VARCHAR(200) DEFAULT '' COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS  
   
 )  
     
 CREATE TABLE #Data           
 (           
    Emp_Id   numeric ,           
    For_date datetime,          
    Duration_in_sec numeric,          
    Shift_ID numeric ,          
    Shift_Type numeric ,          
    Emp_OT  numeric ,          
    Emp_OT_min_Limit numeric,          
    Emp_OT_max_Limit numeric,          
    P_days  numeric(12,3) default 0,          
    OT_Sec  numeric default 0  ,  
    In_Time datetime,  
    Shift_Start_Time datetime,  
    OT_Start_Time numeric default 0,  
    Shift_Change tinyint default 0,  
    Flag int default 0,  
    Weekoff_OT_Sec  numeric default 0,  
    Holiday_OT_Sec  numeric default 0,  
    Chk_By_Superior numeric default 0,  
    IO_Tran_Id    numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)  
    OUT_Time datetime,  
    Shift_End_Time datetime,   --Ankit 16112013  
    OT_End_Time numeric default 0, --Ankit 16112013  
    Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014  
    Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014  
    GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014  
   )          
      
 CREATE NONCLUSTERED INDEX IX_DATA ON DBO.#ATT_MUSTER_EXCEL  
  ( EMP_ID,EMP_CODE,ROW_ID )   
  



-----------Added by ronakk 05082022 ------------------
Declare @Branch_ID as int  = 0
Declare @Sal_St_Date	Datetime
Declare @Sal_end_Date   Datetime 
Declare @OutOf_Days		NUMERIC  
declare @manual_salary_period as numeric(18,0)

			IF @Branch_ID = 0  
				SET @Branch_ID = null
				
			IF @Emp_ID = 0  
				SET @Emp_ID = null
				
				
			IF @Branch_ID is null
				begin
					select @Branch_ID  = Branch_ID 
					from dbo.T0095_Increment EI WITH (NOLOCK)
					where Increment_ID in (select max(Increment_ID) as Increment_ID from dbo.T0095_Increment WITH (NOLOCK)  where Increment_Effective_date <= @To_Date  
					and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID) 
					and Emp_ID = @Emp_ID
				End

			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End 
				
				
			if isnull(@Sal_St_Date,'') = ''    
				  begin    
					   set @From_Date  = @From_Date     
					   set @To_Date = @To_Date    
					   set @OutOf_Days = @OutOf_Days			  			   
				  end  
				     
			 else if day(@Sal_St_Date) =1
				  begin    
					   set @From_Date  = @From_Date     
					   set @To_Date = @To_Date    
					   set @OutOf_Days = @OutOf_Days    	         			   
				  end
				  		  
			else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
				  begin   
					if @manual_salary_period = 0 
					   begin
					   
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
							Set @From_Date = @Sal_St_Date
							Set @To_Date = @Sal_End_Date 			        
					   end 
					else
						begin
							select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
							Set @From_Date = @Sal_St_Date
							Set @To_Date = @Sal_End_Date 				    				    
						end   
				  end
				  



------------End By ronakk 05082022 -------------------





 EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_GET @CMP_ID,@FROM_DATE,@TO_DATE,0,0,0,0,0,0,@EMP_ID,@EMP_ID,'','EXCEL'  
  
  
	SELECT	DISTINCT GS.Branch_ID,INC_HOLIDAY,INC_WEEKOFF
	INTO	#GENERAL_SETTING
	FROM	T0040_GENERAL_SETTING GS WITH (NOLOCK)
			INNER JOIN(
							SELECT	MAX(GS1.FOR_DATE) AS FOR_DATE,GS1.Branch_ID
							FROM	DBO.T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
									INNER JOIN #ATT_MUSTER_EXCEL EC ON GS1.Branch_ID=EC.Branch_ID
							WHERE	GS1.FOR_DATE < = @TO_DATE AND GS1.CMP_ID = @CMP_ID 
							GROUP BY GS1.Branch_ID 
						) GS1 ON GS1.Branch_ID = GS.Branch_ID AND GS.FOR_DATE = GS1.FOR_DATE


  
   
 ALTER TABLE #ATT_MUSTER_EXCEL 
 ADD FHS VARCHAR(15), FHD NUMERIC(9,3), SHS VARCHAR(50), SHD NUMERIC(9,3),FHSFULL VARCHAR(50),DNM VARCHAR(50),BgColor VARCHAR(50),Html NVARCHAR(MAX)  


   
  
   
 UPDATE ATT  
 SET  FHS = '-', FHD =0, SHS='-', SHD = 0,FHSFULL=''  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.STATUS in ('-')  
   
   
 --Full Present  
 UPDATE ATT  
 SET  FHS = 'P', FHD =P_DAYS, SHS='P', SHD = 0,FHSFULL='Present'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.P_DAYS>0  
   
 --Holiday/WeekOff  
 UPDATE ATT  
 SET  FHS = STATUS, FHD = ATT.P_DAYS, SHS=ATT.STATUS_2, SHD = 0,FHSFULL='Qurter Day(0.25)'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.STATUS IN ('QD')  
   
 UPDATE ATT  
 SET  FHS = STATUS, FHD = ATT.P_DAYS, SHS=ATT.STATUS_2, SHD = 0,FHSFULL='3rd Quarter(0.75)'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.STATUS IN ('3QD')  
   
   
 --Holiday/WeekOff  
 UPDATE ATT  
 SET  FHS = WO_HO, FHD =1, SHS=WO_HO, SHD = 0,FHSFULL='Week Off'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.WO_HO IN ('W','OD/WO')  
   
   
  
 UPDATE ATT  
 SET	FHS = WO_HO, FHD = 1,
		SHS=WO_HO, SHD = 0,FHSFULL='Holiday'  
 FROM	#ATT_MUSTER_EXCEL ATT  
 WHERE	ATT.WO_HO IN ('HO','OHO')  
   
  
   
   --select * from #ATT_MUSTER_EXCEL
  -- select * from T0140_LEAVE_TRANSACTION where Emp_Id = 14838 and For_Date = '2019-12-30'
  
   
  
 --Absent  
 UPDATE ATT  
 SET  FHS = 'A', FHD =1, SHS='A', SHD = 0,FHSFULL='Absent'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.A_DAYS = 1   
 
 --Retantion Added by ronakk 08082022
  UPDATE ATT  
 SET  FHS = 'RT', FHD =1, SHS='RT', SHD = 0,FHSFULL='Retantion'
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.STATUS = 'RT'   
   

 --Absent  
 UPDATE ATT  
 SET  SHS='A', SHD = ATT.A_DAYS,FHSFULL='Absent'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE (ATT.A_DAYS BETWEEN 0.1 AND 0.9)   
   
 --Half Holiday   
 UPDATE ATT  
 SET   SHS=WO_HO, SHD = 0,FHSFULL='Half Holiday'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.STATUS IN ('HHO')  
  
   
  

 --Leave  
 UPDATE ATT  
 SET  FHS = ATT.STATUS, FHD = 1, SHS='L', SHD = 0,FHSFULL='Leave'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.Leave_Count = 1  
   
   
 --Leave  
 --UPDATE ATT  
 --SET  SHS=Status, SHD = Leave_Count,FHSFULL='Leave'  
 --FROM #ATT_MUSTER_EXCEL ATT  
 --WHERE ATT.Leave_Count between 0.1 and  0.9  
   
UPDATE ATT  
 SET  FHS=Status, FHD = Leave_Count,FHSFULL='Leave'  
 FROM #ATT_MUSTER_EXCEL ATT  
 WHERE ATT.Leave_Count between 0.1 and  0.9    
         
  
 --SELECT @Leave_Count =SUM(LEAVE_COUNT) from #ATT_MUSTER_EXCEL ATT   
 --WHERE ATT.FHS ='L'   
   
 ------Present Payabale Days  
 --UPDATE ATT  
 --SET  SHS='PD', SHD = ATT.P_DAYS,FHSFULL='Payable Present Days'  
 --FROM #ATT_MUSTER_EXCEL ATT  
   
   
 ------Gate PASS Days  
 UPDATE ATT  
 SET  DNM=SUBSTRING({fn DAYNAME(ATT.FOR_DATE)},1,3)  
 FROM #ATT_MUSTER_EXCEL ATT   
 WHERE ATT.ROW_ID <= 31  
     	
    

    
 UPDATE #ATT_MUSTER_EXCEL  
 SET  FHS = CASE ROW_ID    
      WHEN 32  
       THEN 'P'   
      WHEN 33  
       THEN 'A'   
      WHEN 34  
       THEN 'L'  
      WHEN 35  
       THEN 'W'  
      WHEN 36  
       THEN 'H'  
      WHEN 37  
       THEN 'LC'  
      ELSE  
       FHS  
     END, FHD = STATUS   
 WHERE ROW_ID > 31  
  
  
 UPDATE #ATT_MUSTER_EXCEL  
 SET  FHSFULL = CASE FHS    
      WHEN 'P'  
       THEN 'Present'   
      WHEN 'A'  
       THEN 'Absent'   
      WHEN 'L'  
       THEN 'Leave'  
      WHEN 'W'  
       THEN 'Week Off'  
      WHEN 'H'  
       THEN 'Holiday'  
      WHEN 'LC'  
       THEN 'Late Count'  
      ELSE  
       FHSFULL  
     END  
 WHERE ROW_ID > 31  
 -- --Leave Count  
 --UPDATE ATT  
 --SET  FHS = 'LC', FHD =@Leave_Count,SHS='LC', SHD = 0  
 --FROM #ATT_MUSTER_EXCEL ATT  
 --WHERE ATT.ROW_ID=37   
 DECLARE @PresentDaysPayable NUMERIC(18,3)
 DECLARE @GatePassDays NUMERIC(18,2)  
 DECLARE @Fordate DATETIME  
 DECLARE @WeekoffDays NUMERIC(18,2)
 DECLARE @HolidayDays NUMERIC(18,2)
 DECLARE @LateDays NUMERIC(18,2)
 DECLARE @EarlyDays NUMERIC(18,2)
 DECLARE @INC_HOLIDAY TINYINT
 DECLARE @INC_WEEKOFF TINYINT
 DECLARE @LATE_WITH_LEAVE TINYINT 
 
 SET @HolidayDays = 0
 SET @WeekoffDays = 0
 SET @LateDays = 0
 Set @EarlyDays = 0

	SELECT	DISTINCT @INC_HOLIDAY = INC_HOLIDAY,@INC_WEEKOFF = INC_WEEKOFF, @LATE_WITH_LEAVE = GS.LATE_WITH_LEAVE
	--INTO	#GENERAL_SETTING1
	FROM	T0040_GENERAL_SETTING GS WITH (NOLOCK)
			INNER JOIN(
							SELECT	MAX(GS1.FOR_DATE) AS FOR_DATE,GS1.Branch_ID
							FROM	DBO.T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
									INNER JOIN #ATT_MUSTER_EXCEL EC ON GS1.Branch_ID=EC.Branch_ID
							WHERE	GS1.FOR_DATE < = @TO_DATE AND GS1.CMP_ID = @CMP_ID 
							GROUP BY GS1.Branch_ID 
						) GS1 ON GS1.Branch_ID = GS.Branch_ID AND GS.FOR_DATE = GS1.FOR_DATE

   --SELECT @INC_HOLIDAY = INC_HOLIDAY, @INC_WEEKOFF = INC_WEEKOFF  FROM #GENERAL_SETTING1

  SELECT @GatePassDays =SUM(ATT.GATE_PASS_DAYS)  
  FROM  #ATT_MUSTER_EXCEL  ATT  
  GROUP by ATT.EMP_ID  

  SELECT @Leave_Count =SUM(Cast(ATT.STATUS As Numeric(18,4)))  
  FROM  #ATT_MUSTER_EXCEL  ATT  
  WHERE ROW_ID = 34
  GROUP by ATT.EMP_ID  

	IF @INC_WEEKOFF = 1
		SELECT @WeekoffDays =SUM(Cast(ATT.STATUS As Numeric(18,2)))  
		FROM  #ATT_MUSTER_EXCEL  ATT  
		WHERE ROW_ID = 35
		GROUP by ATT.EMP_ID  

	IF @INC_HOLIDAY = 1
		SELECT @HolidayDays =SUM(Cast(ATT.STATUS As Numeric(18,2)))   
		FROM  #ATT_MUSTER_EXCEL  ATT  
		WHERE ROW_ID = 36
		GROUP by ATT.EMP_ID  
	

	IF @LATE_WITH_LEAVE = 0
		BEGIN
			SELECT @EarlyDays =SUM(ISNULL(ATT.EARLY_DEDUCT_DAYS,0))   
			FROM  #ATT_MUSTER_EXCEL  ATT  
			GROUP by ATT.EMP_ID

			UPDATE #ATT_MUSTER_EXCEL SET STATUS = Isnull(STATUS,0) + Isnull(@EarlyDays,0)
			--, FHD = Isnull(STATUS,0) + Isnull(@EarlyDays,0) 
			WHERE ROW_ID = 37
		END

	IF @LATE_WITH_LEAVE = 0
		SELECT @LateDays =SUM(Cast(ATT.STATUS As Numeric(18,2)))   
		FROM  #ATT_MUSTER_EXCEL  ATT  
		WHERE ROW_ID = 37
		GROUP by ATT.EMP_ID  


			




------ Added by Deepal :- 23032022	 as discussed with sandip bhai the below setting was not implemented.
 Declare @OD_Compoff_As_Present tinyint 
 Set @OD_Compoff_As_Present = 0 

 SELECT @OD_COMPOFF_AS_PRESENT = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK)    
 WHERE SETTING_NAME = 'OD and CompOff Leave Consider As Present' AND CMP_ID = @CMP_ID  

 if @OD_Compoff_As_Present = 1
 Begin
		
		---- modify by jignsh patel 01-Apr-2022-----
		-----SELECT @PresentDaysPayable= SUM(ATT.P_DAYS) + Q1.OD_Compoff
		SELECT @PresentDaysPayable= isnull(SUM(ATT.P_DAYS),0) + isnull(Q1.OD_Compoff,0)
		FROM  #ATT_MUSTER_EXCEL  ATT  
		LEFT OUTER JOIN   
		(select sum(((IsNull(LT.CompOff_Used,0) - IsNull(LT.Leave_Encash_Days,0)) + IsNull(LT.Leave_Used,0)) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID  
		from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)    
		  INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LT.Leave_ID=LM.Leave_ID        
		where (Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID  
		  AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE  
		group by Emp_ID  
		)Q1 on ATT.EMP_ID = Q1.Emp_ID
			GROUP by ATT.EMP_ID  ,Q1.OD_Compoff
  END
  ELSe
  BEGIN
	SELECT @PresentDaysPayable= SUM(ATT.P_DAYS) 
	FROM  #ATT_MUSTER_EXCEL  ATT  
	GROUP by ATT.EMP_ID  
  END
  ------ Added by Deepal :- 23032022	 as discussed with sandip bhai the below setting was not implemented.

  SELECT @Fordate=FOR_DATE FROM #ATT_MUSTER_EXCEL WHERE ROW_ID=32  
    
   UPDATE ATT  
   SET  FHS='GP', FHD = @GatePassDays,FHSFULL='Gate Pass Days'  
   FROM #ATT_MUSTER_EXCEL ATT  
   WHERE ATT.ROW_ID = 38  
   

   
   INSERT INTO #ATT_MUSTER_EXCEL(CMP_ID,FOR_DATE,EMP_ID,FHS,FHD,SHS,SHD,ROW_ID,FHSFULL)  
   VALUES(@CMP_ID,@Fordate,@EMP_ID,'PD',@PresentDaysPayable+Isnull(@Leave_Count,0)+Isnull(@WeekoffDays,0)+ Isnull(@HolidayDays,0)-Isnull(@GatePassDays,0)-Isnull(@LateDays,0),NULL,NULL,39,'Payable Days')  
 --SELECT @PresentDaysPayable,@GatePassDays  
   
 --INSERT INTO #ATT_MUSTER_EXCEL(EMP_ID,FHS,FHD,SHS,SHD,ROW_ID,FHSFULL)  
 --SELECT  EMP_ID ,Status , Total,'',0,RowID,FHSFULL from #GP_PD_DATA GPD  

Create TABLE #Data_Leave_Pending  
(  
 Emp_ID   INT,  
 FOR_DATE DATETIME,  
 Leave_Code VARCHAR(5),  
 Leave_Status VARCHAR(25),   
 BgColor  VARCHAR(30) ,  
 Html        nvarchar(max)  
)  
 

 INSERT INTO #Data_Leave_Pending(Emp_ID,FOR_DATE,Leave_Code,Leave_Status,BgColor,Html)  
  select  LP.Emp_ID,LP.FOR_DATE, Leave_Code,Leave_Status,Case When Leave_Status = 'Pending' Then '#775dd0' Else 'transperent' End BgColor,  
      '<li>  
       '+ Leave_Name + ' Applied for ' +  
        Case When Isnull(leave_out_Time , '1900-01-01') <> '1900-01-01' AND Leave_Assign_As = 'Part Day' Then  
         IsNull(Leave_Assign_As,'') + ' From ' + convert(varchar(5), Leave_Out_Time, 108) + ' To ' + convert(varchar(5), leave_In_time, 108)   
         When Isnull(Half_Leave_Date, '1900-01-01') = LP.For_Date  Then  
          IsNull(Leave_Assign_As,'') + ' '   
         When Isnull(Half_Leave_Date, '1900-01-01') <> LP.For_Date and Isnull(Half_Leave_Date, '1900-01-01') <> '1900-01-01' Then  
          ' Full Day '   
         Else   
          ' From ' + convert(varchar(10), From_Date, 103) + ' To ' + convert(varchar(10), To_Date, 103)   
        End + ' Reason: ' + IsNull(Leave_Reason,'') + ' - ' + Leave_Status + '  
      </li>' As Html  
    from #ATT_MUSTER_EXCEL EX  
      INNER JOIN (SELECT EX1.Emp_ID, Ex1.For_Date,LAD.From_Date, LAD.To_Date, LM.Leave_Code,LM.Leave_Name, LM.Leave_Type, LAD.Leave_Reason,   
           LAD.Leave_Assign_As, LAD.Leave_Out_Time, LAD.leave_In_time,LAD.Half_Leave_Date As Half_Leave_Date, 'Pending' As Leave_Status  
         FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  
           INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID  
           INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID=LM.Leave_ID  
           INNER JOIN #ATT_MUSTER_EXCEL EX1 ON EX1.EMP_ID=LA.Emp_ID AND EX1.FOR_DATE BETWEEN LAD.From_Date AND LAD.To_Date             
         WHERE LA.Application_Status = 'P' AND Case WHEN LA.M_Cancel_WO_HO = 0 AND EX1.WO_HO<>'' Then 0 Else 1 End = 1  
         UNION ALL  
         SELECT EX1.Emp_ID, Ex1.For_Date,LAD.From_Date, LAD.To_Date, LM.Leave_Code,LM.Leave_Name, LM.Leave_Type, LAD.Leave_Reason,   
           LAD.Leave_Assign_As, LAD.Leave_Out_Time, LAD.leave_In_time,LAD.Half_Leave_Date As Half_Leave_Date, 'Approved' As Leave_Status  
         FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)  
           INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID  
           INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID=LM.Leave_ID  
           INNER JOIN #ATT_MUSTER_EXCEL EX1 ON EX1.EMP_ID=LA.Emp_ID AND EX1.FOR_DATE BETWEEN LAD.From_Date AND LAD.To_Date             
         WHERE LA.Approval_Status <> 'R' AND Case WHEN LA.M_Cancel_WO_HO = 0 AND EX1.WO_HO<>'' Then 0 Else 1 End = 1  
           AND NOT EXISTS(SELECT 1 FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) WHERE LA.Leave_Approval_ID=LC.Leave_Approval_id AND EX1.FOR_DATE=LC.For_date)  
         ) LP ON Ex.EMP_ID=LP.EMP_ID AND Ex.FOR_DATE=LP.FOR_DATE  
    Where Ex.For_date Between @FROM_DATE and @TO_DATE  



	--select Leave_Status,[STATUS],Leave_Code,FHD,SHD,* from  #ATT_MUSTER_EXCEL ATT  
 --  INNER JOIN #Data_Leave_Pending DLP on DLP.Emp_ID = ATT.EMP_ID and ATT.FOR_DATE= DLP.FOR_DATE  



    UPDATE ATT  
   SET  ATT.BgColor=DLP.BgColor,
   ATT.Html=DLP.Html

   ----------------- Modify By Jignesh Patel 09-Dec-2021-----------
   --,FHS = case WHEN FHD < 1 And SHS <> 'A' then FHS  else Leave_Code end,
   -- SHS = case WHEN FHD < 1 then SHS  else Leave_Code end

   ,FHS = case when Leave_Status = 'Approved' then
					case WHEN FHD <= 1 And [STATUS] <> 'A'  then
							Leave_Code  else Leave_Code  end
			   else Leave_Code end

  , SHS = case when Leave_Status = 'Approved' then
						case WHEN SHD <= 1 And  [STATUS] <> 'A' then 
						Leave_Code  else Leave_Code end 
			  else Leave_Code end
	-----------------------End ----------------

	--,FHS = case WHEN FHD < 1 then FHS + ' - ' + Leave_Code else Leave_Code end,
	--SHS = case WHEN FHD < 1 then SHS + ' - ' + Leave_Code else Leave_Code end 
   FROM #ATT_MUSTER_EXCEL ATT  
   INNER JOIN #Data_Leave_Pending DLP on DLP.Emp_ID = ATT.EMP_ID and ATT.FOR_DATE= DLP.FOR_DATE  


   UPDATE ATT  
   SET  ATT.BgColor='transperent'  
   FROM #ATT_MUSTER_EXCEL ATT  
   WHERE ISNULL(ATT.BgColor,'')=''  

   --Added by ronakk 08082022
  UPDATE ATT  
   SET  ATT.BgColor='#cc99ff'  
   FROM #ATT_MUSTER_EXCEL ATT  
   WHERE ATT.FHS ='RT'

 
   
 --SELECT  EMP_ID, isnull(FHS,' - ') as FHS , isnull(FHD,0) FHD , isnull(SHS,' - ') as SHS , SHD ,FOR_DATE as D,ROW_ID,
 --isnull(FHSFULL,' ') FHSFULL,DNM,BgColor,Html,format(FOR_DATE,'dd-MM') as DDD
 --FROM #ATT_MUSTER_EXCEL   
 --order by ROW_ID asc
  
 
  SELECT  EMP_ID,FHS ,FHD ,SHS , SHD ,FOR_DATE as D,ROW_ID, FHSFULL,DNM,BgColor,Html,format(FOR_DATE,'dd-MM') as DDD
 FROM #ATT_MUSTER_EXCEL   
 order by ROW_ID asc

 --WHERE ISNULL(FHS,'') <>''   
 --WHERE ROW_ID <= 37  
   
   
 --SELECT  EMP_ID, STATUS, P_DAYS, STATUS_2, A_DAYS, LEAVE_COUNT, WO_HO, WO_HO_DAY, FOR_DATE, ROW_ID, LATE_DEDUCT_DAYS, EARLY_DEDUCT_DAYS,  
 --  FHS, FHD, SHS, SHD   
 --FROM #ATT_MUSTER_EXCEL   
     
           
   
 Drop TABLE #Data_Leave_Pending   
    
END 
