

-- Created By rohit for Order Type master Entry
--Created Date 30122015
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_order_type_master]
	 
	  @Order_Type_Id numeric(18,0) output
	 ,@Order_Type_Name varchar(255)
	 ,@Cmp_ID numeric(18,0)
	 ,@Remarks varchar(max)=''
	 ,@tran_type char
	 ,@User_Id numeric(18,0) = 0 
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
		
			if exists (Select Order_Type_Id  from t0050_order_type_master WITH (NOLOCK) Where Upper(Order_Type_Name) = Upper(@Order_Type_Name) and Cmp_ID = @Cmp_ID) 
				begin
					set @Order_Type_Id=0
					RETURN 
				end
						
					insert into t0050_order_type_master(Cmp_Id,Order_Type_Name,Remarks)
					values(@Cmp_Id,@Order_Type_Name,@Remarks)
					
					
					Select @Order_Type_Id = Order_Type_Id  from t0050_order_type_master WITH (NOLOCK) Where Upper(Order_Type_Name) = Upper(@Order_Type_Name) and Cmp_ID = @Cmp_ID
					
					exec P9999_Audit_get @table = 't0050_order_type_master' ,@key_column='Order_Type_Id',@key_Values=@Order_Type_Id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
					--

		end 
	else if upper(@tran_type) ='U' 
		begin
		
		if exists (Select Order_Type_Id  from t0050_order_type_master WITH (NOLOCK) Where Upper(Order_Type_Name) = Upper(@Order_Type_Name) and Cmp_ID = @Cmp_ID and  Order_Type_Id <> @Order_Type_Id) 
				begin
					set @Order_Type_Id=0
					RETURN 
				end
			   
			   	exec P9999_Audit_get @table='t0050_order_type_master' ,@key_column='Order_Type_Id',@key_Values=@Order_Type_Id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    
				Update t0050_order_type_master 
				Set Order_Type_Name = @Order_Type_Name, 
				Remarks = @Remarks,modify_date=getdate()
				where Order_Type_Id = @Order_Type_Id
				
				exec P9999_Audit_get @table = 't0050_order_type_master' ,@key_column='Order_Type_Id',@key_Values=@Order_Type_Id,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			   	
			
		end	
	else if upper(@tran_type) ='D'
		begin
				if Exists(select Order_Type_ID from T0140_Travel_Vendor_Expense_Request WITH (NOLOCK) where Cmp_ID=@CMP_ID and Order_Type_ID=@Order_Type_Id)
					begin
						RAISERROR('@@ Reference Exists @@',16,2)
						RETURN	
					end
		
				exec P9999_Audit_get @table='t0050_order_type_master' ,@key_column='Order_Type_Id',@key_Values=@Order_Type_Id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    
				
			     delete  from t0050_order_type_master where Order_Type_Id=@Order_Type_Id
					
			end
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Order Type Master',@OldValue,@Order_Type_Id,@User_Id,@IP_Address
		
	RETURN




