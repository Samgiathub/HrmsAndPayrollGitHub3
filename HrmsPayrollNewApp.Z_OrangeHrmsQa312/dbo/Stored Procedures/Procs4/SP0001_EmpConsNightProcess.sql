

--EXEC SP0001_EmpConsNightProcess 1
CREATE PROCEDURE [dbo].[SP0001_EmpConsNightProcess]  
	@Rerun int = 0
AS
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--select * from T0001_EmpCons_NigthProcess
--DECLARE @DyTble AS NVARCHAR(50) = ''
--SELECT  @DyTble ='T0001_EmpCons_' + cast(Month(GETDATE()) as nvarchar(1)) + '_'+ cast(YEAR(GETDATE()) as nvarchar(10))

DECLARE @DyTble AS NVARCHAR(50) = ''
--SELECT  @DyTble ='T0001_EmpCons_' + DateName(month,DateAdd(month,Month(GETDATE()),-1)) + '_'+ cast(YEAR(GETDATE()) as nvarchar(10))
SELECT  @DyTble ='T0001_EmpCons_NigthProcess' 
DECLARE @STR as nvarchar(MAX) = ''


if @Rerun = 0
BEGIN
	print @Rerun
	SET @STR ='
	IF NOT exists(select 1 from Sys.tables where name = ''' + @DyTble + ''')
	BEGIN
		SELECT I.Emp_ID,I.Branch_ID,I.Increment_ID ,I.Cmp_Id
		into '+ @DyTble + '
		FROM T0095_INCREMENT I  WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON I.EMP_ID=EM.EMP_ID INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
		FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN (SELECT	Emp_ID, Max(Increment_Effective_Date) As Increment_Effective_Date FROM	T0095_INCREMENT I2 WITH (NOLOCK) WHERE	I2.Increment_Effective_Date	 <= GETDATE() GROUP BY I2.Emp_ID
	) I2 ON I1.Emp_ID=I2.Emp_ID and I1.Increment_Effective_Date=I2.Increment_Effective_Date GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID where EM.Emp_Left = ''N''
	END'
END
ELSE
BEGIN
	print @Rerun
	SET @STR ='
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE    TABLE_NAME = ''T0001_EmpCons_NigthProcess''))
		Drop Table '+ @DyTble + '
	IF NOT exists(select 1 from Sys.tables where name = ''' + @DyTble + ''')
	BEGIN
		SELECT I.Emp_ID,I.Branch_ID,I.Increment_ID ,I.Cmp_Id
		into '+ @DyTble + '
		FROM T0095_INCREMENT I  WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON I.EMP_ID=EM.EMP_ID INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
		FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN (SELECT	Emp_ID, Max(Increment_Effective_Date) As Increment_Effective_Date FROM	T0095_INCREMENT I2 WITH (NOLOCK) WHERE	I2.Increment_Effective_Date	 <= GETDATE() GROUP BY I2.Emp_ID
	) I2 ON I1.Emp_ID=I2.Emp_ID and I1.Increment_Effective_Date=I2.Increment_Effective_Date GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID where EM.Emp_Left = ''N''
	END'
	--select @STR
END
execute sp_executesql @STR
