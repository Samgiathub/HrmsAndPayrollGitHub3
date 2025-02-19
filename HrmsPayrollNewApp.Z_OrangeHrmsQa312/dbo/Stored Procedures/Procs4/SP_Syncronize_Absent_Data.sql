CREATE PROCEDURE SP_Syncronize_Absent_Data
    @Year INT
AS
BEGIN
    DECLARE @Month INT = 1;
    DECLARE @StartDate DATETIME;
    DECLARE @EndDate DATETIME;

    -- Loop through each month of the year
    WHILE @Month <= 12
    BEGIN
        -- Calculate StartDate and EndDate for the current month
        SET @StartDate = DATEFROMPARTS(@Year, @Month, 1);
        SET @EndDate = DATEADD(SECOND, -1, DATEADD(MONTH, 1, @StartDate));

        -- Insert data directly into T0150_EMP_ABSENT_RECORD by executing the stored procedure SP_RPT_EMP_ATTENDANCE_MUSTER_GET
        INSERT INTO T0150_EMP_ABSENT_RECORD (
            Emp_Id,
            Cmp_ID,
            For_Date,
            Status,
            Leave_Count,
            WO_HO,
            Status_2,
            Row_ID,
            WO_HO_Day,
            P_days,
            A_days,
            Join_Date,
            Left_Date,
            GatePass_Days,
            Late_deduct_Days,
            Early_deduct_Days,
            shift_id,
            Emp_code,
            Emp_Full_Name,
            Branch_Address,
            comp_name,
            Branch_Name,
            Dept_Name,
            Grd_Name,
            Desig_Name,
            P_From_date,
            P_To_Date,
            BRANCH_ID,
            Shift_Name,
            cmp_name,
            cmp_address,
            Mobile_No,
            Emp_First_Name,
            Type_Name,
            Reporting_Manager,
            Vertical_Name,
            SubVertical_Name
        )
        EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_GET 
            @Cmp_ID = 1, 
            @From_Date = @StartDate, 
            @To_Date = @EndDate, 
            @Branch_ID = 0, 
            @Cat_ID = 0, 
            @Grd_ID = 0, 
            @Type_ID = 0, 
            @Dept_ID = 0, 
            @Desig_ID = 0, 
            @Emp_ID = 0, 
            @Constraint = '', 
            @Export_Type = '5', 
            @Report_For = 'Complete_Absent', 
            @Con_Absent_Days = 0;

        -- Move to the next month
        SET @Month = @Month + 1;
    END;
END;