


---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0210_MONTHLY_LEAVE_DETAIL_GET]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	numeric
,@Cat_ID 		numeric 
,@Grd_ID 		numeric
,@Type_ID 		numeric
,@Dept_ID 		numeric
,@Desig_ID 		numeric
,@Emp_ID 		numeric
,@constraint 	varchar(max)
,@Sal_Type		numeric = 0
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 24072013
,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 01082013	
,@Status varchar(20) = ''		 -- Added by Nimesh 19 May 2015 (To Filter Salary by Status)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON		
 
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
	if @Segment_Id = 0 
		 set @Segment_Id = null
	IF @Vertical_Id= 0 
		set @Vertical_Id = null
	if @SubVertical_Id = 0 
		set @SubVertical_Id= Null
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 01082013
	set @SubBranch_Id = null	

	
	CREATE TABLE #Emp_Cons
	(      
	   Emp_ID numeric,     
	   Branch_ID Numeric,
	   Increment_ID numeric
	 )  
	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	

	--Added by Nimesh 19 May 2015
	--Filtering Employee Record according to Salary Status
	IF (@Status = 'Hold' OR @Status = 'Done') BEGIN
		DELETE	FROM #Emp_Cons 
		WHERE	Emp_ID NOT IN ( 
								SELECT Emp_ID FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
								WHERE	Month(S.Month_End_Date)=Month(@To_Date) 
										AND Year(S.Month_End_Date)=Year(@To_Date) 
										AND S.Cmp_ID=@Cmp_ID 
										AND S.Salary_Status=@Status
							   )
	END
	

	--Declare @Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
			
			
	--		Insert Into @Emp_Cons

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
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 24072013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
	--	    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013       
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
		  declare @manual_salary_Period as numeric(18,0) -- Comment and added By rohit on 11022013
		  
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)-- Comment and added By rohit on 11022013
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)-- Comment and added By rohit on 11022013
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End 
				
	if @Salary_Cycle_id > 0
		begin
			select @Sal_St_Date = Salary_st_date from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Salary_Cycle_id
		end  
          
		       
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
			   -- Comment and added By rohit on 11022013
			   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   --set @From_Date = @Sal_St_Date
			   --Set @To_Date = @Sal_end_Date   
			   			     
			if @manual_salary_Period =0 
				Begin
				   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
				   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
				   Set @From_Date = @Sal_St_Date
				   Set @To_Date = @Sal_End_Date  
				 end
			else
				begin
					select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)							   
					Set @From_Date = @Sal_St_Date
					Set @To_Date = @Sal_End_Date    
				End	
				-- Comment and added By rohit on 11022013
			End
		
		/* added by Falak on 17-DEC-2010 for NIIT salary Slip */
		-----Start
		Declare @L_Emp_ID as numeric(18,0)
		Declare @L_Leave_ID as numeric(18,0)
		
		Declare @Temp table
			(
			Emp_Id numeric(18,0),
			Leave_T_Id numeric(18,0),
			Leave_Opening numeric(18,2),
			Leave_Used  numeric(18,2),
			LEAVE_CLOSING  numeric(18,2),
			Back_dated_leave numeric(18,2)
			)
		
		
		
		Insert into @Temp SELECT LT.Emp_id,LT.Leave_Id,Leave_Opening,Leave_Used,LEAVE_CLOSING, Back_Dated_Leave FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN  
		(SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
			WHERE FOR_DATE <=@To_Date
		GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID
		where LT.Emp_Id in (select Emp_ID from #EMP_CONS)
		 /*
		Insert into @Temp SELECT EC.Emp_id,MLD.Leave_Id,0,0,0 FROM 
			T0210_MONTHLY_LEAVE_DETAIL  MLD inner join @Emp_Cons Ec on MLD.Emp_ID = Ec.Emp_id
			where for_date >= @From_Date and For_Date <= @To_Date 
		
		--Insert into @Temp SELECT EC.Emp_id,LM.Leave_Id,0,0,0 FROM 
		--	T0040_LEAVE_MASTER LM inner join T0080_EMP_MASTER EM 
		--	 on LM.Cmp_ID = EM.Cmp_id inner join @Emp_Cons Ec on Em.Emp_ID = EC.Emp_ID 
		--	where LM.Leave_Paid_Unpaid = 'P'
			--where for_date >= @From_Date and For_Date <= @To_Date 
				
		Declare LEave_Cur cursor for
			SELECT Emp_id,Leave_T_Id FROM @Temp
		Open Leave_Cur 
		Fetch next from LEave_cur into @L_Emp_ID,@L_Leave_Id
		While @@FETCH_STATUS = 0
		begin
			
			 
			
			Update @Temp
			set Leave_Opening = isnull(Q1.Leave_opening,0)
			from @Temp T inner join 
			(select Emp_id,Leave_ID,isnull(Leave_Opening,0)Leave_Opening from T0140_LEave_Transaction LT1 where for_Date =		
			(SELECT MIN(FOR_dATE) FOR_DATE FROM T0140_LEAVE_TRANSACTION 
			WHERE FOR_DATE >=@From_Date and Emp_ID = @L_Emp_ID and LEave_ID = @L_LEave_ID)
			) Q1 ON T.EMP_ID = Q1.EMP_ID AND T.LEAVE_T_ID = Q1.LEAVE_ID	
			where T.Emp_Id = @L_Emp_ID and T.Leave_T_Id = @L_Leave_ID 
			
			--Update @Temp
			--set Leave_Used = Q1.LEave_Used
			--from @Temp T inner join	
			--(Select Emp_ID,Leave_Id,isnull(sum(Leave_Days),0) as LEave_Used from T0210_Monthly_LEave_Detail where cmp_id = @cmp_id and for_Date >= @From_Date and
			--for_date <= @To_Date and Emp_ID = @L_Emp_ID GROUP BY EMP_ID,LEAVE_ID ) Q1  
			--on T.Emp_id = Q1.Emp_ID and T.Leave_T_ID = Q1.Leave_Id
			--where T.Emp_Id = @L_Emp_ID and T.Leave_T_Id = @L_Leave_ID
			
			
			Update @Temp 
			set Leave_Used  = isnull(Q2.Leave_Used,0)
			from @Temp T Left Outer join
			(Select Emp_Id,LEave_ID,isnull(sum(LEave_Used),0) Leave_Used from T0140_LEave_Transaction where for_Date between @From_Date and @To_Date 
				group by Emp_ID ,Leave_ID ) Q2
			 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
			where T.Emp_Id = @L_Emp_ID and T.Leave_T_Id = @L_Leave_ID 
			
			Update @Temp 
			set LEAVE_CLOSING = isnull(Q2.Leave_Closing,0)
			from @Temp T Left Outer join
			(Select Emp_Id,LEave_ID,isnull(LEave_Closing,0)LEave_Closing from T0140_LEave_Transaction where for_Date =
			(SELECT MAX(FOR_dATE) FOR_DATE FROM T0140_LEAVE_TRANSACTION 
			WHERE FOR_DATE <=@To_Date and Emp_ID = @L_Emp_ID and LEave_ID = @L_LEave_ID)) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
			where T.Emp_Id = @L_Emp_ID and T.Leave_T_Id = @L_Leave_ID 
			
			Fetch next from Leave_Cur into @L_Emp_Id,@L_Leave_Id
		end
		close Leave_Cur
		deallocate Leave_Cur
		*/
		--Insert into @Temp SELECT LT.Emp_id,LT.Leave_Id,Leave_Opening,MLD.M_Leave,LEAVE_CLOSING FROM T0140_LEAVE_TRANSACTION LT INNER JOIN  
		--(SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION 
		--	WHERE FOR_DATE <=@To_Date
		--GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		--LT.FOR_DATE = Q.FOR_DATE left outer join
		--(Select Emp_ID,Leave_Id,isnull(sum(Leave_Days),0) as M_Leave from T0210_Monthly_LEave_Detail where cmp_id = @cmp_id and
		--	for_date <= @To_Date group by Emp_Id,Leave_ID ) MLD  on LT.Emp_id = MLD.Emp_ID and LT.Leave_ID = MLD.Leave_Id
		--INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID = LM.LEAVE_ID
		--where LT.Emp_Id in (select Emp_ID from @Emp_cons)
		 
	 ---End
	 
	-- Changed By Ali 22112013
	Select MLD.*,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Branch_Address,Comp_name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Leave_Name,Leave_Code
			,LD.*,BM.Branch_ID		
		 From T0210_MONTHLY_LEAVE_DETAIL  MLD WITH (NOLOCK) Inner join 
			  T0040_LEAVE_MASTER LM WITH (NOLOCK) ON MLD.Leave_ID = LM.Leave_ID INNER JOIN 
		T0080_EMP_MASTER E WITH (NOLOCK) on MLD.emp_ID = E.emp_ID INNER  JOIN 
			#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			@Temp as LD on LD.Emp_ID = EC.Emp_Id and LD.Leave_T_ID = MLD.LEave_ID
			inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  LEft outer join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
					
		WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
	
					
	RETURN 




