-- exec JP0001_LeaveCarryForwardNightProcess
CREATE PROCEDURE [dbo].[JP0001_LeaveCarryForwardNightProcess_Stage1]  
	
AS
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

Declare @StartDate As DATE= NULL
Declare @EndDate As DATE= NULL
Declare @ForDate As DATE= NULL
SET @StartDate = Cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as DATE)
SET @EndDate =   CAST(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0)) as DATE)
SET @ForDate = GETDATE()

set @STARTDATE = '2024-02-21 00:00:00.000'
set @ENDDATE = '2024-03-20 00:00:00.000'
SET @ForDate = '2024-04-01 00:00:00.000'

DECLARE @Cmp_id as int = 1
DECLARE @EMP_ID as bigint
DECLARE @CNT as int = 1
DECLARE @ROWCNT as int

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
		
		select @MaxLeaveCFId = MAX(isnull(LEAVE_CF_ID,0)) + 1 from T0001_LEAVECF_NightProcess
		
		set @STR = '--insert into T0001_LEAVECF_NightProcess (Cmp_ID,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)
		EXEC SP_LEAVE_CF_Display_NightProcess  0,'+ cast(@Cmp_id as nvarchar(2)) +', ''' + cast(@StartDate as nvarchar(50)) + ''',''' + cast(@EndDate as nvarchar(50)) + ''',''' + cast(@ForDate as nvarchar(50)) + ''',0,0,0,0,0,0,'+ CAST(@EMP_ID as Varchar(50)) +' ,'''',60,0,0,0,0'
		select @STR
		exec sp_executesql  @STR
		
		set @CNT = @CNT + 1
	END
END

