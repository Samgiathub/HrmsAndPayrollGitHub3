


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Salary_Cycle_For_Rpt]
   @Cmp_ID numeric(18)
  ,@Month nvarchar(4)
  ,@Year nvarchar(4)
  
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		CREATE table #Salary_Cycle
		(
			St_En_Date nvarchar(60)
		);
		
		
		-- Declare @Sal_St_Date   Datetime    
		-- Declare @Month_St_Date   Datetime    
		-- Declare @Month_End_Date   Datetime
 
		---- SELECT DISTINCT sal_st_date FROM T0095_INCREMENT where cmp_id = @Cmp_ID and isnull(Sal_St_Date,'') <> '' 
		 
		--declare curSalCycle cursor for                    
		--	SELECT DISTINCT sal_st_date FROM T0095_INCREMENT where cmp_id = @Cmp_ID and isnull(Sal_St_Date,'') <> '' 
		--open curSalCycle                      
		--fetch next from curSalCycle into @Sal_St_Date
			   
		--WHILE @@fetch_status = 0                    
		--	BEGIN
				 
				 
		--		-- select  cast(day(@Sal_St_Date) as VARCHAR(2)) + '-' +  dbo.F_GET_MONTH_NAME(@Month) + '-' + @year
				 
		--		 set @Sal_St_Date = cast((cast(day(@Sal_St_Date) as VARCHAR(2)) + '-' +  dbo.F_GET_MONTH_NAME(@Month) + '-' + @year) as DATETIME)
		--		--set @Sal_St_Date = replace(@Sal_St_Date,month(@Sal_St_Date),@month) 
		--		--set @Sal_St_Date = replace(@Sal_St_Date,year(@Sal_St_Date),@year) 
		--		----set @Sal_St_Date = replace(@Sal_St_Date,month(@Sal_St_Date),@month) 
				 
				 
		--		if day(@Sal_St_Date) =1  
		--			begin    
		--			   set @Month_St_Date  = @Sal_St_Date     
		--			   set @Month_End_Date = dateadd(dd,-1,dateadd(mm,1,@Sal_St_Date))
					   
		--			end     
		--		else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		--			begin   
						
		--			  	set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Sal_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Sal_St_Date) )as varchar(10)) as smalldatetime)    
		--				set @Month_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		--				Set @Month_St_Date = @Sal_St_Date
						
		--			end
						   
		--			insert INTO #Salary_Cycle 
		--			SELECT convert(nvarchar,@Month_St_Date,103) + ' - ' + convert(nvarchar,@Month_End_Date ,103)
					
		--		fetch next from curSalCycle into @Sal_St_Date	
		--	END
		-- CLOSE curSalCycle                    
		-- DEALLOCATE curSalCycle
	 
		--	SELECT DISTINCT ST_EN_DATE FROM #SALARY_CYCLE
			
			drop table #Salary_Cycle
END


