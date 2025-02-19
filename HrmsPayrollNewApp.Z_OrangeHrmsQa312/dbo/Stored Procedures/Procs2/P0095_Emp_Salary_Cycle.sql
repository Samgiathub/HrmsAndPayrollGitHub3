


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_Emp_Salary_Cycle]  
  @Tran_id numeric(18,0) 
 ,@Cmp_id numeric(18,0)
 ,@Emp_id numeric(18,0)
 ,@Effective_Date Datetime
 ,@SalDate_id numeric(18,0)
 ,@Tran_type   char(1)
 ,@User_Id numeric(18,0) = 0 
 ,@IP_Address varchar(30)= '' 
  
AS       
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Old_Cmp_ID numeric
	Declare @Old_SalDate_id numeric
	Declare @Old_Emp_Name nvarchar(60)
	Declare @Old_Salary_Cycle nvarchar(30)
	Declare @New_Salary_Cycle nvarchar(30)
	Declare @Old_Effective_Date datetime
	declare @OldValue as varchar(max)
		
	 
	set @Old_Cmp_ID  = 0
	set @Old_SalDate_id = 0
	set @Old_Emp_Name = ''
	set @Old_Salary_Cycle = ''
	set @New_Salary_Cycle = ''
	set @Old_Effective_Date = null
	set @OldValue = ''
	
	
	
	if  @Tran_type ='I'  
		Begin
			
			if exists (SELECT 1 from T0095_Emp_Salary_Cycle WITH (NOLOCK) where Emp_id = @Emp_id AND Effective_date = @Effective_Date)
				begin
					-- Added by Ali 04102013 - Start
					select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
					select @Old_SalDate_id = SalDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date = @Effective_date and Emp_id = @Emp_id
					Select @Old_Salary_Cycle = Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where cmp_Id = @Cmp_id AND Tran_Id = @Old_SalDate_id
					-- Added by Ali 04102013 - End	
					
					UPDATE    T0095_Emp_Salary_Cycle
					SET      SalDate_id = @SalDate_id where Effective_date = @Effective_date and Emp_id = @Emp_id
					
					Update T0095_Increment set SalDate_id = @SalDate_id where Increment_ID = (Select Increment_id  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_id) -- Added By Gadriwala 08102013
					
					-- Added by Ali 04102013 - Start
					Select @New_Salary_Cycle = Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where cmp_Id = @Cmp_id AND Tran_Id = @SalDate_id
					set @OldValue = ' old Value # Salary Cycle : ' + convert(nvarchar(10),@Old_Salary_Cycle) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Effective Date : ' + convert(nvarchar(21),@Effective_Date)
									+ 'New Value # Salary Cycle : ' + convert(nvarchar(10),@New_Salary_Cycle) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Effective Date : ' + convert(nvarchar(21),@Effective_Date)
					exec P9999_Audit_Trail @Cmp_ID,'U','Salary Cycle Transfer',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
					-- Added by Ali 04102013 - End	
				end
			else
				begin	
						
					INSERT INTO T0095_Emp_Salary_Cycle
							  (Cmp_id, Emp_id, SalDate_id, Effective_date)
					VALUES     (@Cmp_id,@Emp_id,@SalDate_id,@Effective_date)
					
					Update T0095_Increment set SalDate_id = @SalDate_id where Increment_ID = (Select Increment_id  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_id) -- Added By Gadriwala 08102013
					
					-- Added by Ali 04102013 - Start					
					select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
					Select @Old_Salary_Cycle = Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where cmp_Id = @Cmp_id AND Tran_Id = @SalDate_id
					
					set @OldValue = ' New Value # Salary Cycle : ' + convert(nvarchar(10),@Old_Salary_Cycle) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Effective Date : ' + convert(nvarchar(21),@Effective_Date)
					
					exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Salary Cycle Transfer',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
					-- Added by Ali 04102013 - End
			
				end
				
						
		end           
	Else if @Tran_type ='U'  
		Begin   
		
				-- Added by Ali 04102013 - Start
				select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
				select @Old_SalDate_id = SalDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date = @Effective_date and Emp_id = @Emp_id
				Select @Old_Salary_Cycle = Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where cmp_Id = @Cmp_id AND Tran_Id = @Old_SalDate_id
				-- Added by Ali 04102013 - End	
					
				UPDATE    T0095_Emp_Salary_Cycle
				SET      SalDate_id = @SalDate_id where Effective_date = @Effective_date and Emp_id = @Emp_id
				
				Update T0095_Increment set SalDate_id = @SalDate_id where Increment_ID = (Select Increment_id  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_id)	-- Added By Gadriwala 08102013	
				
				-- Added by Ali 04102013 - Start
				Select @New_Salary_Cycle = Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where cmp_Id = @Cmp_id AND Tran_Id = @SalDate_id
				set @OldValue = ' old Value # Salary Cycle : ' + convert(nvarchar(10),@Old_Salary_Cycle) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Effective Date : ' + convert(nvarchar(21),@Effective_Date)
								+ 'New Value # Salary Cycle : ' + convert(nvarchar(10),@New_Salary_Cycle) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Effective Date : ' + convert(nvarchar(21),@Effective_Date)
				exec P9999_Audit_Trail @Cmp_ID,'U','Salary Cycle Transfer',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
				-- Added by Ali 04102013 - End	
		End    
	Else if @Tran_type ='D'
		begin
			
			select @Effective_date = Effective_date,@Emp_id = Emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
			WHERE     Tran_id = @Tran_id
			
			if not exists (SELECT 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_id AND (Month_St_Date >= @Effective_date OR Month_End_Date >= @Effective_date ) )
				begin
				
					-- Added by Ali 04102013 - Start					
					select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
					Select @Old_Salary_Cycle = Name from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id in (Select SalDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where Tran_id = @Tran_id)
					
					set @OldValue = ' old Value # Salary Cycle : ' + convert(nvarchar(10),@Old_Salary_Cycle) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Effective Date : ' + convert(nvarchar(21),@Effective_Date)
					
					exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Salary Cycle Transfer',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
					
					-- Added by Ali 04102013 - End
					
					
					DELETE FROM T0095_Emp_Salary_Cycle
					WHERE     Tran_id = @Tran_id-- and Emp_id = @Emp_id
					
					Select @SalDate_id =  MAX(SalDate_id)  from T0095_Emp_Salary_Cycle WITH (NOLOCK) where Emp_ID = @Emp_id -- Added By Gadriwala 08102013	
					Update T0095_Increment set SalDate_id = @SalDate_id where Increment_ID = (Select max(Increment_id)  from T0095_Increment WITH (NOLOCK) where Emp_ID = @Emp_id) -- Added By Gadriwala 08102013		
				end
			else
				begin	
					Raiserror('Refernce Exists',16,2)
				end
			
		end		  
 RETURN  
  
  
  

