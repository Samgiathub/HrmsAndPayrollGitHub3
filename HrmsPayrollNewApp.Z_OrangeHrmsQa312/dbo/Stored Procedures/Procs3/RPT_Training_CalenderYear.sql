

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_CalenderYear]
	@Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	--,@Branch_ID		varchar(Max) 
	--,@Cat_ID		varchar(Max)
	--,@Grd_ID		varchar(Max) 
	--,@Type_ID		varchar(Max) 
	--,@Dept_ID		varchar(Max) 
	--,@Desig_ID		varchar(Max)
	--,@Emp_ID		Numeric
	--,@Constraint	varchar(MAX)
	--,@Training_id   numeric(18,0)
	,@Year			numeric(18,0)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	--CREATE TABLE #Emp_Cons 
	-- (      
	--   Emp_ID numeric ,     
	--   Branch_ID numeric,
	--   Increment_ID numeric    
	-- )  
	 
	--exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	--Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
	--	SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
	--				  FROM dbo.V_Emp_Cons VE inner join
	--				  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
	--	)a
	--where a.Emp_ID = #Emp_Cons.Emp_ID 
	
Create table #finalTable
	(
		--cmp_name			 varchar(100)
		--,cmp_address		 varchar(200)
		--,cmp_logo			 image
		Training_name		 varchar(50)
		,Training_id		 numeric(18,0)
		,Training_Apr_id	 numeric(18,0)
		,Training_Code       varchar(50)
		,Calender_Year		 numeric(18,0)
		,Calender_Month      varchar(50)
		,Calender_Month_n     int
		,training_StartDate	 datetime
		,training_endDate	 datetime
		,training_calenderid	numeric(18,0)
	)
	
	declare @col as numeric(18,0)
	declare @col1 as numeric(18,0)
	declare @trainingdate as datetime --added on 12 aug 2015
	
	insert into #finalTable
	(Training_id,Training_Apr_id,Training_Code,training_StartDate,training_endDate,Training_name)	
	  select t.Training_id,Training_Apr_ID,isnull(Training_Code,Training_Apr_ID),TST.From_date,TST.To_date,m.Training_name
	 from V0120_HRMS_TRAINING_APPROVAL t 
	 inner join T0040_Hrms_Training_master m WITH (NOLOCK) on m.Training_id = t.Training_id 
	 inner JOIN 
	 (
		SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID						
		FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) 
		GROUP  BY Training_App_ID
	 )TST on TST.Training_App_ID = T.Training_App_ID			
	 where t.Cmp_ID=@Cmp_ID  and DATEPART(YYYY,Training_Date)=@Year and Apr_Status =1
	 order by training_date
	 

--declare cur cursor
--for 
--	select training_id,training_apr_id,training_StartDate from #finalTable 
--open cur
--	fetch next from cur into @col,@col1,@trainingdate
--	while @@FETCH_STATUS=0
--		begin		
--			update #finalTable 
--			set Calender_Year =t.Calender_Year,
--				Calender_Month = t.Calender_Month,
--				training_calenderid=t.Event_id,
--				Calender_Month_n=t.Calender_Month_n
--			from (select Event_id,YEAR(Training_date) as Calender_Year,DateName( month , DateAdd( month ,Month(TEC.Training_date) , -1 ) )Calender_Month,
--					MONTH(Training_date) as Calender_Month_n
--				  from T0052_Hrms_Training_Event_Calender_Yearly  TEC
--				  where YEAR(Training_date)=@Year and Training_Id=@col and month(TEC.Training_date)= datepart(MM,@trainingdate))t	
--			where Training_id = @col and Training_Apr_id=@col1
			
--			fetch next from cur into @col,@col1,@trainingdate
--		end
--close cur
--deallocate cur
		
--update #finalTable
--set Calender_Month = 'Unplanned'
--where Calender_Month is null	

--set @col= null

--create table #final
--(
	
--		Training_name		 varchar(50)
--		,Training_id		 numeric(18,0)
--		,Training_Apr_id	 numeric(18,0)
--		,Training_Code       varchar(50)
--		,Calender_Year		 numeric(18,0)
--		,Calender_Month      varchar(50)
--		,training_StartDate	 datetime
--		,training_endDate	 datetime
--		,Calender_Month_n     int
--		,training_calenderid	numeric(18,0)
--)
--declare cur cursor
--for 
--	select event_ID from T0052_Hrms_Training_Event_Calender_Yearly where year(Training_date)=@year and cmp_id = @cmp_id
--open cur
--fetch next from cur into @col
--while @@FETCH_STATUS=0	
--	begin				
--		if Not exists(select 1 from #finalTable where training_calenderid=@col)
--			begin		
--				insert into #finalTable(training_calenderid,Calender_Year,Calender_Month,Calender_Month_n,Training_name,Training_id)
--				select Y.Event_id,year(y.Training_date),DateName( month , DateAdd( month ,Month(y.Training_date) , -1 ) )Calender_Month,
--				MONTH(y.Training_date),t.Training_name,y.Training_Id
--				from T0052_Hrms_Training_Event_Calender_Yearly Y inner join 
--				t0040_hrms_training_master t on t.Training_id=y.Training_Id
--				where year(y.Training_date)=@year and y.Event_id = @col and y.Cmp_Id=@cmp_id
--				order by y.Training_date
--			end
--		fetch next from cur into @col
--	end
--close cur
--deallocate cur

select 
		Cmp_Name,
		Cmp_Address,
		cmp_logo,
		Training_id,
		Training_name,	  
	   Training_Apr_id,
	   isnull(Training_Code,'')Training_Code,
	   CONVERT(varchar(15),training_StartDate,103)training_StartDate,
	   CONVERT(varchar(15),training_endDate,103)training_endDate
	 -- Case When row_number() OVER ( PARTITION BY training_calenderid order by Training_id) = 1
		--Then  calender_year else null end as 'calender_year' ,
	 --  Case When row_number() OVER ( PARTITION BY training_calenderid order by Training_id) = 1
		--Then  calender_month_n else null end as 'calender_month_n' ,
	 --  Case When row_number() OVER ( PARTITION BY training_calenderid order by Training_id) = 1
		--Then  training_calenderid else null end as 'training_calenderid' ,
	 --  Case When row_number() OVER ( PARTITION BY training_calenderid order by Training_id) = 1
		--Then  Calender_Month else '' end as 'Calender_Month'  
from #finalTable,T0010_COMPANY_MASTER WITH (NOLOCK) 
where cmp_id=@cmp_id
order by isnull(calender_month_n,13)

drop table #finalTable

	
END


