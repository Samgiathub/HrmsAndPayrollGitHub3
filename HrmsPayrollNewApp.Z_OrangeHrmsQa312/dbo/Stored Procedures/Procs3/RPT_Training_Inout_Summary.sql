

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:exec RPT_Training_Inout_Summary @Cmp_ID=9,@From_Date='2015-07-23 00:00:00',@To_Date='2015-07-23 00:00:00',@Branch_ID='0',@Cat_ID='0',@Grd_ID='0',@Type_ID='0',@Dept_ID='0',@Desig_ID='0',@Emp_ID=0,@Constraint='1351#1352#1355',@Training_ID=44
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Inout_Summary]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max)='' 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max)='' 
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
	,@Report_Type	tinyint = 0
	,@Training_id   numeric(18,0)
	,@PBranch_ID	varchar(max)= '' --Added By Jaina 07-10-2015
	,@PVertical_ID	varchar(max)= '' --Added By Jaina 07-10-2015
	,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 07-10-2015
	,@PDept_ID varchar(max)=''  --Added By Jaina 07-10-2015
	,@flag			int = 0 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 07-10-2015
		set @PBranch_ID = null   	
		
	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 07-10-2015
		set @PVertical_ID = null
	
	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 07-10-2015
		set @PsubVertical_ID = null
		
		
	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 07-10-2015
		set @PDept_ID = NULL	 
		
	--Added By Jaina 07-10-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
	print @PVertical_ID
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0'
				
		else
			set @PVertical_ID = @PVertical_ID + ',0'
		
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'
	End
	--Added By Jaina 7-10-2015 End
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	 
--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,'' ,'' ,'' ,'' 
	
--if (@Constraint='')
--	begin		
--		select @Constraint = coalesce(@Constraint+'#' ,'') + cast(emp_id as varchar(18))
--		from T0080_EMP_MASTER 
--		where Emp_Left<>'Y' 
--		set @Constraint =  substring(@Constraint,1,len(@Constraint)-1)		
--		set @Constraint =  right(@Constraint, len (@Constraint)-1)		
--	end

	 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	--Added By Jaina 7-10-2015 Start
	
	 
	DELETE FROM #Emp_Cons
	WHERE NOT EXISTS (
					select	 E.Emp_ID 
					from	#Emp_Cons as  E Inner JOIN T0095_INCREMENT as i WITH (NOLOCK) ON i.Increment_ID = E.Increment_ID
					where	 #Emp_Cons.Increment_ID = E.Increment_ID
					  and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))
					  and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
					  and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
					  AND  EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0))  
					  
				)
	
	--Added By Jaina 7-10-2015 End
	
	
	Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	where a.Emp_ID = #Emp_Cons.Emp_ID   	
	
	Declare @Cur_Emp_ID numeric(18,0)
	Declare @Cur_Branch_ID numeric(18,0)
	Declare @Prev_Branch_ID numeric(18,0)
	Declare @Cur_For_Date datetime
	Declare @Cur_Tran_ID numeric(18,0)
	
	 set @Cur_Emp_ID = 0
	 set @Cur_Branch_ID = 0
	 set @Prev_Branch_ID = 0
	 set @Cur_Tran_ID = 0
	
	 if @flag=0
		BEGIN
	 		create table #finaltable
			 (
				 emp_id				numeric(18)
				 ,Emp_code			 varchar(50)
				 ,Emp_Full_Name		 varchar(50)
				 ,Branch_Address	 varchar(200)
				 ,comp_name			 varchar(100)
				, Branch_Name		 varchar(50)
				, Dept_Name			 varchar(50)
				,Grd_Name			 varchar(50)
				, Desig_Name		 varchar(50)
				, For_date			varchar(50)
				--,P_From_Date		 datetime
				--,P_To_Date			 datetime
				,BRANCH_ID			 numeric(18)
				,cmp_name			 varchar(100)
				, cmp_address		 varchar(200)
				,In_Time			varchar(50)
				,Out_Time			varchar(50)
				,Hours				varchar(50)
				,training_name		varchar(100)
				,training_code		varchar(50)
				,training_fromdate  datetime
				,training_todate	datetime
				,training_fromtime  DATETIME
				,training_totime	DATETIME
				,final_hours		varchar(50)
			 )
			 
			
			 declare @col as numeric(18)
			 declare @tmp_fromdate as datetime
			 declare @tmp_todate as datetime
			  declare @tmp_fordate as varchar(50)
			  --declare @tmp_finalhrs as varchar(50)
			  --declare @hrs as numeric(18)
			  --declare @min as numeric(18)
			 
			 
			 SELECT @tmp_fromdate=From_date,@tmp_todate= To_date 
			 FROM T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) INNER JOIN
				 (
					SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID
					FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
					GROUP by Training_App_ID
				 )TS on Ts.Training_App_ID = T0120_HRMS_TRAINING_APPROVAL.Training_App_ID
			 WHERE  Training_Apr_ID=@Training_id
			 
			 --select @tmp_fromdate=Training_Date,@tmp_todate= Training_End_Date from T0120_HRMS_TRAINING_APPROVAL where  Training_Apr_ID=@Training_id --Cmp_ID=@Cmp_ID and --remove cmpid on 29122015
			 
			
			declare cur cursor
				for 
				   select Emp_ID from #Emp_Cons
				open cur
				fetch next from cur into @col
				while @@FETCH_STATUS = 0
					begin
						if exists(select 1 from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Training_Apr_ID=@training_id and Emp_ID=@col  and (Emp_tran_status =1 or Emp_tran_status=4))
							begin
								If @Report_Type = 0
									begin
										insert into #finaltable(
												emp_id
												,emp_code
												,emp_full_name
												,branch_address
												,comp_name
												, Branch_Name		 
												, Dept_Name			
												,Grd_Name			
												, Desig_Name		
												, For_date			 
												--,P_From_Date		
												--,P_To_Date			 
												,BRANCH_ID			
												,cmp_name			
												, cmp_address		 
												--,In_Time			
												--,Out_Time			
												--,Hours				
											)
										(Select distinct @col, E.Alpha_Emp_Code , E.Emp_Full_Name  ,Branch_Address,comp_name
											, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),EGP.For_Date,103),' ','/')  ,BM.BRANCH_ID
											 , cm.cmp_name , cm.cmp_address
											from T0150_EMP_Training_INOUT_RECORD EGP WITH (NOLOCK) Left outer join
											T0150_EMP_Training_INOUT_RECORD ED WITH (NOLOCK) on EGP.Emp_ID = ED.Emp_ID and EGP.For_date = ED.For_date and ED.Tran_ID = EGP.Tran_Id
											Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
											INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
														( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
														where   emp_id = @col and Increment_Effective_date <= @tmp_todate
														group by emp_ID  ) Qry on
														I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
											E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
											dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
											dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
											dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
											T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = e.cmp_id 
											where e.emp_id = @col 
												and  EGP.For_date >= @tmp_fromdate and EGP.For_date <=@tmp_todate )
											
											declare cur_date cursor
												for
													select for_date from #finaltable 
												open cur_date
												fetch next from cur_date into @tmp_fordate
												while @@FETCH_STATUS=0
													begin
														 if exists(select * from T0040_IP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Is_Training=1)
															begin 
																update #finaltable 														
																set In_Time=convert(varchar(15), cast(i.In_Time AS TIME), 100 ),
																	Out_Time=convert(varchar(15), cast(i.Out_Time AS TIME), 100),
																	[Hours]=cast(i.Hours as varchar(10))
																From (select MIN(in_time) as in_time,MAX(out_time)as out_time,dbo.F_Return_Hours (datediff(s, Min(in_time),MAX(out_time))) as Hours
																	  from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
																	  where emp_id=@col and cmp_id=@cmp_id
																			and For_date = CONVERT(Datetime, @tmp_fordate, 104))i
																where emp_id=@col and For_date=@tmp_fordate
															End
														 else
															begin 
																update #finaltable
																set In_Time=convert(varchar(15), cast(i.In_Time AS TIME), 100 ),
																	Out_Time=convert(varchar(15), cast(i.Out_Time AS TIME), 100),
																	[Hours]=cast(i.Hours as varchar(10))
																From (select MIN(in_time) as in_time,MAX(out_time)as out_time,dbo.F_Return_Hours (datediff(s, Min(in_time),MAX(out_time))) as Hours
																	  from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
																	  where emp_id=@col and cmp_id=@cmp_id and training_apr_id = @Training_id
																			and For_date =CONVERT(Datetime, @tmp_fordate, 104))i
																where emp_id=@col and For_date=@tmp_fordate 
															end
														
														fetch next from cur_date into @tmp_fordate
													End
											close cur_date
											deallocate cur_date		
											
										--update #finaltable
										--	set training_name = t.Training_name,
										--		training_code=t.training_code,
										--		training_fromdate=t.Training_Date,
										--		training_todate=t.Training_End_Date,
										--		training_fromtime=t.training_fromtime,
										--		training_totime=t.training_totime
										--		from (select tm.Training_name,isnull(ta.Training_Code,ta.Training_Apr_ID) as training_code,ta.Training_Date,ta.Training_End_Date,Training_FromTime as training_fromtime,Training_ToTime as training_totime
										--			  from T0120_HRMS_TRAINING_APPROVAL TA inner join
										--			       T0040_Hrms_Training_master TM on TM.Training_id = TA.Training_id 
										--			  where Training_Apr_ID=@Training_id and ta.cmp_id=@Cmp_ID)t 
										--where #finaltable.emp_id=@col
										
										update #finaltable
											set training_name = t.Training_name,
												training_code=t.training_code,
												training_fromdate=t.From_date,
												training_todate=t.To_date,
												training_fromtime=t.training_fromtime,
												training_totime=t.training_totime
												from (select DISTINCT tm.Training_name,isnull(ta.Training_Code,ta.Training_Apr_ID) as training_code,
												TST.From_date,TST.To_date,From_Time as training_fromtime,To_Time as training_totime
													  from T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) inner join
														   T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_id = TA.Training_id inner JOIN 
															(
																SELECT MIN(From_date)From_date,MAX(To_date)To_date,	
																MIN(convert(TIME,From_Time))From_Time,
																max(convert(TIME,To_Time))To_Time,Training_App_ID					
																FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
																GROUP  BY Training_App_ID
															)TST on TST.Training_App_ID = TA.Training_App_ID
													  where Training_Apr_ID=@Training_id and ta.cmp_id=@Cmp_ID)t 
										where #finaltable.emp_id=@col
									end
								else
									begin
									 if exists(select * from T0040_IP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Is_Training=1)
										begin
												insert into #finaltable(
														emp_id
														,emp_code
														,emp_full_name
														,branch_address
														,comp_name
														, Branch_Name		 
														, Dept_Name			
														,Grd_Name			
														, Desig_Name		
														, For_date			 
														--,P_From_Date		
														--,P_To_Date			 
														,BRANCH_ID			
														,cmp_name			
														, cmp_address		 
														--,In_Time			
														--,Out_Time			
														--,Hours	
														,training_fromdate
														,training_todate
														,training_fromtime
														,training_totime
														,training_code
														,training_name				
														)
														(
															Select distinct @col,E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
															, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),@tmp_todate ,103),' ','/') as For_date ,BM.BRANCH_ID
															 , cm.cmp_name , cm.cmp_address,TST.From_date,TST.To_date,TST.From_Time,TST.To_Time,ta.Training_Code,tm.Training_name
															 --, convert(varchar(15), cast(EGP.In_Time AS TIME), 100),convert(varchar(15), cast(EGP.Out_Time AS TIME), 100),EGP.Hours
															from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP WITH (NOLOCK) 
															Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
															INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
																		( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
																		where Emp_ID=@col 
																		and  Increment_Effective_date <= @tmp_todate
																		group by emp_ID  ) Qry on
																		I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
															E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
															dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
															dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
															dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
															T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = e.cmp_id inner join 
															T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) on TA.Training_Apr_ID = @Training_ID inner join
															T0040_Hrms_Training_master  TM WITH (NOLOCK) on TM.Training_id = TA.Training_id inner JOIN 
															(
																SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,From_Time,To_Time						
																FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
																GROUP  BY Training_App_ID,From_Time,To_Time
															)TST on TST.Training_App_ID = TA.Training_App_ID						 
															where EGP.Emp_ID=@col 
															--and  EGP.For_date >= @tmp_fromdate and EGP.For_date <=@tmp_todate 
															and  not exists (select 1 from T0150_EMP_Training_INOUT_RECORD ei WITH (NOLOCK) where ei.For_date >= @tmp_fromdate and ei.For_date <=@tmp_todate  and emp_id=egp.Emp_ID)
														)											
										end
									else
										begin
										print 'nn'
										PRINT @tmp_fromdate
										PRINT @tmp_todate
										--select * from #emp_cons
											insert into #finaltable(
														emp_id
														,emp_code
														,emp_full_name
														,branch_address
														,comp_name
														, Branch_Name		 
														, Dept_Name			
														,Grd_Name			
														, Desig_Name		
														, For_date			 
														--,P_From_Date		
														--,P_To_Date			 
														,BRANCH_ID			
														,cmp_name			
														, cmp_address		 
														--,In_Time			
														--,Out_Time			
														--,Hours
														,training_fromdate
														,training_todate
														,training_fromtime
														,training_totime
														,training_code
														,training_name				
														)
														(
															Select distinct @col,E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
															, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,REPLACE(CONVERT(VARCHAR(11),@tmp_todate ,103),' ','/') as For_date ,BM.BRANCH_ID
															 , cm.cmp_name , cm.cmp_address, TST.From_date,TST.To_date,TST.From_Time,TST.To_Time,ta.Training_Code,tm.Training_name
															 --, convert(varchar(15), cast(EGP.In_Time AS TIME), 100),convert(varchar(15), cast(EGP.Out_Time AS TIME), 100),EGP.Hours
															from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP  WITH (NOLOCK)
															Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
															INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
																		( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
																		where Emp_ID=@col 
																		and  Increment_Effective_date <= @tmp_todate
																		group by emp_ID  ) Qry on
																		I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
															E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
															dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
															dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
															dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
															T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = e.cmp_id inner join 
															T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) on TA.Training_Apr_ID = @Training_ID inner join
															T0040_Hrms_Training_master  TM WITH (NOLOCK) on TM.Training_id = TA.Training_id inner JOIN 
															(
																SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,From_Time,To_Time						
																FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
																GROUP  BY Training_App_ID,From_Time,To_Time
															)TST on TST.Training_App_ID = TA.Training_App_ID													
															where EGP.Emp_ID=@col 
															and  not exists (select 1 from T0150_EMP_Training_INOUT_RECORD ei WITH (NOLOCK) where Training_Apr_Id=@Training_ID and emp_id=egp.Emp_ID and ei.For_date >= @tmp_fromdate and ei.For_date <=@tmp_todate)
														)												
										end		
									end
							end
						fetch next from cur into @col
					end
				close cur
				deallocate cur 
				
				
				select * from #finaltable
				
			 drop table #finaltable
			END
	ELSE
		BEGIN
			create table #trainingtable
			 (
				 emp_id				numeric(18)
				,Emp_code			 varchar(50)
				,Emp_Full_Name		 varchar(50)				
				,Branch_Name		 varchar(50)
				,Dept_Name			 varchar(50)
				,Grd_Name			 varchar(50)
				,Desig_Name			 varchar(50)				
				,BRANCH_ID			 numeric(18)
				,cmp_name			 varchar(100)
				,cmp_address		 varchar(200)
				,training_name		varchar(100)
				,training_code		varchar(50)
				--,training_fromdate  datetime
				--,training_todate	datetime
				--,training_fromtime  DATETIME
				--,training_totime	DATETIME	
				,date_attended		VARCHAR(15) 
				,joining_date		DATETIME
				,Training_Apr_ID	numeric(18)
			 )
			-- select * from #Emp_Cons
			 insert into #trainingtable 		
				Select distinct e.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,
					Branch_Name,Dept_Name,Grd_Name,Desig_Name,BM.Branch_ID,cm.cmp_name,cm.cmp_address, 
					tm.Training_name,REPLACE(ta.Training_Code,' ',''),
					--TST.From_date,TST.To_date,TST.From_Time,TST.To_Time,
					case when CONVERT(VARCHAR(10),ti.For_date,103) is NULL then '-' else CONVERT(VARCHAR(10),ti.For_date,103)end,E.Date_Of_Join,EGP.Training_Apr_ID
				from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP  WITH (NOLOCK)
				Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EGP.EMP_ID = E.EMP_ID
				Inner join #Emp_Cons EC ON EC.EMP_ID = E.EMP_ID
				LEFT join T0150_EMP_Training_INOUT_RECORD TI WITH (NOLOCK) on TI.Training_Apr_Id=EGP.Training_Apr_ID and ti.emp_id=ec.Emp_ID
				INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
							where --Emp_ID=@col and
							  Increment_Effective_date <= @To_Date
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
				E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID   Inner join 
				T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = e.cmp_id inner join 
				T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) on TA.Training_Apr_ID = egp.Training_Apr_ID inner join
				T0040_Hrms_Training_master  TM WITH (NOLOCK) on TM.Training_id = TA.Training_id inner JOIN 
				(
					SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,From_Time,To_Time						
					FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
					GROUP  BY Training_App_ID,From_Time,To_Time
				)TST on TST.Training_App_ID = TA.Training_App_ID													
				--where not exists (select 1 from T0150_EMP_Training_INOUT_RECORD ei where Training_Apr_Id=@Training_ID and 
				--emp_id=egp.Emp_ID and ei.For_date >= @tmp_fromdate and ei.For_date <=@tmp_todate)
		
			
			select * from #trainingtable
		END


END
