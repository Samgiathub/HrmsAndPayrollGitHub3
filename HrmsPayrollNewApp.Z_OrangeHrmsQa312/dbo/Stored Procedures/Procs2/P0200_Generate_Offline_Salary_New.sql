

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_Generate_Offline_Salary_New]
    @cmp_id NUMERIC ,
    @from_date DATETIME ,
    @to_date DATETIME ,
    @is_manual NUMERIC = 1 ,
    @branch_id NUMERIC = 0 ,
    @Cat_ID NUMERIC = 0 ,
    @grd_id NUMERIC = 0 ,
    @Type_id NUMERIC = 0 ,
    @dept_ID NUMERIC = 0 ,
    @desig_ID NUMERIC = 0 ,
    @emp_id NUMERIC = 0 ,
    @Salary_Cycle_id NUMERIC = 0 ,
    @Branch_Constraint NVARCHAR(1000) = '' ,
    @Segment_ID NUMERIC = 0 ,
    @Vertical NUMERIC = 0 ,
    @SubVertical NUMERIC = 0 ,
    @SubBranch NUMERIC = 0 ,
    @ID VARCHAR(100) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    BEGIN
        --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        

		/*************************************************************************
		Added by Nimesh: 02/Oct/2017
		(To get holiday/weekoff data for all employees in seperate table)
		*************************************************************************/
		CREATE TABLE #EMP_HOLIDAY_SAL(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_SAL_EMPID_FORDATE ON #EMP_HOLIDAY_SAL(EMP_ID, FOR_DATE);
		CREATE TABLE #EMP_WEEKOFF_SAL
		(
			Row_ID			NUMERIC,
			Emp_ID			NUMERIC,
			--Cmp_ID			NUMERIC,
			For_Date		DATETIME,
			Weekoff_day		VARCHAR(10),
			W_Day			numeric(4,1),
			Is_Cancel		BIT
		)
		CREATE CLUSTERED INDEX IX_Emp_WeekOff_SAL_EmpID_ForDate ON #EMP_WEEKOFF_SAL(Emp_ID, For_Date)		

		CREATE TABLE #Emp_WeekOff_Holiday_SAL
		(
			Emp_ID				NUMERIC,
			WeekOffDate			VARCHAR(Max),
			WeekOffCount		NUMERIC(4,1),
			HolidayDate			VARCHAR(Max),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		VARCHAR(Max),
			HalfHolidayCount	NUMERIC(4,1),
			OptHolidayDate		VARCHAR(Max),
			OptHolidayCount		NUMERIC(4,1)
		);

		CREATE TABLE #EMP_HW_CONS_SAL
		(
			Emp_ID				NUMERIC,
			WeekOffDate			Varchar(Max),
			WeekOffCount		NUMERIC(4,1),
			CancelWeekOff		Varchar(Max),
			CancelWeekOffCount	NUMERIC(4,1),
			HolidayDate			Varchar(MAX),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		Varchar(MAX),
			HalfHolidayCount	NUMERIC(4,1),
			CancelHoliday		Varchar(Max),
			CancelHolidayCount	NUMERIC(4,1)
		);

		CREATE TABLE #HW_DETAIL_SAL(EMP_ID NUMERIC, FOR_DATE DATETIME, Is_UnPaid TinyInt);
		CREATE UNIQUE CLUSTERED INDEX IX_HW_DETAIL_SAL_EMPID_FORDATE ON #HW_DETAIL_SAL(EMP_ID, FOR_DATE);
		
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_SAL_EmpID ON #EMP_HW_CONS_SAL(Emp_ID)
 

        CREATE TABLE #Pre_Salary_Data_Exe
            (
              Row_ID NUMERIC(18, 0) ,
              Tran_id NUMERIC(18, 0) ,
              Type NVARCHAR(50) ,
              M_Sal_Tran_ID NVARCHAR(50) ,
              Emp_Id NUMERIC ,
              Cmp_ID NUMERIC ,
              Sal_Generate_Date NVARCHAR(50) ,
              Month_St_Date NVARCHAR(50) ,
              Month_End_Date NVARCHAR(50) ,
              Present_Days NUMERIC(18, 2) ,
              M_OT_Hours NUMERIC(18, 2) ,
              Areas_Amount NUMERIC(18, 2) ,
              M_IT_Tax NUMERIC(18, 2) ,
              Other_Dedu NUMERIC(18, 2) ,
              M_LOAN_AMOUNT NUMERIC ,
              M_ADV_AMOUNT NUMERIC ,
              IS_LOAN_DEDU NUMERIC ,
              Login_ID NUMERIC ,
              ErrRaise VARCHAR(100) ,
              Is_Negetive VARCHAR(1) ,
              Status VARCHAR(10) ,
              IT_M_ED_Cess_Amount NUMERIC(18, 2) ,
              IT_M_Surcharge_Amount NUMERIC(18, 2) ,
              Allo_On_Leave NUMERIC(18, 0) ,
              User_Id NUMERIC(18, 0) ,
              IP_Address VARCHAR(30) ,
              Is_processed TINYINT ,
              Batch_id VARCHAR(100),
              IS_Bond_DEDU BIT
            )
	
	
        CREATE TABLE #Pre_Salary_Data_monthly_Exe
            (
			  Row_ID NUMERIC(18, 0) ,
              Tran_id NUMERIC(18, 0) ,
              [Type] NVARCHAR(50) ,
              M_Sal_Tran_ID NVARCHAR(50) ,
              Emp_Id NUMERIC ,
              Cmp_ID NUMERIC ,
              Sal_Generate_Date NVARCHAR(50) ,
              Month_St_Date NVARCHAR(50) ,
              Month_End_Date NVARCHAR(50) ,
              M_OT_Hours NUMERIC(18, 2) ,
              Areas_Amount NUMERIC(18, 2) ,
              M_IT_Tax NUMERIC(18, 2) ,
              Other_Dedu NUMERIC(18, 2) ,
              M_LOAN_AMOUNT NUMERIC ,
              M_ADV_AMOUNT NUMERIC ,
              IS_LOAN_DEDU NUMERIC ,
              Login_ID NUMERIC ,
              ErrRaise VARCHAR(100) ,
              Is_Negetive VARCHAR(1) ,
              [Status] VARCHAR(10) ,
              IT_M_ED_Cess_Amount NUMERIC(18, 2) ,
              IT_M_Surcharge_Amount NUMERIC(18, 2) ,
              Allo_On_Leave NUMERIC(18, 0) ,
              W_OT_Hours NUMERIC(18, 2) ,
              H_OT_Hours NUMERIC(18, 2) ,
              [User_Id] NUMERIC(18, 0) ,
              IP_Address VARCHAR(30) ,
              Is_processed TINYINT,
              Batch_id VARCHAR(100),
              IS_Bond_DEDU BIT
            ) 
	
        DECLARE @cur_Tran_id AS NUMERIC(18, 0)
        DECLARE @cur_Type AS NVARCHAR(50)
        DECLARE @cur_M_Sal_Tran_ID AS NVARCHAR(50) 
        DECLARE @cur_Emp_Id AS NUMERIC      
        DECLARE @cur_Cmp_ID AS NUMERIC      
        DECLARE @cur_Sal_Generate_Date AS NVARCHAR(50) 
        DECLARE @cur_Month_St_Date AS NVARCHAR(50)
        DECLARE @cur_Month_End_Date AS NVARCHAR(50)
        DECLARE @cur_Present_Days AS NUMERIC(18, 2)      
        DECLARE @cur_M_OT_Hours AS NUMERIC(18, 2)      
        DECLARE @cur_Areas_Amount AS NUMERIC(18, 2)       
        DECLARE @cur_M_IT_Tax AS NUMERIC(18, 2)      
        DECLARE @cur_Other_Dedu AS NUMERIC(18, 2)      
        DECLARE @cur_M_LOAN_AMOUNT AS NUMERIC      
        DECLARE @cur_M_ADV_AMOUNT AS NUMERIC      
        DECLARE @cur_IS_LOAN_DEDU AS NUMERIC      
        DECLARE @cur_Login_ID AS NUMERIC    
        DECLARE @cur_ErrRaise AS VARCHAR(100) 
        DECLARE @cur_Is_Negetive AS VARCHAR(1)  
        DECLARE @cur_Status AS VARCHAR(10)  
        DECLARE @cur_IT_M_ED_Cess_Amount AS NUMERIC(18, 2)
        DECLARE @cur_IT_M_Surcharge_Amount AS NUMERIC(18, 2)
        DECLARE @cur_Allo_On_Leave AS NUMERIC(18, 0) 
        DECLARE @cur_User_Id AS NUMERIC(18, 0) 	
        DECLARE @cur_IP_Address AS VARCHAR(30)	  
        DECLARE @Cur_Is_processed AS TINYINT
        DECLARE @cur_IS_Bond_DEDU AS BIT 
	
	
        DECLARE @cur_mon_Tran_id AS NUMERIC(18, 0)
        DECLARE @Cur_mon_Type AS NVARCHAR(50)
        DECLARE @Cur_mon_M_Sal_Tran_ID AS NVARCHAR(50) 
        DECLARE @Cur_mon_Emp_Id AS NUMERIC      
        DECLARE @Cur_mon_Cmp_ID AS NUMERIC      
        DECLARE @Cur_mon_Sal_Generate_Date AS NVARCHAR(50) 
        DECLARE @Cur_mon_Month_St_Date AS NVARCHAR(50)
        DECLARE @Cur_mon_Month_End_Date AS NVARCHAR(50)
        DECLARE @Cur_mon_M_OT_Hours AS NUMERIC(18, 2)      
        DECLARE @Cur_mon_Areas_Amount AS NUMERIC(18, 2)       
        DECLARE @Cur_mon_M_IT_Tax AS NUMERIC(18, 2)      
        DECLARE @Cur_mon_Other_Dedu AS NUMERIC(18, 2)      
        DECLARE @Cur_mon_M_LOAN_AMOUNT AS NUMERIC      
        DECLARE @Cur_mon_M_ADV_AMOUNT AS NUMERIC      
        DECLARE @Cur_mon_IS_LOAN_DEDU AS NUMERIC      
        DECLARE @Cur_mon_Login_ID AS NUMERIC    
        DECLARE @Cur_mon_ErrRaise AS VARCHAR(100) 
        DECLARE @Cur_mon_Is_Negetive AS VARCHAR(1)  
        DECLARE @Cur_mon_Status AS VARCHAR(10)  
        DECLARE @Cur_mon_IT_M_ED_Cess_Amount AS NUMERIC(18, 2)
        DECLARE @Cur_mon_IT_M_Surcharge_Amount AS NUMERIC(18, 2)
        DECLARE @Cur_mon_Allo_On_Leave AS NUMERIC(18, 0) 
        DECLARE @Cur_mon_W_OT_Hours AS NUMERIC(18, 2)
        DECLARE @Cur_mon_H_OT_Hours AS NUMERIC(18, 2)
        DECLARE @Cur_mon_User_Id AS NUMERIC(18, 0) 	
        DECLARE @Cur_mon_IP_Address AS VARCHAR(30) 
        DECLARE @Cur_mon_Is_processed AS TINYINT
        DECLARE @Cur_mon_IS_Bond_DEDU AS BIT 
	
		
        DECLARE @Emp_cons_list AS VARCHAR(MAX)
        SET @Emp_cons_list = ''
	
	        
		   
	    DECLARE @wo_date VARCHAR(1000) 
        DECLARE @wo_count NUMERIC(12, 2)
        DECLARE @ho_date VARCHAR(1000) 
        DECLARE @ho_count NUMERIC(12, 2)
        DECLARE @wo_date_mid VARCHAR(1000)
        DECLARE @wo_count_mid NUMERIC(12, 2) 
	
        SET @wo_date = ''
        SET @wo_count = 0
        SET @ho_date = ''
        SET @ho_count = 0
        SET @wo_date_mid = ''
        SET @wo_count_mid = 0
	
        IF @is_manual = 1
            BEGIN
			
                INSERT  INTO #Pre_Salary_Data_Exe
                        SELECT  ROW_NUMBER() OVER ( ORDER BY Emp_ID DESC ) AS Row ,
                                *
                        FROM    dbo.t0200_Pre_Salary_Data WITH (NOLOCK)
                        WHERE   is_processed = 0
                                AND ISNULL(batch_id, '') = @ID
			
			
                SELECT  @Emp_cons_list = REPLACE(REPLACE(STUFF((SELECT
                                                              '#'
                                                              + QUOTENAME(CAST(Emp_ID AS VARCHAR(MAX)))
                                                              FROM
                                                              #Pre_Salary_Data_Exe
                                                              AS a
                                                              CROSS APPLY ( SELECT
                                                              'Emp_ID' col ,
                                                              1 so
                                                              ) c
                                                              GROUP BY a.Emp_ID
                                                              ORDER BY a.Emp_ID
                                                         FOR  XML
                                                              PATH('') ,
                                                              TYPE ).value('.',
                                                              'NVARCHAR(MAX)'),
                                                              1, 1, ''), '[',
                                                         ''), ']', '')
			
			                  		
					
                DECLARE @Count_emp AS NUMERIC
                DECLARE @Temp_emp_Id NUMERIC(18, 0)
                DECLARE @intFlag AS NUMERIC(18, 0)	
                SET @intFlag = 1
	  	  
                SELECT  @Count_emp = COUNT(row_ID)
                FROM    #Pre_Salary_Data_Exe 
				
                DECLARE @LogDesc NVARCHAR(MAX)
                DECLARE @Error NVARCHAR(MAX)
		
                SET @intFlag = 1
                WHILE ( @intFlag <= @Count_emp )
                    BEGIN
                        SET @LogDesc = ''
                        SET @Error = ''
				--		BEGIN TRY
						
                        SELECT  @cur_Tran_id = Tran_id ,
                                @cur_Type = Type ,
                                @cur_Cmp_ID = Cmp_ID ,
                                @cur_M_Sal_Tran_ID = M_Sal_Tran_ID ,
                                @cur_Emp_Id = Emp_Id ,
                                @cur_Sal_Generate_Date = Sal_Generate_Date ,
                                @cur_Month_St_Date = Month_St_Date ,
                                @cur_Month_End_Date = Month_End_Date ,
                                @cur_Present_Days = Present_Days ,
                                @cur_M_OT_Hours = M_OT_Hours ,
                                @cur_Areas_Amount = Areas_Amount ,
                                @cur_M_IT_Tax = M_IT_Tax ,
                                @cur_Other_Dedu = Other_Dedu ,
                                @cur_M_LOAN_AMOUNT = M_LOAN_AMOUNT ,
                                @cur_M_ADV_AMOUNT = M_ADV_AMOUNT ,
                                @cur_IS_LOAN_DEDU = IS_LOAN_DEDU ,
                                @cur_Login_ID = Login_ID ,
                                @cur_ErrRaise = ErrRaise ,
                                @cur_Is_Negetive = Is_Negetive ,
                                @cur_Status = Status ,
                                @cur_IT_M_ED_Cess_Amount = IT_M_ED_Cess_Amount ,
                                @cur_IT_M_Surcharge_Amount = IT_M_Surcharge_Amount ,
                                @cur_Allo_On_Leave = Allo_On_Leave ,
                                @cur_User_Id = User_Id ,
                                @cur_IP_Address = IP_Address ,
                                @Cur_Is_processed = Is_processed,
                                @cur_IS_Bond_DEDU = IS_Bond_DEDU
                        FROM    #Pre_Salary_Data_Exe
                        WHERE   Row_ID = @intFlag
					                
					   
                        EXEC P0200_MONTHLY_SALARY_GENERATE_MANUAL @cur_M_Sal_Tran_ID,
                            @cur_Emp_Id, @cur_Cmp_ID, @cur_Sal_Generate_Date,
                            @cur_Month_St_Date, @cur_Month_End_Date,
                            @cur_Present_Days, @cur_M_OT_Hours,
                            @cur_Areas_Amount, @cur_M_IT_Tax, @cur_Other_Dedu,
                            @cur_M_LOAN_AMOUNT, @cur_M_ADV_AMOUNT,
                            @cur_IS_LOAN_DEDU, @cur_Login_ID, @cur_ErrRaise,
                            @cur_Is_Negetive, @cur_Status,
                            @cur_IT_M_ED_Cess_Amount,
                            @cur_IT_M_Surcharge_Amount, @cur_Allo_On_Leave,
                            @cur_User_Id, @cur_IP_Address, @wo_date, @wo_count,
                            @ho_date, @ho_count, @wo_date_mid, @wo_count_mid
                            ,@cur_IS_Bond_DEDU
						
						
						
                        UPDATE  dbo.t0200_Pre_Salary_Data
                        SET     is_processed = 1
                        WHERE   Tran_ID = @cur_Tran_id		


						DECLARE @GUID_PART VARCHAR(32);
						Select	@GUID_PART = REVERSE(SUBSTRING(REVERSE(Batch_id),0, CHARINDEX('-', REVERSE(Batch_id)))) 
						FROM	t0200_Pre_Salary_Data WITH (NOLOCK)
						WHERE   Tran_ID = @cur_Tran_id

						DECLARE @Processed INT;
						SELECT  @Processed = COUNT(1)
						FROM	t0200_Pre_Salary_Data WITH (NOLOCK)
						WHERE   Batch_id LIKE '%' + @GUID_PART and is_processed=1

						UPDATE	T0211_SALARY_PROCESSING_STATUS
						SET		Processed = @Processed
						WHERE	SPID = @@SPID

					----		END TRY
			
					--		BEGIN CATCH
					--			 update dbo.t0200_Pre_Salary_Data SET is_processed = 2 where Tran_ID = @cur_Tran_id
					--			SET @LogDesc = 'Emp_ID='+@cur_Emp_Id+', Month='+cast(MONTH(@cur_Month_End_Date) as varchar)+', Year='+cast(year(@cur_Month_End_Date) as varchar)
					--			SET @Error = ERROR_MESSAGE()
					--Commented by Gadriwala Muslim 17012017
                        --EXEC Event_Logs_Insert 0, @cur_Cmp_ID, @cur_Emp_Id,
                        --    @cur_User_Id, 'Salary Manual#', @Error, @LogDesc,
                        --    1, ''			 		
					--		END CATCH
		
                        SET @intFlag = @intFlag + 1
                        IF @intFlag > @Count_emp + 1
                            BREAK;
                    END
			
                DROP TABLE #Pre_Salary_Data_Exe  
            END
        ELSE
            BEGIN
			--select Emp_ID,is_processed from t0200_Pre_Salary_Data_monthly where ISNULL(batch_id, '') = '619d8451-c958-4b32-a4fd-1120016c305a' and  is_processed = 0  --mansi
				INSERT  INTO #Pre_Salary_Data_monthly_Exe
                SELECT  ROW_NUMBER() OVER ( ORDER BY Emp_ID DESC ) AS Row ,
                                *
                FROM    dbo.t0200_Pre_Salary_Data_monthly WITH (NOLOCK)
                WHERE   is_processed = 0
                        AND ISNULL(batch_id, '') = @ID
				
				

                SELECT  @Emp_cons_list = REPLACE(REPLACE(STUFF((SELECT
                                                              '#'
      + QUOTENAME(CAST(Emp_ID AS VARCHAR(MAX)))
                                                              FROM
                                                              #Pre_Salary_Data_monthly_Exe
                                                              AS a
                                                              CROSS APPLY ( SELECT
                                                              'Emp_ID' col ,
                                                              1 so
                                                              ) c
                                                              GROUP BY a.Emp_ID
                                                              ORDER BY a.Emp_ID
                                                         FOR  XML
                                                              PATH('') ,
                                                              TYPE ).value('.',
                                                              'NVARCHAR(MAX)'),
                                                              1, 1, ''), '[',
                                                         ''), ']', '')
				

				
				/*IMPLEMENTED BY NIMESH on 24-Dec-2015
				For those employees who did not get increment or transfer withing salary month.
				*/
			
				-- For Calculate Present Days    
				CREATE TABLE #Data_SAL    
				(     
					Emp_Id     NUMERIC ,     
					For_date   DATETIME,    
					Duration_in_sec  NUMERIC,    
					Shift_ID   NUMERIC ,    
					Shift_Type   NUMERIC ,    
					Emp_OT    NUMERIC ,    
					Emp_OT_min_Limit NUMERIC,    
					Emp_OT_max_Limit NUMERIC,    
					P_days    NUMERIC(18, 4) default 0,    
					OT_Sec    NUMERIC default 0,
					In_Time DATETIME default null,
					Shift_Start_Time DATETIME default null,
					OT_Start_Time NUMERIC default 0,
					Shift_Change TINYINT default 0 ,
					Flag Int Default 0  ,
					Weekoff_OT_Sec  NUMERIC default 0,
					Holiday_OT_Sec  NUMERIC default 0	,
					Chk_By_Superior NUMERIC default 0,
					IO_Tran_Id	   NUMERIC default 0,
					OUT_Time DATETIME, 
					Shift_End_Time DATETIME,		--Ankit 16112013
					OT_End_Time NUMERIC default 0,	--Ankit 16112013
					Working_Hrs_St_Time TINYINT default 0, --Hardik 14/02/2014
					Working_Hrs_End_Time TINYINT default 0, --Hardik 14/02/2014
					GatePass_Deduct_Days NUMERIC(18, 4) default 0 -- Added by Gadriwala Muslim 05012014	  
					 --,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
				)
				
				CREATE NONCLUSTERED INDEX IX_Data_SAL ON #Data_SAL(EMP_ID, For_date)
				
				DECLARE @CONSTRAINT VARCHAR(MAX);
				
				
				SELECT	@CONSTRAINT=COALESCE(@CONSTRAINT + '#', '') + isnull(CAST(EMP_ID AS VARCHAR(10)),0)
				FROM	(Select Emp_ID FROM #Pre_Salary_Data_monthly_Exe Group BY Emp_ID) T 
		
				


				EXEC dbo.SP_MONTHLY_SALARY_CALC_PRESENT_DAYS @Cmp_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @CONSTRAINT=@CONSTRAINT


				DECLARE @Count_emp_monthly AS NUMERIC
				DECLARE @intFlag_monthly AS NUMERIC(18, 0)	
              
                SELECT  @Count_emp_monthly = COUNT(row_ID)
                FROM    #Pre_Salary_Data_monthly_Exe 
				
				
				SET @intFlag_monthly = 1
                WHILE ( @intFlag_monthly <= @Count_emp_monthly )
                    BEGIN

						SELECT  @cur_mon_Tran_id = Tran_id ,
                                @cur_mon_Type = Type ,
                                @cur_mon_Cmp_ID = Cmp_ID ,
                                @cur_mon_M_Sal_Tran_ID = M_Sal_Tran_ID ,
                                @cur_mon_Emp_Id = Emp_Id ,
                                @cur_mon_Sal_Generate_Date = Sal_Generate_Date ,
                                @cur_mon_Month_St_Date = Month_St_Date ,
                                @cur_mon_Month_End_Date = Month_End_Date ,
                                @cur_mon_M_OT_Hours = M_OT_Hours ,
                                @cur_mon_Areas_Amount = Areas_Amount ,
                                @cur_mon_M_IT_Tax = M_IT_Tax ,
                                @cur_mon_Other_Dedu = Other_Dedu ,
                                @cur_mon_M_LOAN_AMOUNT = M_LOAN_AMOUNT ,
                                @cur_mon_M_ADV_AMOUNT = M_ADV_AMOUNT ,
                                @cur_mon_IS_LOAN_DEDU = IS_LOAN_DEDU ,
                                @cur_mon_Login_ID = Login_ID ,
                                @cur_mon_ErrRaise = ErrRaise ,
                                @cur_mon_Is_Negetive = Is_Negetive ,
                                @cur_mon_Status = Status ,
                                @cur_mon_IT_M_ED_Cess_Amount = IT_M_ED_Cess_Amount ,
                                @cur_mon_IT_M_Surcharge_Amount = IT_M_Surcharge_Amount ,
                                @cur_mon_Allo_On_Leave = Allo_On_Leave ,
                                @cur_mon_User_Id = User_Id ,
                                @cur_mon_IP_Address = IP_Address ,
                                @Cur_mon_Is_processed = Is_processed,
                                @cur_mon_is_Bond_Dedu = IS_Bond_Dedu
                        FROM    #Pre_Salary_Data_monthly_Exe
                        WHERE   Row_ID = @intFlag_monthly

			
                        EXEC P0200_MONTHLY_SALARY_GENERATE_PRORATA @Cur_mon_M_Sal_Tran_ID,
                            @cur_mon_Emp_Id, @Cur_mon_Cmp_ID,
                            @Cur_mon_Sal_Generate_Date, @Cur_mon_Month_St_Date,
                            @Cur_mon_Month_End_Date, @Cur_mon_M_OT_Hours,
                            @Cur_mon_Areas_Amount, @Cur_mon_M_IT_Tax,
                            @Cur_mon_Other_Dedu, @Cur_mon_M_LOAN_AMOUNT,
                            @Cur_mon_M_ADV_AMOUNT, @Cur_mon_IS_LOAN_DEDU,
                            @Cur_mon_Login_ID, @Cur_mon_ErrRaise,
                            @Cur_mon_Is_Negetive, @Cur_mon_Status,
                            @Cur_mon_IT_M_ED_Cess_Amount,
                            @Cur_mon_IT_M_Surcharge_Amount,
                            @Cur_mon_Allo_On_Leave, @Cur_mon_W_OT_Hours,
                            @Cur_mon_H_OT_Hours, @Cur_mon_User_Id,
                            @Cur_mon_IP_Address
                            ,@cur_mon_is_Bond_Dedu
					 
						BREAK;
						
						/*
                        UPDATE  t0200_Pre_Salary_Data_monthly
                        SET     is_processed = 1
                        WHERE   Tran_ID = @cur_mon_Tran_id
					 
                        --FETCH NEXT FROM curExecSalarMon INTO @cur_mon_Tran_id,
                        --    @Cur_mon_Type, @Cur_mon_M_Sal_Tran_ID,
                        --    @Cur_mon_Emp_Id, @Cur_mon_Cmp_ID,
                        --    @Cur_mon_Sal_Generate_Date, @Cur_mon_Month_St_Date,
                        --    @Cur_mon_Month_End_Date, @Cur_mon_M_OT_Hours,
                        --    @Cur_mon_Areas_Amount, @Cur_mon_M_IT_Tax,
                        --    @Cur_mon_Other_Dedu, @Cur_mon_M_LOAN_AMOUNT,
                        --    @Cur_mon_M_ADV_AMOUNT, @Cur_mon_IS_LOAN_DEDU,
                        --    @Cur_mon_Login_ID, @Cur_mon_ErrRaise,
                        --    @Cur_mon_Is_Negetive, @Cur_mon_Status,
                        --    @Cur_mon_IT_M_ED_Cess_Amount,
                        --    @Cur_mon_IT_M_Surcharge_Amount,
                        --    @Cur_mon_Allo_On_Leave, @Cur_mon_W_OT_Hours,
                        --    @Cur_mon_H_OT_Hours, @Cur_mon_User_Id,
                        --    @Cur_mon_IP_Address, @Cur_mon_Is_processed
						  SET @intFlag_monthly = @intFlag_monthly + 1
                        IF @intFlag_monthly > @Count_emp_monthly + 1
                            BREAK;*/
                    END
				
                DROP TABLE #Pre_Salary_Data_monthly_Exe
	
            END
	 

    END

