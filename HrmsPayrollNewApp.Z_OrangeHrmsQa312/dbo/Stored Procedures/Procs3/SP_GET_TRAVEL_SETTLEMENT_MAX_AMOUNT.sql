
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_TRAVEL_SETTLEMENT_MAX_AMOUNT]
	 @Cmp_ID		Numeric
	,@Expense_type_ID numeric(18,0)
	,@Travel_Approval_ID numeric(18,0)	
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@DDL_ForDate   datetime	
	,@Emp_ID		Numeric(18,0)
	,@LocID			numeric(18,0)=0
	,@is_petrol		tinyint=0
	,@Constraint	varchar(MAX)
	,@City_ID		numeric(18,0)= 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Flag_Grd_Drsig as numeric(18,0)
declare @Chk_City_Cat as numeric(18,0)
declare @ToDate as Datetime
declare @Emp_ID_In as varchar(max)
Declare @Var_Query as varchar(max)
set @Var_Query=''
Create Table #Cons_Data
(
	Emp_ID numeric(18,0)
)

----------------------Frst Table-------------------------------------------------
if (@LocID <> 0)
	Begin
		set @Chk_City_Cat=1;		
		select @Flag_Grd_Drsig=Flag_Grd_Desig--,@Chk_City_Cat=City_Cat_Flag
				 from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
				  where Cmp_ID=@Cmp_ID and Expense_Type_ID =@Expense_type_ID
	End
Else
	Begin
		select @Flag_Grd_Drsig=Flag_Grd_Desig,@Chk_City_Cat=City_Cat_Flag
				 from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
				  where Cmp_ID=@Cmp_ID and Expense_Type_ID =@Expense_type_ID
	End	
		
			  
----------------------Secnd Table-----------------------------------------------------------				  
	
		SELECT @ToDate=max(to_date)
			FROM T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK) 
			where Travel_Approval_ID=@Travel_Approval_ID
		
-------------------------------------------------------------------------------------------	    

if @Constraint<>''
Begin


	INSERT INTO #Cons_Data
	SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,',') 
	
End
select @Emp_ID_In= COALESCE(@Emp_ID_In + ',','') +  '' +cast(Emp_ID as varchar(500)) + ''
from #Cons_Data										
set @Emp_ID_In=@Emp_ID_In + ','+ cast(@Emp_ID as varchar(500)) +''



------------------------Third Table--Get Max Amount----------------------------------------------------


         if @Chk_City_Cat=1
				Begin				
						If @Flag_Grd_Drsig=1
							Begin							
								if @Constraint=''
									Begin 
									if (@LocID =0)
											Begin
												if (@City_ID=0)
													Begin
														select ISNULL(max(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT Ex WITH (NOLOCK) inner join
															
															(select City_Cat_ID from  T0030_CITY_MASTER WITH (NOLOCK) where city_id in											
															(select case when 
																		(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
																		Else 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc )
															End )		 
															) City on City.City_Cat_ID=Ex.City_Cat_ID	
															and Expense_Type_ID = @Expense_type_ID 
															and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
																					where Expense_Type_ID=@Expense_type_ID 
																					and Cmp_ID=@Cmp_ID) 
															and cmp_ID = @cmp_ID 
															and Grd_ID = 
																		( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																			(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																				where Increment_Effective_date <=  @DDL_ForDate 
																				and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																				and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
													End
													Else
														Begin	
															select ISNULL(max(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT Ex WITH (NOLOCK) inner join
															
															(select City_Cat_ID from  T0030_CITY_MASTER WITH (NOLOCK) where city_id =@City_ID
															--(select case when 
															--			(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
															--			>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
															--			(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
															--			>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
															--			Else 
															--			(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
															--			<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc )
															--End )		 
															) City on City.City_Cat_ID=Ex.City_Cat_ID	
															and Expense_Type_ID = @Expense_type_ID 
															and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
																					where Expense_Type_ID=@Expense_type_ID 
																					and Cmp_ID=@Cmp_ID) 
															and cmp_ID = @cmp_ID 
															and Grd_ID = 
																		( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																			(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																				where Increment_Effective_date <=  @DDL_ForDate 
																				and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																				and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
														End
																		
										End
									Else	
										Begin
												if (@City_ID=0)
													Begin
													
														select ISNULL(max(Country_Cat_Amount),0) as Amount 
														from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY Ex WITH (NOLOCK) inner join											
															(select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_ID in
															(select case when 
																(SELECT top 1 count (Loc_ID) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
																(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
																Else 
																(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc )
														End )		 
														) Country on Country.Loc_Cat_ID=Ex.Country_Cat_ID
														and Expense_Type_ID = @Expense_type_ID 
														and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																			where Expense_Type_ID=@Expense_type_ID 
																			and Cmp_ID=@Cmp_ID) 
														and cmp_ID = @Cmp_ID 
														and Grd_ID = 
																	( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																		(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																		where Increment_Effective_date <=  @DDL_ForDate 
																		and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																		and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
													End					
													Else
													
														Begin
																	select ISNULL(max(Country_Cat_Amount),0) as Amount 
																		from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY Ex WITH (NOLOCK) inner join											
																	(select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_ID=@City_ID --ID works as Loc_ID
																--	(select case when 
																--		(SELECT top 1 count (Loc_ID) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
																--		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
																--		(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
																--		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
																--		Else 
																--		(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
																--		<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc )
																--End )		 
																) Country on Country.Loc_Cat_ID=Ex.Country_Cat_ID
																and Expense_Type_ID = @Expense_type_ID 
																and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																					where Expense_Type_ID=@Expense_type_ID 
																					and Cmp_ID=@Cmp_ID) 
																and cmp_ID = @Cmp_ID 
																and Grd_ID = 
																			( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																				(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) 
																				where Increment_Effective_date <=  @DDL_ForDate 
																				and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																				and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
														End					
											End	
																
									End
								Else
									Begin		
									if (@LocID =0)
										Begin
										
											if (@City_ID=0)
												Begin
														set @Var_Query='select isnull(Sum(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT EX WITH (NOLOCK)
														 inner join 
														 ( select Grd_ID From T0095_Increment I WITH (NOLOCK)  
															where	i.Increment_ID =
																	(select top 1 Increment_ID
																		from T0095_INCREMENT i1 WITH (NOLOCK)
																		where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																				and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																		order by Increment_Effective_Date desc, Increment_ID desc)
																		and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																		 INC ON EX.Grd_ID=INC.Grd_ID
														inner join (select City_Cat_ID from  T0030_CITY_MASTER where city_id in WITH (NOLOCK)
																		(select case when 
																		(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
																		Else 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																			<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End ))
																		
																		 CITY ON CITY.City_Cat_ID=EX.City_Cat_ID
													where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK) 
																			where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																			and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
													and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''
												End
												Else
													Begin
														set @Var_Query='select isnull(Sum(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT EX WITH (NOLOCK)
														 inner join 
														 ( select Grd_ID From T0095_Increment I  
															where	i.Increment_ID =
																	(select top 1 Increment_ID
																		from T0095_INCREMENT i1 WITH (NOLOCK)
																		where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																				and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																		order by Increment_Effective_Date desc, Increment_ID desc)
																		and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																		 INC ON EX.Grd_ID=INC.Grd_ID
														inner join (select City_Cat_ID from  T0030_CITY_MASTER WITH (NOLOCK) where city_id ='+ CAST(@City_ID as varchar(500)) +' 
																		)
																		
																		 CITY ON CITY.City_Cat_ID=EX.City_Cat_ID
													where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
																			where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																			and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
													and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''
													End	
													--(select case when 
													--					(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
													--					(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
													--					Else 
													--					(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--						<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End )
										--print @Var_Query
										
										End
										
									Else
										Begin

										if (@City_ID=0)
												Begin
													set @Var_Query='select isnull(Sum(Country_Cat_Amount),0) as Amount 
														from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY EX WITH (NOLOCK)
													 inner join 
													 ( select Grd_ID From T0095_Increment I  
														where	i.Increment_ID =
																(select top 1 Increment_ID
																	from T0095_INCREMENT i1 WITH (NOLOCK)
																	where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																			and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																	order by Increment_Effective_Date desc, Increment_ID desc)
																	and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																	 INC ON EX.Grd_ID=INC.Grd_ID
													inner join (select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_id in 
																	(select case when 
																	(SELECT top 1 count (Loc_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																	>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
																	(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																	>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
																	Else 
																	(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End ))
																	
																	 COUNTRY ON COUNTRY.Loc_Cat_ID=EX.Country_Cat_ID
												where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
												and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																		where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																		and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
												and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''	
											End	
											Else
												Begin
													set @Var_Query='select isnull(Sum(Country_Cat_Amount),0) as Amount 
														from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY EX WITH (NOLOCK)
													 inner join 
													 ( select Grd_ID From T0095_Increment I  
														where	i.Increment_ID =
																(select top 1 Increment_ID
																	from T0095_INCREMENT i1 WITH (NOLOCK)
																	where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																			and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																	order by Increment_Effective_Date desc, Increment_ID desc)
																	and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																	 INC ON EX.Grd_ID=INC.Grd_ID
															inner join (select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_id = '+cast(@City_ID as varchar(500))+'
																	)
																	
																	 COUNTRY ON COUNTRY.Loc_Cat_ID=EX.Country_Cat_ID
												where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
												and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY  WITH (NOLOCK)
																		where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																		and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
												and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''	
												
												--(select case when 
												--					(SELECT top 1 count (Loc_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
												--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
												--					(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
												--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
												--					Else 
												--					(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
												--						<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End )
												
												End
										End	
										
									Exec(@Var_Query)	
									End						
							End
						Else IF @Flag_Grd_Drsig=0
							Begin							
								if @Constraint=''
									Begin
									if (@LocID =0)
											Begin	
											if (@City_ID=0)
												Begin
														select ISNULL(max(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT Ex WITH (NOLOCK) 
															inner join 
															(select City_Cat_ID from  T0030_CITY_MASTER WITH (NOLOCK) where city_id in
															 (select case when 
																		(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= @DDL_ForDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
																		Else 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc ) End )			 
															) City on City.City_Cat_ID=Ex.City_Cat_ID
																	and Expense_Type_ID = @Expense_type_ID 
																	and Effective_Date= 
																				(select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK) 
																					where Expense_Type_ID=@Expense_type_ID 
																					and Cmp_ID=@Cmp_ID) 
																	and cmp_ID = @Cmp_ID 
																	and Desig_ID = 
																			( Select Desig_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																				(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																					where Increment_Effective_date <=  @DDL_ForDate 
																					and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																	and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID)
												End
													Else
														Begin
															select ISNULL(max(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT Ex WITH (NOLOCK)
															inner join 
															(select City_Cat_ID from  T0030_CITY_MASTER WITH (NOLOCK) where city_id =@City_ID
															 --(select case when 
																--		(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
																--		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
																--		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
																--		>= @DDL_ForDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
																--		Else 
																--		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
																--		<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc ) End )			 
															) City on City.City_Cat_ID=Ex.City_Cat_ID
																	and Expense_Type_ID = @Expense_type_ID 
																	and Effective_Date= 
																				(select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
																					where Expense_Type_ID=@Expense_type_ID 
																					and Cmp_ID=@Cmp_ID) 
																	and cmp_ID = @Cmp_ID 
																	and Desig_ID = 
																			( Select Desig_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																				(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) 
																					where Increment_Effective_date <=  @DDL_ForDate 
																					and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																	and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID)
														End					
										End
									Else	
										Begin	
										if (@City_ID=0)
												Begin									
													select ISNULL(max(Country_Cat_Amount),0) as Amount 
													from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY Ex WITH (NOLOCK) inner join											
														(select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_ID in
														(select case when 
															(SELECT top 1 count (Loc_ID) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
															>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
															(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
															>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
															Else 
															(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
															<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc )
													End )		 
													) Country on Country.Loc_Cat_ID=Ex.Country_Cat_ID
													and Expense_Type_ID = @Expense_type_ID 
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																		where Expense_Type_ID=@Expense_type_ID 
																		and Cmp_ID=@Cmp_ID) 
													and cmp_ID = @Cmp_ID 
													and Desig_ID = 
																( Select Desig_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																	(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																		where Increment_Effective_date <=  @DDL_ForDate 
																		and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
														and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID)
												End	
												Else
													Begin
														select ISNULL(max(Country_Cat_Amount),0) as Amount 
													from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY Ex WITH (NOLOCK) inner join											
														(select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_ID =@City_ID
													--	(select case when 
													--		(SELECT top 1 count (Loc_ID) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
													--		(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--		>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
													--		Else 
													--		(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--		<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc )
													--End )		 
													) Country on Country.Loc_Cat_ID=Ex.Country_Cat_ID
													and Expense_Type_ID = @Expense_type_ID 
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																		where Expense_Type_ID=@Expense_type_ID 
																		and Cmp_ID=@Cmp_ID) 
													and cmp_ID = @Cmp_ID 
													and Desig_ID = 
																( Select Desig_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																	(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) 
																		where Increment_Effective_date <=  @DDL_ForDate 
																		and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
														and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID)
													End
										End		
													
									End
								Else
									Begin
									 if (@LocID =0)
											Begin
											if (@City_ID=0)
													Begin
														set @Var_Query='select isnull(Sum(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT EX WITH (NOLOCK)
														 inner join 
														 ( select Desig_ID From T0095_Increment I  
															where	i.Increment_ID =
																	(select top 1 Increment_ID
																		from T0095_INCREMENT i1 WITH (NOLOCK)
																		where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																				and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																		order by Increment_Effective_Date desc, Increment_ID desc)
																		and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																		 INC ON EX.Desig_ID=INC.Desig_ID
														inner join (select City_Cat_ID from  T0030_CITY_MASTER where city_id in WITH (NOLOCK) 
																		(select case when 
																		(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
																		Else 
																		(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																			<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End ))
																		
																		CITY ON CITY.City_Cat_ID=EX.City_Cat_ID
													where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
																			where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																			and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
													and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''
													Exec(@Var_Query)
													End
													Else
														Begin
															set @Var_Query='select isnull(Sum(City_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT EX WITH (NOLOCK)
														 inner join 
														 ( select Desig_ID From T0095_Increment I  WITH (NOLOCK)
															where	i.Increment_ID =
																	(select top 1 Increment_ID
																		from T0095_INCREMENT i1 WITH (NOLOCK)
																		where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																				and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																		order by Increment_Effective_Date desc, Increment_ID desc)
																		and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																		 INC ON EX.Desig_ID=INC.Desig_ID
														inner join (select City_Cat_ID from  T0030_CITY_MASTER WITH (NOLOCK) where city_id ='+ CAST(@City_ID as varchar(500)) +'
																		
																			)
																		
																		CITY ON CITY.City_Cat_ID=EX.City_Cat_ID
													where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
																			where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																			and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
													and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''
													
													--(select case when 
													--					(SELECT top 1 count (city_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
													--					(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
													--					Else 
													--					(SELECT top 1 city_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--						<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End )
														Exec(@Var_Query)
														End
														
										End
										Else
											Begin
											if (@City_ID=0)
												Begin
														set @Var_Query='select isnull(Sum(Country_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY EX WITH (NOLOCK)
														 inner join 
														 ( select Desig_ID From T0095_Increment I WITH (NOLOCK)  
															where	i.Increment_ID =
																	(select top 1 Increment_ID
																		from T0095_INCREMENT i1 WITH (NOLOCK)
																		where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																				and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																		order by Increment_Effective_Date desc, Increment_ID desc)
																		and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																		 INC ON EX.Desig_ID=INC.Desig_ID
														inner join (select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_id in 
																		(select case when 
																		(SELECT top 1 count (Loc_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
																		(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																		>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
																		Else 
																		(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
																			<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End ))
																		
																		CITY ON CITY.Loc_Cat_ID=EX.Country_Cat_ID
													where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																			where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																			and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
													and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''
												End
											Else
												Begin
													set @Var_Query='select isnull(Sum(Country_Cat_Amount),0) as Amount 
															from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY EX WITH (NOLOCK)
														 inner join 
														 ( select Desig_ID From T0095_Increment I WITH (NOLOCK) 
															where	i.Increment_ID =
																	(select top 1 Increment_ID
																		from T0095_INCREMENT i1 WITH (NOLOCK)
																		where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																				and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																		order by Increment_Effective_Date desc, Increment_ID desc)
																		and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																		 INC ON EX.Desig_ID=INC.Desig_ID
														inner join (select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_id ='+cast(@City_ID as varchar(500))+'
																		
																		
																		CITY ON CITY.Loc_Cat_ID=EX.Country_Cat_ID
													where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																			where Expense_Type_ID='+cast(@Expense_type_ID as varchar(200))+'
																			and Cmp_ID='+cast(@Cmp_ID as varchar(200))+') 
													and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''
													
													--(select case when 
													--					(SELECT top 1 count (Loc_id) FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''')>=1 then 
													--					(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--					>= '''+CONVERT(varchar(20),@DDL_ForDate,101) +''' and To_Date <= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) 
													--					Else 
													--					(SELECT top 1 Loc_id FROM T0130_TRAVEL_APPROVAL_DETAIL t where From_Date 
													--						<= '''+CONVERT(varchar(20),@ToDate,101) +''' and To_Date >= '''+CONVERT(varchar(20),@ToDate,101) +''' and Travel_Approval_ID='''+Cast(@Travel_Approval_ID as varchar(200))+''' order by t.From_Date asc ) End )
													--					)
												End
												
											End
										--print @Var_Query
										
									Exec(@Var_Query)	
									End			
							End
			
				End
			Else IF @Chk_City_Cat=0
				Begin
				if Exists(select Emp_ID from #Cons_Data)
				Begin
				declare @varquery as varchar(max)
				
				set @varquery='select isnull(sum(Amount),0)as Amount
					from T0050_EXPENSE_TYPE_MAX_LIMIT TX WITH (NOLOCK)
							inner join
								( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
									(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)
										where Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
										and Cmp_ID = '+cast(@Cmp_ID as varchar(200))+' group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
							and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID in ('+ isnull(@Emp_ID_In,0) +'))
							IA on IA.Grd_ID=TX.Grd_ID
							where Expense_Type_ID = '+cast(@Expense_type_ID as varchar(200))+'
							and cmp_ID = '+cast(@Cmp_ID as varchar(200))+''
					
				--print @varquery		
				Exec(@varquery)	
							
				
				End
				Else
					Begin
					
					select City_Cat_Amount,City_Cat_ID,City_Cat_Flag,Grd_ID,Desig_ID,Expense_Type_ID,isnull(Amount,0)as Amount
					from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)
					where Expense_Type_ID = @Expense_type_ID 
							and cmp_ID = @Cmp_ID 
							and Grd_ID = 
								( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
									(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
										where Increment_Effective_date <=  @DDL_ForDate 
										and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
							and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
					End	
				End				
		Else
			Begin			
			if (@is_petrol=0)
				Begin
					select ISNULL(max(Country_Cat_Amount),0) as Amount 
													from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY Ex WITH (NOLOCK) inner join											
														(select Loc_Cat_ID from  T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_ID in
														(select case when 
															(SELECT top 1 count (Loc_ID) FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
															>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID)>=1 then 
															(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
															>= @DDL_ForDate and To_Date <= @ToDate and Travel_Approval_ID=@Travel_Approval_ID order by t.From_Date asc ) 
															Else 
															(SELECT top 1 Loc_ID FROM T0130_TRAVEL_APPROVAL_DETAIL t WITH (NOLOCK) where From_Date 
															<= @ToDate and To_Date >= @ToDate and Travel_Approval_ID=@Travel_Approval_ID  order by t.From_Date asc )
													End )		 
													) Country on Country.Loc_Cat_ID=Ex.Country_Cat_ID
													and Expense_Type_ID = @Expense_type_ID 
													and Effective_Date= (select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY WITH (NOLOCK)
																		where Expense_Type_ID=@Expense_type_ID 
																		and Cmp_ID=@Cmp_ID) 
													and cmp_ID = @Cmp_ID 
													and Grd_ID = 
																( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																	(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																	where Increment_Effective_date <=  @DDL_ForDate 
																	and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																	and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
				End
					Else
						Begin
						
						declare @Rate as numeric(18,2)
						set @Rate=0
						if (@is_petrol=1)
							Begin
							select @Flag_Grd_Drsig=flag_grd_desig from T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK)
								where Cmp_ID=@Cmp_ID and Expense_Type_ID =@Expense_type_ID
								if (@Flag_Grd_Drsig=0)
									Begin
										if (@Constraint='')
											Begin											
												select Effective_date,Grd_ID,Desig_ID,Expense_Type_ID,ISNULL(KM_Rate,0) as Rate_KM,isnull(Max_KM * KM_Rate,0)as Amount
													from T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK)
													where Expense_Type_ID = @Expense_type_ID 
													and cmp_ID = @Cmp_ID 
													and Effective_date=(select MAX(Effective_date) from T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Expense_Type_ID=@Expense_type_ID)
													and Grd_ID = 
														( Select Grd_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
															(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																where Increment_Effective_date <=  @DDL_ForDate 
																and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
													and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
											End
										Else
											Begin
												set @varquery=''
												set @varquery='select isnull(sum(Max_KM * KM_Rate),0) as Amount,isnull(sum(KM_Rate),0) as Rate_KM
													from T0050_EXPENSE_TYPE_MAX_KM EX WITH (NOLOCK) inner join
													( select Grd_ID From T0095_Increment I WITH (NOLOCK) 
														where	i.Increment_ID =
														(select top 1 Increment_ID
															from T0095_INCREMENT i1 WITH (NOLOCK)
															where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																	and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
															order by Increment_Effective_Date desc, Increment_ID desc)
															and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
															 INC ON EX.Grd_ID=INC.Grd_ID														 
													where Expense_Type_ID = '+CAST (@Expense_type_ID as varchar(200))+'
													and cmp_ID = '+ cast(@Cmp_ID as varchar(200)) +'
													'--group by KM_Rate
													
												Exec(@varquery)	
												
											End	
									End
								Else
									Begin
										if (@Flag_Grd_Drsig=1)
											Begin
											if (@Constraint='')
												Begin
													select @Flag_Grd_Drsig=flag_grd_desig from T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK)
													where Cmp_ID=@Cmp_ID and Expense_Type_ID =@Expense_type_ID													
															select Effective_date,Grd_ID,Desig_ID,Expense_Type_ID,ISNULL(KM_Rate,0) as Rate_KM,isnull(Max_KM * KM_Rate,0)as Amount
																from T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK)
																where Expense_Type_ID = @Expense_type_ID 
																and cmp_ID = @Cmp_ID 
																and Effective_date=(select MAX(Effective_date) from T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Expense_Type_ID=@Expense_type_ID)
																and Desig_ID = 
																	( Select Desig_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN 
																		(select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
																			where Increment_Effective_date <=  @DDL_ForDate 
																			and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on I.Emp_ID = Qry.Emp_ID 
																and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID =  @Emp_ID )
												End		
											Else
												Begin
													set @varquery=''
														set @varquery='select isnull(sum(Max_KM * KM_Rate),0) as Amount,isnull(sum(KM_Rate),0) as Rate_KM
																	from T0050_EXPENSE_TYPE_MAX_KM EX WITH (NOLOCK) inner join
																	( select desig_id From T0095_Increment I WITH (NOLOCK) 
																		where	i.Increment_ID =
																		(select top 1 Increment_ID
																			from T0095_INCREMENT i1 WITH (NOLOCK)
																			where i.Emp_ID=i1.Emp_ID and i.Cmp_id=i1.Cmp_ID 
																					and Increment_Effective_date <=  '''+CONVERT(varchar(20),@DDL_ForDate,101) +'''
																			order by Increment_Effective_Date desc, Increment_ID desc)
																			and I.Emp_ID in( '+ isnull(@Emp_ID_In,0) +') )
																			 INC ON EX.desig_id=INC.desig_id													
																	where Expense_Type_ID = '+ CAST(@Expense_type_ID as varchar(200)) +'
																	and cmp_ID = '+ CAST(@Cmp_ID as varchar(200)) +'
																	'--group by KM_Rate
													Exec(@varquery)																										
												End
												
											End
									End			
							End
					
					End	
			End	
         
         
    	RETURN 


