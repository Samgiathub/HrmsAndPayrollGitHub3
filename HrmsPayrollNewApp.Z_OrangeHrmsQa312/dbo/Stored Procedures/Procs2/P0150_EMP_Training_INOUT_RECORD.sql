

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0150_EMP_Training_INOUT_RECORD]
	   @Tran_Id					numeric(18) output   
      ,@cmp_Id					numeric(18)    
      ,@emp_id					numeric(18)  
      ,@For_date				datetime
      ,@Out_Time				varchar(25)
      ,@In_Time					varchar(25)
      ,@Hours					varchar(25)
      ,@Trans_Type				char(1) 
      ,@Training_Apr_id			numeric(18,0) = null         --added on 3 aug 2015
      ,@User_Id numeric(18,0) = 0 -- added By Mukti 19082015
      ,@IP_Address varchar(30)= '' -- added By Mukti 19082015
AS


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


--Added By Mukti 19082015(start)
	declare @OldValue as varchar(max)
	declare @Oldemp_id	        varchar(25)
    declare @OldFor_date        varchar(25)
    declare @OldOut_Time        varchar(25)
    declare @OldIn_Time         varchar(25)
    declare @OldHours	        varchar(25)
    declare @OldTraining_Apr_id varchar(25)
--Added By Mukti 19082015(end)
BEGIN
	 set nocount on     

 IF @Out_Time = ''    
  SET @Out_Time  = NULL    
 
 IF @In_Time = ''    
  SET @In_Time  = NULL 
  
  if @Training_Apr_id = 0
	set @Training_Apr_id = NULL  --added on 3 aug 2015
  
  if @Hours=''
	if @In_Time is not null and @Out_Time is not null
		begin
			set @Hours= dbo.F_Return_Hours (datediff(s,@In_Time,@Out_Time)) 
		End
	Else
		set @Hours = null
  
   set @For_Date = cast(cast(@For_Date as varchar(11)) as smalldatetime)    
   If @Trans_Type ='I'     
	begin
		 If exists (Select Tran_Id  from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and For_Date=  @For_Date and In_Time = @In_Time)   
			begin			
				set @Tran_Id=0    
				return    
			end  
		  Select @Tran_Id= isnull(max(Tran_Id),0) + 1  from dbo.T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
		 	 --print @Tran_Id 
		  insert into T0150_EMP_Training_INOUT_RECORD (Tran_Id,cmp_Id,emp_id,For_date,Out_Time,In_Time,Hours,Training_Apr_id,IP_Address)   
		  Values(@Tran_Id,@cmp_Id,@emp_id,@For_date,@For_date+' '+@Out_Time,@For_date+' '+ @In_Time,@Hours,@Training_Apr_id,'') --added on 3 aug 2015
		  
	--Added By Mukti 19082015(start)
			    set @OldValue = 'New Value' + '#'+ 'Employee Id:' + cast(Isnull(@emp_id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'For Date:' + cast(Isnull(@For_date,'') as varchar(30)) + '#' + 
													'In Time:' + cast(Isnull(@In_Time,'') as varchar(25)) + '#' + 
													'Out Time:' + cast(Isnull(@Out_Time,'') as varchar(25)) + '#' + 
													'Hours:' + cast(Isnull(@Hours,'') as varchar(25)) + '#' + 
													'Training Apr id:' + cast(Isnull(@Training_Apr_id,0) as varchar(25)) 
	--Added By Mukti 19082015(end)
	return @Tran_Id	
	end
else if @Trans_Type ='U' 
	begin
		If Exists(Select 1 From dbo.T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) Where Emp_ID = @Emp_ID and For_Date=  @For_Date and Tran_Id = @Tran_Id)      
		Begin
		--Added By Mukti 19082015(start)
			select @OldHours = Hours,
			    @OldIn_Time = In_Time,
			    @OldOut_Time = Out_Time,
			    @OldTraining_Apr_id = Training_Apr_id 
			from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
			where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id   
		--Added By Mukti 19082015(end)

			Update dbo.T0150_EMP_Training_INOUT_RECORD     
			Set	[Hours] = @Hours,
			    In_Time = @for_date +' '+ @In_Time,
			    Out_Time = @for_date +' '+ @Out_Time,
			    Training_Apr_id = @Training_Apr_id ---added on 3 aug 2015
			where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id   
					
			 If Exists(select 1 from Dbo.T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where emp_id = @Emp_ID and For_date = @For_Date and Tran_Id = @Tran_Id and Out_Time is null)
				begin
					Declare @In_Date_Time as datetime
					Declare @Out_Date_Time as datetime
					
					select @In_Date_Time = In_Time from Dbo.T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
					where emp_id = @Emp_ID and For_date = @For_Date and Tran_Id = @Tran_Id 
					
					set @Out_Date_Time	= @In_Date_Time
					Set	@Out_Date_Time = DATEADD(s,dbo.F_Return_Sec(@Hours),@Out_Date_Time)	
				
					Update dbo.T0150_EMP_Training_INOUT_RECORD     
					Set	Out_Time = @for_date +' '+ cast(@Out_Date_Time as varchar(25))					
					where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id    
				end
		End
		--Added By Mukti 19082015(start)
			    set @OldValue = 'Old Value' + '#'+ 'Employee Id:' + cast(Isnull(@emp_id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'For Date:' + cast(Isnull(@For_date,'') as varchar(30)) + '#' + 
													'In Time:' + cast(Isnull(@OldIn_Time,'') as varchar(25)) + '#' + 
													'Out Time:' + cast(Isnull(@OldOut_Time,'') as varchar(25)) + '#' + 
													'Hours:' + cast(Isnull(@OldHours,'') as varchar(25)) + '#' + 
													'Training Apr id:' + cast(Isnull(@Training_Apr_id,0) as varchar(25)) + '#' + 
								'New Value' + '#'+ 'Employee Id:' + cast(Isnull(@emp_id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'For Date:' + cast(Isnull(@For_date,'') as varchar(30)) + '#' + 
													'In Time:' + cast(Isnull(@In_Time,'') as varchar(25)) + '#' + 
													'Out Time:' + cast(Isnull(@Out_Time,'') as varchar(25)) + '#' + 
													'Hours:' + cast(Isnull(@Hours,'') as varchar(25)) + '#' + 
													'Training Apr id:' + cast(Isnull(@Training_Apr_id,0) as varchar(25)) 
		--Added By Mukti 19082015(end)	
	end
else if @Trans_Type = 'D'  
	begin
	--Added By Mukti 19082015(start)
			select @OldHours = Hours,
			    @OldIn_Time =  In_Time,
			    @OldOut_Time = Out_Time,
			    @OldTraining_Apr_id = Training_Apr_id 
			from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
			where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id   
	--Added By Mukti 19082015(end)
	
		Update dbo.T0150_EMP_Training_INOUT_RECORD     
		Set	 Out_Time = null
		where Emp_ID= @Emp_ID and Tran_Id = @Tran_Id	

	 --Added By Mukti 19082015(start)
			    set @OldValue = 'Old Value' + '#'+ 'Employee Id:' + cast(Isnull(@emp_id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'For Date:' + cast(Isnull(@For_date,'') as varchar(30)) + '#' + 
													'In Time:' + cast(Isnull(@OldIn_Time,'') as varchar(25)) + '#' + 
													'Out Time:' + cast(Isnull(@OldOut_Time,'') as varchar(25)) + '#' + 
													'Hours:' + cast(Isnull(@OldHours,'') as varchar(25)) + '#' + 
													'Training Apr id:' + cast(Isnull(@OldTraining_Apr_id,0) as varchar(25)) 
	--Added By Mukti 19082015(end)	
	end
	exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training In-Out Record',@OldValue,@Tran_Id,@User_Id,@IP_Address
	
	
END
return @Tran_Id
