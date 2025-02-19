



---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_IMPORT_Weekoff_SCHEDULE]
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
			
	Declare @Emp_ID			numeric 
	Declare @Cmp_ID			numeric 
	DEclare @Emp_Code		numeric 
	Declare @Month			numeric 
	Declare @Year			numeric 
	Declare @Day1			varchar(10)
	
	Declare @Day2			varchar(10)
	Declare @Day3			varchar(10)
	DEclare @Day4			varchar(10)
	DEclare @Day5			varchar(10)
	DEclare @Day6			varchar(10)
	Declare @Day7			varchar(10)	
	DEclare @Day8			varchar(10)	
	Declare @Day9			varchar(10)
	Declare @Day10			varchar(10)
	Declare @Day11			varchar(10)	
	Declare @Day12			varchar(10)
	Declare @Day13			varchar(10)
	Declare @Day14			varchar(10)
	Declare @Day15			varchar(10)
	Declare @Day16			varchar(10)
	Declare @Day17			varchar(10)
	Declare @Day18			varchar(10)
	Declare @Day19			varchar(10)
	Declare @Day20			varchar(10)
	Declare @Day21			varchar(10)
	Declare @Day22			varchar(10)
	Declare @Day23			varchar(10)
	Declare @Day24			varchar(10)
	Declare @Day25			varchar(10)
	Declare @Day26			varchar(10)
	Declare @Day27			varchar(10)	
	Declare @Day28			varchar(10)
	Declare @Day29			varchar(10)
	Declare @Day30			varchar(10)
	Declare @Day31			varchar(10)
	Declare @For_Date		Datetime
	Declare @Weekoff_Day	varchar(10)							  			
	Declare @W_Tran_ID		numeric		
	
							  				
	Declare Cur_Shift cursor for
		select Cmp_ID,s.Emp_Id,s.Emp_Code,Month,Year ,Day1,Day2,Day3,Day4,Day5,Day6,Day7,Day8,Day9,Day10
										  ,Day11,Day12,Day13,Day14,Day15,Day16,Day17,Day18,Day19,Day20
										  ,Day21,Day22,Day23,Day24,Day25,Day26,Day27,Day28,Day29,Day30,Day31
				From T9999_IMPORT_SHIFT_SCHEDULE S WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on s.emp_ID=e.emp_ID and
					s.emp_code =e.emp_Code						  
				Where Month > 0 and year >0	
	Open cur_Shift
	fetch next from cur_Shift into @Cmp_Id,@Emp_ID,@Emp_Code,@Month,@Year ,@Day1,@Day2,@Day3,@Day4,@Day5,@Day6,@Day7,@Day8,@Day9,@Day10
										  ,@Day11,@Day12,@Day13,@Day14,@Day15,@Day16,@Day17,@Day18,@Day19,@Day20
										  ,@Day21,@Day22,@Day23,@Day24,@Day25,@Day26,@Day27,@Day28,@Day29,@Day30,@Day31
	While @@fetch_Status=0
		begin
		
				
				Delete from T0100_EMP_SHIFT_DETAIL where emp_ID=@Emp_ID and Month(For_Date) =@month and Year(for_Date)=@Year
			
				if (isnumeric(@Day1) = 1)
				  Begin
				  set  @Day1 ='w'
					
				if  @Day1 ='w'  
					begin
									
										select  @For_Date = dbo.GET_MONTH_ST_DATE(@month,@Year)	
										
										Select Datename(dw,@For_Date)
									
										Select @Weekoff_Day=DATENAME(dw, @For_Date)
										
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										Insert Into T0100_WEEKOFF_ADJ
										(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
										values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					end
			  
			       
				if  @Day2 ='W'  
					begin
									   select  @For_Date = dateadd(d,1,dbo.GET_MONTH_ST_DATE(@month,@Year))	
									   
									   Select datename(dw,	@For_Date)	
									   
									   Select @Weekoff_Day=DATENAME(dw, @For_Date)
									  
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end

				  if @Day3= 1 
			       set @Day3='w'
			  
			       
				if  @Day3 ='W'  
					begin
								    select  @For_Date = dateadd(d,2,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
								    Select @Weekoff_Day=DATENAME(dw, @For_Date)
															
									Select @Weekoff_Day=DATENAME(dw, getdate())
									
									select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
									
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
					
				
								
					end

				  if @Day4= 1 
			       set @Day4='w'
				
				if  @Day4 ='W'  
					begin
					
					                     select  @For_Date = dateadd(d,3,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										 Select @Weekoff_Day=DATENAME(dw, @For_Date)				
									
									     select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
	
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
				  if @Day5= 1 
			       set @Day5='w'	
			       
				if  @Day5 ='W'  
					begin
										 select  @For_Date = dateadd(d,4,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
								    		
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
				if @Day6= 1 
			       set @Day6='w'	
				if  @Day6 ='W'  
					begin
										select  @For_Date = dateadd(d,5,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
															
									
									
									select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
								
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
							
								
							
					end
										
					 if @Day7= 1 
			       set @Day7='w'							
				if  @Day7 ='W'  
					begin
									select  @For_Date = dateadd(d,6,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
										values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
					if @Day8= 1 
			       set @Day8='w'
				if  @Day8 ='W'  
					begin
															
									
									
									select  @For_Date = dateadd(d,7,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
								
			if @Day9= 1 
			       set @Day9='w'
				if  @Day9 ='W'  
					begin
											select  @For_Date = dateadd(d,8,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										
										
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
						
                                         Select * from 	T0100_WEEKOFF_ADJ WITH (NOLOCK)
					end
				
				if @Day10= 1 
			       set @Day10='w'
				if  @Day10 ='W'  
					begin
															
									select  @For_Date = dateadd(d,9,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
				if @Day11= 1 
			       set @Day11='w'
				if  @Day11 ='W'  
					begin
															
								select  @For_Date = dateadd(d,10,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)	
										  
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end

				if @Day12= 1 
			       set @Day12='w'
				if  @Day12 ='W'  
					begin
										select  @For_Date = dateadd(d,11,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
											
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end

				
				if @Day13= 1 
			       set @Day13='w'
				if  @Day13 ='W'  
					begin
											select  @For_Date = dateadd(d,12,dbo.GET_MONTH_ST_DATE(@month,@Year))		
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end

				if @Day14= 1 
			       set @Day14='w'
				if  @Day14 ='W'  
					begin
											select  @For_Date = dateadd(d,13,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end

			  if @Day15= 1 
			       set @Day15='w'
				if  @Day15 ='W'  
					begin
										select  @For_Date = dateadd(d,14,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)				
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
							
					end
					
					if @Day16 =1 
						   set @Day16='w'
				if  @Day16 ='W'  
					begin
										select  @For_Date = dateadd(d,15,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)				
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
							
					end
					
				if @Day17 =1 
						   set @Day17='w'	
				if  @Day17 ='W'  
					begin
															
									
										select  @For_Date = dateadd(d,16,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)	
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
							
					end
					
				if @Day18 =1 
						   set @Day18='w'
				if  @Day18 ='W'  
					begin
										select  @For_Date = dateadd(d,17,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
							
					end
						
				if @Day19 =1 
						   set @Day19='w'																																								
				if  @Day19 ='W'  
					begin
											select  @For_Date = dateadd(d,18,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
							
					end
	
	if @Day20 =1 
						   set @Day20='w'
					if  @Day20 ='W'  
					begin
															
										select  @For_Date = dateadd(d,19,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
										  
									select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
									
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
						
					 Select * from 	T0100_WEEKOFF_ADJ WITH (NOLOCK)	
							
					end
	
			if @Day21 =1 
						   set @Day21='w'
					if  @Day21 ='W'  
					begin
															
									select  @For_Date = dateadd(d,20,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
							
					end
	
					if @Day22 =1 
						   set @Day22='w'
					if  @Day22 ='W'  
					begin
									select  @For_Date = dateadd(d,21,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)					
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
				
				if @Day23 =1 
						   set @Day23='w'
				if  @Day23 ='W'  
					begin
															
									
									select  @For_Date = dateadd(d,22,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)	
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
								Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
	
			if @Day24 =1 
						   set @Day24='w'
				if  @Day24 ='W'  
					begin
											select  @For_Date = dateadd(d,23,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)				
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
											
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
	
	if @Day25 =1 
						   set @Day25='w'
						if  @Day25 ='W'  
					begin
											select  @For_Date = dateadd(d,24,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)				
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
								Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
	
	
	 if @Day26 =1 
						   set @Day26='w'
						if  @Day26 ='W'  
					begin
												select  @For_Date = dateadd(d,25,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)	
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
			 if @Day27 =1 
						   set @Day27='w'
			
				if  @Day27 ='W'  
					begin
															
										select  @For_Date = dateadd(d,26,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
											
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end

				
				if @Day28 =1 
						   set @Day28='w'
				if  @Day28 ='W'  
					begin
												
										select  @For_Date = dateadd(d,27,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										Select @Weekoff_Day=DATENAME(dw, @For_Date)
										  
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
									
									   
										
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
					if @Day29 =1 
						   set @Day29='w'
					if  @Day29 ='W'  
					begin
												select  @For_Date = dateadd(d,28,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)			
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
											
										
								Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
				if @Day30 =1 
						   set @Day30='w'
					if  @Day30 ='W'  
					begin
												select  @For_Date = dateadd(d,29,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)		
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
										
										
								Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
					values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
					if @Day31=1 
						   set @Day31='w'
						if  @Day31 ='W'  
					begin
											select  @For_Date = dateadd(d,30,dbo.GET_MONTH_ST_DATE(@month,@Year))			
									   
										  Select @Weekoff_Day=DATENAME(dw, @For_Date)
									
										select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1 from T0100_Weekoff_adj WITH (NOLOCK)
											
										
										
									Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)
									values(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
								
							
					end
					
					
				
				Fetch next from cur_Shift into @Cmp_Id,@Emp_ID,@Emp_Code,@Month,@Year ,@Day1,@Day2,@Day3,@Day4,@Day5,@Day6,@Day7,@Day8,@Day9,@Day10
										  ,@Day11,@Day12,@Day13,@Day14,@Day15,@Day16,@Day17,@Day18,@Day19,@Day20
										  ,@Day21,@Day22,@Day23,@Day24,@Day25,@Day26,@Day27,@Day28,@Day29,@Day30,@Day31			
				
		end
	close cur_shift
	deallocate cur_Shift
	
		

	RETURN





