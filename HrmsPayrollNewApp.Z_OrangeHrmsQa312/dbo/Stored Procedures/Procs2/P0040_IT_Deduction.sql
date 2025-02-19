
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_IT_Deduction]	
	@IT_Tran_ID numeric(18,0) output,
	@Cmp_ID numeric(18,2),
	@IT_name  varchar(100),
	@Max_Limit numeric(18,2),
	@tran_type char(1),
	@User_Id numeric(18,0) = 0, -- Add By Mukti 20072016
	@IP_Address varchar(30)= '' -- Add By Mukti 20072016

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 -- Add By Mukti 20072016(start)
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
 -- Add By Mukti 20072016(end)	
	
	if @tran_type ='I'
	  Begin 
	  
	    if exists (Select @IT_Tran_ID from T0040_IT_Deduction WITH (NOLOCK) where cmp_ID=@Cmp_ID and IT_name=@IT_Name)
	      Begin
	           set @IT_Tran_ID =0
	           return -1
	      End
	  
	     select @IT_Tran_ID = isnull(max(IT_Tran_ID),0) + 1  from T0040_IT_Deduction WITH (NOLOCK)	
	      
	      Insert into T0040_IT_Deduction(IT_tran_ID,IT_name,Cmp_ID,Max_Limit)
	       values(@IT_tran_ID,@IT_name,@Cmp_ID,@Max_Limit)
	      
	    -- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table = 'T0040_IT_Deduction' ,@key_column='IT_tran_ID',@key_Values=@IT_tran_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 20072016(end)	
	  
	  End
Else if @tran_type ='U'
	   Begin
			-- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table='T0040_IT_Deduction' ,@key_column='IT_tran_ID',@key_Values=@IT_tran_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 20072016(end)
	   
	      Update T0040_IT_Deduction 
	        set  IT_Tran_ID =@IT_tran_ID,
	             IT_Name =@IT_name,
	             Cmp_ID =@Cmp_ID,
	             Max_Limit = @Max_Limit
	      where  IT_Tran_ID =@IT_tran_ID    
	   
			 -- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table = 'T0040_IT_Deduction' ,@key_column='IT_tran_ID',@key_Values=@IT_tran_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
			 -- Add By Mukti 20072016(end)
	   End
Else if @tran_type ='D'
	   Begin 
			-- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table='T0040_IT_Deduction' ,@key_column='IT_tran_ID',@key_Values=@IT_tran_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 20072016(end)
	      delete from T0040_IT_Deduction where IT_Tran_ID =@IT_tran_ID
	   End	   
	   exec P9999_Audit_Trail @CMP_ID,@tran_type,'IT Deduction',@OldValue,@IT_Tran_ID,@User_Id,@IP_Address	
RETURN




