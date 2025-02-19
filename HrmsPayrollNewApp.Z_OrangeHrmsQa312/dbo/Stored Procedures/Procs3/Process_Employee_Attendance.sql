cREATE PROCEDURE [dbo].[Process_Employee_Attendance]
AS
BEGIN
    -- Declare variables
    DECLARE @Cmp_ID INT;
    DECLARE @Emp_ID INT;
    DECLARE @Branch_ID INT;
    DECLARE @From_Date_I DATETIME;
    DECLARE @To_Date_I DATETIME;
    DECLARE @Sal_St_Date DATETIME;

    -- Create a table variable to temporarily hold the results
    CREATE TABLE #TempResults (
        Emp_ID NUMERIC(18,0),
        Cmp_ID NUMERIC(18,0),
        Branch_ID NUMERIC(18,0),
        Present NUMERIC(18,2),
        WO NUMERIC(18,2),
        HO NUMERIC(18,2),
        OD NUMERIC(18,2),
        Absent NUMERIC(18,2),
        Leave NUMERIC(18,2),
        Total NUMERIC(18,2),
        D_Present NUMERIC(18,2),
        Month NVARCHAR(MAX),
        Sal_St_Date datetime,
		Create_Date datetime
    );

    -- Temporary table to hold the results from the stored procedure
    CREATE TABLE #SPResults (
        Emp_ID NUMERIC(18,0),
        Present NUMERIC(18,2),
        WO NUMERIC(18,2),
        HO NUMERIC(18,2),
        OD NUMERIC(18,2),
        Absent NUMERIC(18,2),
        Leave NUMERIC(18,2),
        Total NUMERIC(18,2),
        D_Present NUMERIC(18,2)
    );

    -- Create a cursor to iterate through each company
    DECLARE company_cursor CURSOR FOR
        SELECT Cmp_Id
        FROM T0010_COMPANY_MASTER ;

    OPEN company_cursor;

    FETCH NEXT FROM company_cursor INTO @Cmp_ID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Create a cursor to iterate through each branch within the current company
        DECLARE branch_cursor CURSOR FOR
            SELECT Branch_ID
            FROM T0030_BRANCH_MASTER
            WHERE Cmp_ID = @Cmp_ID ;

        OPEN branch_cursor;

        FETCH NEXT FROM branch_cursor INTO @Branch_ID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Get the Sal_St_Date for the current company and branch
            SELECT @Sal_St_Date = Sal_St_Date 
            FROM T0040_GENERAL_SETTING 
            WHERE Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID;
						-- Calculate the dynamic From_Date_I and To_Date_I based on Sal_St_Date
			-- Extract the day part from Sal_St_Date
			DECLARE @DayPart INT = DAY(@Sal_St_Date);
			
			-- Set From_Date_I to the previous month and current year with the day from Sal_St_Date
			SET @From_Date_I = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()) - 1, @DayPart);
			--Print @From_Date_I;
			-- Calculate To_Date_I as the last day of the next month from the previous month
			SET @To_Date_I = DATEADD(DAY, -1, DATEADD(MONTH, 1, @From_Date_I));
			--Print @To_Date_I;
			
            -- Create a cursor to iterate through each employee within the current branch and company
            DECLARE employee_cursor CURSOR FOR
                SELECT Emp_ID
                FROM T0080_EMP_MASTER
                WHERE Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID;

            OPEN employee_cursor;

            FETCH NEXT FROM employee_cursor INTO @Emp_ID;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Insert the results from the stored procedure into the temporary table
                DELETE FROM #SPResults; -- Clear previous results

                INSERT INTO #SPResults (Emp_ID, Present, WO, HO, OD, Absent, Leave, Total, D_Present)
                EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET_Karmesh 
                    @Cmp_ID = @Cmp_ID,
                    @From_Date = @From_Date_I,
                    @To_Date = @To_Date_I,
                    @Branch_ID = @Branch_ID,
                    @Cat_ID = 0,
                    @Grd_ID = 0,
                    @Type_ID = 0,
                    @Dept_ID = 0,
                    @Desig_ID = 0,
                    @Emp_ID = @Emp_ID,
                    @Constraint = N'',
                    @Report_for = N'IN-OUT';

                -- Insert the results into #TempResults with Cmp_ID and Branch_ID
                INSERT INTO #TempResults (Cmp_ID, Branch_ID, Emp_ID, Present, WO, HO, OD, Absent, Leave, Total, D_Present, Month,Sal_St_Date,Create_Date)
                SELECT @Cmp_ID, @Branch_ID, Emp_ID, Present, WO, HO, OD, Absent, Leave, Total, D_Present, DATENAME(MONTH, @From_Date_I),@From_Date_I,GETDATE()
                FROM #SPResults;

				-- Insert data from temporary table to the main table
				INSERT INTO T0080_Emp_Present_Days (Cmp_ID, Branch_ID, Emp_ID, Present, WO, HO, OD, Absent, Leave, Total, D_Present,	Month,Sal_St_Date,Create_Date)
				SELECT Cmp_ID, Branch_ID, Emp_ID, Present, WO, HO, OD, Absent, Leave, Total, D_Present, Month,Sal_St_Date,Create_Date
				FROM #TempResults;

	 truncate table #TempResults;

                FETCH NEXT FROM employee_cursor INTO @Emp_ID;
            END

            CLOSE employee_cursor;
            DEALLOCATE employee_cursor;

            FETCH NEXT FROM branch_cursor INTO @Branch_ID;
        END

        CLOSE branch_cursor;
        DEALLOCATE branch_cursor;

        -- Fetch the next company
        FETCH NEXT FROM company_cursor INTO @Cmp_ID;
    END

    CLOSE company_cursor;
    DEALLOCATE company_cursor;

    
    -- Drop the temporary tables
   DROP TABLE #TempResults;
   DROP TABLE #SPResults;
END;
