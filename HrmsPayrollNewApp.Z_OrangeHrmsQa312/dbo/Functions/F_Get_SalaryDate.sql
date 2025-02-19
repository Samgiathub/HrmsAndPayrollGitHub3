

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[F_Get_SalaryDate]
(	
	@Cmp_Id numeric,
	@Branch_Id numeric,
	@Month numeric,
	@Year numeric
)
RETURNS @SalDate TABLE 
(
	Sal_St_Date datetime,
	Sal_End_Date datetime
)
AS
begin
		DECLARE @MANUAL_SALARY_PERIOD AS NUMERIC(18,0) 
		DECLARE @SAL_ST_DATE AS DATETIME
		DECLARE @SAL_END_DATE AS DATETIME
		   
		DECLARE @MONTH_ST_DATE AS DATETIME
		DECLARE @MONTH_END_DATE AS DATETIME
		   
		DECLARE @OUTOF_DAYS AS INT
		   
		  
		  --set @Month_St_Date  = cast('01' + '-' + (cast(@Month as varchar(10)) + '-' +  cast( @Year as varchar(10)) as smalldatetime)  
		SET @MONTH_ST_DATE  =  CONVERT(DATETIME,CAST( '01' AS VARCHAR(2)) + '/' +(CAST( @MONTH AS VARCHAR(2))) +'/'+ CAST(@YEAR AS VARCHAR(4)) ,103)
		SET @MONTH_END_DATE = DATEADD(D,-1,DATEADD(M,1,@MONTH_ST_DATE))
		  
		  --select @Month_St_Date,@Month_End_Date
		  
	    SELECT @SAL_ST_DATE  =SAL_ST_DATE ,@MANUAL_SALARY_PERIOD=ISNULL(MANUAL_SALARY_PERIOD ,0) 
	    FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID
		AND FOR_DATE = ( SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE FOR_DATE <=@MONTH_END_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID)    


			if isnull(@Sal_St_Date,'') = ''    
				  begin    
					   set @Month_St_Date  = @Month_St_Date     
					   set @Month_End_Date = @Month_End_Date    
					   set @OutOf_Days = @OutOf_Days
				  end     
			 else if day(@Sal_St_Date) =1    
				  begin    
					   --set @Month_St_Date  = @Month_St_Date     
					   --set @Month_End_Date = @Month_End_Date    
					   --set @OutOf_Days = @OutOf_Days  
					   
						set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date )as varchar(10)) as smalldatetime)    
						set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
						set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
				   
						Set @Month_St_Date = @Sal_St_Date
						Set @Month_End_Date = @Sal_End_Date 
				          	         
				  end     
			 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
				  begin    
						 if @manual_salary_period = 0 
					   begin
					        
					        			        
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
							--set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(month(@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date) as varchar(10)) as smalldatetime)    
					        
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
							Set @Month_St_Date = @Sal_St_Date
							Set @Month_End_Date = @Sal_End_Date 

					
					   end 
					 else
						begin
							select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period WITH (NOLOCK) where month= month(@Month_St_Date) and YEAR=year(@Month_St_Date)
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
						   
							Set @Month_St_Date = @Sal_St_Date
							Set @Month_End_Date = @Sal_End_Date 
						end   
			  end
			  
			  Insert INTO @SalDate 
			  SELECT @Month_St_Date,@Month_End_Date
		RETURN 

end


