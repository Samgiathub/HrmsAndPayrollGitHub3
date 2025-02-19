
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Graphic_Leave_Reports]  
  @Cmp_ID  Numeric  
 ,@From_Date  Datetime  
 ,@To_Date  Datetime  
 ,@Emp_ID numeric
 ,@Type numeric =0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
 
 --Declare @Max_Date As DateTime
 
 --Select @Max_date=Max(For_Date) From Dbo.T0140_Leave_Transaction Where Emp_Id=@Emp_Id and cmp_Id=@cmp_Id and YEAR(For_Date) = YEAR(GETDATE()) --Changed By nikunj 19-04-2011 because some time it gives you wrong data
 
 --Commented By Jimit 11122018 (As per case at WCL it's showing from Financial year wise but before version it was showing calcnder year wise) 

-- SET @From_Date = CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)
-- SET @From_Date = DATEADD(D, DAY(@From_Date)*-1, @From_Date)+1
-- IF MONTH(@From_Date) BETWEEN 1 AND 3
--	SET @From_Date = DATEADD(YYYY,-1, DATEADD(MM, 4-MONTH(@From_Date), @From_Date))
--ELSE
--	SET @From_Date = DATEADD(MM, 4-MONTH(@From_Date), @From_Date)

--SET @To_Date = DATEADD(YYYY, 1, @From_Date) - 1


 
 Declare @Emp_leave Table
	(
		leave_name nvarchar(50),
		leave_code nvarchar(10),
		leave_opening numeric(5,2),
		leave_credit numeric(5,2),
		leave_used	numeric(5,2),
		leave_remain numeric(5,2),
		Emp_id numeric
	)

	declare @leaveid numeric
		
	declare @leave_name nvarchar(50)
	declare @leave_code nvarchar(10)
	declare @leave_opening numeric(5,2)
	declare @leave_remain numeric(5,2)
	declare @leave_used	numeric(5,2)
	declare @leave_credit nvarchar(50)
	declare @Max_ForDate datetime  -- Added by mihir 13012012
				
	set @leave_name	= 0
	set @leave_code	= 0
	set @leave_opening	= 0
	set @leave_remain	= 0
	set @leave_used	= 0
	set @leave_credit = 0
	
	
	 DECLARE @Leave_Bal_Display_FixOpening NUMERIC /*TMS - For Electrothem requirement  (Email Dated :  Apr 12, 2016) --Ankit 12042016 */
	 --SELECT @Leave_Bal_Display_FixOpening = Leave_Balance_Display_FixOpening FROM T0010_COMPANY_MASTER WHERE Cmp_Id = @cmp_Id
	 SET @Leave_Bal_Display_FixOpening = 1
	 DECLARE @Leave_Opening_First	NUMERIC(18,2)
	 SET @Leave_Opening_First = 0
	 DECLARE @TMS_Module NUMERIC
	 SET @TMS_Module = 1 -- 0 For TMS,
	 SELECT @TMS_Module = module_status FROM T0011_module_detail WITH (NOLOCK) WHERE module_name = 'Payroll' AND Cmp_id = @Cmp_ID 

	--- Added by mihir 16012012
	declare @Grade_Id numeric
	
	select @Grade_Id=I.Grd_ID from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
	---End of Added by mihir 16012012
	
	
if @Type = 1
    	Begin
			--select Sum(T.Leave_Used) as Leave_Used,L.leave_name,L.Leave_Code,max(t.leave_opening)as leave_opening,max(t.leave_opening)-Sum(T.Leave_Used) as leave_remain From T0140_LEave_Transaction T inner 
			--join T0040_Leave_Master L  on T.Leave_id = L.Leave_id  where T.Cmp_ID = @Cmp_ID  and T.For_Date<=@Max_date group by L.leave_name,L.leave_code
			
		declare Cur_Allow   cursor for
		select lt.leave_id,lt.emp_id from T0140_LEave_Transaction lt WITH (NOLOCK) inner join t0040_leave_master lm WITH (NOLOCK) on lt.Leave_Id=lm.Leave_Id and isnull(Lm.Default_Short_Name,'') <> 'COMP' -- Changed By Gadriwala Muslim 01102014
		where  lt.cmp_id=@Cmp_ID and YEAR(FOR_DATE) = YEAR(GETDATE()) and lm.Display_leave_balance =1 group by lt.Leave_ID,emp_id
		open cur_allow
		fetch next from cur_allow  into @leaveid,@Emp_ID
		while @@fetch_status = 0
			begin
				select @leave_used = SUM(leave_used) + ISNULL(SUM(Back_Dated_Leave),0) ,@leave_credit =SUM(Leave_Credit) from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID AND YEAR(FOR_DATE) = YEAR(GETDATE()) and leave_id = @leaveid
				select top 1 @leave_opening = Leave_Opening from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID AND YEAR(FOR_DATE) = YEAR(GETDATE()) and leave_id = @leaveid order by For_Date
				select top 1 @leave_remain = Leave_Closing from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID AND YEAR(FOR_DATE) = YEAR(GETDATE()) and leave_id = @leaveid 
				And (Leave_Opening >0 or Leave_Credit >0 or Leave_Used > 0 or Leave_Closing > 0) order by For_Date desc
				select @leave_code = Leave_Code,@leave_name = Leave_Name from T0040_Leave_Master WITH (NOLOCK) where Leave_ID = @leaveid
				
				--set @leave_opening = @leave_opening + @leave_credit
				
				
				insert into @Emp_leave 
				select @leave_name,@leave_code,isnull(@leave_opening,0),isnull(@leave_credit,0),isnull(@leave_used,0),isnull(@leave_remain,0),@Emp_ID
				
				set @leave_opening = 0
				set @leave_credit = 0
				set @leave_used = 0
				set @leave_remain = 0 
				
				fetch next from cur_allow  into @leaveid,@Emp_ID
			end
		close cur_Allow
		deallocate Cur_Allow
			
			
        end
 Else
      Begin	
		
	  --  select Sum(T.Leave_Used) as Leave_Used,L.leave_name,L.Leave_Code,max(t.leave_opening)as leave_opening,max(t.leave_opening)-Sum(T.Leave_Used) as leave_remain From T0140_LEave_Transaction T inner 
			--join T0040_Leave_Master L  on T.Leave_id = L.Leave_id Where T.Cmp_ID = @Cmp_ID  and T.For_Date<=@Max_date and T.Emp_ID= @Emp_ID  group by L.leave_name ,L.leave_code
		declare Cur_Allow   cursor for
		select lt.leave_id from T0140_LEave_Transaction lt WITH (NOLOCK) inner join t0040_leave_master lm WITH (NOLOCK) on lt.Leave_Id=lm.Leave_Id and isnull(Lm.Default_Short_Name,'') <> 'COMP' -- Changed By Gadriwala Muslim 01102014
		where lt.cmp_id=@Cmp_ID and lt.Emp_ID = @Emp_ID and lm.Display_leave_balance =1  
		group by lt.Leave_ID --AND YEAR(FOR_DATE) = YEAR(GETDATE())   -- Changes done by mihir 13012012		
		open cur_allow
		fetch next from cur_allow  into @leaveid
		while @@fetch_status = 0
			begin
				SET @leave_opening = null;
				SET	@leave_remain = null;
				SET @leave_credit = NULL;
				SET @leave_used = NULL;
				
				IF @Leave_Bal_Display_FixOpening = 1 AND @TMS_Module = 0	
					BEGIN
						SELECT @Max_ForDate = MAX(For_Date) FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND YEAR(For_Date) = YEAR(GETDATE()) AND leave_id = @leaveid 
						
						
						SELECT TOP 1 @Leave_Opening_First = ISNULL(Leave_Opening,0) 
						FROM T0140_LEave_Transaction WITH (NOLOCK)
						WHERE Emp_ID = @Emp_ID AND leave_id = @leaveid AND For_Date >= @From_Date --AND YEAR(FOR_DATE) = YEAR(GETDATE()) 
						ORDER BY For_Date ASC

						if @Leave_Opening_First IS NULL
							SELECT TOP 1 @Leave_Opening_First = ISNULL(Leave_Closing,0) 
							FROM T0140_LEave_Transaction WITH (NOLOCK)
							WHERE Emp_ID = @Emp_ID AND leave_id = @leaveid AND For_Date < @From_Date --AND YEAR(FOR_DATE) = YEAR(GETDATE()) 
							ORDER BY For_Date DESC

						

						--SELECT @Leave_Opening_First = ISNULL(leave_negative_max_limit,0) FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND Leave_ID = @leaveid
						--IF YEAR(@Max_ForDate) >= YEAR(GETDATE())
						--	BEGIN
						--		SELECT TOP 1 @leave_opening = Leave_Opening FROM T0140_LEave_Transaction 
						--		WHERE Emp_ID = @Emp_ID AND  
						--			For_Date = (SELECT MIN(For_Date)  FROM T0140_LEAVE_TRANSACTION LT INNER JOIN 
						--							T0050_LEAVE_DETAIL LD ON LD.Grd_ID = @Grade_Id   AND LD.Leave_ID = LT.Leave_ID
						--						WHERE YEAR(For_Date) = YEAR(GETDATE()) AND LT.Emp_ID = @Emp_ID AND LT.leave_id =@leaveid GROUP BY LT.Leave_ID 
						--						)
						--			AND leave_id =@leaveid 
						--		ORDER BY For_Date DESC
						--	END
						--ELSE
						--	BEGIN
						--		SELECT TOP 1 @leave_opening = Leave_Closing FROM T0140_LEave_Transaction WHERE Emp_ID = @Emp_ID AND 
						--			For_Date = (SELECT MAX(For_Date)  FROM T0140_LEAVE_TRANSACTION LT INNER JOIN T0050_LEAVE_DETAIL LD ON LD.Grd_ID = @Grade_Id  AND LD.Leave_ID = LT.Leave_ID
						--		WHERE YEAR(For_Date) <= YEAR(GETDATE()) AND LT.Emp_ID = @Emp_ID  AND LT.leave_id =@leaveid GROUP BY LT.Leave_ID )AND leave_id =@leaveid ORDER BY For_Date DESC
						--	END
						
						SELECT @leave_used = ISNULL(SUM(leave_used),0)+ ISNULL(SUM(Back_Dated_Leave),0) --added by jimit 01122016
								,@leave_credit =SUM(Leave_Credit) FROM T0140_LEave_Transaction WITH (NOLOCK)
						WHERE	Emp_ID = @Emp_ID AND leave_id = @leaveid 
								--AND YEAR(FOR_DATE) = YEAR(GETDATE())
								And For_Date BETWEEN @From_Date AND @To_Date
						
						IF YEAR(@Max_ForDate) >= YEAR(GETDATE())
							BEGIN
								SELECT	TOP 1 @leave_remain = Leave_Closing 
								FROM	T0140_LEave_Transaction WITH (NOLOCK)
								WHERE	Emp_ID = @Emp_ID AND leave_id = @leaveid 
										AND (Leave_Opening >0 OR Leave_Credit >0 OR Leave_Used > 0 OR Leave_Closing > 0)
										--AND YEAR(FOR_DATE) = YEAR(GETDATE()) 
										and For_Date Between @From_Date AND @To_Date 
								ORDER BY For_Date DESC
								
							END
						ELSE
							BEGIN
								SELECT	TOP 1 @leave_remain = Leave_Closing 
								FROM	T0140_LEave_Transaction WITH (NOLOCK)
								WHERE	Emp_ID = @Emp_ID 
										AND For_Date = (SELECT	MAX(For_Date)  FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LD.Grd_ID = @Grade_Id  AND LD.Leave_ID = LT.Leave_ID
														WHERE	--YEAR(For_Date) <= YEAR(GETDATE()) 
																For_Date BETWEEN @From_Date AND @To_Date
																AND LT.Emp_ID = @Emp_ID  AND LT.leave_id =@leaveid 
														GROUP BY LT.Leave_ID )
										AND leave_id =@leaveid 
								ORDER BY For_Date DESC								
							END
						

						IF @leave_remain IS NULL
							SET @leave_remain = @leave_opening + IsNull(@leave_credit,0) - IsNull(@leave_used,0)


						SELECT @leave_code = Leave_Code,@leave_name = Leave_Name FROM T0040_Leave_Master WITH (NOLOCK) WHERE Leave_ID = @leaveid
						---SET @leave_remain =  ISNULL(@leave_credit,0) - ISNULL(@leave_used,0)
						 
						INSERT INTO @Emp_leave 
						SELECT @leave_name,@leave_code,ISNULL(@Leave_Opening_First,0),ISNULL(@leave_credit,0),ISNULL(@leave_used,0),ISNULL(@leave_remain,0),@Emp_ID
						
					END
				ELSE
					BEGIN	
						
						---Added by Mihir 13012012  and some condition correction done on 16012012
						select	@Max_ForDate=Max(For_Date) 
						from	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
						where	Emp_ID = @Emp_ID And 
								--YEAR(For_Date) = YEAR(GETDATE()) 
								For_Date Between @From_Date AND @To_Date
								and leave_id = @leaveid 

						SELECT	TOP 1 @leave_opening = Leave_Opening 
						FROM	T0140_LEave_Transaction WITH (NOLOCK)
						WHERE	Emp_ID = @Emp_ID AND leave_id =@leaveid 
								AND For_Date  >= @From_Date
						ORDER BY For_Date 

						IF @leave_opening IS NULL
							SELECT	TOP 1 @leave_opening = Leave_Closing
							FROM	T0140_LEave_Transaction WITH (NOLOCK)
							WHERE	Emp_ID = @Emp_ID AND leave_id =@leaveid 
									AND For_Date  < @From_Date
							ORDER BY For_Date desc

						
						--if Year(@Max_ForDate) >= YEAR(getdate())
						--	begin							
						--		SELECT	TOP 1 @leave_opening = Leave_Opening 
						--		FROM	T0140_LEave_Transaction 
						--		WHERE	Emp_ID = @Emp_ID AND For_Date = (SELECT	MIN(For_Date)  
						--												FROM	T0140_LEAVE_TRANSACTION LT 
						--														INNER JOIN T0050_LEAVE_DETAIL LD ON LD.Grd_ID = @Grade_Id  AND LD.Leave_ID = LT.Leave_ID
						--												WHERE	--YEAR(For_Date) = YEAR(Getdate()) 
						--														For_Date BETWEEN @From_Date AND @To_Date
						--														and LT.Emp_ID = @Emp_ID and LT.leave_id =@leaveid 
						--												GROUP BY LT.Leave_ID )
						--				and leave_id =@leaveid 
						--		order by For_Date desc
						--	end
						--else
						--	begin
						--		select top 1 @leave_opening = Leave_Closing from T0140_LEave_Transaction where Emp_ID = @Emp_ID AND 
						--		For_Date = (select Max(For_Date)  from T0140_LEAVE_TRANSACTION LT inner join T0050_LEAVE_DETAIL LD on LD.Grd_ID = @Grade_Id  and LD.Leave_ID = LT.Leave_ID
						--		where YEAR(For_Date) <= YEAR(Getdate()) and LT.Emp_ID = @Emp_ID  and LT.leave_id =@leaveid group by LT.Leave_ID )and leave_id =@leaveid order by For_Date desc
						--	end
						--End of added by Mihir 13012012 and some condition correction done on 16012012
						SELECT	@leave_used = isnull(SUM(leave_used),0) + ISNULL(SUM(Back_Dated_Leave),0) + Sum(IsNull(Leave_Adj_L_Mark,0)),
								@leave_credit =SUM(Leave_Credit) 
						from	T0140_LEave_Transaction WITH (NOLOCK)
						where	Emp_ID = @Emp_ID and leave_id = @leaveid --AND YEAR(FOR_DATE) = YEAR(GETDATE())
								AND For_Date BETWEEN @From_Date AND @To_Date
						
						--- Below Commented by Mihir 13012012
						--select top 1 @leave_opening = Leave_Opening from T0140_LEave_Transaction where Emp_ID = @Emp_ID AND 
						---- YEAR(FOR_DATE) = YEAR(GETDATE()) and leave_id = @leaveid order by For_Date
						--Year(For_Date) = (select MAX(For_Date)  from T0140_LEAVE_TRANSACTION where YEAR(For_Date) <= YEAR(Getdate()) and leave_id =@leaveid group by Leave_ID )and leave_id =@leaveid order by For_Date
						---End of Below Commented by Mihir 13012012
						
						--if Year(@Max_ForDate) >= YEAR(getdate())
						--begin
						--select top 1 @leave_remain = Leave_Closing from T0140_LEave_Transaction where Emp_ID = @Emp_ID AND YEAR(FOR_DATE) = YEAR(GETDATE()) and leave_id = @leaveid 
						--	And (Leave_Opening >0 or Leave_Credit >0 or Leave_Used > 0 or Leave_Closing > 0)order by For_Date desc
						--END
						--ELSE
						--BEGIN
						--		select top 1 @leave_remain = Leave_Closing from T0140_LEave_Transaction where Emp_ID = @Emp_ID AND 
						--		For_Date = (select Max(For_Date)  from T0140_LEAVE_TRANSACTION LT inner join T0050_LEAVE_DETAIL LD on LD.Grd_ID = @Grade_Id  and LD.Leave_ID = LT.Leave_ID
						--		where YEAR(For_Date) <= YEAR(Getdate()) and LT.Emp_ID = @Emp_ID  and LT.leave_id =@leaveid group by LT.Leave_ID )and leave_id =@leaveid order by For_Date desc
						
						--END	
						SELECT	TOP 1 @leave_remain = Leave_Closing 
						from	T0140_LEave_Transaction WITH (NOLOCK)
						WHERE	Emp_ID = @Emp_ID AND --YEAR(FOR_DATE) = YEAR(GETDATE()) 
								For_Date BETWEEN @From_Date AND @To_Date
								and leave_id = @leaveid 
								And (Leave_Opening >0 or Leave_Credit >0 or Leave_Used > 0 or Leave_Closing > 0)
						ORDER BY For_Date desc
						
						

						IF @leave_remain IS NULL
							SET @leave_remain = @leave_opening + IsNull(@leave_credit,0) - IsNull(@leave_used,0)
						

						select @leave_code = Leave_Code,@leave_name = Leave_Name from T0040_Leave_Master WITH (NOLOCK) where Leave_ID = @leaveid
						
						
						-- Added by Mihir 16012012
						--if not @leave_opening is null
						--	begin
						--			set @leave_opening = @leave_opening + isnull(@leave_credit,0)
									insert into @Emp_leave 
									select @leave_name,@leave_code,isnull(@leave_opening,0),isnull(@leave_credit,0),isnull(@leave_used,0),isnull(@leave_remain,0),@Emp_ID
						--	end								
						--end of  Added by Mihir 16012012
						
					END			
				set @leave_opening = 0
				set @leave_credit = 0
				set @leave_used = 0
				set @leave_remain = 0 
				
				fetch next from cur_allow  into @leaveid
			end
		close cur_Allow
		deallocate Cur_Allow
	
		
       End
       
       select * from @Emp_leave 
       
 RETURN




