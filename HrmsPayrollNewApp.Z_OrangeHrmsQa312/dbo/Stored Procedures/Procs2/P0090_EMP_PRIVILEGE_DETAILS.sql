
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_PRIVILEGE_DETAILS]
	@Trans_Id as numeric output,
	@Privilege_ID AS numeric,
	@CMP_ID AS numeric,
	@Login_Id as numeric,
	@Effect_Date as datetime,
	@tran_type varchar(1) = 'I',
	@User_Id numeric(18,0) = 0,	-- Added for Audit Trail by Ali 09102013
	@IP_Address varchar(30)= '' -- Added for Audit Trail by Ali 09102013
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
										-- Added for audit trail by Ali on 10102013 -- Start
										Declare @Old_Login_Id as numeric
										Declare @S_Emp_Id as numeric
										Declare @Old_Emp_Name as varchar(100)
										Declare @Old_Privilege_ID as numeric
										Declare @New_Privilage_Name as varchar(150)
										Declare @Old_Privilage_Name as varchar(150)
										Declare @Old_Effect_Date as datetime
										Declare @OldValue as varchar(max)
										
										Set @Old_Login_Id = 0
										Set @S_Emp_Id = 0
										Set @Old_Emp_Name = ''										
										Set @Old_Privilege_ID = 0										
										Set @Old_Privilage_Name = ''
										Set @New_Privilage_Name = ''
										Set @Old_Effect_Date  = null
										Set @OldValue = ''
										-- Added for audit trail by Ali on 10102013 -- End
	If @tran_type  = 'I'
		Begin	
		
		
				
				If Exists(Select Trans_ID From T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Login_Id = @Login_Id and From_Date = @Effect_Date --and Privilege_Id = @Privilege_Id --Commented by rohit for change priviledge of guest user on 21122012
				) 
					begin
							
										-- Added for audit trail by Ali on 10102013 -- Start
										Select 
										@Old_Login_Id = Login_Id
										,@Old_Privilege_ID = Privilege_Id
										,@Old_Effect_Date = From_Date
										from T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
										where Login_Id = @Login_Id and Cmp_Id = @Cmp_Id and From_Date = @Effect_Date
										
										Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID IN ( select Emp_ID from T0011_Login WITH (NOLOCK) where Login_ID = @Login_Id AND Cmp_ID = @CMP_ID))										
										Set @Old_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID And Privilege_ID = @Old_Privilege_ID)
										Set @New_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID And Privilege_ID = @Privilege_ID)
										
										set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Assigned Privilege :' + ISNULL(@Old_Privilage_Name,'') 																						
												+ '#' + 'Effect Date :' + cast(ISNULL(@Old_Effect_Date,'') as nvarchar(11)) 										
												+ '#' +
												+ 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Assigned Privilege :' + ISNULL(@New_Privilage_Name,'') 																						
												+ '#' + 'Effect Date :' + cast(ISNULL(@Effect_Date,'') as nvarchar(11)) 										
										Set @S_Emp_Id = (select Emp_ID from T0011_Login WITH (NOLOCK) where Login_ID = @Old_Login_Id)
										exec P9999_Audit_Trail @Cmp_ID,'U','Employee Privileges',@Oldvalue,@S_Emp_Id,@User_Id,@IP_Address,1
										
										-- Added for audit trail by Ali on 10102013 -- End
										
							UPDATE   T0090_EMP_PRIVILEGE_DETAILS
							SET     Privilege_Id = @Privilege_ID
							where Login_Id = @Login_Id and Cmp_Id = @Cmp_Id and From_Date = @Effect_Date
							
					end
				else If Exists(Select Trans_ID From T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Login_Id = @Login_Id and From_Date > @Effect_Date) 
					begin
					
						set @Trans_Id = 0
														
					end
				else
					begin
						
						select @Trans_Id = isnull(Trans_Id,0) From T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Login_Id = @Login_Id 
						declare @tmpEffDate datetime
						if @Trans_Id = 0
							begin
								
								select @tmpEffDate = em.Date_Of_Join  from T0080_EMP_MASTER em WITH (NOLOCK) inner join
								T0011_LOGIN LG WITH (NOLOCK) on lg.Emp_ID = em.Emp_ID
								where LG.Login_ID = @Login_Id
								
								if @tmpEffDate > @Effect_Date
									begin
										set @Effect_Date = @tmpEffDate
									end
								
							end
					
						select @Trans_Id = Isnull(max(Trans_Id),0) + 1 	From T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
												
						INSERT INTO T0090_EMP_PRIVILEGE_DETAILS
							  (Trans_Id, Cmp_Id, Login_Id, Privilege_Id,From_Date)
						VALUES     (@Trans_Id,@CMP_ID,@Login_Id,@Privilege_ID,@Effect_Date)
						
										-- Added for audit trail by Ali on 10102013 -- Start
										Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID IN ( select Emp_ID from T0011_Login WITH (NOLOCK) where Login_ID = @Login_Id AND Cmp_ID = @CMP_ID))										
										Set @Old_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID And Privilege_ID = @Privilege_ID)
										
										set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Assigned Privilege :' + ISNULL(@Old_Privilage_Name,'') 																						
												+ '#' + 'Effect Date :' + cast(ISNULL(@Effect_Date,'') as nvarchar(11))
										Set @S_Emp_Id = (select Emp_ID from T0011_Login WITH (NOLOCK) where Login_ID = @Login_Id)
										exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Employee Privileges',@Oldvalue,@S_Emp_Id,@User_Id,@IP_Address,1
										-- Added for audit trail by Ali on 10102013 -- End
					end				
		End
	--Else if @Tran_Type = 'U'
	--	begin
				
				
	--			UPDATE   T0090_EMP_PRIVILEGE_DETAILS
	--			SET     Is_View = @Is_View, Is_Edit = @Is_Edit, 
	--					Is_Save = @Is_Save, Is_Delete = @Is_Delete, Is_Print = 0
 --               where Privilage_ID = @Privilege_ID and Cmp_Id = @Cmp_Id and Form_Id = @Form_Id
				
	--	end
	Else if @Tran_Type = 'D'
		begin
				select @Trans_Id
					
										-- Added for audit trail by Ali on 10102013 -- Start
										Select 
										@Old_Login_Id = Login_Id
										,@Old_Privilege_ID = Privilege_Id
										,@Old_Effect_Date = From_Date
										from T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
										Where Trans_ID = @Trans_Id
										
										Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID IN ( select Emp_ID from T0011_Login WITH (NOLOCK) where Login_ID = @Old_Login_Id AND Cmp_ID = @CMP_ID))										
										Set @Old_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Cmp_Id = @CMP_ID And Privilege_ID = @Old_Privilege_ID)
										
										set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Assigned Privilege :' + ISNULL(@Old_Privilage_Name,'') 																						
												+ '#' + 'Effect Date :' + cast(ISNULL(@Old_Effect_Date,'') as nvarchar(11)) 										
										Set @S_Emp_Id = (select Emp_ID from T0011_Login WITH (NOLOCK) where Login_ID = @Old_Login_Id)
										exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Employee Privileges',@Oldvalue,@S_Emp_Id,@User_Id,@IP_Address,1
										-- Added for audit trail by Ali on 10102013 -- End
					
				Delete From T0090_EMP_PRIVILEGE_DETAILS Where Trans_ID = @Trans_Id
		end

	RETURN




