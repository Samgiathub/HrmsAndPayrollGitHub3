



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EH_EMPLOYEE_LOAN_SUMMARY]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(5000)
	,@Loan_ID 	varchar(5000) =0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		 
		declare @Yearly_Loan Table 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric ,
				Loan_Id		numeric,
				Month_1			numeric(12,1) default 0,
				Month_2			numeric(12,1) default 0,
				Month_3			numeric(12,1) default 0,
				Month_4			numeric(12,1) default 0,
				Month_5			numeric(12,1) default 0,
				Month_6			numeric(12,1) default 0,
				Month_7			numeric(12,1) default 0,
				Month_8			numeric(12,1) default 0,
				Month_9			numeric(12,1) default 0,
				Month_10		numeric(12,1) default 0,
				Month_11		numeric(12,1) default 0,
				Month_12		numeric(12,1) default 0,
				Total			numeric(12,1) default 0
			)
			
		IF OBJECT_ID('tempdb..#Loan_MONTH') IS NOT NULL
		BEGIN
			DROP TABLE #Loan_MONTH
		END		
			
		CREATE table #Loan_MONTH
		(
		   Month_1 varchar(200),
		   Month_2   numeric,
		   Emp_ID  numeric,
		   Loan_ID varchar(20),
		    Loan_Issues numeric(18,2) default 0,
		   Loan_Opening numeric(18,2) default 0,
		   Loan_return numeric(18,2)  default 0,		   
		   Loan_Closing numeric(18,2) default 0,		   
		)



		insert into @Yearly_Loan (Cmp_ID,Emp_ID,Loan_ID)
			select @Cmp_ID,emp_ID,Loan_ID From @Emp_Cons ec cross join 
			t0040_Loan_Master lm WITH (NOLOCK) where lm.cmp_ID = @cmp_ID

		
		declare @Loan_Opening as varchar(255)
		declare @Loan_return as varchar(255)
		declare @Loan_Closing as varchar(255)
		declare @Month as numeric	
		declare @Month_name as varchar(3)
		declare @Temp_Date datetime
		declare @Loan_Issues numeric(18,2)
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		while @Temp_Date <=@To_Date 
			Begin
			
			set @Month_name = Upper(DATENAME(MONTH, @Temp_Date))
				if @count = 1 
					begin
																								
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						  set @Loan_Issues =0
						 
						 
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Issue)as  Loan_Issue, 
										Max(Loan_Opening)as  Loan_Opening, 
										min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return	
																					 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID									
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
									
					
					
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,1,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						
					
						
					end
				else if @count = 2 
					begin
					
					 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						
					 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
							@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
								
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,
										Max(Loan_Issue)as  Loan_Issue 	
																							 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,2,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 3
					begin
					
					 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,	
										Max(Loan_Issue)as  Loan_Issue 
																						 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,3,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 4 
					begin
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,	
										Max(Loan_Issue)as  Loan_Issue 
																							 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
									
								
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,4,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						
					end
				else if @count = 5 
					begin
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						
						
						
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,	
										Max(Loan_Issue)as  Loan_Issue 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
						
						
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,5,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 6
					begin
					
		
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						 
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return	,
										Max(Loan_Issue)as  Loan_Issue 
																						 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
						
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,6,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 7 
					begin
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID     
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,	
														Max(Loan_Issue)as  Loan_Issue 									 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
									
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,7,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 8
					begin
					 
					
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						 
						 
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
							@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,	
														Max(Loan_Issue)as  Loan_Issue
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
						
						
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,8,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						
					end
				else if @count = 9 
					begin
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						 
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID     
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,
										Max(Loan_Issue)as  Loan_Issue	
																							 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
									
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,9,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 10 
					begin
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						 
						 select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
							@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID   
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,
										Max(Loan_Issue)as  Loan_Issue						 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
									
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,10,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 11 
					begin
					
						 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
						 
						  select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID  
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,
										Max(Loan_Issue)as  Loan_Issue	
																						 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,11,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 12
					begin
					
					
					 set @Loan_Opening =0 
						 set @Loan_Closing =0
						 set @Loan_return =0
						 set @Loan_Issues =0
				
						
					  select @Loan_Opening = isnull(Loan_Opening,0), 
								@Loan_Closing = isnull(Loan_closing,0),
								@Loan_ID =isnull(L.Loan_ID,0) ,
								@Loan_return= isnull(Loan_return,0),
								@Loan_Issues =isnull(Loan_Issue,0),
								@Emp_ID = L.Emp_ID    
						 from   @Yearly_Loan Y inner join (						 						
								 select emp_ID,Loan_Id,
										Max(Loan_Opening)as  Loan_Opening, 
										Min(Loan_Closing) as Loan_Closing,
										sum(Loan_return) as Loan_return,
										Max(Loan_Issue)as  Loan_Issue		
																							 
									from t0140_Loan_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Loan_ID =@Loan_ID
									group by emp_Id,Loan_ID) L on Y.Emp_Id = L.Emp_ID and Y.Loan_Id = L.Loan_ID
						
						insert into #Loan_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,12,@Emp_ID,@Loan_ID,@Loan_Issues,@Loan_Opening,@Loan_return,@Loan_Closing
						from @Yearly_Loan where Cmp_ID=@Cmp_ID
						
					end

																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End
																							
		
		select * from (
		
		select DISTINCT #Loan_MONTH.Month_1,#Loan_MONTH.Month_2,  #Loan_MONTH.Loan_ID,T0040_Loan_MASTER.Loan_Name,
		#Loan_MONTH.Loan_Issues,#Loan_MONTH.Loan_Opening,#Loan_MONTH.Loan_return,#Loan_MONTH.Loan_Closing 
		from #Loan_MONTH 
		 inner join T0040_Loan_MASTER WITH (NOLOCK) on #Loan_MONTH.Loan_ID= T0040_Loan_MASTER.Loan_ID)q
		 
		 where ISNULL(q.Loan_Issues,0) > 0 or 
		 ISNULL(q.Loan_Opening,0) >0 or
		 ISNULL(q.Loan_return,0) >0 or
		 ISNULL(q.Loan_Closing ,0) >0
		 
		 
		 
		order by q.Loan_ID,q.MONTH_2
		
		
		
		--DECLARE @query AS NVARCHAR(MAX)
		--DECLARE @pivot_cols NVARCHAR(1000);
		--SELECT @pivot_cols =
		--		STUFF((SELECT DISTINCT '],[' + T0040_Loan_Master.Loan_name
		--			   FROM #Loan_MONTH inner join T0040_Loan_Master on #Loan_MONTH.Loan_ID = T0040_Loan_Master.Loan_ID
		--			   ORDER BY '],[' + Loan_name
		--			   FOR XML PATH('')
		--			   ), 1, 2, '') + ']';
               
 

		--	SET @query =
		--	'SELECT * FROM
		--	(
		--		SELECT distinct Month_1,Month_2,T0040_Loan_Master.Loan_name,isnull(Loan_return,0) as Loan_return 
		--		FROM #Loan_MONTH inner join T0040_Loan_Master on #Loan_MONTH.Loan_ID = T0040_Loan_Master.Loan_ID
				
		--	)Salary
		--	PIVOT (SUM(Loan_return) FOR Loan_name
		--	IN ('+@pivot_cols+')) AS pvt'


		--	print @query
		--	EXECUTE (@query)
		
		--select DISTINCT Month_1,Loan_ID,Loan_Opening,Loan_return,Loan_Closing from #Loan_MONTH	
				
	RETURN



