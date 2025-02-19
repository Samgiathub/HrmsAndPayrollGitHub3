



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_MONTHLY_LOCK_INFORMATION]
	 @Lock_ID  numeric output
	,@Cmp_Id numeric(18,0)
	,@Branch_ID  numeric(18,0)
	,@Month numeric(5,0)
	,@Year numeric(5,0)
	,@Is_Lock tinyint
	,@User_ID numeric(18,0)
	,@tran_type varchar(1)
	,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 22102013

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

								-- Added for audit trail By Ali 22102013
									Declare @OldValue  varchar(max)
									Declare @Old_Branch_Name  varchar(150)
									Declare @New_Branch_Name  varchar(150)
									Declare @Old_Branch_ID  numeric(18,0)
									Declare @Old_Month numeric(5,0)
									Declare @Old_Year numeric(5,0)
									Declare @Old_Is_Lock tinyint
									Declare @Old_User_ID numeric(18,0)
									Declare @Old_User_Name Varchar(150)
									Declare @Old_Date datetime
									
									Set @OldValue = ''
									Set @Old_Branch_Name = ''
									Set @New_Branch_Name = ''
									Set @Old_Branch_ID = 0
									Set @Old_Month = 0
									Set @Old_Year = 0
									Set @Old_Is_Lock = 0
									Set @Old_User_ID = 0
									Set @Old_User_Name = ''
									Set @Old_Date = null
								-- Added for audit trail By Ali 22102013
	
	If @tran_type  = 'I' 
		Begin
		
			if @Branch_ID = 0
				begin	
					if exists (select lock_id from T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) where MONTH = @Month and YEAR = @Year and Cmp_ID = @Cmp_Id and Branch_ID <> 0)
						begin	
							set @Lock_ID = -1
							return
						end
				end
			
			if @Branch_ID <> 0
				begin	
					if exists (select lock_id from T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) where Branch_ID = 0 and MONTH = @Month and YEAR = @Year and Cmp_ID = @Cmp_Id)
						begin	
							set @Lock_ID = -2
							return
						end
				end
			
				
	
			select @Lock_ID = Isnull(max(Lock_ID),0) + 1 	From T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK)
				
			INSERT INTO T0250_MONTHLY_LOCK_INFORMATION
						(Lock_ID, Cmp_ID, Branch_ID, Month,Year, Is_Lock, User_ID, System_Date)
				VALUES  (@Lock_ID,@Cmp_ID,@Branch_ID,@Month,@Year,@Is_Lock,@User_ID,GETDATE())
				
								-- Added for audit trail By Ali 19102013 -- Start
									Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)
									Set @Old_User_Name = (select Login_Name from T0011_LOGIN WITH (NOLOCK) where Login_ID = @User_ID)
											
									set @OldValue = 'New Value' 
										+ '#' + 'Month  : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
										+ '#' + 'Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')																						
										+ '#' + 'Status : ' + CASE ISNULL(@Is_Lock,0) When 0 Then 'Unlock' ELSE 'Lock' END
										+ '#' + 'Done By : ' + ISNULL(@Old_User_Name,'')
										+ '#' + 'Date : ' + cast(ISNULL(Getdate(),'') as nvarchar(11))
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Month Lock',@OldValue,@Lock_ID,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
								
		End
	Else if @Tran_Type = 'U' 
		begin

								-- Added for audit trail By Ali 19102013 -- Start
									Select 
									@Old_Month = [Month]
									,@Old_Year = [Year]
									,@Old_Branch_ID = Branch_ID
									,@Old_Is_Lock = Is_Lock
									,@Old_User_ID = [User_ID]
									,@Old_Date = System_Date
									From T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK)
									Where Cmp_ID = @Cmp_Id and Lock_ID = @Lock_ID
									
									
									Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Old_Branch_ID)
									Set @New_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)
									Set @Old_User_Name = (select Login_Name from T0011_LOGIN WITH (NOLOCK) where Login_ID = @Old_User_ID)
											
									set @OldValue = 'old Value' 
										+ '#' + 'Month  : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
										+ '#' + 'Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')																						
										+ '#' + 'Status : ' + CASE ISNULL(@Old_Is_Lock,0) When 0 Then 'Unlock' ELSE 'Lock' END
										+ '#' + 'Done By : ' + ISNULL(@Old_User_Name,'')
										+ '#' + 'Date : ' + cast(ISNULL(@Old_Date,'') as nvarchar(11))
										+ '#' +
										+ 'New Value' +
										+ '#' + 'Month  : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
										+ '#' + 'Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@New_Branch_Name,'')																						
										+ '#' + 'Status : ' + CASE ISNULL(@Is_Lock,0) When 0 Then 'Unlock' ELSE 'Lock' END
										+ '#' + 'Done By : ' + ISNULL(@Old_User_Name,'')
										+ '#' + 'Date : ' + cast(ISNULL(Getdate(),'') as nvarchar(11))
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Month Lock',@OldValue,@Lock_ID,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
								
					UPDATE    T0250_MONTHLY_LOCK_INFORMATION
					SET Is_Lock = @Is_Lock, User_ID = @User_ID, System_Date = GETDATE()
                      where Cmp_ID = @Cmp_Id and Lock_ID = @Lock_ID
				
		end
	Else if @Tran_Type = 'D' 
		begin
								-- Added for audit trail By Ali 19102013 -- Start
									Select 
									@Old_Month = [Month]
									,@Old_Year = [Year]
									,@Old_Branch_ID = Branch_ID
									,@Old_Is_Lock = Is_Lock
									,@Old_User_ID = [User_ID]
									,@Old_Date = System_Date
									From T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK)
									Where Lock_ID = @Lock_ID and Cmp_ID = @Cmp_Id
									
									
									Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Old_Branch_ID)
									Set @Old_User_Name = (select Login_Name from T0011_LOGIN WITH (NOLOCK) where Login_ID = @Old_User_ID)
											
									set @OldValue = 'old Value' 
										+ '#' + 'Month  : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
										+ '#' + 'Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')																						
										+ '#' + 'Status : ' + CASE ISNULL(@Old_Is_Lock,0) When 0 Then 'Unlock' ELSE 'Lock' END
										+ '#' + 'Done By : ' + ISNULL(@Old_User_Name,'')
										+ '#' + 'Date : ' + cast(ISNULL(@Old_Date,'') as nvarchar(11))
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Month Lock',@OldValue,@Lock_ID,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
				Delete From T0250_MONTHLY_LOCK_INFORMATION Where Lock_ID = @Lock_ID and Cmp_ID = @Cmp_Id
		end


	RETURN




