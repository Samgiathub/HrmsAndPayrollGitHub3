CREATE PROCEDURE [dbo].[SP_Home_Holiday_Detail] 
	@Cmp_ID numeric,
	@From_Date dateTime,
	@To_date dateTime,
	@Is_Holiday numeric(18,2),
	@Emp_ID numeric(18,0) = 0 ,
	@Branch_Id numeric = 0 ,
	@Upcoming_flag int = 0
	
AS
	declare @Startdate  as datetime =  NULL
	declare @Enddate  as datetime =  NULL
	set @Startdate = DATEADD(DAY,1,EOMONTH(@From_Date,-1))
	--set @Startdate = DATEADD(MONTH,-12,@From_Date) --for Stridely 29122021
	Set @Enddate = DATEADD(MONTH,24,@From_Date)
	
	--Added by Mihir 16102011
	IF @Branch_Id = 0
		set @Branch_Id = null
	--End Added by Mihir 16102011
	
	Declare @holiday table
	(
	   Holiday_Name varchar(100),--Changed by Falak on 16-MAY-2011
	   Holiday_From_date DateTime,
	   Holiday_To_date Datetime,
	   Branch_ID numeric(18,0),
	   Repeat varchar(10),
	   Id  numeric(18,0) Identity 
	)
	
	--Select @Branch_Id = branch_ID from T0080_EMP_MASTER where emp_id=@Emp_ID and cmp_id=@Cmp_ID
	--Commnetd and Added below by Sumit for getting New branch ID after increment 02032016
Select @Branch_Id = I.branch_ID from T0080_EMP_MASTER E WITH (NOLOCK) 
	inner join T0095_Increment I WITH (NOLOCK) on E.Emp_ID=I.Emp_ID inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) 
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
	 where E.Emp_ID=@Emp_ID and E.cmp_id=@Cmp_ID
	
	if @Is_Holiday =0 
	  BEGIN

			--select @Startdate,@Enddate
			--select @From_Date,@TO_DATE
	  
		 	-- all branch changes done by for mitesh on 10/01/2012		 		   
			Insert into @holiday(Holiday_Name,Holiday_From_date,Holiday_To_date,Branch_ID,Repeat)
			--select * from T0040_Holiday_Master where cmp_Id = 120 and isnull(Is_Optional,0) = 0 and H_From_Date>='2023-06-13' and H_To_Date<='2023-12-31'

			Select DISTINCT  Hday_Name,H_From_Date,H_To_Date,Branch_ID,Is_Fix
			   From T0040_Holiday_Master WITH (NOLOCK)  where isnull(Is_Optional,0) = 0 and 
			    H_From_Date>=@From_Date and H_To_Date<=@To_date + 31	-- Added by Divyaraj Kiri on 28/12/2023
				--H_From_Date>=@Startdate and H_To_Date<=@Enddate
				and Cmp_id=@Cmp_ID  
				and (isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0 ) -- Branch ID Condition Added by Mihir 16102011 
			 --  OR (Hday_ID IN (SELECT A.Hday_ID FROM T0120_Op_Holiday_Approval A WITH (NOLOCK)  Inner Join T0040_HOLIDAY_MASTER H  WITH (NOLOCK) on A.HDay_ID = h.Hday_ID 
				--WHERE A.CMP_id=@cMP_id AND A.Emp_ID=@eMP_id AND Op_Holiday_Apr_Status='A' AND
				--H_From_Date>=@From_Date and H_To_Date<=@To_date   --Commented by Hardik 22/03/2016 and added below condition.
				--))
				--H_From_Date>=@Startdate and H_To_Date<=@Enddate  Commented by Mr.Mehul on 13062023
				--(
				--(@FROM_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR 
				--(@TO_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR
				--(H_FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE) OR
				--(H_To_Date BETWEEN @FROM_DATE AND @TO_DATE) 	
				--)
				 
					    			    			 
			if  month(@From_Date)=month(@To_date)
				Begin
				
					Insert into @holiday(Holiday_Name,Holiday_From_date,Holiday_To_date,Branch_ID,Repeat)
					Select  Hday_Name,convert(varchar(11), dateadd(yy,(year(@From_Date) - year(H_From_Date) ),H_From_Date), 106),convert(varchar(11), dateadd(yy,(year(@to_date) - year(H_To_Date)),H_To_Date), 106),Branch_ID,Is_Fix 
				    From T0040_Holiday_Master WITH (NOLOCK)  where isnull(Is_Optional,0) = 0 and 
				    H_From_Date < @From_Date and H_To_Date < @To_date And Month(H_From_Date)= Month(@From_Date) And Month(H_To_Date)=Month(@To_date)and Cmp_id=@Cmp_ID and is_Fix='Y' 
				    and (isnull(Branch_ID,0) = isnull(@Branch_Id ,0)  or isnull(Branch_ID,0) = 0 )
				   OR (Hday_ID IN (SELECT A.Hday_ID FROM T0120_Op_Holiday_Approval A WITH (NOLOCK)  Inner Join T0040_HOLIDAY_MASTER H WITH (NOLOCK)  on A.HDay_ID = h.Hday_ID 
					WHERE A.CMP_id=@cMP_id AND A.Emp_ID=@eMP_id AND Op_Holiday_Apr_Status='A' AND
				--H_From_Date>=@From_Date and H_To_Date<=@To_date
				(
				(@FROM_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR 
				(@TO_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR
				(H_FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE) OR
				(H_To_Date BETWEEN @FROM_DATE AND @TO_DATE) 	
				)
				))

				    
				    
				    -- Branch ID Condition Added by Mihir 16102011
				    -- dateadd added by mitesh on 16/02/2012  for correcting year for holidays with repating checked
				    
				End
			else
				Begin
				
					Insert into @holiday(Holiday_Name,Holiday_From_date,Holiday_To_date,Branch_ID,Repeat)
					Select  Hday_Name,convert(varchar(11), dateadd(yy,(year(@From_Date) - year(H_From_Date) ),H_From_Date), 106),convert(varchar(11), dateadd(yy,(year(@to_date) - year(H_To_Date)),H_To_Date), 106),
					Branch_ID,Is_Fix
				    From T0040_Holiday_Master WITH (NOLOCK)  where isnull(Is_Optional,0) = 0 and 
				    --H_From_Date < @From_Date and H_To_Date < @To_date 
					Cmp_id=@Cmp_ID and is_Fix='Y' and
					H_From_Date>=@From_Date and H_To_Date<=@To_date
				    and (isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0))   or isnull(Branch_ID,0) = 0 ) 
			--	   OR (Hday_ID IN (SELECT A.Hday_ID FROM T0120_Op_Holiday_Approval A WITH (NOLOCK)  Inner Join T0040_HOLIDAY_MASTER H WITH (NOLOCK)  on A.HDay_ID = h.Hday_ID 
			--		WHERE A.CMP_id=@cMP_id AND A.Emp_ID=@eMP_id AND Op_Holiday_Apr_Status='A' AND
			--	--H_From_Date>=@From_Date and H_To_Date<=@To_date
			--	(
			--	(@FROM_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR 
			--	(@TO_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR
			--	(H_FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE) OR
			--	(H_To_Date BETWEEN @FROM_DATE AND @TO_DATE) 	
			--	)
			--	))
					-- dateadd added by mitesh on 16/02/2012 for correcting year for holidays with repating checked
				END
			   			 
	  END
	  else if @Is_Holiday =1
	   Begin	   
			Insert into @holiday(Holiday_Name,Holiday_From_date,Holiday_To_date,Branch_ID,Repeat)
			
			 Select  Hday_Name,convert(varchar(11), H_From_Date, 106),convert(varchar(11), H_To_Date, 106),Branch_ID,Is_Fix
			 From T0040_Holiday_Master WITH (NOLOCK)  where isnull(Is_Optional,0) = 0 and
			 H_From_Date>=@From_Date and H_To_Date<=@To_date and Cmp_id=@Cmp_ID  
		   OR (Hday_ID IN (SELECT A.Hday_ID FROM T0120_Op_Holiday_Approval A WITH (NOLOCK)  Inner Join T0040_HOLIDAY_MASTER H WITH (NOLOCK)  on A.HDay_ID = h.Hday_ID 
			WHERE A.CMP_id=@cMP_id AND A.Emp_ID=@eMP_id AND Op_Holiday_Apr_Status='A' AND
				--H_From_Date>=@From_Date and H_To_Date<=@To_date
				(
				(@FROM_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR 
				(@TO_DATE BETWEEN H_FROM_DATE AND H_To_Date) OR
				(H_FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE) OR
				(H_To_Date BETWEEN @FROM_DATE AND @TO_DATE) 	
				)
				))

	   End
		  	 
		--	 select * from @holiday

		--select * from @holiday
		--where id in(
		--	SELECT MAX(ID)
		--	FROM @holiday
		--	GROUP BY Holiday_From_date)

	   -- delete t1 FROM @holiday t1
		--INNER  JOIN @holiday t2 on 
		--WHERE
		--	t1.id < t2.id AND
		--	--t1.day = t2.day AND
		--	t1.month = t2.month AND
		--	t1.year = t2.year;
		 
	 if @Upcoming_flag =0
	 begin
			 Select * from (Select DISTINCT 
			 Holiday_Name,DATENAME(DW,Holiday_From_date)+' '+convert(varchar(20), Holiday_From_date, 106) AS Holiday_From_date,DATENAME(DW,Holiday_To_date)+' '+convert(varchar(11), Holiday_To_date, 106) AS Holiday_To_date,isnull(Branch_Name,'All Branch') as Branch_Name,Repeat ,isnull(H.Branch_ID,0) as Branch_Id,Holiday_From_date as Holiday_From_date_ord ,Holiday_To_date as Holiday_To_date_ord
			 from @holiday H left outer join t0030_branch_master BM WITH (NOLOCK)  on H.Branch_ID=BM.Branch_ID
			 where H.id in(   SELECT MAX(ID)
							FROM @holiday
							GROUP BY Holiday_From_date)
			 
			 ) qry
			 order by Holiday_From_date_ord
	end
	else
	begin 
	   
		 Select * from (Select DISTINCT 
						Holiday_Name,DATENAME(DW,Holiday_From_date)+' '+convert(varchar(20), Holiday_From_date, 106) AS Holiday_From_date,DATENAME(DW,Holiday_To_date)+' '+convert(varchar(11), Holiday_To_date, 106) AS Holiday_To_date,isnull(Branch_Name,'All Branch') as Branch_Name,Repeat ,isnull(H.Branch_ID,0) as Branch_Id,Holiday_From_date as Holiday_From_date_ord ,Holiday_To_date as Holiday_To_date_ord
						from @holiday H left outer join t0030_branch_master BM WITH (NOLOCK)  on H.Branch_ID=BM.Branch_ID
						where (h.Holiday_To_date >= @Startdate and h.Holiday_To_date <= @Enddate) and
						H.id in(SELECT MAX(ID) FROM @holiday GROUP BY Holiday_From_date)
			 ) qry
			 
			 order by Holiday_From_date_ord
			  
	end
			
			 --order by Month(Holiday_From_date),Day(Holiday_From_date),Year(Holiday_From_date)
	RETURN
