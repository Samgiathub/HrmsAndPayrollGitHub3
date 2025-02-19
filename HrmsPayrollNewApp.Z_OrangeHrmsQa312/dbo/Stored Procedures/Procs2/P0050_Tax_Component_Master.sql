

-- Created By Sumit 
--Created Date 07012016
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Tax_Component_Master]	 
	  @Tran_Id numeric(18,0) output
	 ,@Tax_Component_Name varchar(255)
	 ,@Cmp_ID numeric(18,0)
	 ,@Remarks varchar(max)=''
	 ,@tran_type char
	 ,@User_Id numeric(18,0) = 0 
	 ,@Tax_Per numeric(18,2)
     ,@IP_Address varchar(30)= '' 
     
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

declare @OldValue as  varchar(max)
Declare @String as varchar(max)
set @String=''
set @OldValue =''
------
	if Upper(@tran_type) ='I' 
		begin
		
			if exists (Select Tran_ID  from T0050_Travel_Tax_Component_Master WITH (NOLOCK) Where Upper(Tax_Cmponent_Name) = Upper(@Tax_Component_Name) and Cmp_ID = @Cmp_ID) 
				begin
					set @Tran_Id=0
					RETURN 
				end
					select @Tran_Id=isnull(MAX(Tran_ID),0)+1 from T0050_Travel_Tax_Component_Master WITH (NOLOCK)
						
						
					insert into T0050_Travel_Tax_Component_Master(Tran_ID,Cmp_Id,Tax_Cmponent_Name,Tax_Per,Remarks,Modify_date)
					values(@Tran_Id,@Cmp_Id,@Tax_Component_Name,@Tax_Per,@Remarks,GETDATE())
					
					
					Select @Tran_Id = Tran_ID  from T0050_Travel_Tax_Component_Master WITH (NOLOCK) Where Upper(Tax_Cmponent_Name) = Upper(@Tax_Component_Name) and Cmp_ID = @Cmp_ID
					
					exec P9999_Audit_get @table = 'T0050_Travel_Tax_Component_Master' ,@key_column='Tran_ID',@key_Values=@Tran_Id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
					--

		end 
	else if upper(@tran_type) ='U' 
		begin
		
		if exists (Select Tran_ID  from T0050_Travel_Tax_Component_Master WITH (NOLOCK) Where Upper(Tax_Cmponent_Name) = Upper(@Tax_Component_Name) and Cmp_ID = @Cmp_ID and  Tran_ID <> @Tran_Id) 
				begin
					set @Tran_Id=0
					RETURN 
				end
			   
			   	exec P9999_Audit_get @table='T0050_Travel_Tax_Component_Master' ,@key_column='Tran_ID',@key_Values=@Tran_Id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    
				Update T0050_Travel_Tax_Component_Master 
				Set Tax_Cmponent_Name = @Tax_Component_Name,
				Tax_Per=@Tax_Per,
				Remarks = @Remarks,
				modify_date=getdate()
				where Tran_ID = @Tran_Id
				
				exec P9999_Audit_get @table = 'T0050_Travel_Tax_Component_Master' ,@key_column='Tran_ID',@key_Values=@Tran_Id,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			   	
			
		end	
	else if upper(@tran_type) ='D'
		begin
				if Exists(select Tax_Components from T0140_Travel_Vendor_Expense_Request WITH (NOLOCK) where Cmp_ID=@CMP_ID and Tax_Components=@Tran_Id)
					begin
						RAISERROR('@@ Reference Exists @@',16,2)
						RETURN	
					end
				exec P9999_Audit_get @table='T0050_Travel_Tax_Component_Master' ,@key_column='Tran_ID',@key_Values=@Tran_Id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    		
			     delete  from T0050_Travel_Tax_Component_Master where Tran_ID=@Tran_Id
					
			end
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Tax Component Master',@OldValue,@Tran_Id,@User_Id,@IP_Address
		
	RETURN




