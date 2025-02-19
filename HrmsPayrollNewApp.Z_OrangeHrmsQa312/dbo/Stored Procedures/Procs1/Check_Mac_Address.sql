


---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Check_Mac_Address]
   @Cmp_ID numeric(18)
  ,@Mac_Address nvarchar(100)
  ,@Emp_id numeric(18)
  
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Is_Allow numeric(18) 
	declare @Mac_Enable tinyint
	declare @is_Deny tinyint
	declare @is_hr_admin tinyint
	 
	set @Mac_Enable = 0
	set @is_Deny = 0
	set @Is_Allow = 1
	set @is_hr_admin = 0
	
	select @is_hr_admin = Is_HR  from T0011_LOGIN  WITH (NOLOCK) where Emp_ID = @Emp_id and Cmp_ID = @Cmp_ID
	
	if @is_hr_admin = 1 or @emp_id = 0
		begin
			set @Is_Allow = 1
		end
	Else
		begin
	
			Select @Mac_Enable = isnull(Is_Enable,0) , @is_Deny = isnull(Deny_Mac,0) from T9999_MAC_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID
						
			if @Mac_Enable = 0
				begin
					
					set @Is_Allow = 1
				end
			Else
				begin
					
					IF @is_deny = 0
						begin
							IF exists (SELECT Tran_id from T9999_MAC_DETAIL WITH (NOLOCK) where replace(Mac_Address,'-',':') = replace(@Mac_Address,'-',':') and (Emp_id = @Emp_id OR isnull(Emp_id,0) = 0))
								begin
									set @Is_Allow = 1
								end
							else
								begin
									set @Is_Allow = 0
								end
						end
					else IF @is_deny = 1
						begin
							
							IF exists (SELECT Tran_id from T9999_MAC_DETAIL WITH (NOLOCK) where replace(Mac_Address,'-',':') = replace(@Mac_Address,'-',':')  and (Emp_id = @Emp_id OR isnull(Emp_id,0) = 0))
								begin
									set @Is_Allow = 0
								end
							else
								begin
									set @Is_Allow = 1
								end
						end
					
					
				end
		end
		
	select @Is_Allow as 'is_allow'
	
     
END


