CREATE PROCEDURE [dbo].[SP_Customize_Leave_Report]
    @Cmp_ID        NUMERIC,
    @Emp_ID        NUMERIC,
    @Constraint    VARCHAR(MAX),
    @Leave_IDs     VARCHAR(MAX), 
    @For_Date      DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET ARITHABORT ON;

    DECLARE @Emp_Cons TABLE (Emp_ID NUMERIC);
    DECLARE @Leave_Cons TABLE (Leave_ID NUMERIC); 
    DECLARE @DynamicSQL NVARCHAR(MAX); 
    DECLARE @ColumnNames NVARCHAR(MAX); 
    DECLARE @LeaveColumns NVARCHAR(MAX); 
    
  
    IF @Constraint <> ''        
    BEGIN        
        INSERT INTO @Emp_Cons        
        SELECT CAST(data AS NUMERIC)        
        FROM dbo.Split(@Constraint, '#');
    END

 
    IF @Leave_IDs <> ''        
    BEGIN        
        INSERT INTO @Leave_Cons        
        SELECT CAST(data AS NUMERIC)        
        FROM dbo.Split(@Leave_IDs, '#');
    END

    CREATE TABLE #Emp_Cons (
        Emp_ID NUMERIC,
        Branch_ID NUMERIC,
        Increment_ID NUMERIC
    )

    EXEC SP_RPT_FILL_EMP_CONS 
        @Cmp_ID,
        '',
        '',
        0,
        0,
        0,
        0,
        0,
        0,
        @Emp_ID,
        @Constraint,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0

    
    SELECT @ColumnNames = STRING_AGG(QUOTENAME(Leave_Name), ', ') 
    FROM dbo.T0040_LEAVE_MASTER
    WHERE Leave_ID IN (SELECT Leave_ID FROM @Leave_Cons);
    
 
    IF @ColumnNames IS NULL
    BEGIN
        PRINT 'No valid leave IDs found.';
        RETURN;
    END


   SET @LeaveColumns = 
'DECLARE @Leave_Cons TABLE (Leave_ID NUMERIC); ' + 
'INSERT INTO @Leave_Cons ' +
'SELECT CAST(data AS NUMERIC) FROM dbo.Split(@Leave_IDs, ''#''); ' + 

'SELECT * FROM ( ' + 
    'SELECT e.Emp_ID, ' +
            'e.Alpha_Emp_Code AS Emp_code, ' +
            'e.Emp_Full_Name, ' +
            'g.Grd_Name, ' +
            'd.Dept_Name, ' +
            't.Type_Name, ' +  
            'c.Cat_Name, ' +
            'de.Desig_Name, ' +
            'l.For_Date, ' +
            'lm.Leave_Name ' + 
     'FROM dbo.T0140_LEAVE_TRANSACTION AS l WITH (NOLOCK) ' +
     'INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON l.Emp_ID = EC.Emp_ID ' +
     'INNER JOIN dbo.T0080_EMP_MASTER AS e WITH (NOLOCK) ON l.Emp_ID = e.Emp_ID AND l.Cmp_ID = e.Cmp_ID ' +
     'INNER JOIN dbo.T0040_GRADE_MASTER AS g WITH (NOLOCK) ON e.Grd_ID = g.Grd_ID ' +
     'INNER JOIN dbo.T0040_LEAVE_MASTER AS lm WITH (NOLOCK) ON l.Leave_ID = lm.Leave_ID ' +  -- Alias for Leave Master
     'LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER AS de WITH (NOLOCK) ON e.Desig_Id = de.Desig_ID ' +
     'LEFT OUTER JOIN dbo.T0040_TYPE_MASTER AS t WITH (NOLOCK) ON e.Type_ID = t.Type_ID ' +
     'LEFT OUTER JOIN dbo.T0030_CATEGORY_MASTER AS c WITH (NOLOCK) ON e.Cat_ID = c.Cat_ID ' +
     'LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER AS d WITH (NOLOCK) ON e.Dept_ID = d.Dept_Id ' +
     'WHERE ISNULL(l.IsMakerChaker, 0) <> 1 ' +
     'AND ((l.Leave_Opening <> 0) OR ' +  
          '(l.Leave_Credit <> 0) OR ' +  
          '(l.Leave_Used <> 0) OR ' +  
          '(l.Leave_Closing <> 0) OR ' +  
          '(l.CompOff_Balance <> 0) OR ' +  
          '(l.CompOff_Credit <> 0) OR ' +  
          '(l.CompOff_Debit <> 0) OR ' +  
          '(l.CompOff_Used <> 0)) ' +
     'AND l.Cmp_ID = @Cmp_ID ' +
     'AND l.For_Date = @For_Date ' +
     'AND l.Leave_ID IN (SELECT Leave_ID FROM @Leave_Cons) ' +
     ') AS SourceTable ' + 
     'PIVOT(MAX(Leave_Name) FOR Leave_Name IN (' + @ColumnNames + ')) AS pivot_table;';

EXEC sp_executesql @LeaveColumns, 
       N'@Cmp_ID NUMERIC, @For_Date DATETIME, @Leave_IDs VARCHAR(MAX)', 
       @Cmp_ID, @For_Date, @Leave_IDs;

	   End