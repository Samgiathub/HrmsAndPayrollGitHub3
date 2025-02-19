-- exec JP0001_LeaveCarryForwardNightProcess
create PROCEDURE [dbo].[JP0001_LeaveCarryForwardNightProcess_Stage2]  
	
AS
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

Declare @StartDate As DATE= NULL
Declare @EndDate As DATE= NULL
Declare @ForDate As DATE= NULL

-- Current month
--SET @StartDate = Cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as DATE)
--SET @EndDate =   CAST(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0)) as DATE)
--END Current Month
SET @StartDate = Cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as DATE)
SET @EndDate =   CAST(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(m, 0, GETDATE()), 0)) as DATE)
SET @ForDate = cast(GETDATE()-1 as date)

--select @StartDate,@EndDate


--set @STARTDATE = '2024-02-21 00:00:00.000'
--set @ENDDATE = '2024-03-20 00:00:00.000'
--SET @ForDate = '2024-04-01 00:00:00.000'
DECLARE @salary_st_date as DATE 

DECLARE @EMP_ID as bigint
DECLARE @CNT as int = 1
DECLARE @ROWCNT as int

DECLARE @CNTCMP as int = 1
DECLARE @ROWCNTCMP as int = 0

DECLARE @Cmp_id as int = 0
DECLARE @Branch_Id as int = 0

	SELECT ROW_NUMBER() OVER(ORDER BY CM.CMP_ID) AS RowNoCmp, CM.CMP_ID ,BM.BRANCH_ID INTO #TMPCMPBRANCH 
	FROM T0010_COMPANY_MASTER CM INNER JOIN T0030_BRANCH_MASTER BM ON CM.CMP_ID = BM.CMP_ID WHERE IS_ACTIVE = 1 ORDER BY CMP_ID,BRANCH_ID
	
	SELECT @ROWCNTCMP = count(1) from #TMPCMPBRANCH
	WHILE (@CNTCMP <= @ROWCNTCMP)
	BEGIN
		
			SELECT @Cmp_id = Cmp_Id, @Branch_Id = Branch_ID FROM #TMPCMPBRANCH where RowNoCmp =  @CNTCMP
			
			SELECT @salary_st_date = max(sal_st_Date) from T0040_GENERAL_SETTING where cmp_id = @Cmp_ID and Branch_ID = @Branch_ID
			--select @StartDate = DATEADD(M,-1,DATEADD(D,DAY(@salary_st_date)-1,@StartDate)) , @EndDate = DATEADD(D,DAY(@salary_st_date)-2,@EndDate)
			if DAY(@salary_st_date) != 1
			BEGIN
				--select @salary_st_date,@Branch_Id,@StartDate,@EndDate,DATEADD(M,-1,DATEADD(D,DAY(@salary_st_date)-1,@StartDate)) ,  DATEADD(D,DAY(@salary_st_date)-2,@StartDate),@ForDate
				select @StartDate = DATEADD(M,-1,DATEADD(D,DAY(@salary_st_date)-1,@StartDate)) , @EndDate =  DATEADD(D,DAY(@salary_st_date)-2,@StartDate)
			END
			
			--IF OBJECT_ID('tempdb..#tmpEmpCons_NigthProcess') IS NOT NULL
			--		 Drop TABLE #tmpEmpCons_NigthProcess
			--
			--SELECT  ROW_NUMBER() OVER(order by EMP_ID) RowNo ,*  into #tmpEmpCons_NigthProcess from T0001_EmpCons_NigthProcess where Branch_ID = @Branch_Id
			
				DECLARE @STR as Nvarchar(MAX) = ''
			
				--SELECT @ROWCNT = count(1) from  #tmpEmpCons_NigthProcess 
				--WHILE (@CNT <= @ROWCNT)
				--BEGIN
					--SET @EMP_ID = 0
					--SELECT @EMP_ID = EMP_Id from #tmpEmpCons_NigthProcess where RowNo = @cnt	
				
					--set @STR = 'insert into T0001_LEAVECF_NightProcess (Cmp_ID,Branch_Id,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)
					--EXEC SP_LEAVE_CF_Display_NightProcess  0,'+ cast(@Cmp_id as nvarchar(2)) +', ''' + cast(@StartDate as nvarchar(50)) + ''',''' + cast(@EndDate as nvarchar(50)) + ''',''' + cast(@ForDate as nvarchar(50)) + ''',0,0,0,0,0,0,'+ CAST(@EMP_ID as Varchar(50)) +' ,'''',60,0,0,0,0'
					
					--set @STR = 'EXEC SP_LEAVE_CF_Display_NightProcess  0,'+ cast(@Cmp_id as nvarchar(2)) +', ''' + cast(@StartDate as nvarchar(50)) + ''',''' + cast(@EndDate as nvarchar(50)) + ''',''' + cast(@ForDate as nvarchar(50)) + ''',0,0,0,0,0,0,'+ CAST(@EMP_ID as Varchar(50)) +' ,'''',60,0,0,0,0'
					SET @STR = 'insert into T0001_LEAVECF_NightProcess (Cmp_ID,Branch_Id,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)
								EXEC SP_LEAVE_CF_Display_NightProcess  0,'+ cast(@Cmp_id as nvarchar(2)) +', ''' + cast(@StartDate as nvarchar(50)) + ''',''' + cast(@EndDate as nvarchar(50)) + ''',''' + cast(@ForDate as nvarchar(50)) + ''','''+ cast(@Branch_Id as nvarchar(50)) +''', 0,0,0,0,0,0,'''',60,0,0,0,0' -- BranchId
					EXEC sp_executesql  @STR
					--set @CNT = @CNT + 1
				--END
			

		SET @CNTCMP = @CNTCMP + 1
	ENd
END

