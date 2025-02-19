

CREATE PROCEDURE [dbo].[SP_EMP_HOLIDAY_WEEKOFF_ALL_2212023] 
        @Cmp_ID         NUMERIC,
        @From_Date      DateTime,
        @To_Date        DateTime,
        @All_Weekoff    bit = 0,
        @Constraint     Varchar(Max) = ''   
AS  
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET ARITHABORT ON;  
	
    
    DECLARE @Month int;
    DECLARE @Year int;
    DECLARE @Start datetime;
    DECLARE @End datetime;
    DECLARE @Emp_ID NUMERIC;
    DECLARE @Weekoff_Day_Value VARCHAR(50);
    DECLARE @weekday_Date DATETIME;
    DECLARE @Alt_W_Full_Day_cont VARCHAR(100);
    DECLARE @Weekday VARCHAR(100);
    DECLARE @Alt_w_Name VARCHAR(100);
	declare @From_Date_Actual datetime
	Declare @To_Date_Actual Datetime -- added by Hardik 06/05/2020 for Wonder as he given weekoff on 01-05-2020 to sunday but in april month weekoff was showing sunday instead of friday because of 7 day adding in To Date
    
	Set @From_Date_Actual = @From_Date
	Set @To_Date_Actual = @To_Date

    /*The following logic has been added by Nimesh on 07-Nov-2016*/
    /*If Holiday is continue after month end or there is a weekoff on next day of month end then it should be taken to check the sandwich policy*/
    SET @From_Date = DATEADD(d, -7, @From_Date)
    SET @To_Date = DATEADD(d, 7, @To_Date)
    
    SET @month = MONTH(@From_Date);
    SET @YEAR = YEAR(@From_Date);
    
    SET @Start=DATEADD(mm,@Month-1,DATEADD(yy,@Year-1900,0));
    SET @End=@To_Date

	
    IF (OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL)
	Begin 
        CREATE TABLE #Emp_WeekOff
        (
            Row_ID          NUMERIC,
            Emp_ID          NUMERIC,
			--Cmp_ID			NUMERIC,
            For_Date        DATETIME,
            Weekoff_day     VARCHAR(10),
            W_Day           numeric(3,1),
            Is_Cancel       BIT
        )
	END
    ELSE
	    TRUNCATE TABLE #Emp_WeekOff;
		
	
    
    --IF OBJECT_ID('IX_Emp_WeekOff_EmpID_ForDate') IS NULL
    --  CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #Emp_WeekOff(Emp_ID, For_Date)
   
    IF OBJECT_ID('tempdb..#EMP_CONS') IS NULL
    BEGIN
        CREATE TABLE #EMP_CONS(EMP_ID NUMERIC, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
        --EXEC dbo.SP_RPT_FILL_EMP_CONS @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0,@Cat_ID=0, @Grd_ID=0, @Type_ID=0, @Dept_ID=0, @Desig_ID=0,@Emp_ID=0,@Constraint=@Constraint 
    END
    
    IF NOT EXISTS(SELECT TOP 1 1 FROM #EMP_CONS)
    BEGIN
        INSERT INTO #EMP_CONS
        SELECT  I.EMP_ID, I.BRANCH_ID, I.INCREMENT_ID
        FROM    T0095_INCREMENT I WITH (NOLOCK) INNER JOIN (SELECT CAST(DATA AS numeric) AS EMP_ID FROM dbo.Split(@Constraint,'#') T Where Data <> '') T ON I.Emp_ID=T.EMP_ID
        WHERE   I.Increment_ID=(
                                    SELECT  TOP 1 INCREMENT_ID 
                                    FROM    T0095_INCREMENT I2  WITH (NOLOCK) 
                                    WHERE   I.Emp_ID=I2.Emp_ID AND I.Increment_Effective_Date <= @To_Date_Actual 
                                    ORDER by I2.Increment_Effective_Date DESC, I2.Increment_ID DESC
                                )
                AND I.Cmp_ID=@Cmp_ID
                
    END
    
    INSERT INTO #EMP_HW_CONS(EMP_ID)
    SELECT distinct EMP_ID FROM #EMP_CONS;

	CREATE TABLE #ALL_INCREMENT
	(
		ROW_ID NUMERIC,
		EMP_ID NUMERIC,
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC,
		INCREMENT_EFF_DATE DATETIME
	)
	--INSERT INTO #ALL_INCREMENT
	--SELECT ROW_NUMBER()OVER(PARTITION BY I.EMP_ID ORDER BY I.EMP_ID ASC, I.Increment_Effective_Date ASC),EC.*,I.Increment_Effective_Date FROM #EMP_CONS EC INNER JOIN T0095_INCREMENT I WITH (NOLOCK)  ON EC.EMP_ID=I.EMP_ID AND EC.INCREMENT_ID=I.Increment_ID

	INSERT INTO #ALL_INCREMENT
	SELECT ROW_NUMBER()OVER( ORDER BY I.EMP_ID ASC, I.Increment_Effective_Date ASC),EC.*,I.Increment_Effective_Date FROM #EMP_CONS EC INNER JOIN T0095_INCREMENT I WITH (NOLOCK)  ON EC.EMP_ID=I.EMP_ID AND EC.INCREMENT_ID=I.Increment_ID
	UNION ALL
    SELECT  ROW_NUMBER()OVER( ORDER BY I.EMP_ID ASC, I.Increment_Effective_Date ASC),I.EMP_ID, I.BRANCH_ID, I.INCREMENT_ID,I.Increment_Effective_Date
    FROM    T0095_INCREMENT I WITH (NOLOCK)  INNER JOIN 
			#EMP_CONS EC ON I.Emp_ID=EC.EMP_ID INNER JOIN
			T0095_INCREMENT I3 WITH (NOLOCK)  ON EC.EMP_ID = I3.EMP_ID AND EC.INCREMENT_ID = I3.Increment_ID
    WHERE   I.Increment_ID IN (
                                SELECT TOP 1 INCREMENT_ID 
                                FROM    T0095_INCREMENT I2 WITH (NOLOCK)  
                                WHERE   I2.Emp_ID=I3.Emp_ID 
									AND I2.Increment_Effective_Date < I3.Increment_Effective_Date
								ORDER by I2.Increment_Effective_Date DESC, I2.Increment_ID DESC
                            )
			AND I.Cmp_ID=@Cmp_ID AND I3.Increment_Effective_Date BETWEEN @FROM_DATE AND @To_Date  --changes the I3 increment to I  deepal 29112021 inditrade issue  ticket 19681
            --AND I.Cmp_ID=@Cmp_ID AND I.Increment_Effective_Date BETWEEN @FROM_DATE AND @To_Date -- Deepal Uncomment the above line and comment this line to check bug 22261 DATE :- 29082022
			
	UPDATE I SET ROW_ID = QRY.ROW_ID 
		FROM #ALL_INCREMENT I INNER JOIN
			(SELECT ROW_NUMBER()OVER(PARTITION BY EMP_ID ORDER BY EMP_ID ASC, INCREMENT_EFF_DATE ASC) ROW_ID, EMP_ID,INCREMENT_EFF_DATE 
				FROM #ALL_INCREMENT) QRY ON QRY.EMP_ID = I.EMP_ID AND QRY.INCREMENT_EFF_DATE = I.INCREMENT_EFF_DATE

		
    
    CREATE TABLE #Month_CTE(ROW_ID NUMERIC,For_Date datetime PRIMARY KEY);
    
    INSERT INTO #Month_CTE (For_Date)
    SELECT  DATEADD(d, ROW_ID, @Start)
    FROM    (SELECT (ROW_NUMBER() OVER (ORDER BY OBJECT_ID) -1) AS ROW_ID
             FROM sys.objects) T
    WHERE   DATEADD(d, ROW_ID, @Start) <= @To_Date 
    
    Update  M
    SET     ROW_ID = T.ROW_ID
    FROM    #Month_CTE M INNER JOIN 
            (SELECT ROW_NUMBER() over (PARTITION BY Year(For_Date), MOnth(For_Date), DATENAME(dw,For_Date) ORDER BY For_Date,DATENAME(dw,For_Date)) AS ROW_ID, For_Date
             FROM #Month_CTE T) T on M.For_Date=T.For_Date
    
    
    DECLARE @Pre_Emp numeric
    SET @Pre_Emp = 0;
    
    DECLARE @Join_Date DATETIME;
    DECLARE @Left_Date DATETIME;
    
                    
    SELECT  row_number() over(partition by emp_id order by emp_id, for_date) ROW_ID, Emp_id,For_Date As For_Date,Weekoff_Day,Alt_W_Full_Day_cont,Alt_w_Name , WeekOffOddEven
    INTO    #HW                 
    FROM    (SELECT *           
                From    (
                            Select  WA.Emp_id, For_Date,Weekoff_Day,Alt_W_Full_Day_cont,Alt_w_Name  ,WeekOffOddEven
                            from    dbo.T0100_WEEKOFF_ADJ WA WITH (NOLOCK)  INNER JOIN #EMP_CONS E ON WA.Emp_ID=E.EMP_ID
                            where   Weekoff_Day <> 'N' and cmp_id=@Cmp_Id and 
                                    For_Date = (
                                                    SELECT  MAX(for_Date) 
                                                    FROM    dbo.T0100_WEEKOFF_ADJ  WITH (NOLOCK) 
                                                    WHERE   Emp_ID = WA.Emp_ID and for_Date <= @To_Date_Actual 
                                                )   
							UNION ALL

                            Select  WA.Emp_id, For_Date,Weekoff_Day,Alt_W_Full_Day_cont,Alt_w_Name ,WeekOffOddEven  --- Added union all by Hardik 08/06/2020 for Punishka, Compoff Issue.. Change Weekoff from 01-06-2020 but weekoff showing wrong for 2019 years also.
                            from    dbo.T0100_WEEKOFF_ADJ WA WITH (NOLOCK)  INNER JOIN #EMP_CONS E ON WA.Emp_ID=E.EMP_ID
                            where   Weekoff_Day <> 'N' and cmp_id=@Cmp_Id and 
                                    For_Date = (
                                                    SELECT  MAX(for_Date) 
                                                    FROM    dbo.T0100_WEEKOFF_ADJ  WITH (NOLOCK) 
                                                    WHERE   Emp_ID = WA.Emp_ID and for_Date <= @From_Date_Actual 
                                                )   

							UNION ALL
								Select  WA.Emp_ID,For_Date,Weekoff_Day,Alt_W_Full_Day_cont,Alt_w_Name  ,WeekOffOddEven	
								FROM    dbo.T0100_WEEKOFF_ADJ WA WITH (NOLOCK)  INNER JOIN #EMP_CONS E ON WA.Emp_ID=E.EMP_ID
								WHERE   Weekoff_Day <> 'N' and cmp_id=@Cmp_Id
										And For_Date >= @From_Date and For_Date <= @To_Date) Qry
            ) T         
            
    DELETE  C
    FROM    #HW C
            INNER JOIN #HW P ON C.ROW_ID = (P.ROW_ID+1) AND C.EMP_ID=P.EMP_ID
    WHERE   C.WeekOff_Day = P.WeekOff_Day AND C.Alt_W_Full_Day_cont = P.Alt_W_Full_Day_cont AND C.Alt_W_Name=P.Alt_W_Name

	-- Added condition by Hardik 26/11/2019 for Iconic as above delete query is deleting between rows so Row_Id got missing between and below query was going wrong so again assign row_id
	Update #HW Set Row_id= Row_Id_New
	From #HW H Inner Join
		(Select row_number() over(partition by emp_id order by emp_id, for_date) Row_Id_New,Emp_Id, For_Date From #HW) Qry On H.Emp_ID = Qry.Emp_ID And H.For_Date = Qry.For_Date
    

	

    DECLARE @IS_LAST_REC BIT;
  

    INSERT  INTO #EMP_WEEKOFF(Row_ID,Emp_ID,For_Date,Weekoff_day,W_Day,Is_Cancel)
    SELECT  D.ROW_ID,EC.EMP_ID, FOR_DATE, DATENAME(WEEKDAY, FOR_DATE), 1, 0
    FROM    #EMP_CONS EC CROSS JOIN #Month_CTE D
            --INNER JOIN T0080_EMP_MASTER EM ON EC.Emp_ID=EM.Emp_ID AND D.FOR_DATE BETWEEN EM.Date_Of_Join AND IsNull(EM.Emp_Left_Date, D.For_Date) /*Mid Joining Mid Left Case will not work in Prorata Salary if you uncomment this line*/
    WHERE   EXISTS(SELECT 1 FROM #HW WHERE EMP_ID=EC.EMP_ID)
    
	


    SELECT  ROW_NUMBER() OVER(Partition By Emp_ID ORDER BY Emp_ID, From_Date) As Row_ID, *
    INTO    #EMP_WEEKOFF_SLAB
    FROM    (SELECT isNull(hw1.emp_id, hw2.Emp_id) Emp_ID,
                    IsNull(hw2.For_Date, @From_date) From_Date,IsNull(hw1.For_Date-1, @To_Date) As To_Date, IsNull(hw2.WeekOff_Day, hw1.WeekOff_Day) WeekOff_Day, 
                    IsNull(hw2.Alt_W_Full_Day_Cont, hw1.Alt_W_Full_Day_Cont) Alt_W_Full_Day_Cont, IsNull(hw2.Alt_W_Name, hw1.Alt_W_Name) Alt_W_Name
            FROM    #hw hw1 
                    FULL OUTER JOIN #hw hw2 on hw1.Emp_ID=hw2.Emp_ID AND hw1.Row_ID=hw2.Row_id+1
            )T
    
    
    DELETE  W 
    FROM    #EMP_WEEKOFF W 
    WHERE   FOR_DATE  NOT BETWEEN @FROM_DATE AND @TO_DATE
    
    
    
    DELETE  W 
    FROM    #EMP_WEEKOFF W 
            INNER JOIN #EMP_WEEKOFF_SLAB WS ON W.EMP_ID=WS.EMP_ID AND W.FOR_DATE BETWEEN WS.FROM_DATE AND WS.TO_DATE 
                        --AND W.WeekOff_Day NOT IN (WS.WeekOff_Day, WS.Alt_W_Name) 
                        AND NOT (CHARINDEX(W.WeekOff_Day, WS.WeekOff_Day) > 0 OR CHARINDEX(W.WeekOff_Day, WS.Alt_W_Name) > 0)
    
    
    --DELETE  w
    --FROM    #EMP_WEEKOFF W 
    --        INNER JOIN #EMP_WEEKOFF_SLAB WS ON W.EMP_ID=WS.EMP_ID AND W.FOR_DATE BETWEEN WS.FROM_DATE AND WS.TO_DATE 
    --                    --AND W.WeekOff_Day = WS.Alt_W_Name
    --                    AND CHARINDEX(W.WeekOff_Day, WS.Alt_W_Name) > 0
    --                    AND CHARINDEX('#' + CAST(W.ROW_ID AS VARCHAR(10)) + '#', '#' + WS.Alt_W_Full_Day_cont + '#') = 0
    --                    --AND LEN(Alt_W_Full_Day_cont) > 0        --Commented by Hardik 06/05/2020 for Wonder as if Alt_W_Full_Day_Count is blank then those days not deleting from table
		
		
		--Modified by Nimesh on 04-April-2016
		/**CANCEL WEEKOFF FROM ROSTER**/
		--Added Query here to take Cancel WeekOff Effect for Sandwitch Policy
		/*Do not consider the Roster Data (Only Assigned WeekOff)
		  This scenario is used to fetch the Assigned WeekOff Detail only in T0100_EMP_WEEKOFFADJ table.
		  Nimesh : 02-Feb-2018
		*/
	
		--ADDED BY DEEPAL ON 11-OCT-2023

	DECLARE @SETTINGVAL AS NUMERIC
	SELECT @SETTINGVAL = ISNULL(Setting_Value,0) FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Weekoff Odd Even.'

	
	IF @SETTINGVAL = 1
	BEGIN
			if (Select weekOffOddEven from #HW  H inner join #EMP_CONS E on H.Emp_ID = E.EMP_ID) = 'Odd'
			Begin 
				Delete FROM #EMP_WEEKOFF 
				where For_date not in (select WeekOffDate from T0010_Yearly_Odd_Even_WeekOff where WeekOffDate between @From_Date_Actual and @To_Date_Actual and SrNo % 2 <> 0)
			END 
			else 
				Delete FROM #EMP_WEEKOFF 
				where For_date not in (select WeekOffDate from T0010_Yearly_Odd_Even_WeekOff where WeekOffDate between @From_Date_Actual and @To_Date_Actual and SrNo % 2 = 0)

			--select * from #EMP_WEEKOFF

	END
	ELSE
	BEGIN
			
			DELETE  w
		    FROM    #EMP_WEEKOFF W 
            INNER JOIN #EMP_WEEKOFF_SLAB WS ON W.EMP_ID=WS.EMP_ID AND W.FOR_DATE BETWEEN WS.FROM_DATE AND WS.TO_DATE 
                        --AND W.WeekOff_Day = WS.Alt_W_Name
                        AND CHARINDEX(W.WeekOff_Day, WS.Alt_W_Name) > 0
                        AND CHARINDEX('#' + CAST(W.ROW_ID AS VARCHAR(10)) + '#', '#' + WS.Alt_W_Full_Day_cont + '#') = 0
                        --AND LEN(Alt_W_Full_Day_cont) > 0        --Commented by Hardik 06/05/2020 for Wonder as if Alt_W_Full_Day_Count is blank then those days not deleting from table
	
	END
	
    IF @All_Weekoff = 1 
        BEGIN 
		
            DELETE  E 
            FROM    #Emp_WeekOff E INNER JOIN T0100_WEEKOFF_ROSTER R WITH (NOLOCK)  ON R.For_date=E.For_Date AND E.Emp_ID=R.Emp_id 
            WHERE   R.is_Cancel_WO=1  
            
			
            --INSERT  INTO #Emp_WeekOff 
			INSERT  INTO #EMP_WEEKOFF(Row_ID,Emp_ID,For_Date,Weekoff_day,W_Day,Is_Cancel)
            SELECT  0, R.EMP_ID, R.FOR_DATE,DATENAME(dw, R.FOR_DATE),1, 0
            FROM    T0100_WEEKOFF_ROSTER R  WITH (NOLOCK) INNER JOIN #EMP_CONS T on R.Emp_id=T.Emp_ID
            WHERE   NOT EXISTS(SELECT 1 FROM #Emp_WeekOff E WHERE E.Emp_ID=R.Emp_id AND E.For_Date=R.For_date)
                    AND R.is_Cancel_WO=0 and For_date between @from_date and @To_date
        END
    /**CANCEL WEEKOFF FROM ROSTER**/

	
    
    --GETTING WEEKOFF DATES BY EMPLOYEE ID
    INSERT INTO #Emp_WeekOff_Holiday (Emp_ID,WeekOffDate,WeekOffCount)
    SELECT  W1.Emp_ID,
                STUFF((SELECT   ';' + CAST(W.For_Date AS VARCHAR(11)) AS FOR_DATE FROM  #Emp_WeekOff W
                       WHERE    W.Emp_ID = W1.Emp_ID AND W_Day <> 0 FOR XML PATH('')), 1,1, '') As WeekOff,
            Sum(W_Day) As WeekOffCount              
    FROM    #Emp_WeekOff W1 
    Where (For_Date BETWEEN @From_Date AND @To_Date) ---Added by Nilesh on 26022016 after Comfirmation of Hardik bhai For week off filteration from date to to date
    GROUP BY W1.Emp_ID                  

    --Added by Hardik 08/12/2016 as if Cutoff Salary and From date-To date pass 26th to 31st and if no weekoff is there then it will insert only emp id in table
    INSERT INTO #Emp_WeekOff_Holiday (Emp_ID)
    Select Emp_Id From #EMP_CONS EC Where not EXISTS(Select 1 From #Emp_WeekOff_Holiday EWH Where EC.EMP_ID = EWH.Emp_Id)
    

	

    CREATE TABLE #DATES(FOR_DATE DATETIME, FOR_MD numeric);
    CREATE UNIQUE CLUSTERED INDEX IX_DATES_H_FORDATE ON #DATES(For_Date, FOR_MD);

    INSERT INTO #DATES
    SELECT FOR_DATE, CAST(RIGHT(CONVERT(VARCHAR(10), T.FOR_DATE, 112), 4) AS numeric) AS FOR_MD     
    FROM (SELECT DATEADD(d, ROW_NUMBER() OVER(ORDER BY object_id) -1, @FROM_DATE ) AS FOR_DATE FROM sys.all_objects) T 
    WHERE FOR_DATE <= @TO_DATE

    
    --GETTING OPTIONAL HOLIDAY DATES BY EMPLOYEE ID
    CREATE TABLE #OP_HOLIDAY(EMP_ID numeric, H_From_Date Datetime,H_To_Date datetime,Is_Fix char(1),Is_Half_Day tinyint,Is_P_Comp tinyint, FOR_DATE datetime,Is_UnPaid TinyInt);
    
    INSERT  INTO #OP_HOLIDAY
    SELECT  T.Emp_ID,H_From_Date, T.H_To_Date,T.Is_Fix,T.Is_Half_Day,T.Is_P_Comp,T.OP_HOLIDAY,Is_Unpaid_Holiday
    FROM    (
                --SELECT    DISTINCT  CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@TO_DATE) THEN CAST(YEAR(@FROM_DATE)AS VARCHAR(4)) ELSE CAST(YEAR(@TO_DATE)AS VARCHAR(4)) END AS DATETIME) AS OP_HOLIDAY,
                SELECT  DISTINCT D.FOR_DATE OP_HOLIDAY,
                        HA.Emp_ID, H.H_From_Date,H.H_To_Date, h.Is_Fix, h.Is_Half As Is_Half_Day, H.Is_P_Comp,H.Is_Unpaid_Holiday
                FROM    T0040_HOLIDAY_MASTER H  WITH (NOLOCK) INNER JOIN T0120_OP_HOLIDAY_APPROVAL HA WITH (NOLOCK)  ON H.Hday_ID=HA.HDay_ID 
                        INNER JOIN #EMP_CONS EC ON HA.Emp_ID=EC.EMP_ID
                        INNER JOIN #DATES D ON D.FOR_DATE BETWEEN H.H_From_Date AND H_To_Date
                WHERE   H.CMP_ID=@Cmp_ID AND HA.Op_Holiday_Apr_Status='A' And ISNULL(H.Is_P_Comp,0) = 0                             
                        AND H.H_FROM_DATE BETWEEN @From_Date AND @To_Date
            ) T

    --Creating #HDATES temp table to collect all holidays in a single table
    IF OBJECT_ID('tempdb..#HDATES') IS NULL
    BEGIN
        CREATE TABLE #HDATES (Branch_ID numeric, H_From_Date DATETIME, H_To_Date DATETIME, FOR_DATE datetime, IS_FIX CHAR(1), Is_Half_Day tinyint , Is_P_Comp tinyint, Is_Opt bit,Is_UnPaid TinyInt);
        CREATE UNIQUE CLUSTERED INDEX IX_HDATES_H_BRANCHID_FOR_DATE ON #HDATES(BRANCH_ID, FOR_DATE);
    END
    ELSE
        TRUNCATE TABLE #HDATES
    	
    --INSERT INTO   #HDATES
    SELECT  DISTINCT ROW_NUMBER() OVER(ORDER BY H.Branch_ID, H.FOR_DATE) AS ROW_ID, H.Branch_ID, H.H_From_Date, H.H_To_Date , H.FOR_DATE, H.Is_Fix, H.Is_Half_Day, H.Is_P_Comp,Is_Opt, Is_Unpaid_Holiday As Is_UnPaid
    INTO #TMP_HOLIDAY
    FROM (
            SELECT  H.Branch_ID, H.H_From_Date, H.H_To_Date , D.FOR_DATE, H.Is_Fix, H.Is_Half_Day, H.Is_P_Comp,0 As Is_Opt,Is_Unpaid_Holiday
            FROM    (
                        SELECT  CAST(RIGHT(CONVERT(VARCHAR(10), H_From_Date, 112), 4) AS NUMERIC) AS FROM_MD,
                                CAST(RIGHT(CONVERT(VARCHAR(10), H_To_Date, 112), 4) AS NUMERIC) AS TO_MD,
                                H.Branch_ID, H.H_From_Date, H.H_To_Date,Is_Fix Collate SQL_Latin1_General_CP1_CI_AS as Is_Fix, H.Is_P_Comp, H.Is_Half As Is_Half_Day,H.Is_Unpaid_Holiday
                        FROM    T0040_HOLIDAY_MASTER H WITH (NOLOCK)  --INNER JOIN #EMP_BRANCH B ON H.Branch_ID=B.BRANCH_ID OR H.Branch_ID IS NULL
                        WHERE   H.cmp_Id=@Cmp_ID AND IsNull(H.Is_Optional, 0)=0  And ISNULL(H.Is_P_Comp,0) = 0
                    ) H
                    INNER JOIN #DATES D ON (D.FOR_DATE BETWEEN H.H_From_Date AND H.H_To_Date AND H.Is_Fix='N') OR (D.For_MD BETWEEN h.FROM_MD AND H.TO_MD AND H.Is_Fix='Y')     
        ) H
		--select * from #TMP_HOLIDAY where Branch_ID=906
    
    -- If more than one holiday is created for same date (holiday can be repeated annually).

	


    INSERT  INTO #HDATES
    SELECT  Branch_ID, H_From_Date, H_To_Date , FOR_DATE, Is_Fix, Is_Half_Day, Is_P_Comp,Is_Opt,Is_UnPaid
    FROM    #TMP_HOLIDAY T
    WHERE   ROW_ID = (SELECT TOP 1 ROW_ID FROM #TMP_HOLIDAY T1 WHERE T.FOR_DATE=T1.FOR_DATE AND (T.BRANCH_ID=T1.BRANCH_ID OR T1.BRANCH_ID IS NULL))
	
	
    --GETTING HOLIDAY DATES BY EMPLOYEE ID
    UPDATE  #Emp_WeekOff_Holiday
    SET     HolidayDate = REPLACE(REPLACE((
                                    SELECT  ';' + CAST(W.FOR_DATE AS VARCHAR(11)) AS FOR_DATE FROM  #HDATES W
                                    WHERE   (W.Branch_ID = E.BRANCH_ID OR W.Branch_ID IS NULL) 
                                            AND Is_Half_Day=0 AND Is_Opt=0 FOR XML PATH('')
                                ), '<FOR_DATE>', ''), '</FOR_DATE>', ''),
            HalfHolidayDate = REPLACE(REPLACE((
                                    SELECT  ';' + CAST(W.FOR_DATE AS VARCHAR(11)) AS FOR_DATE FROM  #HDATES W
                                    WHERE   (W.Branch_ID = E.BRANCH_ID OR W.Branch_ID IS NULL) 
                                            AND Is_Half_Day=1 AND Is_Opt=0 FOR XML PATH('')
                                ), '<FOR_DATE>', ''), '</FOR_DATE>', ''),
            OptHolidayDate = REPLACE(REPLACE((
                                    SELECT  ';' + CAST(W.FOR_DATE AS VARCHAR(11)) AS FOR_DATE FROM  #OP_HOLIDAY W   --Replaced #HDATES to #OP_HOLIDAY by Nimesh on 04-April-2016
                                    WHERE   (W.Emp_ID = E.Emp_ID) FOR XML PATH('')
                                ), '<FOR_DATE>', ''), '</FOR_DATE>', '')
    FROM    #Emp_WeekOff_Holiday HW INNER JOIN #EMP_CONS E ON HW.Emp_ID=E.EMP_ID

    UPDATE  #Emp_WeekOff_Holiday
    SET     HolidayCount = H.FullCount,
            HalfHolidayCount = H.HalfCount
    FROM    (SELECT Emp_ID, SUM(CASE    WHEN Is_Half_Day=1 AND Is_Opt=0 THEN 0.5 ELSE 0 END) AS HalfCount, 
                    SUM(CASE    WHEN Is_Half_Day=0 AND Is_Opt=0 THEN 1 ELSE 0 END) AS FullCount
            FROM    #HDATES H INNER JOIN #EMP_CONS E ON (H.Branch_ID=E.BRANCH_ID OR H.Branch_ID IS NULL)
            GROUP BY EMP_ID) H 
    WHERE   #Emp_WeekOff_Holiday.Emp_ID=H.EMP_ID
    
    --Query Seperated by Nimesh on 04-April-2016 (Optional Holiday Count should be calculated from #OP_HOLIDAY table)
    UPDATE  #Emp_WeekOff_Holiday
    SET     OptHolidayCount = H.OptCount
    FROM    (SELECT H.Emp_ID,COUNT(1) AS OptCount
            FROM    #OP_HOLIDAY H INNER JOIN #EMP_CONS E ON H.EMP_ID=E.EMP_ID
            GROUP BY H.EMP_ID) H 
    WHERE   #Emp_WeekOff_Holiday.Emp_ID=H.EMP_ID
    /*                  
    UPDATE  #Emp_WeekOff_Holiday
    SET     Holidays = REPLACE(REPLACE((
                                    SELECT  ';' + CAST(W.For_Date AS VARCHAR(11)) AS FOR_DATE FROM  #OP_HOLIDAY W
                                    WHERE   W.Emp_ID = HW.Emp_ID  FOR XML PATH('')
                                ), '<FOR_DATE>', ''), '</FOR_DATE>', '')
    FROM    #Emp_WeekOff_Holiday HW INNER JOIN #OP_HOLIDAY H ON HW.Emp_ID=H.EMP_ID
    */
    
    -- select * from #emp_cons
	--insert into #Emp_cons
	--select 23253,554,17964

    --select * from #TMP_HOLIDAY
	

--if OBJECT_ID('tempdb..#debug') is not null
--begin
--select * from #ALL_INCREMENT ORDER BY EMP_ID,ROW_ID
--select * from #HDATES where branch_id in (554,906)
--select EMP_ID from #ALL_INCREMENT GROUP BY EMP_ID HAVING COUNT(EMP_ID)>1

--	SELECT  DISTINCT E.EMP_ID, H.FOR_DATE,Is_Half_Day,Is_P_Comp,E.INCREMENT_EFF_DATE,E1.INCREMENT_EFF_DATE-1
--        --FROM    #HDATES H INNER JOIN #EMP_CONS E ON H.Branch_ID=E.BRANCH_ID OR H.Branch_ID IS NULL
--		FROM    #HDATES H INNER JOIN #ALL_INCREMENT E ON (H.Branch_ID=E.BRANCH_ID OR H.Branch_ID IS NULL) AND ROW_ID=1
--			LEFT OUTER JOIN #ALL_INCREMENT E1 ON E.EMP_ID=E1.EMP_ID AND E1.ROW_ID = 2
--		--where H.FOR_DATE between E.INCREMENT_EFF_DATE and E1.INCREMENT_EFF_DATE -1

--end
 


	
    IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NOT NULL
    BEGIN        
	
        INSERT INTO #EMP_HOLIDAY(#EMP_CONS.EMP_ID,FOR_DATE,Is_Half,Is_P_Comp)
        SELECT  DISTINCT E.EMP_ID, H.FOR_DATE,Is_Half_Day,Is_P_Comp
        FROM    #HDATES H INNER JOIN #EMP_CONS E ON H.Branch_ID=E.BRANCH_ID OR H.Branch_ID IS NULL
		WHERE EMP_ID NOT IN (SELECT EMP_ID from #ALL_INCREMENT GROUP BY EMP_ID HAVING COUNT(EMP_ID)>1)
        UNION    --Union Added by Nimesh on 04-April-2016 (Optional Holiday is seperated so, we need to write seperate query to insert in #EMP_HOLIDAY table) 
        SELECT  DISTINCT E.EMP_ID, H.FOR_DATE,Is_Half_Day,Is_P_Comp
        FROM    #OP_HOLIDAY H INNER JOIN #EMP_CONS E ON H.Emp_ID=E.Emp_ID

		DECLARE @ROW_ID_CUR NUMERIC
		DECLARE @EMP_ID_CUR NUMERIC
		DECLARE @BRANCH_ID_CUR NUMERIC
		DECLARE @INCREMENT_EFF_DATE_CUR DATETIME
		DECLARE @INCREMENT_TO_DATE DATETIME
	
		
			--select * from #EMP_HOLIDAY
			--return

		DECLARE CURHOLIDAY CURSOR FAST_FORWARD FOR
			SELECT ROW_ID, EMP_ID,BRANCH_ID,INCREMENT_EFF_DATE 
			FROM #ALL_INCREMENT 
			WHERE EMP_ID IN (SELECT EMP_ID FROM #ALL_INCREMENT GROUP BY EMP_ID HAVING COUNT(EMP_ID) > 1)
		    ORDER BY EMP_ID,INCREMENT_EFF_DATE 
		OPEN CURHOLIDAY
        FETCH NEXT FROM CURHOLIDAY INTO @ROW_ID_CUR, @EMP_ID_CUR, @BRANCH_ID_CUR, @INCREMENT_EFF_DATE_CUR
        WHILE @@FETCH_STATUS = 0
            BEGIN
			
				IF EXISTS (SELECT 1 FROM #ALL_INCREMENT WHERE ROW_ID = @ROW_ID_CUR + 1 AND EMP_ID =@EMP_ID_CUR)
					BEGIN
						SELECT @INCREMENT_TO_DATE = INCREMENT_EFF_DATE - 1 
						FROM #ALL_INCREMENT WHERE ROW_ID = @ROW_ID_CUR + 1 AND EMP_ID =@EMP_ID_CUR
					END
				ELSE
					BEGIN
						SET @INCREMENT_TO_DATE = @To_Date_Actual
					END
					
					INSERT INTO #EMP_HOLIDAY(#EMP_CONS.EMP_ID,FOR_DATE,Is_Half,Is_P_Comp)
					SELECT  DISTINCT E.EMP_ID, H.FOR_DATE,Is_Half_Day,Is_P_Comp
					FROM    #HDATES H INNER JOIN #ALL_INCREMENT E ON Isnull(H.Branch_ID,E.BRANCH_ID) = E.BRANCH_ID
					WHERE EMP_ID = @EMP_ID_CUR AND H.FOR_DATE BETWEEN @INCREMENT_EFF_DATE_CUR AND @INCREMENT_TO_DATE
						AND (H.Branch_ID IS NULL OR H.Branch_ID = @BRANCH_ID_CUR)

					IF OBJECT_ID('tempdb..#HW_DETAIL') IS NOT NULL
						BEGIN

							INSERT INTO #HW_DETAIL(EMP_ID,FOR_DATE,Is_UnPaid)
							SELECT  DISTINCT E.EMP_ID, H.FOR_DATE,Is_UnPaid
							FROM    #HDATES H INNER JOIN #ALL_INCREMENT E ON H.Branch_ID = E.BRANCH_ID
							WHERE EMP_ID = @EMP_ID_CUR AND H.FOR_DATE BETWEEN @INCREMENT_EFF_DATE_CUR AND @INCREMENT_TO_DATE
								AND (H.Branch_ID IS NULL OR H.Branch_ID = @BRANCH_ID_CUR)
						END


				FETCH NEXT FROM CURHOLIDAY INTO @ROW_ID_CUR, @EMP_ID_CUR, @BRANCH_ID_CUR, @INCREMENT_EFF_DATE_CUR
			END
		CLOSE CURHOLIDAY
		DEALLOCATE CURHOLIDAY
		
    END
	
	
    IF OBJECT_ID('tempdb..#HW_DETAIL') IS NOT NULL
        BEGIN
		
            TRUNCATE TABLE #HW_DETAIL

            INSERT INTO #HW_DETAIL(EMP_ID,FOR_DATE,Is_UnPaid)
            SELECT  DISTINCT E.EMP_ID, H.FOR_DATE,Is_UnPaid
            FROM    #HDATES H INNER JOIN #EMP_CONS E ON H.Branch_ID=E.BRANCH_ID OR H.Branch_ID IS NULL
			WHERE EMP_ID NOT IN (SELECT EMP_ID from #ALL_INCREMENT GROUP BY EMP_ID HAVING COUNT(EMP_ID)>1)
            UNION   --Union Added by Nimesh on 04-April-2016 (Optional Holiday is seperated so, we need to write seperate query to insert in #EMP_HOLIDAY table) 
            SELECT  DISTINCT E.EMP_ID, H.FOR_DATE,Is_UnPaid
            FROM    #OP_HOLIDAY H INNER JOIN #EMP_CONS E ON H.Emp_ID=E.Emp_ID
        END


    IF OBJECT_ID('tempdb..#BRANCH_HOLIDAY') IS NULL
    BEGIN
        CREATE TABLE #BRANCH_HOLIDAY
        (
            Branch_ID       NUMERIC,
            HOLIDAY_DATE    Varchar(Max)
        )
        CREATE UNIQUE CLUSTERED INDEX IX_BRANCH_HOLIDAY_H_BRANCHID ON #BRANCH_HOLIDAY(BRANCH_ID);
    END
    
    INSERT INTO #BRANCH_HOLIDAY
    SELECT  H1.Branch_ID,
                REPLACE(REPLACE((
                                    SELECT  ';' + CAST(FOR_DATE AS VARCHAR(11)) AS FOR_DATE FROM    #HDATES H                   
                                    WHERE   H.BRANCH_ID = H1.BRANCH_ID OR H.BRANCH_ID IS NULL FOR XML PATH('')
                                ), '<FOR_DATE>', ''), '</FOR_DATE>', '')  AS HOLIDAY_DATE
    FROM    #HDATES H1
    GROUP BY H1.Branch_ID


	 

	 