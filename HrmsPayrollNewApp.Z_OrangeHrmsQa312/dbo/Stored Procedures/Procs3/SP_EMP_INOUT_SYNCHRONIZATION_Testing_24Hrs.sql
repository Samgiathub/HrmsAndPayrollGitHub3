


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_Testing_24Hrs]
 @EMP_ID NUMERIC ,    
 @CMP_ID NUMERIC ,    
 @IO_DATETIME DATETIME ,    
 @IP_ADDRESS VARCHAR(50)    ,
 @In_Out_flag numeric = 0, 
 @Flag int = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF
	 
 Declare @In_Time Datetime     
 Declare @Out_Time Datetime     
 Declare @For_Date Datetime     
 Declare @varFor_Date varchar(22)     
 Declare @F_In_Time datetime     
 Declare @F_Out_Time Datetime     
 Declare @S_In_Time datetime     
 Declare @S_Out_Time Datetime     
 Declare @T_In_Time datetime     
 Declare @T_Out_Time Datetime     
	
	
 Declare @Shift_st_Time  Datetime     
 Declare @Shift_End_Time  datetime     
 Declare @F_Shift_In_Time Datetime     
 Declare @F_Shift_End_Time datetime     
 Declare @S_Shift_in_Time datetime     
 Declare @S_shift_end_Time datetime     
 Declare @T_Shift_In_Time datetime     
 Declare @T_Shift_End_Time datetime 
 
 Declare @Shift_st_Time_P  Datetime     
 Declare @Shift_End_Time_P  datetime     
 Declare @F_Shift_In_Time_P Datetime     
 Declare @F_Shift_End_Time_P datetime     
 Declare @S_Shift_in_Time_P datetime     
 Declare @S_shift_end_Time_P datetime     
 Declare @T_Shift_In_Time_P datetime     
 Declare @T_Shift_End_Time_P datetime  
 Declare @For_Date_P Datetime    
  
  
 declare @IO_Tran_ID   numeric     
 declare @Last_Entry numeric(18,0)
 Declare @minutdiff numeric(22,0)
 set @For_Date = cast(@IO_DATETIME as varchar(11))    
 set @varFor_Date = cast(@IO_DATETIME as varchar(11)) 
 set @For_Date_P = Dateadd(d,-1,@For_Date)



	--------------------- Add by jigensh 30-Apr-2015---- For Canteen Entry Client:- Apollo ----
	if  @IP_ADDRESS='Canteen'
	begin
	     return
	end
	
	if  exists(select IP_Address from T0040_IP_MASTER WITH (NOLOCK) where IP_Address=@IP_Address and Device_No > 200)
	begin
	     return
	end
	------------------------------- End ------------------------	
	
	
 Declare @Max_Date datetime
 --changes done by Falak on 04-jan-2011 
 -- for blocking of updating the entry of inout records
 set @Max_Date = null
-- select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID
	-- Added by Gadriwala Muslim 02012015 - Start
If Len(@Ip_Address) <=3
	Begin
	  if exists(select 1 from T0040_IP_MASTER WITH (NOLOCK) where Device_No = @IP_ADDRESS and Cmp_ID = @CMP_ID and Is_Gate_Pass = 1)	
			begin
					
				Exec SP_EMP_INOUT_SYNCHRONIZATION_GATE_PASS @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,@Flag
				return
			end
		--added by sneha on 21 july 2015 -start
	 else if exists(select 1 from T0040_IP_MASTER WITH (NOLOCK) where Device_No = @IP_ADDRESS and Cmp_ID = @CMP_ID and Is_Training = 1)	
		begin		 		
			Exec SP_EMP_INOUT_SYNCHRONIZATION_TRAINING @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,@Flag
			return
		end	--added by sneha on 21 july 2015 -end
	End
-- Added by Gadriwala Muslim 02012015 - End
  if @Flag = 0
	begin
		select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record WITH (NOLOCK) where emp_ID=@emp_ID
	end
else
	begin
	
	
		select @In_Time = max(In_time)  from 
		T0150_emp_inout_Record WITH (NOLOCK) where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(In_time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
		
		select @Out_Time = max(Out_Time) from 
		T0150_emp_inout_Record WITH (NOLOCK) where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(Out_Time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
	end
	
 
 
 select @Max_Date = max(for_date) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @EMP_ID 
  
----  select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID  

	Declare @InOut_duration_Gap numeric    --Added by Mihir 06/03/2012
	select @InOut_duration_Gap = ISNULL(Inout_Duration,300) from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID   --Added by Mihir 06/03/2012
	
	

if isnull(@In_Out_flag,0) = 0
	begin
			
			if @Flag = 0
			begin	
				If @IO_DATETIME < @Max_Date 
				begin		
					Return
				end	  
			end
				
				 if Exists(select IO_Tran_ID from t0150_emp_inout_record WITH (NOLOCK) where 
				 Emp_Id=@Emp_Id And(In_time = @IO_DATETIME OR Out_Time = @IO_DATETIME ))
				Begin		
					Return
				End 
							
			--declare @minInTime datetime
			--declare @maxOutTime datetime


			--select @minInTime=min(In_Time),@maxOutTime=max(Out_Time) from t0150_emp_inout_record where Emp_Id=@Emp_Id And(day(For_Date) = day(@IO_DATETIME) and month(For_Date) = month(@IO_DATETIME) and year(For_Date) = year(@IO_DATETIME) )


			--if Exists(select IO_Tran_ID from t0150_emp_inout_record where Emp_Id=@Emp_Id And day(For_Date) = day(@IO_DATETIME) and month(For_Date) = month(@IO_DATETIME) and year(For_Date) = year(@IO_DATETIME) and In_Time is not NULL and Out_Time is not NULL) OR (@minInTime is not NULL and @maxOutTime is not NULL)
			--Begin			
			--	Return
			--End 
			
			 if not @In_time is null and @In_Time > isnull(@Out_Time,'01-01-1900') and datediff(s,@In_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@In_Time,@IO_DATETIME) >0    --@InOut_duration_Gap Added by Mihir 06/03/2012
			  begin   
			  --print 'y' 
			   Update T0150_emp_inout_Record     
			   set  In_Time = @IO_DATETIME    
				 ,Duration = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,Out_Time))      
			   where In_Time = @In_Time and Emp_ID=@emp_ID    
			   
			   goto UpdtFormDate
			  -- return     
			  end    
			 else if not @Out_Time is null and @Out_Time > isnull(@In_Time,'01-01-1900')   and datediff(s,@Out_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@Out_Time,@IO_DATETIME) >0    
			  begin    
			  --print 'N'
			   Update T0150_emp_inout_Record     
			   set  Out_Time = @IO_DATETIME    
				 ,Duration = dbo.F_Return_Hours (datediff(s,In_Time,@IO_DATETIME))      
			   where Out_Time = @Out_Time and Emp_ID=@emp_ID    
			   
			  -- return
			    goto UpdtFormDate     
			  end    

			---- Added by rohit on 31122013 for Auto Shift
			
			  declare @in_time_temp as datetime
			  declare @out_time_temp as datetime
			  declare @Pre_IO_Date as datetime
			  declare @Pre_IO_Flag as varchar
			
			select TOP 1 @in_time_temp=in_time,@out_time_temp=out_time from T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE Emp_Id=@Emp_Id AND cmp_id =@cmp_id AND For_Date < @IO_DATETIME ORDER BY For_Date DESC
			
			if isnull(@out_time,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'
			begin
				set @Pre_IO_Date =@in_time_temp
				set @Pre_IO_Flag='I'
			end
			else
			BEGIN
				set @Pre_IO_Date =@out_time_temp
				set @Pre_IO_Flag='O'
			END
			
				Declare @Shift_St_Time1 as varchar(10)
				Declare @Shift_End_Time1 as varchar(10)
				
		
		   EXEC Get_Emp_Curr_Shift_New @emp_id,@cmp_id,@IO_DATETIME,@Pre_IO_Flag,@Pre_IO_Date,@Shift_St_Time1 output ,@Shift_End_Time1 output
		

			if not @Shift_St_Time1 is null and @Shift_St_Time1 <> ''
				Begin
					set @F_Shift_In_Time = @Shift_St_Time1 
					set @F_Shift_End_Time = @Shift_End_Time1
				End
						

		
			if @Shift_St_Time1 is null OR @Shift_St_Time1 = ''
			begin  	
			  exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date,null,@F_Shift_In_Time output ,@F_Shift_End_Time output,@S_Shift_in_Time output ,@S_shift_end_Time output,@T_Shift_In_Time output ,@T_Shift_End_Time output , @Shift_st_Time output ,@Shift_end_Time output
			End		
				   
			
			exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date_P,null,@F_Shift_In_Time_P output ,@F_Shift_End_Time_P output,@S_Shift_in_Time_P output ,@S_shift_end_Time_P output,@T_Shift_In_Time_P output ,@T_Shift_End_Time_P output , @Shift_st_Time_P output ,@Shift_end_Time_P output
			 --Ended by rohit on 31-dec-2013 for auto shift				   
			
					
			  if @S_Shift_in_Time ='1900-01-01 00:00:00.000'    
			   set @S_Shift_in_Time = null    
			  if @S_Shift_End_Time ='1900-01-01 00:00:00.000'    
			   set @S_Shift_End_Time = null    
				  
			  if @T_Shift_In_Time ='1900-01-01 00:00:00.000'    
			   set @T_Shift_In_Time = null    
				
			  if @T_Shift_End_Time ='1900-01-01 00:00:00.000'    
			   set @T_Shift_End_Time = null    
			   
			   if @S_Shift_in_Time_P ='1900-01-01 00:00:00.000'    
			   set @S_Shift_in_Time_P = null    
			  if @S_Shift_End_Time_P ='1900-01-01 00:00:00.000'    
			   set @S_Shift_End_Time_P = null    
				  
			  if @T_Shift_In_Time_P ='1900-01-01 00:00:00.000'    
			   set @T_Shift_In_Time_P = null    
				
			  if @T_Shift_End_Time_P ='1900-01-01 00:00:00.000'    
			   set @T_Shift_End_Time_P = null    
					  
			  set @F_Shift_In_Time =  @varFor_Date + ' ' + @F_Shift_In_Time    
			  set @F_Shift_End_Time = @varFor_Date + ' ' + @F_Shift_End_Time    
			  set @S_Shift_in_Time = @varFor_Date + ' ' + @S_Shift_in_Time    
			  set @S_shift_end_Time = @varFor_Date + ' ' + @S_shift_end_Time    
			  set @T_Shift_In_Time = @varFor_Date + ' ' + @T_Shift_In_Time     
			  set @T_Shift_End_Time = @varFor_Date + ' ' + @T_Shift_End_Time    
			  set @Shift_end_Time = @varFor_Date + ' ' + @Shift_end_Time    
			  set @Shift_st_Time = @varFor_Date + ' ' + @Shift_st_Time 
			  
			   
			select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record WITH (NOLOCK)  

				   if Exists (select Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
								Begin
									Declare @Diff numeric(22,0)
									set @Diff = isnull(Datediff(s,@F_Shift_In_Time,@IO_DATETIME),0)
									
									--if @Diff >=-10800
									If @IO_DATETIME between Dateadd(HOUR,-2,@F_Shift_In_Time) AND DATEADD(hour,2,@F_Shift_In_Time) --Added by hardik 21/05/2015 as when shift is changed for night then it will not consider new Punch as IN
										Begin				
										
											select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  
											And Out_Time is null And In_time <  @IO_DATETIME     
											and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))
											
											if @In_Time is not null  
												Begin									
													
													Declare @varFor_Date_P varchar(22)    
													
													set @varFor_Date_P = cast(@In_Time as varchar(11)) 
													
													set @F_Shift_In_Time_P =  @varFor_Date_P + ' ' + @F_Shift_In_Time_P  
													set @minutdiff = isnull(Datediff(s,@F_Shift_In_Time_P,@IO_DATETIME),0)
													
														if @minutdiff > =  54000  --75600
															Begin
															
																INSERT INTO T0150_EMP_INOUT_RECORD    
																(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
																VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)			
																-- return						
																 goto UpdtFormDate
															End	
														Else if @minutdiff <0 And Datediff(s,@In_Time,@Io_Datetime) >= 43200--12 Hours --39000 --32400 --9 hours --Added by Hardik 21/05/2015
															Begin
															   
																INSERT INTO T0150_EMP_INOUT_RECORD    
																(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
																VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)			
																-- return						
																 goto UpdtFormDate
															End	
														
												End
										End					
								  
								End


		
				   if Exists (select Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
						  Begin 
						  
							--Condition added by Hardik on 05/04/2014 for below case going wrong
							/* Sample case
								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 10:00AM', '192.168.1.1',0, 0
								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 12:01PM', '192.168.1.1',0, 0
								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 06:59PM', '192.168.1.1',0, 0
								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '02-apr-2014 10:01AM', '192.168.1.1',0, 0
							*/
						
							
							If @F_Shift_In_Time_P > @F_Shift_End_Time_P --or @F_Shift_In_Time > @F_Shift_End_Time
								Begin
								
									select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  
									And Out_Time is null And In_time <  @IO_DATETIME     
									and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))
								End
							Else
								Begin
									
									
									--select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  
									--And Out_Time is null 
									--And In_time <  @IO_DATETIME    
									--and  For_Date=@For_Date
									--------- jignesh  21-OCt-2015-------
									--Commented by Hardik 27/10/2015 from below If condition
									---( datepart(hh,@IO_DATETIME)=0)and
									if   (datepart(hh,@F_Shift_In_Time_P)=0 or datepart(hh,@F_Shift_In_Time)=0)
									    begin
												select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  
											And Out_Time is null 
											And In_time <  @IO_DATETIME    
											and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))
									    end
										
									 else
									   begin
											   select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  
											And Out_Time is null 
											And In_time <  @IO_DATETIME    
											and  For_Date=@For_Date
									   end
								--------- end------- 
									
								End
						
						   
						   if @In_Time is null  
									Begin  
							    	--select Shift_ID from T0100_Emp_Shift_Detail where Emp_ID=@Emp_ID and For_Date in(select max(for_date) from T0100_Emp_Shift_Detail where Emp_ID=@Emp_ID and For_Date <= @For_Date) And Shift_type <> 1	
									
									INSERT INTO T0150_EMP_INOUT_RECORD    
									(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
									VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)			
									
				
									
									 --Return
									  goto UpdtFormDate
									End  
						   else  

							Begin 

							 declare @Sec_Diff numeric(22,0) 
							 set @Sec_Diff = isnull(Datediff(s,@In_Time,@IO_DATETIME),0)
							 
								--if @Sec_Diff <= 126000,57600
								--if @Sec_Diff <= 72000
							
							 Declare @Diff_sec_Temp Numeric(22,0)	--Ankit 26062015
							 Set @Diff_sec_Temp = 0
							 
							 
							 If CONVERT(varchar(5), @Shift_St_Time1, 108) < CONVERT(varchar(5), @Shift_End_Time1, 108)
								begin
								
							    set @Diff_sec_Temp = 64800--61200
							    end
							 Else
							    begin
							    
							    set @Diff_sec_Temp = 59000--50400--46800
								end
								----select @IO_DATETIME,@Sec_Diff,@Diff_sec_Temp

								if @Sec_Diff <= @Diff_sec_Temp--46800 --54000 ------modify by jignesh 14-May-2015---
								
									Begin
																	
										Update T0150_EMP_INOUT_RECORD  
										set  Out_Time = @IO_DATETIME  ,IP_Address=@Ip_Address
										where Emp_ID =@Emp_ID and  ((For_Date=@For_Date)  
										OR (For_Date=dateadd(d,-1,@For_Date))) 
										and in_Time  = @In_Time 
										
							 
										Update T0150_emp_inout_Record     
										set  Duration = dbo.F_Return_Hours (datediff(s,In_time,Out_Time))      
										where Emp_ID =@Emp_ID and (For_Date =@For_Date OR (For_Date=dateadd(d,-1,@For_Date))) and not in_time  is null and not out_Time is null   
				
										--return
										 goto UpdtFormDate
									End
								
								
							INSERT INTO T0150_EMP_INOUT_RECORD    
							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)				
							  --return
							   goto UpdtFormDate
							End  
						  End 
						  
				   if Not Exists (select Max(In_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
						Begin
								 INSERT INTO T0150_EMP_INOUT_RECORD    
							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)			
						
						End
				end

---------------- Add jignesh 22-Oct-2015-------------
UpdtFormDate:
				if  ( datepart(hh,@IO_DATETIME)=0)and (datepart(hh,@F_Shift_In_Time_P)=0 or datepart(hh,@F_Shift_In_Time)=0)
				begin
				
					 Update T0150_EMP_INOUT_RECORD  
										set  For_date = For_date-1 
										where Emp_ID =@Emp_ID 
										--and  ((For_Date=@For_Date)  
										--OR (For_Date=dateadd(d,-1,@For_Date))) 
										and in_Time  = @IO_DATETIME
				end
------------------------- End -------------------------
else
	begin
		
		if @In_Out_flag = 2 
			begin
				
			
				
				select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record WITH (NOLOCK)
				
				 INSERT INTO T0150_EMP_INOUT_RECORD    
				(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,Cmp_prp_out_flag,is_Cmp_purpose)    
				VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@IO_DATETIME,'','',@Ip_Address,null,null, 0, 0,@In_Out_flag,1)			
			
								
				
			end
		
		if @In_Out_flag = 3
			begin
			
		
				select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record WITH (NOLOCK)
				
				-- INSERT INTO T0150_EMP_INOUT_RECORD    
				--(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,Cmp_prp_in_flag,is_Cmp_purpose)    
				--VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,@In_Out_flag,1)			
				
				
				Update T0150_emp_inout_Record     
			   set  In_Time = @IO_DATETIME    
					,Cmp_prp_in_flag = @In_Out_flag	
				 ,Duration = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,Out_Time))      
			   where Emp_ID=@emp_ID and is_Cmp_purpose = 1 and Cmp_prp_in_flag = 0 and Cmp_prp_out_flag > 0 and For_Date = @For_Date
			   
		
			
			end
		
	end
					
		
RETURN



