
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_EMP_INOUT_RECORDS_Admin]  
	  @IO_Tran_Id  numeric(27) output  
     ,@Emp_ID   numeric(18)  
     ,@Cmp_Id   numeric(18)    
     ,@For_Date   datetime  
     ,@In_Time   Datetime  
     ,@Out_Time   Datetime  
     ,@Duration   varchar(10)  
     ,@Reason   varchar(100)  
     ,@Ip_Address  varchar(50)  
     ,@tran_type  char(1)  
     ,@Skip_Count  numeric = 0  
     ,@Is_Cancel_Late_In   numeric(1,0)		--MOdified By Ramiz on 07/10/2015
     ,@Is_Cancel_Early_Out numeric(1,0)		--Added By Ramiz on 07/10/2015
	 ,@User_Id numeric(18,0) = 0	-- Added for audit trail By Ali 09102013
	 ,@UIP_Address varchar(30) = ''	-- Added for audit trail By Ali 09102013
	 ,@IsDefault  numeric(18,0) = 0 -- Added for audit trail By Ali 09102013
	 ,@Is_default_cancel_Early_out numeric(18,0) = 0  -- Added by nilesh for Default Out time (For Nirma Client) on 08042015
	 ,@ManualEntryFlag char(3) ='N' --Added by Sumit for row color change if manual entry for Samarth 13-Feb-2016
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

			-- Added for audit trail By Ali 09102013 -- Start
			declare  @old_Emp_ID numeric
			declare  @old_Cmp_ID numeric
			declare  @old_For_Date datetime
			declare  @old_In_Time datetime
			declare  @old_Out_Time datetime
			declare  @old_Duration varchar(12)
			declare  @old_Reason varchar(50)
			declare  @old_Ip_Address varchar(20)
			declare  @old_In_Date_Time datetime
			declare  @old_Out_Date_Time datetime
			declare  @old_Sup_Comment varchar(50)
			declare  @old_Emp_Name varchar(50)
			declare  @new_Emp_Name varchar(50)
			
			set @new_Emp_Name = ''
			set @old_Emp_ID = 0
			set @old_Cmp_ID = 0
			set @old_For_Date = null
			set @old_In_Time = null
			set @old_Out_Time = null
			set @old_Duration =''
			set @old_Reason =''
			set @old_Ip_Address =''
			set @old_In_Date_Time = null
			set @old_Out_Date_Time = null
			set @old_Sup_Comment  =''
			set @old_Emp_Name =''
			
			declare @OldValue as varchar(max)
			set @OldValue = '' 
			
			-- Added for audit trail By Ali 09102013 -- End
			
   
   
  If isnull(@Out_Time,'') =''  
	  begin  
	   set @Out_Time = null  
	  end   
  If isnull(@In_Time,'') <> '' and  isnull(@Out_Time,'') <> ''  
	  begin  
	   set @Duration = dbo.F_Return_Hours(datediff(s,@In_Time,@Out_time))  
	  end  
 
  
 Declare @System_Date Datetime	--Ankit 22082014
 Set  @System_Date = GETDATE()
  
   
 If @tran_type ='I'   
   begin  
    --If exists (Select IO_Tran_Id  from T0150_EMP_INOUT_RECORD Where Emp_ID = @Emp_ID and For_Date=  @For_Date and Out_Time >= @In_Time)   
    -- begin  
    --  set @IO_Tran_Id=0  
    --  return  
    -- end  
    
      ---  Added by Mihir 12122011 for Check Salary Exist Condition
	  if  exists(select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) 
	  where Month_St_Date<= @For_Date And isnull(cutoff_date,Month_End_Date) >= @For_Date and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_Id and is_Monthly_Salary = 1)
       begin
			set @IO_Tran_Id=0
			RAISERROR('salary Exist - Insert',16,2)
       return  
	   end
	
      ---  end Added by Mihir 12122011 for Check Salary Exist Condition
       
	  IF EXISTS(SELECT 1 FROM T0180_LOCKED_ATTENDANCE WITH (NOLOCK) WHERE FROM_DATE <= @FOR_DATE AND case when cutoff_date ='1900-01-01 00:00:00' then To_date else cutoff_date end >= @FOR_DATE AND EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID)
       BEGIN
			SET @IO_TRAN_ID=0
			RAISERROR('Attendance Lock - Insert',16,2)
			RETURN  
	   END

        
    If Exists(Select Io_Tran_ID From T0150_Emp_inout_Record WITH (NOLOCK) where Emp_ID = @emp_ID and (In_time =@In_time or ( Out_Time =@out_time and isnull(@Out_time,'') <>'')))  
		BEGIN
			IF @Is_Cancel_Early_Out = 1 or @Is_Cancel_Late_In = 1
				BEGIN
					If @IsDefault = 1
						BEGIN	--Allowed to Update from Default Inout Page ( Ramiz - 26/12/2017 )
							UPDATE T0150_Emp_inout_Record 
							SET Is_Cancel_Late_In = isnull(@Is_Cancel_Late_In,0) , Is_Cancel_Early_Out = isnull(@Is_Cancel_Early_Out,0) , 
							Reason = isnull(@Reason,'') , Chk_By_Superior = 2  --Chk_By_Superior = 1 , Half_Full_day = 'Full Day' ''Commented and Changed By Ramiz on 17/03/2016 , Now It will Reduce the Count of Late/Early but will not Regularize that Entry
							WHERE Emp_ID = @emp_ID and (In_time =@In_time or ( Out_Time =@out_time and isnull(@Out_time,'') <>''))
						
							SELECT @IO_Tran_Id =  Io_Tran_ID From T0150_Emp_inout_Record WITH (NOLOCK)
							WHERE Emp_ID = @emp_ID and (In_time =@In_time or ( Out_Time =@out_time and isnull(@Out_time,'') <>''))
						END
					ELSE
						BEGIN	--Restricted Same Date Duplicate Entry from Employee In Out Form ) ( Jaina - 14/09/2017)
							SET @IO_Tran_Id=0  
							RAISERROR('Record already exists,please check In/Out Time',16,2)
							RETURN
						END
						
				END
			ELSE
				BEGIN
					If @IsDefault = 1
						BEGIN	--Allowed to Update from Default Inout Page ( Ramiz - 26/12/2017 )
							UPDATE T0150_Emp_inout_Record 
							SET Is_Cancel_Late_In = isnull(@Is_Cancel_Late_In,0) , Is_Cancel_Early_Out = isnull(@Is_Cancel_Early_Out,0) , Reason = isnull(@Reason,'') , Chk_By_Superior = 0 , Half_Full_day = ''
							WHERE Emp_ID = @emp_ID and (In_time =@In_time or ( Out_Time =@out_time and isnull(@Out_time,'') <>''))
							
							SELECT @IO_Tran_Id =  Io_Tran_ID 
							FROM T0150_Emp_inout_Record WITH (NOLOCK)
							WHERE Emp_ID = @emp_ID and (In_time =@In_time or ( Out_Time =@out_time and isnull(@Out_time,'') <>''))
						END
					ELSE
						BEGIN	--Restricted Same Date Duplicate Entry from Employee In Out Form ) ( Jaina - 14/09/2017)
							SET @IO_Tran_Id=0  
							RAISERROR('Record already exists,please check In/Out Time',16,2)
							RETURN
						END	
				END
		END   
    ELSE IF exists (select For_Date ,In_time ,Out_time from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time >= @In_Time and For_date =@For_date)  
		BEGIN	
			 if exists( select * from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and Out_time >= @In_Time and In_time < @In_Time)  
				  BEGIN  
					SET @IO_Tran_Id=0  
					If @IsDefault = 0
						RAISERROR('Record already exists,please check In/Out Time',16,2)
					RETURN  
				  END   
			 else if Isnull(@Out_Time,'')<> ''  
				  BEGIN
						IF EXISTS(select In_time from T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID= @emp_ID and In_time =   
									(select min(In_time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time >=@In_Time )
								   and In_Time < @Out_Time )  
						BEGIN  
							SET @IO_Tran_Id=0
							If @IsDefault = 0
								RAISERROR('Record already exists,please check In/Out Time',16,2)  
							RETURN  
						END  
				  END  
		END  
    ELSE IF exists(select Out_time from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time < @In_Time)
		 BEGIN  
			IF exists(select Out_time from T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID= @emp_ID and In_time =  
			(select max(In_time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time < @In_Time  ) and Out_Time > @In_Time)  
				BEGIN  
					SET @IO_Tran_Id=0 
					If @IsDefault = 0 
						RAISERROR('Record already exists,please check In/Out Time',16,2)
					RETURN  
				END
				Else IF exists(select Out_time from T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID= @emp_ID and In_time =  
			(select max(In_time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time < @In_Time  ) and Out_Time >= @In_Time)  
				BEGIN  
				--Added by ronakk 15122022
					SET @IO_Tran_Id=0 
					If @IsDefault = 0 
						RAISERROR('Previous out time and current in time can not be same',16,2)
					RETURN  
				END
		 END  
     ELSE IF isnull(@Out_Time,'') <>''  
		 BEGIN  
			  IF EXISTS(select Emp_ID from T0150_emp_inout_record WITH (NOLOCK) where Emp_ID=@Emp_ID and In_Time >=@In_Time and In_Time <@Out_time)  
			   BEGIN  
				SET @IO_Tran_Id=0 
				If @IsDefault = 0 
					RAISERROR('Record already exists,please check In/Out Time',16,2) 
				RETURN  
			   END  
		 END  
         
    If NOT EXISTS(Select Io_Tran_ID From T0150_Emp_inout_Record WITH (NOLOCK) where Emp_ID = @emp_ID and (In_time =@In_time or ( Out_Time =@out_time and isnull(@Out_time,'') <>'')))
		Begin  
			set @ManualEntryFlag='New' --Added by Sumit 13022016
			Select @IO_Tran_Id= isnull(max(IO_Tran_Id),0) + 1  from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
			

			--Added by mehul for in admin time and out admin time flag 30102021
			Declare @In_Admin_Time as char,
			@Out_Admin_Time as char
			
			If CAST(@In_Time as Time) > '00:00:00'
			Begin
			SET @In_Admin_Time = 'A'
			End
			
			If CAST(@Out_Time as Time) > '00:00:00'
			Begin
			SET @Out_Admin_Time = 'A'
			End
			
				
			 Insert Into T0150_EMP_INOUT_RECORD(IO_Tran_Id,Emp_ID,Cmp_ID,For_Date,In_Date_Time,Out_Date_Time,In_Time,Out_Time,Duration,Reason,Ip_Address,Is_Cancel_Late_In,System_Date,Is_Cancel_Early_Out,ManualEntryFlag,In_Admin_Time,Out_Admin_Time)  
				values(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@In_Time,@Out_Time,@In_Time,@Out_Time,@Duration,@Reason,@Ip_Address,@Is_Cancel_Late_In,@System_Date,@Is_Cancel_Early_Out,@ManualEntryFlag,@In_Admin_Time,@Out_Admin_Time)	--Modified By Ramiz on 07/10/2015
				


					-- Added for audit trail By Ali 09102013 -- Start
					Select @IO_Tran_Id= isnull(max(IO_Tran_Id),0) + 1  from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
					select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
					set @OldValue = ' New Value # Emp Name : ' 
									+ @old_Emp_Name + ' # Emp Id : ' 
									+ cast(@Emp_ID as nvarchar(10)) 
									+ ' # Cmp id : ' + cast(@Cmp_ID as nvarchar(10)) 
									+ ' # For Date : ' + cast(@For_Date as nvarchar(25))  
									+ ' # In Time : ' + cast(@In_Time as nvarchar(25)) 
									+ ' # Out Time : ' + cast(@Out_Time as nvarchar(25))  
									+ ' # Duration : ' + cast(@Duration  as nvarchar(10)) 
									+ ' # Reason : ' + ISNULL(@Reason,'')
									+ ' # IP Address : ' + ISNULL(@Ip_Address,'')
					-- Added for audit trail By Ali 09102013 -- End
			END		
       
   end  
 else if @tran_type ='U'   
   begin  
    
--    If exists (Select IO_Tran_Id  from T0150_EMP_INOUT_RECORD Where Emp_ID = @Emp_ID and For_Date=  @For_Date and Out_Time >= @In_Time and IO_Tran_Id <> @IO_Tran_Id)   
--     begin  
--      set @IO_Tran_Id=0  
--      return  
--     end  
	  if Exists(select 1 from T0160_Attendance_Application WITH (NOLOCK) where For_Date = DATEADD(DAY,1,@For_Date) and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_Id)
		   Begin
				set @IO_Tran_Id=0
				RAISERROR('Attendance Application is exists so you can not update it.',16,2)
				Return  
		   End

	   ---  Added by Mihir 12122011 for Check Salary Exist Condition
	  if  exists(select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date<= @For_Date And isnull(cutoff_date,Month_End_Date)>= @For_Date and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_Id)
       begin
			set @IO_Tran_Id=0
			RAISERROR('salary Exist - Update',16,2)
       return  
	   end
	
      ---  end Added by Mihir 12122011 for Check Salary Exist Condition

	  if  exists(select 1 from T0180_LOCKED_ATTENDANCE WITH (NOLOCK) where From_Date <= @For_Date And case when cutoff_date ='1900-01-01 00:00:00' then To_date else cutoff_date end >= @For_Date and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_Id)
       BEGIN
			SET @IO_TRAN_ID=0
			RAISERROR('Attendance Lock - Update',16,2)
			RETURN  
	   END
      
    If Exists(Select Io_Tran_ID From T0150_Emp_inout_Record WITH (NOLOCK) where Emp_ID = @emp_ID    and  (In_time =@In_time or ( Out_Time =@out_time and isnull(@Out_time,'') <>'')) and IO_Tran_Id <> @IO_Tran_Id )  
		  BEGIN   
			   SET @IO_Tran_Id=0
			   IF @IsDefault = 0
					RAISERROR('Record already exists,please check In/Out Time',16,2)
			   RETURN
		  END   
    ELSE IF exists (select For_Date ,In_time ,Out_time from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time >= @In_Time and For_date =@For_date and IO_Tran_Id <> @IO_Tran_Id )  
		BEGIN  
			 if exists( select * from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and Out_time >= @In_Time and In_time < @In_Time and IO_Tran_Id <> @IO_Tran_Id )  
				  BEGIN
					   set @IO_Tran_Id=0
					   IF @IsDefault = 0  
							RAISERROR('Record already exists,please check In/Out Time',16,2)
					   return  
				  END   
			 else if Isnull(@Out_Time,'')<> ''  
				  begin  
					   if exists(select In_time from T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID= @emp_ID and In_time =   
					   (select min(In_time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and  In_time >=@In_Time and IO_Tran_Id <> @IO_Tran_Id)  
					   and In_Time <@Out_Time and IO_Tran_Id <> @IO_Tran_Id )  
						BEGIN  
							 SET @IO_Tran_Id=0
							 IF @IsDefault = 0
								RAISERROR('Record already exists,please check In/Out Time',16,2) 
							 RETURN  
						END  
				  end  
			 end  
			else if exists(select Out_time from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time < @In_Time  and IO_Tran_Id <> @IO_Tran_Id )  
				 BEGIN  
					  if exists(select Out_time from T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID= @emp_ID and In_time =  
					  (select max(In_time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and In_time < @In_Time  and IO_Tran_Id <> @IO_Tran_Id ) and Out_Time > @In_Time and IO_Tran_Id <> @IO_Tran_Id)  
					   BEGIN  
							SET @IO_Tran_Id=0
							IF @IsDefault = 0
								RAISERROR('Record already exists,please check In/Out Time',16,2) 
							RETURN  
					   END  
				 END
			else if isnull(@Out_Time,'') <>''  
				 BEGIN  
					  if exists(select Emp_ID from T0150_emp_inout_record WITH (NOLOCK) where Emp_ID=@Emp_ID and In_Time >=@In_Time and In_Time <@Out_time and IO_Tran_Id <> @IO_Tran_Id)  
					   BEGIN  
						set @IO_Tran_Id=0 
					    IF @IsDefault = 0
							RAISERROR('Record already exists,please check In/Out Time',16,2) 
						RETURN  
					   END  
				 END  
		   
									-- Added for audit trail By Ali 09102013 -- Start
			SELECT @Old_Emp_ID = Emp_ID, @Old_Cmp_ID =Cmp_ID, @Old_For_Date = For_Date
			, @Old_In_Time= In_Time, @Old_Out_Time= Out_Time,  @Old_Duration = Duration
			, @Old_Reason=Reason, @Old_Ip_Address=Ip_Address, @Old_Sup_Comment=Sup_Comment
			FROM   T0150_EMP_INOUT_RECORD WITH (NOLOCK)
			WHERE  IO_Tran_Id = @IO_Tran_Id									
			select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @old_Emp_ID
							
							--if @Old_In_Time = @In_Time and @old_Out_Time=@Out_Time
							--	Begin
							--		set @ManualEntryFlag='N'									
							--	End
							--Else if @Old_In_Time = @In_Time and @old_Out_Time <> @Out_Time
							--	Begin
							--			if (convert(varchar(11),@old_Out_Time,103) = CONVERT(varchar(11),@Out_Time,103))
							--				Begin
							--					set @ManualEntryFlag='Out' --Flag Change for Only Out time
							--				End
							--			Else if (convert(varchar(5),@old_Out_Time,108) = CONVERT(varchar(5),@Out_Time,108))
							--				Begin
							--					set @ManualEntryFlag='OD' ----Flag Change for Only Out Date
							--				End	
							--			else	
							--				Begin 
							--					set @ManualEntryFlag='ODB' ----Flag Change for Only Out Date and  Ou time both
							--				End
							--	End
							--Else if @Old_In_Time <> @In_Time and @old_Out_Time=@Out_Time
							--	Begin
								
							--			if (convert(varchar(11),@Old_In_Time,103) = CONVERT(varchar(11),@In_Time,103))
							--				Begin
							--					set @ManualEntryFlag='IN' --Flag Change for Only In time
							--				End
							--			Else if (convert(varchar(5),@Old_In_Time,108) = CONVERT(varchar(5),@In_Time,108))
							--				Begin
							--					set @ManualEntryFlag='ID' ----Flag Change for Only In Date
							--				End	
							--			else	
							--				Begin 
							--					set @ManualEntryFlag='IDB' ----Flag Change for Only In Date and  In time both
							--				End
									
							--	End
							--Else if @Old_In_Time <> @In_Time and @old_Out_Time <> @Out_Time
							--	Begin
									
							--			if (convert(varchar(11),@Old_In_Time,103) = CONVERT(varchar(11),@In_Time,103)) and (convert(varchar(11),@old_Out_Time,103) = CONVERT(varchar(11),@Out_Time,103))
							--				Begin
							--					set @ManualEntryFlag='IO' --Flag Change for In time and Out time
							--				End
							--			Else if (convert(varchar(11),@Old_In_Time,103) = CONVERT(varchar(11),@In_Time,103)) and  (convert(varchar(5),@old_Out_Time,108) = CONVERT(varchar(5),@Out_Time,108))
							--				Begin
							--					set @ManualEntryFlag='ITO' ----Flag Change for Only In Time and Out Date 
							--				End
							--			else	
							--				Begin 
							--					set @ManualEntryFlag='IOD' ----Flag Change for Only In Date and  In time both
							--				End
									
									
							--	End		
							 
							set @OldValue = 'old Value # Emp Name :' + @old_Emp_Name 
											+ ' # Emp Id :' + cast(@Old_Emp_ID as nvarchar(10)) 
											+ ' # Cmp id : ' + cast(@Old_Cmp_ID as nvarchar(10)) 
											+ ' # For Date : ' + cast(@Old_For_Date as nvarchar(25))  
											+ ' # In Time : ' + cast(@Old_In_Time as nvarchar(25)) 
											+ ' # Out Time : ' + cast(@Old_Out_Time  as nvarchar(25)) 
											+ ' # Duration : ' + cast(@Old_Duration  as nvarchar(10)) 
											+ ' # Reason : ' + ISNULL(@Old_Reason,'')
											+ ' # IP Address : ' + ISNULL(@Old_Ip_Address,'')
											+ ' # New Value # Emp Name :' + @old_Emp_Name 
											+ ' # Emp Id :' + cast(@Old_Emp_ID as nvarchar(10)) 
											+ ' # Cmp id : ' + cast(@Old_Cmp_ID as nvarchar(10)) 
											+ ' # For Date : ' + cast(@For_Date as nvarchar(25))  
											+ ' # In Time : ' + cast(@In_Time as nvarchar(25)) 
											+ ' # Out Time : ' + cast(@Out_Time as nvarchar(25))  
											+ ' # Duration : ' + cast(@Duration  as nvarchar(10)) 
											+ ' # Reason : ' + ISNULL(@Reason ,'')
											+ ' # IP Address : ' + ISNULL(@Old_Ip_Address,'')
							-- Added for audit trail By Ali 09102013 -- End
						
   --Modified By Ramiz on 07/10/2015
     	If @Is_default_cancel_Early_out = 0
		   Begin
		 
			  Update T0150_EMP_INOUT_RECORD   
			  Set  Out_Time = @Out_Time,  
				In_Time=@In_Time,  
				Duration = @Duration,  
				Reason = @Reason ,  
				Skip_Count = @Skip_Count,  
				Late_Calc_Not_app = @Is_Cancel_Late_In,
				System_Date = @System_Date,
				ManualEntryFlag=@ManualEntryFlag
			  where IO_Tran_Id= @IO_Tran_Id 
			  End
		Else
			Begin
	
				Update T0150_EMP_INOUT_RECORD   
			  Set  Out_Time = @Out_Time,  
				In_Time=@In_Time,  
				Duration = @Duration,  
				Reason = @Reason ,  
				Skip_Count = @Skip_Count,  
				Is_Cancel_Late_In = @Is_Cancel_Late_In,
				Is_Cancel_Early_Out = @Is_Cancel_Early_Out,
				System_Date = @System_Date,
				ManualEntryFlag=@ManualEntryFlag
			  where IO_Tran_Id= @IO_Tran_Id 
			End 
    end   
 else if @tran_type ='D'   
   begin  
       --Added by Mihir 12122011 for check salary reference exist condition
       declare @Io_for_date as Datetime
       select @Io_for_date = For_Date,@Emp_ID=Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where IO_Tran_Id= @IO_Tran_Id

		IF EXISTS(SELECT 1 FROM T0180_LOCKED_ATTENDANCE WITH (NOLOCK) WHERE FROM_DATE <= @Io_for_date AND case when cutoff_date ='1900-01-01 00:00:00' then To_date else cutoff_date end >= @Io_for_date AND EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID)
		   BEGIN
				SET @IO_TRAN_ID=0
				RAISERROR('Attendance Lock - Insert',16,2)
				RETURN  
		   END

       
	   if Exists(select 1 from T0160_Attendance_Application WITH (NOLOCK) where For_Date = DATEADD(DAY,1,@Io_for_date) and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_Id)
		   Begin
				set @IO_Tran_Id=0
				RAISERROR('Attendance Application is exists so you can not deleted it.',16,2)
				Return  
		   End	


		    --Added by ronakk 22112022
	   if exists ( select 1 from V0250_MONTHLY_LOCK_INFORMATION where Cmp_ID=@Cmp_Id and Month=month(@Io_for_date) and year = Year(@Io_for_date))
	   Begin
				Declare @Islock int =0
				declare @BranchLockID int

			    select @Islock= Is_Lock, @BranchLockID =Branch_ID from V0250_MONTHLY_LOCK_INFORMATION where Cmp_ID=@Cmp_Id and Month=month(@Io_for_date) and year = Year(@Io_for_date)

			    if @BranchLockID <> 0
				Begin
				  declare @EBID int 
				  select @EBID=  branch_id from V0080_EMP_MASTER_INCREMENT_GET where Emp_ID = @Emp_ID

				  if @EBID = @BranchLockID and @Islock=1
				  Begin
						RAISERROR('Month Lock Exists',16,2)
						RETURN  
				  end				
				end
				else
				Begin
				 if @BranchLockID = 0 and @Islock=1
				 Begin
				 
						RAISERROR('Month Lock Exists',16,2)
						RETURN  
				 End
				end

				   --RAISERROR('Month Lock Exists',16,2)
	   --RETURN  

	   end


       if Not exists(select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date<= @Io_for_date And isnull(cutoff_date,Month_End_Date)>= @Io_for_date and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_Id)
	       begin
	       
								-- Added for audit trail By Ali 09102013 -- Start
								SELECT @Old_Emp_ID = Emp_ID, @Old_Cmp_ID =Cmp_ID, @Old_For_Date = For_Date
								, @Old_In_Time= In_Time, @Old_Out_Time= Out_Time,  @Old_Duration = Duration
								, @Old_Reason=Reason, @Old_Ip_Address=Ip_Address, @Old_Sup_Comment=Sup_Comment
								FROM   T0150_EMP_INOUT_RECORD WITH (NOLOCK)
								WHERE  IO_Tran_Id = @IO_Tran_Id
								select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @old_Emp_ID
								
								set @OldValue = 'old Value # Emp Name :'  + @old_Emp_Name 
										+ ' # Emp Id :' + cast(@Old_Emp_ID as nvarchar(10)) 
										+ ' # Cmp id : ' + cast(@Old_Cmp_ID as nvarchar(10)) 
										+ ' # For Date : ' + cast(@Old_For_Date as nvarchar(25)) 
										+ ' # In Time : ' + cast(@Old_In_Time as nvarchar(25)) 
										+ ' # Out Time : ' + cast(@Old_Out_Time  as nvarchar(25)) 
										+ ' # Duration : ' + cast(@Old_Duration  as nvarchar(10)) 
										+ ' # Reason : ' + ISNULL(@Old_Reason ,'')
										+ ' # IP Address : ' + ISNULL(@Old_Ip_Address,'')
								-- Added for audit trail By Ali 09102013 -- End
				Delete from T0150_EMP_INOUT_RECORD  where IO_Tran_Id= @IO_Tran_Id
	       end
       else
	       begin
				Set @IO_Tran_Id = 0
				RAISERROR('salary Exist - delete',16,2)
				RETURN 
		   END
	   --End of Added by Mihir 12122011 for check salary reference exist condition
       
   end  
     
     IF @IsDefault = 1
     BEGIN
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'EMP DEFAULT IN OUT',@OldValue,@Emp_ID,@User_Id,@UIP_Address,1
     END
     ELSE
     BEGIN
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'EMPlOYEE IN OUT',@OldValue,@Emp_ID,@User_Id,@UIP_Address,1
     END
     
   
 RETURN  
  
  


