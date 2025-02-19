
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_EMP_GATE_PASS_INOUT_RECORD]    
	  @Tran_Id	   numeric(18) output    
     ,@Emp_ID	   numeric(18)    
     ,@Cmp_Id	   numeric(18)      
     ,@For_Date    datetime    
     ,@In_Time     varchar(25)    
     ,@Out_Time    varchar(25)    
     ,@Hours	   varchar(25)    
     ,@Reason_id   numeric(18,0)
     ,@Exempted	   tinyint    
     ,@Is_Approved tinyint
     ,@Is_Default tinyint
     ,@Shift_St_Time varchar(10)
     ,@Shift_End_Time varchar(10)
     ,@tran_type   char(1)      
     ,@App_ID		Numeric = 0 --Ankit 28052016   
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    

 IF @Out_Time = ''    
  SET @Out_Time  = NULL    
 
 IF @In_Time = ''    
  SET @In_Time  = NULL 
      
         
 DECLARE @In_Datetime DATETIME
 DECLARE @Out_Datetime DATETIME
 
 set @For_Date = cast(cast(@For_Date as varchar(11)) as smalldatetime)    
   
  
	If @tran_type ='I'     
		begin    
			SET @Out_Datetime  = convert(datetime, convert(varchar(10), @For_Date, 102) + ' '  + convert(varchar(8), @Out_Time, 114), 102)
			SET @In_Datetime  = convert(datetime, convert(varchar(10), @For_Date, 102) + ' '  + convert(varchar(8), @In_time, 114), 102)
			
			If exists (Select Tran_Id  from dbo.T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and For_Date=  @For_Date and Out_Time = @Out_Datetime)  --Change by Jaina 25-10-2017     
				begin    
					set @Tran_Id=0    
					return    
				end
	     

			 --SET @Out_Datetime =  CAST(@For_Date AS DATE) + CAST( @Out_Time AS TIME) 
			 --SET @In_Datetime =  CAST(@For_Date AS DATE) + CAST( @In_time AS TIME)
			 SET @Hours = RIGHT('0' + CAST( DATEDIFF(MINUTE ,@Out_Datetime ,@In_Datetime)/60 AS VARCHAR(5)), 2) + ':'+ RIGHT('0' + CAST( DATEDIFF(MINUTE ,@Out_Datetime ,@In_Datetime)%60 AS VARCHAR(2)), 2) 
		      
			 Select @Tran_Id= isnull(max(Tran_Id),0) + 1  from dbo.T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK)   
		         
			 --Insert Into dbo.T0150_EMP_Gate_Pass_INOUT_RECORD(Tran_Id,Emp_ID,Cmp_ID,For_Date,In_Time,Out_Time,Hours,Reason_id,Exempted,Is_Approved)    
			 --values(@Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@In_Time,@Out_Time,@Hours,@Reason_id,@Exempted,@Is_Approved)    
			
			 Insert Into dbo.T0150_EMP_Gate_Pass_INOUT_RECORD(Tran_Id,Emp_ID,Cmp_ID,For_Date,In_Time,Out_Time,Hours,Reason_id,Exempted,Is_Approved,IP_Address,App_ID,Shift_St_Time,Shift_End_Time)    
			 values(@Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@In_Datetime,@Out_Datetime,@Hours,@Reason_id,@Exempted,@Is_Approved,'100.100.100.100',@App_ID,@Shift_St_Time,@Shift_End_Time)
     		
			 UPDATE T0120_GATE_PASS_APPROVAL
			 SET Actual_Out_Time = @Out_Datetime,Actual_In_Time = @In_Datetime ,Actual_Duration = @Hours
			 WHERE App_ID = @App_ID and Emp_ID = @Emp_ID
		     
	   end    
       
  else if @tran_type ='U'     
   begin    

	--Added by Jaina 25-10-2017
	SET @Out_Datetime  = convert(datetime, convert(varchar(10), @For_Date, 102) + ' '  + convert(varchar(8), @Out_Time, 114), 102)
	
	--Commented By Ramiz n  18/12/2018 as in Update Sceneri , this entry wil definately exist.
	--If exists (Select Tran_Id  from dbo.T0150_EMP_Gate_Pass_INOUT_RECORD Where Emp_ID = @Emp_ID and For_Date=  @For_Date and Out_Time = @Out_Datetime)     
	--begin    
	--	set @Tran_Id=0    
	--	return    
	--end
	if exists (select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where  @For_date between Month_St_Date and Month_End_Date and Emp_Id = @Emp_ID)
				begin
					RAISERROR ('@@Cant Update Records, Salary Generated of this month@@', -- Message text.
									16, -- Severity.
									1   -- State.
									);
						RETURN
				end
	
    If Exists(Select 1 From dbo.T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and For_Date=  @For_Date and Tran_Id = @Tran_Id)      
     Begin    
			--SET @In_Datetime =  CAST(@For_Date AS DATETIME) + CAST( @In_time AS TIME)
			SET @In_Datetime  = convert(datetime, convert(varchar(10), @For_Date, 102) + ' '  + convert(varchar(8), @In_time, 114), 102)

		
		  Update dbo.T0150_EMP_Gate_Pass_INOUT_RECORD     
			Set		  
					 Reason_id = @Reason_id 
					,Exempted = @Exempted
					,Is_Approved = @Is_Approved
					,Shift_st_Time = @Shift_St_Time
					,Shift_End_Time = @Shift_End_Time
					,Is_Default = @Is_Default
					,Hours = RIGHT('0' + CAST( DATEDIFF(MINUTE ,Out_Time ,@In_Datetime)/60 AS VARCHAR(5)), 2) + ':'+ RIGHT('0' + CAST( DATEDIFF(MINUTE ,Out_Time ,@In_Datetime)%60 AS VARCHAR(2)), 2) --@Hours
					,Out_Time = @Out_Datetime  --Added by Jaina 27-10-2017
					,In_Time = @In_Datetime  --Added by Jaina 27-10-2017
					where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id    
		
		 If Exists(select 1 from Dbo.T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK) where emp_id = @Emp_ID and For_date = @For_Date and Tran_Id = @Tran_Id and In_Time is null)
			begin
					Declare @In_Date_Time as datetime
					Declare @Out_Date_Time as datetime
					
					select @Out_Date_Time = OUT_Time from Dbo.T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK)
					where emp_id = @Emp_ID and For_date = @For_Date and Tran_Id = @Tran_Id 
					
					set @In_Date_Time	= @Out_Date_Time
					Set	@In_Date_Time = DATEADD(s,dbo.F_Return_Sec(@Hours),@In_Date_Time)
				
					Update dbo.T0150_EMP_Gate_Pass_INOUT_RECORD     
					Set	In_Time =  cast(@In_Date_Time as varchar(25))					
					where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id    
					
				
			end
		
     End       
   end     
   else if @tran_type = 'D'  
	 begin
	 
			if exists (select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where  @For_date between Month_St_Date and Month_End_Date and Emp_Id = @Emp_ID)
				begin
					RAISERROR ('@@Cant delete Records, Salary Generated of this month@@', -- Message text.
									16, -- Severity.
									1   -- State.
									);
						RETURN
				end
			  	
			Update dbo.T0150_EMP_Gate_Pass_INOUT_RECORD     
					Set	Reason_id = 0, 
					    Exempted = 0, 
					    Is_Approved = 0,
					    Shift_St_Time = null,
					    Shift_End_Time = null
					where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id    
			
			Update dbo.T0150_EMP_Gate_Pass_INOUT_RECORD     
					Set	 In_Time = null,
						 Is_Default = 0
					where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id and Is_Default = 1		
	 end
    
 RETURN    
    
    
    

