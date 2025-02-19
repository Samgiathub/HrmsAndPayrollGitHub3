
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Statewise_Minimum_Wages_RECORD]      
  @Cmp_ID  numeric,
  @For_Date datetime,
  @To_Date datetime
        
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
     
     --declare @str_For_Date varchar(25)
     --declare @str_To_Date  varchar(25)
     
     SET @To_Date = CONVERT(DATETIME, CONVERT(char(10), @To_Date, 103) + ' 23:59:59', 103);
     
     --set @str_For_Date = REPLACE(Convert(varchar(25),@For_Date,103),' ','/')  
     --set @str_To_Date =  REPLACE(Convert(varchar(25),@To_Date,103),' ','/')
       
   DECLARE @cols AS NVARCHAR(MAX), @query  AS NVARCHAR(MAX), @Col_name as nvarchar(MAX)

	select @cols = STUFF((SELECT distinct ',' + QUOTENAME(Skill_Name) 
                from V0050_Minimum_Wages_Master where Cmp_ID = @Cmp_ID and Eff_Date >= @For_Date and Eff_Date <= @To_Date
        FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)') ,1,1,'')
  
   select @Col_name = STUFF((SELECT distinct ',' + QUOTENAME(Skill_Name) + ' as ' + '''' + cast(Skill_Name as varchar) +'''' 
                from V0050_Minimum_Wages_Master where Cmp_ID = @Cmp_ID  and Eff_Date >= @For_Date and Eff_Date <= @To_Date
        FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)') ,1,1,'')    
            
				
					
		set @query=   ' SELECT * FROM 
					(SELECT ROW_NUMBER() OVER(PARTITION BY State_ID
                                 ORDER BY Eff_Date DESC) AS rk ,State_Name,Convert(varchar(10),Eff_Date,103) As Effective_Date ' + (CASE WHEN @cols IS NULL THEN '' ELSE ',' + @cols END) + '                        
				   FROM
				(
					SELECT MW.State_ID,MW.State_Name,Wages_Value,Skill_Name,Eff_Date,Cmp_ID
					FROM V0050_Minimum_Wages_Master MW  where Eff_Date >= ''' + Cast(@For_Date As Varchar) +''' and Eff_Date <= '''+ Cast(@To_Date As Varchar) +'''
					group by MW.State_ID,MW.State_Name,Wages_Value,Skill_Name,Eff_Date,Cmp_ID
				) ps
				PIVOT
				(
					max(Wages_Value) FOR Skill_Name in(' + ISNULL(@cols,'NO_COL') + ')
				) AS pvt where cmp_ID = ' + Convert(Varchar(10),@Cmp_ID) + ') T Where rk=1'
				
				
  --      if object_id('tempdb..#t2') is not null --exists(select 1 from sys.tables where name ='t2')
		--begin
		--	drop table #t2;
		--end
			print @query	
		execute(@query)		 
		
		
		--return;
		-- if object_id('tempdb..#t2') is not null --exists(select 1 from sys.tables where name ='t2')
		-- begin
		--	select * from #t2 where rk = 1 
		--	--execute(@query);
		-- end
	  
 RETURN      
      
      
 

