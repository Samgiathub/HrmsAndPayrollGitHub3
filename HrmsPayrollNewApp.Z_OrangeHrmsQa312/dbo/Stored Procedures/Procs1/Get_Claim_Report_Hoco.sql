

CREATE PROCEDURE [dbo].[Get_Claim_Report_Hoco]  
@CMP_ID NUMERIC(18,0),
@Constraint	varchar(max),
@FROM_DATE DATETIME,
@TO_DATE DATETIME 

AS  
  
SET NOCOUNT ON  
BEGIN  
  
Create Table #temp
(
Claim_Date nvarchar(20)
)

--set @FROM_DATE= '2024-03-20 00:00:00';
--set @TO_DATE='2024-03-31 23:59:00.000';
--set @CMP_ID=120


select FORMAT(CLAD.For_Date, 'dd-MM-yyyy')'For_date',CLA.Emp_ID,CLM.Claim_Name as 'Claim_ID',sum(CLAD.Application_Amount)Ammount into #claimdata 
from T0100_CLAIM_APPLICATION CLA 
LEFT JOIN T0110_CLAIM_APPLICATION_DETAIL CLAD ON CLAD.Cmp_ID = CLA.Cmp_ID and  CLA.Claim_App_ID = CLAD.Claim_App_ID 
LEFT JOIN T0040_CLAIM_MASTER CLM ON CLM.Cmp_ID= CLAD.Cmp_ID and CLM.Claim_ID=CLAD.Claim_ID
where CLA.cmp_ID =@CMP_ID  and CLA.Claim_App_Date between @FROM_DATE and @TO_DATE and CLA.Claim_App_Status='A' and CLA.Emp_ID in (select  cast(data  as numeric) from dbo.Split (@Constraint,','))
group by CLAD.For_Date,CLM.Claim_Name,CLA.Emp_ID

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select Emp_Full_Name,Emp_code,Desig_Name,Branch_Name,Cmp_Name,Emp_ID from V0030_Emp_Master_Detail where Cmp_ID=@CMP_ID and  Emp_ID in (select  cast(data  as numeric) from dbo.Split (@Constraint,','))

  select distinct Claim_ID into #Claim_ID from #claimdata 
Declare @str nvarchar(max),
		@str1 nvarchar(max);
select @str = COALESCE( +@str + ',[' + cast(Claim_ID as nvarchar)+']','['+cast(Claim_ID as nvarchar)+']') from #Claim_ID
select @str1 = COALESCE( +@str1 + ',ISNULL([' + cast(Claim_ID as nvarchar)+'],0)'''+cast(Claim_ID as nvarchar)+'''','ISNULL(['+cast(Claim_ID as nvarchar)+'],0)'''+cast(Claim_ID as nvarchar)+'''') from #Claim_ID
declare  @query  AS NVARCHAR(MAX);




 set @query ='SELECT For_date,ISNULL([Emp_ID],0)Emp_ID,'+ @str1 +' FROM (
SELECT
 ISNULL(For_Date,0)For_Date,
 ISNULL(Emp_ID,0)Emp_ID,
 ISNULL(Claim_ID,0)Claim_ID,
 ISNULL(Ammount,0)Ammount 	
 FROM #claimdata
) StudentResults
PIVOT (
  max(Ammount)
  FOR Claim_ID
  IN ('+ @str +')
) AS PivotTable'

execute(@query);

--select * from #FinalData;
  drop table #temp;
drop table #claimdata;
--drop table #FinalData;

 
END  
RETURN  
