

--Created By: Falak on 21-SEP-2010
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_Form_ER_1_Deepali_Bkp_16012025]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	--,@Branch_ID		numeric   = 0
	,@Branch_ID		Varchar(Max)  --Mukti 22122015
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@PBranch_ID	varchar(MAX) = '0'
	,@Segment_Id		numeric = 0   
	,@Vertical_Id		numeric = 0   
	,@SubVertical_Id	numeric = 0 
	,@SubBranch_Id		numeric = 0   
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	--if @Branch_ID = 0
	--	set @Branch_ID = null
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @Branch_ID = '0' or @Branch_ID = ''
		set @Branch_ID = null
		
	if @Branch_ID is null --or @Branch_ID = '0'
	Begin	
		select   @Branch_ID = COALESCE(@Branch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @Branch_ID = @Branch_ID + ',0'
	End
	
	
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

	If @Segment_Id = 0
		set @Segment_Id = null
	If @Vertical_Id = 0
		set @Vertical_Id = null
	If @SubVertical_Id = 0
		set @SubVertical_Id = null
	If @SubBranch_Id = 0
		set @SubBranch_Id = null


	
	Declare @cnt_M as numeric
	Declare @cnt_F as numeric
	Declare @cnt_T as numeric
	Declare @cnt_M_P as numeric
	Declare @cnt_F_P as numeric
	Declare @cnt_T_P as numeric
	declare @quater numeric
	
	select @quater = DATEPART(qq, @TO_date) 
	
	Declare @qua_end_date as datetime	
	Declare @qua_st_date as datetime
	Declare @p_qua_st_date as datetime
	Declare @p_qua_end_date as datetime
	
	if @quater = 1
		begin
			set @qua_st_date = dbo.GET_MONTH_ST_DATE (1,year(@to_date))
			set @qua_end_date = dbo.GET_MONTH_END_DATE (3,YEAR(@to_date))
			set @p_qua_st_date = dbo.GET_MONTH_ST_DATE (10,year(@to_date)-1)
			set @p_qua_end_date = dbo.GET_MONTH_END_DATE (12,year(@to_Date)-1)
		end
		
	else if @quater = 2
		begin
			set @qua_st_date = dbo.GET_MONTH_ST_DATE (4,year(@to_date))
			set @qua_end_date = dbo.GET_MONTH_END_DATE (6,YEAR(@to_date))
			set @p_qua_st_date = dbo.GET_MONTH_ST_DATE (1,year(@to_date))
			set @p_qua_end_date = dbo.GET_MONTH_END_DATE (3,year(@to_Date))
		end	
	else if @quater = 3
		begin
			set @qua_st_date = dbo.GET_MONTH_ST_DATE (7,year(@to_date))
			set @qua_end_date = dbo.GET_MONTH_END_DATE (9,YEAR(@to_date))
			set @p_qua_st_date = dbo.GET_MONTH_ST_DATE (4,year(@to_date))
			set @p_qua_end_date = dbo.GET_MONTH_END_DATE (6,year(@to_Date))
		end
	else if @quater = 4
		begin
			set @qua_st_date = dbo.GET_MONTH_ST_DATE (10,year(@to_date))
			set @qua_end_date = dbo.GET_MONTH_END_DATE (12,YEAR(@to_date))
			set @p_qua_st_date = dbo.GET_MONTH_ST_DATE (7,year(@to_date))
			set @p_qua_end_date = dbo.GET_MONTH_END_DATE (9,year(@to_Date))
		end
	
	--CREATE TABLE #Emp_Cons	-- Ankit 10092014 for Same Date Increment
	-- (      
	--   Emp_ID numeric ,     
	--   Branch_ID numeric,
	--   Increment_ID numeric    
	-- )   
	
	--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,@New_Join_emp,@Left_Emp,4,@PBranch_ID
	
	--CREATE TABLE #Emp_Cons_1	-- Ankit 10092014 for Same Date Increment
	-- (      
	--   Emp_ID numeric ,     
	--   Branch_ID numeric,
	--   Increment_ID numeric    
	-- )   
	 
	--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,@New_Join_emp,@Left_Emp,4,@PBranch_ID
	  	
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
		
	Declare @Emp_Cons_1 Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#')
			Insert Into @Emp_Cons_1
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end	
	else 
		begin
			if @PBranch_ID <> '0' and isnull(@Branch_ID,'') = '' --isnull(@Branch_ID,0) = 0
				Begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @qua_end_date 
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			AND EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(Branch_ID,0) or isnull(Branch_ID,0) = 0 ) --Mukti 31122015
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
			-- Changed By rohit on 23112012
				--(( @qua_st_date   >= join_Date  and  @p_qua_st_date  <= left_date) 
				--or ( @qua_end_date   >= join_Date  and @qua_end_date  <= left_date)
				--or Left_date is null and @qua_end_date  >= Join_Date)
				--or @qua_end_date  >= left_date and  @p_qua_st_date  <= left_date)
					(( @qua_st_date   >= join_Date  and  @qua_st_date  <= left_date) 
				or ( @qua_end_date   >= join_Date  and @qua_end_date  <= left_date)
				or Left_date is null and @qua_end_date  >= Join_Date)
				or @qua_end_date  >= left_date and  @qua_st_date  <= left_date)
			-- Ended By rohit on 23112012
			
			
			Insert Into @Emp_Cons_1
			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @p_qua_end_date 
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			AND EXISTS (select Data from dbo.Split(@Branch_Id, '#') PB Where cast(PB.data as numeric)=Isnull(Branch_ID,0) or isnull(Branch_ID,0) = 0 ) --Mukti 31122015
			--and (ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Id,ISNULL(Branch_ID,0)),'#') ) or isnull(Branch_ID,0) = 0 )  --Mukti 22122015
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @p_qua_st_date   >= join_Date  and  @p_qua_st_date  <= left_date) 
				or ( @p_qua_end_date   >= join_Date  and @p_qua_end_date  <= left_date)
				or Left_date is null and @p_qua_end_date  >= Join_Date)
				or @p_qua_end_date  >= left_date and  @p_qua_st_date  <= left_date)
	     End 
			else
				Begin
			Insert Into @Emp_Cons
     		select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @qua_end_date 
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and (ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Id,ISNULL(Branch_ID,0)),'#') ) or isnull(Branch_ID,0) = 0 )  --Mukti 22122015
			AND EXISTS (select Data from dbo.Split(@Branch_Id, '#') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0)) --Mukti 31122015
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--Mukti(start)29122015
			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 
			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
			and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
			--Mukti(end)29122015	
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
			-- Changed by rohit on 23112012
				--(( @qua_st_date   >= join_Date  and  @p_qua_st_date  <= left_date) 
				--or ( @qua_end_date   >= join_Date  and @qua_end_date  <= left_date)
				--or Left_date is null and @qua_end_date  >= Join_Date)
				--or @qua_end_date  >= left_date and  @p_qua_st_date  <= left_date)
			(( @qua_st_date   >= join_Date  and  @qua_st_date  <= left_date) 
				or ( @qua_end_date   >= join_Date  and @qua_end_date  <= left_date)
				or Left_date is null and @qua_end_date  >= Join_Date)
				or @qua_end_date  >= left_date and  @qua_st_date  <= left_date)
			--End By rohit on 23112012
			
			Insert Into @Emp_Cons_1
			select I.Emp_Id from T0095_Increment I  WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @p_qua_end_date 
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
		   -- and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and (ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Id,ISNULL(Branch_ID,0)),'#') ) or isnull(Branch_ID,0) = 0 )  --Mukti 22122015
			AND EXISTS (select Data from dbo.Split(@Branch_Id, '#') PB Where cast(PB.data as numeric)=Isnull(i.Branch_ID,0)) --Mukti 31122015
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--Mukti(start)29122015
			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 
			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
			and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
			--Mukti(end)29122015	
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @p_qua_st_date   >= join_Date  and  @p_qua_st_date  <= left_date) 
				or ( @p_qua_end_date   >= join_Date  and @p_qua_end_date  <= left_date)
				or Left_date is null and @p_qua_end_date  >= Join_Date)
				or @p_qua_end_date  >= left_date and  @p_qua_st_date  <= left_date)
	     End			
		End
		
			----Get only half Quetar employee generated Salary---ANkit 14072015
			--select * from @Emp_Cons
			--select * from @Emp_Cons_1
		
		---------- Comment by Jignesh Patel 23-Sep-2021----------------
		------delete from @Emp_Cons where Emp_ID not in (select Emp_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where Cmp_ID = @Cmp_ID and month(Month_End_Date) =MONTH(@qua_end_date) and year(Month_End_Date) =year(@qua_end_date) )
		-----delete from @Emp_Cons_1 where Emp_ID not in (select Emp_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where Cmp_ID = @Cmp_ID and month(Month_End_Date) =MONTH(@p_qua_end_date) and year(Month_End_Date) =year(@p_qua_end_date) )
		------------------- End ---------------

			
			select @cnt_M = COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) ,
			@cnt_F = COUNT(CASE WHEN  E.Gender = 'F' THEN 1 ELSE NULL END) ,
			--@cnt_T = Count(E.Emp_Id)
			@cnt_T = @cnt_M + @cnt_F
			from T0080_Emp_Master As E WITH (NOLOCK)

			INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--- Modify by Jignesh Patel 23-Sep-2021----
			----INNER JOIN @Emp_Cons ECM on ECM.emp_id = E.emp_id --Mukti 31122015
			Inner Join (select distinct Emp_ID from T0200_MONTHLY_SALARY where Cmp_ID = @Cmp_ID and Month_End_Date between @qua_st_date And  @qua_end_date) AS MS
			On MS.Emp_ID = E.Emp_ID 
			--------------- End ------------
			WHERE E.Cmp_ID = @Cmp_Id 
			--And E.Emp_ID in (select Emp_ID From @Emp_Cons) --commenetd By Mukti 31122015

			
			select @cnt_M_P = COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) ,
			@cnt_F_P = COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) ,
			--@cnt_T_P = Count(E.Emp_Id) 
			@cnt_T_P = @cnt_M_P + @cnt_F_P
			from T0080_Emp_Master As E WITH (NOLOCK)
			INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id

			--- Modify by Jignesh Patel 23-Sep-2021----
			-----INNER JOIN @Emp_Cons_1 ECM on ECM.emp_id = E.emp_id --Mukti 31122015
			Inner Join (select distinct Emp_ID from T0200_MONTHLY_SALARY where Cmp_ID = @Cmp_ID And Month_End_Date between @p_qua_st_date And @p_qua_end_date)  as MS
			On MS.Emp_ID = E.Emp_ID 
			---------------- End -------------------
			WHERE E.Cmp_ID = @Cmp_Id 
			--And E.Emp_ID in (select Emp_ID From @Emp_Cons_1) --commenetd By Mukti 31122015
		
		
			select C.Cmp_Name,C.Cmp_Address,C.Cmp_City,C.Cmp_Pincode,@cnt_M AS Male_Cur,
			@cnt_F AS Female_Cur,@cnt_T As Total,@cnt_M_P AS Male_Cur_Pre,@cnt_F_P AS Female_Pre,
			@cnt_T_P As Total_Pre,
			@qua_end_date  as quarter_end 
			,@p_qua_end_date as p_qua_end_date
			,c.Nature_of_Business	--Ankit 23092013
			from T0080_Emp_Master As E WITH (NOLOCK)
			INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			INNER JOIN @Emp_Cons ECM on ECM.emp_id = E.emp_id --Mukti 31122015
			WHERE E.Cmp_ID = @Cmp_Id 
		--And E.Emp_ID in (select Emp_ID From @Emp_Cons) --commenetd By Mukti 31122015
			Group By C.Cmp_Name,C.Cmp_Address,C.Cmp_City,C.Cmp_Pincode,c.Nature_of_Business		
	RETURN



