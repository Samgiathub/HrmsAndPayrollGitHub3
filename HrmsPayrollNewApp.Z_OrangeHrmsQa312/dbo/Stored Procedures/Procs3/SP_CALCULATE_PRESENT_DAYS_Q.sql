


-- =============================================
-- Author:		Siddharth Pathak
-- ALTER date: 15/12/2013
-- Description:	SP_CALCULATE_PRESENT_DAYS
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_CALCULATE_PRESENT_DAYS_Q] 
	-- Add the parameters for the stored procedure here
  @Cmp_ID    numeric        
 ,@From_Date   datetime        
 ,@To_Date    datetime         
 ,@Branch_ID   numeric        
 ,@Cat_ID    numeric         
 ,@Grd_ID    numeric        
 ,@Type_ID    numeric        
 ,@Dept_ID    numeric        
 ,@Desig_ID    numeric        
 ,@Emp_ID    VARCHAR(MAX)        
 ,@constraint   varchar(5000)        
 ,@Return_Record_set numeric = 1 
 ,@StrWeekoff_Date varchar(Max)  =''
 ,@Is_Split_Shift_Req tinyint = 0
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN


DECLARE @Chk_Emp_ID varchar(max)

if @Emp_ID <> '0'
begin
	set @chk_emp_id = ' and ec.Emp_ID in ('+@emp_id+')'
end
else
begin
	set @Chk_Emp_ID = ''
end


exec getAllDaysBetweenTwoDate @from_date, @to_date


if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_EMP_TEMP' and type = 'u')
begin
	DROP TABLE #v_EMP_TEMP
end

DECLARE @Q1 AS VARCHAR(MAX)

CREATE table #v_EMP_TEMP
(
	Cmp_ID		numeric,
	Emp_ID		numeric,
	Branch_ID	numeric
)

SET @Q1 = '	INSERT INTO #v_EMP_TEMP
			SELECT DISTINCT Cmp_ID, Emp_ID, Branch_ID
			FROM (	SELECT     ec.Cmp_ID, ec.Emp_ID, ec.Branch_ID
					FROM          T0095_INCREMENT AS ec WITH (NOLOCK) INNER JOIN
						(SELECT     Emp_ID, MAX(Increment_Effective_Date) AS Increment_effective_date
                         FROM          T0095_INCREMENT WITH (NOLOCK)
                         GROUP BY Emp_ID) AS inc ON ec.Emp_ID = inc.Emp_ID AND 
                         ec.Increment_Effective_Date = inc.Increment_effective_date '+@Chk_Emp_ID+' ) AS a'


EXEC (@Q1)




if exists(select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_weekoff_temp_temp' and type = 'u') 
begin 
 drop table #v_weekoff_temp_temp 
end 

SELECT DISTINCT a.Cmp_ID, a.Emp_ID, For_Date, eff_date, weekoff_Day1, weekoff_Day2
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
                       inner join #v_EMP_TEMP ec on ec.emp_id = a.Emp_ID and ec.cmp_id = a.Cmp_ID



if exists(select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_alt_weekoff_temp_temp' and type = 'u') 
begin 
 drop table #v_alt_weekoff_temp_temp 
end 

SELECT DISTINCT a.Cmp_ID, a.Emp_ID, eff_date, Alt_Weekoff_day, Count1, Count2, Count3, Count4, Count5
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
                       inner join #v_EMP_TEMP ec on ec.emp_id = a.Emp_ID and ec.cmp_id = a.Cmp_ID


if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#v_shift_detail_temp' and type = 'u') 
begin 
 drop table #v_shift_detail_temp 
end

SELECT     a.Emp_ID, a.Cmp_ID, Shift_ID, For_Date, Eff_Date_Sd, Shift_St_Time, Shift_End_Time, Is_Night_Shift, Is_Split_Shift,
                                              F_St_Time,F_End_Time,S_St_Time,S_End_Time,T_St_Time,T_End_Time,Shift_Dur
INTO            #v_shift_detail_temp
FROM         (SELECT     a.Emp_ID, a.Cmp_ID, a.Shift_ID, a.For_Date, a.Expr1 AS Eff_Date_Sd, sm.Shift_St_Time, sm.Shift_End_Time, 
                                              CASE WHEN sm.Shift_St_Time > sm.Shift_End_Time THEN 1 ELSE 0 END AS Is_Night_Shift, sm.Is_Split_Shift,
                                              sm.F_St_Time,sm.F_End_Time,sm.S_St_Time,sm.S_End_Time,sm.T_St_Time,sm.T_End_Time,sm.Shift_Dur
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
                                               SELECT     Emp_ID, Cmp_ID, Shift_ID, For_Date, For_Date AS Expr1
                                               FROM         T0100_EMP_SHIFT_DETAIL AS sd1 WITH (NOLOCK)
                                               WHERE     (For_Date BETWEEN @from_date AND @to_date)) AS a INNER JOIN
                                              T0040_SHIFT_MASTER AS sm WITH (NOLOCK) ON a.Shift_ID = sm.Shift_ID) AS a
                                              inner join #v_EMP_TEMP as ec on a.Emp_ID = ec.emp_id and a.Cmp_ID = ec.cmp_id



if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#Calc_Present_Day1' and type = 'u') 
begin 
 drop table #Calc_Present_Day1 
end

               
SELECT     IO_Tran_Id, Branch_ID, Emp_ID, Cmp_ID, For_Date, CASE WHEN Is_Night_Shift = 1 THEN CASE WHEN Is_Split_Shift = 1 
	THEN DATEADD(HOUR, - 3, In_Time) ELSE DATEADD(HOUR, - 9, In_Time) END ELSE In_Time END AS In_Time,CASE WHEN Is_Night_Shift = 1 THEN 
	CASE WHEN Is_Split_Shift = 1 THEN DATEADD(HOUR, - 3, Out_Time) 	ELSE DATEADD(HOUR, - 9, Out_Time) END ELSE Out_Time END AS Out_Time, 
	Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App, Chk_By_Superior, Sup_Comment, Half_Full_day, 
	Is_Cancel_Late_In, Is_Cancel_Early_Out, Is_Default_In, Is_Default_Out, Cmp_prp_in_flag, Cmp_prp_out_flag, Shift_St_Time, Shift_End_Time, 
	is_Cmp_purpose, Is_Night_Shift, Shift_ID, F_ST_Time, F_End_Time, S_St_Time, S_End_Time, weekoff_Day1, weekoff_Day2, HFix,HUnFix,HOpt,Shift_Dur
INTO            #Calc_Present_Day1
FROM         (SELECT     IO_Tran_Id, EIR_1.Branch_ID, EIR_1.Emp_ID, EIR_1.Cmp_ID, EIR_1.For_Date, In_Time, ISNULL(Out_Time, In_Time) AS Out_Time, Duration, 
                                              Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App, Chk_By_Superior, Sup_Comment, Half_Full_day, 
                                              Is_Cancel_Late_In, Is_Cancel_Early_Out, Is_Default_In, Is_Default_Out, Cmp_prp_in_flag, Cmp_prp_out_flag, is_Cmp_purpose,
                                              ho1.Hday_ID as HFix,ho2.Hday_ID as HUnFix,ho3.Hday_ID as HOpt,
                                                  (SELECT     Is_Night_Shift
                                                    FROM          #v_shift_detail_temp
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_17
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS Is_Night_Shift,
                                                  (SELECT     Is_Split_Shift
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_16
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_15
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS Is_Split_Shift,
                                                  (SELECT     Shift_ID
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_14
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_13
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS Shift_ID,
                                                  (SELECT     Shift_Dur
                                                    FROM          #v_shift_detail_temp 
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_13
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS Shift_Dur,
                                                  (SELECT     Shift_St_Time
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_12
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_11
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS Shift_St_Time,
                                                  (SELECT     Shift_End_Time
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_10
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_9
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS Shift_End_Time,
                                                  (SELECT     F_St_Time
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_8
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_7
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS F_ST_Time,
                                                  (SELECT     F_End_Time
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_6
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_5
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS F_End_Time,
                                                  (SELECT     S_St_Time
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_4
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_3
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS S_St_Time,
                                                  (SELECT     S_End_Time
                                                    FROM          #v_shift_detail_temp AS #v_shift_detail_temp_2
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd =
                                                                               (SELECT     MAX(Eff_Date_Sd) AS Expr1
                                                                                 FROM          #v_shift_detail_temp AS #v_shift_detail_temp_1
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (Eff_Date_Sd <= EIR_1.For_Date)))) AS S_End_Time,
                                                  (SELECT     weekoff_Day1
                                                    FROM          #v_weekoff_temp_temp
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (eff_date =
                                                                               (SELECT     MAX(eff_date) AS Expr1
                                                                                 FROM          #v_weekoff_temp_temp AS #v_weekoff_temp_temp_3
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (eff_date <= EIR_1.For_Date)))) AS weekoff_Day1,
                                                  (SELECT     weekoff_Day2
                                                    FROM          #v_weekoff_temp_temp AS #v_weekoff_temp_temp_2
                                                    WHERE      (Emp_ID = EIR_1.Emp_ID) AND (eff_date =
                                                                               (SELECT     MAX(eff_date) AS Expr1
                                                                                 FROM          #v_weekoff_temp_temp AS #v_weekoff_temp_temp_1
                                                                                 WHERE      (Emp_ID = EIR_1.Emp_ID) AND (eff_date <= EIR_1.For_Date)))) AS weekoff_Day2
                       FROM          (SELECT     t1.IO_Tran_Id, t1.Emp_ID, t1.Cmp_ID, ec.Branch_ID, CAST(DATEADD(hour, -6, ISNULL(t1.Out_Time, isnull(t1.In_Time,for_date))) AS DATE) 
                                                                      AS For_Date, isnull(t1.In_Time,t1.For_Date) as In_Time, isnull(t1.Out_Time,isnull(t1.In_Time,t1.For_Date)) as Out_Time, t1.Duration, t1.Reason, t1.Ip_Address, t1.In_Date_Time, t1.Out_Date_Time, t1.Skip_Count, 
                                                                      t1.Late_Calc_Not_App, t1.Chk_By_Superior, t1.Sup_Comment, t1.Half_Full_day, t1.Is_Cancel_Late_In, t1.Is_Cancel_Early_Out, 
                                                                      t1.Is_Default_In, t1.Is_Default_Out, t1.Cmp_prp_in_flag, t1.Cmp_prp_out_flag, t1.is_Cmp_purpose
                                               FROM          T0150_EMP_INOUT_RECORD AS t1 WITH (NOLOCK)  INNER JOIN  
                                                                          #v_EMP_TEMP AS ec ON ec.Emp_ID = t1.Emp_ID AND
                                                                       ec.Cmp_ID = t1.Cmp_ID) AS EIR_1 
                                                                       LEFT OUTER JOIN
                                                  (SELECT     Hday_ID, cmp_Id, Hday_Name, H_From_Date, H_To_Date, Is_Fix, Hday_Ot_setting, Branch_ID, Is_Half, Is_P_Comp, 
                                                                           Message_Text, Sms, No_Of_Holiday, System_Date, is_National_Holiday, Is_Optional
                                                    FROM          T0040_HOLIDAY_MASTER WITH (NOLOCK)
                                                    WHERE      (H_From_Date BETWEEN @from_date AND @to_date) AND (Is_Fix = 'Y') AND (ISNULL(Is_Optional, 0) = 0)) AS ho1 ON 
                                              EIR_1.Cmp_ID = ho1.cmp_Id AND EIR_1.Branch_ID = ho1.Branch_ID AND MONTH(EIR_1.For_Date) >= MONTH(ho1.H_From_Date) AND 
                                              DAY(EIR_1.For_Date) >= DAY(ho1.H_From_Date) AND MONTH(EIR_1.For_Date) <= MONTH(ho1.H_To_Date) AND DAY(EIR_1.For_Date) 
                                              <= DAY(ho1.H_To_Date) LEFT OUTER JOIN
                                                  (SELECT     Hday_ID, cmp_Id, Hday_Name, H_From_Date, H_To_Date, Is_Fix, Hday_Ot_setting, Branch_ID, Is_Half, Is_P_Comp, 
                                                                           Message_Text, Sms, No_Of_Holiday, System_Date, is_National_Holiday, Is_Optional
                                                    FROM          T0040_HOLIDAY_MASTER AS T0040_HOLIDAY_MASTER_1 WITH (NOLOCK)
                                                    WHERE      (H_From_Date BETWEEN @from_date AND @to_date) AND (Is_Fix = 'N') AND (ISNULL(Is_Optional, 0) = 0)) AS ho2 ON 
                                              EIR_1.Cmp_ID = ho2.cmp_Id AND EIR_1.Branch_ID = ho2.Branch_ID AND EIR_1.For_Date >= ho2.H_From_Date AND 
                                              EIR_1.For_Date <= ho2.H_To_Date LEFT OUTER JOIN
                                                  (SELECT     hm.Hday_ID, hm.cmp_Id, hm.Hday_Name, hm.H_From_Date, hm.H_To_Date, hm.Is_Fix, hm.Hday_Ot_setting, hm.Branch_ID, 
                                                                           hm.Is_Half, hm.Is_P_Comp, hm.Message_Text, hm.Sms, hm.No_Of_Holiday, hm.System_Date, hm.is_National_Holiday, 
                                                                           hm.Is_Optional, ha.Emp_ID
                                                    FROM          T0040_HOLIDAY_MASTER AS hm WITH (NOLOCK) INNER JOIN
                                                                           T0120_Op_Holiday_Approval AS ha WITH (NOLOCK) ON hm.Hday_ID = ha.HDay_ID AND hm.cmp_Id = ha.Cmp_ID
                                                    WHERE      (hm.Is_Optional = '1') AND (ha.Op_Holiday_Apr_Status = 'A')) AS ho3 ON EIR_1.Cmp_ID = ho3.cmp_Id AND 
                                              EIR_1.Emp_ID = ho3.Emp_ID AND EIR_1.For_Date = ho3.H_From_Date AND EIR_1.For_Date = ho3.H_To_Date
                       WHERE      (EIR_1.For_Date >= @from_date) AND (EIR_1.For_Date <= @to_date)) AS EIR_2



if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#Calc_Present_Day2' and type = 'u') 
begin 
 drop table #Calc_Present_Day2 
end


SELECT     EIR.Emp_ID, CAST(CONVERT(NVARCHAR(10), MAX(EIR.Out_Time), 101) AS DATETIME) AS FOR_DATE, 
CASE WHEN DATENAME(DW, eir.For_Date) = weekoff_Day1 OR DATENAME(DW, eir.For_Date) = weekoff_Day2 OR HFix IS NOT NULL OR HUnFix IS NOT NULL OR HOpt IS NOT NULL
THEN 0 
ELSE 
	CASE WHEN First_In_Last_Out_For_InOut_Calculation = 0 
	THEN case when dbo.F_Return_Sec(Shift_Dur) <= SUM(DATEDIFF(s, In_Time, Out_Time))  then dbo.F_Return_Sec(Shift_Dur) else SUM(DATEDIFF(s, In_Time, Out_Time)) end
	ELSE case when dbo.F_Return_Sec(Shift_Dur) <= DATEDIFF(s, MIN(In_Time), MAX(Out_Time)) then dbo.F_Return_Sec(Shift_Dur) else DATEDIFF(s, MIN(In_Time), MAX(Out_Time)) end
	END 
END AS Duration, 
EIR.Shift_ID, NULL AS Shift_type, a_1.Emp_OT, dbo.F_Return_Sec(a_1.Emp_OT_Min_Limit) AS Emp_OT_Min_Limit, dbo.F_Return_Sec(a_1.Emp_OT_Max_Limit) AS Emp_OT_Max_Limit, 
CASE WHEN Emp_OT = 1 AND (OTA.Is_Approved = 1 OR T0040_GENERAL_SETTING.Is_OT_Auto_Calc = 1)
THEN 
	CASE WHEN DATENAME(DW, eir.For_Date) = weekoff_Day1 OR DATENAME(DW, eir.For_Date) = weekoff_Day2 OR HFix IS NOT NULL OR HUnFix IS NOT NULL OR HOpt IS NOT NULL
	THEN 0
	ELSE
		CASE WHEN T0040_GENERAL_SETTING.First_In_Last_Out_For_InOut_Calculation = 0 
		THEN
			CASE WHEN SUM(DATEDIFF(s, In_Time, Out_Time)) >= OTA.Approved_HO_OT_Sec
			THEN OTA.Approved_HO_OT_Sec
			ELSE
				CASE WHEN SUM(DATEDIFF(s, In_Time, Out_Time)) - dbo.F_Return_Sec(SHIFT_DUR) < dbo.F_Return_Sec(a_1.Emp_OT_Min_Limit)
				THEN 0
				ELSE
					CASE WHEN SUM(DATEDIFF(s, In_Time, Out_Time)) - dbo.F_Return_Sec(SHIFT_DUR) > CASE WHEN dbo.F_Return_Sec(a_1.Emp_OT_Max_Limit) = 0 THEN 86400 ELSE dbo.F_Return_Sec(a_1.Emp_OT_Max_Limit) END
					THEN dbo.F_Return_Sec(a_1.Emp_OT_Max_Limit)
					ELSE SUM(DATEDIFF(s, In_Time, Out_Time)) - dbo.F_Return_Sec(SHIFT_DUR)
					END
				END
			END
		ELSE 
			CASE WHEN DATEDIFF(s, MIN(In_Time), MAX(Out_Time)) - dbo.F_Return_Sec(SHIFT_DUR) < dbo.F_Return_Sec(a_1.Emp_OT_Min_Limit)
			THEN 0
			ELSE
				CASE WHEN DATEDIFF(s, MIN(In_Time), MAX(Out_Time)) - dbo.F_Return_Sec(SHIFT_DUR) > CASE WHEN dbo.F_Return_Sec(a_1.Emp_OT_Max_Limit) = 0 THEN 86400 ELSE dbo.F_Return_Sec(a_1.Emp_OT_Max_Limit) END
				THEN dbo.F_Return_Sec(a_1.Emp_OT_Max_Limit)
				ELSE DATEDIFF(s, MIN(In_Time), MAX(Out_Time)) - dbo.F_Return_Sec(SHIFT_DUR)
				END
			END
		END
	END 
ELSE 0 
END AS OT_Sec, 
MIN(EIR.In_Time) AS In_Time, EIR.Shift_St_Time, 0 AS Shift_Change, 0 AS Flag, 
CASE WHEN Emp_OT = 1
THEN 
	CASE WHEN DATENAME(DW, eir.For_Date) = weekoff_Day1 OR DATENAME(DW, eir.For_Date) = weekoff_Day2
	THEN 
		CASE WHEN T0040_GENERAL_SETTING.First_In_Last_Out_For_InOut_Calculation = 0 
		THEN SUM(DATEDIFF(s, In_Time, Out_Time))
		ELSE DATEDIFF(s, MIN(In_Time), MAX(Out_Time))
		END
	ELSE 0 
	END 
ELSE 0 
END AS Weekoff_OT_Sec, 
CASE WHEN Emp_OT = 1
THEN 
	CASE WHEN HFix IS NOT NULL OR HUnFix IS NOT NULL OR HOpt IS NOT NULL
	THEN 
		CASE WHEN DATENAME(DW, eir.For_Date) = weekoff_Day1 OR DATENAME(DW, eir.For_Date) = weekoff_Day2
		THEN 0
		ELSE
			CASE WHEN T0040_GENERAL_SETTING.First_In_Last_Out_For_InOut_Calculation = 0 
			THEN SUM(DATEDIFF(s, In_Time, Out_Time))
			ELSE DATEDIFF(s, MIN(In_Time), MAX(Out_Time)) - dbo.F_Return_Sec(SHIFT_DUR)
			END
		END
	ELSE 0 
	END 
ELSE 0 
END AS Holiday_OT_Sec, 
MAX(EIR.Out_Time) AS Out_Time, EIR.Chk_By_Superior, EIR.Half_Full_day, EIR.F_ST_Time, EIR.F_End_Time, EIR.S_St_Time, EIR.S_End_Time,eir.Cmp_ID
INTO #Calc_Present_Day2
FROM         #Calc_Present_Day1 AS EIR INNER JOIN			
                          (SELECT     ec.Cmp_ID, ec.Emp_ID, ec.Branch_ID, ec.Emp_OT, ec.Emp_OT_Min_Limit, ec.Emp_OT_Max_Limit
                            FROM          T0095_INCREMENT AS ec WITH (NOLOCK) INNER JOIN
                                                       (SELECT     Emp_ID, MAX(Increment_Effective_Date) AS Increment_effective_date
                                                         FROM          T0095_INCREMENT AS T0095_INCREMENT_1 WITH (NOLOCK)
                                                         GROUP BY Emp_ID) AS inc_1 ON ec.Emp_ID = inc_1.Emp_ID AND ec.Increment_Effective_Date = inc_1.Increment_effective_date) 
                      AS a_1 ON EIR.Emp_ID = a_1.Emp_ID AND EIR.Cmp_ID = a_1.Cmp_ID INNER JOIN
                      T0040_GENERAL_SETTING WITH (NOLOCK) ON a_1.Branch_ID = T0040_GENERAL_SETTING.Branch_ID
                      LEFT OUTER JOIN T0160_OT_APPROVAL AS OTA WITH (NOLOCK) ON EIR.Cmp_ID=OTA.Cmp_ID AND EIR.Emp_ID = OTA.Emp_ID
GROUP BY EIR.Emp_ID, EIR.Cmp_ID, EIR.Chk_By_Superior, EIR.Half_Full_day, EIR.For_Date, EIR.Shift_ID, EIR.F_ST_Time, EIR.F_End_Time, EIR.S_St_Time, 
                      EIR.S_End_Time, a_1.Emp_OT, a_1.Emp_OT_Min_Limit, a_1.Emp_OT_Max_Limit, EIR.weekoff_Day1, EIR.weekoff_Day2, 
                      T0040_GENERAL_SETTING.First_In_Last_Out_For_InOut_Calculation, EIR.Shift_St_Time, EIR.Shift_End_Time, HFix, HUnFix, HOpt,OTA.Is_Approved, OTA.Approved_HO_OT_Sec,
                      T0040_GENERAL_SETTING.Is_OT_Auto_Calc,Shift_Dur




if @Return_Record_set <> 4
begin
	SELECT     Emp_ID, FOR_DATE, Duration, cp.Shift_ID, Shift_type, Emp_OT, Emp_OT_Min_Limit, Emp_OT_Max_Limit, isnull(Calculate_Days,0) as P_Days, OT_Sec, In_Time, Shift_St_Time,sd.OT_Start_Time, Shift_Change, 
						  Flag, Weekoff_OT_Sec,Holiday_OT_Sec, Out_Time, Chk_By_Superior, Half_Full_day, F_ST_Time, F_End_Time, S_St_Time, S_End_Time
	FROM         #Calc_Present_Day2 as cp Left outer join T0050_SHIFT_DETAIL sd WITH (NOLOCK) on cp.cmp_id = sd.cmp_id and cp.shift_id = sd.shift_id
	and cast(Duration/3600 as decimal(18,2)) >= sd.from_hour and cast(Duration/3600 as decimal(18,2)) <= sd.to_hour
	order by FOR_DATE
end
else
begin
	SELECT     Emp_ID, FOR_DATE, Duration, cp.Shift_ID, Shift_type, Emp_OT, 
	Emp_OT_Min_Limit, Emp_OT_Max_Limit, isnull(Calculate_Days,0) as P_Days, OT_Sec, In_Time, 
	Shift_St_Time,sd.OT_Start_Time, Shift_Change, Flag, Weekoff_OT_Sec,
	Holiday_OT_Sec,Chk_By_Superior,0 as IO_Tran_Id, Out_Time 
	FROM         #Calc_Present_Day2 as cp Left outer join T0050_SHIFT_DETAIL sd WITH (NOLOCK) on cp.cmp_id = sd.cmp_id and cp.shift_id = sd.shift_id
	and cast(Duration/3600 as decimal(18,2)) >= sd.from_hour and cast(Duration/3600 as decimal(18,2)) <= sd.to_hour
	order by FOR_DATE
end


DROP TABLE #v_EMP_TEMP
drop table #v_weekoff_temp_temp 
drop table #v_alt_weekoff_temp_temp 
drop table #v_shift_detail_temp 
drop table #Calc_Present_Day1 
drop table #Calc_Present_Day2 


END


