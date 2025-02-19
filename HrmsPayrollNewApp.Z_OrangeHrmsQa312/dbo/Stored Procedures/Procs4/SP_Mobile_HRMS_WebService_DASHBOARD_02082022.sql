

CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_DASHBOARD_02082022]
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0)
AS


DECLARE @FromDate DATETIME
DECLARE @ToDate DATETIME
DECLARE @CURRENTDATE DATETIME
DECLARE @SALSTDATE DATETIME
SET @CURRENTDATE = CAST(GETDATE() AS varchar(11))

--SET @FromDate =  (DATEADD(dd,-(DAY(@CURRENTDATE)-1),@CURRENTDATE))
--SET @ToDate = (DATEADD(dd,-(DAY(DATEADD(mm,1,@CURRENTDATE))),DATEADD(mm,1,@CURRENTDATE)))

SELECT @SALSTDATE = cast(Sal_St_Date as Date)
					from T0040_GENERAL_SETTING where Branch_ID = ( 
					    SELECT distinct I.branch_id
						FROM   t0095_increment I 
						INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
						FROM   t0095_increment 
						WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
						GROUP  BY emp_id) Qry 
						ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
						where I.Emp_ID = @Emp_ID)

set @SALSTDATE = cast(Year(GETDATE()) as varchar(4)) +'-'+  DATENAME(mm, GETDATE()) + '-' + cast(DAY(@SALSTDATE) as varchar(2))

SET @FromDate =  cast(@SALSTDATE as date) 
SET @ToDate = DATEADD(mm,1,@SALSTDATE)-1

EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate,@Branch_ID=1,
@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = @Emp_ID,@Constraint='',@Report_for='Mobile In-Out'


--EXEC SP_RPT_EMP_INOUT_RECORD_GET_GRAPH @Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate,@Branch_ID = 0,
--@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = @Emp_ID,@Constraint = '',@Report_call = 'SUMMARY'

