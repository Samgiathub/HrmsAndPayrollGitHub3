
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_OVERTIME_REGISTER]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint		varchar(5000) = ''
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 19082013
	,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 19082013
	,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 19082013	
	,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 19082013
	,@Return_Record_set  varchar(50) = 'Paid Overtime'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 19082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 19082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 19082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 19082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 19082013
	set @SubBranch_Id = null	
	
	CREATE TABLE #Emp_Cons -- Ankit 06092014 for Same Date Increment
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )   
		 
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

	--Added by Nimesh 17-Jul-2015 (For different salary cycle date for different branch)
	SELECT	G.Branch_ID, G.Sal_st_Date, DATEADD(m, 1, G.Sal_st_Date) As Sal_End_Date
	INTO	#GEN
	FROM	(
				SELECT	Branch_ID,
						(CASE WHEN DAY(Sal_st_Date) > 1 THEN DATEADD(M,-1, DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date)) ELSE DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date) END ) AS Sal_st_Date	
				FROM	T0040_GENERAL_SETTING G WITH (NOLOCK)
				WHERE	For_Date = (
									SELECT Max(For_Date) FROM T0040_GENERAL_SETTING G1 WITH (NOLOCK)
									WHERE For_Date < @To_Date and G1.Branch_id=G.Branch_ID
								) AND Cmp_ID=@Cmp_ID
			) G

	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
			
			
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 19082013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 19082013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 19082013
	--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 19082013
		
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
	--	end
		
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
	 
	 
	 
		 if isnull(@Sal_St_Date,'') = ''    
			begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
			begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_end_Date   
			End
	
	
	
		---- Changed By Ali 22112013 EmpName_Alias
		--select I_Q.* , E.Emp_Code,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name)  as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,
		--		Dept_Name,Desig_Name,grd_name,type_name,@From_Date P_From_Date ,@To_Date P_To_Date ,isnull(ms.Ot_hours,0) as Ot_hours,isnull(ms.Ot_amount,0) as Ot_amount,  
		--		isnull(ms.M_WO_OT_Hours,0) as M_WO_OT_Hours,isnull(ms.M_HO_OT_Hours,0) as M_HO_OT_Hours,isnull(ms.M_WO_OT_Amount,0) as M_WO_OT_Amount,isnull(ms.M_HO_OT_Amount,0) as M_HO_OT_Amount
		--,E.Alpha_emp_code --added jimit 01062015
		--,DGM.Desig_Dis_No              ---added jimit 24082015
		--from T0080_EMP_MASTER E inner join 
		--     t0200_monthly_salary MS on E.Emp_ID =MS.Emp_Id inner join
		--     T0010_Company_master CM on E.Cmp_ID =Cm.Cmp_ID inner join
		--    			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
		--			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
		--			where Increment_Effective_date <= @To_Date
		--			and Cmp_ID = @Cmp_ID
		--			group by emp_ID  ) Qry on
		--			I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
		--		on E.Emp_ID = I_Q.Emp_ID  inner join					
		--			T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		--			T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
		--			T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		--			T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					
		--			T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID 
		--			LEFT OUTER JOIN #GEN G ON G.Branch_ID=I_Q.Branch_ID --Added by Nimesh 17-Jul-2015 (For Different salary cycle for different branch)
		----WHERE E.Cmp_ID = @Cmp_Id and  MS.month_st_date >= @From_Date and MS.month_end_date <= @To_Date and (Ms.OT_Hours > 0 or Ms.M_HO_OT_Hours > 0 or M_WO_OT_Hours > 0)
		--WHERE E.Cmp_ID = @Cmp_Id and  MS.month_st_date >= G.Sal_St_date and MS.month_end_date <= G.Sal_End_date and (Ms.OT_Hours > 0 or Ms.M_HO_OT_Hours > 0 or M_WO_OT_Hours > 0)
		--		And E.Emp_ID in (select Emp_ID From #Emp_Cons) order by E.Emp_Code asc 
		
		
		--Commented Above Portion and Added the Record Set here By Ramiz on 25/12/2015 --	
		IF  @Return_Record_Set = 'Paid Overtime'
			BEGIN
				-- Changed By Ali 22112013 EmpName_Alias
				select I_Q.* , E.Emp_Code,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name)  as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,
						Dept_Name,Desig_Name,grd_name,type_name,@From_Date P_From_Date ,@To_Date P_To_Date ,isnull(ms.Ot_hours,0) as Ot_hours,isnull(ms.Ot_amount,0) as Ot_amount,  
						isnull(ms.M_WO_OT_Hours,0) as M_WO_OT_Hours,isnull(ms.M_HO_OT_Hours,0) as M_HO_OT_Hours,isnull(ms.M_WO_OT_Amount,0) as M_WO_OT_Amount,isnull(ms.M_HO_OT_Amount,0) as M_HO_OT_Amount
				,E.Alpha_emp_code --added jimit 01062015
				,DGM.Desig_Dis_No              ---added jimit 24082015
				,Vs.Vertical_Name,sv.SubVertical_Name   --added jimit 29042016
				from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
					 t0200_monthly_salary MS WITH (NOLOCK) on E.Emp_ID =MS.Emp_Id inner join
					 T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		    					( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join					
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
							#GEN G ON G.Branch_ID=I_Q.Branch_ID   Left Outer JOIN--Added by Nimesh 17-Jul-2015 (For Different salary cycle for different branch)
							T0040_Vertical_Segment Vs WITH (NOLOCK) ON Vs.Vertical_ID = I_Q.vertical_Id LEFT outer JOIN
							T0050_SubVertical sv WITH (NOLOCK) On sv.SubVertical_ID = I_Q.SubVertical_ID
				--WHERE E.Cmp_ID = @Cmp_Id and  MS.month_st_date >= @From_Date and MS.month_end_date <= @To_Date and (Ms.OT_Hours > 0 or Ms.M_HO_OT_Hours > 0 or M_WO_OT_Hours > 0)
				WHERE E.Cmp_ID = @Cmp_Id and  MS.month_st_date >= G.Sal_St_date and MS.month_end_date <= G.Sal_End_date and (Ms.OT_Hours > 0 or Ms.M_HO_OT_Hours > 0 or M_WO_OT_Hours > 0)
						And E.Emp_ID in (select Emp_ID From #Emp_Cons) order by E.Emp_Code asc 
			END
	
	 IF @Return_Record_Set = 'Pending Overtime'
			BEGIN
		
			 CREATE table #Data         
			   (         
				   Emp_Id   numeric ,         
				   For_date datetime,        
				   Duration_in_sec numeric,        
				   Shift_ID numeric ,        
				   Shift_Type numeric ,        
				   Emp_OT  numeric ,        
				   Emp_OT_min_Limit numeric,        
				   Emp_OT_max_Limit numeric,        
				   P_days  numeric(12,3) default 0,
				   OT_Sec  numeric default 0  ,
				   In_Time datetime,
				   Shift_Start_Time datetime,
				   OT_Start_Time numeric default 0,
				   Shift_Change tinyint default 0,
				   Flag int default 0,
				   Weekoff_OT_Sec  numeric default 0,
				   Holiday_OT_Sec  numeric default 0,   
				   Chk_By_Superior numeric default 0,
				   IO_Tran_Id	   numeric default 0,
				   OUT_Time datetime,
				   Shift_End_Time datetime,
				   OT_End_Time numeric default 0,
				   Working_Hrs_St_Time tinyint default 0,
				   Working_Hrs_End_Time tinyint default 0,
				   GatePass_Deduct_Days numeric(18,2) default 0
			   )     
		
			--This SP is Just Executed to take Total OT Hours in Case of Auto_OT Approval--
			exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@constraint=@constraint,@Return_Record_set=4
		
		
		
			SELECT	I_Q.Emp_ID, 
						E.Emp_Code,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,
						Dept_Name,Desig_Name,grd_name,type_name,E.Alpha_emp_code,DGM.Desig_Dis_No , MS.Month_St_Date , MS.Month_End_Date,I_Q.Inc_Bank_AC_No,
						dbo.F_Return_Hours(Sum(OTA.Approved_OT_Sec)) as Approved_OT_Hours ,
						Isnull(MP.Over_Time,0) as Imported_OT_Hours,
						dbo.F_Return_Hours(Sum(OTA.Approved_WO_OT_Sec)) as Approved_WO_OT_Hours , 
						Isnull(MP.WO_OT_Hour,0) as Imported_WO_OT_Hours,
						dbo.F_Return_Hours(Sum(OTA.Approved_HO_OT_Sec)) as Approved_HO_OT_Hours,
						Isnull(MP.HO_OT_Hour,0) as Imported_HO_OT_Hours ,
						Isnull(Sum(Approved_OT_Sec + Approved_WO_OT_Sec + Approved_HO_OT_Sec),0) as Total_OT_Seconds,
						Isnull(Replace(dbo.F_Return_Hours(Sum(Approved_OT_Sec + Approved_WO_OT_Sec + Approved_HO_OT_Sec)),':' , '.'),0) + ISNULL((MP.Over_Time + MP.WO_OT_Hour + MP.HO_OT_Hour),0) as Total_OT_Hours,
						--Cast(Replace(dbo.F_Return_Hours(isnull(ms.Ot_hours,0)*3600),':','.') as numeric(18,2)) as Paid_OT_Hours,
						Case When ISNULL(Ms.OT_Hours,0) < isnull(Cast(Replace(I_Q.Emp_OT_Max_Limit,':','.') as Numeric(18,2)) ,0) and ISNULL(Ms.OT_Amount,0) = 0 Then
						  Cast(Replace(dbo.F_Return_Hours((isnull(ms.Ot_hours,0)+ISNULL(ms.M_WO_OT_hours,0)+ISNULL(ms.M_HO_OT_Hours,0))*3600),':','.') as numeric(18,2)) 
						Else
						  Cast(Replace(dbo.F_Return_Hours(isnull(ms.Ot_hours,0)*3600),':','.') as numeric(18,2))
						End 
						as Paid_OT_Hours,
						OT_QRY.OT_AMOUNT as Paid_OT_Amount
						,CASE 
						WHEN Isnull(Sum(Approved_OT_Sec + Approved_WO_OT_Sec + Approved_HO_OT_Sec),0) > 0 Then
							Case WHEN  ISNULL(Ms.OT_Hours,0) < isnull(Cast(Replace(I_Q.Emp_OT_Max_Limit,':','.') as Numeric(18,2)) ,0) and ISNULL(Ms.OT_Amount,0) = 0 Then
							  Isnull(Replace(dbo.F_Return_Hours(Sum(Approved_OT_Sec + Approved_WO_OT_Sec + Approved_HO_OT_Sec)),':' , '.'),0) + ISNULL((MP.Over_Time + MP.WO_OT_Hour + MP.HO_OT_Hour),0) - Cast(Replace(dbo.F_Return_Hours((isnull(ms.Ot_hours,0)+ISNULL(ms.M_WO_OT_hours,0)+ISNULL(ms.M_HO_OT_Hours,0))*3600),':','.') as numeric(18,2))
							else
							  Isnull(Replace(dbo.F_Return_Hours(Sum(Approved_OT_Sec + Approved_WO_OT_Sec + Approved_HO_OT_Sec)),':' , '.'),0) + ISNULL((MP.Over_Time + MP.WO_OT_Hour + MP.HO_OT_Hour),0) - Cast(Replace(dbo.F_Return_Hours(isnull(ms.Ot_hours,0)*3600),':','.') as numeric(18,2))
							End
						Else
							Isnull(Replace(dbo.F_Return_Hours(Sum(Data.OT_Sec)),':','.') - Cast(Replace(dbo.F_Return_Hours(isnull(ms.Ot_hours,0)* 3600),':','.') as numeric(18,2)),0)
						End  
						as Pending_OT_Hours
						,ISNULL(dbo.F_Return_Hours(Data.OT_Sec),0) as Auto_OT_Hours
						,Vs.Vertical_Name,sv.SubVertical_Name   --added jimit 29042016
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					LEFT Outer JOIN T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID =OTA.Emp_Id and OTA.For_Date >= @from_date and OTA.For_Date <= @to_date   
					INNER JOIN t0200_monthly_salary MS WITH (NOLOCK) on E.Emp_ID =MS.Emp_Id 
					INNER JOIN T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID 
					INNER JOIN
		    					(	select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID , Inc_Bank_AC_No , I.Emp_OT_Max_Limit,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) INNER JOIN 
										( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
											where Increment_Effective_date <= @To_Date
											and Cmp_ID = @Cmp_ID
											group by emp_ID  
										) Qry 
										on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
								) I_Q 
								on E.Emp_ID = I_Q.Emp_ID  
					INNER JOIN		T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN	T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID
					LEFT OUTER JOIN #GEN G ON G.Branch_ID=I_Q.Branch_ID
					Left OUTER JOIN T0190_MONTHLY_PRESENT_IMPORT MP WITH (NOLOCK) ON MP.Emp_ID = E.Emp_ID and (MP.Month = Month(@from_date) and MP.Year = Year(@from_date))
					left outer JOIN (
										select MS.Emp_ID, CASE WHEN AD_CALCULATE_ON = 'Transfer OT' THEN EED.M_AD_Amount 
																ELSE MS.OT_Amount END as OT_AMOUNT, ms.Month_End_Date
										from  #Emp_Cons E
										inner JOIN  T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON Ms.Emp_ID = e.EMP_ID			 
										LEFT OUTER JOIN (SELECT AD_CALCULATE_ON,M_AD_Amount, EED.Sal_Tran_ID 
														 FROM	T0210_MONTHLY_AD_DETAIL EED WITH (NOLOCK)
														 INNER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON EED.AD_ID=ADM.AD_ID AND AD_CALCULATE_ON = 'Transfer OT') EED  ON MS.Sal_Tran_ID=EED.Sal_Tran_ID 				
										where MS.CMP_ID = @Cmp_Id  AND MS.Month_End_Date BETWEEN @FROM_DATE AND @TO_DATE
									) OT_QRY ON OT_QRY.Emp_ID=E.Emp_ID
					LEFT JOIN (SELECT Emp_ID, SUM(OT_Sec) As OT_Sec FROM #Data Where For_date >= @from_date and For_date  <= @to_date  Group BY Emp_ID) Data ON Data.Emp_Id = E.Emp_ID 
					Left Outer JOIN	T0040_Vertical_Segment Vs WITH (NOLOCK) ON Vs.Vertical_ID = I_Q.vertical_Id 
					LEFT outer JOIN	T0050_SubVertical sv WITH (NOLOCK) On sv.SubVertical_ID = I_Q.SubVertical_ID
				WHERE E.Cmp_ID = @Cmp_Id and  			
				MS.month_st_date >= G.Sal_St_date and MS.month_end_date <= G.Sal_End_date and (Ms.OT_Hours > 0 or Ms.M_HO_OT_Hours > 0 or M_WO_OT_Hours > 0) And
				 E.Emp_ID in (select Emp_ID From #Emp_Cons)
				GROUP BY I_Q.Emp_id , Ot_hours , OT_QRY.OT_AMOUNT ,MP.Over_Time , MP.WO_OT_Hour , MP.HO_OT_Hour , MS.OT_Amount , M_WO_OT_hours , M_HO_OT_hours
				, Emp_Code, EmpName_Alias_Salary , Emp_Full_Name ,BM.branch_name,branch_address,Comp_name,Cmp_Name,Cmp_Address
				, Dept_Name,Desig_Name,grd_name,type_name ,Emp_OT_Max_Limit , Alpha_emp_code,Desig_Dis_No ,  MS.Month_St_Date , MS.Month_End_Date , I_Q.Inc_Bank_AC_No , Data.OT_Sec
				,Vs.Vertical_Name,sv.SubVertical_Name
				ORDER BY E.EMP_CODE ASC 
			
			END			
		
		
	RETURN

