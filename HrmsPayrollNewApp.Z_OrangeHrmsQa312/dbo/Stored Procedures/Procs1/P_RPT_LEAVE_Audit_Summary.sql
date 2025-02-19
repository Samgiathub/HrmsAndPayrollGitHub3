


-- Created by rohit on 12122015 for Leave Audit report inductotherm.
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_LEAVE_Audit_Summary]
	 @Company_Id		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric = 0
	,@Cat_ID		Numeric = 0
	,@Grade_ID		Numeric = 0
	,@Type_ID		Numeric = 0
	,@Dept_Id		Numeric = 0
	,@Desig_Id		Numeric = 0
	,@Emp_ID		Numeric = 0
	,@leave_id      varchar(5000)=''
	,@Constraint	varchar(max) = ''
	,@Flag			tinyint =0 --Added by Sumit Leave Encash Slip 08032016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	/*  --> This Portion is Commented By Ramiz on 23/09/2016 as Increment ID was Required for Back Dated Entry
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grade_ID = 0  
		set @Grade_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Company_Id
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
			Where Cmp_ID = @Company_Id 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grade_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
				where cmp_ID = @Company_Id   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		end
*/
--New Code of #EMP_Cons is Added By Ramiz on 23/09/2016
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0
--Code of #EMP_CONS ends here

	Create table #Emp_Leave_Bal 
			(
				Cmp_ID			numeric,
				Emp_ID			numeric,
				Leave_ID		numeric,
				Leave_Opening	numeric(18,2),
				Leave_Laps		numeric(18,2),
				Leave_Credit	numeric(18,2),
				Leave_Used		numeric(18,2),
				Leave_Closing	numeric(18,2),
				Leave_Posting	numeric(18,2),
				Leave_Encash_Days	numeric(18,2),
				Back_Dated_Leave	numeric(18,2),
				LeaveClosing_CF numeric(18,2) default 0
				
			)
--Added below condition by Sumit 08032016
if @leave_id=''
	Begin
		select @leave_id=(COALESCE(@leave_id + ',', '') +  '' + cast(Leave_ID as varchar(max)) + '')	from T0040_LEAVE_MASTER WITH (NOLOCK)
		where Cmp_id = @Company_Id	
		
		SELECT @leave_id=RIGHT(@leave_id, LEN(@leave_id) - 1)
	End			
if @Flag=1
	Begin
		set @leave_id=REPLACE(@leave_id,'#',',')
	End		

insert into #Emp_Leave_Bal
 select lt.Cmp_id,LT.Emp_id,Leave_id ,0 as leave_opening,sum(ISNULL(CF_Laps_Days,0)) as Leave_Laps,sum(isnull(Leave_Credit,0)) as Leave_Credit,
 sum(isnull(Leave_Used,0) +  ISNULL(Half_Payment_Days,0)) as Leave_Used,  --added by rohit for  Half_payment Days as per Discussion with Hardikbhai on 17122015
 0 as Leave_Closing, 
 sum(isnull(Leave_Posting,0)) as Leave_Posting,
 sum(isnull(Leave_Encash_Days,0)) as Leave_Encash_Days,
	sum(isnull(Back_Dated_Leave,0)) as Back_Dated_Leave,0
	from  dbo.T0140_LEAVE_TRANSACTION AS LT WITH (NOLOCK) INNER JOIN
	#Emp_Cons EC on LT.emp_id = EC.emp_id	where for_date >=@From_Date and for_date <= @to_date and cmp_id=@Company_Id 
	and leave_id in (select data from dbo.split(@leave_id,','))
	group by lt.Cmp_id,lt.emp_id,leave_id 

--commented by Krushna 07012020	
--update #Emp_Leave_Bal 
--	set Leave_Opening = leave_Bal.Leave_Closing
--	From #Emp_Leave_Bal  LB Inner join  
--	( select lt.* From T0140_leave_Transaction LT inner join 
--		( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction where For_date <= @From_Date and Cmp_ID = @Company_Id
--		Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
--		)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 

--Udpate by Krushna 07012020 due to mid of year employee join
	update	#Emp_Leave_Bal 
	set		Leave_Opening = leave_Bal.Leave_Opening
	From	#Emp_Leave_Bal  LB 
			Inner join (
							select	lt.* 
							From	T0140_leave_Transaction LT WITH (NOLOCK) 
									inner join (
													select	min(For_Date) For_Date , T0140_leave_Transaction.Emp_ID ,leave_ID 
													from	T0140_leave_Transaction WITH (NOLOCK)
															inner join #Emp_Cons EC on  T0140_leave_Transaction.Emp_ID = EC.Emp_ID
															Inner join T0080_EMP_MASTER E WITH (NOLOCK) on EC.Emp_ID = E.Emp_ID
													where	For_date >= (case when @From_Date >= E.Date_Of_Join then @From_Date 
																				else E.Date_Of_Join end)
															and T0140_leave_Transaction. Cmp_ID = @Company_Id
													Group by T0140_leave_Transaction.Emp_ID ,T0140_leave_Transaction.LEave_ID 
												) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
			)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 

update #Emp_Leave_Bal 
set Leave_Opening = leave_Bal.Leave_Opening
From #Emp_Leave_Bal  LB Inner join  
( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
	( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date = @From_Date and Cmp_ID = @Company_Id
	Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
	)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
				
update #Emp_Leave_Bal 
set Leave_Closing = leave_Bal.Leave_Closing 
From #Emp_Leave_Bal  LB Inner join  
( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
	( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) WHERE CAST(CAST(For_date AS VARCHAR(11))AS DATETIME) <= @To_Date and Cmp_ID = @Company_Id
	Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
	)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
	
	
if @Flag=0
	Begin	
		SELECT     TOP (100) PERCENT l.Cmp_ID, e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name,BM.Branch_Name,g.Grd_Name, d.Dept_Name, t.Type_Name, 
                      c.Cat_Name, de.Desig_Name, 
                      convert(varchar(15),E.date_of_join ,103) as date_of_join
                      , l.Leave_ID, dbo.T0040_LEAVE_MASTER.Leave_Name,
                      l.Leave_Opening, l.Leave_Credit, l.Leave_Used, l.Leave_Closing
                      --,l.Leave_Posting  -- Commenetd by rohit as per Discussion with hardikbhai on 17122015
                      --, l.Leave_Adj_L_Mark, 
                      --l.CompOff_Credit, l.CompOff_Debit, l.CompOff_Balance, l.CompOff_Used
                      ,l.Leave_Encash_Days,l.Back_Dated_Leave
                      --,l.Half_Payment_Days
		FROM #Emp_Leave_Bal l        
			INNER JOIN
			dbo.T0080_EMP_MASTER AS e WITH (NOLOCK) ON l.Emp_ID = e.Emp_ID AND l.Cmp_ID = e.Cmp_ID  INNER JOIN	
			#Emp_Cons EC			  ON EC.Emp_ID = E.Emp_ID inner join
			dbo.T0095_INCREMENT IC	  WITH (NOLOCK) ON IC.Increment_ID = EC.Increment_ID 	INNER JOIN
			dbo.T0040_GRADE_MASTER AS g WITH (NOLOCK) ON IC.Grd_ID = g.Grd_ID INNER JOIN
			dbo.T0040_LEAVE_MASTER WITH (NOLOCK) ON l.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID LEFT OUTER JOIN
			dbo.T0040_DESIGNATION_MASTER AS de WITH (NOLOCK) ON IC.Desig_Id = de.Desig_ID LEFT OUTER JOIN
			dbo.T0040_TYPE_MASTER AS t WITH (NOLOCK) ON IC.Type_ID = t.Type_ID LEFT OUTER JOIN
			dbo.T0030_CATEGORY_MASTER AS c WITH (NOLOCK) ON IC.Cat_ID = c.Cat_ID LEFT OUTER JOIN
			dbo.T0040_DEPARTMENT_MASTER AS d WITH (NOLOCK) ON IC.Dept_ID = d.Dept_Id INNER JOIN
			dbo.T0030_Branch_Master BM WITH (NOLOCK) ON BM.Branch_ID = IC.Branch_ID
                      
		WHERE			  
			(l.Leave_Opening <> 0) OR (l.Leave_Credit <> 0) OR (l.Leave_Used <> 0) OR (l.Leave_Closing <> 0)
                      
		ORDER BY e.Emp_Full_Name, T0040_LEAVE_MASTER.leave_name
	End
Else
	Begin
	
	
		declare @CF_Date as datetime
		declare @CF_Fromdate as datetime
		
		
		set @CF_Date=DATEADD(day,2,@To_Date) --Added 2 days for getting Carry forwared Leave
		set @CF_Fromdate=DATEADD(DAY,-2,@CF_Date)
	
	update #Emp_Leave_Bal 
			set LeaveClosing_CF = leave_Bal.Leave_Closing 
			From #Emp_Leave_Bal  LB Inner join  
			( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
			( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) WHERE CAST(CAST(For_date AS VARCHAR(11))AS DATETIME) <= @CF_Date and Cmp_ID = @Company_Id
					Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
			)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 



	update 	#Emp_Leave_Bal 
			set Leave_Credit=isnull(Leave_Bal.Leave_Credit,0)
			from #Emp_Leave_Bal LB inner join
			(select LT.* from dbo.T0140_LEAVE_TRANSACTION AS LT WITH (NOLOCK) INNER JOIN
			(select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where for_date >=@CF_Fromdate and for_date <= @CF_Date and cmp_id=@Company_Id 
					Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
			)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID		

	update #Emp_Leave_Bal
		set Leave_Encash_Days= Leave_Enc.Lv_Encash_Apr_Days
		from #Emp_Leave_Bal LB inner join		
		(select isnull(LA.Lv_Encash_Apr_Days,0) as Lv_Encash_Apr_Days,LA.Leave_ID,LA.Emp_ID,LA.Cmp_ID
			from #Emp_Leave_Bal ED inner join T0120_LEAVE_ENCASH_APPROVAL LA WITH (NOLOCK) on
			ED.Leave_ID=LA.Leave_ID and LA.Emp_ID=ED.Emp_ID and LA.Cmp_ID=ED.Cmp_ID
			and LA.Lv_Encash_Apr_Date >@CF_Fromdate
			and LA.Lv_Encash_Apr_Date <=@CF_Date) Leave_Enc	on
			Leave_Enc.Emp_ID=LB.Emp_ID and Leave_Enc.Leave_ID=LB.Leave_ID and LB.Cmp_ID=Leave_Enc.Cmp_ID
				
				--group by lt.Cmp_id,lt.emp_id,leave_id		
	
		Create Table #EncashDetails
		(
			Emp_ID numeric(18,0),
			Cmp_ID numeric(18,0),
			Leave_ID numeric(18,0),
			PresentDay numeric(18,2),
			WeekoffDay	numeric(18,2),
			OD_Leave numeric(18,2),
			Holiday	numeric(18,2),
			AbsentDay numeric(18,2),
			Paid_Leave numeric(18,2),
			TotalLeaveDays numeric(18,2),
			Leave_Encash_Days numeric(18,2),
			Leave_Encash_Amount numeric(18,2)		
		)
		create clustered index ix_#EncashDetails_Emp_Id_Leave_ID on #EncashDetails(Emp_Id,Leave_ID);
		
		insert into #EncashDetails
			select EL.Emp_ID,EL.Cmp_ID,EL.Leave_ID,
					isnull(MSD.Present_Days,0) as Present_Days,ISNULL(MSD.Weekoff_Days,0) as Weekoff_Days,
					ISNULL(MSD.OD_Leave_Days,0) as OD_Leave_Days,isnull(MSD.Holiday_Days,0) as Holiday_Days,
					ISNULL(MSD.Absent_Days,0) as Absent_Days,ISNULL(MSD.Paid_Leave_Days,0) as Paid_Leave_Days,
					ISNULL(MSD.Total_Leave_Days,0) as Total_Leave_Days,--0,0					
					sum(ISNULL(LA.Lv_Encash_Apr_Days,0)),
					sum(ISNULL(LA.Leave_Encash_Amount,0))
					 from
					 #Emp_Leave_Bal EL 
					 inner join #Emp_Cons EC on EC.Emp_ID=EL.Emp_ID 
					 left join
					 T0120_LEAVE_ENCASH_APPROVAL LA WITH (NOLOCK) on LA.Emp_ID=EL.Emp_ID and LA.Leave_ID=EL.Leave_ID					 
					 left join
					 (
						select MS.Emp_ID,MS.Cmp_ID,
						SUM(MS.Present_Days) as Present_Days,
						SUM(Weekoff_Days) as Weekoff_Days,
						SUM(OD_Leave_Days) as OD_Leave_Days,
						SUM(Holiday_Days) as Holiday_Days,
						SUM(Absent_Days) as Absent_Days,
						SUM(Paid_Leave_Days) as Paid_Leave_Days,
						SUM(Total_Leave_Days) as Total_Leave_Days 
						 from T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						 where MS.Month_St_Date >=@From_Date and MS.Month_End_Date<=@To_Date
						 Group By MS.Emp_ID,MS.Cmp_ID
					) MSD
					 on LA.Emp_id = MSD.emp_id and EL.cmp_id = MSD.cmp_id
					 where (LA.Lv_Encash_Apr_Date>=@From_Date and LA.Lv_Encash_Apr_Date<=@To_Date)
					group by EL.Emp_ID,EL.Cmp_ID,EL.Leave_ID, Present_Days,Weekoff_Days,OD_Leave_Days
						 ,Holiday_Days,Absent_Days,Paid_Leave_Days,Total_Leave_Days
		
					--select EL.Emp_ID,EL.Cmp_ID,EL.Leave_ID,
					--SUM(isnull(ASD.Present_Days,0)),SUM(ISNULL(ASD.Weekoff_Days,0)),
					--SUM(ISNULL(ASD.OD_Leave_Days,0)),SUM(isnull(ASD.Holiday_Days,0)),
					--SUM(ISNULL(ASD.Absent_Days,0)),SUM(ISNULL(ASD.Paid_Leave_Days,0)),
					--SUM(ISNULL(ASD.Total_Leave_Days,0)),--0,0
					--sum(ISNULL(ASD.Lv_Encash_Apr_Days,0)),
					--sum(ISNULL(ASD.Leave_Encash_Amount,0))
					-- from
					-- #Emp_Leave_Bal EL 
					--  inner join @Emp_Cons EC on EC.Emp_ID=EL.Emp_ID 
					-- left join
					-- (select LA.Lv_Encash_Apr_Days,LA.Leave_Encash_Amount,LA.Leave_ID,LA.emp_id,MS.Present_Days,Weekoff_Days,OD_Leave_Days
					-- ,Holiday_Days,Absent_Days,Paid_Leave_Days,Total_Leave_Days from T0120_LEAVE_ENCASH_APPROVAL LA
					--   left join
					-- T0200_MONTHLY_SALARY MS 
					-- on  LA.Emp_id = Ms.emp_id and la.cmp_id = Ms.cmp_id
					-- left join @Emp_Cons EC on EC.Emp_ID=LA.Emp_ID
					-- where 
					-- ((MS.Month_St_Date >=@From_Date and MS.Month_End_Date<=@To_Date)
					--  or
					--   --(LA.Lv_Encash_Apr_Date>=@CF_Fromdate and LA.Lv_Encash_Apr_Date<=@CF_Date))
					--   (LA.Lv_Encash_Apr_Date>=@From_Date and LA.Lv_Encash_Apr_Date<=@To_Date))
					-- ) ASD on ASD.Leave_ID=EL.Leave_ID and ASD.Emp_ID=EL.Emp_ID					
					--group by EL.Emp_ID,EL.Cmp_ID,EL.Leave_ID
				
			
				
	update #EncashDetails
		set Leave_Encash_Days= Leave_Enc.Lv_Encash_Apr_Days,
		Leave_Encash_Amount=Leave_Enc.Lv_Encash_Apr_Amount
		from #EncashDetails LB inner join		
		(select isnull(LA.Lv_Encash_Apr_Days,0) as Lv_Encash_Apr_Days,ISNULL(LA.Leave_Encash_Amount,0) as Lv_Encash_Apr_Amount,LA.Leave_ID,LA.Emp_ID,LA.Cmp_ID
			from #Emp_Leave_Bal ED inner join T0120_LEAVE_ENCASH_APPROVAL LA WITH (NOLOCK) on
			ED.Leave_ID=LA.Leave_ID and LA.Emp_ID=ED.Emp_ID and LA.Cmp_ID=ED.Cmp_ID
			and LA.Lv_Encash_Apr_Date >@CF_Fromdate
			and LA.Lv_Encash_Apr_Date <=@CF_Date) Leave_Enc	on
			Leave_Enc.Emp_ID=LB.Emp_ID and Leave_Enc.Leave_ID=LB.Leave_ID and LB.Cmp_ID=Leave_Enc.Cmp_ID
			

--** Commented and Code Changed By Ramiz on 23/09/2016 for Taking Entry from Increment , instead of Employee Master 
--** and also for Optimization

/*
SELECT     TOP (100) PERCENT l.Cmp_ID, e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name, g.Grd_Name, d.Dept_Name, t.Type_Name, 
                c.Cat_Name, de.Desig_Name, 
                convert(varchar(15),E.date_of_join ,103) as date_of_join
                , l.Leave_ID, LM.Leave_Name,
                l.Leave_Opening, l.Leave_Credit, l.Leave_Used, l.Leave_Closing
                --,l.Leave_Posting  -- Commenetd by rohit as per Discussion with hardikbhai on 17122015
                --, l.Leave_Adj_L_Mark, 
                --l.CompOff_Credit, l.CompOff_Debit, l.CompOff_Balance, l.CompOff_Used
                ,l.Leave_Encash_Days,l.Back_Dated_Leave,l.LeaveClosing_CF
                --,l.Half_Payment_Days
FROM #Emp_Leave_Bal l        
	INNER JOIN
	#EncashDetails ED on ED.Emp_ID=l.Emp_ID and ED.Cmp_ID=l.Cmp_ID and l.Leave_ID=ed.Leave_ID inner join
    dbo.T0080_EMP_MASTER AS e ON l.Emp_ID = e.Emp_ID AND l.Cmp_ID = e.Cmp_ID INNER JOIN
    
    dbo.T0040_GRADE_MASTER AS g ON e.Grd_ID = g.Grd_ID INNER JOIN
    dbo.T0040_LEAVE_MASTER LM ON l.Leave_ID = LM.Leave_ID Inner JOIN
    dbo.T0040_DESIGNATION_MASTER AS de ON e.Desig_Id = de.Desig_ID LEFT OUTER JOIN
    dbo.T0040_TYPE_MASTER AS t ON e.Type_ID = t.Type_ID LEFT OUTER JOIN
    dbo.T0030_CATEGORY_MASTER AS c ON e.Cat_ID = c.Cat_ID LEFT OUTER JOIN
    dbo.T0040_DEPARTMENT_MASTER AS d ON e.Dept_ID = d.Dept_Id
                      
WHERE LM.Leave_Type='Encashable' and		  
((l.Leave_Opening <> 0) OR (l.Leave_Credit <> 0) OR (l.Leave_Used <> 0) OR (l.Leave_Closing <> 0))                    
ORDER BY e.Emp_Full_Name, LM.leave_name


select  ED.*,
	 e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name, g.Grd_Name, d.Dept_Name, t.Type_Name, 
                      c.Cat_Name, de.Desig_Name, 
                      convert(varchar(15),E.date_of_join ,103) as date_of_join
                      , ED.Leave_ID, LM.Leave_Name,
                      @From_Date as From_Date,
                      @To_Date as To_Date,CM.Cmp_Name,Cmp_Address,
                      E.Alpha_Emp_Code,BM.Branch_Name,BM.Branch_Address,@CF_Fromdate as CF_FromDate,
                      @CF_Date as CF_ToDate,
                      isnull(BNM.Bank_Name,'') as Bank_Name,isnull(QRy.Inc_Bank_AC_No,'') as Inc_Bank_AC_No
                      
	 from #EncashDetails ED inner join
	dbo.T0080_EMP_MASTER AS e ON ED.Emp_ID = e.Emp_ID AND ED.Cmp_ID = e.Cmp_ID INNER JOIN
	#Emp_Cons EC on EC.Emp_ID=E.Emp_ID inner join
	T0040_LEAVE_MASTER LM on LM.Leave_ID=ED.Leave_ID and LM.Cmp_ID=ED.Cmp_ID  
	inner join	
		(
			select IC.Increment_ID,IC.Emp_ID,IC.Cat_ID,IC.Bank_ID,IC.Inc_Bank_AC_No from t0095_increment IC 
			inner join
				(
					Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
					Where Increment_effective_Date <= @To_Date Group by emp_ID
				) new_inc on IC.Emp_ID = new_inc.Emp_ID and IC.Increment_Effective_Date=new_inc.Increment_Effective_Date
			Where IC.Increment_effective_Date <= @To_Date
		) Qry on EC.Increment_Id = Qry.Increment_Id and EC.Emp_ID=Qry.Emp_ID
	LEFT join
	dbo.T0040_GRADE_MASTER AS g ON e.Grd_ID = g.Grd_ID left outer join
	dbo.T0040_TYPE_MASTER AS t ON e.Type_ID = t.Type_ID LEFT OUTER JOIN
    dbo.T0030_CATEGORY_MASTER AS c ON e.Cat_ID = c.Cat_ID LEFT OUTER JOIN
     dbo.T0030_BRANCH_MASTER BM on BM.Branch_ID=E.Branch_ID left OUTER join
    dbo.T0010_COMPANY_MASTER CM on CM.Cmp_Id=ED.Cmp_ID LEFT OUTER JOIN
    dbo.T0040_DESIGNATION_MASTER AS de ON e.Desig_Id = de.Desig_ID LEFT JOIN
    dbo.T0040_DEPARTMENT_MASTER AS d ON e.Dept_ID = d.Dept_Id left join
    dbo.T0040_BANK_MASTER BNM on BNM.Bank_ID=Qry.Bank_ID
    where LM.Leave_type='Encashable' and ED.Cmp_ID=@Company_Id
*/			

------added by jimit 24032017
			
			 Declare @Lv_Encash_Cal_On varchar(50)   
			 Declare @Lv_Encash_W_Day Numeric
			 SET @Lv_Encash_Cal_On = ''   
			 Set @Lv_Encash_W_Day = 0
			
			select @Lv_Encash_Cal_On = Lv_Encash_Cal_On,@Lv_Encash_W_Day = Lv_Encash_W_Day 
			FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @Company_Id AND Branch_ID = ISNULL(@Branch_ID,Branch_ID)
			AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@To_Date AND Branch_ID = ISNULL(@Branch_ID,Branch_ID) AND Cmp_ID = @Company_ID) 
				   
	
			
-----ended------------



--New Code Added By Ramiz on 23/09/2016--
			
				SELECT     TOP (100) PERCENT l.Cmp_ID, e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name, g.Grd_Name, d.Dept_Name, t.Type_Name, 
								c.Cat_Name, de.Desig_Name, convert(varchar(15),E.date_of_join ,103) as date_of_join
								, l.Leave_ID, LM.Leave_Name,
								l.Leave_Opening, l.Leave_Credit, l.Leave_Used, l.Leave_Closing
								,l.Leave_Encash_Days,l.Back_Dated_Leave,l.LeaveClosing_CF
				FROM #Emp_Leave_Bal l        
					INNER JOIN  #EncashDetails ED on ED.Emp_ID=l.Emp_ID and ED.Cmp_ID=l.Cmp_ID and l.Leave_ID=ed.Leave_ID
					INNER JOIN	#Emp_Cons EC on EC.Emp_ID = ED.Emp_ID
					inner join	T0095_INCREMENT IC WITH (NOLOCK) on IC.Increment_ID = EC.Increment_ID 
					inner join		dbo.T0080_EMP_MASTER			E	WITH (NOLOCK) ON l.Emp_ID = e.Emp_ID AND l.Cmp_ID = e.Cmp_ID 
					INNER JOIN		dbo.T0040_GRADE_MASTER			G	WITH (NOLOCK) ON IC.Grd_ID = g.Grd_ID 
					INNER JOIN		dbo.T0040_LEAVE_MASTER			LM	WITH (NOLOCK) ON l.Leave_ID = LM.Leave_ID
					Inner JOIN		dbo.T0040_DESIGNATION_MASTER	DE	WITH (NOLOCK) ON IC.Desig_Id = de.Desig_ID
					LEFT OUTER JOIN dbo.T0040_TYPE_MASTER			T	WITH (NOLOCK) ON IC.Type_ID = t.Type_ID 
					LEFT OUTER JOIN dbo.T0030_CATEGORY_MASTER		C	WITH (NOLOCK) ON IC.Cat_ID = c.Cat_ID
					LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER		D	WITH (NOLOCK) ON IC.Dept_ID = d.Dept_Id
				WHERE LM.Leave_Type='Encashable' and		  
				((l.Leave_Opening <> 0) OR (l.Leave_Credit <> 0) OR (l.Leave_Used <> 0) OR (l.Leave_Closing <> 0))                    
				ORDER BY e.Emp_Full_Name, LM.leave_name

				
				
			If @Lv_Encash_Cal_On = 'Gross'
			Begin
			
				
			
				select  ED.*,
					 e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name, g.Grd_Name, d.Dept_Name, t.Type_Name, 
									  c.Cat_Name, de.Desig_Name, 
									  convert(varchar(15),E.date_of_join ,103) as date_of_join
									  , ED.Leave_ID, LM.Leave_Name,
									  @From_Date as From_Date,
									  @To_Date as To_Date,CM.Cmp_Name,Cmp_Address,
									  E.Alpha_Emp_Code,BM.Branch_Name,BM.Branch_Address,@CF_Fromdate as CF_FromDate,
									  @CF_Date as CF_ToDate,
									  isnull(BNM.Bank_Name,'') as Bank_Name,isnull(IC.Inc_Bank_AC_No,'') as Inc_Bank_AC_No 
									  ,(IC.Gross_Salary) AS Basic_Salary   --added by jimit 23032017     
					 from #EncashDetails ED 
						 inner join		dbo.T0080_EMP_MASTER E				WITH (NOLOCK) ON ED.Emp_ID = e.Emp_ID AND ED.Cmp_ID = e.Cmp_ID 
						 INNER JOIN		#Emp_Cons EC						ON EC.Emp_ID = ED.Emp_ID 
						 inner join		dbo.T0095_INCREMENT IC				WITH (NOLOCK) ON IC.Increment_ID = EC.Increment_ID 
						 inner join		dbo.T0040_LEAVE_MASTER LM			WITH (NOLOCK) ON LM.Leave_ID=ED.Leave_ID and LM.Cmp_ID=ED.Cmp_ID  
						 LEFT join		dbo.T0040_GRADE_MASTER G			WITH (NOLOCK) ON IC.Grd_ID = g.Grd_ID 
						 left outer join	dbo.T0040_TYPE_MASTER T			WITH (NOLOCK) ON IC.Type_ID = t.Type_ID
						 LEFT OUTER JOIN	dbo.T0030_CATEGORY_MASTER C		WITH (NOLOCK) ON IC.Cat_ID = c.Cat_ID 
						 LEFT OUTER JOIN	dbo.T0030_BRANCH_MASTER BM		WITH (NOLOCK) ON BM.Branch_ID=IC.Branch_ID 
						 left OUTER join	dbo.T0010_COMPANY_MASTER CM		WITH (NOLOCK) ON CM.Cmp_Id=ED.Cmp_ID 
						 LEFT OUTER JOIN	dbo.T0040_DESIGNATION_MASTER DE WITH (NOLOCK) ON IC.Desig_Id = de.Desig_ID 
						 LEFT JOIN			dbo.T0040_DEPARTMENT_MASTER D	WITH (NOLOCK) ON IC.Dept_ID = d.Dept_Id 
						 left join			dbo.T0040_BANK_MASTER BNM		WITH (NOLOCK) ON BNM.Bank_ID=IC.Bank_ID						 
					where LM.Leave_type='Encashable' and ED.Cmp_ID = @Company_Id				
					
			end
			
		else
			begin
				
				CREATE TABLE #Emp_Allow 
				(
					Emp_id NUMERIC,
					AD_Id	NUMERIC,
					Ad_Amount NUMERIC(18,2)
				)
	
	
				INSERT INTO #Emp_Allow
			Select EED.EMP_ID,eed.AD_ID,
				Case When Qry1.Increment_ID >= EED.INCREMENT_ID  Then
					Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
				Else eed.e_ad_Amount End 
			FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
				#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
				T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
					From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
					#Emp_Cons EC ON EC.Emp_Id = EEDR.Emp_ID AND EC.Increment_Id = EEDR.INCREMENT_ID INNER JOIN	
					 ( Select Max(For_Date) For_Date, Ad_Id,EE.EMP_ID From T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
						t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
						Where For_date <= LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
						Group by Ad_Id ,EE.EMP_ID
					 ) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
				
			WHERE EED.CMP_ID = @Company_Id AND Isnull(A.AD_EFFECT_ON_LEAVE,0)=1
			
			UNION 

			SELECT EED.EMP_ID,eed.AD_ID,E_AD_Amount
			FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
				#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
				( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
					t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
					Where For_date <=  LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
					Group by Ad_Id 
				) Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
			   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
			WHERE Adm.AD_ACTIVE = 1 And EEd.ENTRY_TYPE = 'A' AND Isnull(ADM.AD_EFFECT_ON_LEAVE,0)=1
				
				select  ED.*,
					 e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name, g.Grd_Name, d.Dept_Name, t.Type_Name, 
									  c.Cat_Name, de.Desig_Name, 
									  convert(varchar(15),E.date_of_join ,103) as date_of_join
									  , ED.Leave_ID, LM.Leave_Name,
									  @From_Date as From_Date,
									  @To_Date as To_Date,CM.Cmp_Name,Cmp_Address,
									  E.Alpha_Emp_Code,BM.Branch_Name,BM.Branch_Address,@CF_Fromdate as CF_FromDate,
									  @CF_Date as CF_ToDate,
									  isnull(BNM.Bank_Name,'') as Bank_Name,isnull(IC.Inc_Bank_AC_No,'') as Inc_Bank_AC_No 
									  ,(IC.Basic_Salary + ISNULL(SUBI_Q.E_AD_AMOUNT,0)) AS Basic_Salary   --added by jimit 23032017     
					 from #EncashDetails ED 
						 inner join		dbo.T0080_EMP_MASTER E				WITH (NOLOCK) ON ED.Emp_ID = e.Emp_ID AND ED.Cmp_ID = e.Cmp_ID 
						 INNER JOIN		#Emp_Cons EC						ON EC.Emp_ID = ED.Emp_ID 
						 inner join		dbo.T0095_INCREMENT IC				WITH (NOLOCK) ON IC.Increment_ID = EC.Increment_ID 
						 inner join		dbo.T0040_LEAVE_MASTER LM			WITH (NOLOCK) ON LM.Leave_ID=ED.Leave_ID and LM.Cmp_ID=ED.Cmp_ID  
						 LEFT join		dbo.T0040_GRADE_MASTER G			WITH (NOLOCK) ON IC.Grd_ID = g.Grd_ID 
						 left outer join	dbo.T0040_TYPE_MASTER T			WITH (NOLOCK) ON IC.Type_ID = t.Type_ID
						 LEFT OUTER JOIN	dbo.T0030_CATEGORY_MASTER C		WITH (NOLOCK) ON IC.Cat_ID = c.Cat_ID 
						 LEFT OUTER JOIN	dbo.T0030_BRANCH_MASTER BM		WITH (NOLOCK) ON BM.Branch_ID=IC.Branch_ID 
						 left OUTER join	dbo.T0010_COMPANY_MASTER CM		WITH (NOLOCK) ON CM.Cmp_Id=ED.Cmp_ID 
						 LEFT OUTER JOIN	dbo.T0040_DESIGNATION_MASTER DE WITH (NOLOCK) ON IC.Desig_Id = de.Desig_ID 
						 LEFT JOIN			dbo.T0040_DEPARTMENT_MASTER D	WITH (NOLOCK) ON IC.Dept_ID = d.Dept_Id 
						 left join			dbo.T0040_BANK_MASTER BNM		WITH (NOLOCK) ON BNM.Bank_ID=IC.Bank_ID
						 left outer join
								( SELECT ISNULL(SUM(AD_AMOUNT),0) AS E_AD_AMOUNT,EMP_ID FROM #Emp_Allow group by emp_ID	
								) SUBI_Q  ON E.Emp_ID = SUBI_Q.Emp_ID
					where LM.Leave_type='Encashable' and ED.Cmp_ID = @Company_Id			
					
			
			end
					drop table #EncashDetails
					drop table #Emp_Leave_Bal	
	
	
	End					


