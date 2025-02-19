

-- =============================================
-- Author:		<Hiral Chandora>
-- ALTER date: <20 Nov,2012>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0090_ADVANCE_PAYMENT_APPROVAL]
	 @Adv_Approval_ID	NUMERIC(18,0) OUTPUT
	,@Cmp_ID			NUMERIC(18,0)
	,@Emp_ID			NUMERIC(18,0)
	,@Application_Date	Varchar(50) = ''
	,@Requested_Amount	NUMERIC(18,0)
	,@Emp_Remarks		VarChar(250)
	,@Approval_Date		Varchar(50) = ''
	,@Approval_Amount	NUMERIC(18,0) = ''
	,@Superior_Remarks	VarChar(250) = ''
	,@Advance_Status	Char(1)
	,@Approved_By		Numeric(18,0) = ''
	,@tran_type			VarChar(1)
	,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 18102013
	,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 18102013
	,@Res_id numeric(18,0)   ---Added By Jaina 20-10-2015
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


									-- Added for audit trail By Ali 18102013 -- Start
										Declare @Old_Emp_Id as numeric
										Declare @Old_Emp_Name as varchar(150)
										Declare @Old_Application_Date as Varchar(50)
										Declare @Old_Requested_Amount as NUMERIC(18,0)
										Declare @Old_Emp_Remarks as	VarChar(250)
										Declare @Old_Approval_Date as Varchar(50) 
										Declare @Old_Approval_Amount as NUMERIC(18,0) 
										Declare @Old_Superior_Remarks as VarChar(250)
										Declare @Old_Advance_Status as Char(1)
										Declare @Old_Approved_By as Numeric(18,0)
										Declare @OldValue as Varchar(max)
										
										
										Set @Old_Emp_Id  = 0
										Set @Old_Emp_Name = ''
										Set @Old_Application_Date = ''
										Set @Old_Requested_Amount = 0
										Set @Old_Emp_Remarks  = ''
										Set @Old_Approval_Date = ''
										Set @Old_Approval_Amount  = 0
										Set @Old_Superior_Remarks  = ''
										Set @Old_Advance_Status  = ''
										Set @Old_Approved_By  = 0
										Set @OldValue  = ''
									-- Added for audit trail By Ali 18102013 -- End
BEGIN
	
	Declare @Create_Date As DateTime
	Set @Create_Date = GETDATE()
	
	If @Application_Date = ''
		Set @Application_Date = NULL
		
	If @Approval_Date = ''
		Set @Approval_Date = NULL
		
	--If @Approval_Amount = ''
	--	Set @Approval_Amount = NULL
		
	If @Superior_Remarks = ''
		Set @Superior_Remarks = NULL
		
	--If @Approved_By = ''
	--	Set @Approved_By = NULL
	
	
	If @tran_type ='I' 
			begin
			
				If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And @Application_Date >= Month_St_Date And @Application_Date <= Month_End_Date)
					Begin
						Raiserror('@@Month Salary Exists cant Insert@@',16,2)
						return -1
					End
				--If Exists(Select 1 From T0090_ADVANCE_PAYMENT_APPROVAL where Cmp_ID=@Cmp_ID And  EMP_ID=@Emp_ID  and  Application_Date = @Application_Date and  Advance_Status='P' and Adv_Approval_ID = @Adv_Approval_ID)
				--	Begin
				--		Raiserror('@@Entry Exists for This Employee on Same Day@@',16,2)
				--		return -1
				--	End	
				Else
					Begin
					   --IF Not Exists (select 1 from T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID =@Emp_ID and Application_Date=@Application_Date)
					      If @Adv_Approval_ID = 0
						Begin
							--print 'insert'
							Select @Adv_Approval_ID = Isnull(max(Adv_Approval_ID),0) + 1 From T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK)
																
							INSERT INTO T0090_ADVANCE_PAYMENT_APPROVAL
								(Adv_Approval_ID, Cmp_ID, Emp_ID, Application_Date, Requested_Amount, Emp_Remarks, Approval_Date
								,Approval_Amount, Superior_Remarks, Advance_Status, Approved_By, Create_Date,Res_Id)   --Change By Jaina 20-10-2015
							VALUES   
								(@Adv_Approval_ID, @Cmp_ID, @Emp_ID, @Application_Date, @Requested_Amount, @Emp_Remarks, @Approval_Date
								,@Approval_Amount, @Superior_Remarks, @Advance_Status, @Approved_By, @Create_Date,@Res_Id)
						End
						--Added By Jimit 24122019 to solve the duplicate approval process for Advance
						Else
							--sandip bhai dicussion due to comment below code should not be update amount during new add application 20022020
							Begin
								--print 'update'
								Update	T0090_ADVANCE_PAYMENT_APPROVAL 
								Set		Application_Date = @Application_Date,Approval_Date = @Application_Date, 
										Requested_Amount = @Requested_Amount, Emp_Remarks = @Emp_Remarks ,Res_id=@Res_id,
										Advance_Status = @Advance_Status								
								Where Cmp_ID = @Cmp_ID and Emp_ID =@Emp_ID and Application_Date =@Application_Date AND Adv_Approval_ID = @Adv_Approval_ID

							End
										-- Added for audit trail By Ali 18102013 - Start
										
											Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID)
										
											set @OldValue = 'New Value' 
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Application Date : ' + cast(ISNULL(@Application_Date,'') as nvarchar(11))
															+ '#' + 'Approval Date : ' + cast(ISNULL(@Approval_Date,'') as nvarchar(11))
															+ '#' + 'Requested Amount : ' + CONVERT(nvarchar(100),ISNULL(@Requested_Amount,0))
															+ '#' + 'Employee Remarks : ' + ISNULL(@Emp_Remarks,'')
															--+ '#' + 'Approval Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Approval_Amount,0))
															--+ '#' + 'Manager Remarks : ' + ISNULL(@Old_Superior_Remarks,'')
															+ '#' + 'Status : ' + CASE ISNULL(@Advance_Status,'') WHEN 'A' THEN 'Approve' WHEN 'R' THEN 'Reject' ELSE 'Pending' END
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Salary Advance Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
												
										-- Added for audit trail By Ali 18102013 - End
					End 
			END
	else if @tran_type ='U' 
			begin
				If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And @Application_Date >= Month_St_Date And @Application_Date <= Month_End_Date)
					Begin
						Raiserror('@@Month Salary Exists cant update@@',16,2)
						return -1
					End
				If Exists(Select 1 From T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK) where Cmp_ID=@Cmp_ID And  EMP_ID=@Emp_ID  and  Application_Date = @Application_Date And Adv_Approval_ID <> @Adv_Approval_ID and Advance_Status='P')   --Change By Jaina 21-10-2015 Add Status='p'
					Begin
						Raiserror('@@Entry Exists for This Employee on Same Day@@',16,2)
						return -1
					End		
					
				Else
					Begin
					
										-- Added for audit trail By Ali 18102013 - Start
											Select
											@Old_Emp_Id = Emp_ID
											,@Old_Application_Date = Application_Date
											,@Old_Approval_Date = Approval_Date
											,@Old_Requested_Amount = Requested_Amount
											,@Old_Emp_Remarks = Emp_Remarks
											,@Old_Approval_Amount = Approval_Amount
											,@Old_Superior_Remarks = Superior_Remarks
											,@Old_Advance_Status  = Advance_Status
											From T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK)
											Where Cmp_ID = @Cmp_ID And Adv_Approval_ID = @Adv_Approval_ID 
											
											Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Old_Emp_Id)
										
											set @OldValue = 'old Value' 
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Application Date : ' + cast(ISNULL(@Old_Application_Date,'') as nvarchar(11))
															+ '#' + 'Approval Date : ' + cast(ISNULL(@Old_Approval_Date,'') as nvarchar(11))
															+ '#' + 'Requested Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Requested_Amount,0))
															+ '#' + 'Employee Remarks : ' + ISNULL(@Old_Emp_Remarks,'')
															+ '#' + 'Approval Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Approval_Amount,0))
															+ '#' + 'Manager Remarks : ' + ISNULL(@Old_Superior_Remarks,'')
															+ '#' + 'Status : ' + CASE ISNULL(@Advance_Status,'') WHEN 'A' THEN 'Approve' WHEN 'R' THEN 'Reject' ELSE 'Pending' END
															+ '#' +
															+ 'New Value' +
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Application Date : ' + cast(ISNULL(@Application_Date,'') as nvarchar(11))
															+ '#' + 'Approval Date : ' + cast(ISNULL(@Approval_Date,'') as nvarchar(11))
															+ '#' + 'Requested Amount : ' + CONVERT(nvarchar(100),ISNULL(@Requested_Amount,0))
															+ '#' + 'Employee Remarks : ' + ISNULL(@Emp_Remarks,'')
															+ '#' + 'Approval Amount : ' + CONVERT(nvarchar(100),ISNULL(@Approval_Amount,0))
															+ '#' + 'Manager Remarks : ' + ISNULL(@Superior_Remarks,'')
															+ '#' + 'Status : ' + CASE ISNULL(@Advance_Status,'') WHEN 'A' THEN 'Approve' WHEN 'R' THEN 'Reject' ELSE 'Pending' END
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Salary Advance Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
												
										-- Added for audit trail By Ali 18102013 - End
										
										
						Update T0090_ADVANCE_PAYMENT_APPROVAL 
							Set Application_Date = @Application_Date,Approval_Date = @Application_Date, Requested_Amount = @Requested_Amount, Emp_Remarks = @Emp_Remarks ,Res_id=@Res_id  --Change By Jaina 20-10-2015
							Where Cmp_ID = @Cmp_ID And Adv_Approval_ID = @Adv_Approval_ID 
					End
			End
	
	Else if @tran_type ='D'
			begin
				select @Application_Date = Application_Date ,@EMP_ID = EMP_ID FROM T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK) where Adv_Approval_ID = @Adv_Approval_ID
				
				
				If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And @Application_Date >= Month_St_Date And @Application_Date <= Month_End_Date)
					Begin
						Raiserror('@@This Months Salary Exists@@',16,2)
						return -1
					End
				Else
					Begin
					
										-- Added for audit trail By Ali 18102013 - Start
											Select
											@Old_Emp_Id = Emp_ID
											,@Old_Application_Date = Application_Date
											,@Old_Approval_Date = Approval_Date
											,@Old_Requested_Amount = Requested_Amount
											,@Old_Emp_Remarks = Emp_Remarks
											,@Old_Approval_Amount = Approval_Amount
											,@Old_Superior_Remarks = Superior_Remarks
											,@Old_Advance_Status  = Advance_Status
											From T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK)
											Where Adv_Approval_ID = @Adv_Approval_ID
											
											Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Old_Emp_Id)
										
											set @OldValue = 'old Value' 
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Application Date : ' + cast(ISNULL(@Old_Application_Date,'') as nvarchar(11))
															+ '#' + 'Approval Date : ' + cast(ISNULL(@Old_Approval_Date,'') as nvarchar(11))
															+ '#' + 'Requested Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Requested_Amount,0))
															+ '#' + 'Employee Remarks : ' + ISNULL(@Old_Emp_Remarks,'')
															--+ '#' + 'Approval Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Approval_Amount,0))
															--+ '#' + 'Manager Remarks : ' + ISNULL(@Old_Superior_Remarks,'')
															+ '#' + 'Status : ' + CASE ISNULL(@Advance_Status,'') WHEN 'A' THEN 'Approve' WHEN 'R' THEN 'Reject' ELSE 'Pending' END
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Salary Advance Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
												
										-- Added for audit trail By Ali 18102013 - End
										
						DELETE FROM T0090_ADVANCE_PAYMENT_APPROVAL where Adv_Approval_ID = @Adv_Approval_ID
					End
			end
Else if @tran_type ='N'
			begin
				If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And @Application_Date >= Month_St_Date And @Application_Date <= Month_End_Date)
					Begin
						Raiserror('@@Month Salary Exists cant update@@',16,2)
						return -1
					End
				--If Exists(Select 1 From T0100_ADVANCE_PAYMENT where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And For_Date = @Approval_Date and @Advance_Status<>'P')
				--	Begin
				--		Raiserror('@@Entry Exists for This Employee on Same Day@@',16,2)
				--		return -1
				--	End		
				Else
					Begin
						Update T0090_ADVANCE_PAYMENT_APPROVAL 
							Set
							 Approval_Date = @Approval_Date,
							 Approval_Amount = @Approval_Amount, 
							 Superior_Remarks = @Superior_Remarks, 
							 Advance_Status=@Advance_Status,
							 Approved_By=@Approved_By
							Where Cmp_ID = @Cmp_ID And Adv_Approval_ID = @Adv_Approval_ID 
					End
			End				
END


