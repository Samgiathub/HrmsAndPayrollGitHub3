

-- Created By rohit for project master Entry
--Created Date 30122015
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Project_Master_Payroll]
	 
	  @Tran_Id numeric(18,0) output
	 ,@Project_Name varchar(255)
	 ,@Cmp_ID numeric(18,0)
	 ,@Project_Manager_Id numeric(18,0)
	 ,@Customer_Name varchar(max)=''
	 ,@Site_Id varchar(max)=''
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
		
			if exists (Select Tran_Id  from T0050_Project_Master_Payroll WITH (NOLOCK) Where Upper(Project_Name) = Upper(@Project_Name) and Cmp_ID = @Cmp_ID) 
				begin
					set @Tran_Id=0
					RETURN 
				end
						
					insert into T0050_Project_Master_Payroll(Cmp_Id,Project_Name,Project_Manager_Id,Customer_Name,Site_Id,Remarks)
					values(@Cmp_Id,@Project_Name,@Project_Manager_Id,@Customer_Name,@Site_Id,@Remarks)
					
					
					Select @Tran_Id = Tran_Id  from T0050_Project_Master_Payroll WITH (NOLOCK) Where Upper(Project_Name) = Upper(@Project_Name) and Cmp_ID = @Cmp_ID
					
					exec P9999_Audit_get @table = 'T0050_Project_Master_Payroll' ,@key_column='Tran_Id',@key_Values=@Tran_Id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
					--

		end 
	else if upper(@tran_type) ='U' 
		begin
		
		if exists (Select Tran_Id  from T0050_Project_Master_Payroll WITH (NOLOCK) Where Upper(Project_Name) = Upper(@Project_Name) and Cmp_ID = @Cmp_ID and  Tran_Id <> @Tran_Id) 
				begin
					set @Tran_Id=0
					RETURN 
				end
			   
			   	exec P9999_Audit_get @table='T0050_Project_Master_Payroll' ,@key_column='Tran_Id',@key_Values=@Tran_Id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    
				Update T0050_Project_Master_Payroll 
				Set Project_Name = @Project_Name, Project_Manager_Id=@Project_Manager_Id ,Customer_Name = @Customer_Name,
				Site_Id = @Site_Id,Remarks = @Remarks,modify_date=getdate()
				where Tran_Id = @Tran_Id
				
				exec P9999_Audit_get @table='T0050_Project_Master_Payroll' ,@key_column='Tran_Id',@key_Values=@Tran_Id,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			   	
			
		end	
	else if upper(@tran_type) ='D'
		begin
				if Exists(select Project_ID from T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) where Cmp_ID=@CMP_ID and Project_ID=@Tran_Id)
					begin
						RAISERROR('@@ Reference Exists @@',16,2)
						RETURN	
					end
				exec P9999_Audit_get @table='T0050_Project_Master_Payroll' ,@key_column='Tran_Id',@key_Values=@Tran_Id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				
			     delete  from T0050_Project_Master_Payroll where Tran_Id=@Tran_Id
					
			end
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Project Master Payroll',@OldValue,@Tran_Id,@User_Id,@IP_Address
		
	RETURN




