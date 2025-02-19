
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_REGISTER_FORMAT2]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric	
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	--,@Leave_ID		Numeric
	,@Constraint	varchar(MAX)
	
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


	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID in (select emp_Id from
					(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
					where Cmp_ID = @Cmp_ID   and  
					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					or ( @From_Date <= join_Date  and @To_Date >= left_date )	
					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					or left_date is null and  @To_Date >= Join_Date)) 
		end	

		CREATE table #LEAVE_DETAILS
		(
			--Leave_id numeric(18,0),
			Cmp_ID numeric,
			from_Date VARCHAR(50),
			to_date VARCHAR(50),
			Emp_ID numeric(18,0),
			Leave_ID numeric(18,0),
			Leave_Name varchar(100),
			Leave_Opening numeric(18,2),
			Leave_Credit numeric(18,2),
			Leave_Closing numeric(18,2),
			Leave_CF numeric(18,2),
			Emp_Name varchar(100),
			Emp_Code varchar(100),
			Cmp_Name varchar(200),
			DOJ datetime,
			Branch_Name varchar(100),
			Desig_Name varchar(100),
			Cmp_Address varchar(500),
			Resig_Date datetime,
			Notice_period numeric(18,0),
			Left_Date datetime,
			Sort_No int,
			Grd_Name varchar(100),
			Father_Name varchar(100),
			Branch_ID numeric(18,0),
			Branch_Address varchar(250),
			Comp_Name varchar(250)
			--Leave_Name varchar(100)
		)
		
		
		
		insert into #LEAVE_DETAILS 
		select distinct LD.Cmp_ID,convert(varchar(15),@From_Date,103),convert(varchar(15),@To_Date,103),ec.Emp_ID,LD.Leave_ID,replace(Lm.Leave_Name,' ','_'),0,0,0,0,
		em.Emp_Full_Name,em.Alpha_Emp_code,cm.Cmp_Name,em.Date_Of_Join,		
		bm.Branch_Name,dm.Desig_Name,cm.Cmp_Address,le.Reg_Date,le.Notice_Period,le.Left_Date,lm.Leave_Sorting_No
		,grd.Grd_Name,em.Father_name,BM.Branch_ID
		,BM.Branch_Address,Bm.Comp_Name
		 from T0050_LEAVE_DETAIL LD WITH (NOLOCK) inner join T0040_Leave_Master lm WITH (NOLOCK) on LM.Leave_ID =LD.Leave_ID
			inner join t0080_Emp_Master em WITH (NOLOCK) on em.grd_ID=LD.grd_ID
			inner join @Emp_Cons ec on ec.Emp_ID =em.Emp_ID
			inner join
			 ( select I.Emp_Id,I.Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Cmp_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on IQ.Emp_ID=ec.Emp_ID
			left join T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.Cmp_Id=IQ.Cmp_ID
			left join T0030_BRANCH_MASTER bm WITH (NOLOCK) on bm.Branch_ID=iq.Branch_ID
			left join T0040_DESIGNATION_MASTER dm WITH (NOLOCK) on dm.Desig_ID=iq.Desig_Id
			left join T0100_LEFT_EMP le WITH (NOLOCK) on le.Emp_ID=em.emp_ID
			Left join T0040_GRADE_MASTER grd WITH (NOLOCK) on Grd.Grd_ID=IQ.Grd_ID
			inner join (select Leave_ID, Cmp_ID,Emp_ID,For_Date from T0140_LEAVE_TRANSACTION WITH (NOLOCK)) LT   ON LT.Emp_ID=Ec.Emp_ID AND LT.Cmp_ID=LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID 
			where LD.Cmp_ID=@cmp_ID and lm.Display_leave_balance=1 AND (LT.For_Date Between @From_Date AND @To_Date)
			order by lm.Leave_Sorting_No
					
					
		
		declare @leave_name as varchar(100)
		declare @leave_ID as numeric(18,0)
		declare @lv_id as numeric(18,0)
		Declare @Query nvarchar(200)
		Declare @SetVal nvarchar(200)
		declare @Emp_l_ID as numeric
		
			Declare curLeaveName cursor for			
			
			select lm.Emp_ID,lm.Leave_ID from #LEAVE_DETAILS lm  
				open curLeaveName  
					fetch next from curLeaveName into @Emp_l_ID, @lv_id
						while @@fetch_status = 0  
							begin  
								declare @LeaveName as varchar(100)								
								declare @Leave_opening as numeric(18,2)	
								declare @Leave_credit as numeric(18,2)	
								declare @Leave_closing as numeric(18,2)	
								declare @Ttl_CF_Leave as numeric(18,2)								
								Set @Emp_l_ID = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Emp_l_ID)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')	
								Set @lv_id = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@lv_id)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')									
								
									select  @Leave_opening=isnull(LT.Leave_Opening,0),
											@Leave_credit=isnull(LT.Leave_Credit,0)
											from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
												inner join #LEAVE_DETAILS ld on lt.Leave_ID=ld.Leave_ID and lt.Emp_ID =ld.Emp_ID 
												where lt.For_Date <= @From_Date and lt.Emp_ID=@Emp_l_ID and lt.Leave_ID=@lv_id 
												and for_date=(select MAX(For_Date) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)
												where Cmp_ID=@Cmp_ID and Leave_ID=@lv_id and Emp_ID=@Emp_l_ID 
												and For_Date<=@From_Date)
									select @Leave_closing=isnull(LT.Leave_Closing,0) 	
											from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
												inner join #LEAVE_DETAILS ld on lt.Leave_ID=ld.Leave_ID and lt.Emp_ID =ld.Emp_ID 
												where lt.For_Date <= @To_Date and lt.Emp_ID=@Emp_l_ID and lt.Leave_ID=@lv_id 
												and for_date=(select MAX(For_Date) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)
												where Cmp_ID=@Cmp_ID and Leave_ID=@lv_id and Emp_ID=@Emp_l_ID 
												and For_Date<=@From_Date)		
												
												
									--select 	@Leave_closing,@Emp_l_ID		
									select @Ttl_CF_Leave=Sum(isnull(LT.Leave_Credit,0)) 
											from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join #LEAVE_DETAILS ld on lt.Leave_ID=ld.Leave_ID 
											and lt.Emp_ID =ld.Emp_ID where lt.For_Date between @From_Date and @to_date and lt.Emp_ID=@Emp_l_ID and lt.Leave_ID=@lv_id --and for_date=(select MAX(For_Date) from T0140_LEAVE_TRANSACTION where Cmp_ID=@Cmp_ID and Leave_ID=@lv_id and lt.Emp_ID=@Emp_l_ID and For_Date<@From_Date)
								
								
								--select @Leave_opening
								
								Set @SetVal = 'update #LEAVE_DETAILS set Leave_Opening=' + convert(nvarchar,isnull(@Leave_opening,0)) + ',Leave_Credit=' + convert(nvarchar,isnull(@Leave_credit,0)) + ',Leave_Closing='+ convert(nvarchar,isnull(@Leave_closing,0)) +',Leave_CF='+ convert(nvarchar,isnull(@Ttl_CF_Leave,0)) +' where #LEAVE_DETAILS.Leave_ID = ' + convert(nvarchar,@lv_id) +' and  #LEAVE_DETAILS.Emp_ID= ' + convert(nvarchar,@Emp_l_ID)
								
								exec (@SetVal)	
								Set @SetVal = ''
								
								set @Leave_opening=0
								set @Leave_credit=0
								set @Leave_closing=0
								set @Ttl_CF_Leave=0
							fetch next from curLeaveName into @Emp_l_ID, @lv_id
							End
				close curLeaveName  
				deallocate curLeaveName  
			
			set @leave_name=''
			
			
			
			Create table #Leave_Used
			(
				Row_ID		numeric identity (1,1),
				Leave_ID numeric(18,0),
				Month_Name numeric,
				Leave_used numeric(18,2),
				Emp_lv_ID numeric(18,0),
				Ttl_Leave numeric(18,2),
				Leave_frm_date datetime,
				Lv_to_date datetime,
				Sort_No int				
			)
			
			DECLARE @EmpID Numeric(18,0),
					@LeaveID Numeric(18,0),
					@LeaveUsed Numeric(18,2),
					@From_Dt varchar(50),
					@To_Dt varchar(50),
					@MnthName numeric(18,0);
					
			
			
			SELECT distinct  L.Cmp_ID,D.Leave_ID,L.Emp_ID,D.From_Date,D.To_Date,Leave_Period,LD.Leave_Sorting_No as Sort_No
				INTO #LEAVE_DTLS_USED
				from T0120_LEAVE_APPROVAL L WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL D WITH (NOLOCK) ON L.Cmp_ID=D.Cmp_ID AND L.Leave_Approval_ID=D.Leave_Approval_ID
				inner join T0040_LEAVE_MASTER LD WITH (NOLOCK) on LD.Leave_ID=D.Leave_ID --and LD.Leave_ID=D.Leave_ID
				
			where D.Cmp_ID=@Cmp_ID and L.Approval_Status='A' order by LD.Leave_Sorting_No
				
			--select 1,* From #LEAVE_DTLS_USED

			
			--declare curMonthLeave cursor Fast_Forward FOR
				--Select L.Emp_ID,L.Leave_ID,SUM(Leave_Period) As Leave_Used,d.From_Date,D.To_Date 
				--FROM	T0130_LEAVE_APPROVAL_DETAIL D INNER JOIN T0120_LEAVE_APPROVAL A ON D.Cmp_ID=A.Cmp_ID AND D.Leave_Approval_ID=A.Leave_Approval_ID
				--		INNER JOIN #LEAVE_DETAILS L ON A.Emp_ID=L.Emp_ID and a.Cmp_ID=l.Cmp_ID and D.Leave_ID=L.Leave_ID
				--Where D.From_Date >=@From_date AND D.From_Date <= @To_Date
				--and a.Approval_Status='A'
				--Group By L.Leave_ID, L.Emp_ID,D.From_date,D.To_Date
				--insert into #Leave_Used
		
				--INNER JOIN #LEAVE_DETAILS L ON T.Emp_ID=L.Emp_ID and T.Leave_ID=L.Leave_ID
				--Where T.From_Date >=@From_date AND T.From_Date <= @To_Date
				
			--	Select Distinct T.Leave_ID,month(T.From_Date),T.Leave_Used,T.Emp_ID,T.Leave_Used,T.From_Date,T.To_Date,T.Sort_No FROM 
			--		(
			--	Select LV.Cmp_ID,LV.Leave_ID,Lv.Emp_ID,LV.Leave_Period,LV.Sort_No,
			--		(
			--			case when MONTH(LV.From_Date) <> MONTH(T.For_Date) then	
			--				convert(datetime, '01' + right(convert(varchar(10), T.For_Date, 103), 8), 103)				
			--			else
			--				LV.From_Date
			--			end
			
			--		) As From_Date,
			--		(
			--		case when MONTH(LV.To_Date) <> MONTH(T.For_Date) then	
			--			dateadd(dd, (-1 * datepart(dd, dateadd(mm, 1, T.For_Date))), dateadd(mm, 1, T.For_Date))
			--		else
			--			LV.To_Date
			--		end
			--	) As To_Date,		
		
			--		(			
			--		( select SUM(Leave_Used) from T0140_LEAVE_TRANSACTION LT inner join @Emp_Cons Ec on EC.Emp_ID=LT.Emp_ID
			--		 where Cmp_ID=@Cmp_ID and For_Date 
			--			>= case when MONTH(LV.From_Date) <> MONTH(T.For_Date) then	
			--			convert(datetime, '01' + right(convert(varchar(10), T.For_Date, 103), 8), 103)
			--	else
			--		LV.From_Date
			--	end
			--		and For_Date <= case when MONTH(LV.To_Date) <> MONTH(T.For_Date) then	
			--		dateadd(dd, (-1 * datepart(dd, dateadd(mm, 1, T.For_Date))), dateadd(mm, 1, T.For_Date))
			--	else
			--		LV.To_Date
			--	end		and Cmp_ID=@Cmp_ID) 
			
			
			--	) As Leave_Used
		
			--	FROM T0140_LEAVE_TRANSACTION T INNER JOIN #LEAVE_DTLS_USED LV on LV.Cmp_ID=T.Cmp_ID and LV.Emp_ID=T.Emp_ID  AND LV.Leave_ID=T.Leave_ID AND( T.For_Date Between LV.From_Date AND LV.To_Date)
			--	where LV.Cmp_ID=@Cmp_ID
			--) T
			--	INNER JOIN #LEAVE_DETAILS L ON T.Emp_ID=L.Emp_ID and T.Leave_ID=L.Leave_ID
			--	Where T.From_Date >=@From_date AND T.From_Date <= @To_Date
			--	return
				
				
				--select * from #LEAVE_DTLS_USED where Emp_ID=14296
				--return
				insert into #Leave_Used
				Select Distinct T.Leave_ID,month(T.From_Date),T.Leave_Used,T.Emp_ID,T.Leave_Used,T.From_Date,T.To_Date,T.Sort_No FROM 
					(
				Select LV.Cmp_ID,LV.Leave_ID,Lv.Emp_ID,LV.Leave_Period,LV.Sort_No,
					(
						case when MONTH(LV.From_Date) <> MONTH(T.For_Date) then	
							convert(datetime, '01' + right(convert(varchar(10), T.For_Date, 103), 8), 103)				
						else
							LV.From_Date
						end
			
					) As From_Date,
					(
					case when MONTH(LV.To_Date) <> MONTH(T.For_Date) then	
						dateadd(dd, (-1 * datepart(dd, dateadd(mm, 1, T.For_Date))), dateadd(mm, 1, T.For_Date))
					else
						LV.To_Date
					end
				) As To_Date,		
		
					(			
					( select SUM(Leave_Used) from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join @Emp_Cons Ec on Ec.Emp_ID=LT.Emp_ID where --LT.Leave_Used>0 and 
					For_Date 
						>= case when MONTH(LV.From_Date) <> MONTH(T.For_Date) then	
						convert(datetime, '01' + right(convert(varchar(10), T.For_Date, 103), 8), 103)
				else
					LV.From_Date
				end
					and For_Date <= case when MONTH(LV.To_Date) <> MONTH(T.For_Date) then	
					dateadd(dd, (-1 * datepart(dd, dateadd(mm, 1, T.For_Date))), dateadd(mm, 1, T.For_Date))
				else
					LV.To_Date
				end		and Cmp_ID=@Cmp_ID) 
			
			
				) As Leave_Used
		
				FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK) INNER JOIN #LEAVE_DTLS_USED LV on LV.Cmp_ID=T.Cmp_ID and LV.Emp_ID=T.Emp_ID  AND LV.Leave_ID=T.Leave_ID AND( T.For_Date Between LV.From_Date AND LV.To_Date)
				where LV.Cmp_ID=@Cmp_ID --and T.Leave_Used>0
			) T
				INNER JOIN #LEAVE_DETAILS L ON T.Emp_ID=L.Emp_ID and T.Leave_ID=L.Leave_ID
				Where T.From_Date >=@From_date AND T.From_Date <= @To_Date
				
				
				--select 2,* from #Leave_Used
				--return
				
			--return
			--OPEN curMOnthLeave
			--FETCH NEXT FROM curMOnthLeave INTO @EmpID, @LeaveID, @LeaveUsed, @From_Dt, @To_Dt
			
			--WHILE @@FETCH_STATUS =0 
			--BEGIN
			--	--IF EXISTS(SELECT 1 FROM T0130_LEAVE_APPROVAL_DETAIL D INNER JOIN T0120_LEAVE_APPROVAL A ON D.Cmp_ID=A.Cmp_ID AND D.Leave_Approval_ID=A.Leave_Approval_ID
			--	--					INNER JOIN #LEAVE_DETAILS L ON A.Emp_ID=L.Emp_ID and a.Cmp_ID=l.Cmp_ID and D.Leave_ID=L.Leave_ID
			--	--			  WHERE YEAR(D.From_Date)=YEAR(@From_Dt) AND MONTH(D.From_Date)=MONTH(@From_Dt))
			--	--BEGIN
			--		Insert Into #Leave_Used
			--		Select Distinct T2.Leave_ID,Month(@FRom_Dt),0,T1.EMP_ID,0,@From_Dt,@To_Dt,Sort_No--@From_Date,@To_Date
			--		FROM (SELECT EMP_ID FROM #LEAVE_DETAILS) T1,(SELECT Leave_ID,Sort_No FROM #LEAVE_DETAILS) T2
			--		Order By Emp_ID
					
			--		UPDATE #Leave_Used
			--		SET		Leave_used = T.Leave_Used
			--		From	(Select L.Emp_ID,L.Leave_ID,SUM(Leave_Period) As Leave_Used,d.From_Date,D.To_Date--,L.Sort_No 
			--				FROM	T0130_LEAVE_APPROVAL_DETAIL D INNER JOIN T0120_LEAVE_APPROVAL A ON D.Cmp_ID=A.Cmp_ID AND D.Leave_Approval_ID=A.Leave_Approval_ID
			--						INNER JOIN #LEAVE_DETAILS L ON A.Emp_ID=L.Emp_ID and a.Cmp_ID=l.Cmp_ID and D.Leave_ID=L.Leave_ID
			--				Where D.From_Date >=@From_date AND D.From_Date <= @To_Date
			--				and a.Approval_Status='A'
			--				 Group By L.Leave_ID, L.Emp_ID,D.From_date,D.To_Date) T
			--		Where	T.Emp_ID=#Leave_Used.Emp_lv_ID AND T.Leave_ID=#Leave_Used.Leave_ID 
			--				AND #Leave_Used.Leave_frm_date=T.From_Date AND #Leave_Used.Leave_frm_date=@From_Dt 
			--				--order by T.Sort_No asc
							
					
			--	--END
			--	FETCH NEXT FROM curMOnthLeave INTO @EmpID, @LeaveID, @LeaveUsed, @From_Dt, @To_Dt
			--END
			
			--CLOSE curMOnthLeave;
			--DEALLOCATE curMOnthLeave;
			--select * from #LEAVE_DETAILS
			--return
			--select * from #LEAVE_DETAILS
			--return
			--declare curMonthLeave cursor Fast_Forward FOR
			--	select distinct Leave_ID,from_date,Emp_ID,To_Date from #LEAVE_DTLS_USED				
			--	OPEN curMOnthLeave
			--		FETCH NEXT FROM curMOnthLeave INTO @LeaveID,@FRom_Dt,@Emp_ID ,@To_Dt--, @LeaveUsed, @From_Dt, @To_Dt			
			--			WHILE @@FETCH_STATUS =0 
			--			BEGIN
						
			--				IF EXISTS(SELECT 1 FROM T0130_LEAVE_APPROVAL_DETAIL D INNER JOIN T0120_LEAVE_APPROVAL A ON D.Cmp_ID=A.Cmp_ID AND D.Leave_Approval_ID=A.Leave_Approval_ID
			--					INNER JOIN #LEAVE_DETAILS L ON A.Emp_ID=L.Emp_ID and a.Cmp_ID=l.Cmp_ID and D.Leave_ID=L.Leave_ID
			--				  WHERE YEAR(D.From_Date)=YEAR(@From_Dt) AND MONTH(D.From_Date)=MONTH(@From_Dt))
			--					Begin								
								
			--						Insert Into #Leave_Used
			--						Select Distinct T2.Leave_ID,Month(@FRom_Dt),0,T1.EMP_ID,0,@From_Dt,@To_Dt,0--@From_Date,@To_Date
			--						FROM (SELECT EMP_ID FROM #LEAVE_DETAILS) T1,(SELECT Leave_ID,Sort_No FROM #LEAVE_DETAILS) T2
			--						Order By Emp_ID							
			--					End
			--			FETCH NEXT FROM curMOnthLeave INTO @LeaveID,@FRom_Dt,@Emp_ID ,@To_Dt	
			--			END
					
			--	--END					
			--CLOSE curMonthLeave;
			--DEALLOCATE curMOnthLeave;
			
			
			
			Delete #Leave_Used 
			FROM  (Select Leave_frm_date,Emp_lv_ID 
					FROM #Leave_Used L
					Group By Leave_frm_date,Emp_lv_ID
					Having SUM(L.Leave_used) = 0) T
			Where	#Leave_Used.Leave_frm_date=T.Leave_frm_date AND #Leave_Used.Emp_lv_ID=T.Emp_lv_ID
			
			
			--return;
			
			/*
			declare @tempdate datetime;
			
			set @tempdate = @From_Date;
			while @tempdate <= @To_Date
				begin									
				
					/*
					if month(@tempdate)= 5 and  year(@tempdate)= 2014
					begin
						--select * from #LEAVE_DETAILS
						--SELECT
						--T.Leave_Used,
						--t.From_Date,
						--t.To_Date
						--From	(Select L.Emp_ID,L.Leave_ID,SUM(Leave_Period) As Leave_Used,d.From_Date,D.To_Date 
						--		FROM	T0130_LEAVE_APPROVAL_DETAIL D INNER JOIN T0120_LEAVE_APPROVAL A ON D.Cmp_ID=A.Cmp_ID AND D.Leave_Approval_ID=A.Leave_Approval_ID
						--				INNER JOIN #LEAVE_DETAILS L ON A.Emp_ID=L.Emp_ID and a.Cmp_ID=l.Cmp_ID and D.Leave_ID=L.Leave_ID
						--		Where MONTH(D.From_Date) = month(@tempdate)  AND Year(D.From_Date)=YEAR(@tempdate)and D.From_Date >=@From_date AND D.From_Date <= @To_Date
						--		and a.Approval_Status='A'
						--		Group By L.Leave_ID, L.Emp_ID,D.From_date,D.To_Date) T
						--where Month(T.From_Date)= 5 AND Year(T.From_Date)= 2014
					end
					*/
					
					if EXISTS(SELECT 1 FROM T0130_LEAVE_APPROVAL_DETAIL D INNER JOIN T0120_LEAVE_APPROVAL A ON D.Cmp_ID=A.Cmp_ID AND D.Leave_Approval_ID=A.Leave_Approval_ID
									INNER JOIN #LEAVE_DETAILS L ON A.Emp_ID=L.Emp_ID and a.Cmp_ID=l.Cmp_ID and D.Leave_ID=L.Leave_ID
							  WHERE YEAR(D.From_Date)=YEAR(@tempdate) AND MONTH(D.From_Date)=MONTH(@tempdate))
					BEGIN
						Insert Into #Leave_Used
						Select Distinct T2.Leave_ID,Month(@tempdate),0,T1.EMP_ID,0,@tempdate,@tempdate--@From_Date,@To_Date
						FROM (SELECT EMP_ID FROM #LEAVE_DETAILS) T1,(SELECT Leave_ID FROM #LEAVE_DETAILS) T2
						Order By Emp_ID
						
						
						UPDATE #Leave_Used
						SET		Leave_used = T.Leave_Used,--,Ttl_Leave=sum(T.Leave_Used)
						Leave_frm_date=t.From_Date,
						Lv_to_date=t.To_Date
						From	(Select L.Emp_ID,L.Leave_ID,SUM(Leave_Period) As Leave_Used,d.From_Date,D.To_Date 
								FROM	T0130_LEAVE_APPROVAL_DETAIL D INNER JOIN T0120_LEAVE_APPROVAL A ON D.Cmp_ID=A.Cmp_ID AND D.Leave_Approval_ID=A.Leave_Approval_ID
										INNER JOIN #LEAVE_DETAILS L ON A.Emp_ID=L.Emp_ID and a.Cmp_ID=l.Cmp_ID and D.Leave_ID=L.Leave_ID
								Where MONTH(D.From_Date) = month(@tempdate)  AND Year(D.From_Date)=YEAR(@tempdate)and D.From_Date >=@From_date AND D.From_Date <= @To_Date
								and a.Approval_Status='A'
								Group By L.Leave_ID, L.Emp_ID,D.From_date,D.To_Date) T
						Where	T.Emp_ID=#Leave_Used.Emp_lv_ID AND T.Leave_ID=#Leave_Used.Leave_ID AND #Leave_Used.Month_name=Month(@tempdate) AND Year(#Leave_Used.Leave_frm_date)=Year(@tempdate) AND T.From_Date <> '2014-05-20'
					END
										
					set @tempdate = DATEADD(MM,1, @tempdate);
				
				end

		
			*/
		
			
			/*
			Delete #Leave_Used 
			FROM  (Select Month_Name,Emp_lv_ID 
					FROM #Leave_Used L
					Group By Month_Name,Emp_lv_ID
					Having SUM(L.Leave_used) = 0) T
			Where	#Leave_Used.Month_Name=T.Month_Name AND #Leave_Used.Emp_lv_ID=T.Emp_lv_ID
			*/
		
			--declare @Ttl_Leave as numeric(18,2)
			
			--Delete from #Leave_Used Where Month_Name<> '4'
			--select * from #Leave_Used T	 Where Month_Name='4'
			
						
			DECLARE @Leave_Sort_No int;
			DECLARE @Leave_Total int;
			
			Select * INTO #TMP_LEAVE FROM #Leave_Used 
			
			
			
			declare curMonth Cursor FAST_FORWARD FOR  
			select Distinct Month_Name from #TMP_LEAVE  T	 
			OPEN curMonth
			FETCH NEXT FROM curMonth INTO @MnthName
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				
				declare curLeaveID Cursor FAST_FORWARD FOR 
				select Leave_ID,Sort_No,Sum(Ttl_Leave) As Ttl_Leave from #TMP_LEAVE  T	 GROUP BY Leave_ID,Sort_No
				OPEN curLeaveID
				FETCH NEXT FROM curLeaveID INTO @LeaveID,@Leave_Sort_No,@Leave_Total
				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					
					Insert Into #Leave_Used(Leave_ID, Month_Name, Leave_Used, Emp_lv_ID,Ttl_Leave,Leave_frm_date,Lv_to_date,Sort_No)
					Select @LeaveID, L.Month_Name, 0, L.Emp_lv_ID,@Leave_Total,L.Leave_frm_date,L.Lv_to_date,@Leave_Sort_No
					From  #TMP_LEAVE  L Left Outer Join #TMP_LEAVE E On L.Row_ID=E.Row_ID  AND E.Leave_ID=@LeaveID
					Where  L.Month_Name=@MnthName AND E.Row_ID IS NULL
					
					FETCH NEXT FROM curLeaveID INTO @LeaveID,@Leave_Sort_No,@Leave_Total
				END
				
				CLOSE curLeaveID;
				DEALLOCATE curLeaveID;
				
				FETCH NEXT FROM curMonth INTO @MnthName
			END
			
			CLOSE curMonth;
			DEALLOCATE curMonth;
			--select * from #LEAVE_DETAILS
			--return
			--select * from #Leave_Used where Leave_ID=446
			--return
			
			
			select *,Leave_Closing+Leave_CF as TotalLeave from #LEAVE_DETAILS D	Order by D.Cmp_ID,D.Emp_ID
			
			
			
			select * from #Leave_Used T Order by Leave_Frm_Date ,T.Sort_No,T.Leave_ID
			
			 --T.Emp_lv_ID, T.Leave_frm_date, T.Leave_ID
			
			--select Emp_lv_ID,U.Leave_ID,( Leave_Closing + Leave_CF - IsNull(U.Leave_used,0)) As Total_Leave, IsNull(U.Leave_used,0)  As Total_Leave_Used 
			--from #LEAVE_DETAILS D Inner Join 
			--		(Select U.Emp_lv_ID,U.Leave_ID,U.Sort_No,Sum(U.Leave_used) As Leave_used 
			--		FROM #Leave_Used U 
			--		Group By U.Emp_lv_ID,U.Leave_ID,U.Sort_No
			--		) U ON U.Emp_lv_ID=D.Emp_ID AND U.Leave_ID=D.Leave_ID					
			--Where D.Cmp_ID=@Cmp_ID
			
			--Order by U.Sort_No--U.Emp_lv_ID, U.Leave_ID
			
			
			select Emp_lv_ID,U.Leave_ID,( Leave_Closing + Leave_CF - IsNull(SUM(Leave_used),0)) As Total_Leave, IsNull(SUM(Leave_used),0)  As Total_Leave_Used 
			from #Leave_Used U Inner Join #LEAVE_DETAILS D ON U.Emp_lv_ID=D.Emp_ID AND U.Leave_ID=D.Leave_ID
			Where D.Cmp_ID=@Cmp_ID
			Group By Emp_lv_ID,U.Leave_ID,Leave_Closing,Leave_CF,U.Sort_No
			Order by U.Sort_No,U.Leave_ID--U.Emp_lv_ID, U.Leave_ID
			
			drop table #LEAVE_DETAILS
			drop table #Leave_Used
			drop table #LEAVE_DTLS_USED
			drop table #TMP_LEAVE
			
	
	RETURN 




