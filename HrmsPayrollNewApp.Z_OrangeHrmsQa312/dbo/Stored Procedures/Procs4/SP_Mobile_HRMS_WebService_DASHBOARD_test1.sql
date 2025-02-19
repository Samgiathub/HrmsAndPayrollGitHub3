
CREATE PROCEDURE[dbo].[SP_Mobile_HRMS_WebService_DASHBOARD_test1]
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0)
AS


DECLARE @FromDate DATETIME
DECLARE @ToDate DATETIME
DECLARE @Branch_ID int
DECLARE @CURRENTDATE DATETIME
DECLARE @SALSTDATE DATETIME
SET @CURRENTDATE = CAST(GETDATE() AS varchar(11))

SET @FromDate =  (DATEADD(dd,-(DAY(@CURRENTDATE)-1),@CURRENTDATE))
SET @ToDate = (DATEADD(dd,-(DAY(DATEADD(mm,1,@CURRENTDATE))),DATEADD(mm,1,@CURRENTDATE)))

Select @Branch_ID = Branch_ID from T0080_EMP_MASTER where EMP_ID = @Emp_ID and Cmp_ID = @Cmp_ID


SELECT Distinct @SALSTDATE = cast(Sal_St_Date as Date)
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


IF (DAY(GETDATE()) < DAY(@SALSTDATE))
	BEGIN
		SET @FromDate =  DATEADD(mm,-1,@SALSTDATE) -- Added by Niraj (02082022)
		SET @ToDate = DATEADD(MM,1,@SALSTDATE)-1 -- Added by Niraj (02082022)
		
	END
ELSE
	BEGIN
		SET @FromDate =  CAST(@SALSTDATE as Date) -- Added by Niraj (02082022)
		SET @ToDate = DATEADD(MM,1,@SALSTDATE)-1 -- Added by Niraj (02082022)
		
	END
	
EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET_HRMS_MOBILE @Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate,@Branch_ID=@Branch_ID,
@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = @Emp_ID,@Constraint='',@Report_for='Mobile In-Out'


--EXEC SP_RPT_EMP_INOUT_RECORD_GET_GRAPH @Cmp_ID = @Cmp_ID,@From_Date = @FromDate,@To_Date = @ToDate,@Branch_ID = 0,
--@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = @Emp_ID,@Constraint = '',@Report_call = 'SUMMARY'

DECLARE @Ip_Address varchar(50) = '' -- Addded by Niraj(10012022)
DECLARE @StartDate datetime  
DECLARE @EndDate datetime
DECLARE @BranchID numeric(18,0)
DECLARE @Setting_Value int
Declare @Month	 int =	0
Declare @Year	 int =	0

select @Month = Month(GETDATE())
select @Year = Year(GETDATE())

--IF @Type = 'S'     
--	BEGIN
		SET @StartDate = CONVERT(datetime, CAST(@Month as varchar) + '/01/' + CAST(@Year as varchar))  
		SET @EndDate = DATEADD(month, 1, CONVERT(datetime, CAST(@Month as varchar)+ '/01/' + CAST(@Year as varchar))) -1
		
		SELECT @BranchID = TIC.Branch_ID
		FROM T0095_INCREMENT TIC WITH (NOLOCK)
		INNER JOIN
		(
			SELECT MAX(IC.Increment_ID) AS 'Increment_ID' FROM T0095_INCREMENT IC WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date) AS 'Increment_Effective_Date',Emp_ID 
				FROM T0095_INCREMENT  WITH (NOLOCK)
				WHERE Emp_ID = @Emp_ID
				GROUP BY Emp_ID
			) TP ON IC.Increment_Effective_Date = TP.Increment_Effective_Date AND IC.Emp_ID = TP.Emp_ID
		) TTP ON TIC.Increment_ID = TTP.Increment_ID
		
		--EXEC Mobile_HRMS_SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID = @Cmp_ID,@From_Date = @StartDate,@To_Date = @EndDate,
		--@Branch_ID = @BranchID,@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = @Emp_ID,
		--@Constraint='',@Report_for='IN-OUT',@Graph_flag = '',@ReloadData = 1 -- Changed by Niraj (03012022)
		
		--select  MONTH(@StartDate),YEAR(@StartDate),@Emp_ID,@Cmp_ID 

		--SELECT Month_St_Date,ISNULL(Cutoff_Date,Month_End_Date) as Month_End_Date 
		--FROM T0200_MONTHLY_SALARY  WITH (NOLOCK)
		--WHERE MONTH(Month_End_Date)= MONTH(@StartDate) AND YEAR(Month_End_Date) = YEAR(@StartDate) AND Emp_ID=@Emp_ID  AND Cmp_ID=@Cmp_ID 

		SELECT Month_St_Date,ISNULL(Cutoff_Date,Month_End_Date) as Month_End_Date 
		FROM T0200_MONTHLY_SALARY  WITH (NOLOCK)
		WHERE MONTH(Month_End_Date)=  MONTH(@StartDate) AND YEAR(Month_End_Date) = YEAR(@StartDate) AND Emp_ID=@Emp_ID  AND Cmp_ID=@Cmp_ID 
		
		SELECT TOP 1 ISNULL(Inout_Days,0) Setting_Value,Attndnc_Reg_Max_Cnt,Sal_St_Date
		FROM T0040_General_Setting  WITH (NOLOCK)
		WHERE 
		--Cmp_Id = @Cmp_ID AND
		Branch_id = @BranchID AND For_Date = 
		(
			SELECT MAX(For_Date) 
			FROM T0040_GENERAL_SETTING  WITH (NOLOCK)
			WHERE For_Date <=GETDATE() AND 
			--Cmp_ID = @Cmp_ID AND 
			Branch_id = @BranchID
		)
			SELECT *
			FROM T0040_SETTING WITH (NOLOCK) 
			WHERE Setting_Name = 'Allow Employee to Regularize the Attendance even In & Out is missing' AND Cmp_ID = @Cmp_ID
--END
