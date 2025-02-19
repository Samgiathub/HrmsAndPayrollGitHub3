  
CREATE PROCEDURE [dbo].[Rpt_Salary_Register_Export_With_Actual_080322]    
  @Company_id numeric    
 ,@From_Date  datetime  
 ,@To_Date   datetime  
 ,@Branch_ID  numeric   
 ,@Grade_ID   numeric  
 ,@Type_ID   numeric  
 ,@Dept_ID   numeric  
 ,@Desig_ID   numeric  
 ,@Emp_ID   numeric  
 ,@Constraint varchar(max)  
 ,@Cat_ID        numeric = 0  
 ,@is_column tinyint = 0,  
  @Salary_Cycle_id numeric = 0,  
  @Summary varchar(max) = '',  
  @Order_By varchar(100) = 'Code', --Added by Nimesh 14-Jul-2015 (To sort by Code/Name/Enroll No)        
  @Show_Hidden_Allowance  bit = 1   --Added by Jaina 20-12-2016  
AS    
  
 SET NOCOUNT ON   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
    
set @Show_Hidden_Allowance = 0  
   
declare @from_date_temp as datetime,  
  @to_date_temp as datetime  
  
---added jimit 26042016------  
CREATE Table #Emp_Cons1  
 (  
  emp_id NUMERIC(18,0)   
 )  
-----------ended--------------  
  
 DECLARE @ProductionBonus_Ad_Def_Id as NUMERIC ---added by jimit 21032017   
 Set @ProductionBonus_Ad_Def_Id = 20  
  
if @salary_cycle_id<>0  
begin  
 select @from_date_temp = Salary_st_date from t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @salary_Cycle_id  
  
 set @from_date = cast(cast(day(@from_date_temp) as varchar(2)) + '-' + cast(datename(mm,dateadd(m,0,@From_Date)) as varchar(10)) + '-' + cast(year(@from_date)as varchar(4)) as datetime)  
 set @to_date = dateadd(d,-1,dateadd(m,1,@from_date))  
end  
  
  
  
--declare @emp_id1 as varchar(max),  
--   @emp_id2 as numeric  
    
if @Constraint = ''  
begin  
   
 --added jimit 26042016--  
 INSERT INTO #Emp_Cons1  
 SELECT distinct emp_id from t0200_monthly_salary WITH (NOLOCK)  
  where month(Month_End_Date) = MONTH(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) and Cmp_id =@Company_id  
   
 if exists(select 1 from #Emp_Cons1)  
  BEGIN  
   SELECT @Constraint = COALESCE(@Constraint + '#', '') + Cast(emp_id as varchar(100)) FROM #Emp_Cons1  
  End  
   
 -------ended----------   
  
end  
else  
begin  
 --set @emp_id1 = @Constraint  
 ------added jimit 26042016  
 INSERT Into #Emp_Cons1  
 Select data from dbo.Split(@Constraint,'#')   
 ------ended---------------   
end  
  
  
  
Create table #Tbl_Get_AD  
 (  
  Emp_ID numeric(18,0),  
  Ad_ID numeric(18,0),  
  for_date datetime,  
  E_Ad_Percentage numeric(18,5),  
  E_Ad_Amount numeric(18,2)  
 )  
  
  
 INSERT INTO #Tbl_Get_AD  
  Exec P_Emp_Revised_Allowance_Get @Company_id,@To_Date,@Constraint  
  
   
if exists (select top 1 * from sysobjects where name = '#v_Leave_pvt' and type = 'u')   
begin   
 drop table #v_Leave_pvt  
end   
if exists (select top 1 * from sysobjects where name = '#v_Leave_pvt1' and type = 'u')   
begin   
 drop table #v_Leave_pvt1  
end   
  
SELECT     Lt.Emp_ID,Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),
'__','_'),'__','_'),'/','') Leave_Name   
, SUM(Leave_Used) + Sum(isnull(Leave_Adj_L_Mark,0)) AS Leave_Used   
INTO #v_Leave_pvt  
FROM         T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
   inner join T0040_Leave_Master LM WITH (NOLOCK) on lt.leave_ID = lm.leave_ID and isnull(lm.Default_Short_Name,'') <> 'COMP'  
   inner join  #Emp_Cons1 Ec ON Ec.emp_id = Lt.Emp_ID  --added jimit 26042016  
   --dbo.split(@constraint,'#') on Data = LT.Emp_ID   
WHERE     (For_Date BETWEEN @from_Date AND @to_Date) and LT.Cmp_ID = @Company_ID and (LT.Leave_used <> 0 or isnull(Leave_Adj_L_Mark,0) <> 0 )-- Changed By Gadriwala Muslim 02102014  
   and LM.Leave_Paid_Unpaid = 'P'  
   --and emp_id in (select data from dbo.split(@constraint,'#'))  
GROUP BY Lt.Emp_ID, Leave_Name  
  
SELECT     Lt.Emp_ID,Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),
'__','_'),'__','_'),'/','') Leave_Name   
, SUM(ISNULL(CompOff_Used,0) - ISNULL(Leave_Encash_Days,0)) AS Leave_Used  
INTO #v_Leave_pvt1  
FROM         T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK)   
    inner join T0040_Leave_Master LM  WITH (NOLOCK) on lt.leave_ID = lm.leave_ID and isnull(lm.Default_Short_Name,'') = 'COMP'  
    inner join #Emp_Cons1 Ec ON Ec.emp_id = Lt.Emp_ID   --added jimit 26042016  
    --dbo.split(@constraint,'#') on Data = LT.Emp_ID   
WHERE     (For_Date BETWEEN @from_Date AND @to_Date) and LT.Cmp_ID = @Company_ID and (( ISNULL(LT.CompOff_Used,0) - ISNULL(LT.Leave_Encash_Days,0)) > 0)-- Changed By Gadriwala Muslim 02102014  
   and LM.Leave_Paid_Unpaid = 'P'  
   --and emp_id in (select data from dbo.split(@constraint,'#'))  
GROUP BY Lt.Emp_ID, Leave_Name  
  
select * into #v_Leave_pvt3 from #v_Leave_pvt  
union all  
select * from #v_Leave_pvt1  
  
  
if exists (select top 1 * from sysobjects where name = '#v_Leave' and type = 'u')   
begin   
 drop table #v_Leave  
end   
  
Declare @ColsPivot_Leave as varchar(max),@ColsPivot_Leave_Null as varchar(max),@ColsPivot_Leave_Total as varchar(max),  
  @qry_Leave as varchar(max)  
  
set @ColsPivot_Leave = STUFF((SELECT ',' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',
' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000)))   
        from #v_Leave_pvt3 as a  
        cross apply ( select 'Leave_Name' col, 1 so ) c   
        group by col,a.Leave_Name,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
set @ColsPivot_Leave_Null = STUFF((SELECT ',ISNULL(' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'
%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000))) + ',0) AS ' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000)))  
        from #v_Leave_pvt3 as a  
        cross apply ( select 'Leave_Name' col, 1 so ) c   
        group by col,a.Leave_Name,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
set @ColsPivot_Leave_Total = STUFF((SELECT '+ISNULL(' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),
'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000))) + ',0)'  
        from #v_Leave_pvt3 as a  
        cross apply ( select 'Leave_Name' col, 1 so ) c   
        group by col,a.Leave_Name,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
if exists(select * from #v_Leave_pvt3)  
begin  
set @qry_Leave = 'select Emp_id, '+@colsPivot_Leave+' into v_Leave   
 from (select emp_id,Leave_Name, Leave_Used from #v_Leave_pvt3)   
 as data pivot   
 ( sum(Leave_Used)   
 for Leave_Name in ('+ @colspivot_leave +') ) p'   
exec (@qry_Leave)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Leave into v_Leave  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = VE.Emp_ID  --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Leave from v_Leave  
drop table v_Leave  
  
if exists (select top 1 * from sysobjects where name = '#v_Leave_pvt_u' and type = 'u')   
begin   
 drop table #v_Leave_pvt_u  
end   
if exists (select top 1 * from sysobjects where name = '#v_Leave_pvt_u1' and type = 'u')   
begin   
 drop table #v_Leave_pvt_u1  
end   
  
SELECT Lt.Emp_ID,  cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_
'),'__','_'),'__','_'),'/','') as varchar(4000)) as Leave_Name, SUM(Leave_Used) AS Leave_Used  
INTO #v_Leave_pvt_u  
FROM T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK)   
    inner join T0040_Leave_Master LM  WITH (NOLOCK) on lt.leave_ID = lm.leave_ID and isnull(lm.Default_Short_Name,'') <> 'COMP'  
    inner join #Emp_Cons1 Ec ON Ec.emp_id = Lt.Emp_ID  --added jimit 26042016  
    --dbo.split(@constraint,'#') on Data = LT.Emp_ID    
WHERE     (For_Date BETWEEN @from_Date AND @to_Date) and LT.Cmp_ID = @Company_ID and (LT.Leave_used <> 0 ) -- Changed By Gadriwala Muslim 02102014  
   and LM.Leave_Paid_Unpaid = 'U'  
   --and emp_id in (select data from dbo.split(@constraint,'#'))  
GROUP BY lt.Emp_ID, Leave_Name  
  
SELECT     lt.Emp_ID, cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' '
,'_'),'__','_'),'__','_'),'/','') as varchar(4000)) as Leave_Name, SUM(isnull(CompOff_Used,0) - isnull(Leave_Encash_Days,0)) AS Leave_Used  
INTO #v_Leave_pvt_u1  
FROM         T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK)   
    inner join T0040_Leave_Master LM  WITH (NOLOCK) on lt.leave_ID = lm.leave_ID and isnull(lm.Default_Short_Name,'') = 'COMP'  
    inner join #Emp_Cons1 Ec ON Ec.emp_id = Lt.Emp_ID  --added jimit 26042016  
    --dbo.split(@constraint,'#') on Data = LT.Emp_ID    
WHERE     (For_Date BETWEEN @from_Date AND @to_Date) and LT.Cmp_ID = @Company_ID and (isnull(CompOff_Used,0) - isnull(Leave_Encash_Days,0) > 0 ) -- Changed By Gadriwala Muslim 02102014  
   and LM.Leave_Paid_Unpaid = 'U'  
   --and emp_id in (select data from dbo.split(@constraint,'#'))  
GROUP BY lt.Emp_ID, Leave_Name  
  
select * into #v_Leave_pvt_u2 from #v_Leave_pvt_u  
Union all  
select * from #v_Leave_pvt_u1  
  
  
if exists (select top 1 * from sysobjects where name = '#v_Leave_U' and type = 'u')   
begin   
 drop table #v_Leave_U  
end   
if exists (select top 1 * from sysobjects where name = 'v_Leave_U' and type = 'u')   
begin   
 drop table v_Leave_U  
end  --Added by Rohit & Sumit 20072016  
  
Declare @ColsPivot_Leave_U as varchar(max),@ColsPivot_Leave_Null_U as varchar(max),@ColsPivot_Leave_Total_U as varchar(max),  
  @qry_Leave_U as varchar(max)  
  
set @ColsPivot_Leave_U = STUFF((SELECT ',' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-'
,' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000)))   
        from #v_Leave_pvt_u2 as a  
        cross apply ( select 'Leave_Name' col, 1 so ) c   
        group by col,a.Leave_Name,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
set @ColsPivot_Leave_Null_U = STUFF((SELECT ',ISNULL(' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' ')
,'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000))) + ',0) AS ' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000)))  
        from #v_Leave_pvt_u2 as a  
        cross apply ( select 'Leave_Name' col, 1 so ) c   
        group by col,a.Leave_Name,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
set @ColsPivot_Leave_Total_U = STUFF((SELECT '+ISNULL(' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '
),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000))) + ',0)'  
        from #v_Leave_pvt_u2 as a  
        cross apply ( select 'Leave_Name' col, 1 so ) c   
        group by col,a.Leave_Name,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
if exists(select * from #v_Leave_pvt_u2)  
begin  
set @qry_Leave = 'select Emp_id, '+@colsPivot_Leave_U+' into v_Leave_U   
 from (select emp_id,Leave_Name, Leave_Used from #v_Leave_pvt_u2)   
 as data pivot   
 ( sum(Leave_Used)   
 for Leave_Name in ('+ @colspivot_leave_U +') ) p'   
exec (@qry_Leave)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Unpaid into v_Leave_U  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
  
select * into #v_Leave_U from v_Leave_U  
drop table v_Leave_U  
  
  
DECLARE @colsPivot AS NVARCHAR(MAX), @colsPivot_ntes AS NVARCHAR(MAX), @colsPivot3 AS NVARCHAR(MAX), @colsPivot3_ntes AS NVARCHAR(MAX), @colsPivot1 AS NVARCHAR(MAX), @colsPivot1_ntes AS NVARCHAR(MAX), @colsPivot2 AS NVARCHAR(MAX),@colsPivot2_ntes AS NVARCHAR(MAX), @colsPivot_T as NVARCHAR(MAX), @colsPivot_T_ntes as NVARCHAR(MAX),  
  @colsPivot_TD as NVARCHAR(MAX), @colsPivot_TD_ntes as NVARCHAR(MAX),@colsPivot_Add AS NVARCHAR(MAX), @colsPivot_Add_ntes AS NVARCHAR(MAX), @colsPivot_ded AS NVARCHAR(MAX), @colsPivot_ded_ntes AS NVARCHAR(MAX), @query AS nvarchar(max), @query1 AS nvarchar(max), @query2 AS nvarchar(max), @query3 AS nvarchar(max), @query4 AS nvarchar(max)  
  
DECLARE @colsPivot4 AS NVARCHAR(MAX), @colsPivot4_ntes AS NVARCHAR(MAX), @colsPivot5 AS NVARCHAR(MAX), @colsPivot5_ntes AS NVARCHAR(MAX), @colsPivot6 AS NVARCHAR(MAX), @colsPivot6_ntes AS NVARCHAR(MAX), @colsPivot7 AS NVARCHAR(MAX), @colsPivot8 AS NVARCHAR(MAX), @colsPivot9 AS NVARCHAR(MAX), @colsPivotArr1 AS NVARCHAR(MAX),    
  @colsPivotArr2 AS NVARCHAR(MAX),  @colsPivotArr3 AS NVARCHAR(MAX), @colsPivotArr4 AS NVARCHAR(MAX), @colsPivotArr1_ded AS NVARCHAR(MAX),  @colsPivotArr2_ded AS NVARCHAR(MAX),  @colsPivotArr3_ded AS NVARCHAR(MAX), @colsPivotArr4_ded AS NVARCHAR(MAX), @colsPivotArr1_ntes AS NVARCHAR(MAX), @colsPivotArr2_ntes AS NVARCHAR(MAX),   
  @colsPivotArr3_ntes AS NVARCHAR(MAX), @colsPivotArr4_ntes AS NVARCHAR(MAX), @colsPivotArr1_ded_ntes AS NVARCHAR(MAX), @colsPivotArr2_ded_ntes AS NVARCHAR(MAX), @colsPivotArr3_ded_ntes AS NVARCHAR(MAX), @colsPivotArr4_ded_ntes AS NVARCHAR(MAX)  
  --,@colsPivot1_ntes_CTC AS NVARCHAR(MAX), @colsPivot2_ntes_CTC AS NVARCHAR(MAX), @colsPivot3_ntes_CTC AS NVARCHAR(MAX), @colsPivot4_ntes_CTC AS NVARCHAR(MAX)    
    
  
declare @colsPivot10 as varchar(max)  
declare @colsPivot_T_ntes_autoPaid as varchar(max) --Added by Ramiz on 05/06/2018  
  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name' and type = 'u')   
begin   
 drop table #v_Ad_Name   
end   
  
-------------- calculated with ad_Flag = I and ad_not_effect_salary = 0  
SELECT replace(A.AD_NAME,' ','_') as AD_SORT_NAME, t.EMP_ID, t.E_AD_AMOUNT  
INTO            #v_Ad_Name  
FROM         T0050_AD_MASTER AS A  WITH (NOLOCK) INNER JOIN  
                          (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID  
                            FROM          #Tbl_Get_AD AS T  
                            WHERE      (T.E_AD_PERCENTAGE > 0) OR  
                                                   (T.E_AD_AMOUNT > 0)) AS t ON A.AD_ID = t.AD_ID INNER JOIN  
                          (SELECT     Emp_ID, Cmp_ID  
                            FROM          T0200_MONTHLY_SALARY WITH (NOLOCK)   
                            WHERE      (Month_St_Date = @From_Date) and Cmp_ID = @Company_id) AS ms ON ms.Emp_ID = t.EMP_ID Inner join  
                            #Emp_Cons1 Ec ON Ec.emp_id = t.Emp_ID --added jimit 26042016  
WHERE     (t.E_AD_AMOUNT <> 0) and a.AD_FLAG = 'I'   
and AD_NOT_EFFECT_SALARY = 0 and A.Cmp_ID = @Company_ID  
and ad_def_Id <> @ProductionBonus_Ad_Def_Id   
--and t.EMP_ID in (select data from dbo.split(@constraint,'#'))  
order by a.Ad_Level,a.AD_Sort_name  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc' and type = 'u')   
begin   
 drop table v_Ad_Calc  
end   
  
set @query = ''  
 select @colsPivot = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot_T = STUFF((SELECT ',isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')+ ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')  
        from #v_Ad_Name as a  
        cross apply ( select 'add_sort_name' col, 1 as so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot1 = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Actual') + ', isnull('  
        from #v_Ad_Name as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot_Add = STUFF((SELECT '+ ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')   
        from #v_Ad_Name as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
print @colsPivot_T  
  
set @colsPivot1 = 'isnull([' + @colsPivot1  
  
set @colsPivot1 = LEFT(@colsPivot1,len(@colsPivot1)-9)  
  
  
  
if exists(select * from #v_Ad_Name)  
begin  
set @query = 'select Emp_id, '+@colsPivot1+' into v_Ad_Calc   
 from (select emp_id,Ad_sort_name, E_Ad_Amount from #v_Ad_Name)   
 as data pivot   
 ( sum(E_Ad_Amount)   
 for Ad_sort_name in ('+ @colspivot +') ) p'   
exec (@query)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Ad_Calc from v_Ad_Calc  
drop table v_Ad_Calc  
-------------- calculated with ad_Flag = I and ad_not_effect_salary = 0 --- Ends  
  
-------------- calculated with ad_Flag = I and ad_not_effect_salary = 1   
  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name' and type = 'u')   
begin   
 drop table #v_Ad_Name_n   
end   
  
SELECT replace(A.AD_NAME,' ','_') as AD_SORT_NAME, t.EMP_ID, t.E_AD_AMOUNT , A.Auto_Paid , A.AD_CAL_TYPE --(A.Auto_Paid , A.AD_CAL_TYPE --> Added by Ramiz on 05/06/2018)   
INTO            #v_Ad_Name_n  
FROM         T0050_AD_MASTER AS A  WITH (NOLOCK) INNER JOIN  
                          (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID  
                            FROM          #Tbl_Get_AD AS T   
                            WHERE      (T.E_AD_PERCENTAGE > 0) OR  
                                                   (T.E_AD_AMOUNT > 0)) AS t ON A.AD_ID = t.AD_ID INNER JOIN  
                          (SELECT     Emp_ID, Cmp_ID  
                            FROM          T0200_MONTHLY_SALARY WITH (NOLOCK)   
                            WHERE      (Month_St_Date = @From_Date) and cmp_ID = @Company_id) AS ms ON ms.Emp_ID = t.EMP_ID  
WHERE     (t.E_AD_AMOUNT <> 0) and a.AD_FLAG = 'I' and AD_NOT_EFFECT_SALARY = 1 and A.Cmp_ID = @Company_ID  
and t.Emp_ID in(select emp_Id from #Emp_Cons1) --added jimit 26042016  
order by a.Ad_Level,a.AD_Sort_name  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_ntes' and type = 'u')   
begin   
 drop table v_Ad_Calc_ntes  
end   
  
set @query = ''  
 select @colsPivot_ntes = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_n as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot_T_ntes = STUFF((SELECT ',isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')+ ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')  
        from #v_Ad_Name_n as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivot1_ntes = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Actual') + ', isnull('  
        from #v_Ad_Name_n as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot_Add_ntes = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')   
        from #v_Ad_Name_n as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
 ----Adding all those Allowance which are AutoPaid every month ( Ramiz 04/10/2018)  
 select @colsPivot_T_ntes_autoPaid = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')   
        from #v_Ad_Name_n as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        where a.Auto_Paid = 1 AND A.AD_CAL_TYPE = 'Monthly' -- Condition  
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
set @colsPivot1_ntes = 'isnull([' + @colsPivot1_ntes  
  
set @colsPivot1_ntes = LEFT(@colsPivot1_ntes,len(@colsPivot1_ntes)-9)  
  
if exists(select * from #v_Ad_Name_n)  
begin  
set @query = 'select Emp_id, '+@colsPivot1_ntes+' into v_Ad_Calc_ntes   
 from (select emp_id,Ad_sort_name, E_Ad_Amount from #v_Ad_Name_n)   
 as data pivot   
 ( sum(E_Ad_Amount)   
 for Ad_sort_name in ('+ @colspivot_ntes +') ) p'   
exec (@query)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_ntes  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID  --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Ad_Calc_ntes from v_Ad_Calc_ntes  
drop table v_Ad_Calc_ntes  
-------------- calculated with ad_Flag = I and ad_not_effect_salary = 1 --- Ends  
  
-------------- calculated with ad_Flag = d and ad_not_effect_salary = 0   
  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_d' and type = 'u')   
begin   
 drop table #v_Ad_Name_d   
end   
   
  
SELECT replace(A.AD_NAME,' ','_') as AD_SORT_NAME, t.EMP_ID, t.E_AD_AMOUNT  
INTO            #v_Ad_Name_d  
FROM         T0050_AD_MASTER AS A  WITH (NOLOCK)   
    INNER JOIN  
                          (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID  
                            FROM          #Tbl_Get_AD AS T   
                            WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)  
                           ) AS t ON A.AD_ID = t.AD_ID   
                INNER JOIN  
                          (SELECT     Emp_ID, Cmp_ID  
                            FROM          T0200_MONTHLY_SALARY WITH (NOLOCK)   
                            WHERE    (Month_St_Date = @From_Date)  and Cmp_ID = @Company_id /*(MONTH(Month_St_Date) = MONTH(@From_Date)) AND (YEAR(Month_St_Date) = YEAR(@From_Date))*/  
                          ) AS ms ON ms.Emp_ID = t.EMP_ID  
WHERE     (t.E_AD_AMOUNT <> 0) and a.AD_FLAG = 'D' and AD_NOT_EFFECT_SALARY = 0 and A.Cmp_ID = @Company_ID  
and t.Emp_ID in (SELECT emp_Id from #Emp_Cons1) --added jimit 26042016  
ORDER BY a.Ad_Level,a.AD_Sort_name  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_D' and type = 'u')   
begin   
 drop table v_Ad_Calc_D  
end   
  
 select @colsPivot3 = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_d as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
 select @colsPivot_TD = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+ '_Actual')   
        from #v_Ad_Name_d as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
 select @colsPivot2 = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Actual') + ', isnull('  
        from #v_Ad_Name_d as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot_ded = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')   
        from #v_Ad_Name_d as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
 declare @colsPivot_ded1 as varchar(max)  
 select @colsPivot_ded1 = STUFF((SELECT ',isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')+ ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')  
          from #v_Ad_Name_d as a  
          cross apply ( select 'add_sort_name' col, 1 so ) c   
          group by col,a.AD_SORT_NAME,so   
          order by so   
        FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
set @colsPivot2 = 'isnull([' + @colsPivot2  
  
set @colsPivot2 = LEFT(@colsPivot2,len(@colsPivot2)-9)  
if exists (select top 1 * from #v_Ad_Name_d)  
begin  
  
 set @query = 'select Emp_id, ' + @colsPivot2 + ' into v_Ad_Calc_D  
  from (select emp_id,Ad_sort_name, E_Ad_Amount from #v_Ad_Name_d)   
  as data pivot   
  ( sum(E_Ad_Amount)   
  for Ad_sort_name in ('+ @colsPivot3 +') ) p'   
  
exec (@query)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_ad_calc_d  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID   --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Ad_Calc_D from v_Ad_Calc_D  
drop table v_Ad_Calc_D  
-------------- calculated with ad_Flag = d and ad_not_effect_salary = 0 ---- ends  
  
-------------- calculated with ad_Flag = d and ad_not_effect_salary = 1   
  
  
--if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_d_ntes' and type = 'u')   
--begin   
-- drop table #v_Ad_Name_d_ntes   
--end   
   
  
--SELECT replace(A.AD_SORT_NAME,' ','_') as AD_SORT_NAME, t.EMP_ID, t.E_AD_AMOUNT  
--INTO            #v_Ad_Name_d_ntes  
--FROM         T0050_AD_MASTER AS A INNER JOIN  
--                          (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID  
--                            FROM          T0100_EMP_EARN_DEDUCTION AS T INNER JOIN  
--                                                       (SELECT     Emp_ID, MAX(Increment_Effective_Date) AS idate  
--                                                         FROM          (SELECT     Emp_ID, Increment_Effective_Date  
--                                                                                 FROM          T0095_INCREMENT  
--                                                                                 WHERE     (Increment_Effective_Date <= @To_Date)) AS a  
--                                                         GROUP BY Emp_ID) AS inc ON T.EMP_ID = inc.Emp_ID AND T.FOR_DATE = inc.idate  
--                            WHERE      (T.E_AD_PERCENTAGE > 0) OR  
--                                                   (T.E_AD_AMOUNT > 0)) AS t ON A.AD_ID = t.AD_ID INNER JOIN  
--                          (SELECT     Emp_ID, Cmp_ID  
--                            FROM          T0200_MONTHLY_SALARY  
--                            WHERE   (Month_St_Date = @From_Date)   /*(MONTH(Month_St_Date) = MONTH(@From_Date)) AND (YEAR(Month_St_Date) = YEAR(@From_Date))*/) AS ms ON ms.Emp_ID = t.EMP_ID  
----inner join #total_count as tc on t.emp_id = tc.emp_id  
--WHERE     (t.E_AD_AMOUNT <> 0) and a.AD_FLAG = 'D' and AD_NOT_EFFECT_SALARY = 1 and A.Cmp_ID = @Company_ID  
--and t.EMP_ID in (select data from dbo.split(@constraint,'#'))  
--order by a.ad_sort_name  
  
  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_d_ntes' and type = 'u')   
begin   
 drop table v_Ad_Calc_d_ntes  
end   
  
  
  
 --select @colsPivot3_ntes = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
 --       from #v_Ad_Name_d_ntes as a  
 --       cross apply ( select 'add_sort_name' col, 1 so ) c   
 --       group by col,a.AD_SORT_NAME,so   
 --       order by so   
 --     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
 --select @colsPivot_TD_ntes = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+ '_Actual')   
 --       from #v_Ad_Name_d_ntes as a  
 --       cross apply ( select 'add_sort_name' col, 1 so ) c   
 --       group by col,a.AD_SORT_NAME,so   
 --       order by so   
 --     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
 --select @colsPivot2_ntes = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Actual') + ', isnull('  
 --       from #v_Ad_Name_d_ntes as a  
 --       cross apply ( select 'add_sort_name' col, 1 so ) c   
 --       group by col,a.AD_SORT_NAME,so   
 --       order by so   
 --     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 --select @colsPivot_ded_ntes = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Actual')   
 --       from #v_Ad_Name_d_ntes as a  
 --       cross apply ( select 'add_sort_name' col, 1 so ) c   
 --       group by col,a.AD_SORT_NAME,so   
 --       order by so   
 --     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
  
set @colsPivot2_ntes = 'isnull([' + @colsPivot2_ntes  
  
set @colsPivot2_ntes = LEFT(@colsPivot2_ntes,len(@colsPivot2_ntes)-9)  
  
  
  
--if exists (select top 1 * from #v_Ad_Name_d_ntes)  
--begin  
-- set @query = 'select Emp_id, ' + @colsPivot2_ntes + ' into v_Ad_Calc_D_ntes  
--  from (select emp_id,Ad_sort_name, E_Ad_Amount from #v_Ad_Name_d_ntes)   
--  as data pivot   
--  ( sum(E_Ad_Amount)   
--  for Ad_sort_name in ('+ @colsPivot3_ntes +') ) p'   
--exec (@query)  
--end  
--else  
--begin  
-- select Distinct Emp_id,0 as Total_Deduction into v_Ad_Calc_D_ntes  
-- from v_emp_cons  
-- inner join dbo.split(@emp_id1,'#') as ds on emp_id = data  
--end  
--select * into #v_Ad_Calc_D_ntes from v_Ad_Calc_D_ntes  
--drop table v_Ad_Calc_D_ntes  
------------  
  
  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_E' and type = 'u')   
begin   
 drop table #v_Ad_Name_E   
end   
   
SELECT     m.Emp_ID, case when m.ReimAmount <>0  then m.ReimAmount else m.M_AD_Amount end as M_AD_Amount ,--m.M_AD_Amount,   
     CASE WHEN A.Allowance_Type = 'R' THEN replace(a.AD_NAME + '_'+ 'Claim',' ','_')   
     ELSE replace(a.AD_NAME,' ','_')  END AS AD_SORT_NAME  
       
INTO            #v_Ad_Name_E  
FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
   INNER JOIN T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
   INNER JOIN #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID --added jimit 26042016  
   --dbo.split(@constraint,'#') on Data = m.Emp_ID  
--inner join #total_count as tc on m.emp_id = tc.emp_id  
WHERE   (m.For_Date = @From_Date) and  --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date)) AND   
(m.M_AD_Amount <> 0) AND (m.M_AD_Flag = 'I') and (AD_NOT_EFFECT_SALARY = 0 OR (ISNULL(m.ReimShow,0) = 1 and isnull(m.ReimAmount,0)<>0)) and m.Cmp_ID = @Company_ID  
and m.S_Sal_Tran_ID is NULL and ad_def_Id <> @ProductionBonus_Ad_Def_Id   
--and m.emp_id in (select data from dbo.split(@constraint,'#'))  
order by a.Ad_Level,a.AD_Sort_name  
  
  
   Insert Into  #v_Ad_Name_E          
   Select  Q.emp_Id,Q.Amount,'Production_Bonus'  
   FROM (  
        SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
        FROM T0210_MONTHLY_AD_DETAIL MAD  WITH (NOLOCK)   
          INNER JOIN T0050_AD_MASTER AD  WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID  
          inner join #Emp_Cons1 Ec ON Ec.emp_id = mad.Emp_ID              
        WHERE MAD.Cmp_ID= @Company_Id   
           AND MONTH(MAD.For_Date) =  Month(@From_Date) and YEAR(MAD.For_Date) = Year(@From_Date)  
           AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
           AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
           --AND MAD.Emp_ID = @EMp_Id_Production  
        GROUP BY Mad.Emp_ID  
         )Q --On CM.Emp_ID = Q.Emp_ID   
  
  
  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_E_PartOfCTC' and type = 'u')   
begin   
 drop table #v_Ad_Name_E_PartOfCTC   
end   
  
  
SELECT     m.Emp_ID, (isnull(m.M_AD_Amount,0) + isnull(MS_arear.ms_amount,0) + isnull(m.M_AREAR_AMOUNT,0)+ isnull(m.M_AREAR_AMOUNT_Cutoff,0)) as M_AD_Amount,  
--replace(a.AD_SORT_NAME,' ','_') as AD_SORT_NAME  
case when a.Allowance_type='R' then replace(a.AD_NAME,' ','_')+ '_' + 'Credit' Else replace(a.AD_NAME,' ','_')  
End as AD_Sort_NAME  
INTO            #v_Ad_Name_E_PartOfCTC  
FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
   INNER JOIN T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
   INNER JOIN #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID --added jimit 26042016  
   Left outer JOIN  
   (  
    Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear    
     From t0210_monthly_ad_detail MAD  WITH (NOLOCK)   
     inner join T0201_MONTHLY_SALARY_SETT MSS  WITH (NOLOCK) on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id    
     inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id  
    where MAD.Cmp_ID = @Company_ID and month(MSS.S_Eff_Date) = Month(@To_Date) and Year(MSS.S_Eff_Date) = Year(@To_Date)   
       and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    and Ad_Active = 1   
    Group By MAD.AD_ID,MSS.Emp_ID  
   ) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear  
   --dbo.split(@constraint,'#') on Data = m.Emp_ID  
--inner join #total_count as tc on m.emp_id = tc.emp_id  
WHERE   (m.For_Date = @From_Date) and  --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date)) AND   
(m.M_AD_Amount <> 0) AND (m.M_AD_Flag = 'I') and   
AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 1   
AND (CASE WHEN @Show_Hidden_Allowance = 0 AND Hide_In_Reports = 1 THEN 0 ELSE 1 END )= 1  --Added by Jaina 23-12-2016  
 and m.Cmp_ID = @Company_ID   --Change by Jaina 20-12-2016  
 and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
--and m.emp_id in (select data from dbo.split(@constraint,'#'))  
order by a.Ad_Level,a.AD_Sort_name  
  
  
  
Declare @colsPivotPartOfCTC nvarchar(max)  
Declare @colsPivotPartOfCTC1 nvarchar(max)  
Declare @colsPivotPartOfCTC_Sum nvarchar(max)  
  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_E' and type = 'u')   
begin   
 drop table v_Ad_Calc_E  
end   
  
 select @colsPivot4 = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_E as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivot5 = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ', isnull('  
        from #v_Ad_Name_E as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot6 = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_E as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
  
 --Added by Gadriwala Muslim 13012015 - Start  
 select @colsPivotPartOfCTC1 = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_E_PartOfCTC as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivotPartOfCTC = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ', isnull('  
        from #v_Ad_Name_E_PartOfCTC as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivotPartOfCTC_Sum = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) + isnull('  
        from #v_Ad_Name_E_PartOfCTC as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
 --Added by Gadriwala Muslim 13012015 - End  
 set @colsPivotPartOfCTC = 'isnull([' + @colsPivotPartOfCTC  
 set @colsPivotPartOfCTC = LEFT(@colsPivotPartOfCTC,len(@colsPivotPartOfCTC)-9)  
   
set @colsPivot5 = 'isnull([' + @colsPivot5  
set @colsPivot5 = LEFT(@colsPivot5,len(@colsPivot5)-9)  
  
 set @colsPivotPartOfCTC_Sum = 'isnull([' + @colsPivotPartOfCTC_Sum  
 set @colsPivotPartOfCTC_Sum = LEFT(@colsPivotPartOfCTC_Sum,len(@colsPivotPartOfCTC_Sum)-9)  
  
  
  
IF exists(select top 1 * from sysobjects where name = 'v_Ad_Name_Calc_E_PartOfCTC')  
 Drop table v_Ad_Name_Calc_E_PartOfCTC  
  
  
  
IF exists(select * from #v_Ad_Name_E_PartOfCTC)  
BEGIN  
 SET @query = 'select Emp_id, '+ @colsPivotPartOfCTC +' into v_Ad_Name_Calc_E_PartOfCTC  
 from (select emp_id,Ad_sort_name, M_Ad_Amount from #v_Ad_Name_E_PartOfCTC)   
 as data pivot   
 ( sum(M_Ad_Amount)   
 for Ad_sort_name in ('+ @colsPivotPartOfCTC1 +') ) p'   
 exec(@query)  
END  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Allowance into v_Ad_Name_Calc_E_PartOfCTC  
  from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
  
  
  
if exists (select * from #v_Ad_Name_E)  
begin  
set @query = 'select Emp_id, '+@colsPivot5+' into v_Ad_Calc_E   
 from (select emp_id,Ad_sort_name, M_Ad_Amount from #v_Ad_Name_E)   
 as data pivot   
 ( sum(M_Ad_Amount)   
 for Ad_sort_name in ('+ @colsPivot4 +') ) p'   
  
exec (@query)  
  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_E  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
  
end  
  
  
  
select * into #v_Ad_Calc_E from v_Ad_Calc_E  
drop table v_Ad_Calc_E  
----------------------------  
  
If Exists(select top 1 * from sysobjects where name = 'v_Ad_Name_Calc_E_PartOfCTC' )  
 begin  
  select * into #v_Ad_Name_E_Calc_PartOfCTC from v_Ad_Name_Calc_E_PartOfCTC  
  drop table v_Ad_Name_Calc_E_PartOfCTC  
 end  
  
  
  if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_E_ntes' and type = 'u')   
  begin   
   drop table #v_Ad_Name_E_ntes   
  end   
  
  SELECT     m.Emp_ID, m.M_AD_Amount, replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
  INTO            #v_Ad_Name_E_ntes  
  FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
     INNER JOIN T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
     INNER JOIN  #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  
     --dbo.split(@constraint,'#') on Data = m.Emp_ID  
     --inner join #total_count as tc on m.emp_id = tc.emp_id  
  WHERE (m.For_Date = @From_Date) and  --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date)) AND   
  (m.M_AD_Amount <> 0)  and --(m.M_AD_Flag = 'I') and  -- Commented by Hardik 28/08/2020 for Cera as they have Deduction which is effect in Net also  
  AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 0    
  AND (CASE WHEN @Show_Hidden_Allowance = 0  and Hide_In_Reports = 1 THEN 0 else 1 END ) =1   --Added by Jaina 23-12-2016  
   and m.Cmp_ID = @Company_ID   --Change By Jaina 09-09-2016  
   and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
  --and m.emp_id in (select data from dbo.split(@constraint,'#'))  
  order by a.AD_SORT_NAME  
  
  
  
--print 111111  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_E_ntes' and type = 'u')   
begin   
  
 drop table v_Ad_Calc_E_ntes--#v_Ad_Calc_E_ntes Change by sumit   
end   
  
 select @colsPivot4_ntes = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_E_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivot5_ntes = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ', isnull('  
        from #v_Ad_Name_E_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot6_ntes = STUFF((SELECT '+ isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0)'  
        from #v_Ad_Name_E_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
set @colsPivot5_ntes = 'isnull([' + @colsPivot5_ntes  
  
set @colsPivot5_ntes = LEFT(@colsPivot5_ntes,len(@colsPivot5_ntes)-9)  
  
  
if exists (select * from #v_Ad_Name_E_ntes)  
begin  
set @query = 'select Emp_id, '+@colsPivot5_ntes+' into v_Ad_Calc_E_ntes   
 from (select emp_id,Ad_sort_name, M_Ad_Amount from #v_Ad_Name_E_ntes)   
 as data pivot   
 ( sum(M_Ad_Amount)   
 for Ad_sort_name in ('+ @colsPivot4_ntes +') ) p'   
  
exec (@query)  
--PRINT @colsPivot4_ntes  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_E_ntes  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID  --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
  
--SELECT * FROM v_Ad_Calc_E_ntes  
  
select * into #v_Ad_Calc_E_ntes from v_Ad_Calc_E_ntes  
drop table v_Ad_Calc_E_ntes  
----------------------------  
  
  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_Ded' and type = 'u')   
begin   
 drop table #v_Ad_Name_Ded   
end   
   
SELECT     m.Emp_ID, m.M_AD_Amount, replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
INTO       #v_Ad_Name_Ded  
FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
    INNER JOIN T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
    INNER JOIN #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID --added jimit 26042016  
    --dbo.split(@constraint,'#') on Data = m.Emp_ID  
WHERE  (m.For_Date = @From_Date) and   --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date)) AND   
(m.M_AD_Amount <> 0) AND (m.M_AD_Flag = 'D') and AD_NOT_EFFECT_SALARY = 0 and m.Cmp_ID = @Company_ID  
and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
--and m.emp_id in (select data from dbo.split(@constraint,'#'))  
order by a.AD_SORT_NAME  
  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_Ded' and type = 'u')   
begin   
 drop table v_Ad_Calc_Ded  
end   
   
   
 select @colsPivot7 = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_Ded as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivot8 = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+ '') + ', isnull('  
        from #v_Ad_Name_Ded as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot10 = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+ '') + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+ '') + ', isnull('  
        from #v_Ad_Name_Ded as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 --select @colsPivot9 = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '')   
 --       from #v_Ad_Name_Ded as a  
 --       cross apply ( select 'add_sort_name' col, 1 so ) c   
 --       group by col,a.AD_SORT_NAME,so   
 --       order by so   
 --     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivot9 = STUFF((SELECT '+ isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+ '') + ',0)  ' -- changed by rohit on 08082016 for sales india case  
        from #v_Ad_Name_Ded as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
set @colsPivot8 = 'isnull([' + @colsPivot8  
  
set @colsPivot8 = LEFT(@colsPivot8,len(@colsPivot8)-9)  
  
set @colsPivot10 = 'isnull([' + @colsPivot10  
  
set @colsPivot10 = LEFT(@colsPivot10,len(@colsPivot10)-9)  
  
  
if exists(select * from #v_Ad_Name_ded)  
begin  
set @query = 'select Emp_id, '+@colsPivot8+' into v_Ad_Calc_Ded   
 from (select emp_id,Ad_sort_name, M_Ad_Amount from #v_Ad_Name_Ded)   
 as data pivot   
 ( sum(M_Ad_Amount)   
 for Ad_sort_name in ('+ @colsPivot7 +') ) p'   
exec (@query)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_Ded  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID   --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Ad_Calc_Ded from v_Ad_Calc_Ded  
drop table v_Ad_Calc_Ded  
-------------  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_Arr' and type = 'u')   
begin   
 drop table #v_Ad_Name_Arr   
end   
   
--SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) )as M_AREAR_AMOUNT  , replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
--INTO       #v_Ad_Name_Arr  
--FROM         T0210_MONTHLY_AD_DETAIL AS m   
--   INNER JOIN T0050_AD_MASTER AS a ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
--   Inner join #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  --added jimit 26042016  
--WHERE   (m.For_Date = @From_Date)  --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date))   
----and M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and M_AD_Amount<>0 and AD_NOT_EFFECT_SALARY = 0 and m.Cmp_ID = @Company_ID -- commented and added by rohit on 07012017  
--and M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and (M_AREAR_AMOUNT<>0 OR m.M_AREAR_AMOUNT_Cutoff <> 0)   
--and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1)  --Condition changed by Nimesh On 07-May-2018 (Autopaid Reimbursement Arrear Amount is not getting calculated)  
--and m.Cmp_ID = @Company_ID  
--and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
----and m.emp_id in (select data from dbo.split(@constraint,'#'))  
--order by a.AD_SORT_NAME  
  
  
--New Code Added By Ramiz for Arrear Amount Head Wise -- Commented Old Code and Included Settlement Entries in this column   
SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) + isnull(MS_arear.ms_amount,0))as M_AREAR_AMOUNT  , replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
INTO       #v_Ad_Name_Arr  
FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
   INNER JOIN T0050_AD_MASTER AS a WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
   INNER JOIN #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  
   LEFT OUTER JOIN  
   (  
    SELECT  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear    
    FROM t0210_monthly_ad_detail MAD WITH (NOLOCK)    
     inner join T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id    
     inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id  
    WHERE MAD.Cmp_ID = @Company_ID and month(MSS.S_Eff_Date) = Month(@To_Date) and Year(MSS.S_Eff_Date) = Year(@To_Date)   
       and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1) --- Added "ReimShow" condition by Hardik 30/07/2020 for Arkray  
       and Ad_Active = 1   
    GROUP BY MAD.AD_ID,MSS.Emp_ID  
   ) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear  
WHERE   (m.For_Date = @From_Date)  
and M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and (M_AREAR_AMOUNT <> 0 OR m.M_AREAR_AMOUNT_Cutoff <> 0 or MS_arear.ms_amount <> 0)   
and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1)  
and m.Cmp_ID = @Company_ID  
and m.S_Sal_Tran_ID is NULL  
order by a.AD_SORT_NAME  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_Arr' and type = 'u')   
begin   
 drop table v_Ad_Calc_Arr  
end   
   
 select @colsPivotArr1 = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_Arr as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivotArr2 = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Arrear') + ', isnull('  
        from #v_Ad_Name_Arr as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivotArr3 = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear')   
        from #v_Ad_Name_Arr as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
 select @colsPivotArr4 = STUFF((SELECT ',isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear') + ',0) as' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear') --+ ', isnull('  
        from #v_Ad_Name_Arr as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
set @colsPivotArr2 = 'isnull([' + @colsPivotArr2  
  
set @colsPivotArr2 = LEFT(@colsPivotArr2,len(@colsPivotArr2)-9)  
  
  
if exists(select * from #v_Ad_Name_Arr)  
begin  
set @query = 'select Emp_id, '+@colsPivotArr2+' into v_Ad_Calc_Arr  
 from (select emp_id,Ad_sort_name, M_AREAR_AMOUNT from #v_Ad_Name_Arr)   
 as data pivot   
 ( sum(M_AREAR_AMOUNT)   
 for Ad_sort_name in ('+ @colsPivotArr1 +') ) p'   
exec (@query)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_Arr  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID  --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Ad_Calc_Arr from v_Ad_Calc_Arr  
drop table v_ad_Calc_Arr  
  
  
-------------------  
--if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_ntes' and type = 'u')   
--begin   
-- drop table #v_Ad_Name_ntes   
--end   
   
--SELECT     m.Emp_ID, m.M_AD_Amount, replace(a.AD_SORT_NAME,' ','_') as AD_SORT_NAME  
--INTO       #v_Ad_Name_ntes  
--FROM         T0210_MONTHLY_AD_DETAIL AS m   
--   INNER JOIN  T0050_AD_MASTER AS a ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
--   Inner join   dbo.split(@constraint,'#') on Data = m.Emp_ID  
--WHERE  (m.For_Date = @From_Date)   --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date))   
--and M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and (AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 1) and m.Cmp_ID = @Company_ID  
----and m.emp_id in (select data from dbo.split(@constraint,'#'))  
--order by a.AD_SORT_NAME  
  
  
  
--if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_ntes' and type = 'u')   
--begin   
-- drop table v_Ad_Calc_ntes  
--end   
   
-- select @colsPivot1_ntes_CTC = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
--        from #v_Ad_Name_ntes as a  
--        cross apply ( select 'add_sort_name' col, 1 so ) c   
--        group by col,a.AD_SORT_NAME,so   
--        order by so   
--      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
-- select @colsPivot2_ntes_CTC = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ', isnull('  
--        from #v_Ad_Name_ntes as a  
--        cross apply ( select 'add_sort_name' col, 1 so ) c   
--        group by col,a.AD_SORT_NAME,so   
--        order by so   
--      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
  
--set @colsPivot2_ntes_CTC = 'isnull([' + @colsPivot2_ntes_CTC  
  
--set @colsPivot2_ntes_CTC = LEFT(@colsPivot2_ntes_CTC,len(@colsPivot2_ntes_CTC)-9)  
  
--if exists(select * from #v_Ad_Name_ntes)  
--begin  
  
  
--set @query = 'select Emp_id, '+@colsPivot2_ntes_CTC+' into v_Ad_Calc_ntes  
-- from (select emp_id,Ad_sort_name, M_AD_Amount from #v_Ad_Name_ntes)   
-- as data pivot   
-- ( sum(M_AD_Amount)   
-- for Ad_sort_name in ('+ @colsPivot1_ntes_CTC +') ) p'   
   
--exec (@query)  
  
  
  
--end  
--else  
--begin  
-- select Distinct Emp_id,0 as Total_Earning into v_Ad_Calc_ntes  
-- from v_emp_cons  
-- inner join dbo.split(@emp_id1,'#') as ds on emp_id = data  
--end  
--select * into #v_Ad_Calc_ntes_CTC from v_Ad_Calc_ntes  
--drop table v_Ad_Calc_ntes  
  
  
-------------------  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_Arr_ntes' and type = 'u')   
begin   
 drop table #v_Ad_Name_Arr_ntes   
end   
   
SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) ) as M_AREAR_AMOUNT, replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
INTO       #v_Ad_Name_Arr_ntes  
FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
   INNER JOIN  T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
   Inner join   #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  --added jimit 26042016  
   --dbo.split(@constraint,'#') on Data = m.Emp_ID  
WHERE  (m.For_Date = @From_Date)   --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date))   
and M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and ( M_AREAR_AMOUNT<>0 or M_AREAR_AMOUNT_Cutoff<>0) and (AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 1) and m.Cmp_ID = @Company_ID  
and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
--and m.emp_id in (select data from dbo.split(@constraint,'#'))  
order by a.AD_SORT_NAME  
  
  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_Arr_ntes' and type = 'u')   
begin   
 drop table v_Ad_Calc_Arr_ntes  
end   
   
 select @colsPivotArr1_ntes = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_Arr_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivotArr2_ntes = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Arrear_ntes') + ', isnull('  
        from #v_Ad_Name_Arr_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivotArr3_ntes = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ntes')   
        from #v_Ad_Name_Arr_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
          
 select @colsPivotArr4_ntes = STUFF((SELECT ',isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ntes') + ',0) as' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ntes') --+ ', isnull('  
        from #v_Ad_Name_Arr_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
  
set @colsPivotArr2_ntes = 'isnull([' + @colsPivotArr2_ntes  
  
set @colsPivotArr2_ntes = LEFT(@colsPivotArr2_ntes,len(@colsPivotArr2_ntes)-9)  
  
if exists(select * from #v_Ad_Name_Arr_ntes)  
begin  
  
  
set @query = 'select Emp_id, '+@colsPivotArr2_ntes+' into v_Ad_Calc_Arr_ntes  
 from (select emp_id,Ad_sort_name, M_AREAR_AMOUNT from #v_Ad_Name_Arr_ntes)   
 as data pivot   
 ( sum(M_AREAR_AMOUNT)   
 for Ad_sort_name in ('+ @colsPivotArr1_ntes +') ) p'   
   
exec (@query)  
  
  
  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_Arr_ntes  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID  --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Ad_Calc_Arr_ntes from v_Ad_Calc_Arr_ntes  
drop table v_Ad_Calc_Arr_ntes  
-------------------  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_Arr_ded' and type = 'u')   
begin   
 drop table #v_Ad_Name_Arr_ded   
end   
   
--New Code of Settlement Added By Ramiz on 14/03/2019 for Arrear Amount Head Wise  
   
--SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) + isnull(MS_arear.ms_amount,0) ) as M_AREAR_AMOUNT, replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
--INTO       #v_Ad_Name_Arr_ded  
--FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
--  INNER JOIN T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
--  INNER JOIN  #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  --added jimit 26042016  
--  LEFT OUTER JOIN  
--   (  
--    SELECT  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear    
--    FROM t0210_monthly_ad_detail MAD  WITH (NOLOCK)   
--     inner join T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)  on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id    
--     inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id  
--    WHERE MAD.Cmp_ID = @Company_ID and month(MSS.S_Eff_Date) = Month(@To_Date) and Year(MSS.S_Eff_Date) = Year(@To_Date)   
--       and AD_NOT_EFFECT_SALARY = 0 and Ad_Active = 1   
--    GROUP BY MAD.AD_ID,MSS.Emp_ID  
--   ) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear  
--WHERE  (m.for_date = @From_Date)  
--and M_AD_Flag = 'D' and a.AD_ACTIVE = 1 and (M_AREAR_AMOUNT <> 0 OR m.M_AREAR_AMOUNT_Cutoff <> 0 or MS_arear.ms_amount <> 0)   
--and AD_NOT_EFFECT_SALARY = 0 and m.Cmp_ID = @Company_ID  
--and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
----and m.emp_id in (select data from dbo.split(@constraint,'#'))  
--order by a.AD_SORT_NAME  
  
SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) + isnull(MS_arear.ms_amount,0) ) as M_AREAR_AMOUNT, replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
INTO       #v_Ad_Name_Arr_ded  
FROM         T0210_MONTHLY_AD_DETAIL AS m   
  INNER JOIN T0050_AD_MASTER AS a ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
  INNER JOIN  #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  --added jimit 26042016  
  LEFT OUTER JOIN  
   (  
    SELECT  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear    
    FROM t0210_monthly_ad_detail MAD   
     inner join T0201_MONTHLY_SALARY_SETT MSS on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id    
     inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id  
    WHERE MAD.Cmp_ID = @Company_ID and month(MSS.S_Eff_Date) = Month(@To_Date) and Year(MSS.S_Eff_Date) = Year(@To_Date)   
       --and AD_NOT_EFFECT_SALARY = 0 -- Comment the changes to show the company ESIC as discussed with chintan bhai :- 02022022 Deepal  
       and Ad_Active = 1   
    GROUP BY MAD.AD_ID,MSS.Emp_ID  
   ) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear  
WHERE  (m.for_date = @From_Date)  
--and M_AD_Flag = 'D' -- Comment the changes to show the company ESIC as discussed with chintan bhai :- 02022022 Deepal  
 and a.AD_ACTIVE = 1 and (M_AREAR_AMOUNT <> 0 OR m.M_AREAR_AMOUNT_Cutoff <> 0 or MS_arear.ms_amount <> 0)   
--and AD_NOT_EFFECT_SALARY = 0  -- Comment the changes to show the company ESIC as discussed with chintan bhai :- 02022022 Deepal  
and m.Cmp_ID = @Company_ID  
and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
--and m.emp_id in (select data from dbo.split(@constraint,'#'))  
order by a.AD_SORT_NAME  
  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_Arr_ded' and type = 'u')   
begin   
 drop table v_Ad_Calc_Arr_ded  
end   
   
 select @colsPivotArr1_ded = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_Arr_ded as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivotArr2_ded = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Arrear_ded') + ', isnull('  
        from #v_Ad_Name_Arr_ded as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivotArr3_ded = STUFF((SELECT '+ isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ded') +',0)'  
       from #v_Ad_Name_Arr_ded as a  
       cross apply ( select 'add_sort_name' col, 1 so ) c   
       group by col,a.AD_SORT_NAME,so   
       order by so   
     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
 select @colsPivotArr4_ded = STUFF((SELECT ',isnull(' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ded') + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ded')   
        from #v_Ad_Name_Arr_ded as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
set @colsPivotArr2_ded = 'isnull([' + @colsPivotArr2_ded  
  
set @colsPivotArr2_ded = LEFT(@colsPivotArr2_ded,len(@colsPivotArr2_ded)-9)  
  
if exists(select * from #v_Ad_Name_Arr_ded)  
begin  
set @query = 'select Emp_id, ' + @colsPivotArr2_ded + ' into v_Ad_Calc_Arr_ded  
 from (select emp_id,Ad_sort_name, M_AREAR_AMOUNT from #v_Ad_Name_Arr_ded)   
 as data pivot   
 ( sum(M_AREAR_AMOUNT)   
 for Ad_sort_name in ('+ @colsPivotArr1_ded +') ) p'   
exec (@query)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_Arr_ded  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID  --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
  
select * into #v_Ad_Calc_Arr_ded from v_Ad_Calc_Arr_ded  
drop table v_Ad_Calc_Arr_ded  
------------------------  
if exists (select top 1 * from sysobjects where name = '#v_Ad_Name_Arr_ded_ntes' and type = 'u')   
begin   
 drop table #v_Ad_Name_Arr_ded_ntes   
end   
  
  
   
SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) ) as M_AREAR_AMOUNT, replace(a.AD_NAME,' ','_') as AD_SORT_NAME  
INTO       #v_Ad_Name_Arr_ded_ntes  
FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK)   
   INNER JOIN T0050_AD_MASTER AS a WITH (NOLOCK)  ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID  
            INNER JOIN  #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  --added jimit 26042016  
            --dbo.split(@constraint,'#') on Data = m.Emp_ID           
WHERE   (m.For_Date = @From_Date)  --(MONTH(m.For_Date) = MONTH(@From_Date)) AND (YEAR(m.For_Date) = YEAR(@From_Date))   
and M_AD_Flag = 'D' and a.AD_ACTIVE = 1 and ( M_AREAR_AMOUNT <> 0 OR m.M_AREAR_AMOUNT_Cutoff <> 0 ) and AD_NOT_EFFECT_SALARY = 1 and m.Cmp_ID = @Company_ID  
and m.S_Sal_Tran_ID is NULL    --added by jimit 25012017 to resolve WCL/RK issue  
--and m.emp_id in (select data from dbo.split(@constraint,'#'))  
order by a.AD_SORT_NAME  
  
  
  
if exists (select top 1 * from sysobjects where name = 'v_Ad_Calc_Arr_ded_ntes' and type = 'u')   
begin   
 drop table v_Ad_Calc_Arr_ded_ntes  
end   
   
 select @colsPivotArr1_ded_ntes = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)))   
        from #v_Ad_Name_Arr_ded_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
 select @colsPivotArr2_ded_ntes = STUFF((SELECT QUOTENAME(cast(AD_SORT_NAME as varchar(4000))) + ',0) as ' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000))+'_Arrear_ded') + ', isnull('  
        from #v_Ad_Name_Arr_ded_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
 select @colsPivotArr3_ded_ntes = STUFF((SELECT '+' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ded')   
        from #v_Ad_Name_Arr_ded_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
 select @colsPivotArr4_ded_ntes = STUFF((SELECT ',' + QUOTENAME(cast(AD_SORT_NAME as varchar(4000)) + '_Arrear_ded')   
        from #v_Ad_Name_Arr_ded_ntes as a  
        cross apply ( select 'add_sort_name' col, 1 so ) c   
        group by col,a.AD_SORT_NAME,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
set @colsPivotArr2_ded_ntes = 'isnull([' + @colsPivotArr2_ded_ntes  
  
set @colsPivotArr2_ded_ntes = LEFT(@colsPivotArr2_ded_ntes,len(@colsPivotArr2_ded_ntes)-9)  
  
  
if exists(select * from #v_Ad_Name_Arr_ded_ntes)  
begin  
set @query = 'select Emp_id, ' + @colsPivotArr2_ded_ntes + ' into v_Ad_Calc_Arr_ded_ntes  
 from (select emp_id,Ad_sort_name, M_AREAR_AMOUNT from #v_Ad_Name_Arr_ded)   
 as data pivot   
 ( sum(M_AREAR_AMOUNT)   
 for Ad_sort_name in ('+ @colsPivotArr1_ded_ntes +') ) p'   
exec (@query)  
end  
else  
begin  
 select Distinct ve.Emp_id,0 as Total_Deduction into v_Ad_Calc_Arr_ded_ntes  
 from v_emp_cons ve  
 inner join #Emp_Cons1 Ec ON Ec.emp_id = ve.Emp_ID --added jimit 26042016  
 --dbo.split(@emp_id1,'#') as ds on emp_id = data  
end  
select * into #v_Ad_Calc_Arr_ded_ntes from v_Ad_Calc_Arr_ded_ntes  
drop table v_Ad_Calc_Arr_ded_ntes  
------------------------  
--commented jimit 26042016  
--if CHARINDEX('#',@emp_id1) > 0  
--begin  
-- if @is_column = 1  
-- begin  
--  set @emp_id1 = left(@emp_id1,charindex('#',@emp_id1)-1)  
-- end  
--end  
---------ended-----------  
  
--+ case when isnull(@ColsPivot_Leave_Null_U, '') = '' then '0.00 as Unpaid' else @ColsPivot_Leave_Null_U + ',(ms.Total_Leave_Days - ms.Paid_Leave_Days) as Unpaid' end  + ',  
-- Added by rohit on 26122014  
if exists ( select 1 from sys.tables where name ='sumcheck' and  type='U')  
 begin   
   drop table sumcheck  
 end  
-- ended by rohit on 26122014  
  
---added jimit 21042016  
DECLARE @str_qry VARCHAR(max)  
DECLARE @cnt NUMERIC  
  
  Select @cnt = count(1) from T0200_MONTHLY_SALARY ms  WITH (NOLOCK) inner join  
  #Emp_Cons1 Ec ON Ec.emp_id = ms.Emp_ID --added jimit 26042016  
  --dbo.split(@emp_id1,'#') as ds on emp_id = data     
  where ms.GatePass_Deduct_Days <> 0    
         
       
  if @cnt > 0   
   BEGIN  
    SET @str_qry = 'ms.Late_Days,ms.Early_Days,ms.GatePass_Deduct_Days'  
   END  
  Else  
   BEGIN  
    SET @str_qry = 'ms.Late_Days,ms.Early_Days'  
   END  
-----ended------  
  
---------------------Added By Jimit 20122017-------------  
  
  
if exists (select top 1 * from sysobjects where name = '#v_Loan_pvt' and type = 'u')   
  begin   
     drop table #v_Loan_pvt  
  end   
  
  SELECT LM.LOAN_NAME,LA.LOAN_ID,LA.Emp_ID  
    ,(SUM(MLP.LOAN_PAY_AMOUNT) + Case when isnull(LM.Is_Principal_First_than_Int,0)<>1 and LM.Is_Intrest_Amount_As_Perquisite_IT = 0  
            then SUM(ISNULL(MLP.INTEREST_AMOUNT,0))   
           else 0 end  
           ) as Loan_Amount  
  INTO #v_Loan_pvt  
  FROM T0210_MONTHLY_LOAN_PAYMENT MLP WITH (NOLOCK)  INNER JOIN   
    T0120_LOAN_APPROVAL LA WITH (NOLOCK)  ON MLP.LOAN_APR_ID=LA.LOAN_APR_ID INNER JOIN  
    T0040_LOAN_MASTER LM WITH (NOLOCK)  ON LA.LOAN_ID=LM.LOAN_ID  
  WHERE MLP.LOAN_PAYMENT_DATE BETWEEN @From_Date AND @To_Date AND SAL_TRAN_ID IS NOT NULL AND MLP.CMP_ID=@Company_id  
  GROUP BY LA.Emp_ID,LM.LOAN_NAME,LA.LOAN_ID,LM.Is_Principal_First_than_Int,LM.Is_Intrest_Amount_As_Perquisite_IT  
  ORDER BY LM.LOAN_NAME  
  
  
    
  select * into #v_Loan_pvt3 from #v_Loan_pvt  
  
  
  
  if exists (select top 1 * from sysobjects where name = '#v_Loan' and type = 'u')   
   begin   
     drop table #v_Loan  
   end   
  
  Declare @ColsPivot_Loan as varchar(max),@ColsPivot_Loan_Null as varchar(max),@ColsPivot_Loan_Total as varchar(max),  
    @qry_Loan as varchar(max)  
  
 set @ColsPivot_Loan = STUFF((SELECT ',' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Loan_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-','
 '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000)))   
        from #v_Loan_pvt3 as a  
        cross apply ( select 'Loan_Name' col, 1 so ) c   
        group by col,a.Loan_Name,so   
        order by so   
      FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
   
 --set @ColsPivot_Loan_Null = STUFF((SELECT ',ISNULL(' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Loan_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000))) + ',0) AS ' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Loan_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000)))  
 --       from #v_Loan_pvt3 as a  
 --       cross apply ( select 'Loan_Name' col, 1 so ) c   
 --       group by col,a.Loan_Name,so   
 --       order by so   
 --     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
   
   
   
 --set @ColsPivot_Loan_Total = STUFF((SELECT '+ISNULL(' + QUOTENAME(cast(Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Loan_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') as varchar(4000))) + ',0)'  
 --       from #v_Loan_pvt3 as a  
 --       cross apply ( select 'Loan_Name' col, 1 so ) c   
 --       group by col,a.Loan_Name,so   
 --       order by so   
 --     FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')  
  
  
  if exists(select * from #v_Loan_pvt3)  
  begin  
   set @qry_Loan = 'select Emp_id, '+@colsPivot_Loan+' into v_Loan          
      from (select emp_id,REPLACE(Loan_Name,'' '',''_'') As Loan_Name, IsNULL(Loan_Amount,0) as Loan_Amount from #v_Loan_pvt3)   
      as data pivot   
      ( sum(Loan_Amount)   
      for Loan_Name in ('+ @colspivot_loan +') ) p'   
   --print @qry_Loan  
   exec (@qry_Loan)  
  end  
  else  
  begin  
   select Distinct ve.Emp_id,0 as Total_Loan into v_Loan  
   from v_emp_cons ve  
   inner join #Emp_Cons1 Ec ON Ec.emp_id = VE.Emp_ID  --added jimit 26042016  
   --dbo.split(@emp_id1,'#') as ds on emp_id = data  
  end  
  select * into #v_Loan from v_Loan  
  drop table v_Loan  
  
    
    
  --select emp_id,Loan_Name, IsNULL(Loan_Amount,0) as Loan_Amount from #v_Loan_pvt3  
    
    
--------------------------ended-----------------------------  
  
  
  
IF (@Order_By = 'Name')   
 SET @Order_By = 'Emp_Full_Name'  
ELSE IF (@Order_By = 'Code')   
 SET @Order_By = 'EMP_CODE'  
ELSE IF (@Order_By = 'Enroll_No') --added by jaina 06082015  
 SET @Order_By = 'RIGHT(REPLICATE(N''0'', 20) + Cast(Enroll_No As Varchar), 20)'  
ELSe IF  (@Order_By = 'Designation')   --added jimit 24082015  
 SET  @Order_By = 'Desig_Dis_No'  
 --Added by jaina 07082015 Center_Code,SIN_No (ESIC No) ,SSN_No (PF NO)--Replace(Emp_Full_Name,EM.initial,'''') as Emp_Full_Name,  
 SET @colsPivot5_ntes = REPLACE(@colsPivot5_ntes,'isnull(', 'isnull(mAdE_ntes.')  
  
 IF @colsPivot_T IS NOT NULL AND @colsPivot_T_ntes IS NOT NULL  
  SET @colsPivot_T = @colsPivot_T + ',' + @colsPivot_T_ntes  
  
   --Isnull(e_Ad_Amount,0) + Isnull(inc1.Basic_Salary,0) +  isnull(' + isnull(@colsPivot_ded,0) +',0) as CTC_Actual,   
   --i_q.CTC as CTC_Actual,  
  --select @colsPivot_T,@colsPivot_Add_ntes  
    
--select * from #v_Ad_Calc   
--select * from #v_ad_calc_ntes  
--select * from #v_ad_calc_d  
--select * from #v_ad_calc_E  
--select * from #v_ad_calc_ded  
--select * from #v_Ad_Calc_Arr  
--select * from #v_Ad_Calc_Arr_ntes  
--SELECT  @colsPivotArr4  
  
set @query = ' Select (ROW_NUMBER() OVER (ORDER BY ' + @Order_By + ')) As Sr_No,* from (  
SELECT Distinct ''="'' + EM.Alpha_Emp_Code + ''"'' as EMP_CODE,    
   Replace(isnull(EmpName_Alias_Salary,Emp_full_name),EM.initial,'''') as Emp_Full_Name,  
   bm.Branch_Name as Branch,SMM.State_Name as Branch_State,VS.vertical_name,sv.subvertical_name,dm.Dept_Name as Department,dsm.desig_name as Designation,gm.Grd_Name as Grade,BND.BandName,tm.Type_Name as TypeName,CCM.Center_Name As Cost_Center,CCM.Center_C
ode,CCM.Cost_Element,CMM.Cat_Name as Category,SB.Subbranch_name,BS.Segment_Name,EM.Enroll_NO,  
   convert(varchar(30),Join_Date,103) as Joining_Date,ISNULL(CONVERT(VARCHAR(30),LEFT_DATE,103),'''') as Left_Date  
   ,em.Pan_No,EM.Aadhar_Card_No,convert(varchar(30),EM.Date_Of_Birth,103) as Date_Of_Birth ,EM.Mobile_No,EM.Work_Email as Official_Email,  
   isnull(ms.OutOf_Days,0) as Month_Days ,isnull(ms.Present_days,0) as Present_Day,  
  
   Case When   
    isnull(ms.Absent_days,0) > (select sum(Leave_Used) from #v_Leave_pvt_u U where U.Emp_ID = EM.Emp_ID group by U.Emp_ID)  
   Then isnull(ms.Absent_days,0) - (select sum(Leave_Used) from #v_Leave_pvt_u U where U.Emp_ID = EM.Emp_ID group by U.Emp_ID)  
   Else isnull(ms.Absent_days,0)   
   End as Absent_Day,'  /* Change by Hardik for Actual Absent day should show without Unpaid leave count for CERA Client 07/09/2019 */  
  
   + ' isnull(ms.Holiday_days,0) as holiday_day, ISNULL(ms.weekoff_days,0) as Weekoff_Day, '   
   + case when isnull(@ColsPivot_Leave_Null, '') = '' then 'ms.paid_leave_days + Isnull(OD_Leave_Days,0) as Total_Paid_Leave_Days' else @ColsPivot_Leave_Null  + ',ms.paid_leave_days + OD_Leave_Days as Total_Paid_Leave_Days' end  + ','  
   + isnull(@ColsPivot_Leave_Null_U,'0 as Unpaid') + ',       
   ms.Total_Leave_Days,'+ @str_qry +',ms.Sal_Cal_Days as Sal_Cal_Day, Isnull(ms.Arear_Day,0) + isnull(Arear_Day_Previous_month,0) as Arear_Day, tmpia.Extra_Day_Month as Arear_Day_Month,ms.Present_on_holiday as Present_on_holiday,  
   I_Q.Basic_Salary as Basic_Actual,  
   ' + isnull(@colsPivot_T,'0 as Total_Actual') + ',           
   Isnull(e_Ad_Amount,0)+Isnull(inc1.Basic_Salary,0) as Gross_Salary_Actual ,   
   ' + isnull(@colsPivot_Add_ntes,'0') + 'as Non_Gross_Salary_Actual,   
   ' + isnull(@colsPivot_T_ntes_autoPaid,'0') + 'as Total_Auto_Paid_Salary_Actual,   
   Isnull(e_Ad_Amount,0) + Isnull(inc1.Basic_Salary,0) + Isnull(' + isnull(@colsPivot_Add_ntes,'0') + ',0) as CTC_Actual,   
   (case when SMM.PT_Deduction_Type = ''Monthly'' then inc1.Emp_PT_Amount else 0 end) as PT_Amount_Actual,  
   ' + isnull(@colsPivot_ded1,'0 as Deduction_Actual') + ',   
   inc1.Emp_PT_Amount + isnull(' + isnull(@colsPivot_ded,0) +',0) as Total_Deduction_Actual,  
   Isnull(e_Ad_Amount,0) + Isnull(inc1.Basic_Salary,0) - (Isnull(inc1.Emp_PT_Amount,0) + isnull(' + isnull(@colsPivot_ded,0) +',0)) as Net_Amount_Actual,  
   ms.salary_amount as Basic_Salary,  
   isnull(ms.Settelement_Amount,0) as Settl_Salary,  
   ms.Other_Allow_Amount as Other_Allow,  
   ' + isnull(@colsPivot5,'0 as Other_Earnings') + ',  
   --Isnull(ms.salary_Amount,0) + IsNull(mADi.Allow_Amount,0) + isnull(ms.Settelement_Amount,0) as Total_Earning,  
   Isnull(ms.salary_Amount,0) + IsNull(mADi.Allow_Amount,0)  as Total_Earning,  
   (isnull(ms.Arear_Basic,0) + isnull(ms.Basic_Salary_arear_cutoff,0) + isnull(sett.S_Salary_Amount,0))  as Basic_Salary_Arrear,  
   ' + isnull(@colsPivotArr4,'0 as Arears') + ',  
   (isnull(ms.Arear_Basic,0) + isnull(ms.Basic_Salary_arear_cutoff,0) + isnull(sett.S_Salary_Amount,0)) + isnull(' + isnull(@colsPivotArr3,0) + ',0) as Total_Arrear_Earning,  
   ISNULL(ms.M_HO_OT_Hours,0) as Holiday_OT_Hours,  
   ISNULL(ms.M_HO_OT_Amount,0) as Holiday_OT_Amount ,  
   ISNULL(ms.M_WO_OT_Hours,0) as Weekoff_OT_Hours,  
   ISNULL(ms.M_WO_OT_Amount,0) as Weekoff_OT_Amount,   
   Case When inc.Fix_OT_Hour_Rate_WD > 0 then round(inc.Fix_OT_Hour_Rate_WD,2) else (case when isnull(dbo.F_Return_Sec(isnull(ot_fix_shift_hours,''00:00'')),0) = 0 then round(Hour_Salary,2) else round(isnull(Day_Salary,0)* 3600/dbo.F_Return_Sec(isnull(ot_
fix_shift_hours,''00:00'')),2) end)  end as Ot_Rate,  
   isnull(OT_Hours,0) as OT_Hours,  
   isnull(OT_Amount,0) OT_Amount,      
   Isnull(inc.Fix_OT_Hour_Rate_WD,0) as WeekDay_Fix_OT_Rate,  
   Isnull(inc.Fix_OT_Hour_Rate_WO_HO,0) as WO_HO_Fix_OT_Rate,  
   ISNULL(msg.Grd_OT_Hours/2,0) AS Grade_OT_Hours,  
   ISNULL(ms.Leave_Salary_Amount,0) as leave_Encash_Amount,  
   isnull(ms.Travel_Amount,0) as Travel_Amount,  
   isnull(ms.Total_Claim_Amount,0) as Total_Claim_Amount,  
   isnull(ms.Uniform_Refund_Amount,0) as Uniform_Refund_Amount,  
   Case When isnull(ms.Settelement_Amount,0) > 0 then  
    ms.gross_salary - isnull(ms.Settelement_Amount,0) +(isnull(ms.Arear_Basic,0) + isnull(ms.Basic_Salary_arear_cutoff,0) + isnull(sett.S_Salary_Amount,0)) + isnull(' + isnull(@colsPivotArr3,0) + ',0)  
   Else  
    ms.gross_salary  
   End As Gross_Salary,  
     
   ms.PT_Amount,  
   ' + Isnull(@ColsPivot_Loan,'0 As Loan_Amount') + ',  
   Isnull(Bond_Amount,0) as Bond_Amount,  
   Isnull(Advance_Amount,0) as Advance_Amount,  
   ' + isnull(@colsPivot10,'0 as Other_Amount') + ',  
   ms.Revenue_Amount,  
   isnull(ms.LWF_Amount,0) as LWF_Amount,  
   Isnull(Other_Dedu_Amount,0) as Other_Dedu,  
   isnull(ms.GatePass_Amount,0) as Gate_Pass_Amount ,  
   isnull(ms.Asset_Installment,0) as Asset_Installment_Amount,  
   isnull(ms.Uniform_Dedu_Amount,0) as Uniform_Installment_Amount,  
   isnull(ms.Late_Dedu_Amount,0) as Late_Dedu_Amount,  
   ' + isnull(@colsPivot9,0) + ' + IsNull(ms.PT_Amount,0) + isnull(ms.loan_amount,0) + isnull(ms.Loan_Intrest_Amount,0) + Isnull(Advance_Amount,0)+ms.Revenue_Amount + isnull(ms.LWF_Amount,0) + Isnull(Other_Dedu_Amount,0) +isnull(ms.GatePass_Amount,0)+isnu
ll(ms.Asset_Installment,0)+isnull(ms.Uniform_Dedu_Amount,0)+isnull(ms.Late_Dedu_Amount,0)   as Total_Deduction,  
   ' + isnull(@colsPivotArr4_ded,'0 as Arear_Deduction')+ ',  
   ' + isnull(@colsPivotArr3_ded,0) + ' as Total_Arrear_Deduction,  
   Case When isnull(ms.Settelement_Amount,0) > 0 then  
    ms.Total_Dedu_Amount +' + isnull(@colsPivotArr3_ded,0) + '    
   Else  
    ms.Total_Dedu_Amount  
   End as Net_Total_Deduction,  
   ISnull(ms.Net_Amount,0) - IsNull(Net_Salary_Round_Diff_Amount,0) As Net_Salary ,  
   Ms.Net_Salary_Round_Diff_Amount As Net_Round,  
   isnull(ms.Travel_Advance_Amount,0) as Travel_Advance_Amount,  
   ms.Net_Amount As Total_Net ,  
   '+isnull(@colsPivotArr4_ntes,'0 as Other_Arrear_Allowance') +',  
   '+ isnull(@colsPivotPartOfCTC,'0 as Other_Part_Of_CTC') + ',  
    ms.gross_salary + ' + ISNULL(@colsPivotPartOfCTC_Sum,0) + '  as Total_CTC_Salary,  
   '+isnull(@colsPivot5_ntes,'0 as Other_Allowance_C') +',  
   ms.salary_Status,     
   inc1.Payment_Mode,  
   Bank.Bank_Name,   
   ''="'' + inc1.Inc_Bank_AC_No + ''"'' as Inc_Bank_AC_No,  
   inc1.Bank_Branch_Name, IFSC_Code As Bank_IFSC_Code, ''="'' + UAN_No + ''"'' as UAN_No,''="'' + EM.SIN_No + ''"'' As ESIC_No , ''="''+ EM.SSN_No + ''"'' AS PF_No  
   ,dsm.Desig_dis_No as Desig_dis_No , EM.Gender  
   ,(  
   SELECT  MAD.M_AD_Calculated_Amount  
   FROM T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)    
     INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)  ON MAD.AD_ID = AD.AD_ID  
   WHERE AD.AD_DEF_ID = 2 and MAD.M_AD_Amount > 0  
     And month(To_date)=month('''+ cast(@To_Date AS varchar(20)) +''')  
     And year(To_date)=year('''+ cast(@To_Date AS varchar(20)) +''')  
     And MAD.Emp_ID= EM.Emp_Id And S_Sal_Tran_Id Is null  
   ) as PF_WAGES ,  
     
   (  
     SELECT  MAD.M_AD_Calculated_Amount   
     FROM T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)    
     INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)  ON MAD.AD_ID = AD.AD_ID  
     WHERE AD.AD_DEF_ID = 3 and MAD.M_AD_Amount > 0  
     And month(To_date)=month('''+ cast(@To_Date AS varchar(20)) +''')  
     And year(To_date)=year('''+ cast(@To_Date AS varchar(20)) +''')  
     And MAD.Emp_ID = EM.Emp_Id And S_Sal_Tran_Id Is null  
   )as ESI_WAGES, Qual_Names As Qualification, CASE WHEN Marital_Status = 0 THEN ''Single''  
      WHEN Marital_Status = 1 THEN ''Married''  
      WHEN Marital_Status = 2 THEN ''Divorced''  
      WHEN Marital_Status = 3 THEN ''Separated''  
      WHEN Marital_Status = 4 THEN ''Widowed''  
     END AS Marital_Status,   
     --Qry_Reporting.Manager_Code + '' - '' + Manager_Name As Reporting_Manager,   
     Left(DateName(MONTH,MS.Month_End_Date),3) + ''-'' + Cast(YEAR(MS.Month_End_Date) as varchar(4)) As Month_Year  
       
   '  
  
--added by mansi start For SalesIndia client Only(CTC Actual Calculation as per informed by nikunjbhai)30-11-21   
--set @query = ' Select (ROW_NUMBER() OVER (ORDER BY ' + @Order_By + ')) As Sr_No,* from (  
--SELECT Distinct ''="'' + EM.Alpha_Emp_Code + ''"'' as EMP_CODE,    
--   Replace(isnull(EmpName_Alias_Salary,Emp_full_name),EM.initial,'''') as Emp_Full_Name,  
--   bm.Branch_Name as Branch,SMM.State_Name as Branch_State,VS.vertical_name,sv.subvertical_name,dm.Dept_Name as Department,dsm.desig_name as Designation,gm.Grd_Name as Grade,BND.BandName,tm.Type_Name as TypeName,CCM.Center_Name As Cost_Center,CCM.Center_Code,CCM.Cost_Element,CMM.Cat_Name as Category,SB.Subbranch_name,BS.Segment_Name,EM.Enroll_NO,  
--   convert(varchar(30),Join_Date,103) as Joining_Date,ISNULL(CONVERT(VARCHAR(30),LEFT_DATE,103),'''') as Left_Date  
--   ,em.Pan_No,EM.Aadhar_Card_No,convert(varchar(30),EM.Date_Of_Birth,103) as Date_Of_Birth ,EM.Mobile_No,EM.Work_Email as Official_Email,  
--   isnull(ms.OutOf_Days,0) as Month_Days ,isnull(ms.Present_days,0) as Present_Day,  
  
--   Case When   
--    isnull(ms.Absent_days,0) > (select sum(Leave_Used) from #v_Leave_pvt_u U where U.Emp_ID = EM.Emp_ID group by U.Emp_ID)  
--   Then isnull(ms.Absent_days,0) - (select sum(Leave_Used) from #v_Leave_pvt_u U where U.Emp_ID = EM.Emp_ID group by U.Emp_ID)  
--   Else isnull(ms.Absent_days,0)   
--   End as Absent_Day,'  /* Change by Hardik for Actual Absent day should show without Unpaid leave count for CERA Client 07/09/2019 */  
  
--   + ' isnull(ms.Holiday_days,0) as holiday_day, ISNULL(ms.weekoff_days,0) as Weekoff_Day, '   
--   + case when isnull(@ColsPivot_Leave_Null, '') = '' then 'ms.paid_leave_days + Isnull(OD_Leave_Days,0) as Total_Paid_Leave_Days' else @ColsPivot_Leave_Null  + ',ms.paid_leave_days + OD_Leave_Days as Total_Paid_Leave_Days' end  + ','  
--   + isnull(@ColsPivot_Leave_Null_U,'0 as Unpaid') + ',       
--   ms.Total_Leave_Days,'+ @str_qry +',ms.Sal_Cal_Days as Sal_Cal_Day, Isnull(ms.Arear_Day,0) + isnull(Arear_Day_Previous_month,0) as Arear_Day, tmpia.Extra_Day_Month as Arear_Day_Month,ms.Present_on_holiday as Present_on_holiday,  
--   I_Q.Basic_Salary as Basic_Actual,  
--   ' + isnull(@colsPivot_T,'0 as Total_Actual') + ',           
--   Isnull(e_Ad_Amount,0)+Isnull(inc1.Basic_Salary,0) as Gross_Salary_Actual ,   
--   ' + isnull(@colsPivot_Add_ntes,'0') + 'as Non_Gross_Salary_Actual,   
--   ' + isnull(@colsPivot_T_ntes_autoPaid,'0') + 'as Total_Auto_Paid_Salary_Actual,   
--   --Isnull(e_Ad_Amount,0) + Isnull(inc1.Basic_Salary,0) + Isnull(' + isnull(@colsPivot_Add_ntes,'0') + ',0) as CTC_Actual,  
--   i_q.CTC as CTC_Actuals,  
--   (case when SMM.PT_Deduction_Type = ''Monthly'' then inc1.Emp_PT_Amount else 0 end) as PT_Amount_Actual,  
--   ' + isnull(@colsPivot_ded1,'0 as Deduction_Actual') + ',   
--   inc1.Emp_PT_Amount + isnull(' + isnull(@colsPivot_ded,0) +',0) as Total_Deduction_Actual,  
--   Isnull(e_Ad_Amount,0) + Isnull(inc1.Basic_Salary,0) - (Isnull(inc1.Emp_PT_Amount,0) + isnull(' + isnull(@colsPivot_ded,0) +',0)) as Net_Amount_Actual,  
--   ms.salary_amount as Basic_Salary,  
--   isnull(ms.Settelement_Amount,0) as Settl_Salary,  
--   ms.Other_Allow_Amount as Other_Allow,  
--   ' + isnull(@colsPivot5,'0 as Other_Earnings') + ',  
--   --Isnull(ms.salary_Amount,0) + IsNull(mADi.Allow_Amount,0) + isnull(ms.Settelement_Amount,0) as Total_Earning,  
--   Isnull(ms.salary_Amount,0) + IsNull(mADi.Allow_Amount,0)  as Total_Earning,  
--   (isnull(ms.Arear_Basic,0) + isnull(ms.Basic_Salary_arear_cutoff,0) + isnull(sett.S_Salary_Amount,0))  as Basic_Salary_Arrear,  
--   ' + isnull(@colsPivotArr4,'0 as Arears') + ',  
--   (isnull(ms.Arear_Basic,0) + isnull(ms.Basic_Salary_arear_cutoff,0) + isnull(sett.S_Salary_Amount,0)) + isnull(' + isnull(@colsPivotArr3,0) + ',0) as Total_Arrear_Earning,  
--   ISNULL(ms.M_HO_OT_Hours,0) as Holiday_OT_Hours,  
--   ISNULL(ms.M_HO_OT_Amount,0) as Holiday_OT_Amount ,  
--   ISNULL(ms.M_WO_OT_Hours,0) as Weekoff_OT_Hours,  
--   ISNULL(ms.M_WO_OT_Amount,0) as Weekoff_OT_Amount,   
--   Case When inc.Fix_OT_Hour_Rate_WD > 0 then round(inc.Fix_OT_Hour_Rate_WD,2) else (case when isnull(dbo.F_Return_Sec(isnull(ot_fix_shift_hours,''00:00'')),0) = 0 then round(Hour_Salary,2) else round(isnull(Day_Salary,0)* 3600/dbo.F_Return_Sec(isnull(ot_fix_shift_hours,''00:00'')),2) end)  end as Ot_Rate,  
--   isnull(OT_Hours,0) as OT_Hours,  
--   isnull(OT_Amount,0) OT_Amount,      
--   Isnull(inc.Fix_OT_Hour_Rate_WD,0) as WeekDay_Fix_OT_Rate,  
--   Isnull(inc.Fix_OT_Hour_Rate_WO_HO,0) as WO_HO_Fix_OT_Rate,  
--   ISNULL(msg.Grd_OT_Hours/2,0) AS Grade_OT_Hours,  
--   ISNULL(ms.Leave_Salary_Amount,0) as leave_Encash_Amount,  
--   isnull(ms.Travel_Amount,0) as Travel_Amount,  
--   isnull(ms.Total_Claim_Amount,0) as Total_Claim_Amount,  
--   isnull(ms.Uniform_Refund_Amount,0) as Uniform_Refund_Amount,  
--   Case When isnull(ms.Settelement_Amount,0) > 0 then  
--    ms.gross_salary - isnull(ms.Settelement_Amount,0) +(isnull(ms.Arear_Basic,0) + isnull(ms.Basic_Salary_arear_cutoff,0) + isnull(sett.S_Salary_Amount,0)) + isnull(' + isnull(@colsPivotArr3,0) + ',0)  
--   Else  
--    ms.gross_salary  
--   End As Gross_Salary,  
     
--   ms.PT_Amount,  
--   ' + Isnull(@ColsPivot_Loan,'0 As Loan_Amount') + ',  
--   Isnull(Bond_Amount,0) as Bond_Amount,  
--   Isnull(Advance_Amount,0) as Advance_Amount,  
--   ' + isnull(@colsPivot10,'0 as Other_Amount') + ',  
--   ms.Revenue_Amount,  
--   isnull(ms.LWF_Amount,0) as LWF_Amount,  
--   Isnull(Other_Dedu_Amount,0) as Other_Dedu,  
--   isnull(ms.GatePass_Amount,0) as Gate_Pass_Amount ,  
--   isnull(ms.Asset_Installment,0) as Asset_Installment_Amount,  
--   isnull(ms.Uniform_Dedu_Amount,0) as Uniform_Installment_Amount,  
--   isnull(ms.Late_Dedu_Amount,0) as Late_Dedu_Amount,  
--   ' + isnull(@colsPivot9,0) + ' + IsNull(ms.PT_Amount,0) + isnull(ms.loan_amount,0) + isnull(ms.Loan_Intrest_Amount,0) + Isnull(Advance_Amount,0)+ms.Revenue_Amount + isnull(ms.LWF_Amount,0) + Isnull(Other_Dedu_Amount,0) +isnull(ms.GatePass_Amount,0)+isnull(ms.Asset_Installment,0)+isnull(ms.Uniform_Dedu_Amount,0)+isnull(ms.Late_Dedu_Amount,0)   as Total_Deduction,  
--   ' + isnull(@colsPivotArr4_ded,'0 as Arear_Deduction')+ ',  
--   ' + isnull(@colsPivotArr3_ded,0) + ' as Total_Arrear_Deduction,  
--   Case When isnull(ms.Settelement_Amount,0) > 0 then  
--    ms.Total_Dedu_Amount +' + isnull(@colsPivotArr3_ded,0) + '    
--   Else  
--    ms.Total_Dedu_Amount  
--   End as Net_Total_Deduction,  
--   ISnull(ms.Net_Amount,0) - IsNull(Net_Salary_Round_Diff_Amount,0) As Net_Salary ,  
--   Ms.Net_Salary_Round_Diff_Amount As Net_Round,  
--   isnull(ms.Travel_Advance_Amount,0) as Travel_Advance_Amount,  
--   ms.Net_Amount As Total_Net ,  
--   '+isnull(@colsPivotArr4_ntes,'0 as Other_Arrear_Allowance') +',  
--   '+ isnull(@colsPivotPartOfCTC,'0 as Other_Part_Of_CTC') + ',  
--    ms.gross_salary + ' + ISNULL(@colsPivotPartOfCTC_Sum,0) + '  as Total_CTC_Salary,  
--   '+isnull(@colsPivot5_ntes,'0 as Other_Allowance_C') +',  
--   ms.salary_Status,     
--   inc1.Payment_Mode,  
--   Bank.Bank_Name,   
--   ''="'' + inc1.Inc_Bank_AC_No + ''"'' as Inc_Bank_AC_No,  
--   inc1.Bank_Branch_Name, IFSC_Code As Bank_IFSC_Code, ''="'' + UAN_No + ''"'' as UAN_No,''="'' + EM.SIN_No + ''"'' As ESIC_No , ''="''+ EM.SSN_No + ''"'' AS PF_No  
--   ,dsm.Desig_dis_No as Desig_dis_No , EM.Gender  
--   ,(  
--   SELECT  MAD.M_AD_Calculated_Amount  
--   FROM T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)    
--     INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)  ON MAD.AD_ID = AD.AD_ID  
--   WHERE AD.AD_DEF_ID = 2 and MAD.M_AD_Amount > 0  
--     And month(To_date)=month('''+ cast(@To_Date AS varchar(20)) +''')  
--     And year(To_date)=year('''+ cast(@To_Date AS varchar(20)) +''')  
--     And MAD.Emp_ID= EM.Emp_Id And S_Sal_Tran_Id Is null  
--   ) as PF_WAGES ,  
     
--   (  
--     SELECT  MAD.M_AD_Calculated_Amount   
--     FROM T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)    
--     INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)  ON MAD.AD_ID = AD.AD_ID  
--     WHERE AD.AD_DEF_ID = 3 and MAD.M_AD_Amount > 0  
--     And month(To_date)=month('''+ cast(@To_Date AS varchar(20)) +''')  
--     And year(To_date)=year('''+ cast(@To_Date AS varchar(20)) +''')  
--     And MAD.Emp_ID = EM.Emp_Id And S_Sal_Tran_Id Is null  
--   )as ESI_WAGES, Qual_Names As Qualification, CASE WHEN Marital_Status = 0 THEN ''Single''  
--      WHEN Marital_Status = 1 THEN ''Married''  
--      WHEN Marital_Status = 2 THEN ''Divorced''  
--      WHEN Marital_Status = 3 THEN ''Separated''  
--      WHEN Marital_Status = 4 THEN ''Widowed''  
--     END AS Marital_Status,   
--     --Qry_Reporting.Manager_Code + '' - '' + Manager_Name As Reporting_Manager,   
--     Left(DateName(MONTH,MS.Month_End_Date),3) + ''-'' + Cast(YEAR(MS.Month_End_Date) as varchar(4)) As Month_Year  
       
--   '  
--adde by mansi end 30-11-21  
  
if @Summary = ''  
 Begin  
  set @query = replace(@query,'As Sr_No,* from (', ' As Sr_No,* into sumcheck from (')    
   
 End  
   
if @Summary <> ''   
begin  
   
 set @query = replace(@query,'As Sr_No,* from (', 'As Sr_No,* into sumcheck from (')  
  
   
end   
  
set @query1 = '  
FROM         V_Emp_Cons AS ec INNER JOIN  
         (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID,ti.Fix_OT_Hour_Rate_WD,ti.Fix_OT_Hour_Rate_WO_HO from t0095_increment TI WITH (NOLOCK)  inner join  
        (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)   
        Where cmp_ID = ' + cast(@Company_id as nvarchar(3)) + ' And Increment_effective_Date <= '''+convert(nvarchar(10),@To_Date,101)+''' Group by emp_ID) new_inc  
        on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
        Where TI.Increment_effective_Date <= '''+convert(nvarchar(10),@To_Date,101)+''' group by ti.emp_id,ti.Fix_OT_Hour_Rate_WD,ti.Fix_OT_Hour_Rate_WO_HO)   
        AS inc ON ec.Emp_ID = inc.Emp_ID AND ec.Increment_ID = inc.Increment_ID  
                            inner join t0040_General_Setting gs WITH (NOLOCK)  on ec.cmp_id = gs.cmp_id and ec.branch_id = gs.branch_id and  gs.For_Date = (select max(for_date) From T0040_General_Setting where Cmp_ID = ec.cmp_id and Branch_ID =ec.branch_i
d)  
                            inner join T0030_BRANCH_MASTER as bm WITH (NOLOCK)  on ec.Branch_ID = bm.Branch_ID and ec.Cmp_ID = bm.Cmp_ID  
        Left Outer Join tblBandMaster as BND WITH (NOLOCK)  on BND.BandId=ec.Band_ID  
                            Left Outer Join T0020_STATE_MASTER SMM WITH (NOLOCK)  on bm.State_Id = SMM.State_Id And bm.Cmp_Id = SMM.Cmp_Id  
                            left outer join T0040_DEPARTMENT_MASTER as dm WITH (NOLOCK)  on ec.Dept_ID = dm.Dept_Id and ec.Cmp_Id = dm.cmp_id  
                            left outer join T0040_GRADE_MASTER as gm WITH (NOLOCK)  on ec.Grd_ID = gm.Grd_ID and ec.Cmp_ID = gm.Cmp_ID  
                            left outer join T0040_TYPE_MASTER as tm WITH (NOLOCK)  on ec.Type_ID = tm.Type_ID and ec.Cmp_ID = tm.Cmp_ID  
                            left outer join T0040_DESIGNATION_MASTER as dsm WITH (NOLOCK)  on ec.desig_id = dsm.desig_id and ec.cmp_id = dsm.cmp_id  
                            inner join T0080_EMP_MASTER as EM WITH (NOLOCK)  on ec.Emp_ID = em.Emp_ID  
                            inner join (select * from t0200_monthly_salary WITH (NOLOCK)  where  cmp_ID = ' + cast(@Company_id as nvarchar(max)) + ' And Month_St_Date = '''+convert(nvarchar(10),@From_Date,101)+''') as ms on ec.Emp_ID = ms.Emp_ID and ec.Cm
p_ID = ms.Cmp_ID  
                            left outer join #v_Ad_Calc as adc on ec.emp_id = adc.emp_id  
                            left outer join #v_ad_calc_ntes adc_ntes on ec.emp_id = adc_ntes.emp_id  
                            left join (select t1.* from T0095_INCREMENT t1 WITH (NOLOCK)  inner join (SELECT Emp_ID, MAX(Increment_ID) AS Increment_ID FROM T0095_INCREMENT WITH (NOLOCK)  where  cmp_ID = ' + cast(@Company_id as nvarchar(3)) + ' And increme
nt_effective_date <= '''+convert(nvarchar(10),@To_Date,101)+''' and increment_type <> ''transfer'' GROUP BY Emp_ID) t2   
        on t1.Emp_ID = t2.Emp_ID and t1.Increment_ID = t2.Increment_ID) as inc1 on ms.Emp_ID = inc1.emp_id and ms.Cmp_ID = inc1.Cmp_ID  
                            left outer join #v_ad_calc_d as add1 on ec.Emp_ID = add1.emp_id  
                            left outer join #v_ad_calc_E as e on ec.Emp_ID = e.emp_id  
                            left outer join #v_ad_calc_ded as ded1 on ec.Emp_ID = ded1.emp_id  
                            left outer join (select Emp_ID,SUM(case when ReimAmount <>0  then ReimAmount else M_AD_Amount end) as Allow_Amount from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)  where month(for_Date) = month('''+convert(nvarchar(10),@From_Date,101)+''') and year(for_date) = year('''+convert(nvarchar(10),@From_Date,101)+''') and M_AD_Flag = ''I'' and AD_ID in ( select distinct ad_id from t0050_AD_MASTER WITH (NOLOCK)  where (AD_NOT_EFFECT_SALARY = 0 OR (ReimShow = 1 and isnull(reimamount,0)<>0)  A
nd cmp_ID = ' + cast(@Company_id as nvarchar(3)) + ' ) and s_Sal_Tran_Id is null and cmp_ID = ' + cast(@Company_id as nvarchar(3)) + ') group by Emp_ID) as mADi ON ec.Emp_ID = mADi.Emp_id  
                            left outer join #v_Ad_Calc_Arr as mArr on ec.Emp_ID = mArr.Emp_ID  
                            left outer join #v_Ad_Calc_Arr_ntes as mArr_ntes on ec.Emp_ID = mArr_ntes.Emp_ID  
                            left outer join #v_Ad_Name_E_Calc_PartOfCTC as epart on ec.Emp_ID = epart.emp_id    
                            left outer join #v_Ad_Calc_Arr_ded as mArr_ded on ec.Emp_ID = mArr_ded.Emp_ID  
                            left outer join #v_Ad_Calc_Arr_ded_ntes as mArr_ded_ntes on ec.Emp_ID = mArr_ded_ntes.Emp_ID  
                            left outer join #v_Ad_Calc_E_ntes as mAdE_ntes on ec.emp_id = mAdE_ntes.emp_id  
                            left outer join t0040_Bank_master as bank WITH (NOLOCK)  on inc1.cmp_id = bank.cmp_id and inc1.Bank_ID = bank.Bank_ID  
                            left outer join #v_Leave as vl on ec.Emp_ID = vl.emp_ID  
                            left outer join #v_Leave_U as vlu on ec.Emp_ID = vlu.Emp_ID  
                            left outer join T0040_COST_CENTER_MASTER as CCM WITH (NOLOCK)  on ec.Center_ID = CCM.Center_ID  
                            left outer join T0190_MONTHLY_PRESENT_IMPORT tmpia WITH (NOLOCK)  on tmpia.Emp_ID = ec.Emp_ID and tmpia.Month = MONTH('''+convert(nvarchar(10),@To_Date,101)+''') and tmpia.Year = YEAR('''+convert(nvarchar(10),@To_Date,101)+''')
   
                            LEFT OUTER JOIN T0210_Monthly_Salary_Slip_Gradecount MSG WITH (NOLOCK)  on MSG.Sal_tran_id = MS.Sal_Tran_ID     
                            left join T0040_Vertical_Segment VS WITH (NOLOCK)  on ec.vertical_id = VS.vertical_id  
                            left Join T0050_SubVertical SV WITH (NOLOCK)  on ec.subvertical_id = sv.subvertical_id  
                            left Join T0030_CATEGORY_MASTER CMM WITH (NOLOCK)  on ec.cat_id = CMM.cat_id  
                            left Join T0050_SubBranch SB WITH (NOLOCK)  on ec.Subbranch_id = SB.SubBranch_Id  
                            left Join T0040_Business_Segment BS WITH (NOLOCK)  on ec.Segment_id = BS.Segment_id   
                            left Outer JOin  #v_Loan vlo On vlo.emp_Id = ec.emp_Id   
                            INNER JOIN  
        T0095_INCREMENT I_Q ON ec.Emp_ID = I_Q.Emp_ID INNER JOIN   
         (  
         SELECT MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID  
         FROM T0095_INCREMENT I2 WITH (NOLOCK)    
           INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
              FROM T0095_INCREMENT I3 WITH (NOLOCK)  
              WHERE  I3.cmp_ID = ' + cast(@Company_id as nvarchar(3)) + '   
                And I3.Increment_Effective_Date <= '''+convert(nvarchar(10),@To_Date,101)+'''  
                and I3.Increment_Type NOT In (''Transfer'',''Deputation'')  
              GROUP BY I3.Emp_ID  
              ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                    
         GROUP BY I2.Emp_ID  
        ) I2_Q ON I_Q.Emp_ID=I2_Q.Emp_ID AND I_Q.Increment_ID=I2_Q.INCREMENT_ID                                                   
         left outer join (select t1.EMP_ID,t1.CMP_ID,Isnull(SUM(e_Ad_Amount),0) as e_Ad_Amount,Increment_ID from T0100_EMP_EARN_DEDUCTION as t1  WITH (NOLOCK)   
        inner join T0050_AD_MASTER as t3 WITH (NOLOCK)  on t1.ad_id = t3.AD_ID where E_AD_FLAG = ''I'' and t3.AD_NOT_EFFECT_SALARY = 0 and t3.AD_ACTIVE = 1   
        group by t1.EMP_ID,t1.CMP_ID,Increment_ID) as adv1 on I2_Q.Emp_ID = adv1.EMP_ID and ec.Cmp_ID = adv1.CMP_ID and I2_Q.Increment_Id=adv1.Increment_ID  
                                              
                            '  
set @query2 = 'LEFT OUTER JOIN   
         ( SELECT  ms.Emp_ID,SUM(msS.S_Salary_Amount) AS S_Salary_Amount ,S_Eff_Date  
          FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)   
           INNER JOIN  T0200_Monthly_Salary MS WITH (NOLOCK)  ON MS.Emp_ID = MSS.Emp_ID   
          WHERE MONTH(S_Eff_Date) = MONTH('''+convert(nvarchar(10),@To_Date,101)+''') AND YEAR(S_Eff_Date) = YEAR('''+convert(nvarchar(10),@To_Date,101)+''')  
           and MONTH(Month_End_Date) = MONTH('''+convert(nvarchar(10),@To_Date,101)+''') AND YEAR(Month_End_Date) = YEAR('''+convert(nvarchar(10),@To_Date,101)+''')   
           AND Isnull(mss.Effect_On_Salary,0) = 1  
          GROUP BY ms.Emp_ID,S_Eff_Date  
         ) sett on sett.Emp_ID = ec.emp_id   
       inner join #Emp_Cons1 EcN ON EcN.emp_id = EC.Emp_ID  
    Left outer Join   
      (  
       SELECT distinct STUFF((SELECT '','' + Qual_Name   
            FROM #Emp_Cons1 EcN  
            right outer join T0090_EMP_QUALIFICATION_DETAIL Q1 WITH (NOLOCK) ON EcN.Emp_ID = Q1.Emp_ID  
            inner join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on QM.Qual_ID=Q1.Qual_ID  
           WHERE Q1.Emp_ID=Q.Emp_ID AND Q1.Cmp_ID=Q1.Cmp_ID  
           for xml path('''')) , 1,1,''''  
          ) As Qual_Names,Q.Emp_ID, Q.Cmp_ID  
        FROM T0090_EMP_QUALIFICATION_DETAIL Q WITH (NOLOCK)  
      ) Q ON Q.Emp_ID=ec.Emp_ID  
   LEFT OUTER JOIN (Select R.*, E.Alpha_Emp_Code As Manager_Code, E.Emp_Full_Name As Manager_Name From dbo.fn_getReportingManager(' + cast(@Company_id as nvarchar(3)) + ',Null,Getdate()) R Inner Join T0080_Emp_Master E WITH (NOLOCK) on R.R_Emp_Id = E.Emp_
Id) As Qry_Reporting On EC.Emp_Id = Qry_Reporting.Emp_Id  
   ) Qry'  
       --dbo.split(''' + @emp_id1 + ''',''#'') as ds on ec.emp_id = ds.data ) Qry '  --added jimit 26042016  
  
Declare @Query5 as varchar(max)  
set @Query5 = ' ORDER BY ' + Case When @Order_By = 'EMP_CODE' THEN   
        'Case When IsNumeric(Replace(Replace(Emp_Code,''="'',''''),''"'','''')) = 1 then Right(Replicate(''0'',21) + Replace(Replace(Emp_Code,''="'',''''),''"'',''''), 20)  
         When IsNumeric(Replace(Replace(Emp_Code,''="'',''''),''"'','''')) = 0 then Left(Replace(Replace(Emp_Code,''="'',''''),''"'','''') + Replicate('''',21), 20)  
         Else Replace(Replace(Emp_Code,''="'',''''),''"'','''') End '  
      ELSE  
       @Order_By   
      END  
  
        
exec (@query + @query1 + @query2 + @Query5);  
  
  
--select @query + @query1 + @query2 + @Query5  
  
--Added by nilesh patel on 06082016  
if @Summary = ''  
 BEGIN  
    
  IF Object_ID('sumcheck_sum') is not null  
   drop TABLE sumcheck_sum  
   
  Select * into sumcheck_sum From sumcheck  
  
  
  Declare @column nvarchar(max)  
  Declare @column_Sum nvarchar(max)  
    
  SET @column = '';  
  SET @column_Sum = '';  
    
    
  
  SELECT  @column_Sum =   
        CASE WHEN @column_Sum = '' Then  
          (case system_type_id when 108 then   
           'Sum(isnull(' + QUOTENAME(name) + ',0)) as [' + name + ']'  
           else  
           ','''' as '+ name +''   
          end)  
        Else  
          @column_Sum +  
          (case system_type_id when 108 then   
             ', Sum(isnull(' + QUOTENAME(name) + ',0)) as [' + name + ']'  
            else  
             ','''' as '+ name +''   
          end)   
        End,  
     @column =  (CASE WHEN @column = '' Then  --New Logic Added By Ramiz on 06/07/2018  
         (case when system_type_id = 167 or system_type_id = 231 then --varchar & nvarchar  
          'isnull(' + QUOTENAME(name) + ','''') as [' + name + ']'  
         else  
          'isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'  
         end)  
        Else  
         @column +   
         (case when system_type_id = 167 or system_type_id = 231 then   
          ',isnull(' + QUOTENAME(name) + ','''') as [' + name + ']'  
         else  
          ',isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'  
         end)  
        End)    
     --@column = (CASE WHEN @column = '' Then 'isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'  
     --   Else  
     --    @column + ',isnull(' + QUOTENAME(name) + ',0) as [' + name + ']'  
     --   End)  
         
   FROM sys.columns  
   WHERE [object_id] = OBJECT_ID('sumcheck')   
   
     
   Set @column_Sum = Replace(@column_Sum,''''' as Emp_Full_Name','Emp_Full_Name')  
   Set @column_Sum = Replace(@column_Sum,','''' as Sr_No','NULL as Sr_No')  
     
   Update sumcheck_sum   
   SET Emp_Full_Name ='Total',Enroll_No = '0',DESIG_DIS_NO = '0'   
     
   Declare @w_sql varchar(max)  
   SET @w_sql = ''   
  
    
     
   SET @w_sql = 'Select ' + @column + ' From sumcheck Union Select ' +  @column_Sum + ' From sumcheck_sum group by Emp_Full_Name';  
      
   EXEC(@w_sql);  
 End  
--Added by nilesh patel on 06082016  
  
if @Summary <> ''   
begin  
  declare @colValues NVARCHAR(MAX)   
  Declare @String Nvarchar(Max)   
  set @String = N''   
  set @colValues =N''  
    
    
  SELECT   
  @colValues = @colValues +  
  case system_type_id when 108 then   
  ', Sum(isnull(' + QUOTENAME(name) + ',0)) as ' + name + ''  
  else  
  ',0 as ''0'''   
  end   
  FROM sys.columns  
  WHERE [object_id] = OBJECT_ID('sumcheck') and system_type_id = 108  
    AND name NOT IN ('ENROLL_NO')  
      
  
  if @Summary='0' --------for GroupBy Branch---------------------------  
  begin  
   set @String = ' select Branch as Branch_Name ' +  @colValues + ' from sumcheck CM group By branch'  
   exec(@String)  
  end  
  else if @Summary='1' --------for GroupBy Grade---------------------------  
  begin  
   set @String = 'select CM.Grade as Grade ' +  @colValues + ' from sumcheck CM group By Grade'  
   exec(@String)  
    
  --select @String  
  --exec(@String)  
  
  end  
  else if @Summary='2' --------for GroupBy Category_Name---------------------------  
  begin  
   set @String = 'select Cat_Name as Category' +  @colValues + ' from sumcheck CM group By Cat_Name'  
   exec(@String)  
   --select @String  
  --exec(@String)  
  
  end  
  else if @Summary='3' --------for GroupBy Department---------------------------  
  begin  
   set @String = 'select ROW_NUMBER() OVER (ORDER BY Department)As Row_No, Department ' +  @colValues + ' INTO ##DEPT from sumcheck CM group By Department'  
   exec(@String)  
  
   set @String = 'INSERT INTO ##DEPT SELECT COUNT(1)+1, ''Total'' ' + @colValues + ' FROM ##DEPT'  
      exec(@String)  
       
      SET @String = 'SELECT * FROM ##DEPT ORDER BY ROW_NO';  
      exec(@String)  
      
   SET @String = 'DROP TABLE ##DEPT';  
      exec(@String)  
    
  --set @String = ' select CM.Deptartment as Department, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '  
  --set @String = @String + ' from #CTCMast CM group By Deptartment'  
  --select @String  
    
  
  end  
  else if @Summary='4' --------for GroupBy designation---------------------------  
  begin  
  --set @String = ' select CM.Designation as Designation, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) asCTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '  
  
  --set @String = @String + ' from #CTCMast CM group By Designation'  
    
   set @String = 'select ROW_NUMBER() OVER (ORDER BY Desig_dis_No)As Row_No,Designation ' +  @colValues + ' from sumcheck CM group By Designation'  
   exec(@String)  
  
    
  --select @String  
 -- exec(@String)  
  
  end  
  else if @Summary='5' --------for GroupBy TypeName---------------------------  
  begin  
  --set @String = ' select CM.TypeName as Type_Name, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '  
  
  --set @String = @String + ' from #CTCMast CM group By TypeName'  
  set @String = 'select TypeName ' +  @colValues + ' from sumcheck CM group By TypeName'  
  exec(@String)  
  --select @String  
 --exec(@String)  
  
  end  
  else if @Summary='6' -----for division wise-------------------  
  begin  
  --set @String = ' select CM.Division as Division, SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '  
  
  --set @String = @String + ' from #CTCMast CM group By Division'  
    
  set @String = 'select Vertical_name ' +  @colValues + ' from sumcheck CM group By Vertical_Name'  
  exec(@String)  
    
  --select @String  
 -- exec(@String)  
  
  end  
  else if @Summary='7' --------for GroupBy Vertical Wise---------------------------  
  begin  
  --set @String = ' select CM.sub_vertical as Sub_Department,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC)as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '  
  --set @String = @String + ' from #CTCMast CM group By sub_vertical'  
    
  set @String = 'select subvertical_Name ' +  @colValues + ' from sumcheck CM group By subvertical_Name'  
  exec(@String)  
    
  --select @String  
  --exec(@String)  
  
  end  
  else if @Summary='8' --------for GroupBy SuB Branch---------------------------  
  begin  
  --set @String = ' select CM.sub_branch as Sub_Branch,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Other_Allow)as Other_Allowance,SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.arear_amount)as Arear_Amount,SUM(CM.PT_Amount)as PT_Amount,SUM(cm.Loan_Amount)as Loan_Amount,SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(CM.Settl_Salary)as Settlement_Salary,SUM(cm.net_amount)as Net_Amount,SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holidy_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '  
  
  --set @String = @String + ' from #CTCMast CM group By sub_branch'  
    
    
  set @String = 'select Subbranch_Name ' +  @colValues + ' from sumcheck CM group By Subbranch_Name'  
  exec(@String)  
    
  --select @String  
 -- exec(@String)  
  
  end  
  else if @Summary='9' --------for GroupBy SuB Branch---------------------------  
  begin  
    
  set @String = 'select Segment_name ' +  @colValues + ' from sumcheck CM group By Segment_name'  
  exec(@String)  
    
  
  end  
  else if @Summary='10' --------for GroupBy Cost Center---------------------------  
  begin  
  
    
  --Emp_Count added by ronakk 28012022  
  set @String = 'select ROW_NUMBER() OVER (ORDER BY Cost_Center)As Row_No, Cost_Center,Center_Code  
      ,count(Net_Amount_Actual) as Emp_Count' +  @colValues + '   
      INTO ##DEPT1 from sumcheck CM group By Cost_Center,Center_Code'  
  exec(@String)  
    
    
    
  set @String = 'INSERT INTO ##DEPT1 SELECT COUNT(1)+1,''Total'','''',Sum(Emp_Count) ' + @colValues + ' FROM ##DEPT1 '  
  exec(@String)  
  
    
  SET @String = 'SELECT * FROM ##DEPT1 ORDER BY ROW_NO'  
  exec(@String)  
  
  SET @String = 'DROP TABLE ##DEPT1'  
  exec(@String)  
  
  end  
  
  
  
end  
  
  
--drop table v_Ad_Calc  
--drop table v_ad_calc_ntes  
--drop table v_ad_calc_d  
--drop table v_ad_calc_ded  
--drop table v_Ad_Calc_Arr  
--drop table v_Ad_Calc_Arr_ntes  
--drop table v_Ad_Calc_Arr_ded  
--drop table v_Ad_Calc_D_ntes  
--drop table v_Ad_Calc_E_ntes  
--drop table v_ad_calc_E  
--drop table v_ad_name  
--drop table v_Leave  
--drop table v_Leave_U  
  
Return  
   