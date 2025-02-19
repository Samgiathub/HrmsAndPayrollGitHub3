-- exec JP0001_LeaveCarryForwardNightProcess
CREATE PROCEDURE [dbo].[JP0001_LeaveCarryForwardNightProcess]  
	
AS
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN


Insert into T0001_LEAVECF_NightProcess_History
select Cmp_ID,Branch_ID,Grd_ID,Dept_ID,Desig_ID,Cat_ID,Type_ID,Segment_ID,subBranch_ID,Vertical_ID,SubVertical_ID,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days
,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance
,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance,Month,Year,GETDATE() 
from T0001_LEAVECF_NightProcess

TRUNCATE TABLE T0001_LEAVECF_NightProcess
TRUNCATE TABLE tblLeaveCarryNightProcess

Declare @StartDate As DATE= NULL
Declare @EndDate As DATE= NULL
Declare @ForDate As DATE= NULL

-- Current month
--SET @StartDate = Cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as DATE)
--SET @EndDate =   CAST(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0)) as DATE)
--END Current Month
SET @StartDate	=	Cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as DATE)
SET @EndDate	=	CAST(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(m, 0, GETDATE()), 0)) as DATE)
SET @ForDate	=	Cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as DATE) --'2024-07-01'--cast(GETDATE()-1 as date)

SET @StartDate = '2024-12-01'	
SET @EndDate =   '2024-12-31'
SET @ForDate = '2025-01-01'

DECLARE @EMP_ID as bigint
DECLARE @CNT as int = 1
DECLARE @ROWCNT as int = 0
DECLARE @CNTCMP as int = 1
DECLARE @ROWCNTCMP as int = 0
DECLARE @Cmp_id as int = 0

	DECLARE @Cmp_Name AS varchar(100)
	DECLARE @Leave_ID AS NUMERIC
	DECLARE @Leave_CF_Type AS VARCHAR(32)
	DECLARE @Leave_CF_ID NUMERIC
	DECLARE @CF_DAYS	NUMERIC(18,4)
	DECLARE @LeaveIDs	Varchar(1024)

	DECLARE @Start_Date AS DATETIME
	DECLARE @End_Date AS DATETIME
	DECLARE @For_Date AS DATETIME
	DECLARE @From_Date AS DATETIME
	DECLARE @To_Date AS DATETIME
	DECLARE @Is_Success AS INT  -- = 0
	DECLARE @Message AS varchar(50) -- = ''
	DECLARE @Advance_Leave_Balance NUMERIC(18,2)

	DECLARE @CF_Leave_Days	NUMERIC(18,4) 
	Declare @Tran_type_flag varchar(30)
	Declare @CF_Type varchar(30)	
	
	DECLARE @CF_For_Date	 AS DATETIME
	DECLARE @CF_From_Date	 AS DATETIME
	DECLARE @CF_To_Date		AS DATETIME
	
			SELECT  ROW_NUMBER() OVER(order by EMP_ID) RowNo ,* into #TMPCMPBRANCH 
			from T0001_EmpCons_NigthProcess 
			--where 
			--Cmp_Id = 13 -- Cmp_id
			--emp_Id in (11160) 

			SELECT @ROWCNTCMP = count(1) from #TMPCMPBRANCH
			WHILE (@CNTCMP <= @ROWCNTCMP)
			BEGIN
				SET @EMP_ID = 0
				SELECT @EMP_ID = EMP_Id,@Cmp_id = CMP_ID from #TMPCMPBRANCH where RowNo = @CNTCMP	

				IF OBJECT_ID('tempdb..#tmpLeave') IS NOT NULL
						Drop TABLE #tmpLeave
				
				-- Below query to check the grade is assign to any Leaveid or not. 
					select ROW_NUMBER() OVER(order by Leave_Name) RowNo , * into #tmpLeave from (
					SELECT DISTINCT L.Leave_ID ,Leave_Name
					FROM T0040_Leave_MASTER L inner join T0050_LEAVE_DETAIL LD on L.Leave_ID = LD.Leave_ID
					WHERE Leave_Type <> 'Paternity Leave' 
					AND (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>=getdate() then 1 else 0 end ) else 1 end )) 
					--AND L.Cmp_ID = 13 -- Cmp_id
					and (leave_cf_type not in('None','0')) 
					UNION
					SELECT DISTINCT L.Leave_ID ,Leave_Name
					FROM T0040_Leave_MASTER L 
					inner join T0050_LEAVE_DETAIL LD on L.Leave_ID = LD.Leave_ID
					Inner join T0050_CF_EMP_TYPE_DETAIL CFTD on L.Leave_ID = CFTD .Leave_ID
					WHERE Leave_Type <> 'Paternity Leave' 
					AND (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>=getdate() then 1 else 0 end ) else 1 end )) 
					--AND L.Cmp_ID = 13 -- Cmp_id
					and (leave_cf_type not in('None','0')) and CFTD.Duration = 'Yearly'  and MONTH(@StartDate) = Release_Month - 1
				) s
			
			-- #tmpLeave --delete query

				DECLARE @STR as Nvarchar(MAX) = ''
				DECLARE @STR1 as Nvarchar(MAX) = ''
				DECLARE @LeaveId int = 0
				set @CNT = 1
				SELECT @ROWCNT = count(1) from  #tmpLeave
				WHILE (@CNT <= @ROWCNT)
				BEGIN	
					SET @LeaveId = 0
					SELECT @LeaveId = Leave_ID from #tmpLeave where RowNo = @cnt	
					
					IF NOT EXISTS (Select  1 from T0100_LEAVE_CF_DETAIL where emp_Id = @EMP_ID and Cmp_ID =  @Cmp_id and Leave_ID = @LeaveId 
					and cast(CF_From_Date as date) = cast(@StartDate as date) and  cast(CF_To_Date as date) = cast(@EndDate as DATE) and cast(CF_For_Date as date) =  cast(@EndDate as DATE))
					BEGIN
							SET @STR = 'insert into T0001_LEAVECF_NightProcess (Cmp_ID,Branch_Id,Grd_ID,Dept_ID,Desig_ID,Cat_ID,Type_ID,Segment_ID,subBranch_ID,Vertical_ID,SubVertical_ID,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance,Month,Year)
										EXEC SP_LEAVE_CF_Display_NightProcess  0,'+ cast(@Cmp_id as nvarchar(2)) +', ''' + cast(@StartDate as nvarchar(50)) + ''',''' + cast(@EndDate as nvarchar(50)) + ''',''' + cast(@ForDate as nvarchar(50)) + ''',0,0,0,0,0,0,'''+ CAST(@EMP_ID as Varchar(50)) +''','''','''+ cast(@LeaveId as nvarchar(50)) +''',0,0,0,0' -- BranchId
							 
							EXEC sp_executesql  @STR
									
							--if (isnull(@@IDENTITY,0) >= 1)
							--BEGIN
							
							--	Select @Leave_ID = Leave_ID ,@CF_For_Date = CF_For_Date ,@CF_From_Date =  CF_From_Date , @CF_To_Date = CF_To_Date
							--	,@CF_DAYS = CF_P_Days,@CF_Leave_Days = CF_Leave_Days ,@Advance_Leave_Balance = Advance_Leave_Balance ,@CF_Type =  CF_Type
							--	from   T0001_LEAVECF_NightProcess where LEAVE_CF_ID = @@IDENTITY
							--	print @Leave_ID
							--	EXEC P0100_LEAVE_CF_DETAIL 
							--							@Leave_CF_ID=@Leave_CF_ID output,
							--							@Cmp_ID=@Cmp_id,
							--							@Emp_ID=@Emp_ID,
							--							@Leave_ID=@Leave_ID,
							--							@CF_For_Date=@CF_For_Date,
							--							@CF_From_Date=@CF_From_Date,
							--							@CF_To_Date=@CF_To_Date,
							--							@CF_P_Days=@CF_DAYS,
							--							--@CF_Leave_Days=,
							--							@CF_Leave_Days=@CF_Leave_Days,
							--							@CF_Type=@CF_Type,
							--							@tran_type='Insert',
							--							@Leave_CompOff_Dates='',
							--							@Reset_Flag='1',
							--							@User_Id='0',
							--							@IP_Address='192.168.1.255',
							--							@Advance_Leave_Balance=@Advance_Leave_Balance,
							--							@Advance_Leave_Recover_Balance='0',
							--							@New_Joing_Falg='0',
							--							@Login_ID=0

							--END

							set @STR1 = 'Insert into tblLeaveCarryNightProcess values  (''' + replace (@STR , '''', '''''')+''')'
							EXEC sp_executesql  @STR1
					END	
					set @CNT = @CNT + 1
				END
				SET @CNTCMP = @CNTCMP + 1
			END
END
