


-- Created By rohit for Audit Record get
-- created on 29122015
CREATE PROCEDURE [dbo].[P9999_Audit_get]
  @table         NVARCHAR(max) = N'T0050_Project_Master_Payroll' , 
  @key_column    SYSNAME       = N'tran_id',
  @key_Values	varchar(999) = '0',
  @String Varchar(Max)='' output
  AS
Set NoCount On;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 SET ARITHABORT ON  
 SET ANSI_WARNINGS OFF;
DECLARE 
  @colNames  NVARCHAR(MAX), --= N'',
  @colValues NVARCHAR(MAX), --= N'',
  @sql       NVARCHAR(MAX), --= N'',
  @NewSql    NVARCHAR(MAX),  --=N'',
  @ParmDefinition nvarchar(MAX);
  
  SET @colNames = N''   --changed jimit 18042016
  SET @colValues = N''	--changed jimit 18042016
  SET @sql = N''		--changed jimit 18042016
  SET @NewSql = N''		--changed jimit 18042016
    
  SET @ParmDefinition = N'@retvalOUT NVarchar(max) OUTPUT';
SELECT 
  @colNames = @colNames + ', 
    ' + QUOTENAME(name), 
  @colValues =@colValues + ', 
    ' + QUOTENAME(name) 
   + ' = CONVERT(VARCHAR(320), ' + QUOTENAME(name) + ')'
FROM sys.columns
WHERE [object_id] = OBJECT_ID(@table)
AND name <> @key_column;

SET @sql = N'SELECT ' + @key_column + ', Property, Value into #Dt
FROM
(
  SELECT ' + @key_column + @colValues + '
   FROM ' + @table + ' WITH (NOLOCK) where ' + @key_column + ' = ' + @key_Values + '
) AS t
UNPIVOT
(
  Value FOR Property IN (' + STUFF(@colNames, 1, 1, '') + ')
) AS up;
';

 

set @NewSql = 'SELECT @retvalOUT = STUFF((SELECT '' '' + s.value FROM ( select ('''' + property + '' : '' + value + ''#'' ) as value, ' + @key_column + ' from #Dt ) s WHERE s.'+ @key_column + '= t.'+ @key_column +' FOR XML PATH('''')),1,1,'''') FROM #Dt AS t where t.'+@key_column +'= '+ @key_Values + ' GROUP BY t.' + @key_column +';'
 --print 1
 set @sql = @sql + @NewSql
 
 --PRINT @sql;
 EXEC sp_executesql @sql,@ParmDefinition, @retvalOUT=@String OUTPUT;
 --PRINT @table;
 --EXEC sp_executesql @NewSql;
 return 
 
 

