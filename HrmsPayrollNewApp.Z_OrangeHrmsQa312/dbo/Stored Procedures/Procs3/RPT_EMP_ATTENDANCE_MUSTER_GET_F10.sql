

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_EMP_ATTENDANCE_MUSTER_GET_F10]
	-- Add the parameters for the stored procedure here
	@cmp_id		numeric 
	,@from_date		datetime
	,@to_date		datetime
	,@branch_id		numeric 
	,@Cat_ID		numeric
	,@grd_id		numeric
	,@Type_id		numeric
	,@dept_ID		numeric
	,@desig_ID		numeric
	,@emp_id		numeric
	,@constraint	varchar(5000)
	,@Report_For	varchar(50) = ''
	,@Export_Type   varchar(50) = 'EXCEL'
	
	
	
	--@from_date_p	datetime
	--,@to_date_p		datetime
	--,@branch_id_p	numeric 
	--,@cmp_id_p		numeric 
	--,@emp_id_p		varchar(max)
	--,@grade_id_p	numeric
	--,@desig_p		numeric
	--,@dept_p		numeric
	--,@category_p	numeric
	--,@BusiSeg_p		numeric
	--,@Vertical_p	numeric
	--,@SubVertical_p numeric
	--,@Type_p		numeric
	--,@SubBranch_p	numeric
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
  
/* Variables are declared at two stages viz
1) to Store the Values in Input
2) to Store the Query Part 
*/
--declare @from_date as date 
--declare @to_date as date 
--declare @cmp_id as numeric 
declare @First_In_Last_Out_For_InOut_Calculation as numeric 
--declare @emp_id as varchar(max) 
--declare @branch_id as numeric 
declare @grade_id as numeric 
declare @desig as numeric 
declare @dept as numeric 
declare @category as numeric 
declare @BusiSeg as numeric 
declare @Vertical as numeric 
declare @SubVertical as numeric 
declare @Type as numeric 
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
--declare @flag_type as numeric = 0

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
	set @chkConstraint = ' and Emp_ID in (select  cast(data  as numeric) from dbo.Split ( ''' + @Constraint + ''',''#''))'
	set @chkConstraint1 = ' and mec.Emp_ID in (select  cast(data  as numeric) from dbo.Split ( ''' + @Constraint + ''',''#''))'
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
select distinct Leave_Code into #weekoff_get_LM_Temp from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_Paid_Unpaid='P'



/* Table Test1 is been created and added dates between two dates through this SP */ 



/* Employee Selection done from V_EMP_CONS View using conditions given in above variables */

declare @qry1 as varchar(max) 
set @qry1 = '' 
if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#V_Emp_Get_Info1' and type = 'u') 
begin 
	drop table #V_Emp_Get_Info1 
end
CREATE TABLE #V_Emp_Get_Info1
(
	emp_id			numeric
	,branch_id		numeric
	,Cmp_ID			numeric
	,Increment_ID	numeric
	,Join_Date		datetime
	,Left_Date		datetime
	,Emp_code		numeric
	,dept_id		numeric
	,grd_id			numeric
	,desig_id		numeric
	,type_id		numeric
)

if @constraint <> ''
begin
	set @qry1 = '
				insert into #V_Emp_Get_Info1
				SELECT DISTINCT mec.Emp_ID, mec.Branch_ID, mec.Cmp_ID, mec.Increment_ID, mec.Join_Date, mec.Left_Date,
					mec.Emp_Code,dept_id,grd_id,desig_id,type_id
				FROM         V_Emp_Cons AS mec INNER JOIN
										  (SELECT     Emp_ID, MAX(Increment_Effective_Date) AS increment_effective_date
											FROM          V_Emp_Cons
											GROUP BY Emp_ID) AS ec ON mec.Emp_ID = ec.Emp_ID AND mec.Increment_Effective_Date = ec.increment_effective_date
				WHERE     (1 = 1)' + @chkConstraint1
	
	--insert into #V_Emp_Get_Info1
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
			  ((@From_Date  >= join_Date  and  @From_Date <= left_date)      
				or (@To_Date  >= join_Date  and @To_Date <= left_date)      
				or (Left_date is null and @To_Date >= Join_Date)      
				or (@To_Date >= left_date  and  @From_Date <= left_date)) 
				order by Emp_ID
					
		delete  from #V_Emp_Get_Info1 where Increment_ID not in (select max(Increment_ID) from dbo.T0095_Increment WITH (NOLOCK)
		where  Increment_effective_Date <= @to_date
		group by emp_ID)
END



declare @leave_footer as varchar(max) ,
		@lc as varchar(max),
		@lt as Varchar(max),
		@ld as numeric

Set @leave_footer = ''

declare leave cursor for
select distinct leave_id, leave_code,leave_Name from t0040_leave_master as lm WITH (NOLOCK)
inner join #V_Emp_Get_Info1 as em on em.cmp_id = lm.cmp_id
order by leave_id
open leave
fetch next from leave into @ld, @lc,@lt
while @@FETCH_STATUS = 0
begin
	set @leave_footer = @leave_footer + @lc + ' : ' + @lt + '  '
	fetch next from leave into @ld,@lc,@lt
end
close leave
deallocate leave



if @Report_For = 'EMP RECORD'
begin



--SELECT		ec1.Emp_ID, ec1.Emp_code, em.Alpha_Emp_Code,em.Emp_First_Name, em.Emp_Full_Name, cm.Cmp_Name as Comp_Name, 
--			bm.Branch_Address, bm.Branch_Name, dm.Dept_Name, gm.Grd_Name, desig.Desig_Name,tm.Type_Name, ec1.Branch_ID, ec1.Cmp_ID, ec1.Increment_ID, Join_Date, Left_Date, ec1.Dept_ID, ec1.Grd_ID, ec1.Desig_Id, ec1.Type_ID
--FROM         #V_Emp_Get_Info1 as ec1
--inner join T0080_EMP_MASTER as em on ec1.Emp_ID = em.Emp_ID and ec1.Cmp_ID = em.Cmp_ID
--inner join T0010_COMPANY_MASTER as cm on ec1.Cmp_ID = cm.Cmp_Id
--inner join T0030_BRANCH_MASTER as bm on ec1.Branch_ID = bm.Branch_ID
--inner join T0040_DEPARTMENT_MASTER as dm on ec1.Dept_ID = dm.Dept_Id
--inner join T0040_GRADE_MASTER as gm on ec1.Grd_ID = gm.Grd_ID
--inner join T0040_DESIGNATION_MASTER as desig on ec1.Desig_Id = desig.Desig_ID
--inner join T0040_TYPE_MASTER as tm on ec1.Type_ID = tm.Type_ID



	Select E.Emp_ID ,E.Emp_code, E.Alpha_Emp_Code, E.Emp_First_Name, E.Emp_full_Name ,Comp_Name,Branch_Address
		, Branch_Name , Dept_Name ,Grd_Name , Desig_Name
		,Type_Name
		,CMP_NAME,CMP_ADDRESS
		,@From_Date as P_From_date ,@To_Date as P_To_Date,BM.BRANCH_ID		
		,@leave_Footer as Leave_Footer		
		From #V_Emp_Get_Info1 EC INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
		( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID INNER JOIN 
		dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID Left outer join 
		dbo.T0040_Type_Master tm WITH (NOLOCK) on Q_I.Type_ID = tm.Type_ID 
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)

	Return
end


if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#V_Emp_Get_Info' and type = 'u') 
begin 
	drop table #V_Emp_Get_Info 
end

SELECT     Extra_AB_Deduction, vec1.*
INTO            #V_Emp_Get_Info
FROM         #V_Emp_Get_Info1 AS vec1 INNER JOIN
                      T0080_EMP_MASTER AS em WITH (NOLOCK) ON vec1.Emp_ID = em.Emp_ID AND vec1.Cmp_ID = em.Cmp_ID

set @from_date = dateadd(d,-10,@from_date)
set @to_date = dateadd(d,10,@to_date)
exec getAllDaysBetweenTwoDate @from_date, @to_date 

/* Employee wise shift details as per the effective date is considered here */

if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_shift_detail_temp' and type = 'u') 
begin 
 drop table #v_shift_detail_temp 
end

SELECT     a.Emp_ID, a.Cmp_ID, Shift_ID, For_Date, Eff_Date_Sd, Shift_St_Time, Shift_End_Time, Is_Night_Shift, Is_Split_Shift
INTO            #v_shift_detail_temp
FROM         (SELECT     a.Emp_ID, a.Cmp_ID, a.Shift_ID, a.For_Date, a.Expr1 AS Eff_Date_Sd, sm.Shift_St_Time, sm.Shift_End_Time, 
                                              CASE WHEN sm.Shift_St_Time > sm.Shift_End_Time THEN 1 ELSE 0 END AS Is_Night_Shift, sm.Is_Split_Shift
                       FROM          (SELECT     sd1.Emp_ID, sd1.Cmp_ID, sd1.Shift_ID, sd1.For_Date,
                                                                          (SELECT     MIN(test1) AS Expr1
                                                                            FROM          test1) AS Expr1
                                               FROM          T0100_EMP_SHIFT_DETAIL AS sd1 WITH (NOLOCK) INNER JOIN
                                                                          (SELECT     Emp_ID, Cmp_ID, MAX(For_Date) AS for_date
                                                                            FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
                                                                            WHERE      (For_Date < @from_date)
                                                                            GROUP BY Emp_ID, Cmp_ID) AS t1 ON t1.Emp_ID = sd1.Emp_ID AND t1.Cmp_ID = sd1.Cmp_ID AND 
                                                                      t1.for_date = sd1.For_Date  
                                               WHERE      (sd1.Emp_ID NOT IN
                                                                          (SELECT DISTINCT Emp_ID
                                                                            FROM          T0100_EMP_SHIFT_DETAIL AS T0100_EMP_SHIFT_DETAIL_3 WITH (NOLOCK)
                                                                            WHERE      (For_Date = @from_date))) 
                                               UNION
                                               SELECT     sd1.Emp_ID, sd1.Cmp_ID, Shift_ID, For_Date, For_Date AS Expr1
                                               FROM         T0100_EMP_SHIFT_DETAIL AS sd1 WITH (NOLOCK)
                                               WHERE     (For_Date BETWEEN @from_date AND @to_date)) AS a INNER JOIN
                                              T0040_SHIFT_MASTER AS sm WITH (NOLOCK) ON a.Shift_ID = sm.Shift_ID) AS a Inner Join
                                              #V_Emp_Get_Info V on a.Emp_ID = v.Emp_ID

/* Regular weekoff is been considered along with approval of compasatory weekoff */

if exists(select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_weekoff_temp_temp' and type = 'u') 
begin 
 drop table #v_weekoff_temp_temp 
end 

SELECT DISTINCT Cmp_ID, Emp_ID, For_Date, eff_date, weekoff_Day1, weekoff_Day2
INTO            #v_weekoff_temp_temp
FROM         (SELECT     w1.Cmp_ID, w1.Emp_ID, w1.For_Date,
                                                  (SELECT     MIN(test1) AS Expr1
                                                    FROM          test1) AS eff_date, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN LEFT(weekoff_day, charindex('#', Weekoff_Day) - 1) 
                                              ELSE Weekoff_Day END AS weekoff_Day1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN RIGHT(weekoff_day, len(weekoff_day) 
                                              - charindex('#', Weekoff_Day)) ELSE '' END AS weekoff_Day2
                       FROM          (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, 
                                                                      Alt_W_Half_Day_Cont, Is_P_Comp
                                               FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK)
                                               WHERE      (Alt_W_Full_Day_Cont = '') OR
                                                                      (Alt_W_Full_Day_Cont IS NULL)) AS w1 INNER JOIN
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
                                             ELSE Weekoff_Day END AS weekoff_Day1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN RIGHT(weekoff_day, len(weekoff_day) 
                                             - charindex('#', Weekoff_Day)) ELSE '' END AS weekoff_Day2
                       FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, 
                                                                     Alt_W_Half_Day_Cont, Is_P_Comp
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
                                                                          Alt_W_Full_Day_Cont = '')))
                       UNION
                       SELECT     Cmp_ID, Emp_ID, For_Date, For_Date AS Expr1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN LEFT(weekoff_day, charindex('#', 
                                             Weekoff_Day) - 1) ELSE Weekoff_Day END AS weekoff_Day1, CASE WHEN charindex('#', Weekoff_Day) > 0 THEN RIGHT(weekoff_day, 
                                             len(weekoff_day) - charindex('#', Weekoff_Day)) ELSE '' END AS weekoff_Day2
                       FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, 
                                                                     Alt_W_Half_Day_Cont, Is_P_Comp
                                              FROM          T0100_WEEKOFF_ADJ WITH (NOLOCK)
                                              WHERE      (Alt_W_Full_Day_Cont = '') OR
                                                                     (Alt_W_Full_Day_Cont IS NULL)) AS T0100_WEEKOFF_ADJ 
                       WHERE     (For_Date BETWEEN @from_date AND @to_date)) AS a
                       

/* Alternate weekoff is considered here along with approval of Compansatory */

if exists(select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_alt_weekoff_temp_temp ' and type = 'u') 
begin 
 drop table #v_alt_weekoff_temp_temp  
end 

SELECT DISTINCT Cmp_ID, Emp_ID, eff_date, Alt_Weekoff_day, Count1, Count2, Count3, Count4, Count5
INTO            #v_alt_weekoff_temp_temp 
FROM         (SELECT     w1.Cmp_ID, w1.Emp_ID, w1.For_Date, @from_date AS eff_date, w1.Weekoff_Day AS Alt_Weekoff_day, w1.Alt_W_Full_Day_Cont, 
                                              CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 2, 1) ELSE 0 END AS Count1, 
                                              CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 2) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 4, 1) ELSE 0 END AS Count2, 
                                              CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 4) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 6, 1) ELSE 0 END AS Count3, 
                                              CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 6) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 8, 1) ELSE 0 END AS Count4, 
                                              CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 8) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 10, 1) ELSE 0 END AS Count5
                       FROM          (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, 
                                                                      Alt_W_Half_Day_Cont, Is_P_Comp
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
                       SELECT     w1_1.Cmp_ID, w1_1.Emp_ID, w1_1.For_Date, @from_date AS eff_date, w1_1.Weekoff_Day AS Alt_Weekoff_day, 
                                             w1_1.Alt_W_Full_Day_Cont, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 2, 1) 
                                             ELSE 0 END AS Count1, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 2) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 4, 1) 
                                             ELSE 0 END AS Count2, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 4) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 6, 1) 
                                             ELSE 0 END AS Count3, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 6) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 8, 1) 
                                             ELSE 0 END AS Count4, CASE WHEN CHARINDEX('#', Alt_W_Full_Day_Cont, 8) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 10, 1) 
                                             ELSE 0 END AS Count5
                       FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, 
                                                                     Alt_W_Half_Day_Cont, Is_P_Comp
                                              FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_4 WITH (NOLOCK)
                                              WHERE      (Alt_W_Full_Day_Cont <> '') AND (Alt_W_Full_Day_Cont IS NOT NULL)) AS w1_1 INNER JOIN
                                                 (SELECT     Emp_ID, Cmp_ID, MAX(For_Date) AS for_date
                                                   FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_3 WITH (NOLOCK)
                                                   WHERE      (For_Date > @to_date)
                                                   GROUP BY Emp_ID, Cmp_ID) AS w2_1 ON w1_1.Emp_ID = w2_1.Emp_ID AND w1_1.Cmp_ID = w2_1.Cmp_ID AND 
                                             w1_1.For_Date = w2_1.for_date
                       WHERE     (w1_1.For_Date > @from_date) AND (w1_1.Emp_ID NOT IN
                                                 (SELECT DISTINCT Emp_ID
                                                   FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_2 WITH (NOLOCK)
                                                   WHERE      (For_Date = @from_date) AND (Alt_W_Full_Day_Cont IS NOT NULL) AND (Alt_W_Full_Day_Cont <> '')))
                       UNION
                       SELECT     Cmp_ID, Emp_ID, For_Date, For_Date AS Expr1, Weekoff_Day AS Alt_Weekoff_day, Alt_W_Full_Day_Cont, CASE WHEN CHARINDEX('#', 
                                             Alt_W_Full_Day_Cont) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 2, 1) ELSE 0 END AS Count1, CASE WHEN CHARINDEX('#', 
                                             Alt_W_Full_Day_Cont, 2) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 4, 1) ELSE 0 END AS Count2, CASE WHEN CHARINDEX('#', 
                                             Alt_W_Full_Day_Cont, 4) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 6, 1) ELSE 0 END AS Count3, CASE WHEN CHARINDEX('#', 
                                             Alt_W_Full_Day_Cont, 6) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 8, 1) ELSE 0 END AS Count4, CASE WHEN CHARINDEX('#', 
                                             Alt_W_Full_Day_Cont, 8) > 0 THEN SUBSTRING(Alt_W_Full_Day_Cont, 10, 1) ELSE 0 END AS Count5
                       FROM         (SELECT     W_Tran_ID, Emp_ID, Cmp_ID, For_Date, Weekoff_Day, Weekoff_Day_Value, Alt_W_Name, Alt_W_Full_Day_Cont, 
                                                                     Alt_W_Half_Day_Cont, Is_P_Comp
                                              FROM          T0100_WEEKOFF_ADJ AS T0100_WEEKOFF_ADJ_1 WITH (NOLOCK)
                                              WHERE      (Alt_W_Full_Day_Cont <> '') AND (Alt_W_Full_Day_Cont IS NOT NULL)) AS T0100_WEEKOFF_ADJ 
                       WHERE     (For_Date BETWEEN @from_date AND @to_date)) AS a


/*	Employee in - out record based on the condition in general setting as to first in last out.
	Here need to note that wherever night shift is found in shift details in-time is considered as 12 hours prior
	to actual in-out time and wherever split shift is found along with night shift the prior hours in reduced to 6 hours
	these dates are considered for FOR_DATE derivation.
*/



if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_Emp_InOut_Record_temp' and type = 'u') 
begin 
 drop table #v_Emp_InOut_Record_temp 
end 
	
SELECT     Emp_ID, Cmp_ID, For_Date, MIN(In_Time) AS In_Time, MAX(Out_Time) AS Out_Time,SUM(dur_sum) as Dur_sum,SUM(max_min_time) as max_min_time,cast(SUM(Present_Hours)/3600 as decimal(18,5)) AS Present_Hours, MAX(Chk_By_Superior) 
					  AS Chk_By_Superior, MAX(Half_Full_day) AS Half_Full_day,MAX(Is_Split_Shift) Is_Split_Shift, max(Is_Night_Shift) Is_Night_Shift,Shift_St_Time,Shift_End_Time
INTO            #v_Emp_InOut_Record_temp
FROM         (SELECT     Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, cast(SUM(Duration) AS decimal(18,5)) as Dur_sum, cast(DATEDIFF(M, MIN(In_Time), MAX(Out_Time))*60 as decimal(18,5)) as max_min_time, case when fc = 0 then cast(SUM(Duration) AS decimal(18,5)) else cast(DATEDIFF(MINUTE, MIN(In_Time), MAX(Out_Time))*60 as decimal(18,5)) end
											  AS Present_Hours, MAX(Chk_By_Superior) AS Chk_By_Superior, MAX(Half_Full_day) AS Half_Full_day, Is_Split_Shift, Is_Night_Shift,Shift_St_Time,Shift_End_Time
					   FROM          (SELECT     eir.Emp_ID, eir.Cmp_ID, gs.First_In_Last_Out_For_InOut_Calculation as fc,
																		  (SELECT     Is_Split_Shift
																			FROM          #v_shift_detail_temp
																			WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																									   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																										 FROM          #v_shift_detail_temp
																										 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS Is_Split_Shift,
																		  (SELECT     Is_Night_Shift
																			FROM          #v_shift_detail_temp
																			WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																									   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																										 FROM          #v_shift_detail_temp
																										 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) AS Is_Night_Shift, 
																	  CASE WHEN
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
																										 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 0 THEN CAST(CONVERT(nvarchar(10), 
																	  dateadd(hour, - 12, eir.In_Time), 101) AS DATE) ELSE CAST(CONVERT(nvarchar(10), dateadd(hour, - 6, eir.In_Time), 101) AS DATE) 
																	  END ELSE CAST(CONVERT(nvarchar(10), dateadd(hour, - 3, eir.In_Time), 101) AS DATE) END AS For_Date, CASE WHEN
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
																	  ELSE dateadd(hour, - 6, eir.In_Time) END ELSE dateadd(hour, - 3, eir.In_Time) END AS In_Time, CASE WHEN
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
																										 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) = 0 THEN dateadd(hour, - 12, 
																	  eir.Out_Time) ELSE dateadd(hour, - 6, eir.Out_Time) END ELSE dateadd(hour, - 3, eir.Out_Time) END AS Out_Time,dbo.f_return_sec(eir.Duration) as Duration, eir.Reason, 
																	  eir.Ip_Address, eir.In_Date_Time, eir.Out_Date_Time, eir.Skip_Count, eir.Late_Calc_Not_App, eir.Chk_By_Superior, 
																	  eir.Sup_Comment, case when Chk_By_Superior = 1 then eir.Half_Full_day else null end as Half_Full_day, 
																	  case when Chk_By_Superior = 1 then eir.Is_Cancel_Late_In else 0 end as Is_Cancel_Late_In, 
																	  case when Chk_By_Superior = 1 then eir.Is_Cancel_Early_Out else 0 end as Is_Cancel_Early_Out, eir.Is_Default_In, eir.Is_Default_Out, 
																	  eir.Cmp_prp_in_flag, eir.Cmp_prp_out_flag, eir.is_Cmp_purpose, ec.branch_id,Shift_St_Time,Shift_End_Time
											   FROM          (SELECT     IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, case when In_Time is null then
																				case when Chk_By_Superior = 1
																				then (SELECT     Shift_St_Time
																						FROM          #v_shift_detail_temp
																						WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																												   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																													 FROM          #v_shift_detail_temp
																													 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date))))  else null end else In_Time end as In_Time, 
																				ISNULL(Out_Time, case when In_Time is null then
																				case when Chk_By_Superior = 1
																				then (SELECT     Shift_St_Time
																						FROM          #v_shift_detail_temp
																						WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																												   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																													 FROM          #v_shift_detail_temp
																													 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date))))  else null end else In_Time end) AS Out_Time, 
																													 (SELECT     Shift_St_Time
																						FROM          #v_shift_detail_temp
																						WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																												   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																													 FROM          #v_shift_detail_temp
																													 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) as Shift_St_Time, 
																				(SELECT     Shift_End_Time
																						FROM          #v_shift_detail_temp
																						WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd =
																												   (SELECT     MAX(Eff_Date_Sd) AS Expr1
																													 FROM          #v_shift_detail_temp
																													 WHERE      (Emp_ID = eir.Emp_ID) AND (Eff_Date_Sd <= eir.For_Date)))) as Shift_End_Time,Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, 
																									  Skip_Count, Late_Calc_Not_App, Chk_By_Superior, Sup_Comment, Half_Full_day, Is_Cancel_Late_In, Is_Cancel_Early_Out, Is_Default_In, Is_Default_Out, 
																									  Cmp_prp_in_flag, Cmp_prp_out_flag, is_Cmp_purpose
																				FROM         T0150_EMP_INOUT_RECORD eir WITH (NOLOCK)
																	   WHERE      (For_Date BETWEEN @from_date AND @to_date)) AS eir INNER JOIN
																	  #V_Emp_Get_Info AS ec ON ec.emp_id = eir.Emp_ID AND ec.Cmp_ID = eir.Cmp_ID 
																	  inner join T0040_GENERAL_SETTING gs WITH (NOLOCK) on ec.Branch_ID = gs.Branch_ID and ec.Cmp_ID = gs.Cmp_ID) AS eir
					   GROUP BY Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Is_Night_Shift, Is_Split_Shift,fc,Shift_St_Time,Shift_End_Time) AS a
GROUP BY Emp_ID, Cmp_ID, For_Date,Shift_St_Time,Shift_End_Time



/*	#weekoff_get1_temp is the first base table generated here with all basic information and considerring only 'P' 
	or 'A' in Presence Column. This column then forms the bases of all other calculations 
*/

if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_get1_temp' and type = 'u') 
begin 
 drop table #weekoff_get1_temp 
end 
SELECT DISTINCT 
                      TOP (100) PERCENT t1.Cmp_ID, t1.emp_id, t1.branch_id, t1.Increment_ID,t1.Extra_AB_Deduction, t1.id, t1.test1, DATENAME(dw, t1.test1) AS Week_Day, DATEPART(week, 
                      t1.test1) % MONTH(t1.test1) + 1 AS Week_Count, ISNULL(GS.Is_Cancel_Weekoff, 0) AS Can_Weekoff, ISNULL(leave.Approval_Status, 0) AS leaveStatus,
                       ISNULL(leave.Weekoff_as_leave, 0) AS Weekoff_as_leave, ISNULL(leave.Holiday_as_leave, 0) AS Holiday_as_leave, 
                      ISNULL(leave.Leave_Assign_As, '') AS Leave_Assign_As,
                          (SELECT     weekoff_Day1
                            FROM          #v_weekoff_temp_temp
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_weekoff_temp_temp
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS weekoff,
                          (SELECT     weekoff_Day2 
                            FROM          #v_weekoff_temp_temp
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_weekoff_temp_temp
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS weekoff2,							
                          (SELECT     Shift_ID
                            FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
                            WHERE      (Emp_ID = t1.emp_id) AND (Cmp_ID = t1.Cmp_ID) AND (For_Date =
                                                       (SELECT     MAX(For_Date) AS Expr1
                                                         FROM          (SELECT     Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type
                                                                                 FROM          T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
                                                                                 WHERE      (Shift_Type = 0)) AS T0100_EMP_SHIFT_DETAIL 
                                                         WHERE      (Emp_ID = t1.emp_id) AND (For_Date <= t1.test1)))) AS shift_ID_Per,
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
                            FROM          #v_alt_weekoff_temp_temp 
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_alt_weekoff_temp_temp 
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Alt_Weekoff_Day,
                          (SELECT     Count1
                            FROM          #v_alt_weekoff_temp_temp 
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_alt_weekoff_temp_temp 
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count1,
                          (SELECT     Count2
                            FROM          #v_alt_weekoff_temp_temp 
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_alt_weekoff_temp_temp 
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count2,
                          (SELECT     Count3
                            FROM          #v_alt_weekoff_temp_temp 
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_alt_weekoff_temp_temp 
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count3,
                          (SELECT     Count4
                            FROM          #v_alt_weekoff_temp_temp 
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_alt_weekoff_temp_temp 
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count4,
                          (SELECT     Count5
                            FROM          #v_alt_weekoff_temp_temp 
                            WHERE      (Emp_ID = t1.emp_id) AND (eff_date =
                                                       (SELECT     MAX(eff_date) AS Expr1
                                                         FROM          #v_alt_weekoff_temp_temp 
                                                         WHERE      (Emp_ID = t1.emp_id) AND (eff_date <= t1.test1)))) AS Count5, t1.left_date, t1.join_date, EIR.Chk_By_Superior, 
                      EIR.Half_Full_day, EIR.Is_Split_Shift, EIR.Is_Night_Shift,eir.In_Time,eir.Out_Time,eir.Shift_St_Time,eir.Shift_End_Time,inc1.Emp_Late_Limit,inc1.Emp_Early_Limit,gs.Late_Limit,gs.Early_Limit,
                      dbo.F_Return_Sec(ISNULL(Emp_Late_Limit,ISNULL(Late_Limit,'00:00'))) latelimit_Sec,
                      DATEDIFF(minute,Shift_St_time,
                      cast(
							cast(DATEPART(HOUR,
												case when eir.Is_Night_Shift = 0 
												then 
													case when eir.is_split_Shift = 0 
													then dateadd(HH,3,In_Time) 
													else dateadd(HH,6,In_Time) 
													end 
												else dateadd(HH,12,In_Time)
												end) as varchar(2)) + ':' +  
							cast(DATEPART(MINUTE,
												case when eir.Is_Night_Shift = 0 
												then 
													case when eir.is_split_Shift = 0 
													then dateadd(HH,3,In_Time) 
													else dateadd(HH,6,In_Time) 
													end 
												else dateadd(HH,12,In_Time)
												end) as varchar(2)) as time)) * 60 as actual_late_Sec,
                      case when dbo.F_Return_Sec(ISNULL(Emp_Late_Limit,ISNULL(Late_Limit,'00:00'))) >= ISNULL(DATEDIFF(minute,Shift_St_time,cast(cast(DATEPART(HOUR,case when eir.Is_Night_Shift = 0 then case when eir.is_split_Shift = 0 then dateadd(HH,3,In_Time) else dateadd(HH,6,In_Time) end else dateadd(HH,12,In_Time)end) as varchar(2)) + ':' +  cast(DATEPART(MINUTE,case when eir.Is_Night_Shift = 0 then case when eir.is_split_Shift = 0 then dateadd(HH,3,In_Time) else dateadd(HH,6,In_Time) end else dateadd(HH,12,In_Time)end) as varchar(2)) as time)),0) * 60
						then 0 else 1 end as Late_Count,
						DATEDIFF(minute,
                      cast(
							cast(DATEPART(HOUR,
												case when eir.Is_Night_Shift = 0 
												then 
													case when eir.is_split_Shift = 0 
													then dateadd(HH,3,Out_Time) 
													else dateadd(HH,6,Out_Time) 
													end 
												else dateadd(HH,12,Out_Time)
												end) as varchar(2)) + ':' +  
							cast(DATEPART(MINUTE,
												case when eir.Is_Night_Shift = 0 
												then 
													case when eir.is_split_Shift = 0 
													then dateadd(HH,3,Out_Time) 
													else dateadd(HH,6,Out_Time) 
													end 
												else dateadd(HH,12,Out_Time)
												end) as varchar(2)) as time),Shift_End_Time) * 60 as actual_Early_Sec,
                      case when dbo.F_Return_Sec(ISNULL(Emp_Early_Limit,ISNULL(Early_Limit,'00:00'))) >= ISNULL(DATEDIFF(minute,cast(cast(DATEPART(HOUR,case when eir.Is_Night_Shift = 0 then case when eir.is_split_Shift = 0 then dateadd(HH,3,Out_Time) else dateadd(HH,6,Out_Time) end else dateadd(HH,12,Out_Time)end) as varchar(2)) + ':' +  cast(DATEPART(MINUTE,case when eir.Is_Night_Shift = 0 then case when eir.is_split_Shift = 0 then dateadd(HH,3,Out_Time) else dateadd(HH,6,Out_Time) end else dateadd(HH,12,Out_Time)end) as varchar(2)) as time),Shift_End_Time),0) * 60
						then 0 else 1 end as Early_Count,Emp_Late_mark,Emp_Early_mark,Is_Late_Mark
INTO            #weekoff_get1_temp   
FROM         (SELECT     ec.emp_id, Extra_AB_Deduction, ec.branch_id, ec.Cmp_ID, ec.Increment_ID, ec.join_date, ec.left_date, test1.id, test1.test1
                       FROM          #V_Emp_Get_Info AS ec CROSS JOIN
                                              test1) AS t1 LEFT OUTER JOIN
				T0095_INCREMENT inc1 WITH (NOLOCK) on t1.emp_id = inc1.Emp_ID and t1.Increment_ID = inc1.Increment_ID and t1.Cmp_ID = inc1.Cmp_ID LEFT OUTER JOIN
                      #v_Emp_InOut_Record_temp AS EIR ON t1.emp_id = EIR.Emp_ID AND t1.Cmp_ID = EIR.Cmp_ID AND t1.test1 = EIR.For_Date LEFT OUTER JOIN
                      T0040_GENERAL_SETTING AS GS WITH (NOLOCK) ON t1.branch_id = GS.Branch_ID AND t1.Cmp_ID = GS.Cmp_ID AND t1.test1 = GS.For_Date LEFT OUTER JOIN
                          (SELECT     t1.Emp_ID, t1.Cmp_ID, t1.Approval_Status, t1.From_Date, t1.To_Date, t1.Weekoff_as_leave, t1.Holiday_as_leave, 
                                                   CASE WHEN t1.Leave_Code <> t2.Leave_Code THEN t1.Leave_Code + '+' + t2.Leave_Code ELSE t1.Leave_Code END AS Leave_Code, 
                                                   t1.Leave_Assign_As
                            FROM          (SELECT     Emp_ID, Cmp_ID, Approval_Status, From_Date, To_Date, MAX(Weekoff_as_leave) AS Weekoff_as_leave, 
                                                                           MAX(Holiday_as_leave) AS Holiday_as_leave, CASE WHEN SUM(leave_period_lad) - SUM(leave_period) = 0 THEN NULL 
                                                                           ELSE MAX(Leave_Code) END AS Leave_Code, CASE WHEN SUM(leave_period_lad) - SUM(leave_period) = 0 THEN NULL 
                                                                           ELSE CASE WHEN SUM(leave_period_lad) - SUM(LEAVE_PERIOD) = 1 THEN 'Full Day' ELSE MAX(Leave_Assign_As) 
                                                                           END END AS Leave_Assign_As
                                                    FROM          (SELECT     la.Emp_ID, la.Cmp_ID, la.Approval_Status, lad.From_Date, lad.To_Date, lm.Weekoff_as_leave, 
                           lm.Holiday_as_leave, MAX(lm.Leave_Code) as Leave_Code, CASE WHEN lad.Leave_Period = isnull(lc.Leave_period, 0) 
                                                                                                   THEN lad.Leave_Assign_As ELSE isnull(lc.Day_type, lad.leave_assign_as) END AS Leave_Assign_As, 
                                                                                                   lc.Leave_period, lad.Leave_Period AS leave_period_lad
                                                                            FROM          T0130_LEAVE_APPROVAL_DETAIL AS lad WITH (NOLOCK) INNER JOIN
                                                                                                   T0120_LEAVE_APPROVAL AS la WITH (NOLOCK) ON lad.Leave_Approval_ID = la.Leave_Approval_ID INNER JOIN
                                                                                                   T0040_LEAVE_MASTER AS lm WITH (NOLOCK) ON lad.Leave_ID = lm.Leave_ID LEFT OUTER JOIN
                                                                                                   T0150_LEAVE_CANCELLATION AS lc WITH (NOLOCK) ON la.Emp_ID = lc.Emp_Id AND 
                                                                                                   la.Leave_Approval_ID = lc.Leave_Approval_id
                                                                            WHERE      /*(lad.From_Date >= @from_date) AND (lad.To_Date <= @to_date) AND*/ (la.Approval_Status = 'A')) AS a
                                                    GROUP BY Emp_ID, Cmp_ID, Approval_Status, From_Date, To_Date) AS t1 INNER JOIN
                                                       (SELECT     Emp_ID, Cmp_ID, Approval_Status, From_Date, To_Date, MAX(Weekoff_as_leave) AS Weekoff_as_leave, 
                                                                                MAX(Holiday_as_leave) AS Holiday_as_leave, CASE WHEN SUM(leave_period_lad) - SUM(leave_period) = 0 THEN NULL 
                                                                                ELSE MIN(Leave_Code) END AS Leave_Code, CASE WHEN SUM(leave_period_lad) - SUM(leave_period) = 0 THEN NULL 
                                                                                ELSE CASE WHEN SUM(leave_period_lad) - SUM(LEAVE_PERIOD) = 1 THEN 'Full Day' ELSE MAX(Leave_Assign_As) 
                                                                                END END AS Leave_Assign_As
                                                         FROM          (SELECT     la.Emp_ID, la.Cmp_ID, la.Approval_Status, lad.From_Date, lad.To_Date, lm.Weekoff_as_leave, 
                                                                                                        lm.Holiday_as_leave, lm.Leave_Code, CASE WHEN lad.Leave_Period = isnull(lc.Leave_period, 0) 
                                                                                                        THEN lad.Leave_Assign_As ELSE isnull(lc.Day_type, lad.leave_assign_as) END AS Leave_Assign_As, 
                                                                                                        lc.Leave_period, lad.Leave_Period AS leave_period_lad
                                                                                 FROM          T0130_LEAVE_APPROVAL_DETAIL AS lad WITH (NOLOCK) INNER JOIN
                                                                                                        T0120_LEAVE_APPROVAL AS la WITH (NOLOCK) ON lad.Leave_Approval_ID = la.Leave_Approval_ID INNER JOIN
                                                                                                        T0040_LEAVE_MASTER AS lm WITH (NOLOCK) ON lad.Leave_ID = lm.Leave_ID LEFT OUTER JOIN
                                                                                                        T0150_LEAVE_CANCELLATION AS lc WITH (NOLOCK) ON la.Emp_ID = lc.Emp_Id AND 
                                                                                                        la.Leave_Approval_ID = lc.Leave_Approval_id
                                                                                 WHERE      /*(lad.From_Date >= lad.From_Date) AND (lad.To_Date <= @to_date) AND*/ (la.Approval_Status = 'A')) AS a
                                                         GROUP BY Emp_ID, Cmp_ID, Approval_Status, From_Date, To_Date) AS t2 ON t1.Emp_ID = t2.Emp_ID AND 
                                                   t1.From_Date = t2.From_Date AND t1.To_Date = t2.To_Date) AS leave ON t1.emp_id = leave.Emp_ID AND t1.Cmp_ID = leave.Cmp_ID AND 
                      t1.test1 >= leave.From_Date AND t1.test1 <= leave.To_Date


/*	This is the main calculation table that considers all the conditions and forms major portion of attendance 
	calculation. Weekoff, Holiday, Leaves, Compansatory leaves, Attendance Regularizations are considered here
*/                      

if exists (select * from [tempdb].[dbo].sysobjects where name = '#weekoff_get2_temp' and type = 'u') 
begin 
 drop table #weekoff_get2_temp 
end 

SELECT DISTINCT wo1.Cmp_ID, wo1.emp_id, wo1.branch_id, wo1.Increment_ID, wo1.shift_ID_Per,wo1.Extra_Ab_Deduction, wo1.id, wo1.test1, wo1.Week_Day, 
CASE WHEN (WO1.TEST1 < wo1.JOIN_DATE OR WO1.TEST1 > WO1.LEFT_DATE) 
THEN '-' 
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
						CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5))) 
						THEN 
							CASE WHEN presence = 'P' 
							THEN 'COM-W' 
							ELSE 'W' 
							END 
						ELSE 'S'
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
						CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5))) 
						THEN 
							CASE WHEN presence = 'P' 
							THEN 'COM-W' 
							ELSE 'W' 
							END 
						ELSE  'P'						
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
				CASE WHEN Leave_Assign_As IN ('First Half', 'Second Half') 
				THEN Leave_Code + '-HF-A' 
				ELSE Leave_Code 
				END 
			ELSE 
				CASE WHEN Leave_Assign_As IN ('First Half', 'Second Half') 
				THEN Leave_Code + '-HF-P' 
				ELSE Leave_Code 
				END 
			END 
		ELSE 
			CASE WHEN ho1.Is_Fix IS NOT NULL OR ho2.Is_Fix IS NOT NULL OR ho3.Is_Fix IS NOT NULL 
			THEN 'HO' 
			ELSE 
				CASE WHEN (Week_Day = weekoff OR Week_day = weekoff2 OR (Week_Day = Alt_Weekoff_Day AND (Week_Count = Count1 OR Week_Count = Count2 OR Week_Count = Count3 OR Week_Count = Count4 OR Week_Count = Count5))) 
				THEN 'W' 
				ELSE 
					CASE WHEN isnull(Calculate_Days, 0) < 1 AND isnull(Calculate_Days, 0) > 0 
					THEN 'HF' 
					ELSE 
						CASE WHEN wo1.Is_Split_Shift <> 0 
						THEN 
							CASE WHEN Calculate_Days IS NULL and ISNULL(Present_Hours,0) < 5
							THEN 'A' 
							ELSE 'S' 
							END 
						ELSE 
							CASE WHEN Calculate_Days IS NULL and ISNULL(Present_Hours,0) < 5
							THEN 'A' 
							ELSE Presence 
						END 
					END 
				END 
			END 
		END 
	END 
END 
END AS Presence,Early_Count,Late_Count,actual_Early_Sec,actual_late_Sec,wo1.Emp_Late_mark,wo1.Emp_Early_mark,wo1.Is_Late_Mark
INTO  #weekoff_get2_temp
FROM         (SELECT     Cmp_ID, emp_id, branch_id, Increment_ID, id,Extra_AB_Deduction, test1, Week_Day, Week_Count, Can_Weekoff, leaveStatus, Weekoff_as_leave, 
                                              Holiday_as_leave, Leave_Assign_As, weekoff, weekoff2,case when shift_ID_Temp IS null then shift_ID_Per else shift_ID_Temp end as shift_ID_Per, null as shift_ID_Temp, Leave_Code, Present_Hours, Presence, 
                                              Alt_Weekoff_Day, Count1, Count2, Count3, Count4, Count5, left_date, join_date, Chk_By_Superior, Half_Full_day, Is_Split_Shift, 
                                              Is_Night_Shift,Early_Count,Late_Count,actual_Early_Sec,actual_late_Sec,Emp_Late_mark,Emp_Early_mark,Is_Late_Mark
                       FROM          #weekoff_get1_temp) AS wo1 LEFT OUTER JOIN
                          (SELECT     Hday_ID, cmp_Id, Hday_Name, H_From_Date, H_To_Date, Is_Fix, Hday_Ot_setting, Branch_ID, Is_Half, Is_P_Comp, Message_Text, 
                                                   Sms, No_Of_Holiday, System_Date, is_National_Holiday, Is_Optional
                            FROM          T0040_HOLIDAY_MASTER WITH (NOLOCK)
                            WHERE      (H_From_Date BETWEEN @from_date AND @to_date) AND (Is_Fix = 'Y') AND (ISNULL(Is_Optional, 0) = 0)) AS ho1 ON 
                      wo1.Cmp_ID = ho1.cmp_Id AND wo1.branch_id = ho1.Branch_ID AND MONTH(wo1.test1) >= MONTH(ho1.H_From_Date) AND DAY(wo1.test1) 
                      >= DAY(ho1.H_From_Date) AND MONTH(wo1.test1) <= MONTH(ho1.H_To_Date) AND DAY(wo1.test1) <= DAY(ho1.H_To_Date) LEFT OUTER JOIN
                          (SELECT     Hday_ID, cmp_Id, Hday_Name, H_From_Date, H_To_Date, Is_Fix, Hday_Ot_setting, Branch_ID, Is_Half, Is_P_Comp, Message_Text, 
                                                   Sms, No_Of_Holiday, System_Date, is_National_Holiday, Is_Optional
                            FROM          T0040_HOLIDAY_MASTER AS T0040_HOLIDAY_MASTER_1 WITH (NOLOCK)
                            WHERE      (H_From_Date BETWEEN @from_date AND @to_date) AND (Is_Fix = 'N') AND (ISNULL(Is_Optional, 0) = 0)) AS ho2 ON 
                      wo1.Cmp_ID = ho2.cmp_Id AND wo1.branch_id = ho2.Branch_ID AND wo1.test1 >= ho2.H_From_Date AND 
                      wo1.test1 <= ho2.H_To_Date LEFT OUTER JOIN
                          (SELECT     hm.Hday_ID, hm.cmp_Id, hm.Hday_Name, hm.H_From_Date, hm.H_To_Date, hm.Is_Fix, hm.Hday_Ot_setting, hm.Branch_ID, hm.Is_Half, 
                                                   hm.Is_P_Comp, hm.Message_Text, hm.Sms, hm.No_Of_Holiday, hm.System_Date, hm.is_National_Holiday, hm.Is_Optional, 
                                                   ha.Emp_ID
                            FROM          T0040_HOLIDAY_MASTER AS hm WITH (NOLOCK) INNER JOIN
                                                   T0120_Op_Holiday_Approval AS ha WITH (NOLOCK) ON hm.Hday_ID = ha.HDay_ID AND hm.cmp_Id = ha.Cmp_ID
                            WHERE      (hm.Is_Optional = '1') AND (ha.Op_Holiday_Apr_Status = 'A')) AS ho3 ON wo1.Cmp_ID = ho3.cmp_Id AND wo1.emp_id = ho3.Emp_ID AND 
                      wo1.test1 = ho3.H_From_Date AND wo1.test1 = ho3.H_To_Date LEFT OUTER JOIN
                          (SELECT     esd.Emp_ID, esd.Cmp_ID, esd.Shift_ID, esd.Eff_Date_Sd, sd.From_Hour, sd.To_Hour, sd.Calculate_Days, esd.Is_Split_Shift
                            FROM          #v_shift_detail_temp AS esd INNER JOIN
                                                   T0050_SHIFT_DETAIL AS sd WITH (NOLOCK) ON sd.Cmp_ID = esd.Cmp_ID AND esd.Shift_ID = sd.Shift_ID
                            WHERE      (esd.Eff_Date_Sd BETWEEN @from_date AND @to_date)) AS shift_Detail1 ON wo1.emp_id = shift_Detail1.Emp_ID AND 
                      wo1.Cmp_ID = shift_Detail1.Cmp_ID AND ISNULL(wo1.Present_Hours, 0) >= shift_Detail1.From_Hour AND ISNULL(wo1.Present_Hours, 0) 
                      <= shift_Detail1.To_Hour AND wo1.test1 >= shift_Detail1.Eff_Date_Sd and (wo1.shift_ID_Per = shift_Detail1.Shift_ID or wo1.shift_id_temp = shift_Detail1.Shift_ID)

/*	#weekoff_get3_temp is table created to adhere sandwich policy.
	Here we have taken a sub query where Last presence, Next presence, 
	Last Absence and Next Absence is been generated.
	the date difference forms the sandwich policy calculations.
*/

if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#weekoff_get3_temp' and type = 'u') 
begin 
 drop table #weekoff_get3_temp 
end 

CREATE TABLE #weekoff_get3_temp 
(
	Cmp_ID				numeric,
	Emp_ID				numeric,
	Branch_ID			numeric,
	Extra_AB_Deduction	numeric(18,2),
	Shift_ID_Per		numeric,
	ID					varchar(max),
	test1				datetime,
	diff_Lt_p			numeric,
	diff_Lt_A			numeric,
	diff_Nt_p			numeric,
	diff_Nt_A			numeric,
	Week_Day			varchar(max),
	presence			varchar(max),
	Cancel_Weekoff		numeric,
	Cancel_Holiday		numeric, 
	lt_Presence			datetime,
	nt_Presence			datetime, 
	lt_Abs				datetime, 
	nt_Abs				datetime,
	Early_Count			numeric,
	Late_Count			numeric,
	Actual_Early_Sec	numeric,
	Actual_Late_Sec		numeric,
	Emp_Late_mark		numeric,
	Emp_Early_mark		numeric,
	Is_Late_Mark		numeric
)


insert into #weekoff_get3_temp
SELECT     Cmp_ID, emp_id, branch_id,Extra_AB_Deduction, shift_ID_Per, id, test1, 
			DATEDIFF(D, lt_Presence, test1) AS diff_Lt_p, DATEDIFF(D, lt_Abs, test1) AS diff_Lt_A, 
			DATEDIFF(d, test1, nt_Presence) AS diff_Nt_p, 
            DATEDIFF(d, test1, nt_Abs) AS diff_Nt_A, Week_Day, 
            CASE WHEN presence = 'W' 
            THEN 
				CASE WHEN Is_Cancel_Weekoff = 0 
				THEN 'W' 
				ELSE 
					CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) 
                    THEN 'W' 
                    ELSE 'A' 
                    END 
                END 
			ELSE 
				CASE WHEN presence = 'HO' 
				THEN 
					CASE WHEN Is_Cancel_Holiday = 0 
					THEN 'HO' 
					ELSE 
						CASE WHEN DATEDIFF(D,lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) 
						THEN 'HO' 
						ELSE 'A' 
						END 
					END 
				ELSE Presence 
				END 
			END AS presence,
			CASE WHEN presence = 'W' 
            THEN 
				CASE WHEN Is_Cancel_Weekoff = 0 
				THEN 0
				ELSE 
					CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) 
                    THEN 0 
                    ELSE 1 
                    END 
                END 
			ELSE 0
			END AS Cancel_Weekoff,
			CASE WHEN presence = 'W' 
            THEN 
				CASE WHEN Is_Cancel_Weekoff = 0 
				THEN 0 
				ELSE 
					CASE WHEN DATEDIFF(D, lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) 
                    THEN 0 
                    ELSE 0 
                    END 
                END 
			ELSE 
				CASE WHEN presence = 'HO' 
				THEN 
					CASE WHEN Is_Cancel_Holiday = 0 
					THEN 0 
					ELSE 
						CASE WHEN DATEDIFF(D,lt_Presence, test1) < DATEDIFF(D, lt_Abs, test1) OR DATEDIFF(d, test1, nt_Presence) < DATEDIFF(d, test1, nt_Abs) 
						THEN 0 
						ELSE 1 
						END 
					END 
				ELSE 0
				END 
			END AS Cancel_Holiday, lt_Presence, 
                      nt_Presence, lt_Abs, nt_Abs,Early_Count,Late_Count,Actual_Early_Sec,Actual_Late_Sec,Emp_Late_mark,Emp_Early_mark,Is_Late_Mark
FROM         (SELECT     wo3.Cmp_ID, wo3.emp_id, wo3.branch_id, shift_ID_Per, Extra_AB_Deduction, wo3.id, wo3.test1, wo3.Week_Day, wo3.Presence, ISNULL
                                                  ((SELECT     MAX(test1) AS Expr1
                                                      FROM         #weekoff_get2_temp AS wo2
                                                      WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (Presence IN ('P', 'S', 
                                                                            CASE WHEN Is_Cancel_Holiday = 0 THEN 'HO' END, CASE WHEN Is_Cancel_Weekoff = 0 THEN 'W' END)) AND 
                                                                            (test1 < wo3.test1) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CASE WHEN charindex('-', 
                                                                            presence) > 0 THEN LEFT(Presence, charindex('-', presence) - 1) ELSE Presence END IN
                                                                                (SELECT DISTINCT Leave_Code
                                                                                  FROM          #weekoff_get_LM_Temp)) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('LWP', Presence) 
                                                                            <> 0) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('-HF-A', Presence) 
                                                                            <> 0)), DATEADD(d, - 52, wo3.test1)) AS lt_Presence, ISNULL
                                                  ((SELECT     MIN(test1) AS Expr1
                                                      FROM         #weekoff_get2_temp AS wo2
                                                      WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (Presence IN ('P', 'S')) AND (test1 > wo3.test1) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 > wo3.test1) AND (CASE WHEN charindex('-', 
                                                                            presence) > 0 THEN LEFT(Presence, charindex('-', presence) - 1) ELSE Presence END IN
                                                                                (SELECT DISTINCT Leave_Code
                                                                                  FROM          #weekoff_get_LM_Temp))), DATEADD(d, 52, wo3.test1)) AS nt_Presence, ISNULL
                                                  ((SELECT     MAX(test1) AS Expr1
                                                      FROM         #weekoff_get2_temp AS wo2
                                                      WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (Presence IN ('A', 'LWP')) AND (test1 < wo3.test1) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('LWP', Presence) 
                                                                            <> 0) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 < wo3.test1) AND (CHARINDEX('-HF-A', Presence) 
                                                                            <> 0)), DATEADD(d, - 52, wo3.test1)) AS lt_Abs, ISNULL
                                                  ((SELECT     MIN(test1) AS Expr1
                                                      FROM         #weekoff_get2_temp AS wo2
                                                      WHERE     (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (Presence IN ('A', 'LWP')) AND (test1 > wo3.test1) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 > wo3.test1) AND (CHARINDEX('LWP', Presence) 
                                                                 <> 0) OR
                                                                            (emp_id = wo3.emp_id) AND (gs.Branch_ID = wo3.branch_id) AND (test1 > wo3.test1) AND (CHARINDEX('-HF-A', Presence) 
                                                                            <> 0)), DATEADD(d, 52, wo3.test1)) AS nt_Abs, gs.Is_Cancel_Holiday, gs.Is_Cancel_Weekoff,wo3.Early_Count,wo3.Late_Count,
													case when wo3.actual_Early_Sec > 0 then wo3.actual_Early_Sec else 0 end as Actual_Early_Sec,
													case when wo3.actual_late_Sec > 0 then wo3.actual_late_Sec else 0 end as Actual_Late_Sec,Emp_Late_mark,Emp_Early_mark,wo3.Is_Late_Mark
                       FROM          #weekoff_get2_temp AS wo3 INNER JOIN
                                              T0040_GENERAL_SETTING AS gs WITH (NOLOCK) ON wo3.Cmp_ID = gs.Cmp_ID AND wo3.branch_id = gs.Branch_ID) AS t1
WHERE     (test1 BETWEEN DATEADD(d, 10, @from_date) AND DATEADD(d, - 10, @to_date))

/*	Total Counting of various combinations are been done in this column */

if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#total_count' and type = 'u') 
begin 
 drop table #total_count 
end 
SELECT Cmp_ID, emp_id, branch_id, SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 
 0) IN ('HF', 'FH', 'SH') OR
 CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) AS P, SUM(CASE WHEN isnull(Presence, 0) IN ('A') --, 'LWP', 'LWP-HF-A'
 THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
 CHARINDEX('-HF-A', Presence) > 0 
 --OR CHARINDEX('+LWP', Presence) > 0 OR
 --CHARINDEX('LWP+', Presence) > 0 OR
 --CHARINDEX('LWP-', Presence) > 0 
 THEN 0.50 ELSE 0 END END) AS A, 
 SUM(CASE WHEN isnull(Presence, 0) 
 = 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', Presence) > 0 OR
 CHARINDEX('PD+', Presence) > 0 THEN 0.50 ELSE 0 END END) AS L, SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
 isnull(Presence, 0) = 'COM-W' THEN 1 ELSE 0 END) AS W, SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
 isnull(Presence, 0) = 'COM-HO' THEN 1 ELSE 0 END) AS H, 
 SUM(CASE WHEN isnull(Presence, 0) IN ('LWP') --, 'LWP', 'LWP-HF-A'
 THEN 1 ELSE CASE WHEN 
 CHARINDEX('+LWP', Presence) > 0 OR
 CHARINDEX('LWP+', Presence) > 0 OR
 CHARINDEX('LWP-', Presence) > 0 
 THEN 0.50 ELSE 0 END END) AS LWP, 
 CASE WHEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
 THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
 CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) - (SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') 
 THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
 CHARINDEX('-HF-A', Presence) > 0 OR
 CHARINDEX('+LWP', Presence) > 0 OR
 CHARINDEX('LWP+', Presence) > 0 OR
 CHARINDEX('LWP-', Presence) > 0 THEN 0.50 ELSE 0 END END)* Extra_AB_Deduction) > 0 THEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
 THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
 CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) - (SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') 
 THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
 CHARINDEX('-HF-A', Presence) > 0 OR
 CHARINDEX('+LWP', Presence) > 0 OR
 CHARINDEX('LWP+', Presence) > 0 OR
 CHARINDEX('LWP-', Presence) > 0 THEN 0.50 ELSE 0 END END)* Extra_AB_Deduction) ELSE 0 END AS Payable_Present_Days, 
 SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
 CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) 
 = 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', Presence) > 0 OR
 CHARINDEX('PD+', Presence) > 0 THEN 0.50 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
 isnull(Presence, 0) = 'COM-W' THEN 1 ELSE 0 END) + SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
 isnull(Presence, 0) = 'COM-HO' THEN 1 ELSE 0 END) AS Total_Days,SUM(Cancel_Weekoff) as Cancel_Weekoff, SUM(Cancel_Holiday) as Cancel_Holiday,
 SUM(Early_Count) as Early_Count, SUM(Late_Count) as Late_Count
 into #total_count
FROM (SELECT Cmp_ID, emp_id, branch_id, 1 as Extra_AB_Deduction, id, test1, Week_Day, CASE WHEN (presence IN
 ((SELECT leave_code
 FROM #weekoff_get_LM_Temp))) OR
 (CHARINDEX('+', presence) > 0 AND CHARINDEX('LWP', Presence) = 0) THEN 'PD' ELSE CASE WHEN CHARINDEX('-', 
 Presence) = 0 THEN CASE WHEN CHARINDEX('+', Presence) = 0 THEN Presence ELSE CASE WHEN LEFT(Presence, 
 CHARINDEX('+', presence) - 1) IN
 ((SELECT leave_code
 FROM #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('+', presence) + 1) 
 ELSE CASE WHEN RIGHT(presence, len(presence) - charindex('+', presence) + 1) IN
 ((SELECT leave_code
 FROM #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('+', presence) - 1) 
 ELSE presence END END END ELSE CASE WHEN LEFT(Presence, CHARINDEX('-', presence) - 1) IN
 ((SELECT leave_code
 FROM #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('-', presence) + 1) 
 ELSE CASE WHEN RIGHT(presence, len(presence) - charindex('-', presence) + 1) IN
 ((SELECT leave_code
 FROM #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('-', presence) - 1) 
 ELSE presence END END END END AS Presence,Cancel_Holiday,Cancel_Weekoff,Early_Count,Late_Count
 FROM #weekoff_get3_temp where test1 between DATEADD(D,10,@from_date) and DATEADD(d,-10,@to_date)) AS weekoff_Get_Temp
GROUP BY Cmp_ID, emp_id, branch_id,Extra_AB_Deduction


--SELECT Cmp_ID, emp_id, branch_id, SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 
-- 0) IN ('HF', 'FH', 'SH') OR
-- CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) AS P, SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP', 'LWP-HF-A') 
-- THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
-- CHARINDEX('-HF-A', Presence) > 0 OR
-- CHARINDEX('+LWP', Presence) > 0 OR
-- CHARINDEX('LWP+', Presence) > 0 OR
-- CHARINDEX('LWP-', Presence) > 0 THEN 0.50 ELSE 0 END END) AS A, SUM(CASE WHEN isnull(Presence, 0) 
-- = 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', Presence) > 0 OR
-- CHARINDEX('PD+', Presence) > 0 THEN 0.50 ELSE 0 END END) AS L, SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
-- isnull(Presence, 0) = 'CO-W' THEN 1 ELSE 0 END) AS W, SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
-- isnull(Presence, 0) = 'CO-HO' THEN 1 ELSE 0 END) AS H, CASE WHEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
-- THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
-- CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) - SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') 
-- THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
-- CHARINDEX('-HF-A', Presence) > 0 OR
-- CHARINDEX('+LWP', Presence) > 0 OR
-- CHARINDEX('LWP+', Presence) > 0 OR
-- CHARINDEX('LWP-', Presence) > 0 THEN 0.50 ELSE 0 END END) > 0 THEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
-- THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
-- CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) - SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') 
-- THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
-- CHARINDEX('-HF-A', Presence) > 0 OR
-- CHARINDEX('+LWP', Presence) > 0 OR
-- CHARINDEX('LWP+', Presence) > 0 OR
-- CHARINDEX('LWP-', Presence) > 0 THEN 0.50 ELSE 0 END END) ELSE 0 END AS Payable_Present_Days, 
-- SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
-- CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) 
-- = 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', Presence) > 0 OR
-- CHARINDEX('PD+', Presence) > 0 THEN 0.50 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
-- isnull(Presence, 0) = 'CO-W' THEN 1 ELSE 0 END) + SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
-- isnull(Presence, 0) = 'CO-HO' THEN 1 ELSE 0 END) AS Total_Days into #total_count
--FROM (SELECT Cmp_ID, emp_id, branch_id, id, test1, Week_Day, CASE WHEN (presence IN
-- ((SELECT leave_code
-- FROM #weekoff_get_LM_Temp))) OR
-- (CHARINDEX('+', presence) > 0 AND CHARINDEX('LWP', Presence) = 0) THEN 'PD' ELSE CASE WHEN CHARINDEX('-', 
-- Presence) = 0 THEN CASE WHEN CHARINDEX('+', Presence) = 0 THEN Presence ELSE CASE WHEN LEFT(Presence, 
-- CHARINDEX('+', presence) - 1) IN
-- ((SELECT leave_code
-- FROM #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('+', presence) + 1) 
-- ELSE CASE WHEN RIGHT(presence, len(presence) - charindex('+', presence) + 1) IN
-- ((SELECT leave_code
-- FROM #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('+', presence) - 1) 
-- ELSE presence END END END ELSE CASE WHEN LEFT(Presence, CHARINDEX('-', presence) - 1) IN
-- ((SELECT leave_code
-- FROM #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('-', presence) + 1) 
-- ELSE CASE WHEN RIGHT(presence, len(presence) - charindex('-', presence) + 1) IN
-- ((SELECT leave_code
-- FROM #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('-', presence) - 1) 
-- ELSE presence END END END END AS Presence
-- FROM #weekoff_get3_temp where test1 between DATEADD(D,10,@from_date) and DATEADD(d,-10,@to_date)) AS weekoff_Get_Temp
--GROUP BY Cmp_ID, emp_id, branch_id



IF @Report_For = '' and @Export_Type = 'EXCEL'
BEGIN
		/*	This section forms the logic of dynamic pivot table columns */
	declare @flag_month as varchar(max) 
Set @flag_month = ''
	select @flag_month = right((select top 1 ID from #weekoff_get3_temp),4)

	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = 'weekoff_get4_temp' and type = 'u') 
	begin 
	 drop table weekoff_get4_temp 
	end 
	DECLARE @colsPivot AS NVARCHAR(MAX), 
	 @query AS NVARCHAR(MAX) 

	select @colsPivot = STUFF((SELECT ',' + QUOTENAME(cast(id as varchar(10))) 
	 from #weekoff_get3_temp 
	 cross apply ( select 'date' col, 1 so ) c 
	 group by col,test1, id, so 
	 order by test1, so 
	 FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')
	 
	 --set @colsPivot = REPLACE(@colsPivot,@flag_month,'')
	 
	set @query = 'select Emp_id, '+@colsPivot+' into weekoff_get4_temp 
	from ( select emp_id,id, presence from #weekoff_get3_temp) 
	as data pivot 
	( max(presence) 
	for id in ('+ @colspivot +') ) p' 
	 

	 
	exec(@query) 


	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = 'weekoff_get5_temp' and type = 'u') 
	begin 
		drop table weekoff_get5_temp 
	end 

	/*	This query forms the final output by joining PIVOT Table and total count table */
	declare @qry as varchar(6000) 
	set @qry = 'SELECT ROW_NUMBER()  OVER (ORDER BY wo3.Emp_Id) As SrNo,EM.Emp_Code,EM.Emp_Full_Name,replace(convert(nvarchar(11),Date_of_Join,106),'' '',''-'') as Date_of_Join,
				Enroll_No, '+@colsPivot+', P,A,L,W,H,LWP,Payable_Present_Days,
				Total_Days into weekoff_get5_temp
				FROM weekoff_get4_temp as wo3 inner join 
				T0080_EMP_MASTER as EM WITH (NOLOCK) on wo3.Emp_ID = em.Emp_ID 
				inner join #total_count on wo3.emp_id = #total_count.emp_id order by wo3.Emp_ID' 
	exec (@qry)

	declare @id_1 as varchar(max)
	declare @qry2 as varchar(max)
	declare @id_2 as varchar(max) 

	Set @id_1  = ''
	Set  @qry2 = ''
	Set  @id_2 = ''
	
	declare id_Ren cursor for
	select distinct id from #weekoff_get3_temp 
	open id_Ren
	fetch next from id_Ren into @id_1
	while @@fetch_status = 0
	begin
		set @qry2 = 'weekoff_get5_temp.' + @id_1
		set @id_2 = REPLACE(@id_1,@flag_month,'')
		
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
		SELECT		Cmp_ID, emp_id, branch_id, dateadd(d,10,@from_date) as From_date, dateadd(d,-10,@to_date) as To_date,
						cast(P as decimal(18,2)) P, cast(A as decimal(18,2)) A, 
						cast(L as decimal(18,2)) L, cast(W as decimal(18,2)) W, 
						cast(H as decimal(18,2)) H, cast(LWP as decimal(18,2)) LWP, 
						cast(Payable_Present_Days as decimal(18,2)) Payable_Present_Days, cast(Total_Days as decimal(18,2)) Total_Days
		FROM         #total_count
	end
	drop table weekoff_get4_temp 
	drop table weekoff_get5_temp
	drop table #total_count 
END
else if @Report_For = 'Absent' and @Export_Type <> 'EXCEL'
begin
	
	SELECT		wo1.Emp_ID, wo1.Cmp_ID, test1 as For_Date,
				case when CHARINDEX('COM-',presence) > 0 then 'P' else presence end as [Status], 
				case when presence = 'PL' then 1 else case when case when charindex('-',presence)>0 then LEFT(presence,charindex('-',presence)-1) else null end in (select distinct leave_code from #weekoff_get_LM_Temp) then 0.50 else NULL end end as Leave_Count, 
				case when presence IN ('HO','COM-HO','W','COM-W') then case when presence IN ('HO','COM-HO') then 'HO' else 'W' end else NULL end as WO_HO, 
				case when presence IN ('COM-HO','COM-W') then presence else case when presence In (select distinct leave_code from #weekoff_get_LM_Temp) then '1' else NULL end end as Status_2, 
				cast(LEFT(id,CHARINDEX('-',id)-1) as numeric) as Row_ID,
				case when presence IN ('HO','COM-HO','W','COM-W') then 1 else 0 end as WO_HO_Day,
				case when presence IN ('P','S') then 1 else case when (presence like '%HF%' OR CHARINDEX('FH',presence)>0 or CHARINDEX('SH',presence)>0) and presence not like '%HF-A' then 0.50 else 0 end end as P_Days,
				case when presence IN ('A') then 1 else case when presence like '%HF-A' then 0.50 else 0 end end as A_Days,
				em1.Join_Date as Join_Date,em1.left_date,shift_ID_Per as Shift_ID,em1.Emp_Code,em2.Emp_Full_Name as Emp_Full_Name,
				bm.Branch_Address,Comp_Name,bm.Branch_Name,dm.Dept_Name,gm.Grd_Name,dsm.Desig_Name,
				dateadd(d,10,@from_date) as P_From_Date,dateadd(d,-10,@to_date) as P_To_Date,
				wo1.Branch_ID, shift_name, Cmp_Name,Cmp_Address
	FROM         #weekoff_get3_temp wo1 inner join #V_Emp_Get_Info as em1 on wo1.Emp_ID = em1.Emp_ID and wo1.Cmp_ID = em1.Cmp_ID
				inner join T0080_EMP_MASTER as em2 WITH (NOLOCK) on wo1.Emp_ID = em2.Emp_ID and em2.Cmp_ID = wo1.Cmp_ID
				inner join T0030_BRANCH_MASTER as bm WITH (NOLOCK) on wo1.Branch_ID = bm.Branch_ID and wo1.Cmp_ID = bm.Cmp_ID
				inner join T0010_COMPANY_MASTER as cm WITH (NOLOCK) on wo1.Cmp_ID = cm.Cmp_Id
				inner Join T0040_DEPARTMENT_MASTER as dm WITH (NOLOCK) on dm.Dept_Id = em1.Dept_ID and dm.Cmp_Id = em1.Cmp_ID
				inner join T0040_GRADE_MASTER as gm WITH (NOLOCK) on em1.Grd_ID = gm.Grd_ID and em1.Cmp_ID = gm.Cmp_ID
				inner join T0040_DESIGNATION_MASTER as dsm WITH (NOLOCK) on em1.Desig_Id = dsm.Desig_ID and em1.Cmp_ID = dsm.Cmp_ID
				inner join T0040_SHIFT_MASTER as sm WITH (NOLOCK) on sm.Shift_ID = wo1.shift_ID_Per and sm.Cmp_ID = wo1.Cmp_ID
	WHERE presence in ('A','HF') or presence like '%HF-A'
	order by wo1.Emp_ID,For_Date

end
else if @Report_For = ''
begin

	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = 'temp_Total' and type = 'u') 
	begin 
		drop table temp_Total
	end 


	SELECT     Cmp_ID, branch_id, emp_id, Status, Row_ID into temp_Total
	FROM         (SELECT     Cmp_ID, branch_id, emp_id, P AS Status, 32 AS Row_ID
						   FROM          #total_count
						   UNION
						   SELECT     Cmp_ID, branch_id, emp_id, A AS Status, 33 AS Row_ID
						   FROM         #total_count
						   UNION
						   SELECT     Cmp_ID, branch_id, emp_id, L AS Status, 34 AS Row_ID
						   FROM         #total_count
						   UNION
						   SELECT     Cmp_ID, branch_id, emp_id, W AS Status, 35 AS Row_ID
						   FROM         #total_count
						   UNION
						   SELECT     Cmp_ID, branch_id, emp_id, H AS Status, 36 AS Row_ID
						   FROM         #total_count
						   UNION
						   SELECT     Cmp_ID, branch_id, emp_id, Payable_Present_Days AS Status, 37 AS Row_ID
						   FROM         #total_count) AS a
	ORDER BY emp_id, Row_ID

	
	select * from (
	SELECT		wo1.Emp_ID, wo1.Cmp_ID, test1 as For_Date,
				case when CHARINDEX('COM-',presence) > 0 then 'P' else presence end as [Status], 
				case when presence = 'PL' then 1 else case when case when charindex('-',presence)>0 then LEFT(presence,charindex('-',presence)-1) else null end in (select distinct leave_code from #weekoff_get_LM_Temp) then 0.50 else NULL end end as Leave_Count, 
				case when presence IN ('HO','COM-HO','W','COM-W') then case when presence IN ('HO','COM-HO') then 'HO' else 'W' end else NULL end as WO_HO, 
				case when presence IN ('COM-HO','COM-W') then presence else case when presence In (select distinct leave_code from #weekoff_get_LM_Temp) then '1' else NULL end end as Status_2, 
				cast(LEFT(id,CHARINDEX('-',id)-1) as numeric) as Row_ID,
				case when presence IN ('HO','COM-HO','W','COM-W') then 1 else 0 end as WO_HO_Day,
				case when presence IN ('P','S') then 1 else case when (presence like '%HF%' OR CHARINDEX('FH',presence)>0 or CHARINDEX('SH',presence)>0) and presence not like '%HF-A' then 0.50 else 0 end end as P_Days,
				case when presence IN ('A') then 1 else case when presence like '%HF-A' then 0.50 else 0 end end as A_Days,
				em1.Join_Date as Join_Date,em1.left_date,em1.Emp_Code,cast(em1.Emp_Code as varchar(max)) + ' - ' + em2.Emp_Full_Name as Emp_Full_Name,
				bm.Branch_Address,Comp_Name,bm.Branch_Name,dm.Dept_Name,gm.Grd_Name,dsm.Desig_Name,
				dateadd(d,10,@from_date) as P_From_Date,dateadd(d,-10,@to_date) as P_To_Date,
				wo1.Branch_ID,   @leave_footer as Leave_Footer
	FROM         #weekoff_get3_temp wo1 inner join #V_Emp_Get_Info as em1 on wo1.Emp_ID = em1.Emp_ID and wo1.Cmp_ID = em1.Cmp_ID
				inner join T0080_EMP_MASTER as em2 WITH (NOLOCK) on wo1.Emp_ID = em2.Emp_ID and em2.Cmp_ID = wo1.Cmp_ID
				inner join T0030_BRANCH_MASTER as bm WITH (NOLOCK) on wo1.Branch_ID = bm.Branch_ID and wo1.Cmp_ID = bm.Cmp_ID
				inner join T0010_COMPANY_MASTER as cm WITH (NOLOCK) on wo1.Cmp_ID = cm.Cmp_Id
				inner Join T0040_DEPARTMENT_MASTER as dm WITH (NOLOCK) on dm.Dept_Id = em1.Dept_ID and dm.Cmp_Id = em1.Cmp_ID
				inner join T0040_GRADE_MASTER as gm WITH (NOLOCK) on em1.Grd_ID = gm.Grd_ID and em1.Cmp_ID = gm.Cmp_ID
				inner join T0040_DESIGNATION_MASTER as dsm WITH (NOLOCK) on em1.Desig_Id = dsm.Desig_ID and em1.Cmp_ID = dsm.Cmp_ID
				inner join T0040_SHIFT_MASTER as sm WITH (NOLOCK) on sm.Shift_ID = wo1.shift_ID_Per and sm.Cmp_ID = wo1.Cmp_ID
	union
	select		wo1.Emp_ID,wo1.Cmp_ID,null as For_Date,
				cast([Status] as varchar(max)) as [Status], 
				null as Leave_Count,
				null as WO_HO,
				null as Status_2, 
				Row_ID,
				0 as WO_HO_Day,
				0 as P_Days,
				0 as A_Days, 
				em1.Join_Date as Join_Date, em1.left_date,em1.Emp_Code,cast(em1.Emp_Code as varchar(max)) + ' - ' + em2.Emp_Full_Name as Emp_Full_Name,
				bm.Branch_Address,Comp_Name,bm.Branch_Name,dm.Dept_Name,gm.Grd_Name,dsm.Desig_Name,
				dateadd(d,10,@from_date) as P_From_Date,dateadd(d,-10,@to_date) as P_To_Date,
				wo1.Branch_ID,   @leave_footer as Leave_Footer
	from temp_total as wo1 inner join #V_Emp_Get_Info as em1 on wo1.Emp_ID = em1.Emp_ID and wo1.Cmp_ID = em1.Cmp_ID
				inner join T0080_EMP_MASTER as em2 WITH (NOLOCK) on wo1.Emp_ID = em2.Emp_ID and em2.Cmp_ID = wo1.Cmp_ID
				inner join T0030_BRANCH_MASTER as bm WITH (NOLOCK) on wo1.Branch_ID = bm.Branch_ID and wo1.Cmp_ID = bm.Cmp_ID
				inner join T0010_COMPANY_MASTER as cm WITH (NOLOCK) on wo1.Cmp_ID = cm.Cmp_Id
				inner Join T0040_DEPARTMENT_MASTER as dm WITH (NOLOCK) on dm.Dept_Id = em1.Dept_ID and dm.Cmp_Id = em1.Cmp_ID
				inner join T0040_GRADE_MASTER as gm WITH (NOLOCK) on em1.Grd_ID = gm.Grd_ID and em1.Cmp_ID = gm.Cmp_ID
				inner join T0040_DESIGNATION_MASTER as dsm WITH (NOLOCK) on em1.Desig_Id = dsm.Desig_ID and em1.Cmp_ID = dsm.Cmp_ID
	) as a
	ORDER BY Emp_ID,Row_ID
	
	drop table temp_Total
	
	
end
else if @Report_For = 'Salary_Report'
begin
	
	
	SELECT Cmp_ID, emp_id, branch_id,test1 as For_Date, SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 
	0) IN ('HF', 'FH', 'SH') OR
	CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) AS P, SUM(CASE WHEN isnull(Presence, 0) IN ('A') --, 'LWP', 'LWP-HF-A'
	THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
	CHARINDEX('-HF-A', Presence) > 0 
	--OR CHARINDEX('+LWP', Presence) > 0 OR
	--CHARINDEX('LWP+', Presence) > 0 OR
	--CHARINDEX('LWP-', Presence) > 0 
	THEN 0.50 ELSE 0 END END) AS A, 
	SUM(CASE WHEN isnull(Presence, 0) 
	= 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', Presence) > 0 OR
	CHARINDEX('PD+', Presence) > 0 THEN 0.50 ELSE 0 END END) AS L, SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
	isnull(Presence, 0) = 'COM-W' THEN 1 ELSE 0 END) AS W, SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
	isnull(Presence, 0) = 'COM-HO' THEN 1 ELSE 0 END) AS H, 
	SUM(CASE WHEN isnull(Presence, 0) IN ('LWP') --, 'LWP', 'LWP-HF-A'
	THEN 1 ELSE CASE WHEN 
	CHARINDEX('+LWP', Presence) > 0 OR
	CHARINDEX('LWP+', Presence) > 0 OR
	CHARINDEX('LWP-', Presence) > 0 
	THEN 0.50 ELSE 0 END END) AS LWP, 
	CASE WHEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
	THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
	CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) - (SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') 
	THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
	CHARINDEX('-HF-A', Presence) > 0 OR
	CHARINDEX('+LWP', Presence) > 0 OR
	CHARINDEX('LWP+', Presence) > 0 OR
	CHARINDEX('LWP-', Presence) > 0 THEN 0.50 ELSE 0 END END)* Extra_AB_Deduction) > 0 THEN SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') 
	THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
	CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) - (SUM(CASE WHEN isnull(Presence, 0) IN ('A', 'LWP') 
	THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('FH', 'SH', 'HF') OR
	CHARINDEX('-HF-A', Presence) > 0 OR
	CHARINDEX('+LWP', Presence) > 0 OR
	CHARINDEX('LWP+', Presence) > 0 OR
	CHARINDEX('LWP-', Presence) > 0 THEN 0.50 ELSE 0 END END)* Extra_AB_Deduction) ELSE 0 END AS Payable_Present_Days, 
	SUM(CASE WHEN isnull(Presence, 0) IN ('P', 'S') THEN 1 ELSE CASE WHEN isnull(Presence, 0) IN ('HF', 'FH', 'SH') OR
	CHARINDEX('-HF-P', Presence) > 0 THEN 0.50 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) 
	= 'PD' THEN 1 ELSE CASE WHEN CHARINDEX('PD-', Presence) > 0 OR
	CHARINDEX('PD+', Presence) > 0 THEN 0.50 ELSE 0 END END) + SUM(CASE WHEN isnull(Presence, 0) = 'W' OR
	isnull(Presence, 0) = 'COM-W' THEN 1 ELSE 0 END) + SUM(CASE WHEN isnull(Presence, 0) = 'HO' OR
	isnull(Presence, 0) = 'COM-HO' THEN 1 ELSE 0 END) AS Total_Days ,SUM(Cancel_Weekoff) as Cancel_Weekoff, SUM(Cancel_Holiday) as Cancel_Holiday,
	SUM(case when Emp_Early_mark > 0 then Early_Count else 0 end) as Early_Count,SUM(case when Is_Late_Mark > 0 then case when Emp_Late_mark > 0 then Late_Count else 0 end else 0 end) as Late_Count,
	SUM(Actual_Early_Sec) as Actual_Early_Sec, SUM(Actual_Late_Sec) as Actual_Late_Sec	
	FROM (SELECT Cmp_ID, emp_id, branch_id, 1 as Extra_AB_Deduction, id, test1, Week_Day, CASE WHEN (presence IN
	((SELECT leave_code
	FROM #weekoff_get_LM_Temp))) OR
	(CHARINDEX('+', presence) > 0 AND CHARINDEX('LWP', Presence) = 0) THEN 'PD' ELSE CASE WHEN CHARINDEX('-', 
	Presence) = 0 THEN CASE WHEN CHARINDEX('+', Presence) = 0 THEN Presence ELSE CASE WHEN LEFT(Presence, 
	CHARINDEX('+', presence) - 1) IN
	((SELECT leave_code
	FROM #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('+', presence) + 1) 
	ELSE CASE WHEN RIGHT(presence, len(presence) - charindex('+', presence) + 1) IN
	((SELECT leave_code
	FROM #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('+', presence) - 1) 
	ELSE presence END END END ELSE CASE WHEN LEFT(Presence, CHARINDEX('-', presence) - 1) IN
	((SELECT leave_code
	FROM #weekoff_get_LM_Temp)) THEN 'PD' + RIGHT(presence, len(presence) - charindex('-', presence) + 1) 
	ELSE CASE WHEN RIGHT(presence, len(presence) - charindex('-', presence) + 1) IN
	((SELECT leave_code
	FROM #weekoff_get_LM_Temp)) THEN 'PD' + LEFT(Presence, CHARINDEX('-', presence) - 1) 
	ELSE presence END END END END AS Presence,Cancel_Holiday,Cancel_Weekoff,Early_Count,Late_Count,Actual_Early_Sec,Actual_Late_Sec
	,Emp_Late_mark,Emp_Early_mark,Is_Late_Mark
	FROM #weekoff_get3_temp where test1 between DATEADD(D,10,@from_date) and DATEADD(d,-10,@to_date)) AS weekoff_Get_Temp
	GROUP BY Cmp_ID, emp_id, branch_id,Extra_AB_Deduction,test1
end
else
begin
	select * from #total_count
end



/*	Temporary tables are deleted here	*/ 


--drop table #V_Emp_Get_Info 
--drop table #v_shift_detail_temp 
--drop table #v_weekoff_temp_temp 
--drop table #v_alt_weekoff_temp_temp  
--drop table #v_Emp_InOut_Record_temp 
--drop table #weekoff_get1_temp 
--drop table #weekoff_get2_temp 
--drop table #weekoff_get3_temp 
----drop table #total_count 
--drop table #weekoff_get_LM_Temp 
END
