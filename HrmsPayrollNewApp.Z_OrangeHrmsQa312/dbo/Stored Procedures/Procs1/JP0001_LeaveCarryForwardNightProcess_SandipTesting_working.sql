
-- exec JP0001_LeaveCarryForwardNightProcess_SandipTesting_working 13,0 ,'2024-07-01' ,'2024-06-01','2024-06-30'
CREATE PROCEDURE [dbo].[JP0001_LeaveCarryForwardNightProcess_SandipTesting_working]  
	@CmpId int,
	@LeavId int,
	@ForData Datetime,
	@FromData Datetime,
	@ToData Datetime
AS

SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
BEGIN

Insert into T0001_LEAVECF_NightProcess_History
select Cmp_ID,Branch_ID,Grd_ID,Dept_ID,Desig_ID,Cat_ID,Type_ID,Segment_ID,subBranch_ID,Vertical_ID,SubVertical_ID,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days
,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance
,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance,Month,Year from T0001_LEAVECF_NightProcess

TRUNCATE TABLE T0001_LEAVECF_NightProcess
TRUNCATE TABLE tblLeaveCarryNightProcess

Declare @StartDate As DATE= NULL
Declare @EndDate As DATE= NULL
Declare @ForDate As DATE= NULL

SET @StartDate = @FromData 
SET @EndDate   = @ToData 
SET @ForDate   = @ForData 

DECLARE @EMP_ID as bigint
DECLARE @CNT as int = 1
DECLARE @ROWCNT as int = 0
DECLARE @CNTCMP as int = 1
DECLARE @ROWCNTCMP as int = 0
DECLARE @Cmp_id as int = @CmpId 
	
			SELECT  ROW_NUMBER() OVER(order by EMP_ID) RowNo ,* into #TMPCMPBRANCH 
			from T0001_EmpCons_NigthProcess 
			where emp_Id in (762,300,759)
			--where emp_Id = 762
		
			SELECT @ROWCNTCMP = count(1) from #TMPCMPBRANCH
			WHILE (@CNTCMP <= @ROWCNTCMP)
			BEGIN
				SET @EMP_ID = 0
				SELECT @EMP_ID = EMP_Id from #TMPCMPBRANCH where RowNo = @CNTCMP	

				IF OBJECT_ID('tempdb..#tmpLeave') IS NOT NULL
						Drop TABLE #tmpLeave

				--SELECT ROW_NUMBER() OVER(order by Leave_Name) RowNo ,Leave_ID INTO #tmpLeave
				--FROM T0040_Leave_MASTER 
				--WHERE Leave_Type <> 'Paternity Leave' 
				--AND (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>=getdate() then 1 else 0 end ) else 1 end )) 
				--AND Cmp_ID = @Cmp_id and (leave_cf_type not in('None','0')) and Leave_Id in (77)
				--ORDER BY Leave_Name	
				
				-- Below query to check the grade is assign to any Leaveid or not. 
				select ROW_NUMBER() OVER(order by Leave_Name) RowNo , * into #tmpLeave from (
					SELECT DISTINCT L.Leave_ID ,Leave_Name
					FROM T0040_Leave_MASTER L inner join T0050_LEAVE_DETAIL LD on L.Leave_ID = LD.Leave_ID
					WHERE Leave_Type <> 'Paternity Leave' 
					AND (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>=getdate() then 1 else 0 end ) else 1 end )) 
					AND L.Cmp_ID = 13 and (leave_cf_type not in('None','0')) --and Leave_Id in (77)
				) s
				
				DECLARE @STR as Nvarchar(MAX) = ''
				DECLARE @STR1 as Nvarchar(MAX) = ''
				DECLARE @LeaveId int = 0
				set @CNT = 1
				SELECT @ROWCNT = count(1) from  #tmpLeave
				WHILE (@CNT <= @ROWCNT)
				BEGIN	
					SET @LeaveId = 0
					SELECT @LeaveId = Leave_ID from #tmpLeave where RowNo = @cnt	
				select @LeaveId
					SET @STR = 'insert into T0001_LEAVECF_NightProcess (Cmp_ID,Branch_Id,Grd_ID,Dept_ID,Desig_ID,Cat_ID,Type_ID,Segment_ID,subBranch_ID,Vertical_ID,SubVertical_ID,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance,Month,Year)
								EXEC SP_LEAVE_CF_Display_NightProcess  0,'+ cast(@Cmp_id as nvarchar(2)) +', ''' + cast(@StartDate as nvarchar(50)) + ''',''' + cast(@EndDate as nvarchar(50)) + ''',''' + cast(@ForDate as nvarchar(50)) + ''',0,0,0,0,0,0,'''+ CAST(@EMP_ID as Varchar(50)) +''','''','''+ cast(@LeaveId as nvarchar(50)) +''',0,0,0,0' -- BranchId

					set @STR1 = 'Insert into tblLeaveCarryNightProcess values  (''' + replace (@STR , '''', '''''')+''')'
					EXEC sp_executesql  @STR1

					EXEC sp_executesql  @STR
							
					set @CNT = @CNT + 1
				END
				SET @CNTCMP = @CNTCMP + 1
			END
END
