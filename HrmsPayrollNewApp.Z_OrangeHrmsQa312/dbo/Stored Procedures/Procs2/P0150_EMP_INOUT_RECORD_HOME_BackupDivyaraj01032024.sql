

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_EMP_INOUT_RECORD_HOME_BackupDivyaraj01032024]  
	  @IO_Tran_Id numeric(18)   output  
     ,@Emp_ID   numeric(18)    
     ,@Cmp_Id   numeric(18)      
     ,@For_Date   datetime    
     ,@Reason   varchar(500)    
     ,@Half_Full_Day Varchar(20)
     ,@Ip_Address  varchar(50)   
     ,@Is_Cancel_Late_In tinyint
     ,@Is_Cancel_Early_Out tinyint 
     ,@In_Date_Time datetime
     ,@Out_Date_Time datetime
     ,@Is_Approve tinyint = 0
     ,@Other_Reason varchar(max) = ''
AS    
 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 declare @In_time As DateTime
 declare @Min_IO_Tran_Id numeric(18)
 declare @Max_IO_Tran_Id numeric(18)
 declare @First_In_Last_Out_For_Att_Regularization tinyint
  
 if @Is_Cancel_Late_In is null
	set @Is_Cancel_Late_In = 0
	
if @Is_Cancel_Early_Out is null
	set @Is_Cancel_Early_Out = 0

	Declare @CycStartDate date	= NULL
	Declare @CycEndDate date  = NULL
	
	--if Exists(select 1 from T0180_LOCKED_ATTENDANCE where emp_id = @Emp_ID and Cmp_Id = @Cmp_Id and [Month] = Month(@For_Date) and [Year] = Year(@For_Date))
	--Begin 
	--	select @CycStartDate = From_Date , @CycEndDate = To_Date 
	--	from T0180_LOCKED_ATTENDANCE 
	--	where emp_id = @Emp_ID and Cmp_Id = @Cmp_Id and [Month] = Month(@For_Date) and [Year] = Year(@For_Date)
	--END
	--ELSe
	--BEGin
	--	select @CycStartDate = From_Date , @CycEndDate = To_Date 
	--	from T0180_LOCKED_ATTENDANCE 
	--	where emp_id = @Emp_ID and Cmp_Id = @Cmp_Id and [Month] = Month(@For_Date) + 1  and [Year] = Year(@For_Date)
	--END
	
	if Exists(select 1 from T0180_LOCKED_ATTENDANCE where emp_id = @Emp_ID and Cmp_Id = @Cmp_Id and @For_Date  between cast(From_date as date) and cast(TO_DATE as date))
	Begin 
		SELECT @CycStartDate = From_Date , @CycEndDate = To_Date 
		FROM T0180_LOCKED_ATTENDANCE 
		WHERE emp_id = @Emp_ID and Cmp_Id = @Cmp_Id and @For_Date  between cast(From_date as date) and cast(TO_DATE as date)
	END
	ELSe
	BEGin
		SELECT @CycStartDate = From_Date , @CycEndDate = To_Date 
		FROM T0180_LOCKED_ATTENDANCE 
		WHERE emp_id = @Emp_ID and Cmp_Id = @Cmp_Id and @For_Date  between cast(From_date as date) and cast(TO_DATE as date)
	END

	
	IF Exists(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
									T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN							  
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
									T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@For_Date))
									AND [MONTH] = MONTH(EOMONTH(@For_Date))
		WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @Emp_ID)
	BEGIN
			--if day(@CycStartDate) >= day(cast(@For_Date as date)) and day(@CycEndDate) <= day(cast(@For_Date as date))
			if @For_Date  between cast(@CycStartDate as date) and cast(@CycEndDate as date)
			Begin
					Raiserror('@@ Attendance Month Lock @@',16,2)
					return -1								
			END
	END 
	ELSE
	BEGIN
			if @For_Date  between cast(@CycStartDate as date) and cast(@CycEndDate as date)
			Begin
					Raiserror('@@ Attendance Month Lock @@',16,2)
					return -1								
			END
	END



	--if ((SELECT count(1) FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
	--								T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN							  
	--								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
	--								T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@For_Date))
	--								AND [MONTH] = MONTH(EOMONTH(@For_Date))
	--	WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @Emp_ID) > 0)
	--BEGIN	
		
	--		if day(@CycStartDate) >= day(cast(@For_Date as date)) and day(@CycEndDate) <= day(cast(@For_Date as date))
	--		Begin
	--				Raiserror('@@ Attendance Month Lock @@',16,2)
	--				return -1								
	--		END
	--END

	
	if exists(select IO_Tran_Id from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where cmp_id=@cmp_id and emp_id=@emp_id and for_date=@for_date)
	 begin
		
		--if @First_In_Last_Out_For_Att_Regularization = 0
		--	begin
			
		--		update T0150_EMP_INOUT_RECORD Set 
		--			 reason=@Reason 
		--			,Half_Full_day=@Half_Full_Day
		--			,Is_Cancel_Late_In=@Is_Cancel_Late_In
		--			,Is_Cancel_Early_Out=@Is_Cancel_Early_Out
		--			,In_Date_Time=@In_Date_Time
		--			,Out_Date_Time=@Out_Date_Time 
		--		where IO_Tran_Id = @IO_Tran_Id		
		--	end
		--else
		--	begin
		Select @Min_IO_Tran_Id=Min(IO_tran_Id), @Max_IO_Tran_Id=Max(IO_Tran_Id) From T0150_emp_Inout_record WITH (NOLOCK)
		Where emp_Id=@Emp_Id And cmp_Id=@Cmp_ID and for_date=@for_date	group by for_date		 	
		set @IO_Tran_Id = @Min_IO_Tran_Id
				

		update T0150_EMP_INOUT_RECORD Set reason= @Reason,Other_Reason=@Other_Reason ,Half_Full_day=@Half_Full_Day,Is_Cancel_Late_In=@Is_Cancel_Late_In where IO_Tran_Id = @Min_IO_Tran_Id		
		update T0150_EMP_INOUT_RECORD Set Is_Cancel_Early_Out=@Is_Cancel_Early_Out where IO_Tran_Id = @Max_IO_Tran_Id		
		update T0150_EMP_INOUT_RECORD set App_Date = GETDATE() where cmp_id=@cmp_id and emp_id=@emp_id and for_date=@for_date and App_Date is null	-- Added By Gadriwala 21022013		          
		
		if @Is_Approve = 1 
			Begin
				--update T0150_EMP_INOUT_RECORD set App_Date = GETDATE(),Sup_Comment='From Approve All',Apr_Date = GETDATE(),Chk_By_Superior = 1,In_Time=@In_Date_Time,Out_Time=@Out_Date_Time where cmp_id=@cmp_id and emp_id=@emp_id and for_date=@for_date and IO_Tran_Id = @Max_IO_Tran_Id		-- Added By Gadriwala 21022013		          
				update T0150_EMP_INOUT_RECORD set Sup_Comment='From Approve All',Apr_Date = GETDATE(),Chk_By_Superior = 1 where cmp_id=@cmp_id and emp_id=@emp_id and for_date=@for_date and IO_Tran_Id = @Max_IO_Tran_Id		-- Added By Gadriwala 21022013		          
				exec UPDATE_EMP_INOUT_RECORD @IO_Tran_Id,@Emp_ID,@Cmp_ID,'','Appr',@Is_Cancel_Late_In,@Is_Cancel_Early_Out,@Half_Full_Day,@In_Date_Time,@Out_Date_Time
			End 
		Else
			Begin
				Update dbo.T0150_EMP_INOUT_RECORD set Chk_By_Superior = 0, In_Date_Time = @In_Date_Time, Out_Date_Time = @Out_Date_Time
				Where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date
			End 
			--end	
			---
			--Update dbo.T0150_EMP_INOUT_RECORD set		
			--	Chk_By_Superior = 0
			--Where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date	
	 end
	else
	 begin
	
		 Select @IO_Tran_Id= isnull(max(IO_Tran_Id),0) + 1  from T0150_EMP_INOUT_RECORD WITH (NOLOCK)    
		 
     -- Added App_Date by Gadriwala 28012014
		 Insert Into T0150_EMP_INOUT_RECORD
		 (IO_Tran_Id
		  ,Emp_ID
		  ,Cmp_ID
		  ,For_Date
		  ,Reason
		  ,Half_Full_Day
		  ,Ip_Address
		  ,Is_Cancel_Late_In
		  ,Is_Cancel_Early_Out
		  ,Chk_By_Superior
		  ,App_Date
		  ,In_Date_Time
		  ,Out_Date_Time
		  ,Sup_Comment
		  ,Apr_Date
		  ,Other_Reason
		  ,ManualEntryFlag --Mukti(07092016)
		  )    
         values
         (@IO_Tran_Id
          ,@Emp_ID
          ,@Cmp_ID
          ,@For_Date
          ,@Reason
          ,@Half_Full_Day
          ,@Ip_Address
          ,@Is_Cancel_Late_In
          ,@Is_Cancel_Early_Out
          ,(case when @Is_Approve = 1 then 1 else 0 end) -- Added by Nilesh patel on 22062015 -For Approve 
          ,GETDATE()
          ,@In_Date_Time
          ,@Out_Date_Time
          ,(case when @Is_Approve = 1 then 'From Approve All' else NULL end) -- Added by Nilesh patel on 22062015 -For Approve
		  ,(case when @Is_Approve = 1 then GETDATE() else NULL end) -- Added by Nilesh patel on 22062015 -For Approve
		  ,@Other_Reason
		  ,'Abs' --Mukti(07092016)to enter new entry for Attendance Regularization
          )    
          
          If (@Is_Approve = 1)
          BEGIN
			--Update dbo.T0150_EMP_INOUT_RECORD SET In_Time=@In_Date_Time, Out_Time=@Out_Date_Time Where Cmp_ID=@Cmp_Id AND IO_Tran_Id=@IO_Tran_Id
			exec UPDATE_EMP_INOUT_RECORD @IO_Tran_Id,@Emp_ID,@Cmp_ID,'','Appr',@Is_Cancel_Late_In,@Is_Cancel_Early_Out,@Half_Full_Day,@In_Date_Time,@Out_Date_Time
          END
     end
 RETURN    
    
    
    

