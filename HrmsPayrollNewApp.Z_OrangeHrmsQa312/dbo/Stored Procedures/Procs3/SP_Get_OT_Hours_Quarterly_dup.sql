
-- =============================================
-- Author:		<Muslim Gadriwala>
-- Create date: <09102014,,>
-- Description:	<Get Record Level Approval>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_OT_Hours_Quarterly_dup] 
	@Cmp_ID NUMERIC(18, 0)
	,@Branch_ID NUMERIC(18, 0) = 26
	,@MonthStr nvarchar(Max)
	,@AfterApprove tinyint =0
	,@salry_Cycle Tinyint = 0
	,@Rpt_level tinyint = 0
AS
BEGIN
	

DECLARE @salary_st_date DATE 



Truncate Table T0040_Quarter_Details_Salarywise




	CREATE TABLE #Emp_Cons 
			(  
				Emp_ID NUMERIC ,
				Branch_ID NUMERIC, 
				Alpha_Emp_Code NUMERIC(18),
				Emp_Full_Name varchar(100),
				QMonth NUMERIC(2),
				Qdate NUMERIC(2),
				Qyear NUMERIC(4),
				TOT_Qt_Hours_limit NUMERIC(18,2),
				Approved_Hours NUMERIC(18,2),
				Qtr_OT_Hrs_Available NUMERIC(18,2),
				Qtr_Date varchar(100),
				QTR tinyint,
				CMP_ID Int
			);
			CREATE TABLE #Emp_Cons_Cycle 
			(  
				Emp_ID NUMERIC ,   
				Alpha_Emp_Code NUMERIC(18),
				Emp_Full_Name varchar(100),
				QMonth NUMERIC(2),
				Qdate NUMERIC(2),
				Qyear NUMERIC(4),
				TOT_Qt_Hours_limit NUMERIC(18,2),
				Approved_Hours NUMERIC(18,2),
				Qtr_OT_Hrs_Available NUMERIC(18,2),
				Qtr_Date varchar(100),
				QTR tinyint,
				CMP_ID Int
			);

select  SUBSTRING(Data, 1, (CHARINDEX ('-', Data)-1))Emp_ID,SUBSTRING(Data, (CHARINDEX ('-', Data)+4),2)QMonth
,SUBSTRING(Data, (CHARINDEX ('-', Data)+1),2)QDate,SUBSTRING(Data, (CHARINDEX ('-', Data)+7),4)Qyear into #temp FROM  dbo.split(@MonthStr, ',')


--insert into #Emp_Cons (Cmp_ID,Emp_ID,QMonth,Qdate,Qyear)
--select @Cmp_ID,Emp_ID,QMonth,QDate,Qyear
--from #temp group by Emp_ID,QMonth,QDate,Qyear

insert into #Emp_Cons (Cmp_ID,Emp_ID,Branch_ID,QMonth,Qdate,Qyear)
SELECT @Cmp_ID,I.Emp_Id,isnull(I.Branch_ID ,0) as Branch_Id,QMonth,QDate,Qyear
	FROM	
	T0095_Increment I WITH (NOLOCK)
	INNER JOIN  
	( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
       FROM T0095_INCREMENT I2 INNER JOIN 
       (
                    SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
                     FROM T0095_INCREMENT I3 
					Inner join #temp EC on I3.Emp_id = EC.Emp_id and I3.INCREMENT_EFFECTIVE_DATE <= GETDATE()
					WHERE  I3.Cmp_ID = 1 
					and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation' 
                     GROUP BY I3.EMP_ID  
        ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
        WHERE I2.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I2.Cmp_ID = 1 
	   and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
        GROUP BY I2.emp_ID  
     ) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID 
	 inner join #temp t on I.Emp_ID = t.Emp_ID

--/////////////////////////////////// Cursor for Branchwise quarter Date ////////////////////////////////////////////////////
DECLARE @CBranch_id int,@Qyear int ;


DECLARE branch_cursor CURSOR FOR
SELECT distinct Branch_ID,Qyear
FROM #Emp_Cons;

OPEN branch_cursor

FETCH NEXT FROM branch_cursor
INTO @CBranch_id,@Qyear


WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @salary_st_date=max(sal_st_Date) from T0040_GENERAL_SETTING where cmp_id=@Cmp_ID and Branch_ID=@CBranch_id

	insert into T0040_Quarter_Details_Salarywise (Cmp_ID,Month_St_Date,Month_End_Date,Qtr)
	select @Cmp_ID,DATEADD(d,DAY(@salary_st_date )-1,DATEADD(M,-1,dateadd(M, (3*1)-3, CONVERT(date, CONVERT(varchar(5),@Qyear)+'-1-1')))),DATEADD(D,DAY(@salary_st_date)-1,DATEADD(M,-1,dateadd(D,-1,dateadd(M, 3*1, CONVERT(date, CONVERT(varchar(5),@Qyear)+'-1-1'))))),'1'
	--from #Emp_Cons group by Emp_ID,QMonth,Qyear

	insert into T0040_Quarter_Details_Salarywise (Cmp_ID,Month_St_Date,Month_End_Date,Qtr)
	select @Cmp_ID,DATEADD(d,DAY(@salary_st_date )-1,DATEADD(M,-1,dateadd(M, (3*2)-3, CONVERT(date, CONVERT(varchar(5),Qyear)+'-1-1')))),DATEADD(D,DAY(@salary_st_date),DATEADD(M,-1,dateadd(D,-1,dateadd(M, 3*2, CONVERT(date, CONVERT(varchar(5),Qyear)+'-1-1'))))),'2'
	from #Emp_Cons group by Emp_ID,QMonth,Qyear
	insert into T0040_Quarter_Details_Salarywise (Cmp_ID,Month_St_Date,Month_End_Date,Qtr)
	select @Cmp_ID,DATEADD(d,DAY(@salary_st_date )-1,DATEADD(M,-1,dateadd(M, (3*3)-3, CONVERT(date, CONVERT(varchar(5),Qyear)+'-1-1')))),DATEADD(D,DAY(@salary_st_date),DATEADD(M,-1,dateadd(D,-1,dateadd(M, 3*3, CONVERT(date, CONVERT(varchar(5),Qyear)+'-1-1'))))),'3'
	from #Emp_Cons group by Emp_ID,QMonth,Qyear
	insert into T0040_Quarter_Details_Salarywise (Cmp_ID,Month_St_Date,Month_End_Date,Qtr)
	select @Cmp_ID,DATEADD(d,DAY(@salary_st_date )-1,DATEADD(M,-1,dateadd(M, (3*4)-3, CONVERT(date, CONVERT(varchar(5),Qyear)+'-1-1')))),DATEADD(D,DAY(@salary_st_date)-1,DATEADD(M,-1,dateadd(D,-1,dateadd(M, 3*4, CONVERT(date, CONVERT(varchar(5),Qyear)+'-1-1'))))),'4'
	from #Emp_Cons group by Emp_ID,QMonth,Qyear  

    FETCH NEXT FROM branch_cursor
INTO @CBranch_id,@Qyear

END
CLOSE branch_cursor;
DEALLOCATE branch_cursor;

--/////////////////////////////////////////////// End Cursor ///////////////////////////////////////////////////////////

select * from T0040_Quarter_Details_Salarywise

return
		UPDATE	#Emp_Cons 
			SET	QTR =  QTRD.Qtr
			FROM	#Emp_Cons EC
			INNER JOIN T0040_Quarter_Details_Salarywise QTRD ON  EC.CMP_ID = QTRD.Cmp_ID
			where 	DATEFROMPARTS(EC.Qyear,EC.QMonth,EC.Qdate) between DATEFROMPARTS(YEAR(QTRD.Month_St_Date),MONTH(QTRD.Month_St_Date),DAY(QTRD.Month_St_Date)) and DATEFROMPARTS(YEAR(QTRD.Month_End_Date),MONTH(QTRD.Month_End_Date),DAY(QTRD.Month_End_Date)) 	
		
		DELETE b from (
		Select ROW_NUMBER() OVER(Partition by Emp_ID,QTR order by EMP_ID) as RN,* 
		from (
		select * from #Emp_Cons
		) a
		) b where b.rn > 1

		--select * from #Emp_Cons
		--return

insert into #Emp_Cons_Cycle (Cmp_ID,Emp_ID,QMonth,Qdate,Qyear)
select @Cmp_ID,Emp_ID,QMonth,QDate,Qyear
from #temp group by Emp_ID,QMonth,QDate,Qyear

		--select Replace(dbo.f_return_HOURs(dbo.F_Get_OT_QUARTERLYHOURS_New(@Cmp_ID,EC.Emp_ID,DATEFROMPARTS(YEAR(GETDATE()),EC.QMonth,1),@salry_Cycle,@Rpt_level )),':','.'),* from #Emp_Cons_Cycle EC
		
		
		UPDATE	#Emp_Cons 
		SET		
		Alpha_Emp_Code=Emp.Alpha_Emp_Code,
		Emp_Full_Name= Emp.Emp_Full_Name,
		TOT_Qt_Hours_limit = Aset.Setting_value,
		Approved_Hours = (select Replace(dbo.f_return_HOURs(dbo.F_Get_OT_QUARTERLYHOURS_New(@Cmp_ID,EC.Emp_ID,DATEFROMPARTS(Ec.Qyear,EC.QMonth,1),null,@salry_Cycle,@Rpt_level )),':','.'))
		,CMP_ID = @Cmp_ID
		FROM	#Emp_Cons EC 
		INNER JOIN T0080_emp_master Emp  ON EC.Emp_ID=Emp.Emp_ID
		INNER JOIN T0040_SETTING ASet ON Emp.Cmp_ID= ASet.Cmp_ID
		where Emp.Cmp_ID=@Cmp_ID and ASet.Cmp_ID=@Cmp_ID and ASet.Setting_Name='Add number of Hours to restrict OT Approval'
		
		
		UPDATE	#Emp_Cons_Cycle 
		SET	QTR =  QTRD.Qtr
		FROM	#Emp_Cons_Cycle EC
		INNER JOIN T0040_Quarter_Details_Salarywise QTRD ON  EC.CMP_ID = QTRD.Cmp_ID
		where 	DATEFROMPARTS(EC.Qyear,EC.QMonth,EC.Qdate) between DATEFROMPARTS(YEAR(QTRD.Month_St_Date),MONTH(QTRD.Month_St_Date),DAY(QTRD.Month_St_Date)) and DATEFROMPARTS(YEAR(QTRD.Month_End_Date),MONTH(QTRD.Month_End_Date),DAY(QTRD.Month_End_Date)) 	
		
		
		UPDATE	#Emp_Cons_Cycle 
		SET		
		Alpha_Emp_Code=Emp.Alpha_Emp_Code,
		Emp_Full_Name= Emp.Emp_Full_Name,
		TOT_Qt_Hours_limit = Aset.Setting_value,
		Approved_Hours =  (select Replace(dbo.f_return_HOURs(dbo.F_Get_OT_QUARTERLYHOURS_New(@Cmp_ID,EC.Emp_ID,QTRD.Month_St_Date,QTRD.Month_End_Date,@salry_Cycle,@Rpt_level )),':','.'))
		,CMP_ID = @Cmp_ID
		FROM	#Emp_Cons_Cycle EC 
		INNER JOIN T0080_emp_master Emp  ON EC.Emp_ID=Emp.Emp_ID
		INNER JOIN T0040_SETTING ASet ON Emp.Cmp_ID= ASet.Cmp_ID
		INNER JOIN T0040_Quarter_Details_Salarywise QTRD ON QTRD.Qtr = EC.QTR 
		where Emp.Cmp_ID=@Cmp_ID and ASet.Cmp_ID=@Cmp_ID and ASet.Setting_Name='Add number of Hours to restrict OT Approval'

		UPDATE	#Emp_Cons
		--set Qtr_OT_Hrs_Available = 
		--ISNULL(  Replace(dbo.f_return_HOURs((dbo.f_return_sec(format((CAST(EC.TOT_Qt_Hours_limit as decimal(10,2))),'00.00')) 
		--- dbo.f_return_sec(format(CAST(EC.Approved_Hours as decimal(10,2)),'00.00')))),':','.') ,0.0)
		set Qtr_OT_Hrs_Available = replace(dbo.F_Return_Hours(Result),':','.')
		FROM	#Emp_Cons EC inner join 
		(
			Select Emp_id,QTR ,cast(dbo.f_return_sec(REPLACE(EC.TOT_Qt_Hours_limit,'.',':'))as NUMERIC(18,0)) - cast(dbo.f_return_sec(REPLACE(EC.Approved_Hours,'.',':')) as NUMERIC(18,0)) as Result
			from #Emp_Cons EC
		) a on a.Emp_ID =EC.Emp_ID and a.QTR = EC.QTR


		UPDATE	#Emp_Cons_Cycle
		set Qtr_OT_Hrs_Available = replace(dbo.F_Return_Hours(Result),':','.')
		FROM	#Emp_Cons_Cycle EC inner join 
		(
			Select Emp_id ,cast(dbo.f_return_sec(REPLACE(EC.TOT_Qt_Hours_limit,'.',':'))as NUMERIC(18,0)) - cast(dbo.f_return_sec(REPLACE(EC.Approved_Hours,'.',':')) as NUMERIC(18,0)) as Result
			from #Emp_Cons_Cycle EC
		) a on a.Emp_ID =EC.Emp_ID

		UPDATE	#Emp_Cons
		set Qtr_Date = (select convert(varchar, DATEADD(qq, DATEDIFF(qq, 0, DATEFROMPARTS(EC.Qyear,EC.QMonth,1)), 0), 106) +' - ' + convert(varchar,DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, DATEFROMPARTS(EC.Qyear,EC.QMonth,1)) +1, 0)),106) )
		FROM	#Emp_Cons EC 

		

		UPDATE	#Emp_Cons_Cycle
		set Qtr_Date = (select convert(varchar, DATEADD(qq, DATEDIFF(qq, 0, DATEFROMPARTS(EC.Qyear,EC.QMonth,1)), 0), 106) +' - ' + convert(varchar,DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, DATEFROMPARTS(EC.Qyear,EC.QMonth,1)) +1, 0)),106) )
		FROM	#Emp_Cons_Cycle EC 

		

DELETE b from (
Select ROW_NUMBER() OVER(Partition by Emp_Full_Name,[PEriod],TOT_Qt_Hours_limit order by [PERIOD]) as RN,* 
from (
		select CAST(Alpha_Emp_Code as varchar) +' - ' + Emp_Full_Name as Emp_Full_Name,Qtr_Date as [Period],TOT_Qt_Hours_limit 
		,Approved_Hours as [Qtr_OT_Approved_Hrs],Qtr_OT_Hrs_Available as [Qtr_OT_Hrs_Available] 
		from #Emp_Cons
	) a
) b where b.rn > 1

select CAST(Alpha_Emp_Code as varchar) +' - ' + Emp_Full_Name as Emp_Full_Name,Qtr_Date as [Period],TOT_Qt_Hours_limit 
	,Approved_Hours as [Qtr_OT_Approved_Hrs],Qtr_OT_Hrs_Available as [Qtr_OT_Hrs_Available] 
	from #Emp_Cons order by CAST(Alpha_Emp_Code as varchar) +' - ' + Emp_Full_Name 
--select CAST(Alpha_Emp_Code as varchar) +' - ' + Emp_Full_Name as Emp_Full_Name,Qtr_Date as [Period],TOT_Qt_Hours_limit ,Approved_Hours as [Qtr_OT_Approved_Hrs],Qtr_OT_Hrs_Available as [Qtr_OT_Hrs_Available]  from #Emp_Cons_Cycle

IF @AfterApprove = 0
BEGIN
	Select ROW_NUMBER() OVER(Partition by Emp_Full_Name,[PEriod],TOT_Qt_Hours_limit order by [PERIOD]) as RNn,* 
	into #tmp
	from (
			select CAST(Alpha_Emp_Code as varchar) +' - ' + Emp_Full_Name as Emp_Full_Name,Convert(varchar(20),A.Month_St_Date, 106) +' - '+ Convert(varchar(20),a.Month_End_Date,106) as [Period]
			,TOT_Qt_Hours_limit,	Approved_Hours as [Qtr_OT_Approved_Hrs],	Qtr_OT_Hrs_Available,a.Month_St_Date	
			--,Qtr_Date	,E.QTR,	E.CMP_ID,DATEFROMPARTS(YEAR(GETDATE()),QMonth,1) as MonthSTDt 
			from #Emp_Cons_Cycle E inner join 
			(
				select Cmp_ID,Month_St_Date,Month_End_Date,Qtr from T0040_Quarter_Details_Salarywise 
			) a on E.CMP_ID = a.Cmp_ID where DATEFROMPARTS(Qyear,QMonth,Qdate) between a.Month_St_Date and a.Month_End_Date
		) a1
	--select * from #tmp
	Select Emp_Full_Name,	[Period],	TOT_Qt_Hours_limit,	Qtr_OT_Approved_Hrs	,Qtr_OT_Hrs_Available
	from #tmp where RNn = 1 order by Emp_Full_Name,Month_St_Date ASC

END
--select CAST(Alpha_Emp_Code as varchar) +' - ' + Emp_Full_Name from #Emp_Cons
	
		----drop TABLE #Leave
END