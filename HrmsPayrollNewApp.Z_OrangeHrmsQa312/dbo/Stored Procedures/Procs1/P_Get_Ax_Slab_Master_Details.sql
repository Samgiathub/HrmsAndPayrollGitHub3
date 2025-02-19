CREATE PROCEDURE [dbo].[P_Get_Ax_Slab_Master_Details]
@Cmp_ID NUMERIC(18,0),
@FROM_DATE Datetime,
@TO_DATE Datetime,
@Cost_Center Varchar(Max) = '',
@Business_Segment Varchar(Max) = ''

AS 
BEGIN

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET ARITHABORT ON;

	
Create table #Tempdetails (
	cost_slab_id numeric,
	Cmp_id numeric(18,0),
	effective_date datetime,
	bandid varchar(Max),
	business_segment1 varchar(Max),
	cost_center_id varchar(Max),
	cost_center_percentage varchar(Max),
	cost_slab_name varchar(Max)
)


Create table #Tempslabid (
	tempslabid numeric
)



Create table #Tempcostper (
	cmp_id numeric,
	costper numeric
)

Create table #Tempfinaldetails (
	slabid numeric,
	effective_date datetime,
	bandid varchar(Max),
	business_segment1 varchar(Max),
	cost_center_id varchar(Max),
	cost_slab_name varchar(Max),
	cost_center_percentage varchar(Max)
)

Create table #tempdata (
	effective_date datetime,
	slabid numeric,
	cost_slab_name varchar(max),
	BandId numeric,
	Band_Name varchar(max),
	Segment_ID numeric,
	Segment_Name varchar(max),
	Center_ID numeric,
	Center_Name varchar(max),
	Cost_Amount numeric
)

Create table #Increment (
	Cmp_id numeric(18,0),
	Emp_id numeric(18,0),
	Increment_id numeric(18,0),
	Basic_Salary numeric(18,0),
	Band_id numeric(18,0),
	Segment_id numeric(18,0),
	Center_id numeric(18,0),
)



declare @bandid varchar(max) = '',
@busi_seg varchar(max) = '',
@cost_centerid varchar(max) = '',
@cost_center_percentage varchar(Max) ='',
@countofrec numeric = 0,
@count numeric ,
@costslabid numeric = 0,
@slabid numeric = 0

set @count = 0

		Insert into #Tempdetails

		select cost_slab_id,Cmp_id,effective_date,Replace(bandid,'#',',' ) + '0',Replace(business_segment,'#',',' ) + '0' ,Replace(cost_center_id,'#',',' ) + '0',Replace(cost_center_percentage,'#',',' ) + '0',
		Cost_Slab_Name
		from T0040_Master_Cost_Center
		where Cmp_id = @Cmp_ID and Cast(effective_date as Date)  between Cast(@FROM_DATE as Date) and Cast(@TO_DATE as date)

		
		select @countofrec = count(Cost_Slab_id) from T0040_Master_Cost_Center where Cmp_id = @Cmp_ID

		--select ROW_NUMBER() OVER (ORDER BY cost_slab_id ASC) AS rownumber, cost_slab_id from #Tempdetails where Cmp_id = @Cmp_ID

		while @count < @countofrec
		begin
			
			set @count = @count + 1

			select @costslabid = cost_slab_id   from 
			(select ROW_NUMBER() OVER (ORDER BY cost_slab_id ASC) AS rownumber, cost_slab_id from #Tempdetails where Cmp_id = @Cmp_ID) as bl
			where rownumber = @count
			
			select @bandid = bandid,@busi_seg = business_segment1,@cost_centerid = cost_center_id,@cost_center_percentage = cost_center_percentage
			from #Tempdetails
			where Cmp_id = @Cmp_ID and cost_slab_id = @costslabid

			Create table #Tempbandid (
				slabid numeric,
				bandid numeric
			)

			Create table #Tempband (
				bandid numeric,
				cmp_id numeric,
				band_name varchar(max)
			)
			
			Create table #Tempbusiid (
				busi_segmentid numeric
			)

			Create table #Tempbusi (
				segid numeric,
				cmp_id numeric,
				busi_segment varchar(max)
			)

			Create table #Tempcostid (
				rn1 numeric,
				cmp_id numeric,
				costid numeric
			)

			Create table #Tempcostamt (
				rn2 numeric,
				cmp_id numeric,
				costamt numeric
			)

			Create table #Tempcost (
				cmp_id numeric,
				cost_name varchar(max),
				costId numeric
			)

			Create table #TempOnlycost (
				cmp_id numeric,
				cost_name varchar(max),
				costamt numeric
			)

			Create table #tempCostAndId12(
				slabid numeric,
				rnCostAndId numeric,
				cmp_id numeric,
				costId numeric,
				costAmt numeric
			)

			
			insert into #Tempbandid
			select  @costslabid,cast(data  as numeric) from dbo.Split (@bandid,',')

			Insert into #Tempband
			Select BandId,Cmp_Id,BandName from tblBandMaster 
			where BandId in (select bandid from #Tempbandid where slabid = @costslabid) and Cmp_Id = @Cmp_ID  order by BandId desc 	
	
			
			Insert into #Tempbusiid
			select  cast(data  as numeric) from dbo.Split (@busi_seg,',')

			Insert into #Tempbusi
			select Segment_ID,Cmp_ID,Segment_Name from T0040_Business_Segment 
			where Cmp_ID = @Cmp_ID and Segment_ID in (Select busi_segmentid from #Tempbusiid)  order by Segment_ID desc 

			Insert into #Tempcostid
			select ROW_NUMBER() OVER (ORDER BY @Cmp_ID ASC) AS Rncostid, @Cmp_ID,cast(data  as numeric) from dbo.Split (@cost_centerid,',')
			
			Insert into #Tempcostamt
			select ROW_NUMBER() OVER (ORDER BY @Cmp_ID ASC) AS rownumber,@Cmp_ID,cast(data  as numeric) from dbo.Split (@cost_center_percentage,',')

			
			Insert into #tempCostAndId12
			SELECT @costslabid,C.rn1,C.cmp_id,C.costid,A.costamt FROM #TEMPCOSTID C 
			INNER JOIN  #TEMPCOSTAMT A ON C.rn1 = A.rn2 WHERE C.COSTID > 0 AND COSTAMT > 0

			

			Insert into #Tempcost
			SELECT  CM.CMP_ID,ISNULL(CENTER_NAME,'') AS CENTER_NAME,CN.costid as CostId
			FROM T0040_COST_CENTER_MASTER CM 
			INNER JOIN #TEMPCOSTID  CN ON CM.CENTER_ID = CN.COSTID
			WHERE CM.CMP_ID = @CMP_ID
			
			--and Center_ID in (Select costid from #Tempcostid)
			--select * from #Tempcostamt
			--SELECT * FROM #TEMPCOSTAMT

			--select * from #tempCostAndId12 T inner join #Tempcost TC on t.costId = TC.costId 

			--	SELECT * FROM #TEMPCOSTID C 
			--INNER JOIN  #TEMPCOSTAMT A ON C.CMP_ID = A.CMP_ID WHERE C.COSTID > 0 AND COSTAMT > 0

			--Insert into #TempOnlycost
			--Select cmp_id,isnull(cost_name,'') as cost_name,0 from #Tempcost where cost_name <> ''
			--union 
			--select cmp_id,'',costamt from #Tempcostamt where costamt <> 0

		

			Insert into #Tempfinaldetails
			select  @costslabid,effective_date,band_name,busi_segment,t.cost_name,cost_slab_name,co.costAmt
			from #Tempdetails td 
			left outer join #Tempband tb on tb.cmp_id = td.Cmp_id
			left outer join #Tempbusi tbu on tbu.cmp_id = td.Cmp_id
			left outer join #TempOnlycost tc on tc.cmp_id = td.Cmp_id 
			--left outer join #Tempcostper tcp on tcp.cmp_id = td.Cmp_id 
			left outer join #tempCostAndId12 co on co.cmp_id = td.Cmp_id
			left outer join #Tempcost T on t.costId = co.costId 
			where td.Cmp_id = @Cmp_ID	and cost_slab_id = @costslabid 
			--and costamt <> 0

			drop table #Tempbandid
			drop table #Tempband
			drop table #Tempbusiid
			drop table #Tempbusi
			drop table #Tempcostid
			drop table #Tempcostamt
			drop table #Tempcost
			drop table #TempOnlycost
			drop table #tempCostAndId12
		end
		--Insert into #Tempcostper
		--select @Cmp_ID,cast(data  as numeric) from dbo.Split (@cost_center_percentage,',')

		 Insert into #tempdata
		 select effective_date,slabid,cost_slab_name,tbl.BandId,tf.bandid,tbs.Segment_ID,business_segment1 as Business_Segment,cc.Center_ID,cost_center_id as Cost_Center_Name,cost_center_percentage 
		 from #Tempfinaldetails tf
		 left outer join tblBandMaster tbl on tbl.BandName = tf.bandid
		 left outer join T0040_Business_Segment tbs on tbs.Segment_Name = tf.business_segment1
		 left outer join T0040_COST_CENTER_MASTER cc on cc.Center_Name = tf.cost_center_id

		 select SUM(Cost_Amount) as CostAmt,BandId,Segment_ID,Center_ID,effective_date into #tmp13
		 from #tempdata 
		 group by BandId,Segment_ID,Center_ID,effective_date
	
		Insert into #Increment
		SELECT Cmp_ID,E.Emp_ID,Increment_ID,Basic_Salary,Band_Id,Segment_ID,Center_ID		FROM   t0080_emp_master E 		INNER JOIN (SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,I.Center_ID						FROM   t0095_increment I 
						INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 						FROM   t0095_increment 						WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID 						GROUP  BY emp_id) Qry 						ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date		)Q_I 		ON E.emp_id = Q_I.emp_id 
		

		 --select Account,Narration from T9999_Ax_Mapping 
		 --where Cmp_id = @Cmp_ID 
		 --union

		 --select  distinct Account as Account_Key,Narration as Account_Name,'' as Narration,isnull(Cast(CostAmt as varchar),'') as Dr,'' as Cr 
		 --from T9999_Ax_Mapping ax Left Outer join #tempdata td on td.BandId = ax.Band_ID and td.Segment_ID = ax.Segment_ID and td.Center_ID = ax.Center_ID
		 --left Outer join #tmp13 t3 on td.BandId = t3.BandID and td.Segment_ID = t3.Segment_ID and td.Center_ID = t3.Center_ID
		 --where Cmp_id = @Cmp_ID 

		 --select  distinct Account as Account_Key,Narration as Account_Name,'' as Narration,Cast((I.Basic_Salary/100 * CostAmt) as decimal(10,2)) as Dr,0 as Cr
		 --from T9999_Ax_Mapping ax Left Outer join #tempdata td on td.BandId = ax.Band_ID and td.Segment_ID = ax.Segment_ID and td.Center_ID = ax.Center_ID
		 --left Outer join #tmp13 t3 on td.BandId = t3.BandID and td.Segment_ID = t3.Segment_ID and td.Center_ID = t3.Center_ID
		 --left Outer join #Increment I on td.BandId = I.Band_Id and td.Segment_ID = I.Segment_ID and td.Center_ID = I.Center_ID
		 --where ax.Cmp_id = @Cmp_ID 

		 --Select * from #Increment Where Band_id is not null and Segment_id is not null
		 --Select Sum(Basic_Salary) as Basic_Sal,Band_id,Segment_id From #Increment where Band_id in (44) and Segment_id = 192 group by Band_id,Segment_id


		 --Select * from #tmp13 where BandId = 44 and Segment_ID = 192
		 --
		 --Select Cast((Sum(Basic_Salary)/100 * Costamt) as decimal(10,2)) as Calculation,Tm.Center_id into #tmp14
		 --from #tmp13 tm inner join #Increment I on I.Band_Id = TM.Bandid and I.Segment_ID = Tm.Segment_id
		 --where Tm.BandId = 44 and Tm.Segment_ID = 192 and Cmp_id = 185
		 --group by Tm.Center_id,Costamt
		 --
		 --select * from #tmp14
		 --select * Into tempdata_deepu from #tempdata
		 --select * Into tempdata from #tmp13

		 CREATE TABLE #FORMATJV (
			Account_Key VARCHAR(500),
			Account_Name VARCHAR(500),
			Narration VARCHAR(500),
			DR DECIMAL(10,2),
			CR DECIMAL(10,2),
			Sorting_number numeric
		 )


		Declare @Count1 as numeric = 1,@CountAx as numeric = 0,@AxName Varchar(500) = ''
		--Select @CountAx = Count(Tran_Id) from T9999_Ax_Mapping where Cmp_id = @Cmp_ID
		
		--while @Count1 <= @CountAx
		--begin
				
				if exists(Select tran_id from T9999_Ax_Mapping where Cmp_id = @Cmp_ID and Head_Name = 'Basic Salary')
					begin
						--Select @AxName = Narration from T9999_Ax_Mapping where Cmp_id = @Cmp_ID and Head_Name = 'Basic Salary'
						--Delete from #FORMATJV where Account_Key = @AxName
						 INSERT INTO #FORMATJV
						 SELECT Account,Narration as Account_key,'' as Narration,DR,CR,Sorting_no FROM (
						SELECT  Distinct Q_I.Band_Id,Q_I.Segment_ID
						,Account,Narration,Sorting_no,sum(Q_I.Basic_Salary) as Total,Center_Name,cost_amount,cast(round(((sum(Q_I.Basic_Salary)*cost_amount) / 100),0) as decimal) as DR,Null as CR
						FROM   
						t0080_emp_master E 
						INNER JOIN (SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,I.Center_ID,I.Segment_ID,I.Band_Id,i.Increment_ID,I.Basic_Salary
						                                FROM   t0095_increment I 
						                                INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
						                                FROM   t0095_increment 
						                                WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
						                                GROUP  BY emp_id) Qry 
						                                ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
						)Q_I ON E.emp_id = Q_I.emp_id and isnull(Q_I.Band_id ,0) <> 0 and isnull(Q_I.Segment_ID ,0) <> 0
						inner join T9999_Ax_Mapping A on A.Segment_ID = Q_I.Segment_ID and A.Band_ID = Q_I.Band_ID 
						inner join T0200_MONTHLY_SALARY M on m.Emp_ID = Q_I.Emp_ID and m.Increment_ID = Q_I.Increment_ID
						--inner join T0210_MONTHLY_AD_DETAIL AD on M.Sal_Tran_ID = AD.Sal_Tran_ID 
						--inner join T0050_AD_MASTER AM on AM.AD_ID = AD.AD_ID and A.Head_Name = Am.AD_NAME
						inner join #tempdata TD on TD.Segment_ID = Q_I.Segment_ID and TD.BandId = Q_I.Band_ID and A.Narration like CONCAT('%', TD.Center_Name, '%') 
						where M.Cmp_ID = @Cmp_ID
						and Month_St_Date >= @FROM_DATE and Month_End_Date <= @TO_DATE 
						and Head_Name = 'Basic Salary'
						group by Q_I.Band_Id,Q_I.Segment_ID,Account,Narration,Sorting_no,Center_Name,cost_amount) as B

					end

					if exists(Select tran_id from T9999_Ax_Mapping where Cmp_id = @Cmp_ID and Head_Name = 'Professional Tax')
					begin
						
						--Select @AxName = Narration from T9999_Ax_Mapping where Cmp_id = @Cmp_ID and Head_Name = 'Professional Tax'
						--Delete from #FORMATJV where Account_Key = @AxName
						INSERT INTO #FORMATJV
						SELECT Account,Narration as Account_key,'' as Narration,DR,CR,Sorting_no FROM (
						SELECT  Distinct Q_I.Band_Id,Q_I.Segment_ID
						,Account,Narration,Sorting_no
						,sum(M.PT_Amount) as Total,Center_Name,cost_amount,Null as DR,cast(round(((sum(M.PT_Amount)*cost_amount) / 100),0) as decimal) as CR
						FROM   
						t0080_emp_master E 
						INNER JOIN (SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,I.Center_ID,I.Segment_ID,I.Band_Id,i.Increment_ID,I.Basic_Salary
						                                FROM   t0095_increment I 
						                                INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
						                                FROM   t0095_increment 
						                                WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
						                                GROUP  BY emp_id) Qry 
						                                ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
						)Q_I ON E.emp_id = Q_I.emp_id and isnull(Q_I.Band_id ,0) <> 0 and isnull(Q_I.Segment_ID ,0) <> 0
						inner join T9999_Ax_Mapping A on A.Segment_ID = Q_I.Segment_ID and A.Band_ID = Q_I.Band_ID 
						inner join T0200_MONTHLY_SALARY M on m.Emp_ID = Q_I.Emp_ID and m.Increment_ID = Q_I.Increment_ID
						inner join #tempdata TD on TD.Segment_ID = Q_I.Segment_ID and TD.BandId = Q_I.Band_ID and A.Narration like CONCAT('%', TD.Center_Name, '%') 
						where M.Cmp_ID = @Cmp_ID
						and Month_St_Date >= @FROM_DATE and Month_End_Date <= @TO_DATE 
						and Head_Name = 'Professional Tax'
						and M.PT_Amount = (Select Max(Pt_Amount) from T0200_MONTHLY_SALARY Ms where Ms.emp_id = Q_I.Emp_ID group by Emp_ID)
						group by Q_I.Band_Id,Q_I.Segment_ID,Account,Narration,Sorting_no,Center_Name,cost_amount) as A
						order by Sorting_no
					end

					if exists(Select tran_id from T9999_Ax_Mapping where Cmp_id = @Cmp_ID and Head_Name = 'Net Salary')
					begin
						--Select @AxName = Narration from T9999_Ax_Mapping where Cmp_id = @Cmp_ID and Head_Name = 'Net Salary'
						--Delete from #FORMATJV where Account_Key = @AxName
						INSERT INTO #FORMATJV
						SELECT Account,Narration as Account_key,'' as Narration,DR,CR,Sorting_no FROM (
						SELECT  Distinct Q_I.Band_Id,Q_I.Segment_ID
						,Account,Narration,Sorting_no
						,sum(M.Net_Amount) as Total,Center_Name,cost_amount,Null as DR,cast(round(((sum(M.Net_Amount)*cost_amount) / 100),0) as decimal) as CR
						FROM   
						t0080_emp_master E 
						INNER JOIN (SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,I.Center_ID,I.Segment_ID,I.Band_Id,i.Increment_ID,I.Basic_Salary
						                                FROM   t0095_increment I 
						                                INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
						                                FROM   t0095_increment 
						                                WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
						                                GROUP  BY emp_id) Qry 
						                                ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
						)Q_I ON E.emp_id = Q_I.emp_id and isnull(Q_I.Band_id ,0) <> 0 and isnull(Q_I.Segment_ID ,0) <> 0
						inner join T9999_Ax_Mapping A on A.Segment_ID = Q_I.Segment_ID and A.Band_ID = Q_I.Band_ID 
						inner join T0200_MONTHLY_SALARY M on m.Emp_ID = Q_I.Emp_ID and m.Increment_ID = Q_I.Increment_ID
						inner join #tempdata TD on TD.Segment_ID = Q_I.Segment_ID and TD.BandId = Q_I.Band_ID and A.Narration like CONCAT('%', TD.Center_Name, '%') 
						where M.Cmp_ID = @Cmp_ID
						and Month_St_Date >= @FROM_DATE and Month_End_Date <= @TO_DATE 
						and Head_Name = 'Net Salary'
						and M.Net_Amount = (Select Max(Net_Amount) from T0200_MONTHLY_SALARY Ms where Ms.emp_id = Q_I.Emp_ID group by Emp_ID)
						group by Q_I.Band_Id,Q_I.Segment_ID,Account,Narration,Sorting_no,Center_Name,cost_amount) as A
						order by Sorting_no
					end
					--Set @Count1 = @Count1 + 1
		--end

		 INSERT INTO #FORMATJV
		 SELECT Account,Narration as Account_key,'' as Narration,DR,CR,Sorting_no FROM (
		SELECT  Distinct Q_I.Band_Id,Q_I.Segment_ID
		,Account,Narration,Sorting_no,sum(M_AD_Amount) as Total,Center_Name,cost_amount,
		case when ad.M_AD_Flag = 'I' then 
		cast(round(((sum(M_AD_Amount)*cost_amount) / 100),0) as decimal) End as DR,
		case when ad.M_AD_Flag = 'D' then 
		cast(round(((sum(M_AD_Amount)*cost_amount) / 100),0) as decimal) End as CR
		FROM   
		t0080_emp_master E 
		INNER JOIN (SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,I.Center_ID,I.Segment_ID,I.Band_Id,i.Increment_ID
		                                FROM   t0095_increment I 
		                                INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
		                                FROM   t0095_increment 
		                                WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
		                                GROUP  BY emp_id) Qry 
		                                ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
		)Q_I ON E.emp_id = Q_I.emp_id and isnull(Q_I.Band_id ,0) <> 0 and isnull(Q_I.Segment_ID ,0) <> 0
		inner join T9999_Ax_Mapping A on A.Segment_ID = Q_I.Segment_ID and A.Band_ID = Q_I.Band_ID 
		inner join T0200_MONTHLY_SALARY M on m.Emp_ID = Q_I.Emp_ID and m.Increment_ID = Q_I.Increment_ID
		inner join T0210_MONTHLY_AD_DETAIL AD on M.Sal_Tran_ID = AD.Sal_Tran_ID 
		inner join T0050_AD_MASTER AM on AM.AD_ID = AD.AD_ID and A.Head_Name = Am.AD_NAME
		inner join #tempdata TD on TD.Segment_ID = Q_I.Segment_ID and TD.BandId = Q_I.Band_ID and A.Narration like CONCAT('%', TD.Center_Name, '%') 
		where M.Cmp_ID = @Cmp_ID
		and Month_St_Date >= @FROM_DATE and Month_End_Date <= @TO_DATE
		group by Q_I.Band_Id,Q_I.Segment_ID,Account,Narration,Sorting_no,Center_Name,cost_amount,M_AD_Flag
		) AS JV
		order by Sorting_no

		select Account_Key,Account_Name,Narration,DR,CR from #FORMATJV order by Sorting_number


	DROP TABLE #FORMATJV	 
	drop table #Tempdetails
	--drop table #Tempbandid
	--drop table #Tempband
	drop table #Tempcostper
	drop table #Tempfinaldetails
	drop table #Tempslabid
	drop table #tempdata
	drop table #Increment
End
