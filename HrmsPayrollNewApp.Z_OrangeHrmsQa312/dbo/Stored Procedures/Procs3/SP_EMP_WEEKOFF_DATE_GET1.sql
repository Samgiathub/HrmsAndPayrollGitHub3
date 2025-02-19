
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_EMP_WEEKOFF_DATE_GET1]
 @Emp_Id 		numeric	
,@Cmp_ID 		numeric
,@From_Date 		Datetime
,@To_Date 		Datetime
,@Join_Date		Datetime = null
,@Left_Date		Datetime = null
,@Is_Cancel_Weekoff 	NUMERIC(1,0)
,@strHoliday_Date 	varchar(max)
,@varWeekOff_Date 	varchar(max)= null output 
,@numWeekOff 		numeric(5,1) output
,@Cancel_WeekOff 	numeric(5,1) output 
,@Use_Table		tinyint =0
,@constraint   varchar(5000)   

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @dtAdjDate as datetime
	set @Cancel_WeekOff = 0
	
	Declare @TempFor_Date 	DateTime
	Declare @WeekOff 	Varchar(100)
	Declare @Effe_weekoff 	Varchar(100)
	Declare @Temp_weekoff 	Varchar(100)
	Declare @Effe_Date 	Datetime
	Declare @Weekoff_Day_Value varchar(100)
	Declare @Eff_Weekoff_Day_Value varchar(100)
	Declare @Weekoff_Value	numeric(3,1)
	Declare @Var_All_H_Date	varchar(max)
	Declare @Pre_Date_WeekOff datetime 
	Declare @Next_Date_WeekOff	Datetime 
	Declare @Alt_W_Name			Varchar(100)
	Declare @Alt_W_Full_Day_cont	varchar(50)
	Declare @Alt_W_Half_Day_cont	varchar(50)
	Declare @varCount				varchar(3)
	Declare @IS_P_Comp			tinyint
		
	Set @Effe_weekoff = ''
	set @numWeekOff = 0								
	set @varWeekOff_Date = ''
	set @Weekoff_Day_Value =''
	set @Eff_Weekoff_Day_Value =''
	
	Declare @T_Weekoff Table 
	 (
		Weekoff_Data	varchar(max) 
	 )
	 
	 Declare @T_W_Count	 Table
		( 
			W_NAme		varchar(20),
			W_Count		int default 0
		 )
	
	insert into @T_W_Count 	select 'Sunday' ,0
	insert into @T_W_Count 	select 'Monday' ,0
	insert into @T_W_Count 	select 'Tuesday' ,0
	insert into @T_W_Count 	select 'Wednesday' ,0
	insert into @T_W_Count 	select 'Thursday' ,0
	insert into @T_W_Count 	select 'Friday' ,0
	insert into @T_W_Count 	select 'Saturday' ,0
	
	
	
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
     ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)   
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date     
           
   Where Cmp_ID = @Cmp_ID     
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)     
  end    
	
		
	
	If isnull(@join_Date,'') = ''
		Begin
			exec SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output
		End

	If isnull(@Left_Date,'') <> '' 
		begin
			If @Left_Date < @Join_Date  
				set @Left_Date = null	
		end
	
  	if @Join_Date > @From_Date
		set @From_Date = @Join_Date
		
			Declare curWeekOff cursor for
					select Weekoff_Day ,For_Date , Weekoff_Day_Value ,isnull(Alt_W_Name,'') ,isnull(Alt_W_Full_Day_cont,'') ,isnull(Alt_W_Half_Day_cont,'') 
							,isnull(IS_P_Comp,0)
					from T0100_WEEKOFF_ADJ ER WITH (NOLOCK) Inner join @Emp_Cons Ec on ER.Emp_Id = ec.Emp_ID  and Weekoff_Day <> 'N' and for_date = (select max(for_Date) as for_date 
					from T0100_WEEKOFF_ADJ ER WITH (NOLOCK) Inner join @Emp_Cons Ec on ER.Emp_Id = ec.Emp_ID and for_Date <= @To_Date)
				
			open curWeekOff
				fetch next from curWeekOff into @WeekOff ,@Effe_Date,@Weekoff_Day_Value,@Alt_W_Name,@Alt_W_Full_day_Cont,@Alt_W_Half_Day_Cont,@IS_P_Comp
				while @@fetch_status = 0
					begin
						set @TempFor_Date = @From_Date
						set @Temp_weekoff = @WeekOff
						Delete from @T_Weekoff 
						insert into @T_Weekoff 
						Select data from dbo.Split(@Weekoff_Day_Value,'#')
						
						while @TempFor_Date <= @To_Date
							begin
							
								if @Effe_Date > @From_Date and @TempFor_Date < @Effe_Date 
									begin
										select @Effe_weekoff = Weekoff_Day  ,@Eff_Weekoff_Day_Value = Weekoff_day_Value 
												,@Alt_W_Name = isnull(Alt_W_Name,'') ,@Alt_W_Full_Day_cont = isnull(Alt_W_Full_Day_cont,'') ,@Alt_W_Half_Day_cont = isnull(Alt_W_Half_Day_cont,'') 
												,@IS_P_Comp = isnull(IS_P_Comp,0)
										From T0100_WEEKOFF_ADJ WITH (NOLOCK) where Emp_id = @Emp_ID and Weekoff_Day <> 'N' 
	    								and for_date = (select max(for_Date) as for_date 
										from T0100_WEEKOFF_ADJ WITH (NOLOCK) where Emp_ID = @Emp_ID and for_Date <= @TempFor_Date )
										set @WeekOff = @Effe_weekoff
											
											Delete from @T_Weekoff 
											insert into @T_Weekoff 
											Select data from dbo.Split(@Eff_Weekoff_Day_Value,'#')
									end
								else
									begin
										set @WeekOff = @Temp_weekoff
									end
								
								
								set @Var_All_H_Date =  @strHoliday_Date + '' + @WeekOff
								
								exec SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @TempFor_Date,@Var_All_H_Date,@Pre_Date_WeekOff output,@Next_Date_WeekOff output
								
								select @Weekoff_Value = isnull(replace(Weekoff_Data,datename(dw,@TempFor_Date),''),1) from @T_Weekoff where charindex(datename(dw,@TempFor_Date) ,Weekoff_Data,0) > 0
								
								if isnull(@Weekoff_Value,0) =0
									set @Weekoff_Value = 1
								
								if charindex(datename(dw,@TempFor_Date) ,@WeekOff,0) >0 
									begin
											update @T_W_Count set W_Count =W_Count  + 1 Where W_Name = datename(dw,@TempFor_Date) 
									end
									
								if @Alt_W_Name <> '' and charindex(@Alt_W_Name,datename(dw,@TempFor_Date),0) >0 
									begin
										Select  @varCount = W_Count  From @T_W_Count Where W_Name = @Alt_W_Name
										
										set @varCount = '#' + @varCount   + '#'
										
										
										if @Alt_W_Full_day_Cont <> '' and charindex(@varCount,@Alt_W_Full_day_Cont,0) >0
											begin
												set @Weekoff_Value =1 
											end																				
										else if @Alt_W_Half_day_Cont <> '' and charindex(@varCount,@Alt_W_Half_day_Cont,0) >0											
											begin
												set @Weekoff_Value =0.5 
											end
										else
											begin	
												set @Weekoff_Value =0 
											end
									end
								
								IF charindex(datename(dw,@TempFor_Date) ,@WeekOff,0) >0   and @Join_Date <=@TempFor_date
									Begin
									print @Cmp_ID
									print 'Cmp1'
									
										 if @Is_Cancel_Weekoff =1 and not exists(select Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND 
										 					cast(for_date as varchar(11)) in ( @Pre_Date_WeekOff,@Next_Date_WeekOff))
										 					BEGIN
										 						set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value
										 					END
										 ELSE If @Left_Date is null 
											begin
													set @numWeekOff =  @numWeekOff + @Weekoff_Value
													set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))													
													if @Use_Table =1 
														begin
															insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
															select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value
														end	
													
											end												
										Else If @Left_Date > @TempFor_Date
											begin
													set @numWeekOff =  @numWeekOff + @Weekoff_Value						
													set @varWeekOff_Date = @varWeekOff_Date + ';' +  cast(@TempFor_Date as varchar(11))
													
													if @Use_Table =1 
														begin
															insert into #Emp_Weekoff (Emp_ID,Cmp_ID,For_Date,W_Day)
															select @Emp_ID ,@Cmp_Id,@TempFor_Date,@Weekoff_Value
														end	
										   	end												
										Else	
											set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value		
									end
								  Else if charindex(datename(dw,@TempFor_Date) ,@WeekOff,0) >0 
									Begin
										set	@Cancel_WeekOff = @Cancel_WeekOff + @Weekoff_Value		
									End
									
								set @TempFor_Date = dateadd(d,1,@TempFor_Date)
							end
						fetch next from curWeekOff into @WeekOff ,@Effe_Date,@Weekoff_Day_Value,@Alt_W_Name,@Alt_W_Full_day_Cont,@Alt_W_Half_Day_Cont,@IS_P_Comp
					end 
			close curWeekOff
			deallocate curWeekOff
  
  
  
	RETURN 




