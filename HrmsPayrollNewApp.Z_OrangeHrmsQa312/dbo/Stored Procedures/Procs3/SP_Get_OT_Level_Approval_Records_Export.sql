
-- =============================================
-- Author:		<Muslim Gadriwala>
-- Create date: <09102014,,>
-- Description:	<Get Record Level Approval>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_OT_Level_Approval_Records_Export] @Cmp_ID NUMERIC(18, 0)
	,@Emp_ID NUMERIC(18, 0)
	,@R_Emp_ID NUMERIC(18, 0)
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Rpt_level NUMERIC(18, 0)
	,@Return_Record_set TINYINT = 2
	,@constraint VARCHAR(max)
	,@Type NUMERIC(18, 0) = 0
	,@Dept_ID NUMERIC(18, 0)
	,@Grd_ID NUMERIC(18, 0)
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	DECLARE @Scheme_ID AS NUMERIC(18, 0)
	DECLARE @Leave AS VARCHAR(100)
	DECLARE @is_rpt_manager AS TINYINT
	DECLARE @is_branch_manager AS TINYINT
	DECLARE @SqlQuery AS NVARCHAR(max)
	DECLARE @SqlExcu AS NVARCHAR(max)
	DECLARE @MaxLevel AS NUMERIC(18, 0)
	DECLARE @Rpt_level_Minus_1 AS NUMERIC(18, 0)
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 31012018 

	
	DECLARE @Emp_ID_Cur NUMERIC(18, 0)
	DECLARE @is_res_passed TINYINT

	SET @Emp_ID_Cur = 0
	SET @is_res_passed = 0

	DECLARE @string_1 VARCHAR(MAX)

	--Added By Jimit 10102018
	CREATE TABLE #Emp_Cons1 (Emp_ID NUMERIC)

	CREATE UNIQUE CLUSTERED INDEX IX_Emp_Cons1_EMPID ON #Emp_Cons1 (EMP_ID);

	WITH RankedEmployees AS (
    SELECT 
        emp_ID,For_Date
    FROM T0115_OT_LEVEL_APPROVAL
	where cmp_ID = @Cmp_ID AND  S_Emp_Id = @R_Emp_ID  AND For_Date between @From_Date and @To_Date
	group by Emp_ID,For_Date
)
SELECT  RS.Emp_ID,RS.For_Date
,EMPS.Scheme_ID,EMPS.App_Emp_ID,EMPS.Rpt_Level INTO #Emp_OT_LISt
FROM RankedEmployees RS
INNER JOIN (
			select EMPSP.Emp_ID,SD.Scheme_Id,EMPSP.Effective_Date,App_Emp_ID,Rpt_Level from T0050_Scheme_Detail SD
LEFT JOIN T0095_EMP_SCHEME EMPSP ON EMPSP.Scheme_ID = SD.Scheme_Id and SD.Rpt_Level >= 1
INNER JOIN (select  Emp_ID,MAX(Effective_Date)Effective_Date from T0095_EMP_SCHEME  where Cmp_ID = @Cmp_ID  and [Type] = 'Over Time' group by Emp_ID
) EMPSC ON EMPSP.Emp_ID = EMPSC.Emp_ID and EMPSP.Effective_Date = EMPSC.Effective_Date and EMPSP.[Type] = 'Over Time'

) EMPS ON EMPS.Emp_ID = RS.Emp_ID 


--delete from #Emp_OT_LISt where S_Emp_Id <> @R_Emp_ID and App_Emp_ID = 0	
--update   #Emp_OT_LISt SET App_Emp_ID = @R_Emp_ID where App_Emp_ID = 0



update EOL SET EOL.App_Emp_ID = T.R_Emp_ID  FROM  #Emp_OT_LISt EOL 
LEFT JOIN (
select RPD.* from T0090_EMP_REPORTING_DETAIL RPD
INNER JOIN (select Emp_ID,max(Effect_Date)Effect_Date from T0090_EMP_REPORTING_DETAIL group by Emp_ID ) RD ON RD.Emp_ID = RPD.EMp_ID	AND RD.Effect_Date = RPD.Effect_Date 
)T ON T.Emp_ID = EOL.Emp_ID
where EOL.App_Emp_ID = 0
--////// Delete  Records after first level rejewcted, because second level not going according to setting  ///////////////////////////

DELETE EOL from #Emp_OT_LISt EOL
INNER JOIN (
select ESL.Emp_ID,ESL.For_Date,ESl.Rpt_Level from #Emp_OT_LISt ESL
LEFT JOIN T0115_OT_LEVEL_APPROVAL OTL ON OTL.emp_Id = Esl.Emp_ID and OTL.s_emp_id = Esl.app_emp_id  AND Esl.For_Date = OTL.For_Date
where  OTL.Is_Approved = 0 AND OTL.Is_Fwd_OT_Rej = 0) T
ON T.Emp_ID = EOL.Emp_ID AND EOL.For_Date = T.For_Date AND EOL.Rpt_Level > T.Rpt_Level 

--select * from #Emp_OT_LISt

--////// Delete  Records before reporting data at final level approval login  ///////////////////////////

--DELETE EOL from #Emp_OT_LISt EOL
--INNER JOIN (
--select ESL.Emp_ID,ESL.For_Date,ESl.Rpt_Level from #Emp_OT_LISt ESL
--LEFT JOIN T0115_OT_LEVEL_APPROVAL OTL ON OTL.emp_Id = Esl.Emp_ID and OTL.s_emp_id = Esl.app_emp_id  AND Esl.For_Date = OTL.For_Date
--where  OTL.Final_Approver = 1 AND OTL.S_Emp_Id = @R_Emp_ID
--) T
--ON T.Emp_ID = EOL.Emp_ID AND EOL.For_Date = T.For_Date AND EOL.Rpt_Level < T.Rpt_Level 



--///////////////////////////// Get column count for dynamic table /////////////////////
select max(Rpt_Level)Rpt_Level from #Emp_OT_LISt
--/////////////////////////////////////////////////////
select CONCAT(EMPs.Alpha_Emp_Code,' - ',EMPS.Emp_Full_Name)Emp_Full_Name,Esl.For_Date
,CASE WHEN Esl.App_Emp_ID = OTL.S_Emp_Id AND OTL.Is_Approved = 1 THEN 'Approved' 
		WHEN Esl.App_Emp_ID = OTL.S_Emp_Id AND OTL.Is_Approved = 0 THEN 'Rejected' 
		Else 'Pending' END as 'Status'
,dbo.F_Return_Hours(OTl.Approved_OT_Sec + OTL.Approved_HO_OT_Sec + OTL.Approved_WO_OT_Sec) as 'OT_Hours'
,CONCAT(EMp.Alpha_Emp_Code, '-' ,  Emp.Emp_Full_Name) as R_Emp_Full_Name
,ESL.Rpt_Level
INTO #FInal_Data
from #Emp_OT_LISt Esl
LEFT JOIN T0115_OT_LEVEL_APPROVAL OTL ON OTL.emp_Id = Esl.Emp_ID and OTL.s_emp_id = Esl.app_emp_id  AND Esl.For_Date = OTL.For_Date
LEFT JOIN T0080_EMP_MASTER EMPS ON EMPS.Emp_ID = Esl.Emp_ID
LEFT JOIN T0080_EMP_MASTER EMP ON EMP.Emp_ID = Esl.App_Emp_ID

select Emp_Full_Name as Emp_ID,For_Date,[status],OT_Hours,R_Emp_Full_Name as Emp_Full_Name  from #FInal_Data 
order by Emp_id,For_Date,Rpt_Level


----DECLARE @Product_Names VARCHAR(MAX);
----SELECT @Product_Names = COALESCE(@Product_Names + ',' + Emp_Full_Name,Emp_Full_Name)
----FROM #FInal_Data;

--SELECT Emp_Full_Name + ' , ' + OT_Hours + ' , ' + [Status] + ' , '
--FROM #FInal_Data FOR XML PATH ('')



END