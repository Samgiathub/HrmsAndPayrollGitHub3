


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	--exec SP_EMP_INOUT_SYNCHRONIZATION 1326,9,'2015-07-22 10:00:00:000','192',0,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_TRAINING]
	 @EMP_ID		NUMERIC ,    
	 @CMP_ID		NUMERIC ,    
	 @IO_DATETIME	DATETIME ,    
	 @IP_ADDRESS	VARCHAR(50)    ,
	 @In_Out_flag	numeric = 0, 
	 @Flag			int = 0
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		SET ANSI_WARNINGS OFF

BEGIN
	
	
	 Declare @In_Time Datetime     
	 Declare @Out_Time Datetime     
	 Declare @For_Date Datetime     
	 Declare @varFor_Date varchar(22)     
	 Declare @F_In_Time datetime     
	 Declare @F_Out_Time Datetime  
	 Declare @For_Date_P Datetime      
	 --Declare @S_In_Time datetime     
	 --Declare @S_Out_Time Datetime     
	 --Declare @T_In_Time datetime     
	 --Declare @T_Out_Time Datetime 
	 
	 declare @IO_Tran_ID   numeric     
	 declare @Last_Entry numeric(18,0)
	 Declare @minutdiff numeric(22,0)
	 set @For_Date = cast(@IO_DATETIME as varchar(11))    
	 set @varFor_Date = cast(@IO_DATETIME as varchar(11)) 
	 set @For_Date_P = Dateadd(d,-1,@For_Date)
	 
	 Declare @Max_Date datetime
	 set @Max_Date = null
	
	
	
	 if @Flag = 0
	begin
		select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID
	end
else
	begin
		select @In_Time = max(In_time)  from 
		T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(In_time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
		select @Out_Time = max(Out_Time) from 
		T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(Out_Time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
	end
	
	select @Max_Date = max(for_date) from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @EMP_ID  

	Declare @InOut_duration_Gap numeric   
	select @InOut_duration_Gap = ISNULL(Inout_Duration,300) from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID 
	
	
	
	if isnull(@In_Out_flag,0) = 0
		begin
			if @Flag = 0
				begin	
					If @IO_DATETIME < @Max_Date 
					begin		
						Return
					end	  
				end
			if Exists(select Tran_ID from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where 
				 Emp_Id=@Emp_Id And(In_time = @IO_DATETIME OR Out_Time = @IO_DATETIME ))
				Begin		
					Return
				End
			if not @In_time is null and @In_Time > isnull(@Out_Time,'01-01-1900') and datediff(s,@In_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@In_Time,@IO_DATETIME) >0    --@InOut_duration_Gap Added by Mihir 06/03/2012
			  begin  
				   Update T0150_EMP_Training_INOUT_RECORD     
				   set  In_Time = @IO_DATETIME    
					 ,[Hours] = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,Out_Time))      
				   where In_Time = @In_Time and Emp_ID=@emp_ID    
				   return     
			  end  
			else if not @Out_Time is null and @Out_Time > isnull(@In_Time,'01-01-1900')   and datediff(s,@Out_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@Out_Time,@IO_DATETIME) >0    
			  begin  
				   Update T0150_EMP_Training_INOUT_RECORD     
				   set  Out_Time = @IO_DATETIME    
					 ,[Hours] = dbo.F_Return_Hours (datediff(s,In_Time,@IO_DATETIME))      
				   where Out_Time = @Out_Time and Emp_ID=@emp_ID    
				   return     
			  end 
			  
			select @IO_Tran_ID = isnull(max(Tran_ID),0)+ 1 from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
			if Exists (select Max(In_time)  from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
				begin 
					select @In_Time = Max(In_time)from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))
					
					if @In_Time is null  
						begin 
							INSERT INTO T0150_EMP_Training_INOUT_RECORD    
							(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours,Ip_Address )    
							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'',@Ip_Address)			
							
							 return
						end
					else
						begin 
							declare @Sec_Diff numeric(22,0) 
							 set @Sec_Diff = isnull(Datediff(s,@In_Time,@IO_DATETIME),0)							
							 Declare @Diff_sec_Temp Numeric(22,0)	
							 Set @Diff_sec_Temp = 0							 
							 set @Diff_sec_Temp = 59000--50400--46800	
												
							if @Sec_Diff <= @Diff_sec_Temp--46800 --54000 ------modify by jignesh 14-May-2015---
								Begin 
									Update T0150_EMP_Training_INOUT_RECORD  
									set  Out_Time = @IO_DATETIME  ,IP_Address=@Ip_Address
									where Emp_ID =@Emp_ID and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))) and in_Time  = @In_Time 
						 
									Update T0150_EMP_Training_INOUT_RECORD     
									set  Hours = dbo.F_Return_Hours (datediff(s,In_time,Out_Time))      
									where Emp_ID =@Emp_ID and (For_Date =@For_Date OR (For_Date=dateadd(d,-1,@For_Date))) and not in_time  is null and not out_Time is null   
									return
								End
							INSERT INTO T0150_EMP_Training_INOUT_RECORD    
							(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours,  Ip_Address)    
							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'',@Ip_Address)				
							return
						End
				end  
			if Not Exists (select Max(In_time)  from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
				Begin
						 INSERT INTO T0150_EMP_Training_INOUT_RECORD    
					(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours,  Ip_Address)    
					VALUES (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'',@Ip_Address)			
				End	  
		end
	if @In_Out_flag = 2 
			begin
				select @IO_Tran_ID = isnull(max(Tran_ID),0)+ 1 from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
				
				 INSERT INTO T0150_EMP_Training_INOUT_RECORD    
				(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours,  Ip_Address)      
				VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@IO_DATETIME,'',@Ip_Address)			
			
			end
	if @In_Out_flag = 3
			begin
				select @IO_Tran_ID = isnull(max(Tran_ID),0)+ 1 from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
			
				
				Update T0150_EMP_Training_INOUT_RECORD     
			   set  In_Time = @IO_DATETIME  
				 ,[Hours] = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,Out_Time))      
			   where Emp_ID=@emp_ID and For_Date = @For_Date
			end
	end
	-------------my code------------------------
	-- if @Flag = 0
	--	begin
	--		select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_EMP_Training_INOUT_RECORD where emp_ID=@emp_ID
	--	end
	--Else
	--	begin
	--		select @In_Time = max(In_time)  from 
	--		T0150_EMP_Training_INOUT_RECORD where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(In_time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
	--		select @Out_Time = max(Out_Time) from 
	--		T0150_EMP_Training_INOUT_RECORD where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(Out_Time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
	--	end
	
	--	select @Max_Date = max(for_date) from T0150_EMP_Training_INOUT_RECORD where Emp_ID = @EMP_ID 
		
	--	Declare @InOut_duration_Gap numeric   
	--	select @InOut_duration_Gap = ISNULL(Inout_Duration,300) from T0010_COMPANY_MASTER where Cmp_Id = @CMP_ID  
		
	--	if isnull(@In_Out_flag,0) = 0
	--		begin
	--			if @Flag = 0
	--				begin	
	--					If @IO_DATETIME < @Max_Date 
	--					begin		
	--						Return
	--					end	  
	--				end
					
	--			if Exists(select Tran_ID from T0150_EMP_Training_INOUT_RECORD where 
	--				Emp_Id=@Emp_Id And(cast(In_time as varchar(11)) + ' ' + dbo.F_GET_AMPM(In_time)  = @IO_DATETIME OR cast(Out_time as varchar(11)) + ' ' + dbo.F_GET_AMPM(Out_time) = @IO_DATETIME ))
	--			Begin		
	--				Return
	--			End
				
	--			 if (not @In_Time is null) and @In_Time > isnull(@OUT_Time,'01-01-1900')  and datediff(s,@In_Time,@IO_DATETIME) >0   and datediff(s,@Out_Time,@IO_DATETIME) < @InOut_duration_Gap  
	--				  begin 
	--					   Update T0150_EMP_Training_INOUT_RECORD     
	--					   set  Out_Time = @IO_DATETIME    
	--						 ,Hours = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,IN_TIME))
	--						 --where Out_Time = @OUT_Time and Emp_ID=@emp_ID
	--						where IN_Time = @IN_Time and Emp_ID=@emp_ID
	--				   return     
	--				  end		
	--			 else if not @Out_Time is null and @OUT_Time > isnull(@IN_Time,'01-01-1900')    and datediff(s,@OUT_Time,@IO_DATETIME) >0    and datediff(s,@In_Time,@IO_DATETIME) < @InOut_duration_Gap
	--				  begin 
	--					   Update T0150_EMP_Training_INOUT_RECORD     
	--					   set  In_Time = @IO_DATETIME    
	--						 ,Hours = dbo.F_Return_Hours (datediff(s,Out_Time,@IO_DATETIME))      
	--					    where Out_Time = @OUT_Time and Emp_ID=@emp_ID
	--					  --where IN_Time = @IN_Time and Emp_ID=@emp_ID
	--						return     
	--				  end
					  
	--			--if Not Exists (select Max(In_Time)  from T0150_EMP_Training_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null And In_Time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
	--				if isnull(@In_time,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'
	--					if  Exists (select Max(Out_Time)  from T0150_EMP_Training_INOUT_RECORD where emp_ID=@emp_ID  And In_Time is null And Out_Time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
	--							Begin 
	--								select @IO_Tran_ID = isnull(max(Tran_ID),0)+ 1 from T0150_EMP_Training_INOUT_RECORD 
	--									 INSERT INTO T0150_EMP_Training_INOUT_RECORD    
	--								(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours,  Ip_Address)    
	--								VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'',@Ip_Address)			
								
	--							End
	--				end
	--	else
	--		begin
	--			if @In_Out_flag = 2 
	--				begin
	--					select @IO_Tran_ID = isnull(max(Tran_ID),0)+ 1 from T0150_EMP_Gate_Pass_INOUT_RECORD 
				
	--					 INSERT INTO T0150_EMP_Training_INOUT_RECORD    
	--					(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours, Ip_Address)    
	--					VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@IO_DATETIME,'',@Ip_Address)			
	--				end
	--		end
	
--END


