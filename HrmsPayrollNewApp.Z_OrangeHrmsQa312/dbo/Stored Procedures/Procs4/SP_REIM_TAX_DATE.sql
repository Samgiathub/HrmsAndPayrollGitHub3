

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_REIM_TAX_DATE]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@RC_ID	NUMERIC ,
	@Block_Period  varchar(255)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	
	 declare @item as numeric 
	 Create table #Temp_Table
	 (
		row_ID    int identity,
		B_Year integer,
		Tax  varchar(10) Default '',
		Non_Tax varchar(10) default ''		
	 )	
	 
	 
	insert into #Temp_Table
	Select data,0,0 From dbo.split(@Block_Period,'-')
	
	Declare @First as numeric
	Declare @Last as numeric
	
	Select @First = B_Year from   #Temp_Table where row_ID=1
	Select @Last = B_Year from   #Temp_Table where row_ID=2
	
	delete from #Temp_Table
	
	Declare @Start_date as Datetime
	Declare @End_date as Datetime
	Declare @Taxable_Count as numeric
	Declare @Non_Taxable_Count as numeric
	WHILE (@First <=@Last)
		BEGIN
			
		
		  			 set @Start_date = '01/Jan/'+cast(@First as varchar(4))
					set @End_date ='31/Dec/'+cast(@First as varchar(4))
						
						
					
				select @Taxable_Count =COUNT(*) 
				From T0100_RC_Application A WITH (NOLOCK)
				Where  APP_Date BETWEEN @Start_date and @End_date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=0 AND 
				isnull(A.Tax_Exception,0) = 1 and A.RC_ID=@RC_ID	
				
				
				
				select @Non_Taxable_Count =COUNT(*) 
				From T0100_RC_Application A WITH (NOLOCK)
				Where  APP_Date BETWEEN @Start_date and @End_date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=0 AND 
				isnull(A.Tax_Exception,0) = 0 and A.RC_ID=@RC_ID	
					
					
				
				insert into #Temp_Table values(@First,@Taxable_Count ,
				 @Non_Taxable_Count)
				
				set @Taxable_Count =0
				set @Non_Taxable_Count =0
		
			SET @First = @First + 1
		END
	
	
	
		select * from #Temp_Table

			
	RETURN




