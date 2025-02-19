



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_CF_Old]  
 @leave_Cf_ID numeric(18,0) output,  
 @Cmp_ID  numeric ,  
 @From_Date Datetime ,  
 @To_Date Datetime ,  
 @For_Date Datetime ,  
 @Branch_ID numeric,  
 @Cat_ID  numeric,  
 @Grd_ID  numeric,  
 @Type_ID numeric,  
 @Dept_ID numeric,  
 @Desig_ID numeric,  
 @Emp_Id  numeric ,  
 @Constraint varchar(5000)='',  
 @P_LeavE_ID numeric, 
 @Is_FNF int = 0,   --Added by Falak on 02-FEB-2011 
 @Inc_HOWO int=0
 
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
   
 if @P_LeavE_ID =0  
  set @P_LeavE_ID = null  
    
 Declare @Emp_Cons Table  
 (  
  Emp_ID numeric  
 )  
   
 if @Constraint <> ''  
  begin  
   Insert Into @Emp_Cons(Emp_ID)  
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
  end  
 else  
  begin  
   Insert Into @Emp_Cons(Emp_ID)  
     
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment  WITH (NOLOCK)
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date   
         
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

    
  Declare @Leave_ID numeric   
  Declare @Leave_Max_Bal numeric   
  Declare @Leave_CF_Type varchar(20)  
  Declare @Leave_PDays numeric(12,1)  
  declare @Leave_get_Against_PDays numeric(12,1)  
  Declare @Leave_Precision numeric(2)   
  Declare @P_Days Numeric(12,1)  
  Declare @Leave_CF_Days numeric(5,2)  
  Declare @Leave_Closing numeric(12,2)  
  Declare @CF_Full_Days Numeric(1,0)  
  Declare @CF_Days numeric(12,2)  
  Declare @C_Paid_Days numeric(5,1)
  Declare @Weekoff_Days numeric(12,1)
  Declare @UnPaid_Days numeric(12,1)
  Declare @Working_Days numeric(12,1)
  --Declare @Leave_CF_ID numeric   
  
      Select @Inc_HOWO = IsNull(Is_Ho_Wo,0) From Dbo.T0040_Leave_Master WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Leave_Id=@P_LeavE_ID            
  
        
  Declare Cur_emp cursor for   
   select I.Emp_Id ,Grd_ID, Branch_ID from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment  WITH (NOLOCK)
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  Inner join  
      @Emp_Cons ec on i.emp_ID =ec.emp_ID   
   Where Cmp_ID = @Cmp_ID   
  Open cur_Emp  
  Fetch next from cur_Emp into @Emp_ID,@Grd_ID,@Branch_ID   
  while @@Fetch_Status =0  
		begin  
		    set @C_Paid_Days = 0			
			set @Weekoff_Days = 0
			set @UnPaid_Days = 0
			set @Working_Days = 0
			set @P_Days = 0
			
		  Declare @Sal_St_Date    Datetime    
		  Declare @Sal_end_Date   Datetime  
		  Declare @Month_St_Date  Datetime    
		  Declare @Month_End_Date Datetime
		  Declare @WO_Days		  numeric
		  Declare @HO_Days		  numeric
		  Declare @Leave_CF_Month numeric
		  Declare @temp_dt		  datetime
		  Declare @Is_Leave_Reset tinyint
		  Declare @Leave_Tran_ID  numeric
		  
		  declare @Flat_Days numeric(10,2)
		  declare @total_days numeric(10,2)
		  declare @join_dt datetime
		  declare @is_leave_CF_Rounding tinyint
		  declare @is_leave_CF_Prorata tinyint
		  
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End    
			
			 if isnull(@Sal_St_Date,'') = ''    
				begin    
				   set @Month_St_Date  = @From_Date     
				   set @Month_End_Date = @To_Date    
				end     
			 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
				begin    
				   set @Month_St_Date  = @From_Date     
				   set @Month_End_Date = @To_Date    
				end     
			 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
				begin    
				   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
				   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
				   set @Month_St_Date = @Sal_St_Date
				   Set @Month_End_Date = @Sal_end_Date   
				End 

		
			--select @P_Days = count(distinct for_Date) From T0150_emp_inout_record  Where Emp_ID =@Emp_ID and For_Date >=@From_Date and For_date <=@To_Date   
			 
			--select @C_Paid_Days = isnull(sum(leave_used),0) from T0140_LEavE_Transaction where Emp_Id =@Emp_ID 
			--	and For_Date >= @From_Date and For_Date <= @To_date and Leave_ID in 
			--		(select Leave_ID from T0040_LEave_Master where Cmp_Id =@Cmp_ID and Leave_Type ='Company Purpose')
			
			
			--If @Inc_HOWO =1
			--begin
			--select @Working_Days = ISNULL (sum(Working_Days ),0),@P_Days = isnull(sum(Sal_Cal_Days),0)  from T0200_MONTHLY_SALARY 
			--	where Emp_ID = @Emp_Id and Month_St_Date >= @From_Date and Month_End_Date <= @To_Date 
			--end	

					
			---start Falak on 02-FEB-2011 for FNF calculation of LEaves
			if @Is_FNF = 1
				begin
					
			  Declare Cur_Lv cursor for   
				   select lm.leavE_Id,Lm.leave_Max_Bal ,Leave_CF_Type,Leave_Pdays,Leave_Get_Against_PDays,Isnull(Leave_Precision,0)  
					,Leave_Days,Leave_CF_month,Leave_Bal_Reset_month,lm.is_leave_CF_Rounding, lm.is_leave_CF_Prorata  
				   from T0040_leave_master lm WITH (NOLOCK) inner join   
					T0050_LEave_Detail ld WITH (NOLOCK) on lm.leavE_ID = ld.leave_ID   
					where lm.cmp_ID =@Cmp_ID and Grd_ID =@Grd_ID and lm.leave_ID = isnull(@P_LeavE_ID,lm.leave_ID)  
					 and (   
					  ( Leave_CF_Type ='Yearly') ---and isnull(Leave_CF_month,0)=Month(@For_Date))  
					   Or   
					   (leave_CF_Type ='Monthly') )  
					 and LeavE_Paid_Unpaid ='P'  
			  Open cur_lv   
			  Fetch next from cur_lv into @Leave_ID,@Leave_Max_Bal ,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@Leave_CF_Month,@Is_Leave_Reset,@is_leave_CF_Rounding, @is_leave_CF_Prorata  
			  While @@Fetch_Status =0  
				begin  
						
						 If @Leave_CF_Type ='Yearly'  
								begin 									
									
									if @Leave_CF_Month is not null
									begin
										
										Set @Month_End_Date = dbo.GET_MONTH_END_DATE (@Leave_CF_Month,YEAR(@Month_End_Date)) -- ADD BY HARDIK 19/01/2012  
										
										--set @temp_dt = cast(cast(@Leave_CF_Month-1 as varchar)+'-01'+'-'+cast(year(@Month_St_Date) as varchar) as datetime)
										--set @Month_End_Date = dateadd(m,-1,@Month_End_Date) 
										--set @Month_End_Date =  cast(cast(day(@Month_End_Date)+1 as varchar(5)) + '-' + cast(datename(mm,@temp_dt) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
									end
									set @Month_St_Date = dateadd(d,1,dateadd(m,-12,@Month_End_Date))
									
									
									SELECT @Leave_Closing  = LEAVE_CLOSING FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN    
									  (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)  
									    WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @Month_End_Date GROUP BY EMP_ID,LEAVE_ID) Q 
									    ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.For_Date = Q.FOR_DATE -- ADD FOR_DATE JOIN BY HARDIK 19/01/2012
									where Lt.LeavE_ID =@LEave_ID  
									
									If @Leave_Closing is null
										set @Leave_Closing = 0
									
									if @Is_Leave_Reset = 1
										begin
											if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date)
												begin
													Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date
													
													Update T0140_LEAVE_TRANSACTION set
													--	Leave_Opening = 0,
														Leave_Closing = 0,
														Leave_Posting = @Leave_Closing
													where Leave_Tran_ID = @Leave_Tran_ID 
												end
											else
												begin 
													Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													
													Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
													values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing)
												end
										end
																		
									select @P_Days=sum(Present_Days), @WO_Days=sum(Weekoff_Days), @HO_Days=sum(Holiday_Days) from T0200_MONTHLY_SALARY WITH (NOLOCK)
									where Emp_Id=@Emp_ID and Month_St_Date >= @Month_St_Date and Month_End_Date <= @Month_End_Date
									
									select @C_Paid_Days = isnull(sum(leave_used),0) from T0140_LEavE_Transaction WITH (NOLOCK) where Emp_Id =@Emp_ID 
										and For_Date >= @Month_St_Date and For_Date <= @Month_End_Date and Leave_ID in 
										(select Leave_ID from T0040_LEave_Master WITH (NOLOCK) where Cmp_Id =@Cmp_ID and Leave_Type ='Company Purpose')
									
									if @P_Days is null
										set @P_Days = 0
									if @WO_Days is null
										set @WO_Days = 0
									if @HO_Days is null
										set @HO_Days = 0
									if @C_Paid_Days is null
										set @C_Paid_Days = 0	
									
									--select @P_Days,@C_Paid_Days,@WO_Days,@HO_Days
																																	
									If @Inc_HOWO = 1
										set @P_Days = @P_Days + @C_Paid_Days + @WO_Days + @HO_Days
									else
										set @P_Days = @P_Days + @C_Paid_Days
									
								   if @Leave_Get_Against_PDays > 0 and @Leave_pDays > 0	
									   begin
											If @is_leave_CF_Rounding = 1   --Added by hasmukh 21012012
												set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays ,0)  
											else 
												set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays ,@Leave_Precision)
									   end 
								   else
										begin 
																						
											Select @Flat_Days = Leave_Days from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID=@Leave_ID and Grd_ID=@Grd_ID and Cmp_ID=@Cmp_ID
											Select @join_dt = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id and Cmp_ID=@Cmp_ID 
											
											if @Flat_Days is null
												set @Flat_Days = 0
											
											if @join_dt > @Month_St_Date and @is_leave_CF_Prorata = 1
												begin
													set @total_days = datediff(d,dateadd(dd,-1,@join_dt),@Month_End_Date)
													
													If @is_leave_CF_Rounding = 1		 --Added by hasmukh 21012012									
														set @Leave_CF_Days = Round(isnull(@total_days,0)*@Flat_Days/365,0)	
													else
														set @Leave_CF_Days = Round(isnull(@total_days,0)*@Flat_Days/365,@Leave_Precision)	
												end
											else
												begin
													set @Leave_CF_Days = @Flat_Days
												end	
											
										end		
										
								   --if (isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) ) > isnull(@Leave_Max_Bal,0)  
									  --set @Leave_CF_Days =  isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) - isnull(@Leave_Max_Bal,0)
									--if (isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) ) > isnull(@Leave_Max_Bal,0) and isnull(@Leave_Max_Bal,0) > 0
									--	set @Leave_CF_Days =  isnull(@Leave_Max_Bal,0) --- isnull(@leave_Closing,0)
									if isnull(@Leave_CF_Days,0) > isnull(@Leave_Max_Bal,0) and isnull(@Leave_Max_Bal,0) > 0
										set @Leave_CF_Days =  isnull(@Leave_Max_Bal,0)
																			
							   end  
						 else   
							  begin  
									SELECT @Leave_Closing = LEAVE_CLOSING FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN    
									  (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION  WITH (NOLOCK) 
									    WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @To_Date GROUP BY EMP_ID,LEAVE_ID) Q 
									    ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.For_Date = Q.FOR_DATE -- ADD FOR_DATE JOIN BY HARDIK 19/01/2012        
									where Lt.LeavE_ID =@LEave_ID  
									
									If @Leave_Closing is null
										set @Leave_Closing = 0
									
									if @Is_Leave_Reset = 1
										begin
											if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date)
												begin
													Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date
													
													Update T0140_LEAVE_TRANSACTION set
														--Leave_Opening = 0,
														Leave_Closing = 0,
														Leave_Posting = @Leave_Closing
													where Leave_Tran_ID = @Leave_Tran_ID 
												end
											else
												begin 
													Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													
													Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
													values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing)
												end
										end
																			
									select @P_Days=sum(Present_Days), @WO_Days=sum(Weekoff_Days), @HO_Days=sum(Holiday_Days) from T0200_MONTHLY_SALARY WITH (NOLOCK)
									where Emp_Id=@Emp_ID and Month_St_Date >= @Month_St_Date and Month_End_Date <= @Month_End_Date
									
									select @C_Paid_Days = isnull(sum(leave_used),0) from T0140_LEavE_Transaction WITH (NOLOCK) where Emp_Id =@Emp_ID 
										and For_Date >= @Month_St_Date and For_Date <= @Month_End_Date and Leave_ID in 
										(select Leave_ID from T0040_LEave_Master WITH (NOLOCK) where Cmp_Id =@Cmp_ID and Leave_Type ='Company Purpose')
								  						  	
						  			if @P_Days is null
										set @P_Days = 0
									if @WO_Days is null
										set @WO_Days = 0
									if @HO_Days is null
										set @HO_Days = 0
									if @C_Paid_Days is null
										set @C_Paid_Days = 0	
															
									--select @P_Days,@C_Paid_Days,@WO_Days,@HO_Days
																																	
									If @Inc_HOWO = 1
										set @P_Days = @P_Days + @C_Paid_Days + @WO_Days + @HO_Days
									else
										set @P_Days = @P_Days + @C_Paid_Days
										
						  		   
						  		   If @Leave_Get_Against_PDays > 0 and @Leave_pDays > 0	
						  				begin
						  					If @is_leave_CF_Rounding = 1 --Added by hasmukh 21012012
						  						set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,0)  
						  					else 
						  						set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,@Leave_Precision)  
											
											--  if ( isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) ) > isnull(@Leave_Max_Bal,0)  
												--set @Leave_CF_Days =  isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) - isnull(@Leave_Max_Bal,0)   										
						  				end						  			
						  		   else
						  			   Begin
						  			   
										   if Exists(select Leave_ID from T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) Where Leave_ID=@Leave_ID and Month(For_Date)=Month(@To_Date) and CF_M_Days <> 0)  
												begin  
													 select @Leave_CF_Days = CF_M_Days from T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) Where Leave_ID=@LEave_ID and Month(For_Date)=Month(@Month_End_Date) order by leave_tran_id
													 
												 end
											else
											
												begin 																								
													Select @Flat_Days = Leave_Days from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID=@Leave_ID and Grd_ID=@Grd_ID and Cmp_ID=@Cmp_ID
													Select @join_dt = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id and Cmp_ID=@Cmp_ID 
													
													if @Flat_Days is null
														set @Flat_Days = 0
													
													set @Leave_CF_Days = @Flat_Days	
													--set @total_days = datediff(d,@join_dt,@Month_End_Date)													
													--set @Leave_CF_Days = Round(isnull(@total_days,0)*@Flat_Days/365,@Leave_Precision)
												end		 												 
											
											
											-- Check this --
											if exists (select Leave_ID From T0050_LEAVE_CF_SETTING WITH (NOLOCK) Where Leave_ID=@Leave_ID )  
												 begin  
													   Select @CF_Days = CF_Days,@CF_Full_Days = CF_Full_Days from T0050_LEAVE_CF_SETTING WITH (NOLOCK) Where Leave_ID =@Leave_ID   
													   and @P_days >= From_Pdays and   @P_days <=To_PDays    
										                
													   If @CF_Full_Days = 0  
														set @Leave_CF_Days = @CF_Days   
												 end  
											-- end --
										end
									
								   if isnull(@Leave_CF_Days,0) > isnull(@Leave_Max_Bal,0) And isnull(@Leave_Max_Bal,0) > 0
												set @Leave_CF_Days = isnull(@Leave_Max_Bal,0)		
								end
								  
									
						   if exists(select Emp_ID From  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) where Leave_ID =@Leave_ID and Emp_ID =@Emp_ID and month(CF_To_Date) =Month (@To_Date) and Year(CF_To_Date) =Year(@To_date))  
								begin  
									 select @Leave_CF_ID =Leave_CF_ID  From  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) where Leave_ID =@Leave_ID and  Emp_ID =@Emp_ID and month(CF_To_Date) =Month (@To_Date) and Year(CF_To_Date) =Year(@To_date)  
						               
									 UPDATE    T0100_LEAVE_CF_DETAIL  
									 SET       CF_For_Date = @For_Date,   
											   CF_From_Date = @From_Date, CF_To_Date = @To_Date, CF_P_Days = @P_Days, CF_Leave_Days = @Leave_CF_Days, CF_Type = @Leave_CF_Type  
									 Where LEAVE_CF_ID = @Leave_CF_ID and Emp_ID =@Emp_ID   
								end  
						   else  
								begin  
									 select @Leave_CF_ID = Isnull(max(Leave_CF_ID),0) + 1  from T0100_LEAVE_CF_DETAIL  WITH (NOLOCK)
						              
									 INSERT INTO T0100_LEAVE_CF_DETAIL  
											(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type)  
									 VALUES     (@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, @For_Date, @From_Date, @To_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type)  
								end  
						 
						 Fetch next from cur_lv into @Leave_ID,@Leave_Max_Bal ,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays ,@Leave_Precision,@Leave_CF_Days,@Leave_CF_Month,@Is_Leave_Reset,@is_leave_CF_Rounding, @is_leave_CF_Prorata    
					end  
			  close cur_lv  
			  deallocate cur_lv  
				   					
				end
			else
				begin
			---- End Falak on 02-FEB-2011					
				 						 
					Declare Cur_Lv cursor for   
						   select lm.leavE_Id,Lm.leave_Max_Bal ,Leave_CF_Type,Leave_Pdays,Leave_Get_Against_PDays,Isnull(Leave_Precision,0)  
							,Leave_Days,Leave_CF_month,Leave_Bal_Reset_month,lm.is_leave_CF_Rounding, lm.is_leave_CF_Prorata  
						   from T0040_leave_master lm WITH (NOLOCK) inner join   
							T0050_LEave_Detail ld WITH (NOLOCK) on lm.leavE_ID = ld.leave_ID   
							where lm.cmp_ID =@Cmp_ID and Grd_ID =@Grd_ID and lm.leave_ID = isnull(@P_LeavE_ID,lm.leave_ID)  
							 and (   
							  --( Leave_CF_Type ='Yearly' and isnull(Leave_CF_month,0)=Month(@For_Date))  
							  ( Leave_CF_Type ='Yearly' and isnull(Leave_CF_month,0)=Month(@To_Date))  -- ADD TO_DATE BY HARDIK 19/01/2012  
							   Or   
							   (leave_CF_Type ='Monthly') )  
							 and LeavE_Paid_Unpaid ='P'  
					  Open cur_lv   
					  Fetch next from cur_lv into @Leave_ID,@Leave_Max_Bal ,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@Leave_CF_Month,@Is_Leave_Reset, @is_leave_CF_Rounding, @is_leave_CF_Prorata  
					  While @@Fetch_Status =0  
						begin  
						
						 If @Leave_CF_Type ='Yearly'  
								begin 									
									
									if @Leave_CF_Month is not null
									begin
										
										Set @Month_End_Date = dbo.GET_MONTH_END_DATE (@Leave_CF_Month,YEAR(@Month_End_Date)) -- ADD BY HARDIK 19/01/2012  
										
										--set @temp_dt = cast(cast(@Leave_CF_Month-1 as varchar)+'-01'+'-'+cast(year(@Month_St_Date) as varchar) as datetime)
										--set @Month_End_Date = dateadd(m,-1,@Month_End_Date) 
										--set @Month_End_Date =  cast(cast(day(@Month_End_Date)+1 as varchar(5)) + '-' + cast(datename(mm,@temp_dt) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
									end
									set @Month_St_Date = dateadd(d,1,dateadd(m,-12,@Month_End_Date))

									
									SELECT @Leave_Closing  = Isnull(LEAVE_CLOSING,0) FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN    
									  (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION  WITH (NOLOCK) 
									    WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @Month_End_Date GROUP BY EMP_ID,LEAVE_ID) Q 
									    ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.For_Date = Q.FOR_DATE -- ADD FOR_DATE JOIN BY HARDIK 19/01/2012         
									where Lt.LeavE_ID =@LEave_ID   

									If @Leave_Closing is null
										set @Leave_Closing = 0
										

									if @Is_Leave_Reset = 1
										begin
											if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date)
												begin
													Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date
													
													Update T0140_LEAVE_TRANSACTION set
														--Leave_Opening = 0,
														Leave_Closing = 0,
														Leave_Posting = @Leave_Closing
													where Leave_Tran_ID = @Leave_Tran_ID 
												end
											else
												begin 
													Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													
													Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
													values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing) -- Add Leave_Opening by Hardik 19/01/2012
												end
										end
																		
									select @P_Days=sum(Present_Days), @WO_Days=sum(Weekoff_Days), @HO_Days=sum(Holiday_Days) from T0200_MONTHLY_SALARY WITH (NOLOCK)
									where Emp_Id=@Emp_ID and Month_St_Date >= @Month_St_Date and Month_End_Date <= @Month_End_Date
									
									select @C_Paid_Days = isnull(sum(leave_used),0) from T0140_LEavE_Transaction WITH (NOLOCK) where Emp_Id =@Emp_ID 
										and For_Date >= @Month_St_Date and For_Date <= @Month_End_Date and Leave_ID in 
										(select Leave_ID from T0040_LEave_Master WITH (NOLOCK) where Cmp_Id =@Cmp_ID and Leave_Type ='Company Purpose')
									
									if @P_Days is null
										set @P_Days = 0
									if @WO_Days is null
										set @WO_Days = 0
									if @HO_Days is null
										set @HO_Days = 0
									if @C_Paid_Days is null
										set @C_Paid_Days = 0	
									
									--select @P_Days,@C_Paid_Days,@WO_Days,@HO_Days
																																	
									If @Inc_HOWO = 1
										set @P_Days = @P_Days + @C_Paid_Days + @WO_Days + @HO_Days
									else
										set @P_Days = @P_Days + @C_Paid_Days
									
								   if @Leave_Get_Against_PDays > 0 and @Leave_pDays > 0	
									   begin
											If @is_leave_CF_Rounding = 1   --Added by hasmukh 21012012
												set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays ,0)  
											else
												set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays ,@Leave_Precision)  
									   end 
								   else
										begin 
																						
											Select @Flat_Days = Leave_Days from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID=@Leave_ID and Grd_ID=@Grd_ID and Cmp_ID=@Cmp_ID
											Select @join_dt = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id and Cmp_ID=@Cmp_ID 
											
											if @Flat_Days is null
												set @Flat_Days = 0
											
											if @join_dt > @Month_St_Date and @is_leave_CF_Prorata = 1
												begin
													set @total_days = datediff(d,dateadd(dd,-1,@join_dt),@Month_End_Date)	
													
													If @is_leave_CF_Rounding = 1		--Added by hasmukh 21012012								
														set @Leave_CF_Days = Round(isnull(@total_days,0)*@Flat_Days/365,0)	
													else 
														set @Leave_CF_Days = Round(isnull(@total_days,0)*@Flat_Days/365,@Leave_Precision)	
														
												end
											else
												begin
													set @Leave_CF_Days = @Flat_Days
												end	
											
										end		
										
								   --if (isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) ) > isnull(@Leave_Max_Bal,0)  
									  --set @Leave_CF_Days =  isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) - isnull(@Leave_Max_Bal,0)
									--if (isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) ) > isnull(@Leave_Max_Bal,0) and isnull(@Leave_Max_Bal,0) > 0
									--	set @Leave_CF_Days =  isnull(@Leave_Max_Bal,0) --- isnull(@leave_Closing,0)
									if isnull(@Leave_CF_Days,0) > isnull(@Leave_Max_Bal,0) and isnull(@Leave_Max_Bal,0) > 0
										set @Leave_CF_Days =  isnull(@Leave_Max_Bal,0)
																			
							   end  
						 else   
							  begin  
									SELECT @Leave_Closing = LEAVE_CLOSING FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN    
									  (SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)  
									    WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @To_Date GROUP BY EMP_ID,LEAVE_ID) Q 
									    ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE       
									where Lt.LeavE_ID =@LEave_ID  
									
									If @Leave_Closing is null
										set @Leave_Closing = 0
									
									if @Is_Leave_Reset = 1
										begin
											if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date)
												begin
													Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date
													
													Update T0140_LEAVE_TRANSACTION set
														--Leave_Opening = 0,
														Leave_Closing = 0,
														Leave_Posting = @Leave_Closing
													where Leave_Tran_ID = @Leave_Tran_ID 
												end
											else
												begin 
													Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													
													Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
													values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing)
												end
										end
																			
									select @P_Days=sum(Present_Days), @WO_Days=sum(Weekoff_Days), @HO_Days=sum(Holiday_Days) from T0200_MONTHLY_SALARY WITH (NOLOCK)
									where Emp_Id=@Emp_ID and Month_St_Date >= @Month_St_Date and Month_End_Date <= @Month_End_Date
									
									select @C_Paid_Days = isnull(sum(leave_used),0) from T0140_LEavE_Transaction WITH (NOLOCK) where Emp_Id =@Emp_ID 
										and For_Date >= @Month_St_Date and For_Date <= @Month_End_Date and Leave_ID in 
										(select Leave_ID from T0040_LEave_Master WITH (NOLOCK) where Cmp_Id =@Cmp_ID and Leave_Type ='Company Purpose')
								  						  	
						  			if @P_Days is null
										set @P_Days = 0
									if @WO_Days is null
										set @WO_Days = 0
									if @HO_Days is null
										set @HO_Days = 0
									if @C_Paid_Days is null
										set @C_Paid_Days = 0	
															
									--select @P_Days,@C_Paid_Days,@WO_Days,@HO_Days
																																	
									If @Inc_HOWO = 1
										set @P_Days = @P_Days + @C_Paid_Days + @WO_Days + @HO_Days
									else
										set @P_Days = @P_Days + @C_Paid_Days
										
						  		   
						  		   If @Leave_Get_Against_PDays > 0 and @Leave_pDays > 0	
						  				begin
						  					If @is_leave_CF_Rounding = 1   --Added by hasmukh 21012012
						  						set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,0)  
						  					else 
						  						set @Leave_CF_Days = Round(@P_Days * isnull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,@Leave_Precision)  
											
											--  if ( isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) ) > isnull(@Leave_Max_Bal,0)  
												--set @Leave_CF_Days =  isnull(@leave_Closing,0) + isnull(@Leave_CF_Days,0) - isnull(@Leave_Max_Bal,0)   										
						  				end						  			
						  		   else
						  			   Begin
						  			   
										   if Exists(select Leave_ID from T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) Where Leave_ID=@Leave_ID and Month(For_Date)=Month(@To_Date) and CF_M_Days <> 0)  
												begin  
													 select @Leave_CF_Days = CF_M_Days from T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) Where Leave_ID=@LEave_ID and Month(For_Date)=Month(@Month_End_Date) order by leave_tran_id
													 
												 end
											else
											
												begin 																								
													Select @Flat_Days = Leave_Days from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID=@Leave_ID and Grd_ID=@Grd_ID and Cmp_ID=@Cmp_ID
													Select @join_dt = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id and Cmp_ID=@Cmp_ID 
													
													if @Flat_Days is null
														set @Flat_Days = 0
													
													set @Leave_CF_Days = @Flat_Days	
													--set @total_days = datediff(d,@join_dt,@Month_End_Date)													
													--set @Leave_CF_Days = Round(isnull(@total_days,0)*@Flat_Days/365,@Leave_Precision)
												end		 												 
											
											
											-- Check this --
											if exists (select Leave_ID From T0050_LEAVE_CF_SETTING WITH (NOLOCK) Where Leave_ID=@Leave_ID )  
												 begin  
													   Select @CF_Days = CF_Days,@CF_Full_Days = CF_Full_Days from T0050_LEAVE_CF_SETTING WITH (NOLOCK) Where Leave_ID =@Leave_ID   
													   and @P_days >= From_Pdays and   @P_days <=To_PDays    
										                
													   If @CF_Full_Days = 0  
														set @Leave_CF_Days = @CF_Days   
												 end  
											-- end --
										end
									
								   if isnull(@Leave_CF_Days,0) > isnull(@Leave_Max_Bal,0) And isnull(@Leave_Max_Bal,0) > 0
												set @Leave_CF_Days = isnull(@Leave_Max_Bal,0)		
								end  
							
								
						   if exists(select Emp_ID From  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) where Leave_ID =@Leave_ID and Emp_ID =@Emp_ID and month(CF_To_Date) =Month (@To_Date) and Year(CF_To_Date) =Year(@To_date))  
								begin  
									 select @Leave_CF_ID =Leave_CF_ID  From  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) where Leave_ID =@Leave_ID and  Emp_ID =@Emp_ID and month(CF_To_Date) =Month (@To_Date) and Year(CF_To_Date) =Year(@To_date)  
						               
									 UPDATE    T0100_LEAVE_CF_DETAIL  
									 SET       CF_For_Date = @For_Date,   
											   CF_From_Date = @From_Date, CF_To_Date = @To_Date, CF_P_Days = @P_Days, CF_Leave_Days = @Leave_CF_Days, CF_Type = @Leave_CF_Type  
									 Where LEAVE_CF_ID = @Leave_CF_ID and Emp_ID =@Emp_ID   
								end  
						   else  
								begin  
									 select @Leave_CF_ID = Isnull(max(Leave_CF_ID),0) + 1  from T0100_LEAVE_CF_DETAIL  WITH (NOLOCK)
						              
									 INSERT INTO T0100_LEAVE_CF_DETAIL  
											(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type)  
									 VALUES     (@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, @For_Date, @From_Date, @To_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type)  
								end  
						 
						 Fetch next from cur_lv into @Leave_ID,@Leave_Max_Bal ,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays ,@Leave_Precision,@Leave_CF_Days,@Leave_CF_Month,@Is_Leave_Reset,@is_leave_CF_Rounding,@is_leave_CF_Prorata    
					end  
			  close cur_lv  
			  deallocate cur_lv  
					
				end
			  
			Fetch next from cur_Emp into @Emp_ID,@Grd_ID,@Branch_ID      
	    end  
   close cur_emp  
   deallocate Cur_Emp   
   
   select Leave_CF_ID,CF_LEAVE_Days,CF_P_DAYS,cf_type,Leave_ID,Emp_ID From t0100_leave_cf_detail WITH (NOLOCK)  
    where cf_from_date =@From_date and cf_to_date = @to_date and Cmp_ID =@Cmp_ID and LeavE_ID = isnull(@P_LeavE_ID,LeavE_ID)
    order by emp_ID asc  
   
 RETURN  
  
  


