



Create PROCEDURE [dbo].[SP_RPT_EMP_LEAVE_CLOSING_ON_DATE_RB010824]
 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Leave_ID		Numeric
	,@Constraint	varchar(MAX)
AS
	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

		Create table #Emp_Leave_Bal 
			(
				Cmp_ID			numeric,
				Emp_ID			numeric,
				For_Date		datetime,
				Leave_Closing_1	numeric(18,2),
				Leave_Closing_2	numeric(18,2),
				Leave_Closing_3	numeric(18,2),
				Leave_Closing_4	numeric(18,2),
				Leave_Closing_5	numeric(18,2),			
				Leave_Name_1	varchar(50),
				Leave_Name_2	varchar(50),
				Leave_Name_3	varchar(50),
				Leave_Name_4	varchar(50),
				Leave_Name_5	varchar(50)			
			) 

		
	if @Branch_ID = 0
		set @Branch_ID = null
	If @Cat_ID = 0
		set @Cat_ID  = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Desig_ID = 0
		set @Desig_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
 	if @Leave_ID = 0
 		set @Leave_ID = null
 		
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Leave_Bal(Cmp_Id,Emp_Id,For_Date)
			select  @Cmp_ID , cast(data  as numeric),@From_Date from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			Insert Into #Emp_Leave_Bal(Cmp_Id,Emp_Id,For_Date)
			select @Cmp_ID , I.Emp_Id ,@From_Date from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
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
		 create table #temp_CompOff
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max),
			Leave_Name		varchar(max),
			Leave_ID		numeric,
			CompOff_String  varchar(max) default null -- Added by Gadriwala 18022015
		)	
		Create table #temp_Leave
		(
			Row_ID numeric(18,0) identity,
			Leave_ID numeric(18,0),
			Leave_Code varchar(25),
			Default_Short_Name varchar(25)
		)
		
		Insert into #temp_Leave
			select  Top 5  isnull(Leave_ID,0),Leave_Code,isnull(Default_Short_Name,'')  from T0040_LEAVE_MASTER WITH (NOLOCK) where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc 
			If @Leave_Id is null
				Begin	
				 declare @Default_Short_Name as varchar(25)
				 Declare @compOff_Leave_ID as numeric(18,0)
				 declare @Leave_Emp_ID numeric(18,0)
				 set @Default_Short_Name = ''
				 
				select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 1	
	
				If @Default_Short_Name = 'COMP'
					begin
								Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
									open curCompOffBalance  
										fetch next from curCompOffBalance into @Leave_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    	
													delete from #temp_CompOff
													
													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
													
													Update #Emp_Leave_Bal 
														set Leave_Closing_1 = isnull(tc.Leave_Closing,0),
														 Leave_Name_1 = tc.Leave_Code
														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
															
													fetch next from curCompOffBalance into @Leave_Emp_ID  
											   end   
									close curCompOffBalance  
									deallocate curCompOffBalance  
					end
				else
					begin
							update #Emp_Leave_Bal 
								set Leave_Closing_1= leave_Bal.Leave_Closing ,
									Leave_Name_1 = LeavE_Code
								From #Emp_Leave_Bal  LB Inner join  
								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
									From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
										( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,Lm.LeavE_Code from T0140_leave_Transaction lt WITH (NOLOCK) inner join 
										T0040_LEave_Master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID inner join
										#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 1
										where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
										lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from									-- Changed By Gadriwala Muslim 01102014 for CompOff
										(select top 1 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
										)*/
										Group by Emp_ID ,lt.LEave_ID,Lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
										)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
					end
					
				 set @Default_Short_Name = ''
				 select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 2
				If @Default_Short_Name = 'COMP'
					begin
						Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
									open curCompOffBalance  
										fetch next from curCompOffBalance into @Leave_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    
												  
													delete from #temp_CompOff
													
													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
												
													Update #Emp_Leave_Bal 
														set Leave_Closing_2 = isnull(tc.Leave_Closing,0)
														, Leave_Name_2 = tc.Leave_Code
														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
													
															
													fetch next from curCompOffBalance into @Leave_Emp_ID  
											   end   
									close curCompOffBalance  
									deallocate curCompOffBalance 
									
					end
				else
					begin
										update #Emp_Leave_Bal 
								set Leave_Closing_2= leave_Bal.Leave_Closing ,
									Leave_Name_2 = LeavE_Code
								From #Emp_Leave_Bal  LB Inner join  
								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
									From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
									( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,LM.LeavE_Code from T0140_leave_Transaction lt WITH (NOLOCK) inner join 
									T0040_LEave_Master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID inner join
									#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 2
									where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
									lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from						-- Changed By Gadriwala Muslim 01102014 for CompOff
									(select top 2 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
									)*/
									Group by Emp_ID ,lt.LEave_ID,Lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
									)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID
					end	
					 
				 set @Default_Short_Name = ''
				select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 3
				If @Default_Short_Name = 'COMP'
					begin
							Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
									open curCompOffBalance  
										fetch next from curCompOffBalance into @Leave_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    	
													delete from #temp_CompOff
													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
													
													Update #Emp_Leave_Bal 
														set Leave_Closing_3 = isnull(tc.Leave_Closing,0),
														Leave_Name_3 = tc.Leave_Code
														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
															
													fetch next from curCompOffBalance into @Leave_Emp_ID  
											   end   
									close curCompOffBalance  
									deallocate curCompOffBalance  
					end
				else
					begin
							update #Emp_Leave_Bal 
								set Leave_Closing_3= leave_Bal.Leave_Closing ,
									Leave_Name_3 = LeavE_Code
								From #Emp_Leave_Bal  LB Inner join  
								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
									From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
									( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,LM.LeavE_Code from T0140_leave_Transaction lt WITH (NOLOCK) inner join 
									T0040_LEave_Master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID inner join
									#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 3
									where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and lt.cmp_ID  =@Cmp_ID /* and lm.Leave_ID in (select top 1 leave_id from							-- Changed By Gadriwala Muslim 01102014 for CompOff
									(select top 3 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
									)*/ Group by Emp_ID ,lt.LEave_ID,Lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID

									)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
					end
	
				set @Default_Short_Name = ''
				select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 4
				If @Default_Short_Name = 'COMP'
					begin
							Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
									open curCompOffBalance  
										fetch next from curCompOffBalance into @Leave_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    	
													delete from #temp_CompOff
													
													--exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
													
													Update #Emp_Leave_Bal 
														set Leave_Closing_4 = isnull(tc.Leave_Closing,0),
														Leave_Name_4 = tc.Leave_Code
														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
															
													fetch next from curCompOffBalance into @Leave_Emp_ID  
											   end   
									close curCompOffBalance  
									deallocate curCompOffBalance  	
					end
				else
					begin
							update #Emp_Leave_Bal 
								set Leave_Closing_4= leave_Bal.Leave_Closing ,
									Leave_Name_4 = LeavE_Code
								From #Emp_Leave_Bal  LB Inner join  
								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
									From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
									( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,lm.LeavE_Code from T0140_leave_Transaction lt WITH (NOLOCK) inner join 
									T0040_LEave_Master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID inner join
								#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 4 
									where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
									lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from								-- Changed By Gadriwala Muslim 01102014 for CompOff
									(select top 4 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
									)*/
									Group by Emp_ID ,lt.LEave_ID,lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID

									)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 	
					end
			set @Default_Short_Name = ''
			select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 5

			If @Default_Short_Name = 'COMP'
					begin
						Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
									open curCompOffBalance  
										fetch next from curCompOffBalance into @Leave_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    	
													delete from #temp_CompOff 
													
													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
	
													 Update #Emp_Leave_Bal 
														set Leave_Closing_5 = isnull(tc.Leave_Closing,0),
														Leave_Name_5 = Leave_Code
														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
														
													fetch next from curCompOffBalance into @Leave_Emp_ID  
											   end   
									close curCompOffBalance  
									deallocate curCompOffBalance  
					end
			Else
					begin
						update #Emp_Leave_Bal 
							set Leave_Closing_5= leave_Bal.Leave_Closing ,
								Leave_Name_5 = LeavE_Code
							From #Emp_Leave_Bal  LB Inner join  
							( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
								From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
								( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,lm.LeavE_Code from T0140_leave_Transaction lt WITH (NOLOCK) inner join 
								T0040_LEave_Master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID  inner join
								#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 5
								where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
								lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (/*select top 1 leave_id from						-- Changed By Gadriwala Muslim 01102014 for CompOff
								(select top 5 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
								*/ select leave_ID from #temp_Leave where Row_ID = 5)*/
								Group by Emp_ID ,lt.LEave_ID,lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID

								)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
					 end
				End
			Else
				Begin
					If exists(select 1 from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_ID and isnull(Default_Short_Name,'') = 'COMP')
						begin
						
								declare @L_Emp_ID numeric(18,0)
								Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
									open curCompOffBalance  
										fetch next from curCompOffBalance into @L_Emp_ID  
											while @@fetch_status = 0  
												begin  
												    	
													delete from #temp_CompOff
													
													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@L_Emp_ID,@Leave_ID,0,0,2	
													
													Update #Emp_Leave_Bal 
														set Leave_Closing_1 = isnull(tc.Leave_Closing,0)
														From #temp_CompOff tc where Emp_ID = @L_Emp_ID 
														
													
															
													fetch next from curCompOffBalance into @L_Emp_ID  
											   end   
									close curCompOffBalance  
									deallocate curCompOffBalance  
						end
					else
						begin
									update #Emp_Leave_Bal 
									set Leave_Closing_1= leave_Bal.Leave_Closing ,
										Leave_Name_1 = LeavE_Code
									From #Emp_Leave_Bal  LB Inner join  
										( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
											( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,LeavE_Code from T0140_leave_Transaction lt WITH (NOLOCK) inner join 
												T0040_LEave_Master lm WITH (NOLOCK) on lt.leavE_ID = lm.leave_ID 
											where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID
											and lt.cmp_ID  =@Cmp_ID and lm.Leave_ID = isnull(@Leave_ID,lm.Leave_ID) and isnull(Default_Short_Name,'') <> 'COMP' -- Changed By Gadriwala Muslim 01102014
											Group by Emp_ID ,lt.LEave_ID,LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
											)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
						end
					
				End			

		
	If @Leave_ID Is null
			Begin
				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_1,'') = '' )
						begin
							
							Update #Emp_Leave_Bal 
							set Leave_Name_1 =q.Leave_Code
							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm WITH (NOLOCK) inner join
																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 1
																	Where Cmp_Id=@Cmp_ID  /*and Leave_ID in (select top 1 leave_id from																																									
																	(select top 1 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/)q  on b.Cmp_ID=q.Cmp_ID
							
																												
						end
				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_2,'') = '' )
						begin
							Update #Emp_Leave_Bal 
							set Leave_Name_2 =q.Leave_Code
							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm WITH (NOLOCK) inner join
																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 2
																	Where Cmp_Id=@Cmp_ID  /*and Leave_ID in (select top 1 leave_id from																																							
																	(select top 2 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/)q on b.Cmp_ID=q.Cmp_ID
						
						end
				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_3,'') = '' )
						begin
							Update #Emp_Leave_Bal 
							set Leave_Name_3 =q.Leave_Code
							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm WITH (NOLOCK) inner join
																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 3
																	Where Cmp_Id=@Cmp_ID/*and Leave_ID in (select top 1 leave_id from																																								
																	(select top 3 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/)q on b.Cmp_ID=q.Cmp_ID
						end
				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_4,'') = '' )
						begin
							Update #Emp_Leave_Bal 
							set Leave_Name_4 =q.Leave_Code
							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm WITH (NOLOCK) inner join
																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 4
																	Where Cmp_Id=@Cmp_ID /* and Leave_ID in (select top 1 leave_id from																																								
																	(select top 4 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID   order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/)q on b.Cmp_ID=q.Cmp_ID
						end
				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_5,'') = '' )
						begin
							Update #Emp_Leave_Bal 
							set Leave_Name_5 =q.Leave_Code
							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm WITH (NOLOCK) inner join
																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 5
																	Where Cmp_Id=@Cmp_ID/* and Leave_ID in (select top 1 leave_id from																																								
																	(select top 5 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID   order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/)q on b.Cmp_ID=q.Cmp_ID
						end
			End
		Else
			Begin
				if exists(select emp_ID from #Emp_Leave_Bal where Leave_Name_1 <> '' )
						begin
						
								Update #Emp_Leave_Bal 
								set Leave_Name_1 =q.Leave_Code
								from #Emp_Leave_Bal B inner join (select cmp_ID,Leave_Code,Leave_Name from T0040_LEave_Master WITH (NOLOCK)					
																		Where Cmp_Id=@Cmp_ID And Leave_Id = ISNULL(@Leave_Id,Leave_ID)  )q on b.Cmp_ID=q.Cmp_ID
						end
			End

		
	select el.* ,EMp_full_Name,BM.Branch_Address,Comp_Name,Emp_code,Alpha_Emp_Code,Emp_First_Name,Grd_NAme,branch_Name,desig_Name,Dept_Name,V.Vertical_Name,type_Name,Street_1 
			,Cmp_Name,Cmp_Address,@To_Date P_To_Date,BM.Branch_ID
	From #Emp_Leave_Bal el Inner join  T0080_Emp_master e WITH (NOLOCK) on el.emp_ID = e.emp_ID inner join 
		(select I.Emp_Id,Branch_Id,Grd_Id,Type_ID,desig_Id,dept_ID,Vertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)I_Q on
			el.emp_ID = i_Q.Emp_ID inner join 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join
				    T0040_Vertical_Segment V WITH (NOLOCK) ON I_Q.Vertical_ID = V.Vertical_ID Inner join
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON e.Cmp_ID =cm.Cmp_ID
	ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500) 
	
	Drop Table #Emp_Leave_Bal	
	
	RETURN 
	
	----commented on 12 Jan 2015-----------


--	 @Cmp_ID		Numeric
--	,@From_Date		Datetime
--	,@To_Date		Datetime
--	,@Branch_ID		Numeric 
--	,@Cat_ID		Numeric
--	,@Grd_ID		Numeric
--	,@Type_ID		Numeric 
--	,@Dept_Id		Numeric
--	,@Desig_Id		Numeric
--	,@Emp_ID		Numeric
--	,@Leave_ID		Numeric
--	,@Constraint	varchar(MAX)
--AS
	
--	set nocount on 

--		Create table #Emp_Leave_Bal 
--			(
--				Cmp_ID			numeric,
--				Emp_ID			numeric,
--				For_Date		datetime,
--				Leave_Closing_1	numeric(18,2),
--				Leave_Closing_2	numeric(18,2),
--				Leave_Closing_3	numeric(18,2),
--				Leave_Closing_4	numeric(18,2),
--				Leave_Closing_5	numeric(18,2),			
--				Leave_Name_1	varchar(50),
--				Leave_Name_2	varchar(50),
--				Leave_Name_3	varchar(50),
--				Leave_Name_4	varchar(50),
--				Leave_Name_5	varchar(50)			
--			) 

		
--	if @Branch_ID = 0
--		set @Branch_ID = null
--	If @Cat_ID = 0
--		set @Cat_ID  = null
--	if @Type_ID = 0
--		set @Type_ID = null
--	if @Dept_ID = 0
--		set @Dept_ID = null
--	if @Grd_ID = 0
--		set @Grd_ID = null
--	if @Desig_ID = 0
--		set @Desig_ID = null
--	if @Emp_ID = 0
--		set @Emp_ID = null
		
-- 	if @Leave_ID = 0
-- 		set @Leave_ID = null
 		
		
--	Declare @Emp_Cons Table
--	(
--		Emp_ID	numeric
--	)
	
--	if @Constraint <> ''
--		begin
--			Insert Into #Emp_Leave_Bal(Cmp_Id,Emp_Id,For_Date)
--			select  @Cmp_ID , cast(data  as numeric),@From_Date from dbo.Split (@Constraint,'#') 
--		end
--	else
--		begin
			
--			Insert Into #Emp_Leave_Bal(Cmp_Id,Emp_Id,For_Date)
--			select @Cmp_ID , I.Emp_Id ,@From_Date from T0095_Increment I inner join 
--					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
--					where Increment_Effective_date <= @To_Date
--					and Cmp_ID = @Cmp_ID
--					group by emp_ID  ) Qry on
--					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
--			Where Cmp_ID = @Cmp_ID 
--			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
--			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
--			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
--			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
--			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
--			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
--			and I.Emp_ID in 
--				( select Emp_Id from
--				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
--				where cmp_ID = @Cmp_ID   and  
--				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
--				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
--				or Left_date is null and @To_Date >= Join_Date)
--				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
			
--		end
--		 create table #temp_CompOff
--		(
--			Leave_opening	decimal(18,2),
--			Leave_Used		decimal(18,2),
--			Leave_Closing	decimal(18,2),
--			Leave_Code		varchar(max),
--			Leave_Name		varchar(max),
--			Leave_ID		numeric
--		)
--		Create table #temp_Leave
--		(
--			Row_ID numeric(18,0) identity,
--			Leave_ID numeric(18,0),
--			Leave_Code varchar(25),
--			Default_Short_Name varchar(25)
--		)
		
--		Insert into #temp_Leave
--			select  Top 5  isnull(Leave_ID,0),Leave_Code,isnull(Default_Short_Name,'')  from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc 
			
		

--			If @Leave_Id is null
--				Begin	
--				 declare @Default_Short_Name as varchar(25)
--				 Declare @compOff_Leave_ID as numeric(18,0)
--				 declare @Leave_Emp_ID numeric(18,0)
--				 set @Default_Short_Name = ''
				 
--				select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 1	
	
--				If @Default_Short_Name = 'COMP'
--					begin
--								Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
--									open curCompOffBalance  
--										fetch next from curCompOffBalance into @Leave_Emp_ID  
--											while @@fetch_status = 0  
--												begin  
												    	
--													delete from #temp_CompOff
													
--													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
													
--													Update #Emp_Leave_Bal 
--														set Leave_Closing_1 = isnull(tc.Leave_Closing,0),
--														 Leave_Name_1 = tc.Leave_Code
--														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
															
--													fetch next from curCompOffBalance into @Leave_Emp_ID  
--											   end   
--									close curCompOffBalance  
--									deallocate curCompOffBalance  
--					end
--				else
--					begin
--							update #Emp_Leave_Bal 
--								set Leave_Closing_1= leave_Bal.Leave_Closing ,
--									Leave_Name_1 = LeavE_Code
--								From #Emp_Leave_Bal  LB Inner join  
--								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
--									From T0140_leave_Transaction LT inner join 
--										( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,Lm.LeavE_Code from T0140_leave_Transaction lt inner join 
--										T0040_LEave_Master lm on lt.leavE_ID = lm.leave_ID inner join
--										#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 1
--										where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
--										lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from									-- Changed By Gadriwala Muslim 01102014 for CompOff
--										(select top 1 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--										)*/
--										Group by Emp_ID ,lt.LEave_ID,Lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
--										)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
--					end
					
--				 set @Default_Short_Name = ''
--				 select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 2
					
--				If @Default_Short_Name = 'COMP'
--					begin
--						Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
--									open curCompOffBalance  
--										fetch next from curCompOffBalance into @Leave_Emp_ID  
--											while @@fetch_status = 0  
--												begin  
												    
												  
--													delete from #temp_CompOff
													
--													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
												
--													Update #Emp_Leave_Bal 
--														set Leave_Closing_2 = isnull(tc.Leave_Closing,0)
--														, Leave_Name_2 = tc.Leave_Code
--														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
													
															
--													fetch next from curCompOffBalance into @Leave_Emp_ID  
--											   end   
--									close curCompOffBalance  
--									deallocate curCompOffBalance 
									
--					end
--				else
--					begin
--										update #Emp_Leave_Bal 
--								set Leave_Closing_2= leave_Bal.Leave_Closing ,
--									Leave_Name_2 = LeavE_Code
--								From #Emp_Leave_Bal  LB Inner join  
--								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
--									From T0140_leave_Transaction LT inner join 
--									( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,LM.LeavE_Code from T0140_leave_Transaction lt inner join 
--									T0040_LEave_Master lm on lt.leavE_ID = lm.leave_ID inner join
--									#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 2
--									where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
--									lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from						-- Changed By Gadriwala Muslim 01102014 for CompOff
--									(select top 2 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--									)*/
--									Group by Emp_ID ,lt.LEave_ID,Lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
--									)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID
--					end	
					 
--				 set @Default_Short_Name = ''
--				select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 3
			
--				If @Default_Short_Name = 'COMP'
--					begin
--							Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
--									open curCompOffBalance  
--										fetch next from curCompOffBalance into @Leave_Emp_ID  
--											while @@fetch_status = 0  
--												begin  
												    	
--													delete from #temp_CompOff
--													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
													
--													Update #Emp_Leave_Bal 
--														set Leave_Closing_3 = isnull(tc.Leave_Closing,0),
--														Leave_Name_3 = tc.Leave_Code
--														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
															
--													fetch next from curCompOffBalance into @Leave_Emp_ID  
--											   end   
--									close curCompOffBalance  
--									deallocate curCompOffBalance  
--					end
--				else
--					begin
--							update #Emp_Leave_Bal 
--								set Leave_Closing_3= leave_Bal.Leave_Closing ,
--									Leave_Name_3 = LeavE_Code
--								From #Emp_Leave_Bal  LB Inner join  
--								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
--									From T0140_leave_Transaction LT inner join 
--									( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,LM.LeavE_Code from T0140_leave_Transaction lt inner join 
--									T0040_LEave_Master lm on lt.leavE_ID = lm.leave_ID inner join
--									#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 3
--									where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and lt.cmp_ID  =@Cmp_ID /* and lm.Leave_ID in (select top 1 leave_id from							-- Changed By Gadriwala Muslim 01102014 for CompOff
--									(select top 3 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--									)*/ Group by Emp_ID ,lt.LEave_ID,Lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID

--									)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
--					end
				
--				set @Default_Short_Name = ''
--				select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 4
--				If @Default_Short_Name = 'COMP'
--					begin
--							Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
--									open curCompOffBalance  
--										fetch next from curCompOffBalance into @Leave_Emp_ID  
--											while @@fetch_status = 0  
--												begin  
												    	
--													delete from #temp_CompOff
													
--													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
													
--													Update #Emp_Leave_Bal 
--														set Leave_Closing_4 = isnull(tc.Leave_Closing,0),
--														Leave_Name_4 = tc.Leave_Code
--														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
															
--													fetch next from curCompOffBalance into @Leave_Emp_ID  
--											   end   
--									close curCompOffBalance  
--									deallocate curCompOffBalance  	
--					end
--				else
--					begin
--							update #Emp_Leave_Bal 
--								set Leave_Closing_4= leave_Bal.Leave_Closing ,
--									Leave_Name_4 = LeavE_Code
--								From #Emp_Leave_Bal  LB Inner join  
--								( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
--									From T0140_leave_Transaction LT inner join 
--									( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,lm.LeavE_Code from T0140_leave_Transaction lt inner join 
--									T0040_LEave_Master lm on lt.leavE_ID = lm.leave_ID inner join
--								#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 4 
--									where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
--									lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from								-- Changed By Gadriwala Muslim 01102014 for CompOff
--									(select top 4 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--									)*/
--									Group by Emp_ID ,lt.LEave_ID,lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID

--									)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 	
--					end
--			set @Default_Short_Name = ''
--			select @Default_Short_Name = ISNULL(Default_Short_Name,''),@compOff_Leave_ID = Leave_ID  from #temp_Leave where Row_ID = 5
--			If @Default_Short_Name = 'COMP'
--					begin
--						Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
--									open curCompOffBalance  
--										fetch next from curCompOffBalance into @Leave_Emp_ID  
--											while @@fetch_status = 0  
--												begin  
												    	
--													delete from #temp_CompOff 
													
--													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
	
--													 Update #Emp_Leave_Bal 
--														set Leave_Closing_5 = isnull(tc.Leave_Closing,0),
--														Leave_Name_5 = Leave_Code
--														From #temp_CompOff tc where Emp_ID = @Leave_Emp_ID 
														
														
--													fetch next from curCompOffBalance into @Leave_Emp_ID  
--											   end   
--									close curCompOffBalance  
--									deallocate curCompOffBalance  
--					end
--			Else
--					begin
--						update #Emp_Leave_Bal 
--							set Leave_Closing_5= leave_Bal.Leave_Closing ,
--								Leave_Name_5 = LeavE_Code
--							From #Emp_Leave_Bal  LB Inner join  
--							( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code 
--								From T0140_leave_Transaction LT inner join 
--								( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,lm.LeavE_Code from T0140_leave_Transaction lt inner join 
--								T0040_LEave_Master lm on lt.leavE_ID = lm.leave_ID  inner join
--								#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 5
--								where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID and
--								lt.cmp_ID  =@Cmp_ID /*and lm.Leave_ID in (/*select top 1 leave_id from						-- Changed By Gadriwala Muslim 01102014 for CompOff
--								(select top 5 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--								*/ select leave_ID from #temp_Leave where Row_ID = 5)*/
--								Group by Emp_ID ,lt.LEave_ID,lm.LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID

--								)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
--					 end
--				End
--			Else
--				Begin
--					If exists(select 1 from T0040_LEAVE_MASTER where Leave_ID = @Leave_ID and isnull(Default_Short_Name,'') = 'COMP')
--						begin
						
--								declare @L_Emp_ID numeric(18,0)
--								Declare curCompOffBalance cursor for select Emp_ID from #Emp_Leave_Bal Order by Emp_ID  
--									open curCompOffBalance  
--										fetch next from curCompOffBalance into @L_Emp_ID  
--											while @@fetch_status = 0  
--												begin  
												    	
--													delete from #temp_CompOff
													
--													exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@L_Emp_ID,@Leave_ID,0,0,2	
													
--													Update #Emp_Leave_Bal 
--														set Leave_Closing_1 = isnull(tc.Leave_Closing,0)
--														From #temp_CompOff tc where Emp_ID = @L_Emp_ID 
														
													
															
--													fetch next from curCompOffBalance into @L_Emp_ID  
--											   end   
--									close curCompOffBalance  
--									deallocate curCompOffBalance  
--						end
--					else
--						begin
--									update #Emp_Leave_Bal 
--									set Leave_Closing_1= leave_Bal.Leave_Closing ,
--										Leave_Name_1 = LeavE_Code
--									From #Emp_Leave_Bal  LB Inner join  
--										( select lt.Emp_Id,lt.LeavE_Id,LeavE_Closing,LeavE_Code From T0140_leave_Transaction LT inner join 
--											( select max(For_Date) For_Date , Emp_ID ,lt.leave_ID,LeavE_Code from T0140_leave_Transaction lt inner join 
--												T0040_LEave_Master lm on lt.leavE_ID = lm.leave_ID 
--											where For_date <= @To_Date and lt.Cmp_ID = @Cmp_ID
--											and lt.cmp_ID  =@Cmp_ID and lm.Leave_ID = isnull(@Leave_ID,lm.Leave_ID) and isnull(Default_Short_Name,'') <> 'COMP' -- Changed By Gadriwala Muslim 01102014
--											Group by Emp_ID ,lt.LEave_ID,LeavE_Code ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
--											)Leave_Bal on LB.Emp_ID = leave_Bal.Emp_ID 
--						end
					
--				End			

		
--	If @Leave_ID Is null
--			Begin
--				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_1,'') = '' )
--						begin
							
--							Update #Emp_Leave_Bal 
--							set Leave_Name_1 =q.Leave_Code
--							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm inner join
--																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 1
--																	Where Cmp_Id=@Cmp_ID  /*and Leave_ID in (select top 1 leave_id from																																									
--																	(select top 1 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--																	)*/)q  on b.Cmp_ID=q.Cmp_ID
							
																												
--						end
--				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_2,'') = '' )
--						begin
--							Update #Emp_Leave_Bal 
--							set Leave_Name_2 =q.Leave_Code
--							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm inner join
--																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 2
--																	Where Cmp_Id=@Cmp_ID  /*and Leave_ID in (select top 1 leave_id from																																							
--																	(select top 2 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--																	)*/)q on b.Cmp_ID=q.Cmp_ID
						
--						end
--				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_3,'') = '' )
--						begin
--							Update #Emp_Leave_Bal 
--							set Leave_Name_3 =q.Leave_Code
--							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm inner join
--																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 3
--																	Where Cmp_Id=@Cmp_ID/*and Leave_ID in (select top 1 leave_id from																																								
--																	(select top 3 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--																	)*/)q on b.Cmp_ID=q.Cmp_ID
--						end
--				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_4,'') = '' )
--						begin
--							Update #Emp_Leave_Bal 
--							set Leave_Name_4 =q.Leave_Code
--							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm inner join
--																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 4
--																	Where Cmp_Id=@Cmp_ID /* and Leave_ID in (select top 1 leave_id from																																								
--																	(select top 4 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID   order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--																	)*/)q on b.Cmp_ID=q.Cmp_ID
--						end
--				if exists(select emp_ID from #Emp_Leave_Bal where isnull(Leave_Name_5,'') = '' )
--						begin
--							Update #Emp_Leave_Bal 
--							set Leave_Name_5 =q.Leave_Code
--							from #Emp_Leave_Bal B inner join (select cmp_ID,lm.Leave_Code,Leave_Name from T0040_LEave_Master lm inner join
--																	#temp_Leave tl on tl.Leave_ID = lm.Leave_ID and Row_ID = 5
--																	Where Cmp_Id=@Cmp_ID/* and Leave_ID in (select top 1 leave_id from																																								
--																	(select top 5 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID   order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
--																	)*/)q on b.Cmp_ID=q.Cmp_ID
--						end
--			End
--		Else
--			Begin
--				if exists(select emp_ID from #Emp_Leave_Bal where Leave_Name_1 <> '' )
--						begin
						
--								Update #Emp_Leave_Bal 
--								set Leave_Name_1 =q.Leave_Code
--								from #Emp_Leave_Bal B inner join (select cmp_ID,Leave_Code,Leave_Name from T0040_LEave_Master					
--																		Where Cmp_Id=@Cmp_ID And Leave_Id = ISNULL(@Leave_Id,Leave_ID)  )q on b.Cmp_ID=q.Cmp_ID
--						end
--			End
				
	
		
--	select el.* ,EMp_full_Name,BM.Branch_Address,Comp_Name,Emp_code,Alpha_Emp_Code,Emp_First_Name,Grd_NAme,branch_Name,desig_Name,Dept_Name,type_Name,Street_1 
--			,Cmp_Name,Cmp_Address,@To_Date P_To_Date,BM.Branch_ID
--	From #Emp_Leave_Bal el Inner join  T0080_Emp_master e on el.emp_ID = e.emp_ID inner join 
--		(select I.Emp_Id,Branch_Id,Grd_Id,Type_ID,desig_Id,dept_ID from T0095_Increment I inner join 
--					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
--					where Increment_Effective_date <= @To_Date
--					and Cmp_ID = @Cmp_ID
--					group by emp_ID  ) Qry on
--					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)I_Q on
--			el.emp_ID = i_Q.Emp_ID inner join 
--					T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID Inner join 
--					T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID LEFT OUTER JOIN
--					T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
--					T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
--					T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join
--					T0010_COMPANY_MASTER CM ON e.Cmp_ID =cm.Cmp_ID
--	ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500) 
	
--	Drop Table #Emp_Leave_Bal	
	
--	RETURN 




