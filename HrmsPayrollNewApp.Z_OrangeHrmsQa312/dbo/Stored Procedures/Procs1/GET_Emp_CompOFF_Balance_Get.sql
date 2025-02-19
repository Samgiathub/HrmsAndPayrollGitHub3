

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[GET_Emp_CompOFF_Balance_Get]
	@For_Date	datetime,
	@Emp_ID		numeric,
	@Cmp_ID		numeric,
	@leave_ID	numeric,
	@leave_Type	numeric
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	CREATE TABLE #Temp_Leave1
	(
		Temp_Trans				numeric,
		Cmp_ID					numeric,
		Emp_ID					numeric,
		For_Date				datetime,
		Leave_Opening			numeric(18,2),
		Leave_Credit			numeric(18,2),
		Leave_Used				numeric(18,2),
		Branch_ID				numeric,
		Is_CompOff				numeric,
		CompOff_Days_Limit		numeric
	)


	CREATE TABLE #Temp_Leave2
	(
		Temp_Trans				numeric,
		Cmp_ID					numeric,
		Emp_ID					numeric,
		For_Date				datetime,
		Leave_Opening			numeric(18,2),
		Leave_Credit			numeric(18,2),
		Leave_Used				numeric(18,2),
		Branch_ID				numeric,
		Is_CompOff				numeric,
		CompOff_Days_Limit		numeric,
		temp_USED				numeric(18,2) default 0,
		TEMP_Balance			numeric(18,2) default 0
	)
	
	
	
	declare @Get_WO_HO as table
	(
		Emp_ID	numeric,
		Cmp_ID	numeric,
		Branch_ID	numeric,
		Weekoff_Date	varchar(max),
		Holiday_Date	varchar(max),
		Weekoff_Count	numeric,
		Holiday_Count	numeric,
		Total_Weekoff_Date	varchar(max),
		Total_Weekoff_Count	numeric
	)
	
	declare @branch_id as numeric,
			@holiday_avail_limit as numeric,
			@weekoff_avail_limit as numeric,
			@wd_avail_limit as numeric,
			@from_date as datetime
	
	select @branch_id = ISNULL(branch_id,0) from T0095_INCREMENT WITH (NOLOCK)
	where Emp_ID = @Emp_ID and Increment_Id =   --Changed by Hardik 10/09/2014 for Same Date Increment
	(select MAX(Increment_Id) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @Emp_ID and Increment_Effective_Date<=@For_Date)
	
	select @wd_avail_limit = CompOff_Avail_Days,@holiday_avail_limit = H_CompOff_Avail_Days ,@weekoff_avail_limit = W_CompOff_Avail_Days from T0040_GENERAL_SETTING WITH (NOLOCK)
	--where Branch_ID = @branch_id    ''Modified by Ramiz on 15092014
	where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID)  
	
	if @wd_avail_limit <> 0 or @holiday_avail_limit <> 0 or @weekoff_avail_limit <> 0
	begin 
	
		SET @wd_avail_limit = CASE WHEN CASE WHEN ISNULL(@holiday_avail_limit, 0) = 0
										 THEN 365
										 ELSE @holiday_avail_limit
									END > CASE WHEN ISNULL(@weekoff_avail_limit,
														   0) = 0 THEN 365
											   ELSE @weekoff_avail_limit
										  END
							   THEN CASE WHEN CASE WHEN ISNULL(@wd_avail_limit,
															  0) = 0 THEN 365
												   ELSE @wd_avail_limit
											  END > CASE WHEN ISNULL(@holiday_avail_limit,
															  0) = 0 THEN 365
														 ELSE @holiday_avail_limit
													END
										 THEN CASE WHEN ISNULL(@wd_avail_limit,
															  0) = 0 THEN 365
												   ELSE @wd_avail_limit
											  END
										 ELSE CASE WHEN ISNULL(@holiday_avail_limit,
															  0) = 0 THEN 365
												   ELSE @holiday_avail_limit
											  END
									END
							   ELSE CASE WHEN ISNULL(@weekoff_avail_limit, 0) = 0
										 THEN 365
										 ELSE @weekoff_avail_limit
									END
						  END
		
	
		set @from_date = DATEADD(d,@wd_avail_limit * -1,@for_date)
	
		insert into @Get_WO_HO 
		EXEC [SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_NEW]
			@cmp_id = @cmp_id,@from_date = @from_date,@to_date = @For_Date ,@branch_id = 0,@Cat_ID = 0,@grd_id = 0,@Type_id = 0
			,@dept_ID = 0,@desig_ID = 0,@emp_id = @Emp_ID ,@constraint = '',@Report_For = 'WHO'

	
	
		INSERT INTO #Temp_Leave1
		SELECT    ROW_NUMBER() over (order by lt.For_Date asc) as Temp_Trans, lt.Cmp_ID, lt.Emp_ID, lt.For_Date, lt.Leave_Opening, lt.Leave_Credit, lt.Leave_Used,lt.Branch_ID,Is_CompOff, 
							  case when charindex(replace(convert(nvarchar(11),lt.For_Date,106),' ','-') ,who.Holiday_Date) > 0 
							  then case when isnull(H_CompOff_Avail_Days,0)=0 then 365 else H_CompOff_Avail_Days end else case when charindex(replace(convert(nvarchar(11),lt.For_Date,106),' ','-'),who.Weekoff_Date)>0 
							  then case when isnull(W_CompOff_Avail_Days,0)=0 then 365 else W_CompOff_Avail_Days end else 
							  case when isnull(CompOff_Avail_Days,0)=0 then 365 else CompOff_Avail_Days end end end as CompOff_Days_Limit
							  --,who.Holiday_Date ,who.Weekoff_Date ,charindex(replace(convert(nvarchar(11),lt.For_Date,106),' ','-'),who.Weekoff_Date)
		FROM         (SELECT     TOP (100) PERCENT Cmp_ID, Emp_ID, For_Date, Leave_Opening, Leave_Credit, Leave_Used, 
														  (SELECT     Shift_ID
															FROM          T0100_EMP_SHIFT_DETAIL AS sd WITH (NOLOCK)
															WHERE      (Emp_ID = lt.Emp_ID) AND (Cmp_ID = Cmp_ID) AND (For_Date =
																					   (SELECT     MAX(For_Date) AS Expr1
																						 FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
																						 WHERE      (Emp_ID = lt.Emp_ID) AND (Cmp_ID = lt.Cmp_ID) AND (For_Date <= lt.For_Date)))) AS Shift_ID,
														  (SELECT     Branch_ID
															FROM          T0095_INCREMENT AS sd WITH (NOLOCK)
															WHERE      (Emp_ID = lt.Emp_ID) AND (Cmp_ID = Cmp_ID) AND (Increment_Effective_Date =
																					   (SELECT     MAX(Increment_Effective_Date) AS Expr1
																						 FROM          T0095_INCREMENT WITH (NOLOCK)
																						 WHERE      (Emp_ID = lt.Emp_ID) AND (Cmp_ID = lt.Cmp_ID) AND (Increment_Effective_Date <= lt.For_Date)))) AS Branch_ID
							   FROM          T0140_LEAVE_TRANSACTION AS lt WITH (NOLOCK)
							   WHERE      (Leave_ID = @leave_ID) and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
							   ORDER BY For_Date) AS lt INNER JOIN
							  T0040_SHIFT_MASTER AS sm WITH (NOLOCK) ON lt.Shift_ID = sm.Shift_ID AND lt.Cmp_ID = sm.Cmp_ID
							  inner join T0040_GENERAL_SETTING as gs WITH (NOLOCK) on lt.Cmp_ID = gs.Cmp_ID and lt.Branch_ID = gs.Branch_ID and gs.For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Added By Ramiz on 15092014
							  left outer join @Get_WO_HO as who on lt.Cmp_ID = who.Cmp_ID and lt.Emp_ID = who.Emp_ID
		
		insert into #Temp_Leave2
		select *,0,0 from #Temp_Leave1
		WHERE     (Emp_ID = @Emp_ID) --AND (For_Date >= DATEADD(d, CompOff_Days_Limit * - 1, @For_Date))

		declare @date1 as datetime
		declare @temp_trans as numeric
		declare @leave_Credit as numeric(18,2)
		declare @leave_Used as numeric(18,2)
		declare @leave_Credit_Temp as numeric(18,2)
		declare @leave_Used_Temp as numeric(18,2)
		declare @date2 as datetime
		declare @CompOff_Days_Limit as numeric
		declare @temp_Balance as numeric(18,2)

		declare leaveCur cursor for
		select For_Date,Leave_Credit,Leave_Used,Compoff_Days_limit from #Temp_Leave2
		open leaveCur
			fetch next from leaveCur into @date1,@leave_Credit,@leave_Used,@Compoff_Days_limit
		while @@FETCH_STATUS = 0
		begin
			if @leave_Credit>0 and DATEADD(d,@CompOff_Days_Limit,@date1)>= @For_Date
			begin
				update #Temp_Leave2
				set temp_USED = 0,
					TEMP_Balance = @leave_Credit
				where For_Date = @date1
			end
			if @leave_Used > 0
			BEGIN
				Declare leave_temp cursor for
					select distinct temp_trans from #temp_leave2
					where for_date <=@date1
				open leave_temp
				fetch next from leave_temp into @temp_trans
				while @@fetch_status = 0
				begin
				
					select @date2 = for_date from #Temp_Leave2 where Temp_Trans = @temp_trans
				
					declare leave_temp1 cursor for
						select For_date,Leave_Credit,Leave_Used,CompOff_Days_Limit from #Temp_Leave2
						where temp_trans<=@temp_trans
					open leave_temp1
					fetch next from leave_temp1 into @date1,@leave_Credit,@leave_Used,@Compoff_Days_limit
					while @@FETCH_STATUS = 0
					begin
						if @leave_Credit>0 and DATEADD(d,@CompOff_Days_Limit,@date1)>= @For_Date
						begin
						
							update #Temp_Leave2
							set temp_USED = 0,
								TEMP_Balance = @leave_Credit
							where For_Date = @date1
						end
						if @leave_Credit <> 0
						begin
							select @temp_balance = TEMP_Balance from #temp_leave2
							where Temp_Trans = @temp_trans
							
							select @date2 = dateadd(d,compoff_days_limit,for_date) from #temp_leave2
							where Temp_Trans = @temp_trans
							
							if @date2>=@date1
							begin
								
								if @temp_balance >=@leave_used
								begin
									update #temp_leave2
									set Temp_Balance = @temp_Balance - @leave_used,
										temp_used = @leave_used
									where temp_trans = @temp_trans
								end
								else
								begin
									update #temp_leave2
									set Temp_Balance = 0,
										temp_used = @temp_balance
									where temp_trans = @temp_trans
									
									set @leave_used = @leave_used - @temp_Balance
								end
							end
						end
						fetch next from leave_temp1 into @date1,@leave_Credit,@leave_Used,@Compoff_Days_limit
					end
					close leave_temp1
					deallocate leave_temp1
					
					select @temp_balance = TEMP_Balance from #temp_leave2
					where Temp_Trans = @temp_trans
					
					select @date2 = dateadd(d,compoff_days_limit,for_date) from #temp_leave2
					where Temp_Trans = @temp_trans
				
					if @date2>=@date1
					begin
					
						if @temp_balance >=@leave_used
						begin
							update #temp_leave2
							set Temp_Balance = @temp_Balance - @leave_used,
								temp_used = @leave_used
							where temp_trans = @temp_trans
						end
						else
						begin
							update #temp_leave2
							set Temp_Balance = 0,
								temp_used = @temp_balance
							where temp_trans = @temp_trans
							
							set @leave_used = @leave_used - @temp_Balance
						end
					end
					fetch next from leave_temp into @temp_trans
				end
				close leave_temp
				deallocate leave_temp
			End
			fetch next from leaveCur into @date1,@leave_Credit,@leave_Used,@Compoff_Days_limit
		end
		close leaveCur
		deallocate leaveCur
		
		if @leave_Type = 3
		begin
			select temp_trans,Cmp_ID,Emp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Branch_ID,Is_CompOff,CompOff_Days_Limit,temp_USED,TEMP_Balance from #Temp_Leave2
		end
		else if @leave_Type = 1
		BEGIN
		
			if exists (select top 1 * from #Temp_Leave2 where Leave_Used = 0 and TEMP_Balance > 0)
			begin
				select MAX(For_Date) as For_Date,SUM(TEMP_Balance) as Leave_Credit From #Temp_Leave2
				where Leave_Used = 0 and TEMP_Balance > 0
			end
			else
			begin
				select @For_Date as For_Date,0 as Leave_Credit
			end
		end
		else if @leave_Type = 2
		begin
			select @For_Date as For_Date,0 as Leave_Used
		end
		else if @leave_Type = 5
		begin
			if exists (select top 1 * from #Temp_Leave2 where Leave_Used = 0 and TEMP_Balance > 0)
			begin
				--insert into #temp_CompOff
				SELECT     SUM(TEMP_Balance) AS Leave_Opening, 0 AS Leave_Used, SUM(TEMP_Balance) AS Leave_Closing, lt.Leave_Code, lt.Leave_Name, @Leave_ID AS Leave_ID
				FROM         [#Temp_Leave2] AS t1 INNER JOIN
									  T0040_LEAVE_MASTER AS lt WITH (NOLOCK) ON lt.Leave_ID = @leave_ID
				WHERE     (Leave_Used = 0) AND (TEMP_Balance > 0)
				GROUP BY lt.Leave_Code, lt.Leave_Name
			end
			--else
			--begin
			--	select @For_Date as For_Date,0 as Leave_Credit
			--end
		end
		else if @leave_Type = 6
		begin
			if exists (select top 1 * from #Temp_Leave2 where Leave_Used = 0 and TEMP_Balance > 0)
			begin
				insert into #temp_CompOff
				SELECT     SUM(TEMP_Balance) AS Leave_Opening, 0 AS Leave_Used, SUM(t1.Leave_Credit) - SUM(t1.Leave_Used) AS Leave_Closing, lt.Leave_Code, lt.Leave_Name, @Leave_ID AS Leave_ID
				FROM         [#Temp_Leave2] AS t1 INNER JOIN
									  T0040_LEAVE_MASTER AS lt WITH (NOLOCK) ON lt.Leave_ID = @leave_ID
				WHERE   for_date <= @For_Date 
				
				 -- (Leave_Used = 0) AND (TEMP_Balance > 0)
				GROUP BY lt.Leave_Code, lt.Leave_Name
			end
			--else
			--begin
			--	select @For_Date as For_Date,0 as Leave_Credit
			--end
		end

	
		drop table #temp_Leave1
	END
	else
	BEGIN
	
		
		if Isnull(@For_Date,'') = '' 
		begin
			select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @Emp_ID
		end
		
		declare @GRD_ID		NUMERIC
		declare @comp_off_leave_id  as numeric
		select @comp_off_leave_id = leave_id from T0040_LEAVE_MASTER WITH (NOLOCK)
		where Default_Short_Name = 'COMP' and Cmp_ID = @CMP_ID
		
		
		if Isnull(@For_Date,'') = '' 
		begin
			select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @Emp_ID
			AND Leave_ID = @comp_off_leave_id 
		end

		select @GRD_ID = grd_id From T0095_Increment I WITH (NOLOCK) inner join     
			   (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)   --Changed by Hardik 10/09/2014 for Same Date Increment 
			   where Increment_Effective_date <= @FOR_DATE group by emp_ID) Qry on    
			   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID
		
		DECLARE @Comp_Off_Balance AS NUMERIC(18,2)
		
		SELECT @Comp_Off_Balance = Leave_Closing FROM dbo.T0140_LEAVE_TRANSACTION AS tlt WITH (NOLOCK) WHERE Emp_ID = @emp_id
		AND Leave_ID = @comp_off_leave_id 
		
		
		insert into #Temp_Leave2
		SELECT distinct ROW_NUMBER()over (order by lt.leave_ID) as Temp_Trans,
			LT.Cmp_ID,LT.Emp_ID,lt.For_Date, Leave_Opening,0 as Leave_Credit,Leave_Used,i3.Branch_ID,1 as Is_Compoff,
			case when gs.CompOff_Avail_Days < gs.H_CompOff_Avail_Days then case when gs.H_CompOff_Avail_Days < gs.W_CompOff_Avail_Days 
			then W_CompOff_Avail_Days else gs.H_CompOff_Avail_Days END else gs.CompOff_Avail_Days end as CompOff_Days_Limit,0 as Temp_Used,
			LEAVE_CLOSING as temp_Balance FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
			INNER JOIN  
			(SELECT MAX(FOR_DATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
			WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE AND LEAVE_ID in (Select Leave_ID from V0040_LEAVE_DETAILS Where Grd_ID=@GRD_ID and Display_leave_balance = 1)
			GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
			LT.FOR_DATE = Q.FOR_DATE 		INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID
			inner join (select branch_id,i1.Emp_ID from T0095_INCREMENT i1 WITH (NOLOCK) inner join (select emp_id,max(increment_effective_date) as idate from T0095_INCREMENT WITH (NOLOCK) group by emp_id ) i2 on i1.Emp_ID = i2.Emp_ID) i3
			on lt.Emp_ID=i3.Emp_ID 
			inner join T0040_GENERAL_SETTING gs WITH (NOLOCK) on i3.Branch_ID = gs.Branch_ID and gs.For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Added by Ramiz on 15092014
			where lt.Leave_ID = @comp_off_leave_id 
		
		
		
		IF @leave_type = 1
		BEGIN
			SELECT @for_date AS For_Date,@Comp_Off_Balance AS Leave_Credit
		END 
		ELSE if @leave_Type = 3
		begin
			select temp_trans,Cmp_ID,Emp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Branch_ID,Is_CompOff,CompOff_Days_Limit,temp_USED,TEMP_Balance from #Temp_Leave2
		end
		else if @leave_Type = 1
		BEGIN
		
			if exists (select top 1 * from #Temp_Leave2 where Leave_Used = 0 and TEMP_Balance > 0)
			begin
				select MAX(For_Date) as For_Date,SUM(TEMP_Balance) as Leave_Credit From #Temp_Leave2
				where Leave_Used = 0 and TEMP_Balance > 0
			end
			else
			begin
				select @For_Date as For_Date,0 as Leave_Credit
			end
		end
		else if @leave_Type = 2
		begin
			select @For_Date as For_Date,0 as Leave_Used
		end
		else if @leave_Type = 5
		begin
			if exists (select top 1 * from #Temp_Leave2 where Leave_Used = 0 and TEMP_Balance > 0)
			begin
				--insert into #temp_CompOff
				SELECT     SUM(TEMP_Balance) AS Leave_Opening, 0 AS Leave_Used, SUM(TEMP_Balance) AS Leave_Closing, lt.Leave_Code, lt.Leave_Name, @Leave_ID AS Leave_ID
				FROM         [#Temp_Leave2] AS t1 INNER JOIN
									  T0040_LEAVE_MASTER AS lt WITH (NOLOCK) ON lt.Leave_ID = @leave_ID
				WHERE     (Leave_Used = 0) AND (TEMP_Balance > 0)
				GROUP BY lt.Leave_Code, lt.Leave_Name
			end
			--else
			--begin
			--	select @For_Date as For_Date,0 as Leave_Credit
			--end
		end
		else if @leave_Type = 6
		begin
			if exists (select top 1 * from #Temp_Leave2 where TEMP_Balance > 0)
			begin
				
				insert into #temp_CompOff
				SELECT     SUM(TEMP_Balance) AS Leave_Opening, 0 AS Leave_Used, SUM(TEMP_Balance) AS Leave_Closing, lt.Leave_Code, lt.Leave_Name, @Leave_ID AS Leave_ID
				FROM         [#Temp_Leave2] AS t1 INNER JOIN
									  T0040_LEAVE_MASTER AS lt WITH (NOLOCK) ON lt.Leave_ID = @leave_ID
				WHERE     (TEMP_Balance > 0)
				GROUP BY lt.Leave_Code, lt.Leave_Name
				
				
				
			end
			--else
			--begin
			--	select @For_Date as For_Date,0 as Leave_Credit
			--end
		end

	
		drop table #temp_Leave1

	end
    
END



