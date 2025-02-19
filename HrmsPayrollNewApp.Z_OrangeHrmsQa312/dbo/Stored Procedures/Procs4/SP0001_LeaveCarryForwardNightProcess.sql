-- exec SP0001_LeaveCarryForwardNightProcess
CREATE PROCEDURE [dbo].[SP0001_LeaveCarryForwardNightProcess]  
	
AS
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

--CREATE TABLE T0001_LEAVECF_NightProcess
--(
--	[LEAVE_CF_ID] [NUMERIC](18, 0) NOT NULL IDENTITY(1,1),
--	[Cmp_ID] [NUMERIC](18, 0) NOT NULL,
--	[Emp_ID] [NUMERIC](18, 0) NOT NULL,
--	[Leave_ID] [NUMERIC](18, 0) NOT NULL,
--	[CF_For_Date] [DATETIME] NOT NULL,
--	[CF_From_Date] [DATETIME] NOT NULL,
--	[CF_To_Date] [DATETIME] NOT NULL,
--	[CF_P_Days] [NUMERIC](18, 2) NOT NULL,
--	[CF_Leave_Days] [NUMERIC](22, 8) NOT NULL,
--	[CF_Type] [varchar](200) NOT NULL,
--	[Exceed_CF_Days] [NUMERIC](22, 8) NULL,
--	[Leave_CompOff_Dates] [nvarchar](10) NULL,
--	[Is_Fnf] varchar(5) NOT NULL,
--	Alpha_Emp_Code Nvarchar(100),
--	Emp_Full_Name Nvarchar(100),
--	Leave_Name Nvarchar(100),
--	new_join_flag varchar(5), 
--	date_of_join varchar(100),
--	diff varchar(10),
--	[Advance_Leave_Balance] [NUMERIC](18, 2) NOT NULL DEFAULT 0,
--	[Advance_Leave_Recover_balance] [NUMERIC](18, 2) NOT NULL DEFAULT 0,
--	[Is_Advance_Leave_Balance][tinyint] NOT NULL DEFAULT 0
--)


Declare @StartDate As DATE= NULL
Declare @EndDate As DATE= NULL
Declare @ForDate As DATE= NULL
SET @StartDate = Cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as DATE)
SET @EndDate =   CAST(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0)) as DATE)
SET @ForDate = GETDATE()
set @STARTDATE = '2024-02-21 00:00:00.000'
set @ENDDATE = '2024-03-20 00:00:00.000'
SET @ForDate = '2024-04-01 00:00:00.000'
DECLARE @EMP_ID as bigint
DECLARE @CNT as int = 1
DECLARE @ROWCNT as int
DECLARE @Cmp_id as int = 1

select  ROW_NUMBER() OVER(order by EMP_ID) RowNo ,* into #tmpEmpCons_NigthProcess from T0001_EmpCons_NigthProcess 
where Branch_ID = 26
	--where EMP_ID in (169,170,171,172)

	DEclare @STR as Nvarchar(MAX) = ''
	Declare @MaxLeaveCFId as Numeric(18,0) = 0
	SELECT @ROWCNT = count(1) from  #tmpEmpCons_NigthProcess 
	WHILE (@CNT <= @ROWCNT)
	BEGIN
		SET @EMP_ID = 0
		SELECT @EMP_ID = EMP_Id from #tmpEmpCons_NigthProcess where RowNo = @cnt	
		
		--print @STARTDATE
		--print @EndDate
		--print @CNT
		select @MaxLeaveCFId = MAX(isnull(LEAVE_CF_ID,0)) + 1 from T0001_LEAVECF_NightProcess
		--select LEAVE_CF_ID,Cmp_ID,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance from  T0001_LEAVECF_NightProcess
		
		set @STR = 'insert into T0001_LEAVECF_NightProcess (Cmp_ID,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)
		EXEC SP_LEAVE_CF_Display_NightProcess  0,'+ cast(@Cmp_id as nvarchar(2)) +', ''' + cast(@StartDate as nvarchar(50)) + ''',''' + cast(@EndDate as nvarchar(50)) + ''',''' + cast(@ForDate as nvarchar(50)) + ''',0,0,0,0,0,0,'+ CAST(@EMP_ID as Varchar(50)) +' ,'''',60,0,0,0,0'
		
		-- EXEC SP_LEAVE_CF_Display @leave_Cf_ID=0,@Cmp_ID=1,@From_Date=@StartDate,@To_Date=@EndDate,@For_Date= @ForDate,@Branch_ID=0,@Cat_ID=0
		--,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID =@EMP_ID,@Constraint='',@P_LeavE_ID=60,@Segment_ID =0,@subBranch_ID =0,@Vertical_ID =0,@SubVertical_ID =0
		exec sp_executesql  @STR
		--select @STR
		

		set @CNT = @CNT + 1
	END
END
--DECLARE @DyTble AS NVARCHAR(50) = ''
--SELECT  @DyTble ='T0001_EmpCons_' + cast(Month(GETDATE()) as nvarchar(1)) + '_'+ cast(YEAR(GETDATE()) as nvarchar(10))
--DECLARE @STR as nvarchar(MAX) = ''
--DECLARE @DyTble AS NVARCHAR(50) = ''
--SELECT  @DyTble ='T0001_EmpCons_' + DateName(month,DateAdd(month,Month(GETDATE()),-1)) + '_'+ cast(YEAR(GETDATE()) as nvarchar(10))
--select @DyTble
--if @Rerun = 0
--BEGIN
--	print @Rerun
--	SET @STR ='
--	IF NOT exists(select 1 from Sys.tables where name = ''' + @DyTble + ''')
--	BEGIN
--		SELECT I.Emp_ID,I.Branch_ID,I.Increment_ID 
--		into '+ @DyTble + '
--		FROM T0095_INCREMENT I  WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON I.EMP_ID=EM.EMP_ID INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
--		FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN (SELECT	Emp_ID, Max(Increment_Effective_Date) As Increment_Effective_Date FROM	T0095_INCREMENT I2 WITH (NOLOCK) WHERE	I2.Increment_Effective_Date	 <= GETDATE() GROUP BY I2.Emp_ID
--	) I2 ON I1.Emp_ID=I2.Emp_ID and I1.Increment_Effective_Date=I2.Increment_Effective_Date GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID
--	END'
--END
--ELSE
--BEGIN
--	print @Rerun
--	SET @STR ='
--	Drop Table '+ @DyTble + '
--	IF NOT exists(select 1 from Sys.tables where name = ''' + @DyTble + ''')
--	BEGIN
--		SELECT I.Emp_ID,I.Branch_ID,I.Increment_ID 
--		into '+ @DyTble + '
--		FROM T0095_INCREMENT I  WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON I.EMP_ID=EM.EMP_ID INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
--		FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN (SELECT	Emp_ID, Max(Increment_Effective_Date) As Increment_Effective_Date FROM	T0095_INCREMENT I2 WITH (NOLOCK) WHERE	I2.Increment_Effective_Date	 <= GETDATE() GROUP BY I2.Emp_ID
--	) I2 ON I1.Emp_ID=I2.Emp_ID and I1.Increment_Effective_Date=I2.Increment_Effective_Date GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID
--	END'
--END
--execute sp_executesql @STR
