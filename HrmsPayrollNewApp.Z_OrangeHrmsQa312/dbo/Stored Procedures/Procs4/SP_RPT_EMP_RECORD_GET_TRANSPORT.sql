

 
 ---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_RECORD_GET_TRANSPORT]
	@Cmp_ID	 numeric,
	@From_Date datetime,
	@To_Date datetime,
	@Branch_ID varchar(Max),
	@Grd_ID	varchar(Max),
	@Desig_ID varchar(Max),
	@Dept_ID varchar(Max),
	@Cat_ID	varchar(Max),
	@Segment_Id varchar(Max),
	@Vertical_Id varchar(Max),
	@SubVertical_Id varchar(Max),
	@Type_ID varchar(Max),
	@SubBranch_Id varchar(Max),
	@Route_ID varchar(Max),
	@Emp_ID numeric(18,0)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
 DECLARE @Show_Left_Employee_for_Salary AS TINYINT
  SET @Show_Left_Employee_for_Salary = 0
  
  SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'
  	
 CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )  
	
IF OBJECT_ID('tempdb..#Route_Temp') IS NOT NULL
	BEGIN
		DROP TABLE #Route_Temp
	END
	
CREATE TABLE #Route_Temp 
(      
	Route_ID numeric(18,0)
)  

IF @Route_ID <> ''
	BEGIN
		INSERT INTO #Route_Temp SELECT CAST(Data AS numeric) FROM dbo.Split(@Route_ID,'#')       
	END
ELSE 
	BEGIN
		INSERT INTO #Route_Temp SELECT Route_ID FROM T0040_Route_Master 
	END 

	
EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    

 

SELECT DISTINCT E.Emp_ID , I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name, E.Present_Street As Street_1,E.City,E.State,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,
	CASE WHEN S.Setting_Value = 1 THEN   --Added By Hardik 04/02/2016
							isnull(E.Initial,'')+' '+E.Emp_First_Name +' '+ isnull(E.Emp_Second_Name,'') + ' '+ isnull(E.Emp_Last_Name,'') 
						ELSE
							E.Emp_First_Name +' '+ isnull(E.Emp_Second_Name,'') + ' ' + isnull(E.Emp_Last_Name,'')
						End AS Emp_Full_Name,
						
						Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
						,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
						Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no--,I_Q.Bank_ID,I_Q.Inc_Bank_AC_No
						,E.Enroll_No    --Added By Nimesh 17-07-2015 (To sort by enroll no)
						,CASE WHEN Is_Terminate = 1 THEN 'Terminated' WHEN Is_Death = 1 THEN 'Death' WHEN isnull(Is_Retire,0) = 1 THEN 'Retirement' ELSE 'Resignation'  End as Reason_Type		--Added By Ramiz on 18/08/2015
						,DGM.Desig_Dis_No        --added jimit 21082015
						,E.Vertical_ID,E.SubVertical_ID   --Added By Jaina 5-10-2015
						,E.Emp_First_Name   --added jimit 09022016
			from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Bank_ID,Inc_Bank_AC_No from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
						#Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner JOIN
						T0040_SETTING S WITH (NOLOCK) on E.Cmp_ID = S.Cmp_ID And S.Setting_Name='Add initial in employee full name' --Added Condition by Hardik 04/02/2016
						INNER JOIN T0040_Employee_Transport_Registration ETR WITH (NOLOCK) ON EC. Emp_ID = ETR.Emp_ID
						LEFT JOIN #Route_Temp ET ON ETR.Route_ID = ET.Route_ID
			WHERE E.Cmp_ID = @Cmp_Id	
			ORDER BY E.Emp_code 
			--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
				--Order by 
				--			Case	When IsNumeric(e.Alpha_Emp_Code) = 1 then
				--						Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				--					ELSE
				--						Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				--					END								

--SELECT * FROM #Emp_Cons

  --DECLARE @Show_Left_Employee_for_Salary AS TINYINT
  --SET @Show_Left_Employee_for_Salary = 0
  
  --SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
  --FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'

	

-- Added by nilesh patel on 06092014

 
 -- Ankit 09092014 for Same Date Increment
 -- EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id ,@New_Join_emp,@Left_Emp
	 
--	if @Constraint <> ''
--		begin
--			Insert Into #Emp_Cons
--			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
--		end
--	else if @New_Join_emp = 1 
--		begin

--			Insert Into #Emp_Cons      
--			Select distinct emp_id,branch_id,Increment_ID From V_Emp_Cons 
--			Where Cmp_id=@Cmp_ID 
--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
--				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
--				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 24072013
--				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
--				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
--				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
--				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
--				and Increment_Effective_Date <= @To_Date 
--				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
--			Order by Emp_ID
						
---- Commented and Added by rohit on 17122013 for polycab issue employee transfer
--			--Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
--			--	Where  Increment_effective_Date <= @to_date Group by emp_ID)

--				Delete From #Emp_Cons Where Increment_ID Not In
--				(select TI.Increment_ID from t0095_increment TI inner join
--				(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
--				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
--				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
--				Where Increment_effective_Date <= @to_date)

---- Ended by rohit on 17122013 
		
--			--Insert Into #Emp_Cons
--			--select I.Emp_Id from dbo.T0095_Increment I inner join dbo.T0080_Emp_Master e on i.Emp_ID = E.Emp_ID inner join 
--			--		( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
--			--		where Increment_Effective_date <= @To_Date
--			--		and Cmp_ID = @Cmp_ID
--			--		group by emp_ID  ) Qry on
--			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
--			--Where I.Cmp_ID = @Cmp_ID 
--			--and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
--			--and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
--			--and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
--			--and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
--			--and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
--			--and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
--			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
--			--and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
--		end
--	else if @Left_Emp = 1 
--		begin

--			Insert Into #Emp_Cons      
--			Select distinct emp_id,branch_id,Increment_ID 
--			From V_Emp_Cons Where Cmp_id=@Cmp_ID 
--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
--				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
--				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))			 -- Added By Gadriwala Muslim 24072013
--				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))		 -- Added By Gadriwala Muslim 24072013	
--				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
--				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
--				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
--				and Increment_Effective_Date <= @To_Date 
--				and Left_date >=@From_Date and Left_Date <=@to_Date
--			Order by Emp_ID
						
---- Commented and Added by rohit on 17122013 for polycab issue employee transfer
--			--Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
--			--	Where  Increment_effective_Date <= @to_date Group by emp_ID)

--		Delete From #Emp_Cons Where Increment_ID Not In
--				(select TI.Increment_ID from t0095_increment TI inner join
--				(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
--				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
--				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
--				Where Increment_effective_Date <= @to_date)
---- Commented and Added by rohit on 17122013 

--			--Insert Into #Emp_Cons

--			--select I.Emp_Id from dbo.T0095_Increment I inner join T0100_lefT_emp Le on i.emp_Id = le.emp_ID inner join 
--			--		( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
--			--		where Increment_Effective_date <= @To_Date
--			--		and Cmp_ID = @Cmp_ID
--			--		group by emp_ID  ) Qry on
--			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
--			--Where I.Cmp_ID = @Cmp_ID 
--			--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
--			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
--			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
--			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
--			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
--			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
--			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
--			--and Left_date >=@From_Date and Left_Date <=@to_Date
--		end		
--	else 
--		begin

--			-- below condition changed by mitesh on 05072013
--			Insert Into #Emp_Cons      
--		      select distinct emp_id,V_Emp_Cons.branch_id,Increment_ID from V_Emp_Cons
--				inner join T0040_GENERAL_SETTING g on V_Emp_Cons.branch_id=g.branch_id --Ankit 05032014
--		        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
--							inner join 
--							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
--							GROUP BY emp_id) Qry
--							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
--		       ON QrySC.eid = V_Emp_Cons.Emp_ID
--		  where 
--		     V_Emp_Cons.cmp_id=@Cmp_ID 
--		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
--			   and V_Emp_Cons.Branch_ID = isnull(@Branch_ID ,V_Emp_Cons.Branch_ID)      
--			   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
--			   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
--			   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
--			   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
--			   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
--			   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       -- Added By Gadriwala Muslim 24072013
--			   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
--			   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  -- Added By Gadriwala Muslim 24072013
--			   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
--			   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
--		       and Increment_Effective_Date <= @To_Date 
--		       and 
--                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
--						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
--						or (Left_date is null and @To_Date >= Join_Date)      
--						or (@To_Date >= left_date  and  @From_Date <= left_date )
--						--OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
--						OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date >= case when (isnull(Sal_St_Date,'')) = ''  then @From_Date  when day(Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'')) = ''  then @to_date when day(sal_st_date)=1 then @to_date else  dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)	--Ankit 05032014
--						) 
--						order by Emp_ID
						
			

--				-- Commented and Added by rohit on 17122013 for polycab issue employee transfer
--			--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
--			--	where  Increment_effective_Date <= @to_date
--			--	group by emp_ID)

--		Delete From #Emp_Cons Where Increment_ID Not In
--				(select TI.Increment_ID from t0095_increment TI inner join
--				(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
--				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
--				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
--				Where Increment_effective_Date <= @to_date)
---- Commented and Added by rohit on 17122013 
				
				
--			--Insert Into #Emp_Cons      
--		   --   select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where 
--		   --   cmp_id=@Cmp_ID 
--		   --    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
--		   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
--		   --and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
--		   --and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
--		   --and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
--		   --and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
--		   --and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
--		   --   and Increment_Effective_Date <= @To_Date 
--		   --   and 
--     --                 ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
--					--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
--					--	or (Left_date is null and @To_Date >= Join_Date)      
--					--	or (@To_Date >= left_date  and  @From_Date <= left_date )
--					--	OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
--					--	) 
--					--	order by Emp_ID
						
--			--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
--			--	where  Increment_effective_Date <= @to_date
--			--	group by emp_ID)
		
--		end

		
	--if @Report_Type =''
	--	Begin
		
	--		select I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name, E.Present_Street As Street_1,E.City,E.State,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,
	--					CASE WHEN S.Setting_Value = 1 then   --Added By Hardik 04/02/2016
	--						isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Last_Name,'') 
	--					ELSE
	--						E.Emp_First_Name + ' ' + isnull(E.Emp_Last_Name,'')
	--					End AS Emp_Full_Name,
						
	--					Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
	--					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
	--					,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
	--					Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no--,I_Q.Bank_ID,I_Q.Inc_Bank_AC_No
	--					,E.Enroll_No    --Added By Nimesh 17-07-2015 (To sort by enroll no)
	--					,CASE WHEN Is_Terminate = 1 THEN 'Terminated' WHEN Is_Death = 1 THEN 'Death' WHEN isnull(Is_Retire,0) = 1 THEN 'Retirement' ELSE 'Resignation'  End as Reason_Type		--Added By Ramiz on 18/08/2015
	--					,DGM.Desig_Dis_No        --added jimit 21082015
	--					,E.Vertical_ID,E.SubVertical_ID   --Added By Jaina 5-10-2015
	--					,E.Emp_First_Name   --added jimit 09022016
	--		from dbo.T0080_EMP_MASTER E left outer join dbo.T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
	--			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Bank_ID,Inc_Bank_AC_No from dbo.T0095_Increment I inner join 
	--					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment	-- Ankit 10092014 for Same Date Increment
	--					where Increment_Effective_date <= @To_Date
	--					and Cmp_ID = @Cmp_ID
	--					group by emp_ID  ) Qry on
	--					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
	--				on E.Emp_ID = I_Q.Emp_ID  inner join
	--					dbo.T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--					dbo.T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--					dbo.T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--					dbo.T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
	--					dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
	--					dbo.T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID Inner Join
	--					#Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner JOIN
	--					T0040_SETTING S on E.Cmp_ID = S.Cmp_ID And S.Setting_Name='Add initial in employee full name' --Added Condition by Hardik 04/02/2016
	--		WHERE E.Cmp_ID = @Cmp_Id	
	--		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
	--			Order by 
	--						Case	When IsNumeric(e.Alpha_Emp_Code) = 1 then
	--									Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
	--								ELSE
	--									Left(e.Alpha_Emp_Code + Replicate('',21), 20)
	--								END										
	--	end
		
	--else
						
							
	--	if @Report_Type = 'ID Card'
	--		begin
	--			select I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name,
	--			 E.Present_Street AS Street_1,
	--			 E.City,
	--			 E.State,
	--			 E.Zip_Code,
	--			 CASE WHEN @PrintEmpName = '1' then   --Added By Jaina 19-10-2015 Start
	--			--E.Emp_Full_Name 
	--			isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Last_Name,'') 
	--			else
	--			E.Emp_First_Name + ' '+ isnull(E.Emp_Last_Name,'')
	--			End as Emp_Full_Name,    --Added By Jaina 19-10-2015 End
	--			E.Worker_Adult_No,E.Father_Name, 
	--			--E.Emp_Code
	--			E.Enroll_no as Emp_Code				
	--			,E.Home_Tel_No
				
	--			,isnull(Vertical_Code,'')as Vertical_Code,isnull(Vertical_name,'')as Vertical_name,isnull(Vertical_description,'') as Vertical_description
	--			,isnull(SubVertical_Code,'')as SubVertical_Code,isnull(SubVertical_name,'')as SubVertical_name,isnull(SubVertical_description,'') as SubVertical_description
	--			,isnull(SubBranch_Description,'') as SubBranch_Description
	--			,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
	--						,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
	--						,Cmp_Name,Cmp_Address,
							
	--			Present_Street,
	--			Present_State,
	--			Present_City,
	--			Present_Post_Box,
				
	--			l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
	--						Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no,E.Image_Name,Blood_Group ,cast ( 0 as VARBINARY(max)) as Emp_Image
	--			,E.SSN_No --Added by Nimesh 18-Jun-2015 (for PF No)
	--			,ETM.[Type_Name]     ---added jimit 09072015
	--			,Cm.cmp_logo         ---added jimit 12082015
	--			,DGM.Desig_Dis_No,E.Emp_First_Name --added jimit 09022016
	--			,E.Tally_Led_Name
	--			,CAST(@reportPath as varchar(max)) + '\report_image\Rp_' + cast (isnull(E.Tally_Led_ID,0) as varchar) + '.png' as rp_Image
	--			from dbo.T0080_EMP_MASTER E left outer join dbo.T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
	--				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,
	--				 Type_ID,Vertical_id,SubVertical_id,I.subBranch_ID from dbo.T0095_Increment I inner join 
	--						( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment	-- Ankit 10092014 for Same Date Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
	--					on E.Emp_ID = I_Q.Emp_ID  inner join
	--						dbo.T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--						dbo.T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--						dbo.T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--						dbo.T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
	--						dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
	--						dbo.T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID Inner Join
	--						#Emp_Cons EC on E.Emp_ID = EC.Emp_ID
							
	--						LEFT OUTER JOIN T0040_Vertical_Segment as VT  on VT.Vertical_id = I_Q.Vertical_id
	--						LEFT OUTER JOIN T0050_SubVertical as SVT  on SVT.SubVertical_id = I_Q.SubVertical_id
	--						LEFT OUTER JOIN dbo.T0050_SubBranch as SBM ON SBM.BRANCH_ID = BM.BRANCH_ID and sbm.SubBranch_ID = I_Q.subBranch_ID
							
	--			WHERE E.Cmp_ID = @Cmp_Id
	--			--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
	--			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
	--			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
	--				Else e.Alpha_Emp_Code
	--			End
	--		end
	RETURN

