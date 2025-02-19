

CREATE PROCEDURE [dbo].[SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_New]
	@cmp_id numeric
	,@from_date datetime
	,@to_date datetime
	,@branch_id numeric
	,@Cat_ID numeric
	,@grd_id numeric
	,@Type_id numeric
	,@dept_ID numeric
	,@desig_ID numeric
	,@emp_id numeric
	,@constraint varchar(5000)
	,@Report_For varchar(50) = ''
	,@Export_Type varchar(50) = 'EXCEL'
	,@Type numeric = 0
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	set ANSI_WARNINGS on;
	/* Variables are declared at two stages viz
	1) to Store the Values in Input
	2) to Store the Query Part
	*/
	declare @First_In_Last_Out_For_InOut_Calculation as numeric
	declare @grade_id as numeric
	declare @desig as numeric
	declare @dept as numeric
	declare @category as numeric
	declare @BusiSeg as numeric
	declare @Vertical as numeric
	declare @SubVertical as numeric
	--declare @Type as numeric
	declare @SubBranch as numeric
	declare @chkemp_id as varchar(max)
	declare @chkemp_id_1 as varchar(max)
	declare @chkbranch_id as varchar(max)
	declare @chkgrade_id as varchar(max)
	declare @chkdesig as varchar(max)
	declare @chkdept as varchar(max)
	declare @chkcategory as varchar(max)
	declare @chkBusiSeg as varchar(max)
	declare @chkVertical as varchar(max)
	declare @chkSubVertical as varchar(max)
	declare @chkType as varchar(max)
	declare @chkSubBranch as varchar(max)
	declare @chkConstraint as varchar(max)
	declare @chkConstraint1 as varchar(max)
	declare @LastDayOfPreviousMonth as datetime
	
	set @LastDayOfPreviousMonth=@from_date
	
	while month(@from_date)=MONTH(@LastDayOfPreviousMonth)
	begin
		set @LastDayOfPreviousMonth=DATEADD(d,-1,@LastDayOfPreviousMonth)
	end
	
	
	set @branch_id = @branch_id
	set @cmp_id = @cmp_id
	set @emp_id = @emp_id
	set @grade_id = @grade_id
	set @desig = @desig
	set @dept = @dept
	set @category = @category
	set @BusiSeg = @BusiSeg
	set @Vertical = @Vertical
	set @SubVertical = @SubVertical
	set @Type = @Type
	set @SubBranch = @SubBranch
	/* Query Part stored in Variables subject to input conditions */
	if @constraint <> ''
	begin
		set @chkConstraint = ' and Emp_ID in (select cast(data as numeric) from dbo.Split ( ''' + @Constraint + ''',''#''))'
		set @chkConstraint1 = ' and mec.Emp_ID in (select cast(data as numeric) from dbo.Split ( ''' + @Constraint + ''',''#''))'
	end
	ELSE
	BEGIN
		SET @chkConstraint = ''
		SET @chkConstraint1 = ''
	END
	if @emp_id <> 0
	begin
		set @chkemp_id=' and Emp_ID in ('+ cast(@emp_id as varchar(max)) + ')'
		set @chkemp_id_1=' and mec.Emp_ID in ('+ cast(@emp_id as varchar(max)) + ')'
	end
	else
	begin
		set @chkemp_id=''
		set @chkemp_id_1=''
	end
	if @branch_id <> 0
	begin
		set @chkbranch_id = ' and branch_id in (' + cast(@branch_id as varchar(max)) + ')'
	end
	else
	begin
		set @chkbranch_id = ''
	end
	if @grade_id <> 0
	begin
		set @chkgrade_id = ' and grd_id in (' + cast(@grade_id as varchar(max)) + ')'
	end
	else
	begin
		set @chkgrade_id=''
	end
	if @desig <> 0
	begin
		set @chkdesig = ' and desig_id in (' + cast(@desig as varchar(max)) + ')'
	end
	else
	begin
		set @chkdesig = ''
	end
	if @dept <> 0
	begin
		set @chkdept=' and dept_id in (' + cast(@dept as varchar(max)) + ')'
	end
	else
	begin
		set @chkdept = ''
	end
	if @category <> 0
	begin
		set @chkcategory =' and cat_id in (' + cast(@category as varchar(max)) + ')'
	end
	else
	begin
		set @chkcategory = ''
	end
	if @BusiSeg <> 0
	begin
		set @chkBusiSeg =' and Segment_ID in (' + cast(@BusiSeg as varchar(max)) + ')'
	end
	else
	begin
		set @chkBusiSeg = ''
	end
	if @Vertical <> 0
	begin
		set @chkVertical =' and Vertical_id in (' + cast(@Vertical as varchar(max)) + ')'
	end
	else
	begin
		set @chkVertical = ''
	end
	if @SubVertical <> 0
	begin
		set @chkSubVertical =' and SubVertical_ID in (' + cast(@SubVertical as varchar(max)) + ')'
	end
	else
	begin
		set @chkSubVertical = ''
	end
	if @SubBranch <> 0
	begin
		set @chkSubBranch =' and SubBranch_ID in (' + cast(@SubBranch as varchar(max)) + ')'
	end
	else
	begin
		set @chkSubBranch = ''
	end
	if @Type <> 0
	begin
		set @chkType =' and Type_ID in (' + cast(@Type as varchar(max)) + ')'
	end
	else
	begin
		set @chkType = ''
	end
	/* Leave Code temp Table created for Paid Leave Codes to be considerred later in Queries */
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_get_LM_Temp' and type = 'u')
	begin
		drop table #weekoff_get_LM_Temp
	end
	select distinct Leave_Code,Holiday_As_Leave,Weekoff_as_leave into #weekoff_get_LM_Temp from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_Paid_Unpaid='P'
	and cmp_ID = @cmp_id
	
	/* Table Test1 is been created and added dates between two dates through this SP */
	/* Employee Selection done from V_EMP_CONS View using conditions given in above variables */
	declare @qry1 as varchar(max)
	set @qry1 = ''
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#V_Emp_Get_Info1' and type = 'u')
	begin
		drop table #V_Emp_Get_Info1
	end
	CREATE table #V_Emp_Get_Info1
	(
		emp_id numeric
		,branch_id numeric
		,Cmp_ID numeric
		,Increment_ID numeric
		,Join_Date datetime
		,Left_Date datetime
		,Emp_code numeric
		,dept_id numeric
		,grd_id numeric
		,desig_id numeric
		,type_id numeric
	)
	if @constraint <> ''
	begin
		set @qry1 = '
					insert into #V_Emp_Get_Info1
					SELECT DISTINCT mec.Emp_ID, mec.Branch_ID, mec.Cmp_ID, mec.Increment_ID, mec.Join_Date, mec.Left_Date,
					mec.Emp_Code,dept_id,grd_id,desig_id,type_id
					FROM V_Emp_Cons AS mec INNER JOIN
					(SELECT Emp_ID, MAX(Increment_Effective_Date) AS increment_effective_date
					FROM V_Emp_Cons
					GROUP BY Emp_ID) AS ec ON mec.Emp_ID = ec.Emp_ID AND mec.Increment_Effective_Date = ec.increment_effective_date
					WHERE (1 = 1)' + @chkConstraint1
		exec (@qry1)
	end
	else
	begin
		insert into #V_Emp_Get_Info1
		select distinct emp_id,branch_id,Cmp_ID,Increment_ID,Join_Date,Left_Date,Emp_code,dept_id,grd_id,desig_id,type_id
		from dbo.V_Emp_Cons where
		cmp_id=@Cmp_ID
		and Isnull(Cat_ID,0) = case when @Cat_ID = 0 then Isnull(Cat_ID,0) else Isnull(@Cat_ID , Isnull(Cat_ID,0)) end
		and Branch_ID = case when @branch_id = 0 then Branch_ID else isnull(@Branch_ID ,Branch_ID) end
		and Grd_ID = case when @grd_id = 0 then Grd_ID else isnull(@Grd_ID ,Grd_ID) end
		and isnull(Dept_ID,0) = case when @dept_ID = 0 then isnull(Dept_ID,0) else isnull(@Dept_ID ,isnull(Dept_ID,0)) end
		and Isnull(Type_ID,0) = case when @Type_id = 0 then Isnull(Type_ID,0) else isnull(@Type_ID ,Isnull(Type_ID,0)) end
		and Isnull(Desig_ID,0) = case when @desig_ID = 0 then Isnull(Desig_ID,0) else isnull(@Desig_ID ,Isnull(Desig_ID,0)) end
		and Emp_ID = case when @emp_id = 0 then Emp_ID else isnull(@Emp_ID ,Emp_ID) end
		and Increment_Effective_Date <= @To_Date
		and
		((@From_Date >= join_Date and @From_Date <= left_date)
		or (@To_Date >= join_Date and @To_Date <= left_date)
		or (Left_date is null and @To_Date >= Join_Date)
		or (@To_Date >= left_date and @From_Date <= left_date))
		order by Emp_ID

		delete from #V_Emp_Get_Info1 where Increment_ID not in (select max(Increment_ID) from dbo.T0095_Increment WITH (NOLOCK) 
		where Increment_effective_Date <= @to_date
		group by emp_ID)
	END
	
	declare @leave_footer as varchar(max) ,
	@lc as varchar(max),
	@lt as Varchar(max),
	@ld as numeric
	SET @leave_footer = ''
	
	declare leave cursor for
		SELECT DISTINCT lm.Leave_ID, lm.Leave_Code, lm.Leave_Name
		FROM         T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  INNER JOIN
							  [#V_Emp_Get_Info1] AS em ON em.cmp_id = lm.Cmp_ID
		ORDER BY lm.Leave_ID	
	open leave
	fetch next from leave into @ld, @lc,@lt
	while @@FETCH_STATUS = 0
	begin
		set @leave_footer = @leave_footer + @lc + ' : ' + @lt + ' '
		fetch next from leave into @ld,@lc,@lt
	end
	close leave
	deallocate leave
	
	-- Added By Ali 28042014 -- Start	
	Set @leave_footer = @leave_footer + 'A*:' + 'Back Dated Leave'
	-- Added By Ali 28042014 -- End
	
	if @Report_For = 'EMP RECORD'
	begin
	
		SELECT     E.Emp_ID, E.Emp_code, E.Alpha_Emp_Code, E.Emp_First_Name, E.Emp_Full_Name, BM.Comp_Name, BM.Branch_Address, BM.Branch_Name, DM.Dept_Name, 
							  GM.Grd_Name, DGM.Desig_Name, tm.Type_Name, CM.Cmp_Name, CM.Cmp_Address, @From_Date AS P_From_date, @To_Date AS P_To_Date, BM.Branch_ID, 
							  @leave_Footer AS Leave_Footer
		FROM         [#V_Emp_Get_Info1] AS EC INNER JOIN
							  T0080_EMP_MASTER AS E WITH (NOLOCK)  ON EC.EMP_ID = E.Emp_ID INNER JOIN
								  (SELECT     I.Branch_ID, I.Grd_ID, I.Dept_ID, I.Desig_Id, I.Type_ID, I.Emp_ID
									FROM          T0095_INCREMENT AS I WITH (NOLOCK)  INNER JOIN
															   (SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID
																 FROM          T0095_INCREMENT WITH (NOLOCK) 
																 WHERE      (Increment_Effective_Date <= @To_Date) AND (Cmp_ID = @Cmp_ID)
																 GROUP BY Emp_ID) AS Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_Effective_Date = Qry.For_Date) AS Q_I ON 
							  E.Emp_ID = Q_I.Emp_ID INNER JOIN
							  T0040_GRADE_MASTER AS GM WITH (NOLOCK)  ON Q_I.Grd_ID = GM.Grd_ID INNER JOIN
							  T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON Q_I.Branch_ID = BM.Branch_ID LEFT OUTER JOIN
							  T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK)  ON Q_I.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
							  T0040_DESIGNATION_MASTER AS DGM  WITH (NOLOCK) ON Q_I.Desig_Id = DGM.Desig_ID INNER JOIN
							  T0010_COMPANY_MASTER AS CM  WITH (NOLOCK) ON CM.Cmp_Id = E.Cmp_ID LEFT OUTER JOIN
							  T0040_TYPE_MASTER AS tm  WITH (NOLOCK) ON Q_I.Type_ID = tm.Type_ID
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.Alpha_Emp_Code, 500)		
		
		Return
	
	end
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#V_Emp_Get_Info' and type = 'u')
	begin
		drop table #V_Emp_Get_Info
	end
		SELECT     Isnull(em.Extra_AB_Deduction,0)Extra_AB_Deduction, vec1.*
		INTO            [#V_Emp_Get_Info]
		FROM         [#V_Emp_Get_Info1] AS vec1 INNER JOIN
							  T0080_EMP_MASTER AS em WITH (NOLOCK)  ON vec1.Emp_ID = em.Emp_ID AND vec1.Cmp_ID = em.Cmp_ID	set @from_date = dateadd(d,-10,@from_date)
	
	set @to_date = dateadd(d,10,@to_date)
	exec getAllDaysBetweenTwoDate @from_date, @to_date
	
	/* Employee wise shift details as per the effective date is considered here */
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_shift_detail_temp' and type = 'u')
	begin
		drop table #v_shift_detail_temp
	end

	SELECT     a.Emp_ID, a.Cmp_ID, a.Shift_ID, a.For_Date, a.Eff_Date_Sd, a.Shift_St_Time, a.Shift_End_Time, a.Is_Night_Shift, a.Is_Split_Shift, a.Is_Training_Shift, a.Week_Day, 
						  a.Half_St_Time, a.Half_End_Time, a.Half_Dur,a.Shift_Type 
	INTO            [#v_shift_detail_temp_temp]
	FROM         (SELECT     a.Emp_ID, a.Cmp_ID, a.Shift_ID, a.For_Date, a.Expr1 AS Eff_Date_Sd, sm.Shift_St_Time, sm.Shift_End_Time, 
												  CASE WHEN sm.Shift_St_Time > sm.Shift_End_Time THEN 1 ELSE 0 END AS Is_Night_Shift, sm.Is_Split_Shift, sm.Is_Training_Shift, sm.Week_Day, 
												  sm.Half_St_Time, sm.Half_End_Time, sm.Half_Dur,Shift_Type 
						   FROM          (SELECT     sd1.Emp_ID, sd1.Cmp_ID, sd1.Shift_ID, sd1.For_Date,
																			  (SELECT     MIN(test1) AS Expr1
																				FROM          test1) AS Expr1,shift_type
												   FROM          T0100_EMP_SHIFT_DETAIL AS sd1 WITH (NOLOCK)  INNER JOIN
																			  (SELECT     Emp_ID, Cmp_ID, MAX(For_Date) AS for_date
																				FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
																				WHERE      (For_Date < @from_date)
																				GROUP BY Emp_ID, Cmp_ID) AS t1 ON t1.Emp_ID = sd1.Emp_ID AND t1.Cmp_ID = sd1.Cmp_ID AND t1.for_date = sd1.For_Date
												   WHERE      (sd1.Emp_ID NOT IN
																			  (SELECT DISTINCT Emp_ID
																				FROM          T0100_EMP_SHIFT_DETAIL AS T0100_EMP_SHIFT_DETAIL_3 WITH (NOLOCK) 
																				WHERE      (For_Date = @from_date)))
												   UNION
												   SELECT     Emp_ID, Cmp_ID, Shift_ID, For_Date, For_Date AS Expr1,shift_type
												   FROM         T0100_EMP_SHIFT_DETAIL AS sd1 WITH (NOLOCK) 
												   WHERE     (For_Date BETWEEN @from_date AND @to_date)) AS a INNER JOIN
												  T0040_SHIFT_MASTER AS sm ON a.Shift_ID = sm.Shift_ID) AS a INNER JOIN
						  [#V_Emp_Get_Info] AS V ON a.Emp_ID = v.Emp_ID	
	
		
	SELECT     Emp_ID,Cmp_ID,Shift_ID,MAX(For_Date) as For_Date,MAX(eff_date_sd) as eff_date_sd,
				Shift_St_Time,Shift_End_Time,Is_Night_Shift,Is_Split_Shift,Is_Training_Shift,Week_Day,
				Half_St_Time,Half_End_Time,Half_Dur,Shift_Type
	INTO [#v_Shift_Detail_Temp]
	FROM        [#v_shift_detail_temp_temp]
	GROUP BY Emp_ID,Cmp_ID,Shift_ID,Shift_St_Time,Shift_End_Time,Is_Night_Shift,Is_Split_Shift,Is_Training_Shift,Week_Day,
				Half_St_Time,Half_End_Time,Half_Dur,Shift_Type
	
	/* Regular weekoff is been considered along with approval of compasatory weekoff */
	
	if exists(select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_weekoff_temp_temp' and type = 'u')
	begin
		drop table #v_weekoff_temp_temp
	end
	
	SELECT DISTINCT Cmp_ID, Emp_ID, For_Date, eff_date, weekoff_Day1, case when charindex(weekoff_Day2+'0.5',Weekoff_Day_Value)>0 then '' else weekoff_day2 end as Weekoff_Day2
	INTO            [#v_weekoff_temp_temp]
	FROM         (SELECT     w1.Cmp_ID, w1.Emp_ID, w1.For_Date,
													  (SELECT     MIN(test1) AS Expr1
														FROM          test1) AS eff_date, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN LEFT(weekoff_day, charindex('#', Weekoff_Day) - 1) 
												  ELSE Weekoff_Day END AS weekoff_Day1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN RIGHT(weekoff_day, len(weekoff_day) - charindex('#', 
												  Weekoff_Day)) ELSE '' END AS weekoff_Day2,Weekoff_Day_Value 
						   FROM          (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, Alt_W_Half_Day_Cont, 
																		  Is_P_Comp
												   FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK) 
												   WHERE      ((Alt_W_Full_Day_Cont = '') OR
																		  (Alt_W_Full_Day_Cont IS NULL) or CHARINDEX('1.0',Weekoff_Day_Value)<>0)) AS w1 INNER JOIN
													  (SELECT     Emp_ID, Cmp_ID, MAX(For_Date) AS for_date
														FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK) 
														WHERE      (For_Date < @from_date)
														GROUP BY Emp_ID, Cmp_ID) AS w2 ON w1.Emp_ID = w2.Emp_ID AND w1.Cmp_ID = w2.Cmp_ID AND w1.For_Date = w2.for_date
						   WHERE      (w1.For_Date < @from_date) AND (w1.Emp_ID NOT IN
													  (SELECT DISTINCT Emp_ID
														FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK) 
														WHERE      (For_Date = @from_date)))
						   UNION
						   SELECT     w1.Cmp_ID, w1.Emp_ID, w1.For_Date,
													 (SELECT     MIN(test1) AS Expr1
													   FROM          test1) AS eff_date, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN LEFT(weekoff_day, charindex('#', Weekoff_Day) - 1) 
												 ELSE Weekoff_Day END AS weekoff_Day1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN RIGHT(weekoff_day, len(weekoff_day) - charindex('#', 
												 Weekoff_Day)) ELSE '' END AS weekoff_Day2,Weekoff_Day_Value
						   FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, Alt_W_Half_Day_Cont, 
																		 Is_P_Comp
												  FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK) 
												  WHERE      (Alt_W_Full_Day_Cont = '') OR
																		 (Alt_W_Full_Day_Cont IS NULL)) AS w1 INNER JOIN
													 (SELECT     Emp_ID, Cmp_ID, MAX(For_Date) AS for_date
													   FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK) 
													   WHERE      (For_Date > @from_date)
													   GROUP BY Emp_ID, Cmp_ID) AS w2 ON w1.Emp_ID = w2.Emp_ID AND w1.Cmp_ID = w2.Cmp_ID AND w1.For_Date = w2.for_date
						   WHERE     (w1.For_Date < @from_date) AND (w1.Emp_ID NOT IN
													 (SELECT DISTINCT Emp_ID
													   FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK) 
													   WHERE      (For_Date = @from_date) AND (Alt_W_Full_Day_Cont IS NULL OR
																			  Alt_W_Full_Day_Cont = '' or CHARINDEX('1.0',Weekoff_Day_Value)<>0)))
						   UNION
						   SELECT     Cmp_ID, Emp_ID, For_Date, For_Date AS Expr1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN LEFT(weekoff_day, charindex('#', Weekoff_Day) - 1) 
												 ELSE Weekoff_Day END AS weekoff_Day1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN RIGHT(weekoff_day, len(weekoff_day) - charindex('#', 
												 Weekoff_Day)) ELSE '' END AS weekoff_Day2,Weekoff_Day_Value
						   FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, Alt_W_Half_Day_Cont, 
																		 Is_P_Comp
												  FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK) 
												  WHERE      (Alt_W_Full_Day_Cont = '') OR
																		 (Alt_W_Full_Day_Cont IS NULL) or CHARINDEX('1.0',Weekoff_Day_Value)<>0) AS T0100_WEEKOFF_ADJ
						   WHERE     (For_Date BETWEEN @from_date AND @to_date)) AS a


	/* Alternate weekoff is considered here along with approval of Compansatory */

	if exists(select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_alt_weekoff_temp_temp ' and type = 'u')
	begin
		drop table #v_alt_weekoff_temp_temp
	end
	
	SELECT DISTINCT Cmp_ID, Emp_ID, eff_date, Alt_Weekoff_day, Count1, Count2, Count3, Count4, Count5
	INTO            [#v_alt_weekoff_temp_temp]
	FROM         (SELECT     w1.Cmp_ID, w1.Emp_ID, w1.For_Date, @from_date AS eff_date, Alt_W_Name AS Alt_Weekoff_day, w1.Alt_W_Full_Day_Cont, 
												  CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 2, 1) ELSE 0 END AS Count1, 
												  CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 2) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 4, 1) ELSE 0 END AS Count2, 
												  CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 4) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 6, 1) ELSE 0 END AS Count3, 
												  CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 6) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 8, 1) ELSE 0 END AS Count4, 
												  CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 8) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 10, 1) ELSE 0 END AS Count5
						   FROM          (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, Alt_W_Half_Day_Cont, 
																		  Is_P_Comp
												   FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_7 WITH (NOLOCK) 
												   WHERE      (Alt_W_Full_Day_Cont <> '') AND (Alt_W_Full_Day_Cont IS NOT NULL)) AS w1 INNER JOIN
													  (SELECT     Emp_ID, Cmp_ID, MAX(For_Date) AS for_date
														FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_6 WITH (NOLOCK) 
														WHERE      (For_Date < @from_date)
														GROUP BY Emp_ID, Cmp_ID) AS w2 ON w1.Emp_ID = w2.Emp_ID AND w1.Cmp_ID = w2.Cmp_ID AND w1.For_Date = w2.for_date
						   WHERE      (w1.For_Date < @from_date) AND (w1.Emp_ID NOT IN
													  (SELECT DISTINCT Emp_ID
														FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_5 WITH (NOLOCK) 
														WHERE      (For_Date = @from_date)))
						   UNION
						   SELECT     w1_1.Cmp_ID, w1_1.Emp_ID, w1_1.For_Date, @from_date AS eff_date, w1_1.Alt_W_Name AS Alt_Weekoff_day, w1_1.Alt_W_Full_Day_Cont, 
												 CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 2, 1) ELSE 0 END AS Count1, 
												 CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 2) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 4, 1) ELSE 0 END AS Count2, 
												 CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 4) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 6, 1) ELSE 0 END AS Count3, 
												 CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 6) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 8, 1) ELSE 0 END AS Count4, 
												 CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 8) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 10, 1) ELSE 0 END AS Count5
						   FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, Alt_W_Half_Day_Cont, 
																		 Is_P_Comp
												  FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_4 WITH (NOLOCK) 
												  WHERE      (Alt_W_Full_Day_Cont <> '') AND (Alt_W_Full_Day_Cont IS NOT NULL)) AS w1_1 INNER JOIN
													 (SELECT     Emp_ID, Cmp_ID, MAX(For_Date) AS for_date
													   FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_3 WITH (NOLOCK) 
													   WHERE      (For_Date > @to_date)
													   GROUP BY Emp_ID, Cmp_ID) AS w2_1 ON w1_1.Emp_ID = w2_1.Emp_ID AND w1_1.Cmp_ID = w2_1.Cmp_ID AND w1_1.For_Date = w2_1.for_date
						   WHERE     (w1_1.For_Date > @from_date) AND (w1_1.Emp_ID NOT IN
													 (SELECT DISTINCT Emp_ID
													   FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_2 WITH (NOLOCK) 
													   WHERE      (For_Date = @from_date) AND (Alt_W_Full_Day_Cont IS NOT NULL) AND (Alt_W_Full_Day_Cont <> '')))
						   UNION
						   SELECT     Cmp_ID, Emp_ID, For_Date, For_Date AS Expr1, Alt_W_Name AS Alt_Weekoff_day, Alt_W_Full_Day_Cont, CASE WHEN CHARINDEX('#', 
												 Alt_W_Full_Day_Cont) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 2, 1) ELSE 0 END AS Count1, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 2) 
												 > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 4, 1) ELSE 0 END AS Count2, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 4) 
												 > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 6, 1) ELSE 0 END AS Count3, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 6) 
												 > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 8, 1) ELSE 0 END AS Count4, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 8) 
												 > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 10, 1) ELSE 0 END AS Count5
						   FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, Alt_W_Half_Day_Cont, 
																		 Is_P_Comp
												  FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_1 WITH (NOLOCK) 
												  WHERE      (Alt_W_Full_Day_Cont <> '') AND (Alt_W_Full_Day_Cont IS NOT NULL)) AS T0100_WEEKOFF_ADJ
						   WHERE     (For_Date BETWEEN @from_date AND @to_date)) AS a

	
	/* Employee in - out record based on the condition in general setting as to first in last out.
	Here need to note that wherever night shift is found in shift details in-time is considered as 12 hours prior
	to actual in-out time and wherever split shift is found along with night shift the prior hours in reduced to 6 hours
	these dates are considered for FOR_DATE derivation.
	*/

	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_Emp_InOut_Record_temp' and type = 'u')
	begin
		drop table #v_Emp_InOut_Record_temp
	end
	
	
	SELECT     Emp_ID, Cmp_ID, For_Date, MIN(In_Time) AS In_Time, MAX(Out_Time) AS Out_Time, SUM(Dur_sum) AS Dur_sum, SUM(max_min_time) AS max_min_time, 
						  CAST(REPLACE(dbo.f_return_hours(SUM(Present_Hours)),':','.') AS decimal(18, 5)) AS Present_Hours, MAX(Chk_By_Superior) AS Chk_By_Superior, MAX(Half_Full_day) AS Half_Full_day, 
						  MAX(Is_Split_Shift) AS Is_Split_Shift, MAX(Is_Night_Shift) AS Is_Night_Shift, MAX(Is_Training_Shift) AS Is_Training_Shift, Shift_St_Time, Shift_End_Time,HF_Week_Day,max(HF_Week_Day_Dur) HF_Week_Day_Dur
	INTO            [#v_Emp_InOut_Record_temp]
	FROM         (SELECT     Emp_ID, Cmp_ID, For_Date, min(In_Time) as In_Time, max(Out_Time) as Out_Time, CAST(SUM(Duration) AS decimal(18, 5)) AS Dur_sum, 
					CAST(DATEDIFF(SECOND, Case when Cast(MIN(In_Time) as varchar(11)) <> 'Jan  1 1900' then MIN(In_Time) else MAX(out_time) end, MAX(Out_Time)) * 1 AS decimal(18, 5)) AS max_min_time, 
					CASE WHEN fc = 0 THEN CAST(SUM(Duration) AS decimal(18, 5)) ELSE 
						CAST(DATEDIFF(SECOND, Case when Cast(MIN(In_Time) as varchar(11)) <> 'Jan  1 1900' then MIN(In_Time) else MAX(out_time) end,MAX(Out_Time)) * 60 AS decimal(18, 5)) END AS Present_Hours, 
						MAX(Chk_By_Superior) AS Chk_By_Superior, MAX(Half_Full_day) AS Half_Full_day, 
												  max(Is_Split_Shift) Is_Split_Shift, max(Is_Night_Shift) Is_Night_Shift, max(Is_Training_Shift) Is_Training_Shift, Shift_St_Time, Shift_End_Time,HF_Week_Day,max(HF_Week_Day_Dur) HF_Week_Day_Dur
						   FROM          (SELECT     eir.Emp_ID, eir.Cmp_ID, gs.First_In_Last_Out_For_InOut_Calculation AS fc,
																			  (SELECT     Is_Split_Shift
																				FROM          [#v_shift_detail_temp]
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          [#v_shift_detail_temp]
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS Is_Split_Shift,
																			  (SELECT     Is_Night_Shift
																				FROM          [#v_shift_detail_temp]
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          [#v_shift_detail_temp]
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS Is_Night_Shift,
																			  (SELECT     Is_Training_Shift
																				FROM          [#v_shift_detail_temp]
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          [#v_shift_detail_temp]
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS Is_Training_Shift, 
																			  (SELECT     Week_Day
																				FROM          [#v_shift_detail_temp]
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          [#v_shift_detail_temp]
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS HF_Week_Day, 
																			  (SELECT     Half_Dur
																				FROM          [#v_shift_detail_temp]
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          [#v_shift_detail_temp]
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS HF_Week_Day_Dur, 
																		  CASE WHEN Chk_By_Superior = 1 THEN eir.For_Date ELSE CASE WHEN
																			  (SELECT     is_night_shift
																				FROM          #v_shift_detail_temp
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          #v_shift_detail_temp
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 1 THEN CASE WHEN
																			  (SELECT     Is_Split_Shift
																				FROM          #v_shift_detail_temp
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          #v_shift_detail_temp
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 0 THEN CAST(CONVERT(nvarchar(10), dateadd(hour, 
																		  - 12, eir.In_Time), 101) AS DATE) ELSE CAST(CONVERT(nvarchar(10), dateadd(hour, - 6, eir.In_Time), 101) AS DATE) 
																		  END ELSE CAST(CONVERT(nvarchar(10), dateadd(hour, - 0, eir.In_Time), 101) AS DATE) END END AS For_Date, CASE WHEN
																			  (SELECT     is_night_shift
																				FROM          #v_shift_detail_temp
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          #v_shift_detail_temp
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 1 THEN CASE WHEN
																			  (SELECT     Is_Split_Shift
																				FROM          #v_shift_detail_temp
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          #v_shift_detail_temp
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 0 THEN dateadd(hour, - 12, eir.In_Time) 
																		  ELSE dateadd(hour, - 6, eir.In_Time) END ELSE dateadd(hour, - 0, eir.In_Time) END AS In_Time, CASE WHEN
																			  (SELECT     is_night_shift
																				FROM          #v_shift_detail_temp
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          #v_shift_detail_temp
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 1 THEN CASE WHEN
																			  (SELECT     Is_Split_Shift
																				FROM          #v_shift_detail_temp
																				WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																										   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																											 FROM          #v_shift_detail_temp
																											 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 0 THEN dateadd(hour, - 12, eir.Out_Time) 
																		  ELSE dateadd(hour, - 6, eir.Out_Time) END ELSE dateadd(hour, - 0, eir.Out_Time) END AS Out_Time, dbo.F_Return_Sec(eir.Duration) AS Duration,
																		  eir.Reason, eir.Ip_Address, eir.In_Date_Time, eir.Out_Date_Time, eir.Skip_Count, eir.Late_Calc_Not_App, eir.Chk_By_Superior, 
																		  eir.Sup_Comment, CASE WHEN Chk_By_Superior = 1 THEN eir.Half_Full_day ELSE NULL END AS Half_Full_day, 
																		  CASE WHEN Chk_By_Superior = 1 THEN eir.Is_Cancel_Late_In ELSE 0 END AS Is_Cancel_Late_In, 
																		  CASE WHEN Chk_By_Superior = 1 THEN eir.Is_Cancel_Early_Out ELSE 0 END AS Is_Cancel_Early_Out, eir.Is_Default_In, eir.Is_Default_Out, 
																		  eir.Cmp_prp_in_flag, eir.Cmp_prp_out_flag, eir.is_Cmp_purpose, ec.branch_id, eir.Shift_St_Time, eir.Shift_End_Time
												   FROM          (SELECT     IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, CASE WHEN In_Time IS NULL THEN CASE WHEN Chk_By_Superior = 1 THEN
																									  (SELECT     Shift_St_Time
																										FROM          #v_shift_detail_temp
																										WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																																   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																																	 FROM          #v_shift_detail_temp
																																	 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) ELSE NULL 
																								  END ELSE In_Time END AS In_Time, ISNULL(Out_Time, CASE WHEN In_Time IS NULL 
																								  THEN CASE WHEN Chk_By_Superior = 1 THEN
																									  (SELECT     Shift_St_Time
																										FROM          #v_shift_detail_temp
																										WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																																   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																																	 FROM          #v_shift_detail_temp
																																	 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) ELSE NULL END ELSE In_Time END) 
																								  AS Out_Time,
																									  (SELECT     CASE WHEN DATENAME(dw, eir.for_Date) = Week_Day THEN Half_St_Time ELSE Shift_St_Time END AS Expr1
																										FROM          [#v_shift_detail_temp]
																										WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																																   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																																	 FROM          [#v_shift_detail_temp]
																																	 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS Shift_St_Time,
																									  (SELECT     CASE WHEN DATENAME(dw, eir.for_date) = Week_Day THEN Half_End_Time ELSE Shift_End_Time END AS Expr1
																										FROM          [#v_shift_detail_temp]
																										WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																																   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																																	 FROM          [#v_shift_detail_temp]
																																	 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS Shift_End_Time, 
																								  Duration, Reason, 
																								  Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App, Chk_By_Superior, Sup_Comment, Half_Full_day, 
																								  Is_Cancel_Late_In, Is_Cancel_Early_Out, Is_Default_In, Is_Default_Out, Cmp_prp_in_flag, Cmp_prp_out_flag, is_Cmp_purpose
																		   FROM          T0150_EMP_INOUT_RECORD AS eir WITH (NOLOCK) 
																		   WHERE      (For_Date BETWEEN @from_date AND @to_date)) AS eir INNER JOIN
																		  [#V_Emp_Get_Info] AS ec ON ec.emp_id = eir.Emp_ID AND ec.Cmp_ID = eir.Cmp_ID INNER JOIN
																		  T0040_GENERAL_SETTING AS gs WITH (NOLOCK)  ON ec.Branch_ID = gs.Branch_ID AND ec.Cmp_ID = gs.Cmp_ID) AS eir
						   GROUP BY Emp_ID, Cmp_ID, For_Date/*, In_Time, Out_Time, Is_Night_Shift, Is_Split_Shift, Is_Training_Shift*/, fc, Shift_St_Time, Shift_End_Time,HF_Week_Day) AS a
	GROUP BY Emp_ID, Cmp_ID, For_Date, Shift_St_Time, Shift_End_Time,HF_Week_Day
	
	
	
	/* #weekoff_get1_temp is the first base table generated here with all basic information and considerring only 'P'
	or 'A' in Presence Column. This column then forms the bases of all other calculations
	*/
	
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_getLeave_Temp' and type = 'u')
	begin
		drop table #weekoff_getLeave_Temp
	end

if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_getLeave_Temp2' and type = 'u')
	begin
		drop table #weekoff_getLeave_Temp2
	end

	SELECT lt.Emp_ID, lt.Cmp_ID, 'A' AS Approval_Status, lt.For_Date AS from_Date, lt.For_Date AS To_Date,case when lm.Apply_Hourly = 1 then lt.Leave_Used * 0.125 else lt.Leave_Used end as Leave_Used, lm.Weekoff_as_leave, lm.Holiday_as_leave,
	lm.Leave_Code, la.Leave_Assign_As ,la.half_leave_date,la.leave_out_time,leave_in_time -- Change by rohit on 11092014
	into #weekoff_getLeave_Temp
	FROM T0140_LEAVE_TRANSACTION AS lt WITH (NOLOCK)  INNER JOIN
	T0040_LEAVE_MASTER AS lm  WITH (NOLOCK) ON lm.Leave_ID = lt.Leave_ID  and isnull(Default_Short_Name,'') <> 'COMP' INNER JOIN
	(SELECT la.Emp_ID, lad.Cmp_ID, lad.Leave_ID, lad.From_Date, lad.To_Date, lad.Leave_Assign_As, la.Approval_Status,lad.Half_Leave_Date,lad.leave_out_time,lad.leave_in_time
	FROM T0130_LEAVE_APPROVAL_DETAIL AS lad  WITH (NOLOCK) INNER JOIN
	T0120_LEAVE_APPROVAL AS la  WITH (NOLOCK) ON la.Leave_Approval_ID = lad.Leave_Approval_ID 
	where la.Approval_Status = 'A') AS la ON lt.Emp_ID = la.Emp_ID AND
	lt.For_Date >= la.From_Date AND lt.For_Date <= la.To_Date AND lt.Leave_ID = la.Leave_ID
	inner join #V_Emp_Get_Info ec on lt.Emp_ID=ec.emp_id
	where lt.leave_used > 0
	order by from_Date

	SELECT lt.Emp_ID, lt.Cmp_ID, 'A' AS Approval_Status, lt.For_Date AS from_Date, lt.For_Date AS To_Date,case when lm.Apply_Hourly = 1 then(isnull(LT.CompOff_Used,0) - isnull(lt.Leave_Encash_Days ,0)) * 0.125 else (isnull(lt.CompOff_Used,0) - isnull(lt.Leave_Encash_Days ,0)) end as Leave_Used, lm.Weekoff_as_leave, lm.Holiday_as_leave,
	lm.Leave_Code, la.Leave_Assign_As ,la.half_leave_date,la.leave_out_time,leave_in_time -- Change by rohit on 11092014
	into #weekoff_getLeave_Temp2
	FROM T0140_LEAVE_TRANSACTION AS lt WITH (NOLOCK)  INNER JOIN
	T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  ON lm.Leave_ID = lt.Leave_ID  and isnull(Default_Short_Name,'') = 'COMP' INNER JOIN
	(SELECT la.Emp_ID, lad.Cmp_ID, lad.Leave_ID, lad.From_Date, lad.To_Date, lad.Leave_Assign_As, la.Approval_Status,lad.Half_Leave_Date,lad.leave_out_time,lad.leave_in_time
	FROM T0130_LEAVE_APPROVAL_DETAIL AS lad  WITH (NOLOCK) INNER JOIN
	T0120_LEAVE_APPROVAL AS la  WITH (NOLOCK) ON la.Leave_Approval_ID = lad.Leave_Approval_ID 
	where la.Approval_Status = 'A') AS la ON lt.Emp_ID = la.Emp_ID AND
	lt.For_Date >= la.From_Date AND lt.For_Date <= la.To_Date AND lt.Leave_ID = la.Leave_ID
	inner join #V_Emp_Get_Info ec on lt.Emp_ID=ec.emp_id
	where lt.CompOff_Used > 0
	order by from_Date
	
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_getLeave_Temp3' and type = 'u')
	begin
		drop table #weekoff_getLeave_Temp3
	end

	
	select * into #weekoff_getLeave_Temp3 from #weekoff_getLeave_Temp
	union all
	select * from #weekoff_getLeave_Temp2


	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_get1_temp' and type = 'u')
	begin
		drop table #weekoff_get1_temp
	end
	

	
		SELECT DISTINCT 
						  TOP (100) PERCENT t1.Cmp_ID, t1.emp_id, t1.branch_id, t1.Increment_ID, t1.Extra_AB_Deduction, t1.id, t1.test1, DATENAME(dw, t1.test1) AS Week_Day, 
						  DATEPART(week, t1.test1) -DATEPART(Week,@LastDayOfPreviousMonth) + 1 AS Week_Count, ISNULL(GS.Is_Cancel_Weekoff, 0) AS Can_Weekoff, ISNULL(leave.Approval_Status, 0) 
						  AS leaveStatus, ISNULL(leave.Weekoff_as_leave, 0) AS Weekoff_as_leave, ISNULL(leave.Holiday_as_leave, 0) AS Holiday_as_leave, 
						  ISNULL(case when leave.Half_Leave_Date = test1 OR leave.half_leave_date is null or leave.Half_Leave_Date='1900-01-01' then isnull(leave.Leave_Assign_As,'') else 'Full Day' end, '') AS Leave_Assign_As,
							  (SELECT     weekoff_Day1
								FROM          [#v_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS weekoff,
							  (SELECT     weekoff_Day2
								FROM          [#v_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS weekoff2,
							  (SELECT     Shift_ID
								FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
								WHERE      (Emp_ID = t1.emp_id) AND (Cmp_ID = t1.Cmp_ID) AND (For_Date =
														   (SELECT     MAX(For_Date) AS Expr1
															 FROM          (SELECT     Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type
																					 FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
																					 WHERE      (Shift_Type = 0)) AS T0100_EMP_SHIFT_DETAIL
															 WHERE      (Emp_ID = t1.emp_id) AND (For_Date <= t1.test1)))) 
															 AS shift_ID_Per,
							  (SELECT     Shift_ID
								FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
								WHERE      (Emp_ID = t1.emp_id) AND (Cmp_ID = t1.Cmp_ID) AND (For_Date =
														   (SELECT     MAX(For_Date) AS Expr1
															 FROM          (SELECT     Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type
																					 FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
																					 WHERE      (Shift_Type = 1)) AS T0100_EMP_SHIFT_DETAIL
															 WHERE      (Emp_ID = t1.emp_id) AND (For_Date = t1.test1)))) AS shift_ID_Temp, leave.Leave_Code, EIR.Present_Hours, 
						  CASE WHEN eir.For_Date IS NULL THEN 'A' ELSE 'P' END AS Presence,
							  (SELECT     Alt_Weekoff_day
								FROM          [#v_alt_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_alt_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Alt_Weekoff_Day,
							  (SELECT     Count1
								FROM          [#v_alt_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_alt_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count1,
							  (SELECT     Count2
								FROM          [#v_alt_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_alt_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count2,
							  (SELECT     Count3
								FROM          [#v_alt_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_alt_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count3,
							  (SELECT     Count4
								FROM          [#v_alt_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_alt_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count4,
							  (SELECT     Count5
								FROM          [#v_alt_weekoff_temp_temp]
								WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
														   (SELECT     MAX(eff_date) AS Expr1
															 FROM          [#v_alt_weekoff_temp_temp]
															 WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count5, t1.left_date, t1.join_date, EIR.Chk_By_Superior, EIR.Half_Full_day, 
						  EIR.Is_Split_Shift, EIR.Is_Night_Shift, EIR.Is_Training_Shift, eir.In_Time, eir.Out_Time, eir.Shift_St_Time, eir.Shift_End_Time, inc1.Emp_Late_Limit, 
						  inc1.Emp_Early_Limit, GS.Late_Limit, GS.Early_Limit, dbo.F_Return_Sec(ISNULL(inc1.Emp_Late_Limit, ISNULL(GS.Late_Limit, '00:00'))) AS latelimit_Sec, 
						  CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) AS time) as Act_In_Time,
						  CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) AS time) as Act_Out_Time,						  
						  
						  case when isnull(substring(CONVERT(VARCHAR, leave.leave_out_time, 108),0,6),'00:00') = Shift_St_time then 0 else DATEDIFF(minute, Shift_St_time, CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) AS time)) * 60 end AS actual_late_Sec, 
						  
						  DATEDIFF(minute, CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) AS time),Shift_St_time) * 60 AS Early_in_Sec, 
						 
						  case when isnull(substring(CONVERT(VARCHAR, leave.leave_out_time, 108),0,6),'00:00') = Shift_St_time then 0 else CASE WHEN dbo.F_Return_Sec(ISNULL(Emp_Late_Limit, ISNULL(Late_Limit, '00:00'))) >= ISNULL(DATEDIFF(minute, Shift_St_time, CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, In_Time) ELSE dateadd(HH, 6, In_Time) END ELSE dateadd(HH, 12, In_Time) END) AS varchar(2)) AS time)), 0) * 60 THEN 0 ELSE 1 END end AS Late_Count, 
						 
						  DATEDIFF(minute, Shift_End_Time, CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) AS time)) * 60 AS Late_Out_Sec,
						 
						  case when isnull(substring(CONVERT(VARCHAR, leave.leave_in_time, 108),0,6),'00:00') = Shift_end_time then 0 else DATEDIFF(minute, CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) AS time), Shift_End_Time) * 60 end AS actual_Early_Sec, 
						  case when isnull(substring(CONVERT(VARCHAR, leave.leave_in_time, 108),0,6),'00:00') = Shift_end_time then 0 else CASE WHEN dbo.F_Return_Sec(ISNULL(Emp_Early_Limit, ISNULL(Early_Limit, '00:00'))) >= ISNULL(DATEDIFF(minute, CAST(CAST(DATEPART(HOUR, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) + ':' + CAST(DATEPART(MINUTE, CASE WHEN eir.Is_Night_Shift = 0 THEN CASE WHEN eir.is_split_Shift = 0 THEN dateadd(HH, 0, Out_Time) ELSE dateadd(HH, 6, Out_Time) END ELSE dateadd(HH, 12, Out_Time) END) AS varchar(2)) AS time), Shift_End_Time), 0) * 60 THEN 0 ELSE 1 END end AS Early_Count, 
						  inc1.Emp_Late_mark, inc1.Emp_Early_mark, GS.Is_Late_Mark,eir.HF_Week_Day,eir.HF_Week_Day_Dur,case when leave_code = 'LWP' then 0 else Leave_Used end as Leave_Used,case when leave_code = 'LWP' then Leave_Used  else 0 end as Un_Leave_Used
	INTO            [#weekoff_get1_temp]
	FROM         (SELECT     ec.emp_id, Extra_AB_Deduction, ec.branch_id, ec.Cmp_ID, ec.Increment_ID, ec.join_date, ec.left_date, test1.id, test1.test1
						   FROM          [#V_Emp_Get_Info] AS ec CROSS JOIN
												  test1) AS t1 LEFT OUTER JOIN
						  T0095_INCREMENT AS inc1 WITH (NOLOCK)  ON t1.emp_id = inc1.Emp_ID AND t1.Increment_ID = inc1.Increment_ID AND t1.Cmp_ID = inc1.Cmp_ID LEFT OUTER JOIN
						  [#v_Emp_InOut_Record_temp] AS EIR ON t1.emp_id = EIR.Emp_ID AND t1.Cmp_ID = EIR.Cmp_ID AND t1.test1 = EIR.For_Date LEFT OUTER JOIN
						  T0040_GENERAL_SETTING AS GS WITH (NOLOCK)  ON t1.branch_id = GS.Branch_ID AND t1.Cmp_ID = GS.Cmp_ID AND t1.test1 = GS.For_Date LEFT OUTER JOIN
							  (	select la.Emp_ID,la.Cmp_ID,la.Approval_Status,from_Date,To_Date,Leave_Used,Weekoff_as_leave,Holiday_as_leave,Leave_Code,
									case when lc.Day_type is not null then case when Day_type='First Half' then 'Second Half' else 'First Half' end else Leave_Assign_As end as Leave_Assign_As,
									Half_Leave_Date,la.leave_out_time,la.leave_in_time from #weekoff_getLeave_Temp3 la
									Left outer join (select * from T0150_LEAVE_CANCELLATION WITH (NOLOCK)  where Is_Approve=1) lc
									on la.Emp_ID = lc.Emp_Id and la.from_Date = lc.for_date) AS leave ON t1.emp_id = leave.Emp_ID AND t1.Cmp_ID = leave.Cmp_ID AND t1.test1 >= leave.From_Date AND 
						  t1.test1 <= leave.To_Date
	
		-- Added by rohit on 10022015
	update [#weekoff_get1_temp] set actual_late_Sec =0,Late_Count =0,actual_Early_Sec =0,Early_Count =0 from [#weekoff_get1_temp] where Chk_By_Superior =1 and Upper(Half_Full_day) ='FULL DAY'
	update [#weekoff_get1_temp] set actual_late_Sec =0,Late_Count =0 from [#weekoff_get1_temp] where Chk_By_Superior =1 and UPPer(Half_Full_day) ='FIRST HALF'
	update [#weekoff_get1_temp] set actual_Early_Sec =0,Early_Count =0 from [#weekoff_get1_temp] where Chk_By_Superior =1 and Upper(Half_Full_day) ='SECOND HALF'
	
	update [#weekoff_get1_temp] set actual_late_Sec =0,Late_Count =0,actual_Early_Sec =0,Early_Count =0 from [#weekoff_get1_temp] where Leave_Used =1 and Upper(Leave_Assign_As) ='FULL DAY' and leaveStatus='A'
	update [#weekoff_get1_temp] set actual_late_Sec =0,Late_Count =0 from [#weekoff_get1_temp] where Leave_Used =0.5 and Upper(Leave_Assign_As) ='FIRST HALF' and leaveStatus='A'
	update [#weekoff_get1_temp] set actual_Early_Sec =0,Early_Count =0 from [#weekoff_get1_temp] where Leave_Used =0.5 and Upper(Leave_Assign_As) ='SECOND HALF' and leaveStatus='A'
	-- Ended by rohit
	
	--select * from #weekoff_get1_temp
	--SELECT lt.Emp_ID, lt.Cmp_ID, 'A' AS Approval_Status, lt.For_Date AS from_Date, lt.For_Date AS To_Date,case when lm.Apply_Hourly = 1 then lt.Leave_Used * 0.125 else lt.Leave_Used end as Leave_Used, lm.Weekoff_as_leave, lm.Holiday_as_leave,
	--							lm.Leave_Code, case when la.day_type is not null then case when la.day_type = 'First Half' then 'Second Half' else 'First Half' end else la.Leave_Assign_As end as Leave_Assign_As ,la.half_leave_date
	--							FROM T0140_LEAVE_TRANSACTION AS lt INNER JOIN
	--							T0040_LEAVE_MASTER AS lm ON lm.Leave_ID = lt.Leave_ID INNER JOIN
	--							(SELECT la.Emp_ID, lad.Cmp_ID, lad.Leave_ID, lad.From_Date, lad.To_Date, lad.Leave_Assign_As, la.Approval_Status,lad.Half_Leave_Date,lc.Day_type 
	--							FROM T0130_LEAVE_APPROVAL_DETAIL AS lad INNER JOIN
	--							T0120_LEAVE_APPROVAL AS la ON la.Leave_Approval_ID = lad.Leave_Approval_ID 
	--							left outer join T0150_LEAVE_CANCELLATION as lc on la.Leave_Approval_ID=lc.Leave_Approval_id
	--							where la.Approval_Status = 'A' and isnull(is_Approve,1) = 1) AS la ON lt.Emp_ID = la.Emp_ID AND
	--							lt.For_Date >= la.From_Date AND lt.For_Date <= la.To_Date AND lt.Leave_ID = la.Leave_ID
	--							where lt.leave_used > 0
	
	declare @wEmp_ID as numeric
	declare @wTest1 as datetime
	declare @wWeek_Day as varchar(max)
	declare @wWeek_Count as numeric
	
	declare weekcount cursor for
	select Emp_ID,test1,week_Day from #weekoff_get1_Temp
	order by test1
	open weekcount
	fetch next from weekcount into @wEmp_ID,@wTest1,@wWeek_Day
	while @@FETCH_STATUS=0
	begin
		if @wTest1 = @from_date
		begin
			update #weekoff_get1_temp
			set Week_Count = DATEPART(week,test1) - datepart(WEEK,@LastDayOfPreviousMonth) + 1
			where test1=@wTest1
			
			select @wWeek_Count=Week_Count from #weekoff_get1_temp 
			where test1=@from_date
		end
		if @wWeek_Day <> 'Sunday' and @wTest1 <> @from_date 
		begin
			if MONTH(@wTest1)<>MONTH(dateadd(d,-1,@wTest1))
				set @wWeek_Count = 1
			update #weekoff_get1_temp
			set Week_Count = @wWeek_Count
			where test1=@wTest1
		end
		else
		begin
			if @wTest1<> @from_date 
			begin
				if MONTH(@wTest1)=MONTH(dateadd(d,-1,@wTest1))
					set @wWeek_Count=@wWeek_Count + 1
				else
					set @wWeek_Count = 1
			end	
			update #weekoff_get1_temp
			set Week_Count = @wWeek_Count
			where test1=@wTest1
		end
		fetch next from weekcount into @wEmp_ID,@wTest1,@wWeek_Day
	end
	close weekcount
	deallocate weekcount
	
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
	   P_days  numeric(12,2) default 0,        
	   OT_Sec  numeric default 0  ,
	   In_Time datetime,
	   Shift_Start_Time datetime,
	   OT_Start_Time numeric default 0,
	   Shift_Change tinyint default 0,
	   Flag int default 0,
	   Weekoff_OT_Sec  numeric default 0,
	   Holiday_OT_Sec  numeric default 0,
	   Chk_By_Superior numeric default 0,
	   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
	   OUT_Time datetime,
	   Shift_End_Time datetime,			--Ankit 16112013
	   OT_End_Time numeric default 0,	--Ankit 16112013
	   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
	   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
	   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
   )

	exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@cmp_id,@From_Date=@from_date,@To_Date=@to_date ,@Branch_ID=@branch_id,@Cat_ID=@Cat_ID,@Grd_ID=@grd_id,@Type_ID=@Type_id,@Dept_ID=@dept_ID,@Desig_ID=@desig_ID,@Emp_ID=@Emp_ID,@constraint=@Constraint,@Return_Record_set=4
	
	
	update #weekoff_get1_temp
	set Present_Hours = cast(replace(dbo.f_return_hours(d.Duration_in_sec),':','.') as numeric(18,2))
	from #weekoff_get1_temp as wo1
	inner join #data as d on wo1.emp_id = d.Emp_Id 
	and d.For_date = wo1.test1 

	
	
	 declare @Emp_ID1 as numeric,
		@Allowed_Full_WeekOf_MidJoining_DayRate as numeric,
		@Allowed_Full_WeekOf_MidJoining as numeric,
		@branch_id_w as numeric,
		@cmp_id_w as numeric,
		@Emp_ID2 as numeric,
		@weekoff as varchar(max),
		@weekoff2 as varchar(max),
		@count1 as numeric,
		@count2 as numeric,
		@count3 as numeric,
		@count4 as numeric,
		@count5 as numeric,
		@test1 as datetime,
		@test2 as datetime
		

	declare weekoffcur cursor for
	select Emp_ID,test1,branch_id,cmp_id,weekoff,weekoff2,count1,count2,count3,count4,count5
	from #weekoff_get1_Temp
	order by test1
	open weekoffcur
	fetch next from weekoffcur into @Emp_ID1,@test1,@branch_id_w,@cmp_id_w,@weekoff,@weekoff2,@count1,@count2,@count3,@count4,@count5
	while @@fetch_Status = 0
	begin
		select @Allowed_Full_WeekOf_MidJoining_DayRate = Allowed_Full_WeekOf_MidJoining_DayRate,
		@Allowed_Full_WeekOf_MidJoining = Allowed_Full_WeekOf_MidJoining from T0040_General_Setting WITH (NOLOCK) 
		where cmp_id = @cmp_id_w and branch_id = @branch_id_w
		
		if @weekoff is null and @Allowed_Full_WeekOf_MidJoining_DayRate = 1 and @Allowed_Full_WeekOf_MidJoining = 1
		begin
			select @test2 = test1 from #weekoff_get1_temp
			where emp_id = @emp_id1 and test1 = @test1
			
			set @emp_id2 = @emp_id1
			
			while @weekoff is null and @emp_id2 = @emp_id1
			begin
				select @weekoff = weekoff,
						@weekoff2 = weekoff2,
						@count1 = count1,
						@count2 = count2,
						@count3 = count3,
						@count4 = count4,
						@count5 = count5,
						@emp_id2 = Emp_ID from #weekoff_get1_temp
				where emp_id = @emp_id1 and test1=@test2
				
				set @test2 = dateadd(d,1,@test2)
			end
			update #weekoff_get1_temp
			set weekoff = @weekoff,
				weekoff2 = @weekoff2,
				count1 = @count1,
				count2 = @count2,
				count3 = @count3,
				count4 = @count4,
				count5 = @count5
			where weekoff is null
			and emp_id = @emp_id1
		end
		fetch next from weekoffcur into @Emp_ID1,@test1,@branch_id_w,@cmp_id_w,@weekoff,@weekoff2,@count1,@count2,@count3,@count4,@count5
	end
	close weekoffcur
	deallocate weekoffcur


	/* This is the main calculation table that considers all the conditions and forms major portion of attendance
	calculation. Weekoff, Holiday, Leaves, Compansatory leaves, Attendance Regularizations are considered here
	*/
	
	
	
	if exists (select * from [tempdb].[dbo].sysobjects where name = '#weekoff_get2_temp' and type = 'u')
	begin
		drop table #weekoff_get2_temp
	end
	
	
	
	SELECT DISTINCT 
						  wo1.Cmp_ID, wo1.emp_id, wo1.branch_id, wo1.Increment_ID, wo1.shift_ID_Per, wo1.Extra_AB_Deduction, wo1.id, wo1.test1, wo1.Week_Day, 
						  CASE WHEN (WO1.TEST1 < wo1.JOIN_DATE OR WO1.TEST1 > WO1.LEFT_DATE) --OR wo1.test1 > CAST(CONVERT(nvarchar(10), getdate(), 101) AS datetime)) 
						  THEN 
							--CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5)))  OR wo1.test1 = wr.for_date 
							--THEN 'W_Pr' 
							--ELSE 
							
							'-' 
							--END
						  ELSE 
							CASE WHEN wo1.Chk_By_Superior = 1 
							THEN 
								CASE WHEN wo1.Half_Full_day = 'First Half' 
								THEN 'FH' 
								ELSE 
									CASE WHEN wo1.Half_Full_day = 'Second Half' 
									THEN 'SH' 
									ELSE 
										CASE WHEN wo1.Is_Split_Shift = 1 
										THEN 
											CASE WHEN ho1.Is_Fix IS NOT NULL OR ho2.Is_Fix IS NOT NULL OR ho3.Is_Fix IS NOT NULL 
											THEN 
												CASE WHEN presence = 'P' 
												THEN 'COM-HO' 
												ELSE 'HO' 
												END 
											ELSE 
												CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5))) OR wo1.test1 = wr.for_date 
												THEN 
													CASE WHEN presence = 'P' 
													THEN 'COM-W' 
													ELSE 
														CASE WHEN Week_Day = weekoff2 or Week_Day = Alt_Weekoff_Day OR wo1.test1 = wr.for_date 
														THEN 'W_C'
														ELSE 'W'
														END
													END 
												ELSE 
													CASE WHEN IS_Training_Shift = 1 
													THEN 'T' 
													ELSE 'S' 
													END 
												END 
											END 
										ELSE 
											CASE WHEN ho1.Is_Fix IS NOT NULL OR ho2.Is_Fix IS NOT NULL OR ho3.Is_Fix IS NOT NULL 
											THEN 
												CASE WHEN presence = 'P' 
												THEN 'COM-HO' 
												ELSE 'HO' 
												END 
											ELSE 
												CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5)))  OR wo1.test1 = wr.for_date 
												THEN 
													CASE WHEN presence = 'P' 
													THEN 'COM-W' 
													ELSE 
														CASE WHEN Week_Day = weekoff2 or Week_Day = Alt_Weekoff_Day OR wo1.test1 = wr.for_date 
														THEN 'W_C'
														ELSE 'W'
														END 
													END 
												ELSE
													CASE WHEN ISNULL(Leave_Assign_As,'') <> ''
													THEN
														CASE WHEN Leave_Assign_As IN ('First Half', 'Second Half') 
														THEN 
															CASE WHEN Leave_Assign_As = 'First Half'
															THEN Leave_Code + '-HF-P' 
															ELSE 'P-HF-' + Leave_Code
															END
														ELSE 
															CASE WHEN Leave_Assign_As = 'Part Day'
															THEN Leave_Code + '-Part_LT-P'
															ELSE Leave_Code
															END 
														END  
													ELSE
														CASE WHEN IS_Training_Shift = 1 
														THEN 'T' 
														ELSE 'P' 
														END 
													END
												END 
											END 
										END 
									END 
								END 
							ELSE 
								CASE WHEN leave_code IS NOT NULL 
								THEN 
									CASE WHEN presence <> 'P' 
									THEN 
										CASE WHEN ho1.Is_Fix IS NOT NULL OR ho2.Is_Fix IS NOT NULL OR ho3.Is_Fix IS NOT NULL 
										THEN 
											CASE WHEN Leave_Assign_As IN ('First Half', 'Second Half') 
											THEN 
												CASE WHEN Leave_Assign_As = 'First Half'
												THEN Leave_Code + '-HF-A' 
												ELSE 'A-HF-' + Leave_Code
												END 
											ELSE Leave_Code 
											END 
										ELSE
											CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5)))  OR wo1.test1 = wr.for_date 
											THEN 
												CASE WHEN Leave_Assign_As IN ('First Half', 'Second Half') 
												THEN 
													CASE WHEN Leave_Assign_As = 'First Half'
													THEN Leave_Code + '-HF-A' 
													ELSE 'A-HF-' + Leave_Code
													END
												ELSE 
													CASE WHEN Leave_Assign_As = 'Part Day'
													THEN Leave_Code + 'Part_LT-A'
													ELSE Leave_Code
													END
												END 
											ELSE
												CASE WHEN Leave_Assign_As IN ('First Half', 'Second Half') 
												THEN 
													CASE WHEN Leave_Assign_As = 'First Half'
													THEN Leave_Code + '-HF-A' 
													ELSE 'A-HF-' + Leave_Code
													END
												ELSE 
													CASE WHEN Leave_Assign_As = 'Part Day'
													THEN Leave_Code + '-Part_LT-A'
													ELSE Leave_Code
													END
												END 
											END 
										END 
									ELSE 
										CASE WHEN Leave_Assign_As IN ('First Half', 'Second Half') 
										THEN 
											CASE WHEN Leave_Assign_As = 'First Half'
											THEN Leave_Code + '-HF-P' 
											ELSE 'P-HF-' + Leave_Code
											END
										ELSE 
											CASE WHEN Leave_Assign_As = 'Part Day'
											THEN Leave_Code + '-Part_LT-P'
											ELSE Leave_Code
											END 
										END 
									END 
								ELSE 
									CASE WHEN ho1.Is_Fix IS NOT NULL OR ho2.Is_Fix IS NOT NULL OR ho3.Is_Fix IS NOT NULL 
									THEN 'HO' 
									ELSE 
										CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5)))  OR wo1.test1 = wr.for_date 
										THEN 
											CASE WHEN Week_Day = weekoff2 or Week_Day = Alt_Weekoff_Day OR wo1.test1 = wr.for_date 
											THEN 'W_C'
											ELSE 'W'
											END 
										ELSE 
											CASE WHEN isnull(Calculate_Days, 0) < 1 AND isnull(Calculate_Days, 0) > 0 
											THEN 
												CASE WHEN CHARINDEX(DATENAME(dw, wo1.test1), hf_week_day) > 0 
												THEN 
													CASE WHEN wo1.Is_Split_Shift = 1 
													THEN 'S' 
													ELSE 
														CASE WHEN wo1.Is_Training_Shift = 1 
														THEN 'T' 
														ELSE 'P' 
														END 
													END 
												ELSE 'HF' 
												END 
											ELSE 
												CASE WHEN wo1.Is_Split_Shift <> 0 
												THEN 
													CASE WHEN Calculate_Days IS NULL AND ISNULL(Present_Hours, 0) < 5 
													THEN 'A' 
													ELSE 
														CASE WHEN IS_Training_Shift = 1 
														THEN 'T' 
														ELSE 'S' 
														END 
													END 
												ELSE 
													CASE WHEN Calculate_Days IS NULL AND ISNULL(Present_Hours, 0) < 5 
													THEN 'A' 
													ELSE 
														CASE WHEN IS_Training_Shift = 1 
														THEN 'T' 
														ELSE Presence 
														END 
													END 
												END 
											END 
										END 
									END 
								END 
							END 
						  END AS Presence, 
						  case when wo1.leave_assign_as='First Half' then 0 else wo1.Late_Count end as late_count, 
						  case when wo1.leave_assign_as='Second Half' then 0 else wo1.actual_Early_Sec end as actual_Early_Sec ,
						  case when wo1.leave_assign_as='First Half' then 0 else wo1.actual_late_Sec end as actual_late_Sec, 
						  wo1.Emp_Late_mark, 
						  wo1.Emp_Early_mark, 
						  wo1.Is_Late_Mark, 
						  dbo.F_Return_Sec(REPLACE(CAST(shift_Detail1.To_Hour AS varchar(MAX)), '.', ':')) as from_hour, 
						  wo1.Present_Hours * 3600 AS Present_Sec,
						  wo1.Early_Count, 
						  Early_in_Sec,
						  Late_Out_Sec,
						  Act_In_Time,Act_Out_Time,weekoff_as_leave,Holiday_As_leave,Calculate_Days,isnull(Leave_Used,0) as Leave_Used,isnull(Un_Leave_Used,0) as Un_Leave_Used,
						  CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5)))  OR wo1.test1 = isnull(wr.for_date,@from_date) 
										THEN gs.Tras_Week_ot ELSE 2 END as Tras_Week_ot
	INTO            [#weekoff_get2_temp]
	FROM         (SELECT     Cmp_ID, emp_id, branch_id, Increment_ID, id, Extra_AB_Deduction, test1, Week_Day, Week_Count, Can_Weekoff, leaveStatus, Weekoff_as_leave, 
							Holiday_as_leave, Leave_Assign_As, weekoff, weekoff2, CASE WHEN shift_ID_Temp IS NULL 
							THEN shift_ID_Per ELSE shift_ID_Temp END AS shift_ID_Per, NULL AS shift_ID_Temp, Leave_Code, Present_Hours, Presence, Alt_Weekoff_Day, 
							Count1, Count2, Count3, Count4, Count5, left_date, join_date, Chk_By_Superior, Half_Full_day, Is_Split_Shift, Is_Night_Shift, Early_Count, Late_Count, 
														Act_In_Time,Act_Out_Time,Leave_Used,Un_Leave_Used,
														actual_Early_Sec, actual_late_Sec, Emp_Late_mark, Emp_Early_mark, Is_Late_Mark, Is_Training_Shift,Early_in_Sec,Late_Out_Sec
						   FROM          [#weekoff_get1_temp]) AS wo1 LEFT OUTER JOIN
							  (SELECT     Hday_ID, cmp_Id, Hday_Name, H_From_Date, H_To_Date, Is_Fix, Hday_Ot_setting, Branch_ID, Is_Half, Is_P_Comp, Message_Text, Sms, 
													   No_Of_Holiday, System_Date, is_National_Holiday, Is_Optional
								FROM          T0040_HOLIDAY_MASTER WITH (NOLOCK) 
								WHERE      /*(H_From_Date BETWEEN @from_date AND @to_date) AND*/ (Is_Fix = 'Y') AND (ISNULL(Is_Optional, 0) = 0)) AS ho1 ON wo1.Cmp_ID = ho1.cmp_Id AND 
						  wo1.branch_id = ISNULL(ho1.Branch_ID, wo1.branch_id) AND MONTH(wo1.test1) >= MONTH(ho1.H_From_Date) AND DAY(wo1.test1) >= DAY(ho1.H_From_Date) AND 
						  MONTH(wo1.test1) <= MONTH(ho1.H_To_Date) AND DAY(wo1.test1) <= DAY(ho1.H_To_Date) LEFT OUTER JOIN
							  (SELECT     Hday_ID, cmp_Id, Hday_Name, H_From_Date, H_To_Date, Is_Fix, Hday_Ot_setting, Branch_ID, Is_Half, Is_P_Comp, Message_Text, Sms, 
													   No_Of_Holiday, System_Date, is_National_Holiday, Is_Optional
								FROM          T0040_HOLIDAY_MASTER AS T0040_HOLIDAY_MASTER_1 WITH (NOLOCK) 
								WHERE      (H_From_Date BETWEEN @from_date AND @to_date) AND (Is_Fix = 'N') AND (ISNULL(Is_Optional, 0) = 0)) AS ho2 ON wo1.Cmp_ID = ho2.cmp_Id AND 
						  wo1.branch_id = ISNULL(ho2.Branch_ID, wo1.branch_id) AND wo1.test1 >= ho2.H_From_Date AND wo1.test1 <= ho2.H_To_Date LEFT OUTER JOIN
							  (SELECT     hm.Hday_ID, hm.cmp_Id, hm.Hday_Name, hm.H_From_Date, hm.H_To_Date, hm.Is_Fix, hm.Hday_Ot_setting, hm.Branch_ID, hm.Is_Half, 
													   hm.Is_P_Comp, hm.Message_Text, hm.Sms, hm.No_Of_Holiday, hm.System_Date, hm.is_National_Holiday, hm.Is_Optional, ha.Emp_ID
								FROM          T0040_HOLIDAY_MASTER AS hm  WITH (NOLOCK) INNER JOIN
													   T0120_Op_Holiday_Approval AS ha ON hm.Hday_ID = ha.HDay_ID AND hm.cmp_Id = ha.Cmp_ID
								WHERE      (hm.Is_Optional = '1') AND (ha.Op_Holiday_Apr_Status = 'A')) AS ho3 ON wo1.Cmp_ID = ho3.cmp_Id AND wo1.emp_id = ho3.Emp_ID AND 
						  wo1.test1 = ho3.H_From_Date AND wo1.test1 = ho3.H_To_Date LEFT OUTER JOIN
							  (SELECT     esd.Emp_ID, esd.Cmp_ID, esd.Shift_ID, esd.Eff_Date_Sd, sd.From_Hour, sd.To_Hour, sd.Calculate_Days, esd.Is_Split_Shift, 
													   esd.Week_Day AS hf_week_day, esd.Half_Dur
								FROM          [#v_shift_detail_temp] AS esd INNER JOIN
													   T0050_SHIFT_DETAIL AS sd WITH (NOLOCK)  ON sd.Cmp_ID = esd.Cmp_ID AND esd.Shift_ID = sd.Shift_ID
								WHERE      (esd.Eff_Date_Sd BETWEEN @from_date AND @to_date)) AS shift_Detail1 ON wo1.emp_id = shift_Detail1.Emp_ID AND 
						  wo1.Cmp_ID = shift_Detail1.Cmp_ID 
						  AND 
						  dbo.F_Return_Sec(REPLACE(CAST(wo1.Present_Hours AS varchar(MAX)), '.', ':')) >= dbo.F_Return_Sec(REPLACE(CAST(shift_Detail1.From_Hour AS varchar(MAX)), '.', ':')) 
						  AND dbo.F_Return_Sec(REPLACE(CAST(wo1.Present_Hours AS varchar(MAX)), '.', ':')) <= dbo.F_Return_Sec(REPLACE(CAST(shift_Detail1.To_Hour AS varchar(MAX)), '.', ':')) 
						  AND wo1.test1 >= shift_Detail1.Eff_Date_Sd AND (wo1.shift_ID_Per = shift_Detail1.Shift_ID OR wo1.shift_ID_Temp = shift_Detail1.Shift_ID)	
						  left outer join T0100_WEEKOFF_ROSTER as wr  WITH (NOLOCK) on wo1.Emp_ID = wr.Emp_ID and wo1.Cmp_ID = wr.Cmp_ID and wo1.test1 = wr.For_Date
						  inner join T0040_GENERAL_SETTING gs WITH (NOLOCK)  on gs.Branch_ID = wo1.branch_id

	--Added by Hardik 21/07/2014
	Update [#weekoff_get2_temp] Set Presence = '-' Where test1 > GETDATE() And Leave_Used = 0 and Un_Leave_Used = 0


	
	Update #weekoff_get2_temp
	set Presence = 'P_W'
	where Tras_Week_ot = 0
	and Calculate_Days = 1
	
	declare @Emp_ID_PL as numeric
	declare @Emp_ID_Temp_PL as numeric
	declare @Presence_PL as varchar(max)
	declare @For_Date_PL as datetime
	declare @For_Date_Temp_PL as Datetime
	declare @Presence_Temp_PL as varchar(max)
	--declare @Count1 as numeric
	declare @Leave_PL as varchar(max)
	declare @Leave_Temp_PL as varchar(max)
	Declare @Row_Number as numeric
	
	declare Partday Cursor for
		select Emp_ID, Presence, test1 from #weekoff_get2_temp
		where presence like '%-Part_LT-A' or presence like '%-Part_LT-P'
		order by test1
	Open Partday
	fetch next from Partday into @Emp_ID_PL,@Presence_PL,@For_Date_PL
	while @@Fetch_Status = 0
	begin
		if isnull(@Emp_ID_Temp_PL,0)=@Emp_ID_PL and @For_Date_Temp_PL = @For_Date_PL
		begin
			delete #Weekoff_Get2_Temp
			where Emp_ID = @Emp_ID_PL and Presence = @Presence_PL and test1 = @For_Date_PL
		end
		else
		begin
			select @Count1 = count(*) from #weekoff_get2_temp
				where (presence like '%-Part_LT-A' or presence like '%-Part_LT-P')
				and emp_id = @Emp_ID_PL and test1 = @For_Date_PL
			
			if @Count1>1
			begin
				set @Leave_PL = ''
				declare partday1 cursor for
					select presence from #Weekoff_Get2_temp
					where (presence like '%-Part_LT-A' or presence like '%-Part_LT-P')
					and Emp_ID = @Emp_ID_PL and test1 = @For_Date_PL
				open partday1
				fetch next from partday1 into @Leave_Temp_PL
				while @@Fetch_Status = 0
				begin
					set @Leave_PL = @Leave_PL  + left(@Leave_Temp_PL,charindex('-',@Leave_Temp_PL)-1) + '-'
					fetch next from partday1 into @Leave_Temp_PL
				end
				close partday1
				deallocate partday1
				
				set @Leave_PL = left(@leave_PL,len(@Leave_PL)-1)
				
				update #weekoff_get2_temp
				set presence = @Leave_PL
				where presence = @Presence_PL and Emp_ID = @Emp_ID_PL and test1 = @For_Date_PL
			end	
			else
			begin
				if @Presence_PL like '%-Part_LT-A' or @Presence_PL like '%-Part_LT-P'
				begin
					update #Weekoff_get2_Temp
					set presence = replace(@Presence_PL,'Part_LT','HF')
					where presence = @Presence_PL and Emp_ID = @Emp_ID_PL and test1 = @For_Date_PL	
				end
			end
		end
		
		set @Emp_ID_Temp_PL = @Emp_ID_PL
		set @For_Date_Temp_PL = @For_Date_PL
		
		fetch next from Partday into @Emp_ID_PL,@Presence_PL,@For_Date_PL
	end
	close partday
	deallocate partday
		
	/* #weekoff_get3_temp is table created to adhere sandwich policy.
	Here we have taken a sub query where Last presence, Next presence,

	Last Absence and Next Absence is been generated.
	the date difference forms the sandwich policy calculations.
	*/

	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_get3_temp' and type = 'u')
	begin
		drop table #weekoff_get3_temp
	end
	
	CREATE table #weekoff_get3_temp
	(
		Cmp_ID numeric,
		Emp_ID numeric,
		Branch_ID numeric,
		Increment_ID numeric,
		Extra_AB_Deduction numeric(18,1),
		Shift_ID_Per numeric,
		ID varchar(max),
		test1 datetime,
		In_Time time,
		Out_Time time,
		diff_Lt_p numeric,
		diff_Lt_A numeric,
		diff_Nt_p numeric,
		diff_Nt_A numeric,
		Week_Day varchar(max),
		presence varchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Cancel_Weekoff numeric,
		Cancel_Holiday numeric,
		lt_Presence datetime,
		nt_Presence datetime,
		lt_Abs datetime,
		nt_Abs datetime,
		Early_Count numeric,
		Late_Count numeric,
		Actual_Early_Sec numeric,
		Actual_Late_Sec numeric,
		Emp_Late_mark numeric,
		Emp_Early_mark numeric,
		Is_Late_Mark numeric,
		Early_in_Sec numeric,
		Late_Out_Sec numeric,
		present_sec numeric,
		weekoff_as_leave numeric,
		holiday_as_leave numeric,
		Leave_Used numeric(18,2),
		Un_Leave_Used numeric(18,2)
	)
	
	--select * from #weekoff_get2_temp
	
	INSERT INTO [#weekoff_get3_temp]
	SELECT     distinct Cmp_ID, emp_id, branch_id, increment_id, Extra_AB_Deduction, shift_ID_Per, id, test1,Act_In_Time,Act_Out_Time, DATEDIFF(D, lt_Presence, test1) AS diff_Lt_p, DATEDIFF(D, lt_Abs, test1) 
						  AS diff_Lt_A, DATEDIFF(d, test1, nt_Presence) AS diff_Nt_p, DATEDIFF(d, test1, nt_Abs) AS diff_Nt_A, Week_Day, 
						  CASE WHEN presence = 'W' THEN CASE WHEN Is_Cancel_Weekoff = 0 THEN 'W' ELSE CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) THEN 'W' ELSE 'A' END END ELSE CASE WHEN presence = 'HO' THEN CASE WHEN Is_Cancel_Holiday = 0 THEN 'HO' ELSE CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) THEN 'HO' ELSE 'A' END END ELSE Presence END END AS presence, 
						  CASE WHEN presence = 'W' THEN CASE WHEN Is_Cancel_Weekoff = 0 THEN 0 ELSE CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) THEN 0 ELSE 1 END END ELSE 0 END AS Cancel_Weekoff, 
						  CASE WHEN presence = 'W' THEN CASE WHEN Is_Cancel_Weekoff = 0 THEN 0 ELSE CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) THEN 0 ELSE 0 END END ELSE CASE WHEN presence = 'HO' THEN CASE WHEN Is_Cancel_Holiday = 0 THEN 0 ELSE CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) THEN 0 ELSE 1 END END ELSE 0 END END AS Cancel_Holiday, 
						  lt_Presence, nt_Presence, lt_Abs, nt_Abs, 
						  case when (Is_Early_Calc_On_HO_WO = 0 and (presence = 'W' or presence = 'HO')) then 0 else Early_Count end as Early_Count, 
						  case when (Is_Late_Calc_On_HO_WO = 0 and (presence = 'W' or presence = 'HO')) then 0 else Late_Count end as Late_Count , 
						  case when (Is_Early_Calc_On_HO_WO = 0 and (presence = 'W' or presence = 'HO')) then 0 else Actual_Early_Sec end as Actual_Early_Sec, 
						  case when (Is_Late_Calc_On_HO_WO = 0 and (presence = 'W' or presence = 'HO')) then 0 else Actual_Late_Sec end as Actual_Late_Sec , 
						  Emp_Late_mark, Emp_Early_mark, Is_Late_Mark, Early_In_Sec, Late_Out_Sec,present_sec,weekoff_as_leave,holiday_as_leave,Leave_Used,Un_Leave_Used
	FROM         (SELECT     wo3.Cmp_ID, wo3.emp_id, wo3.branch_id, increment_id, shift_ID_Per, Extra_AB_Deduction, wo3.id, wo3.test1, wo3.Week_Day, wo3.Presence, wo3.weekoff_as_leave,wo3.holiday_as_leave,
												  ISNULL
													  ((SELECT     MAX(test1) AS Expr1
														  FROM         [#weekoff_get2_temp] AS wo2
														  WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (Presence IN ('P', 'S','W_C','P_W', 'T', CASE WHEN Is_Cancel_Holiday = 0 THEN 'HO' END, 
																				CASE WHEN Is_Cancel_Weekoff = 0 THEN 'W' END)) AND (test1 < wo3.test1) OR
																				(emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CASE WHEN right(presence,2) = '-P' 
																				THEN LEFT(Presence, charindex('-', presence) - 1) ELSE CASE WHEN LEFT(presence,2)='P-' THEN RIGHT(presence,len(presence)-charindex('HF-',Presence)-3) ELSE Presence END END IN
																					(SELECT DISTINCT Leave_Code FROM [#weekoff_get_LM_Temp] where Weekoff_as_leave = 0)) /*OR
																				(emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('LWP', Presence) <> 0) OR
																				(emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('-HF-A', Presence) <> 0)*/), DATEADD(d, 
												  - 52, wo3.test1)) AS lt_Presence, ISNULL
													  ((SELECT     MIN(test1) AS Expr1
														  FROM         [#weekoff_get2_temp] AS wo2
														  WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (Presence IN ('P', 'S','W_C','P_W', 'T', CASE WHEN Is_Cancel_Holiday = 0 THEN 'HO' END, 
																				CASE WHEN Is_Cancel_Weekoff = 0 THEN 'W' END)) AND (test1 > wo3.test1) OR
																				(emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 > wo3.test1) AND (CASE WHEN right(presence,2) = '-P' 
																				THEN LEFT(Presence, charindex('-', presence) - 1) ELSE CASE WHEN LEFT(presence,2)='P-' THEN RIGHT(presence,len(presence)-charindex('HF-',Presence)-3) ELSE Presence END END IN
																					(SELECT DISTINCT Leave_Code FROM [#weekoff_get_LM_Temp] where Weekoff_as_leave = 0))), DATEADD(d, 52, wo3.test1)) AS nt_Presence, 
												ISNULL
													  ((SELECT     MAX(test1) AS Expr1
														  FROM         [#weekoff_get2_temp] AS wo2
														  WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND ((Presence IN ('A', 'LWP', CASE WHEN Is_Cancel_Holiday = 1 THEN 'HO' END, 
																				CASE WHEN Is_Cancel_Weekoff = 1 THEN 'W' END))  OR
																				(CASE WHEN right(presence,2) = '-A' THEN LEFT(Presence, charindex('-', presence) - 1) ELSE CASE WHEN LEFT(presence,2)='A-' THEN RIGHT(presence,len(presence)-charindex('HF-',Presence)-3) ELSE Presence END END IN
																					(SELECT DISTINCT Leave_Code FROM [#weekoff_get_LM_Temp] where Weekoff_as_leave = 1))) /*OR
																				(emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('LWP', Presence) <> 0) OR
																				(emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('-HF-A', Presence) <> 0)*/), DATEADD(d, 
												  - 52, wo3.test1)) AS lt_Abs, ISNULL
													  ((SELECT     MIN(test1) AS Expr1
														  FROM         [#weekoff_get2_temp] AS wo2
														  WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (Presence IN ('A', 'LWP', CASE WHEN Is_Cancel_Holiday = 1 THEN 'HO' END, 
																				CASE WHEN Is_Cancel_Weekoff = 1 THEN 'W' END)) AND (test1 > wo3.test1)  OR
																				(emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 > wo3.test1) AND (CASE WHEN right(presence,2) = '-A' 
																				THEN LEFT(Presence, charindex('-', presence) - 1) ELSE CASE WHEN LEFT(presence,2)='A-' THEN RIGHT(presence,len(presence)-charindex('HF-',Presence)-3) ELSE Presence END END IN
																					(SELECT DISTINCT Leave_Code FROM [#weekoff_get_LM_Temp] where Weekoff_as_leave = 1))), DATEADD(d, 
												  52, wo3.test1)) AS nt_Abs, 
												  gs.Is_Cancel_Holiday, gs.Is_Cancel_Weekoff, wo3.Early_Count, wo3.Late_Count, 
												  CASE WHEN wo3.actual_Early_Sec > 0 THEN wo3.actual_Early_Sec ELSE 0 END AS Actual_Early_Sec, 
												  CASE WHEN wo3.actual_late_Sec > 0 THEN wo3.actual_late_Sec ELSE 0 END AS Actual_Late_Sec, Emp_Late_mark, Emp_Early_mark, wo3.Is_Late_Mark, 
												  CASE WHEN wo3.Early_in_Sec > 0 THEN wo3.Early_in_Sec ELSE 0 END AS Early_In_Sec, 
												  CASE WHEN wo3.Late_Out_Sec > 0 THEN wo3.Late_Out_Sec ELSE 0 END AS Late_Out_Sec, Act_In_Time, Act_Out_Time,present_sec,leave_Used,Un_Leave_Used,gs.Is_Late_Calc_On_HO_WO,gs.Is_Early_Calc_On_HO_WO
						   FROM          [#weekoff_get2_temp] AS wo3 INNER JOIN
												  T0040_GENERAL_SETTING AS gs WITH (NOLOCK)  ON wo3.Cmp_ID = gs.Cmp_ID AND wo3.branch_id = gs.Branch_ID) AS t1
	WHERE     (test1 BETWEEN DATEADD(d, 10, @from_date) AND DATEADD(d, - 10, @to_date))
	
	
--	select * from #weekoff_get3_temp
	declare @e5 as numeric,
			--@test1 as datetime,
			@presence as varchar(max),
			@weekoff_as_leave as numeric,
			@holiday_as_leave as numeric,
			@leave_code as varchar(max),
			@id as varchar(max),
			@id_temp as varchar(max),
			@presence_temp as varchar(max),
			@temp as varchar(max)
	
	declare leave_cur cursor for
	select emp_id, test1,presence,weekoff_as_leave, holiday_as_leave from #weekoff_get3_temp
	order by test1
	open leave_cur
	fetch next from leave_cur into @e5,@test1,@presence,@weekoff_as_leave,@holiday_as_leave
	while @@fetch_status = 0
	begin
		if @presence = 'W' or @presence='W_C'
		begin
			select @weekoff_as_leave = weekoff_as_leave,@leave_code = presence from #weekoff_get3_temp
			where emp_id = @e5 and test1 = dateadd(d,-1,@test1)
		
			if @weekoff_as_leave = 1 and charindex('-',@leave_code) = 0 
			begin
				select @weekoff_as_leave = weekoff_as_leave,@leave_code = presence from #weekoff_get3_temp
				where emp_id = @e5 and test1 = dateadd(d,1,@test1)
			
				if @weekoff_as_leave = 1 and charindex('-',@leave_code) = 0 
				begin
					update #weekoff_get3_temp
					set presence = 'A'
					where emp_id = @e5
					and test1 = @test1
				end
			end
		end
	
		if @presence = 'HO'
		begin
			select @holiday_as_leave = holiday_as_leave from #weekoff_get3_temp
			where emp_id = @e5 and test1 = dateadd(d,-1,@test1)
		
			if @holiday_as_leave = 1
			begin
				select @holiday_as_leave = holiday_as_leave from #weekoff_get3_temp
				where emp_id = @e5 and test1 = dateadd(d,1,@test1)
			
				if @holiday_as_leave = 1
				begin
					update #weekoff_get3_temp
					set presence = 'A'
					where emp_id = @e5
					and test1 = @test1
				end
			end
		end
		fetch next from leave_cur into @e5,@test1,@presence,@weekoff_as_leave,@holiday_as_leave
	end
	close leave_cur
	deallocate leave_cur


	/* Total Counting of various combinations are been done in this column */


	SELECT     Emp_ID, Cmp_ID, Leave_Code, SUM(cast(Leave_Count as decimal(18,2))) AS Leave_Count into #Leave_Count
	FROM         (SELECT     lm.Leave_Code AS Leave_Code, leave_Used + Un_Leave_Used as Leave_Count,lm.Leave_Sorting_No, wo1.*
						   FROM          [#weekoff_get3_temp] AS wo1 INNER JOIN
												  T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  ON (presence COLLATE SQL_Latin1_General_CP1_CI_AS = lm.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS OR
												  CASE WHEN RIGHT(presence,2) in ('-P','-A') 
												  THEN LEFT(presence, charindex('-', presence) - 1) 
												  ELSE 
													CASE WHEN LEFT(presence,2) IN ('P-','A-') 
													THEN RIGHT(presence,LEN(presence) - Charindex('-HF',presence)-3)
												  ELSE presence COLLATE SQL_Latin1_General_CP1_CI_AS END END = lm.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS) AND 
												  wo1.cmp_id = lm.Cmp_ID) AS a
	GROUP BY Emp_ID, Cmp_ID, Leave_Code,Leave_Sorting_No
	order by a.Leave_Sorting_No
	
	
	
	DECLARE @colspivot_leave as varchar(max) ,
			@colspivot_leave1 as varchar(max) ,
			@query_leave as varchar(max) 
	
		SET	@colspivot_leave  = ''
		SET	@colspivot_leave1  = ''
		SET	@query_leave  = ''
			
	select @colsPivot_leave = STUFF((SELECT ',' + QUOTENAME(cast(Leave_Code as varchar(max))) 
								from #leave_Count as a
								cross apply ( select 'Leave_Code' col, 1 so ) c 
								group by col,a.Leave_Code,so 
								order by so 
						FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

	select @colsPivot_leave1 = STUFF((SELECT ',isnull(' + QUOTENAME(cast(Leave_Code as varchar(max))) + ',0) as ' + QUOTENAME(cast(Leave_Code as varchar(max)))
								from #leave_Count as a
								cross apply ( select 'Leave_Code' col, 1 so ) c 
								group by col,a.Leave_Code,so 
								order by so 
						FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

	
	if exists (select 1 from sysobjects where name = 'leave_count_pivot' and type = 'u')
		drop table leave_count_pivot
	
	if exists (select 1 from #leave_count)
	begin
	set @query_leave = 'select Emp_id,cmp_id, '+@colsPivot_leave+' into Leave_Count_Pivot
		from (select Emp_ID,Cmp_ID,Leave_Code, Leave_Count from #leave_Count) 
		as data pivot 
		( sum(Leave_Count) 
		for Leave_Code in ('+ @colsPivot_leave +') ) p' 

	
	exec (@query_leave)
	end
	else
	begin
		select distinct Emp_ID,Cmp_ID,0 as TL into leave_count_pivot from #weekoff_get3_temp
	end
	select * into #leave_count_pivot from leave_count_pivot
	
	drop table leave_Count_pivot

	

	declare multi_leave cursor for
		select Emp_ID,id,presence from #weekoff_get3_temp
	open multi_leave
	fetch next from multi_leave into @e5,@id,@presence
	while @@FETCH_STATUS=0
	begin
		if @id = ISNULL(@id_temp,'')
		begin
			if LEFT(@presence_temp,2) in ('A-','P-')
			begin
				set @temp = RIGHT(@presence_temp,LEN(@presence_temp)-CHARINDEX('HF-',@presence_temp)-2)
				set @presence = left(@presence,charindex('-HF',@presence) + 3) + @temp
				update #weekoff_get3_temp 
				set presence = @presence 
				where ID = @id
				and Emp_ID = @e5
			end
			else
			begin
				set @temp = Left(@presence_temp,CHARINDEX('-',@presence_temp))
				set @presence = @temp + right(@presence,charindex(@presence,'-HF'))
				update #weekoff_get3_temp 
				set presence = @presence 
				where ID = @id
				and Emp_ID = @e5
			end
		end
		
		set @id_temp = @id
		set @presence_temp = @presence
		fetch next from multi_leave into @e5,@id,@presence
	end
	close multi_leave
	deallocate multi_leave


	
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#total_count' and type = 'u')
	begin
		drop table #total_count
	end
	
	SELECT     Cmp_ID, emp_id, branch_id, SUM(CASE WHEN isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) IN ('P', 'S', 'T') THEN 1 ELSE CASE WHEN isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) IN ('HF', 'FH', 'SH') THEN 0.5 ELSE CASE WHEN left(presence COLLATE SQL_Latin1_General_CP1_CI_AS,2)='P-' or right(presence COLLATE SQL_Latin1_General_CP1_CI_AS,2) = '-P' Then 1 - Leave_Used ELSE 0 END END END) AS P, 
						  SUM(CASE WHEN isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) IN ('A') THEN 1 ELSE CASE WHEN isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) IN ('FH', 'SH', 'HF') THEN 0.5 ELSE CASE WHEN left(presence COLLATE SQL_Latin1_General_CP1_CI_AS,2)='A-' or right(presence COLLATE SQL_Latin1_General_CP1_CI_AS,2) = '-A' Then 1 - (Leave_Used + Un_Leave_Used) ELSE 0 END END END) AS A, 
						  SUM(case when charindex('PD',presence COLLATE SQL_Latin1_General_CP1_CI_AS)>0 then leave_Used else 0 end) as L,
						  SUM(CASE WHEN isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) IN ('W','W_C','P_W') OR isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) = 'COM-W' THEN 1 ELSE 0 END) AS W, 
						  SUM(CASE WHEN isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) = 'HO' OR isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) = 'COM-HO' THEN 1 ELSE 0 END) AS H, 
						  --SUM(CASE WHEN isnull(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 0) IN ('LWP') THEN 1 ELSE CASE WHEN CHARINDEX('+LWP', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 OR CHARINDEX('LWP+', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 OR CHARINDEX('LWP-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 AND CHARINDEX('-LWP-',presence COLLATE SQL_Latin1_General_CP1_CI_AS) = 0  THEN 0.5 ELSE CASE WHEN CHARINDEX('-LWP-',presence COLLATE SQL_Latin1_General_CP1_CI_AS)>0 THEN CAST(RIGHT(presence COLLATE SQL_Latin1_General_CP1_CI_AS,4) as Decimal(18,2)) ELSE 0 END END END) AS LWP, 
						  SUM(Un_Leave_Used) As LWP,
						  SUM(Cancel_Weekoff) AS Cancel_Weekoff, SUM(Cancel_Holiday) AS Cancel_Holiday, SUM(Early_Count) AS Early_Count, SUM(Late_Count) AS Late_Count,Extra_Ab_Deduction
	INTO            [#total_count1]
	FROM         (SELECT     Cmp_ID, emp_id, branch_id, Extra_AB_Deduction, id, test1, Week_Day, CASE WHEN (presence COLLATE SQL_Latin1_General_CP1_CI_AS IN
                                                  ((SELECT     leave_code
                                                      FROM         #weekoff_get_LM_Temp))) OR
                                              (CHARINDEX('+', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 AND CHARINDEX('LWP', presence COLLATE SQL_Latin1_General_CP1_CI_AS) 
                                              = 0) THEN 'PD' ELSE CASE WHEN CHARINDEX('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) = 0 THEN CASE WHEN CHARINDEX('+', 
                                              presence COLLATE SQL_Latin1_General_CP1_CI_AS) 
                                              = 0 THEN presence COLLATE SQL_Latin1_General_CP1_CI_AS ELSE CASE WHEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 
                                              CHARINDEX('+', presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) IN
                                                  ((SELECT     leave_code
                                                      FROM         #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 
                                              len(presence COLLATE SQL_Latin1_General_CP1_CI_AS) - charindex('+', presence COLLATE SQL_Latin1_General_CP1_CI_AS) + 1) 
                                              ELSE CASE WHEN RIGHT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, len(presence COLLATE SQL_Latin1_General_CP1_CI_AS) - charindex('+', 
                                              presence COLLATE SQL_Latin1_General_CP1_CI_AS) + 1) IN
                                                  ((SELECT     leave_code
                                                      FROM         #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, CHARINDEX('+', 
                                              presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) 
                                              ELSE presence COLLATE SQL_Latin1_General_CP1_CI_AS END END END ELSE CASE WHEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 
                                              CHARINDEX('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) IN
                                                  ((SELECT     leave_code
                                                      FROM         #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 
                                              len(presence COLLATE SQL_Latin1_General_CP1_CI_AS) - charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) + 1) 
                                              ELSE CASE WHEN RIGHT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, len(presence COLLATE SQL_Latin1_General_CP1_CI_AS) - charindex('-', 
    presence COLLATE SQL_Latin1_General_CP1_CI_AS) + 1) IN
                                                  ((SELECT     leave_code
                                                      FROM         #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, CHARINDEX('-', 
                                              presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) ELSE CASE WHEN (charindex('P-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 OR
                                              charindex('A-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0) and CHARINDEX('LWP', presence COLLATE SQL_Latin1_General_CP1_CI_AS) = 0 THEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 6) 
                                              + '-PD' + RIGHT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 5) 
                                              ELSE presence COLLATE SQL_Latin1_General_CP1_CI_AS END END END END END AS presence, Cancel_Holiday, Cancel_Weekoff, Early_Count, Late_Count,Leave_Used,Un_Leave_Used
						   FROM          (SELECT     Cmp_ID, Emp_ID, Branch_ID, Extra_AB_Deduction, ID, test1, Week_Day, MAX([#weekoff_get3_temp].presence COLLATE SQL_Latin1_General_CP1_CI_AS) AS presence, max(Cancel_Weekoff) as Cancel_Weekoff, 
																		  Max(Cancel_Holiday) as Cancel_Holiday, MAX([#weekoff_get3_temp].Early_Count) AS Early_Count, MAX([#weekoff_get3_temp].Late_Count) AS Late_Count, 
																		  MAX([#weekoff_get3_temp].Actual_Early_Sec) AS Actual_Early_Sec, MAX([#weekoff_get3_temp].Actual_Late_Sec) AS Actual_Late_Sec, 
																		  MAX([#weekoff_get3_temp].Emp_Late_mark) AS Emp_Late_mark, MAX([#weekoff_get3_temp].Emp_Early_mark) AS Emp_Early_mark, 
																		  MAX(ISNULL([#weekoff_get3_temp].is_Late_Mark, 0)) AS is_Late_Mark,Sum(Leave_Used) as Leave_Used,sum(Un_Leave_Used) as Un_Leave_Used
												   FROM          [#weekoff_get3_temp]
												   GROUP BY Cmp_ID, Emp_ID, Branch_ID, Extra_AB_Deduction, ID, test1, Week_Day, Cancel_Weekoff, Cancel_Holiday) AS [#weekoff_get3_temp]
						   WHERE      (test1 BETWEEN DATEADD(D, 10, @from_date) AND DATEADD(d, - 10, @to_date))) AS weekoff_Get_Temp
	GROUP BY Cmp_ID, emp_id, branch_id, Extra_AB_Deduction

	
		
	SELECT     Cmp_ID, Emp_ID, Branch_ID, P, A + Case When @Report_For = '' and @Export_Type = '' then LWP else 0 end as A, L, W, H/*, LWP*/, 
						--CASE WHEN P + L + W + H + LWP - A - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) 
						--	  + 0.20 END) < 0 THEN 0 ELSE P + L + W + H + LWP - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) + 0.20 END) 
						--END AS Payable_Present_Days, 
						--CASE WHEN P + L + W + H + LWP - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) 
						--  + 0.20 END) < 0 THEN 0 ELSE P + L + W + H + LWP - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) + 0.20 END) 
						--END AS Total_Days, 

						CASE WHEN P - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) + 0.25 END) < 0 
							THEN 0 ELSE P - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) + 0.25 END) 
						END AS Payable_Present_Days, 
						CASE WHEN P + L + W + H - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) + 0.25 END) < 0 
							THEN 0 ELSE P + L + W + H - (CASE WHEN A * Isnull(Extra_Ab_Deduction,0) % 0.50 = 0 THEN A * Isnull(Extra_Ab_Deduction,0) ELSE (A * Isnull(Extra_Ab_Deduction,0)) + 0.25 END) 
						END AS Total_Days, 
						
						  Cancel_Weekoff, Cancel_Holiday,Late_Count
	INTO            [#total_Count]
	FROM         [#total_count1]



	update #weekoff_get3_temp
	set presence = 'P'
	where presence = 'P_W'
	
	IF @Report_For = '' and @Export_Type = 'EXCEL'
	BEGIN

		/* This section forms the logic of dynamic pivot table columns */
		declare @flag_month as varchar(max) 
		declare @flag_month1 as varchar(max) 
		
		SET @flag_month  = ''
		SET @flag_month1 = ''
		
		select @flag_month = right((select top 1 ID from #weekoff_get3_temp order by test1),4)

		if MONTH(@from_date)<>MONTH(@to_date)
		begin
			select @flag_month1 = right((select top 1 ID from #weekoff_get3_temp order by test1 desc),4)
		end
		else
		begin
			set @flag_month1 = @flag_month
		end
		if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = 'weekoff_get4_temp' and type = 'u')
		begin
			drop table weekoff_get4_temp
		end
		
		DECLARE @colsPivot AS NVARCHAR(MAX),
				@query AS NVARCHAR(MAX)
		
		set @colsPivot = ''
		
		select @colsPivot = STUFF((SELECT ',' + QUOTENAME(cast(id as varchar(10)))
		from #weekoff_get3_temp
		cross apply ( select 'date' col, 1 so ) c
		group by col,test1, id, so
		order by test1, so
		FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')
		
		set @query = 'select Emp_id, '+@colsPivot+' into weekoff_get4_temp
		from ( select emp_id,id, replace(presence,''W_C'',''W'') as presence from #weekoff_get3_temp)
		as data pivot
		( max(presence)
		for id in ('+ @colspivot +') ) p'
		
		exec(@query)
		
		if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = 'weekoff_get5_temp' and type = 'u')
		begin
			drop table weekoff_get5_temp
		end
		/* This query forms the final output by joining PIVOT Table and total count table */
		
		declare @qry as varchar(6000)
		
		set @qry = ''
		
		-----Original
		--set @qry = 'SELECT ROW_NUMBER() OVER (ORDER BY wo3.Emp_Id) As SrNo,EM.Emp_Code,EM.Emp_Full_Name,replace(convert(nvarchar(11),Date_of_Join,106),'' '',''-'') as Date_of_Join,
		--Enroll_No, '+isnull(@colsPivot,'')+', P,A, L,LWP,W,H,Payable_Present_Days,
		--Total_Days into weekoff_get5_temp
		--FROM weekoff_get4_temp as wo3 inner join
		--T0080_EMP_MASTER as EM on wo3.Emp_ID = em.Emp_ID
		--inner join #total_count on wo3.emp_id = #total_count.emp_id
		--order by wo3.Emp_ID '
		-----Original Ends
		
		
		set @qry = 'SELECT ROW_NUMBER() OVER (ORDER BY wo3.Emp_Id) As SrNo,EM.Emp_Code,EM.Emp_Full_Name,replace(convert(nvarchar(11),Date_of_Join,106),'' '',''-'') as Date_of_Join,
					Enroll_No, '+@colsPivot+',P,A,'+isnull(@colspivot_leave,'0 as TL')+' ,W,H,Late_Count as LC,Payable_Present_Days,
					Total_Days into weekoff_get5_temp
					FROM weekoff_get4_temp as wo3 inner join
					T0080_EMP_MASTER as EM WITH (NOLOCK)  on wo3.Emp_ID = em.Emp_ID
					inner join #total_count on wo3.emp_id = #total_count.emp_id
					left outer join #leave_count_pivot as lcp on wo3.emp_id = lcp.emp_id
					 order by wo3.Emp_ID '
		
		exec (@qry)
		
		
		declare @id_1 as varchar(max) 
		declare @qry2 as varchar(max) 
		declare @id_2 as varchar(max) 
		
		SET @id_1  = ''
		SET @qry2  = ''
		SET @id_2  = ''
		
		declare id_Ren cursor for
		
		select distinct id from #weekoff_get3_temp
		open id_Ren
		fetch next from id_Ren into @id_1
		
		while @@fetch_status = 0
		begin
			set @qry2 = 'weekoff_get5_temp.' + @id_1
			if CHARINDEX(@flag_month,@id_1)>0
			begin
				set @id_2 = REPLACE(@id_1,@flag_month,'')
			end
			else
			begin
				set @id_2 = REPLACE(@id_1,@flag_month1,'')
			end
			EXEC sp_rename
			@objname = @qry2,
			@newname = @id_2,
			@objtype = 'COLUMN'
			fetch next from id_Ren into @id_1
		end
		close id_Ren
		deallocate id_Ren
		if @Report_For = ''
		begin
		
			select * from weekoff_get5_temp
		End
		else if @Report_For = 'T'
		begin
			SELECT     Cmp_ID, emp_id, branch_id, DATEADD(d, 10, @from_date) AS From_date, DATEADD(d, - 10, @to_date) AS To_date, CAST(P AS decimal(18, 1)) AS P, 
								  CAST(A AS decimal(18, 1)) AS A, CAST(L AS decimal(18, 1)) AS L, CAST(W AS decimal(18, 1)) AS W, 0 AS Comp, CAST(H AS decimal(18, 1)) AS H, 
								  CAST(LWP AS decimal(18, 1)) AS LWP, CAST(Payable_Present_Days AS decimal(18, 1)) AS Payable_Present_Days, CAST(Total_Days AS decimal(18, 1)) 
								  AS Total_Days
			FROM         [#total_count]		
		end
				
		drop table weekoff_get4_temp
		drop table weekoff_get5_temp
		drop table #total_count
	END
	else if (@Report_For = 'Absent' and @Export_Type <> 'EXCEL') or (@Report_For = 'Absent_Summary' and @Export_Type = 'FNF')
		begin
			If @Report_For = 'Absent_Summary' and @Export_Type = 'FNF'  -- Added condition by Hardik 10/07/2014 for FNF, Short fall days
				Begin
					SELECT     wo1.Emp_ID, wo1.Cmp_ID, test1 AS For_Date, CASE WHEN CHARINDEX('COM-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 THEN 'P' ELSE presence COLLATE SQL_Latin1_General_CP1_CI_AS END AS Status, 
									  CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('A') 
									  THEN 1 ELSE CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%HF-A' THEN 0.5 ELSE 0 END END AS A_Days, em1.Emp_Code, 
									  em2.Emp_Full_Name
					FROM         [#weekoff_get3_temp] AS wo1 INNER JOIN
										  [#V_Emp_Get_Info] AS em1 WITH (NOLOCK)  ON wo1.Emp_ID = em1.Emp_ID AND wo1.Cmp_ID = em1.Cmp_ID INNER JOIN
										  T0080_EMP_MASTER AS em2 WITH (NOLOCK)  ON wo1.Emp_ID = em2.Emp_ID AND em2.Cmp_ID = wo1.Cmp_ID INNER JOIN
										  T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON wo1.Branch_ID = bm.Branch_ID AND wo1.Cmp_ID = bm.Cmp_ID INNER JOIN
										  T0010_COMPANY_MASTER AS cm WITH (NOLOCK)  ON wo1.Cmp_ID = cm.Cmp_Id INNER JOIN
										  T0040_DEPARTMENT_MASTER AS dm WITH (NOLOCK)  ON dm.Dept_Id = em1.Dept_ID AND dm.Cmp_Id = em1.Cmp_ID INNER JOIN
										  T0040_GRADE_MASTER AS gm WITH (NOLOCK)  ON em1.Grd_ID = gm.Grd_ID AND em1.Cmp_ID = gm.Cmp_ID INNER JOIN
										  T0040_DESIGNATION_MASTER AS dsm WITH (NOLOCK)  ON em1.Desig_Id = dsm.Desig_ID AND em1.Cmp_ID = dsm.Cmp_ID INNER JOIN
										  T0040_SHIFT_MASTER AS sm WITH (NOLOCK)  ON sm.Shift_ID = wo1.shift_ID_Per AND sm.Cmp_ID = wo1.Cmp_ID
					WHERE     (presence COLLATE SQL_Latin1_General_CP1_CI_AS  IN ('A', 'HF')) OR
										  (presence  COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%HF-A')
					ORDER BY wo1.Emp_ID, For_Date
				End
			Else
				begin
					SELECT     wo1.Emp_ID, wo1.Cmp_ID, test1 AS For_Date, CASE WHEN CHARINDEX('COM-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 THEN 'P' ELSE presence COLLATE SQL_Latin1_General_CP1_CI_AS END AS Status, 
										  CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS = 'PL' THEN 1 ELSE CASE WHEN CASE WHEN charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 THEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) ELSE NULL 
										  END IN
											  (SELECT DISTINCT leave_code
												FROM          #weekoff_get_LM_Temp) THEN 0.5 ELSE NULL END END AS Leave_Count, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('HO', 'COM-HO', 'W', 'COM-W') 
										  THEN CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('HO', 'COM-HO') THEN 'HO' ELSE 'W' END ELSE NULL END AS WO_HO, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS  IN ('COM-HO', 'COM-W') 
										  THEN presence COLLATE SQL_Latin1_General_CP1_CI_AS  ELSE CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS  IN
											  (SELECT DISTINCT leave_code
												FROM          #weekoff_get_LM_Temp) THEN '1' ELSE NULL END END AS Status_2, CAST(LEFT(id, CHARINDEX('-', id) - 1) AS numeric) AS Row_ID, 
										  CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS  IN ('HO', 'COM-HO', 'W', 'COM-W') THEN 1 ELSE 0 END AS WO_HO_Day, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS  IN ('P', 'S', 'T') 
										  THEN 1 ELSE CASE WHEN (presence  COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%HF%' OR
										  CHARINDEX('FH', presence COLLATE SQL_Latin1_General_CP1_CI_AS ) > 0 OR
										  CHARINDEX('SH', presence COLLATE SQL_Latin1_General_CP1_CI_AS ) > 0) AND presence COLLATE SQL_Latin1_General_CP1_CI_AS  NOT LIKE '%HF-A' THEN 0.5 ELSE 0 END END AS P_Days, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS  IN ('A') 
										  THEN 1 ELSE CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS  LIKE '%HF-A' THEN 0.5 ELSE 0 END END AS A_Days, em1.Join_Date, em1.left_date, shift_ID_Per AS Shift_ID, em1.Emp_Code, 
										  em2.Emp_Full_Name, bm.Branch_Address, bm.Comp_Name, bm.Branch_Name, dm.Dept_Name, gm.Grd_Name, dsm.Desig_Name, DATEADD(d, 10, @from_date) 
										  AS P_From_Date, DATEADD(d, - 10, @to_date) AS P_To_Date, wo1.Branch_ID, sm.Shift_Name, cm.Cmp_Name, cm.Cmp_Address
					FROM         [#weekoff_get3_temp] AS wo1 INNER JOIN
										  [#V_Emp_Get_Info] AS em1 WITH (NOLOCK)  ON wo1.Emp_ID = em1.Emp_ID AND wo1.Cmp_ID = em1.Cmp_ID INNER JOIN
										  T0080_EMP_MASTER AS em2 WITH (NOLOCK)  ON wo1.Emp_ID = em2.Emp_ID AND em2.Cmp_ID = wo1.Cmp_ID INNER JOIN
										  T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON wo1.Branch_ID = bm.Branch_ID AND wo1.Cmp_ID = bm.Cmp_ID INNER JOIN
										  T0010_COMPANY_MASTER AS cm WITH (NOLOCK)  ON wo1.Cmp_ID = cm.Cmp_Id INNER JOIN
										  T0040_DEPARTMENT_MASTER AS dm WITH (NOLOCK)  ON dm.Dept_Id = em1.Dept_ID AND dm.Cmp_Id = em1.Cmp_ID INNER JOIN
										  T0040_GRADE_MASTER AS gm WITH (NOLOCK)  ON em1.Grd_ID = gm.Grd_ID AND em1.Cmp_ID = gm.Cmp_ID INNER JOIN
										  T0040_DESIGNATION_MASTER AS dsm WITH (NOLOCK)  ON em1.Desig_Id = dsm.Desig_ID AND em1.Cmp_ID = dsm.Cmp_ID INNER JOIN
										  T0040_SHIFT_MASTER AS sm WITH (NOLOCK)  ON sm.Shift_ID = wo1.shift_ID_Per AND sm.Cmp_ID = wo1.Cmp_ID
					WHERE     (presence COLLATE SQL_Latin1_General_CP1_CI_AS  IN ('A', 'HF')) OR
										  (presence  COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%HF-A')
					ORDER BY wo1.Emp_ID, For_Date
				end
		End
	else if @Report_For = ''
	begin
		
		
		if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#temp_Total' and type = 'u')
		begin
			drop table #temp_Total
		end
		
		declare @temp_Flag as table (for_Date datetime,row_id numeric)
		
		if DATEDIFF(D,@from_Date,@to_date)-19 = 28
		begin
			insert into @temp_Flag
			values
			(@to_date,29)
			insert into @temp_Flag
			values
			(@to_date,30)
			insert into @temp_Flag
			values
			(@to_date,31)
		end
		else if DATEDIFF(D,@from_Date,@to_date)-19 = 29
		begin
			insert into @temp_Flag
			values
			(@to_date,30)
			insert into @temp_Flag
			values
			(@to_date,31)
		end
		else if DATEDIFF(D,@from_Date,@to_date)-19 = 30
		begin
			insert into @temp_Flag
			values
			(@to_date,31)
		end
				
		SELECT     Cmp_ID, branch_id, emp_id, Status, Row_ID
		INTO            #temp_Total
		FROM         (SELECT     Cmp_ID, branch_id, emp_id, cast(P as numeric(18,1)) AS Status, 32 AS Row_ID
							   FROM          [#total_count]
							   UNION
							   SELECT     Cmp_ID, branch_id, emp_id, cast(A as numeric(18,1)) AS Status, 33 AS Row_ID
							   FROM         [#total_count]
							   UNION
							   SELECT     Cmp_ID, branch_id, emp_id, cast(L as numeric(18,1)) AS Status, 34 AS Row_ID
							   FROM         [#total_count]
							   UNION
							   SELECT     Cmp_ID, branch_id, emp_id, cast(W as numeric(18,1)) AS Status, 35 AS Row_ID
							   FROM         [#total_count]
							   UNION
							   SELECT     Cmp_ID, branch_id, emp_id, cast(H as numeric(18,1)) AS Status, 36 AS Row_ID
							   FROM         [#total_count]
							   UNION
							   SELECT     Cmp_ID, branch_id, emp_id, cast(late_count as numeric(18,1)) AS Status, 37 AS Row_ID
							   FROM         [#total_count]) AS a
		
		
		
		SELECT     Emp_ID, Cmp_ID, For_Date, Status, Leave_Count, WO_HO, Status_2, Row_ID, WO_HO_Day, P_Days, A_Days, Join_Date, left_date, Emp_Code, Emp_Full_Name, 
							  Branch_Address, Comp_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name, P_From_Date, P_To_Date, Branch_ID, Leave_Footer
		FROM         (SELECT     wo1.Emp_ID, wo1.Cmp_ID, test1 AS For_Date, CASE WHEN CHARINDEX('COM-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 THEN 'P' ELSE presence END AS Status, 
													  CASE WHEN presence = 'PL' THEN 1 ELSE CASE WHEN CASE WHEN charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 THEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) 
													  ELSE NULL END IN
														  (SELECT DISTINCT leave_code
															FROM          #weekoff_get_LM_Temp) THEN 0.5 ELSE NULL END END AS Leave_Count, CASE WHEN presence IN ('HO', 'COM-HO', 'W', 'COM-W') 
													  THEN CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('HO', 'COM-HO') THEN 'HO' ELSE 'W' END ELSE NULL END AS WO_HO, 
													  case when late_count = 1 then 'LC' else
													  CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('COM-HO', 'COM-W') 
													  THEN presence ELSE CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN
														  (SELECT DISTINCT leave_code
															FROM          #weekoff_get_LM_Temp) THEN '1' ELSE NULL END END end AS Status_2, CAST(LEFT(id, CHARINDEX('-', id) - 1) AS numeric) AS Row_ID, 
													  CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('HO', 'COM-HO', 'W', 'COM-W') THEN 1 ELSE 0 END AS WO_HO_Day, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('P', 'S', 'T') 
													  THEN 1 ELSE CASE WHEN (presence COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%HF%' OR
													  CHARINDEX('FH', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0 OR
													  CHARINDEX('SH', presence COLLATE SQL_Latin1_General_CP1_CI_AS) > 0) AND presence COLLATE SQL_Latin1_General_CP1_CI_AS NOT LIKE '%HF-A' THEN 0.5 ELSE 0 END END AS P_Days, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('A') 
													  THEN 1 ELSE CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%HF-A' THEN 0.5 ELSE 0 END END AS A_Days, em1.Join_Date, em1.left_date, em1.Emp_Code, 
													  CAST(em1.Emp_Code AS varchar(MAX)) + ' - ' + em2.Emp_Full_Name AS Emp_Full_Name, bm.Branch_Address, bm.Comp_Name, bm.Branch_Name, 
													  dm.Dept_Name, gm.Grd_Name, dsm.Desig_Name, DATEADD(d, 10, @from_date) AS P_From_Date, DATEADD(d, - 10, @to_date) AS P_To_Date, 
													  wo1.Branch_ID, @leave_footer AS Leave_Footer
							   FROM          [#weekoff_get3_temp] AS wo1 INNER JOIN
													  [#V_Emp_Get_Info] AS em1 WITH (NOLOCK)  ON wo1.Emp_ID = em1.Emp_ID AND wo1.Cmp_ID = em1.Cmp_ID INNER JOIN
													  T0080_EMP_MASTER AS em2 WITH (NOLOCK)  ON wo1.Emp_ID = em2.Emp_ID AND em2.Cmp_ID = wo1.Cmp_ID INNER JOIN
													  T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON wo1.Branch_ID = bm.Branch_ID AND wo1.Cmp_ID = bm.Cmp_ID INNER JOIN
													  T0010_COMPANY_MASTER AS cm WITH (NOLOCK)  ON wo1.Cmp_ID = cm.Cmp_Id LEFT OUTER JOIN
													  T0040_DEPARTMENT_MASTER AS dm WITH (NOLOCK)  ON dm.Dept_Id = em1.Dept_ID AND dm.Cmp_Id = em1.Cmp_ID INNER JOIN
													  T0040_GRADE_MASTER AS gm WITH (NOLOCK)  ON em1.Grd_ID = gm.Grd_ID AND em1.Cmp_ID = gm.Cmp_ID INNER JOIN
													  T0040_DESIGNATION_MASTER AS dsm WITH (NOLOCK)  ON em1.Desig_Id = dsm.Desig_ID AND em1.Cmp_ID = dsm.Cmp_ID LEFT OUTER JOIN
													  T0040_SHIFT_MASTER AS sm WITH (NOLOCK)  ON sm.Shift_ID = wo1.shift_ID_Per AND sm.Cmp_ID = wo1.Cmp_ID
							   UNION
							   select wo1.Emp_ID,wo1.Cmp_ID,For_Date,null as Status,null as leave_count,null as WO_HO,null as status_2,row_id,0 as wo_ho_day,0 as P_Days,0 as A_Days,
							   Join_Date,null as left_Date,wo1.Emp_Code,cast(wo1.Emp_Code as varchar(max)) + ' - ' + Emp_Full_Name as Emp_Full_Name,Branch_Address, bm.Comp_Name,Branch_Name,
							   null as Dept_Name,null as Grd_Name,Desig_Name,dateadd(d,10,@from_date) as P_From_Date, dateadd(d,-10,@to_date) as P_To_Date,wo1.branch_id,
							   @leave_Footer as Leave_Footer from @temp_flag cross join #v_emp_Get_Info wo1
							   INNER JOIN 
							   T0080_EMP_MASTER AS em2 WITH (NOLOCK)  ON wo1.Emp_ID = em2.Emp_ID AND em2.Cmp_ID = wo1.Cmp_ID INNER JOIN
													 T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON wo1.Branch_ID = bm.Branch_ID AND wo1.Cmp_ID = bm.Cmp_ID INNER JOIN
													 T0010_COMPANY_MASTER AS cm WITH (NOLOCK)  ON wo1.Cmp_ID = cm.Cmp_Id LEFT OUTER JOIN
													 T0040_DEPARTMENT_MASTER AS dm WITH (NOLOCK)  ON dm.Dept_Id = wo1.Dept_ID AND dm.Cmp_Id = wo1.Cmp_ID INNER JOIN
													 T0040_GRADE_MASTER AS gm WITH (NOLOCK)  ON wo1.Grd_ID = gm.Grd_ID AND wo1.Cmp_ID = gm.Cmp_ID INNER JOIN
													 T0040_DESIGNATION_MASTER AS dsm WITH (NOLOCK)  ON wo1.Desig_Id = dsm.Desig_ID AND wo1.Cmp_ID = dsm.Cmp_ID
							   union
							   SELECT     wo1.Emp_ID, wo1.Cmp_ID, @to_Date AS For_Date, CAST(Status AS varchar(MAX)) AS Status, NULL AS Leave_Count, NULL AS WO_HO, NULL AS Status_2, 
													 Row_ID, 0 AS WO_HO_Day, 0 AS P_Days, 0 AS A_Days, em1.Join_Date, em1.left_date, em1.Emp_Code, CAST(em1.Emp_Code AS varchar(MAX)) 
													 + ' - ' + em2.Emp_Full_Name AS Emp_Full_Name, bm.Branch_Address, bm.Comp_Name, bm.Branch_Name, dm.Dept_Name, gm.Grd_Name, 
													 dsm.Desig_Name, DATEADD(d, 10, @from_date) AS P_From_Date, DATEADD(d, - 10, @to_date) AS P_To_Date, wo1.Branch_ID, 
													 @leave_footer AS Leave_Footer
							   FROM         #temp_Total AS wo1 INNER JOIN
													 [#V_Emp_Get_Info] AS em1 WITH (NOLOCK)  ON wo1.Emp_ID = em1.Emp_ID AND wo1.Cmp_ID = em1.Cmp_ID INNER JOIN
													 T0080_EMP_MASTER AS em2 WITH (NOLOCK)  ON wo1.Emp_ID = em2.Emp_ID AND em2.Cmp_ID = wo1.Cmp_ID INNER JOIN
													 T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON wo1.Branch_ID = bm.Branch_ID AND wo1.Cmp_ID = bm.Cmp_ID INNER JOIN
													 T0010_COMPANY_MASTER AS cm WITH (NOLOCK)  ON wo1.Cmp_ID = cm.Cmp_Id LEFT OUTER JOIN
													 T0040_DEPARTMENT_MASTER AS dm WITH (NOLOCK)  ON dm.Dept_Id = em1.Dept_ID AND dm.Cmp_Id = em1.Cmp_ID INNER JOIN
													 T0040_GRADE_MASTER AS gm WITH (NOLOCK)  ON em1.Grd_ID = gm.Grd_ID AND em1.Cmp_ID = gm.Cmp_ID INNER JOIN
													 T0040_DESIGNATION_MASTER AS dsm WITH (NOLOCK)  ON em1.Desig_Id = dsm.Desig_ID AND em1.Cmp_ID = dsm.Cmp_ID) AS a
		ORDER BY Emp_ID, Row_ID
		drop table #temp_Total
		
	end
	else if @Report_For = 'Salary_Report'
	begin
		SELECT     Cmp_ID, emp_id, branch_id, test1 AS For_Date, SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
							  CHARINDEX('-HF-P', Presence) > 0 THEN 0.5 ELSE 0 END END) AS P, SUM(CASE WHEN isnull(Presence, 0) IN ('A') THEN 1 ELSE CASE WHEN isnull(Presence, 0) 
							  IN ('FH', 'SH', 'HF') OR
							  CHARINDEX('-HF-A', Presence) > 0 THEN 0.5 ELSE 0 END END) AS A, SUM(CASE WHEN isnull(Presence, 0) = 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', 
							  Presence) > 0 OR
							  CHARINDEX('PD+', Presence) > 0 THEN 0.5 ELSE 0 END END) AS L, SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
							  isnull(Presence, 0) = 'COM-W' THEN 1 ELSE 0 END) AS W, SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
							  isnull(Presence, 0) = 'COM-HO' THEN 1 ELSE 0 END) AS H, SUM(CASE WHEN isnull(Presence, 0) IN ('LWP') THEN 1 ELSE CASE WHEN CHARINDEX('+LWP', Presence) 
							  > 0 OR
							  CHARINDEX('LWP+', Presence) > 0 OR
							  CHARINDEX('LWP-', Presence) > 0 THEN 0.5 ELSE 0 END END) AS LWP, CASE WHEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
							  THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
							  CHARINDEX('-HF-P', Presence) > 0 THEN 0.5 ELSE 0 END END) - (SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') THEN 1 ELSE CASE WHEN isnull(Presence, 0) 
							  IN ('FH', 'SH', 'HF') OR
							  CHARINDEX('-HF-A', Presence) > 0 OR
							  CHARINDEX('+LWP', Presence) > 0 OR
							  CHARINDEX('LWP+', Presence) > 0 OR
							  CHARINDEX('LWP-', Presence) > 0 THEN 0.5 ELSE 0 END END) * Extra_AB_Deduction) > 0 THEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
							  THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
							  CHARINDEX('-HF-P', Presence) > 0 THEN 0.5 ELSE 0 END END) - (SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') THEN 1 ELSE CASE WHEN isnull(Presence, 0) 
							  IN ('FH', 'SH', 'HF') OR
							  CHARINDEX('-HF-A', Presence) > 0 OR
							  CHARINDEX('+LWP', Presence) > 0 OR
							  CHARINDEX('LWP+', Presence) > 0 OR
							  CHARINDEX('LWP-', Presence) > 0 THEN 0.5 ELSE 0 END END) * Extra_AB_Deduction) ELSE 0 END AS Payable_Present_Days, SUM(CASE WHEN isnull(Presence, 0) 
							  IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
							  CHARINDEX('-HF-P', Presence) > 0 THEN 0.5 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) = 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', Presence) 
							  > 0 OR
							  CHARINDEX('PD+', Presence) > 0 THEN 0.5 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
							  isnull(Presence, 0) = 'COM-W' THEN 1 ELSE 0 END) + SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
							  isnull(Presence, 0) = 'COM-HO' THEN 1 ELSE 0 END) AS Total_Days, SUM(Cancel_Weekoff) AS Cancel_Weekoff, SUM(Cancel_Holiday) AS Cancel_Holiday, 
							  SUM(CASE WHEN Emp_Early_mark > 0 THEN Early_Count ELSE 0 END) AS Early_Count, 
							  SUM(CASE WHEN Is_Late_Mark > 0 THEN CASE WHEN Emp_Late_mark > 0 THEN Late_Count ELSE 0 END ELSE 0 END) AS Late_Count, SUM(Actual_Early_Sec) 
							  AS Actual_Early_Sec, SUM(Actual_Late_Sec) AS Actual_Late_Sec
		FROM         (SELECT     Cmp_ID, emp_id, branch_id, 1 AS Extra_AB_Deduction, id, test1, Week_Day, CASE WHEN (presence IN
														  ((SELECT     leave_code
															  FROM         #weekoff_get_LM_Temp))) OR
													  (CHARINDEX('+', presence) > 0 AND CHARINDEX('LWP', Presence) = 0) THEN 'PD' ELSE CASE WHEN CHARINDEX('-', Presence) 
													  = 0 THEN CASE WHEN CHARINDEX('+', Presence) = 0 THEN Presence ELSE CASE WHEN LEFT(Presence, CHARINDEX('+', presence) - 1) IN
														  ((SELECT     leave_code
															  FROM         #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('+', presence) + 1) ELSE CASE WHEN RIGHT(presence, 
													  len(presence) - charindex('+', presence) + 1) IN
														  ((SELECT     leave_code
															  FROM         #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('+', presence) - 1) 
													  ELSE presence END END END ELSE CASE WHEN LEFT(Presence, CHARINDEX('-', presence) - 1) IN
														  ((SELECT     leave_code
															  FROM         #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('-', presence) + 1) ELSE CASE WHEN RIGHT(presence, 
													  len(presence) - charindex('-', presence) + 1) IN
														  ((SELECT     leave_code
															  FROM         #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('-', presence) - 1) ELSE presence END END END END AS Presence, 
													  Cancel_Holiday, Cancel_Weekoff, Early_Count, Late_Count, Actual_Early_Sec, Actual_Late_Sec, Emp_Late_mark, Emp_Early_mark, Is_Late_Mark
							   FROM          [#weekoff_get3_temp]
							   WHERE      (test1 BETWEEN DATEADD(D, 10, @from_date) AND DATEADD(d, - 10, @to_date))) AS weekoff_Get_Temp
		GROUP BY Cmp_ID, emp_id, branch_id, Extra_AB_Deduction, test1
	end
	else if @Report_For = 'TMS_Emp_In_Out_Record'
	begin
		SELECT     wo1.Emp_ID, wo1.test1 AS for_date, inc.Dept_ID, inc.Grd_ID, inc.Type_ID, inc.Desig_Id, Shift_ID_Per AS Shift_ID, In_Time, Out_Time, 
							  CASE WHEN CASE WHEN In_Time < Out_Time THEN dbo.F_Return_Hours(datediff(SECOND, In_Time, Out_Time)) 
							  ELSE '-' END > shift_dur THEN shift_dur ELSE CASE WHEN In_Time < Out_Time THEN dbo.F_Return_Hours(datediff(SECOND, In_Time, Out_Time)) 
							  ELSE '-' END END AS Duration, CASE WHEN CASE WHEN In_Time < Out_Time THEN datediff(SECOND, In_Time, Out_Time) ELSE 0 END > dbo.F_Return_Sec(shift_dur) 
							  THEN dbo.F_Return_Sec(shift_dur) ELSE CASE WHEN In_Time < Out_Time THEN datediff(SECOND, In_Time, Out_Time) ELSE 0 END END AS Duration_Sec, 
							  dbo.F_Return_Hours(actual_late_sec) AS Late_in, dbo.F_Return_Hours(late_out_sec) AS Late_Out, dbo.F_Return_Hours(Early_in_Sec) AS Early_In, 
							  dbo.F_Return_Hours(actual_early_sec) AS Early_Out, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN
								  (SELECT     *
									FROM          #weekoff_get_LM_Temp) THEN presence ELSE CASE WHEN CHARINDEX('-', presence) > 0 THEN CASE WHEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) 
							  - 1) IN
								  (SELECT     *
									FROM          #weekoff_get_LM_Temp) THEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) ELSE NULL END ELSE NULL END END AS Leave, 
							  dbo.F_Return_Sec(sm.Shift_Dur) AS Shift_Sec, sm.Shift_Dur, CASE WHEN In_Time < Out_Time THEN dbo.F_Return_Hours(datediff(SECOND, In_Time, Out_Time)) 
							  ELSE '00:00' END AS Total_Work, CASE WHEN dbo.F_Return_Sec(Shift_Dur) - datediff(SECOND, In_Time, Out_Time) 
							  > 0 THEN dbo.F_Return_Hours(dbo.F_Return_Sec(Shift_Dur) - datediff(SECOND, In_Time, Out_Time)) ELSE NULL END AS Less_Work, CASE WHEN datediff(SECOND, 
							  In_Time, Out_Time) - dbo.F_Return_Sec(Shift_Dur) > 0 THEN dbo.F_Return_Hours(datediff(SECOND, In_Time, Out_Time) - dbo.F_Return_Sec(Shift_Dur)) ELSE NULL 
							  END AS More_Work, eir.Reason, CASE WHEN presence COLLATE SQL_Latin1_General_CP1_CI_AS IN ('P', 'S', 'T') THEN NULL ELSE CASE WHEN CHARINDEX('-', presence) > 0 THEN LEFT(presence COLLATE SQL_Latin1_General_CP1_CI_AS, 
							  charindex('-', presence COLLATE SQL_Latin1_General_CP1_CI_AS) - 1) ELSE presence COLLATE SQL_Latin1_General_CP1_CI_AS END END AS AB_Leave, actual_late_sec AS Late_in_Sec, late_count AS Late_In_Count, 
							  Actual_Early_Sec AS Early_Out_Sec, Early_Count AS Early_Out_Count, dbo.F_Return_Sec(sm.Shift_Dur) - DATEDIFF(SECOND, In_Time, Out_Time) 
							  AS Total_Less_Work_Sec, sm.Shift_St_Time AS Shift_Start_Datetime, sm.Shift_End_Time AS Shift_en_Datetime, Late_Out_Sec AS Working_Sec_AfterShift, 
							  CASE WHEN Late_Out_Sec > 0 THEN 1 ELSE 0 END AS Working_AfterShift_Count, lad.Leave_Reason, eir.Reason AS Inout_Reason, NULL AS SysDate, 
							  CASE WHEN In_Time < Out_Time THEN datediff(SECOND, In_Time, Out_Time) ELSE NULL END AS Total_Work_Sec, Late_Out_Sec, Early_In_Sec, 
							  ABS(DATEDIFF(SECOND, In_Time, Out_Time) - dbo.F_Return_Sec(sm.Shift_Dur)) AS Expr1, Em.Emp_Full_Name, Em.Alpha_Emp_Code, Em.Emp_code, gm.Grd_Name, 
							  sm.Shift_Name, dm.Dept_Name, tm.Type_Name, desig.Desig_Name, Cm.Cmp_Name, Cm.Cmp_Address, DATEADD(d, 10, @from_Date) AS P_From_Date, DATEADD(d, 
							  - 10, @to_Date) AS P_To_Date, sm.Shift_St_Time, sm.Shift_End_Time, In_Time AS Actual_In_Time, Out_Time AS Actual_Out_Time, test1 AS On_Date, inc.Branch_ID, 
							  bm.Branch_Name
		FROM         [#weekoff_get3_temp] AS wo1 INNER JOIN
							  T0095_INCREMENT AS inc WITH (NOLOCK)  ON wo1.Emp_ID = inc.Emp_ID AND wo1.Increment_ID = inc.Increment_ID INNER JOIN
							  T0040_SHIFT_MASTER AS sm WITH (NOLOCK)  ON sm.Cmp_ID = wo1.Cmp_ID AND sm.Shift_ID = wo1.shift_id_per LEFT OUTER JOIN
								  (SELECT     Cmp_ID, Emp_ID, For_Date, MAX(Reason) AS Reason
									FROM          T0150_EMP_INOUT_RECORD WITH (NOLOCK) 
									WHERE      (For_Date BETWEEN @from_date AND @to_date)
									GROUP BY Cmp_ID, Emp_ID, For_Date) AS eir ON wo1.Cmp_ID = eir.Cmp_ID AND wo1.emp_id = eir.Emp_ID AND eir.For_Date = wo1.test1 LEFT OUTER JOIN
								  (SELECT     ld.Leave_Application_ID, ld.Cmp_ID, ld.Leave_ID, ld.From_Date, ld.To_Date, ld.Leave_Period, ld.Leave_Assign_As, ld.Leave_Reason, ld.Row_ID, 
														   ld.Login_ID, ld.System_Date, ld.Half_Leave_Date, lapp.Emp_ID
									FROM          T0110_LEAVE_APPLICATION_DETAIL AS ld WITH (NOLOCK)  INNER JOIN
														   T0120_LEAVE_APPROVAL AS la WITH (NOLOCK)  ON ld.Leave_Application_ID = la.Leave_Application_ID INNER JOIN
														   T0100_LEAVE_APPLICATION AS lapp WITH (NOLOCK)  ON ld.Cmp_ID = lapp.Cmp_ID AND ld.Leave_Application_ID = lapp.Leave_Application_ID
									WHERE      (la.Approval_Status COLLATE SQL_Latin1_General_CP1_CI_AS = 'A')) AS lad ON lad.Cmp_ID = wo1.Cmp_ID AND lad.Emp_ID = wo1.emp_id AND lad.From_Date >= wo1.test1 AND 
							  lad.To_Date <= wo1.test1 INNER JOIN
							  T0080_EMP_MASTER AS Em WITH (NOLOCK)  ON Em.Cmp_ID = wo1.Cmp_ID AND Em.Emp_ID = wo1.Emp_ID INNER JOIN
							  T0010_COMPANY_MASTER AS Cm WITH (NOLOCK)  ON Cm.Cmp_Id = wo1.Cmp_ID LEFT OUTER JOIN
							  T0040_GRADE_MASTER AS gm WITH (NOLOCK)  ON inc.Grd_ID = gm.Grd_ID LEFT OUTER JOIN
							  T0040_DEPARTMENT_MASTER AS dm WITH (NOLOCK)  ON inc.Dept_ID = dm.Dept_Id LEFT OUTER JOIN
							  T0040_TYPE_MASTER AS tm WITH (NOLOCK)  ON inc.Type_ID = tm.Type_ID LEFT OUTER JOIN
							  T0040_DESIGNATION_MASTER AS desig WITH (NOLOCK)  ON inc.Desig_Id = desig.Desig_ID LEFT OUTER JOIN
							  T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON inc.Branch_ID = bm.Branch_ID
		ORDER BY wo1.Emp_ID, for_Date		


		--select wo1.* from #weekoff_get3_temp as wo1
		--inner join T0095_INCREMENT as inc on wo1.Emp_ID = inc.Emp_ID and wo1.Increment_ID = inc.Increment_ID
		--order by wo1.Emp_ID,test1
	
	end
	else if @Report_For = 'WHO'
	begin
		--select * from #weekoff_get1_temp
		--ORDER BY test1
		
		declare @e1 as numeric ,
				@Cmp_ID1 as numeric ,
				@Branch_ID1 as numeric  ,
				@e2 as numeric ,
				@w1 as varchar(max),
				@w2 as varchar(max),
				@ho1 as varchar(max),
				@ho2 as varchar(max),
				@wc as numeric ,
				@hc as numeric ,
				@tw1 as varchar(max) ,
				@tw2 as varchar(max) ,
				@twc  as numeric 
						
			SET	@e1 = 0
			SET	@Cmp_ID1 = 0
			SET	@Branch_ID1 = 0
			SET	@e2 =0
			SET	@w1 = ''
			SET	@w2 = ''
			SET	@ho1 = ''
			SET	@ho2 = ''
			SET	@wc = 0
			SET	@hc = 0
			SET	@tw1  = ''
			SET	@tw2  = ''
			SET	@twc   = 0
		
		
		declare @who as table 
		(
			Emp_id numeric,
			Cmp_ID numeric,
			Branch_ID numeric, 
			Weekoff_Date varchar(max), 
			Holiday_date varchar(max),
			Weekoff_Count numeric,
			Holiday_Count numeric,
			Total_Weekoff_Date varchar(max),
			Total_Weekoff_Count numeric
		)
		
		--select * from #weekoff_get3_temp
	
			
		declare cur_who cursor for
			SELECT     Emp_ID,Cmp_ID,Branch_ID, Weekoff_Date, Holiday_Date,Total_Weekoff_Date
			FROM         (SELECT     Emp_ID,Cmp_ID,Branch_id, REPLACE(CONVERT(nvarchar(11), test1, 106), ' ', '-') AS Weekoff_Date, NULL AS Holiday_Date,NULL as Total_Weekoff_Date
								   FROM          [#weekoff_get3_temp]
								   WHERE      (presence IN ('W', 'COM-W'))
								   UNION
								   SELECT     Emp_ID,Cmp_ID,Branch_id, NULL AS Weekoff_Date, REPLACE(CONVERT(nvarchar(11), test1, 106), ' ', '-') AS Holiday_Date,NULL as Total_Weekoff_Date
								   FROM         [#weekoff_get3_temp]
								   WHERE     (presence IN ('HO', 'COM-HO'))
								   UNION
								   SELECT     Emp_ID,Cmp_ID,Branch_id, NULL AS Weekoff_Date, NULL AS Holiday_Date,REPLACE(CONVERT(nvarchar(11), test1, 106), ' ', '-') as Total_Weekoff_Date
								   FROM         [#weekoff_get3_temp]
								   WHERE     (presence IN ('W', 'COM-W','W_Pr'))) AS a
			ORDER BY Emp_ID, Weekoff_Date, Holiday_Date,Total_Weekoff_Date
		open cur_who
		fetch next from cur_who into @e1,@Cmp_ID1,@Branch_ID1,@w1,@ho1,@tw1
		while @@fetch_status = 0
		begin
			if @e1 = @e2 or @e2=0
			begin
				if @w1 is not null
				begin
					set @w2 = @w2 + @w1 + '; '
					set @wc = @wc + 1
				end
				if @ho1 is not null
				begin
					set @ho2 = @ho2 + @ho1 + '; '
					set @hc = @hc + 1
				end
				if @tw1 is not null
				begin
					set @tw2 = @tw2 + @tw1 + ';'
					set @twc = @twc + 1
				end
			end
			else
			begin
				if charindex('; ',@w2) > 0
					set @w2 = left(@w2,len(@w2)-1)
				if charindex('; ',@ho2) > 0
					set @ho2 = left(@ho2,len(@ho2)-1)
				if charindex('; ',@tw2) > 0
					set @tw2 = left(@tw2,len(@tw2)-1)
				
				insert into @who
				values (@e2,@Cmp_ID1,@Branch_ID1,@w2,@ho2,@wc,@hc,@tw2,@twc)
				
				set @w2 = ''
				set @ho2 = ''
				set @tw2 = ''
				set @wc = 0
				set @hc = 0
				set @twc = 0

				if @w1 is not null
				begin
					set @w2 = @w2 + @w1 + '; '
					set @wc = @wc + 1
				end
				if @ho1 is not null
				begin
					set @ho2 = @ho2 + @ho1 + '; '
					set @hc = @hc + 1
				end
				if @tw1 is not null
				begin
					set @tw2 = @tw2 + @tw1 + ';'
					set @twc = @twc + 1
				end
				
			end
			
			set @e2 = @e1
			
			fetch next from cur_who into @e1,@Cmp_ID1,@Branch_ID1,@w1,@ho1,@tw1
		end
		close cur_who
		deallocate cur_who
		
		insert into @who
		values (@e2,@Cmp_ID1,@Branch_ID1,@w2,@ho2,@wc,@hc,@tw2,@twc)
		
		select * from @who
		order by emp_id
	end
	else if @Report_for = 'CompOff'
	begin
		
		SELECT     Emp_ID, test1 as For_Date,0 as Duration_in_Sec, shift_id_per as Shift_ID,0 as Shift_Type,1 as Emp_OT,0 as Emp_OT_Min_Limit,0 as Emp_OT_Max_Limit,0 as P_Days,0 as OT_Sec, 
					'' as In_Time,'' as Shift_Start_time,0 as OT_Start_Time,0 as Shift_Change,0 as Flag,case when presence in ('W','COM-W') then Compoff_Eligible else 0 end as Weekoff_OT_Sec,
					case when presence in ('HO','COM-HO') then Compoff_Eligible else 0 end as Holiday_OT_Sec,0 as Chk_By_Superior,0 as IO_Tran_ID,'' as Out_Time,'' Shift_End_Time,0 as OT_End_Time, 
					'00:00' as Working_Hour,dbo.f_return_hours(Compoff_Eligible) as OT_Hour, dbo.f_return_hours(present_sec) as Actual_Worked_Hrs,0 as P_Days_Count,
					case when presence not in ('HO','COM-HO') then dbo.f_return_hours(Compoff_Eligible) else '00:00' end as Weekoff_OT_Hour, 
					case when presence in ('HO','COM-HO') then dbo.f_return_hours(Compoff_Eligible) else '00:00' end as Holiday_OT_Hour, '-' as Application_Status
		FROM         (SELECT     wo1.Cmp_ID, Emp_ID, wo1.Branch_ID, Early_in_Sec, wo1.shift_id_per, test1, Late_Out_Sec, present_sec, presence, 
													  CASE WHEN gs.is_compoff = 1 THEN CASE WHEN presence = 'HO' OR
													  presence = 'COM-HO' THEN CASE WHEN present_sec >= dbo.f_return_sec(gs.compoff_min_hours) 
													  THEN present_sec ELSE 0 END ELSE 0 END ELSE 0 END + CASE WHEN gs.is_WO_Compoff = 1 THEN CASE WHEN presence IN ('W', 'COM-W') 
													  THEN CASE WHEN present_sec >= dbo.f_return_sec(gs.compoff_min_hours) 
													  THEN present_sec / 3600 ELSE 0 END ELSE 0 END ELSE 0 END + CASE WHEN gs.is_WD_Compoff = 1 THEN CASE WHEN presence IN ('P', 'S', 'T') 
													  THEN CASE WHEN early_in_sec >= 3600 OR
													  late_out_Sec >= 3600 THEN round((early_in_sec + late_out_sec), 1) ELSE 0 END ELSE 0 END ELSE 0 END AS Compoff_Eligible, gs.Is_CompOff, 
													  gs.Is_WO_CompOff, gs.Is_WD_CompOff
							   FROM          [#weekoff_get3_temp] AS wo1 INNER JOIN
													  T0040_GENERAL_SETTING AS gs WITH (NOLOCK)  ON wo1.cmp_id = gs.Cmp_ID AND wo1.branch_id = gs.Branch_ID) AS a
		WHERE     (Compoff_Eligible > 0)
		ORDER BY test1		

	end
	else if @Report_For = 'Late_Early'
	begin
	
		select Emp_ID,'Early_Going' as Count_Type, sum(Early_Count) as Count_Value from #weekoff_get3_temp 
		group by Emp_ID
		union
		select Emp_ID,'Late_Count' as Count_Type, sum(Late_Count) as Count_Value from #weekoff_get3_temp 
		group by Emp_ID
		union 
		select Emp_ID,'Max_Late' as Max_Late, max(Actual_Late_Sec) as Count_Value from #weekoff_get3_temp 
		group by Emp_ID
		union
		select Emp_ID,'Max_Early' as Max_Late, Max(Actual_Early_Sec) as Count_Value from #weekoff_get3_temp 
		group by Emp_ID
		union
		select Emp_ID,'Sum_Late' as Max_Late, Sum(Actual_Late_Sec) as Count_Value from #weekoff_get3_temp 
		group by Emp_ID
		union
		select Emp_ID,'Sum_Early' as Max_Late, Sum(Actual_Early_Sec) as Count_Value from #weekoff_get3_temp 
		group by Emp_ID
	

	end
	else if @Report_for = 'CompOff'
	begin
		
		SELECT     Emp_ID, test1 as For_Date,0 as Duration_in_Sec, shift_id_per as Shift_ID,0 as Shift_Type,1 as Emp_OT,0 as Emp_OT_Min_Limit,0 as Emp_OT_Max_Limit,0 as P_Days,0 as OT_Sec, 
					'' as In_Time,'' as Shift_Start_time,0 as OT_Start_Time,0 as Shift_Change,0 as Flag,case when presence in ('W','COM-W') then Compoff_Eligible else 0 end as Weekoff_OT_Sec,
					case when presence in ('HO','COM-HO') then Compoff_Eligible else 0 end as Holiday_OT_Sec,0 as Chk_By_Superior,0 as IO_Tran_ID,'' as Out_Time,'' Shift_End_Time,0 as OT_End_Time, 
					'00:00' as Working_Hour,dbo.f_return_hours(Compoff_Eligible) as OT_Hour, dbo.f_return_hours(present_sec) as Actual_Worked_Hrs,0 as P_Days_Count,
					case when presence not in ('HO','COM-HO') then dbo.f_return_hours(Compoff_Eligible) else '00:00' end as Weekoff_OT_Hour, 
					case when presence in ('HO','COM-HO') then dbo.f_return_hours(Compoff_Eligible) else '00:00' end as Holiday_OT_Hour, '-' as Application_Status
		FROM         (SELECT     wo1.Cmp_ID, Emp_ID, wo1.Branch_ID, Early_in_Sec, wo1.shift_id_per, test1, Late_Out_Sec, present_sec, presence, 
													  CASE WHEN gs.is_compoff = 1 THEN CASE WHEN presence = 'HO' OR
													  presence = 'COM-HO' THEN CASE WHEN present_sec >= dbo.f_return_sec(gs.compoff_min_hours) 
													  THEN present_sec ELSE 0 END ELSE 0 END ELSE 0 END + CASE WHEN gs.is_WO_Compoff = 1 THEN CASE WHEN presence IN ('W', 'COM-W') 
													  THEN CASE WHEN present_sec >= dbo.f_return_sec(gs.compoff_min_hours) 
													  THEN present_sec / 3600 ELSE 0 END ELSE 0 END ELSE 0 END + CASE WHEN gs.is_WD_Compoff = 1 THEN CASE WHEN presence IN ('P', 'S', 'T') 
													  THEN CASE WHEN early_in_sec >= 3600 OR
													  late_out_Sec >= 3600 THEN round((early_in_sec + late_out_sec), 1) ELSE 0 END ELSE 0 END ELSE 0 END AS Compoff_Eligible, gs.Is_CompOff, 
													  gs.Is_WO_CompOff, gs.Is_WD_CompOff
							   FROM          [#weekoff_get3_temp] AS wo1 INNER JOIN
													  T0040_GENERAL_SETTING AS gs WITH (NOLOCK)  ON wo1.cmp_id = gs.Cmp_ID AND wo1.branch_id = gs.Branch_ID) AS a
		WHERE     (Compoff_Eligible > 0)
		ORDER BY test1		

	end
	else
	begin
		SELECT     Cmp_ID, emp_id, branch_id, CAST(P AS decimal(18, 1)) AS P, CAST(A AS decimal(18, 1)) AS A, CAST(L AS decimal(18, 1)) AS L, CAST(W AS decimal(18, 1)) AS W, 
							  0 AS Comp, CAST(H AS decimal(18, 1)) AS H, CAST(LWP AS decimal(18, 1)) AS LWP, CAST(Payable_Present_Days AS decimal(18, 1)) AS Payable_Present_Days, 
							  CAST(Total_Days AS decimal(18, 1)) AS Total_Days, Cancel_Weekoff, Cancel_Holiday, Early_Count, Late_Count
		FROM         [#total_count]
	end
	
END

