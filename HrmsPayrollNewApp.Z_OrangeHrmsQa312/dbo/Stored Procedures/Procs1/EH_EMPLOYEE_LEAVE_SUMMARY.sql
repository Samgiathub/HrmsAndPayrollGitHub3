
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EH_EMPLOYEE_LEAVE_SUMMARY]
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
	,@Leave_ID 	varchar(5000) =0
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
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date And Emp_ID = isnull(@Emp_ID ,Emp_ID) 
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
		 
		declare @Yearly_Leave Table 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric ,
				Leave_Id		numeric,
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
			
		 
		IF OBJECT_ID('tempdb..#LEAVE_MONTH') IS NOT NULL
		BEGIN
			DROP TABLE #LEAVE_MONTH
		END	
			
		CREATE TABLE #LEAVE_MONTH
		(
		   Month_1 varchar(200),
		   Month_2   numeric,
		   Emp_ID  numeric,
		   Leave_ID varchar(20),
		   Leave_Opening numeric(18,2) default 0,
		   Leave_Used numeric(18,2)  default 0,		   
		   Leave_Closing numeric(18,2) default 0,
		   Leave_Encash numeric(18,2) default 0,		--Added By Gadriwala 04122013
		   Arrer_Used numeric(18,2) default 0,		    --Added By Gadriwala 04122013
		   Back_Dated_leave numeric(18,2)  default 0  --Mukti(25022017)
		)



		insert into @Yearly_Leave (Cmp_ID,Emp_ID,Leave_ID)
			select @Cmp_ID,emp_ID,Leave_ID From @Emp_Cons ec cross join 
			t0040_Leave_Master lm WITH (NOLOCK) where lm.cmp_ID = @cmp_ID

		declare @Leave_Encash as varchar(255)	--Added By Gadriwala 04122013
		declare @Arrer_Used as varchar(255)		--Added By Gadriwala 04122013
		declare @Leave_Opening as varchar(255)
		declare @Leave_Used as varchar(255)
		declare @Leave_Closing as varchar(255)
		declare @Back_Dated_leave as varchar(255)
		declare @Month as numeric	
		declare @Month_name as varchar(3)
		declare @Temp_Date datetime
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		while @Temp_Date <=@To_Date 
			Begin
			
			set @Month_name = Upper(DATENAME(MONTH, @Temp_Date))
				if @count = 1 
					begin
																								
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)

						 
						 select --@Leave_Opening = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0) - ISNULL(Leave_Encash_Days,0) - ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0), --Added By Gadriwala 04122013
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),--Mukti(27022017)   
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)    
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,											
										--sum(Leave_credit) as Leave_credit,
										sum(Leave_Encash_Days) as Leave_Encash_Days,		--Added By Gadriwala 04122013
										sum(Arrear_Used) as Arrear_Used		,	--Added By Gadriwala 04122013,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015										 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id)									
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

							
						---- Added by Hardik 12/02/2016 As leave balance are coming wrong in Ifedora when Leave Encash and Leave opening on same date, added Opening and Closing Conditions
						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
					
						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,1,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave	--Added By Gadriwala 04122013
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						
					
						
					end
				else if @count = 2 
					begin
					
					 set @Leave_Opening =0 
					 set @Leave_Closing =0
					 set @Leave_Used =0
					 set @Leave_Encash = 0	--Added By Gadriwala 04122013
					 set @Arrer_Used = 0	--Added By Gadriwala 04122013
					 set @Back_Dated_leave = 0 --Mukti(27022017)
					 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
							--	@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),	--Added By Gadriwala 04122013
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),--Mukti(27022017)   
								@Leave_Encash = isnull(Leave_Encash_Days,0),	--Added By Gadriwala 04122013
								@Arrer_Used = isnull(Arrear_Used,0),		    --Added By Gadriwala 04122013
								@Emp_ID = L.Emp_ID,  
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
							--			Max(Leave_Opening)as  Leave_Opening, 
							--			Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
							--			sum(Leave_credit) as Leave_credit,
										sum(Leave_Encash_Days) as Leave_Encash_Days,	--Added By Gadriwala 04122013		
										sum(Arrear_Used) as Arrear_Used	,							--Added By Gadriwala 04122013
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015
																							 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 

						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,2,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave	--Added By Gadriwala 04122013
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 3
					begin
					
					 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),--Mukti(27022017) 
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)  
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,
										sum(Leave_Encash_Days) as Leave_Encash_Days,
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015			
																							 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,3,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 4 
					begin
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),--Mukti(27022017) 
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)    
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,	
										sum(Leave_Encash_Days) as Leave_Encash_Days,
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015																									 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									
								
						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,4,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						
					end
				else if @count = 5 
					begin
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0) - ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),--Mukti(27022017) 
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID ,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)     
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,	
										sum(Leave_Encash_Days) as Leave_Encash_Days,
										sum(Arrear_Used) as Arrear_Used,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015		
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID
						
						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
						
						
						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,5,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 6
					begin
					
					
					 --select emp_ID,leave_Id, for_Date,
						--				Max(Leave_Opening)as  Leave_Opening, 
						--				Min(Leave_Closing) as Leave_Closing,
						--				sum(Leave_Used) as Leave_Used	
																						 
						--			from t0140_leave_transaction 
						--			Where cmp_Id =@Cmp_ID-- and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_Date)
						--			AND Leave_ID = Isnull(@Leave_ID,Leave_Id)
						--			group by emp_Id,leave_ID,for_Date order by For_Date asc
									
									
			
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),--Mukti(27022017) 
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)    
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening,  
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,	
										sum(Leave_Encash_Days) as Leave_Encash_Days,	
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015												 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID
									
						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
						
						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,6,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 7 
					begin
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0	
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								@Leave_Used= isnull(Leave_Used,0),
								@Leave_Encash = isnull(Leave_Encash_Days,0),	
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)         
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,	
										sum(Leave_Encash_Days) as Leave_Encash_Days,													 
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID


						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 

									
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,7,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 8
					begin
					 
					
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						  
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID ,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)     
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,	
										sum(Leave_Encash_Days) as Leave_Encash_Days,													 
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID
						
						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
						
						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,8,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						
					end
				else if @count = 9 
					begin
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),		
								@Emp_ID = L.Emp_ID ,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)     
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,	
										sum(Leave_Encash_Days) as Leave_Encash_Days,
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015													 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 

									
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,9,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 10 
					begin
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
						 select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)        
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used,
										--sum(Leave_credit) as Leave_credit,	
										sum(Leave_Encash_Days) as Leave_Encash_Days,
										sum(Arrear_Used) as Arrear_Used,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015														 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,10,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 11 
					begin
					
						 set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
					     set @Leave_Encash = 0
					     set @Arrer_Used = 0
					     set @Back_Dated_leave = 0 --Mukti(27022017)
						  select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0)- ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),	
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)          
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used	,
										--sum(Leave_credit) as Leave_credit,
										sum(Leave_Encash_Days) as Leave_Encash_Days,
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015												 
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 

						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,11,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						 
					end
				else if @count = 12
					begin					
					     set @Leave_Opening =0 
						 set @Leave_Closing =0
						 set @Leave_Used =0
						 set @Leave_Encash = 0
						 set @Arrer_Used = 0
						 set @Back_Dated_leave = 0 --Mukti(27022017)
					  select --@Leave_Opening = isnull(Leave_Opening,0) + ISNULL(Leave_credit,0), 
								--@Leave_Closing = isnull(Leave_Opening,0) +  ISNULL(Leave_credit,0) - isnull(Leave_Used,0)- ISNULL(Leave_Encash_Days,0)- ISNULL(Arrear_Used,0) - ISNULL(Back_Dated_leave,0),
								@Leave_ID =isnull(L.Leave_ID,0) ,
								--@Leave_Used= isnull(Leave_Used,0)+ IsNull(Back_Dated_leave,0), --added by jimit 01122016
								@Leave_Used= isnull(Leave_Used,0),
								@Leave_Encash = isnull(Leave_Encash_Days,0),
								@Arrer_Used = isnull(Arrear_Used,0),		
								@Emp_ID = L.Emp_ID,
								@Back_Dated_leave= IsNull(Back_Dated_leave,0) --Mukti(27022017)        
						 from   @Yearly_Leave Y inner join (						 						
								 select emp_ID,leave_Id,
										--Max(Leave_Opening)as  Leave_Opening, 
										--Min(Leave_Closing) as Leave_Closing,
										sum(Leave_Used) as Leave_Used	,
										--sum(Leave_credit) as Leave_credit,
										sum(Leave_Encash_Days) as Leave_Encash_Days,
										sum(Arrear_Used) as Arrear_Used	,
										sum(Back_Dated_leave) AS Back_Dated_leave	--Ankit 23012015
									from t0140_leave_transaction WITH (NOLOCK)
									Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
									AND Leave_ID = Isnull(@Leave_ID,Leave_Id) And Emp_ID = Isnull(@Emp_Id,Emp_Id)
									group by emp_Id,leave_ID) L on Y.Emp_Id = L.Emp_ID and Y.Leave_Id = L.Leave_ID

						SELECT DISTINCT @Leave_Opening = Isnull(Qry1.Leave_Op,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select Leave_Opening + ISNULL(LT1.Leave_Credit,0) as Leave_Op, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MIN(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK)  Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 
									

						SELECT DISTINCT @Leave_Closing = Isnull(Qry1.Leave_Cl,Qry2.Leave_Closing) from t0140_leave_transaction LT WITH (NOLOCK)
							Inner Join @Yearly_Leave Y on LT.Emp_ID = Y.Emp_ID 
							Left OUTER JOIN (Select LT1.Leave_Closing as Leave_Cl, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry 
											on LT1.Leave_ID = Qry.Leave_Id And LT1.Emp_ID = Qry.Emp_ID And LT1.For_Date = Qry.For_Date) Qry1 On LT.Emp_ID = Qry1.Emp_ID And Lt.Leave_ID = Qry1.Leave_ID 
							Left OUTER JOIN (Select Leave_Closing as Leave_Closing, LT1.Leave_ID,LT1.Emp_ID  From T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) Inner JOIN
													(Select MAX(FOR_DATE) as For_Date,Emp_Id,Leave_ID From T0140_LEAVE_TRANSACTION WITH (NOLOCK) Where Cmp_ID =@Cmp_id and FOR_DATE <= dbo.GET_MONTH_END_DATE(month(@Temp_Date),  Year(@Temp_datE))
														AND Leave_ID = Isnull(@Leave_ID,Leave_Id) GROUP by Emp_Id,Leave_ID ) Qry11
											on LT1.Leave_ID = Qry11.Leave_Id And LT1.Emp_ID = Qry11.Emp_ID And LT1.For_Date = Qry11.For_Date) Qry2 On LT.Emp_ID = Qry2.Emp_ID And Lt.Leave_ID = Qry2.Leave_ID
						Where LT.cmp_Id =@Cmp_id  AND LT.Leave_ID =Y.Leave_Id 

						
						insert into #LEAVE_MONTH
						SELECT @Month_name + ' ' +cast(Year(@Temp_datE) AS varchar(10)) ,12,@Emp_ID,@Leave_ID,@Leave_Opening,@Leave_Used,@Leave_Closing,@Leave_Encash,@Arrer_Used,@Back_Dated_leave
						from @Yearly_Leave where Cmp_ID=@Cmp_ID
						
					end

																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End
		
		
		
		select * from (
		
		select DISTINCT #LEAVE_MONTH.Month_1,#LEAVE_MONTH.Month_2, 
		 #LEAVE_MONTH.Leave_ID,
		 T0040_LEAVE_MASTER.Leave_Name,
		 #LEAVE_MONTH.Leave_Opening,
		 #LEAVE_MONTH.Leave_Used,
		 #LEAVE_MONTH.Back_Dated_leave ,
		 #LEAVE_MONTH.Arrer_Used, 
		 #LEAVE_MONTH.Leave_Encash, 
		 #LEAVE_MONTH.Leave_Closing
		from #LEAVE_MONTH 
		 inner join T0040_LEAVE_MASTER WITH (NOLOCK) on #LEAVE_MONTH.Leave_ID= T0040_LEAVE_MASTER.Leave_ID)q
		 
		 where isnull(q.Leave_Opening,0) > 0 or isnull(q.Leave_Used,0) >0 or isnull(q.Leave_Closing,0) >0
				
		order by q.Leave_ID,q.MONTH_2
	
		
		--DECLARE @query AS NVARCHAR(MAX)
		--DECLARE @pivot_cols NVARCHAR(1000);
		--SELECT @pivot_cols =
		--		STUFF((SELECT DISTINCT '],[' + T0040_Leave_Master.Leave_name
		--			   FROM #LEAVE_MONTH inner join T0040_Leave_Master on #LEAVE_MONTH.Leave_ID = T0040_Leave_Master.Leave_ID
		--			   ORDER BY '],[' + Leave_name
		--			   FOR XML PATH('')
		--			   ), 1, 2, '') + ']';
               
 

		--	SET @query =
		--	'SELECT * FROM
		--	(
		--		SELECT distinct Month_1,Month_2,T0040_Leave_Master.Leave_name,isnull(Leave_Used,0) as Leave_Used 
		--		FROM #LEAVE_MONTH inner join T0040_Leave_Master on #LEAVE_MONTH.Leave_ID = T0040_Leave_Master.Leave_ID
				
		--	)Salary
		--	PIVOT (SUM(Leave_Used) FOR Leave_name
		--	IN ('+@pivot_cols+')) AS pvt'


		--	print @query
		--	EXECUTE (@query)
		
		--select DISTINCT Month_1,Leave_ID,Leave_Opening,Leave_Used,Leave_Closing from #LEAVE_MONTH	
				
	RETURN



