
CREATE PROCEDURE [dbo].[GetComplianceReport_bkrb]
    @Cmp_ID INT,
    @Branch_ID INT,
    @Year INT,
    @Submission_Type INT  -- 1 for Monthly, 2 for Annual
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables for dynamic SQL
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @Columns NVARCHAR(MAX);

    -- Step 1: Retrieve dynamic compliance names (visible in report) from the Compliance table
    SELECT @Columns = STRING_AGG(QUOTENAME(Compliance_Name), ', ') 
    FROM T0050_COMPLIANCE_MASTER 
    WHERE Cmp_ID = @Cmp_ID
      AND ((Compliance_Submition_Type = 1)  -- Monthly
            OR (Compliance_Submition_Type = 2))  -- Annual

    -- If no columns are found, raise an error
    IF @Columns IS NULL
    BEGIN
        RAISERROR('No compliance records found for the specified parameters.', 16, 1);
        RETURN;
    END
	SELECT @Columns AS Compliance_Columns;
    ---- Step 2: Construct the dynamic SQL query to select compliance status and contractor names
    --SET @DynamicSQL = '
    --SELECT c.Contr_PersonName, ' + @Columns + '
    --FROM T0035_CONTRACTOR_DETAIL_MASTER c
    --INNER JOIN T0050_COMPLIANCE_MASTER cl 
    --    ON c.Contr_ID = cl.Contr_ID
    --WHERE cl.Cmp_ID = @Cmp_ID
    --  AND c.Branch_ID = @Branch_ID
    --  AND YEAR(cl.Updated_Date) = @Year
    --  AND ((cl.Compliance_Submition_Type = 1) 
    --       OR (cl.Compliance_Submition_Type = 2))
    --ORDER BY c.Contr_PersonName;';

    ---- Step 3: Execute the dynamic SQL
    --EXEC sp_executesql @DynamicSQL, 
    --                   N'@Cmp_ID INT, @Branch_ID INT, @Year INT', 
    --                   @Cmp_ID, @Branch_ID, @Year;
END
