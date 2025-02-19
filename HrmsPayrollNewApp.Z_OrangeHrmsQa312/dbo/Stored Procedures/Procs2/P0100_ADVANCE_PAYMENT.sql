

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0100_ADVANCE_PAYMENT]
	 @Adv_ID	Numeric output
	,@Cmp_ID	Numeric
	,@Emp_ID	Numeric
	,@For_Date	DateTime
	,@Adv_Amount	Numeric
	,@Adv_P_Days	Numeric(18,1)
	,@Adv_Approx_Salary	Numeric
	,@Adv_Comments	varchar(250)
	,@tran_type		varchar(1)
	,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 18102013
	,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 18102013
	,@Res_id numeric(18,0)= 0   ---Added By Jaina 20-10-2015
	,@Status	varchar(1) = ''
	,@Adv_Approval_ID numeric = 0  --Added By Jaina 17-11-2015
	,@Sal_Tran_ID	numeric = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @CHECK_SAL_TRAN_ID AS NUMERIC
	SET @CHECK_SAL_TRAN_ID = 0
	
		-- Added for audit trail By Ali 18102013 -- Start
			Declare @OldValue as varchar(Max)
			Declare @Old_Emp_Id as numeric
			Declare @Old_Emp_Name as varchar(150)
			Declare @Old_For_Date as Datetime
			Declare @Old_Adv_Amount as numeric
			Declare @Old_Comments as varchar(250)
			
			Set @OldValue = ''
			Set @Old_Emp_Id = 0
			Set @Old_Emp_Name = ''
			Set @Old_For_Date = null
			Set @Old_Adv_Amount = 0
			Set @Old_Comments = ''
		-- Added for audit trail By Ali 18102013 -- End
		
		if @tran_type ='I' 
			begin
				-- Salary Exist condition set by mihir 15112011
				If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And @For_Date >= Month_St_Date And @For_Date <= Month_End_Date)
					Begin
						Raiserror('@@Month Salary Exists cant Insert@@',16,2)
						return -1
					End
				--Comment By Jaina (Approve more than one records on same date)	16/11/2015
				--If Exists(Select 1 From T0100_ADVANCE_PAYMENT where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And For_Date = @For_Date and Adv_Approval_ID = @Adv_Approval_ID)
				--	Begin
				--		Raiserror('@@Entry Exists for This Employee on Same Day@@',16,2)
				--		return -1
				--	End
					
				--Else
				--	Begin
				If NOT EXISTS (Select 1 From T0100_ADVANCE_PAYMENT WITH (NOLOCK) where Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID And For_Date =  @For_Date and Adv_Comments = 'Due to Negative Salary for ' + Cast(DateAdd(dd , -1 , @For_Date) as Varchar(12)))  --Added By Ramiz on 15062016 as in Negative Salary , Advance Was Repeating Multiple times
					BEGIN
						select @Adv_ID = Isnull(max(Adv_ID),0) + 1 	From T0100_ADVANCE_PAYMENT WITH (NOLOCK)
																
							INSERT INTO T0100_ADVANCE_PAYMENT
							(Adv_ID
							,Cmp_ID
							,Emp_ID
							,For_Date
							,Adv_Amount
							,Adv_P_Days
							,Adv_Approx_Salary
							,Adv_Comments
							,Res_id   --Added By Jaina 20-10-2015
							,Adv_Approval_ID  --Added By Jaina 17-11-2015
							,Sal_Tran_ID	--Added By Ramiz on 05-06-2017
							)
							VALUES   
							(@Adv_ID
							,@Cmp_ID
							,@Emp_ID
							,@For_Date
							,@Adv_Amount
							,@Adv_P_Days
							,@Adv_Approx_Salary
							,@Adv_Comments
							,@Res_id
							,@Adv_Approval_ID
							,@Sal_Tran_ID
							)
							
										-- Added for audit trail By Ali 18102013 -- Start
						Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID)
					
						set @OldValue = 'New Value' 
										+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
										+ '#' + 'Effect Date : ' + cast(ISNULL(@For_Date,'') as nvarchar(11))
										+ '#' + 'Advance Amount : ' + CONVERT(nvarchar(100),ISNULL(@Adv_Amount,0))
										+ '#' + 'Remarks : ' + ISNULL(@Adv_Comments,'')
																																							
						exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Admin Advance Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
										-- Added for audit trail By Ali 18102013 -- End
				END
					--End 
			END
	else if @tran_type ='U' 
			begin
				-- Salary Exist condition set by mihir 15112011
				If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And @For_Date >= Month_St_Date And @For_Date <= Month_End_Date)
						Begin
							Raiserror('@@Month Salary Exists cant update@@',16,2)
							return -1
						End
				Else
					Begin
										-- Added for audit trail By Ali 18102013 -- Start
											Select 
											@Old_Emp_Id = Emp_ID
											,@Old_Adv_Amount = Adv_Amount
											,@Old_Comments = Adv_Comments
											,@Old_For_Date = For_Date											
											From T0100_ADVANCE_PAYMENT WITH (NOLOCK)
											Where Adv_ID = @Adv_ID
											
											Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Old_Emp_Id)
										
											set @OldValue = 'old Value' 
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Effect Date : ' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11))
															+ '#' + 'Advance Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Adv_Amount,0))
															+ '#' + 'Remarks : ' + ISNULL(@Old_Comments,'')
															+ '#' +
															'New Value' +
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Effect Date : ' + cast(ISNULL(@For_Date,'') as nvarchar(11))
															+ '#' + 'Advance Amount : ' + CONVERT(nvarchar(100),ISNULL(@Adv_Amount,0))
															+ '#' + 'Remarks : ' + ISNULL(@Adv_Comments,'')
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Admin Advance Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
										-- Added for audit trail By Ali 18102013 -- End
										
										
					DELETE FROM T0100_ADVANCE_PAYMENT WHERE Adv_ID = @Adv_ID

					INSERT INTO T0100_ADVANCE_PAYMENT
						(Adv_ID
						,Cmp_ID
						,Emp_ID
						,For_Date
						,Adv_Amount
						,Adv_P_Days
						,Adv_Approx_Salary
						,Adv_Comments
						,Res_id    --Added By Jaina 20-10-2015
						,Adv_Approval_ID
						,Sal_Tran_ID 
						)
						VALUES   
						(@Adv_ID
						,@Cmp_ID
						,@Emp_ID
						,@For_Date
						,@Adv_Amount
						,@Adv_P_Days
						,@Adv_Approx_Salary
						,@Adv_Comments
						,@Res_id
						,@Adv_Approval_ID
						,@Sal_Tran_ID
						)
					End
			End
	else if @tran_type ='D'
			begin
				SELECT @For_Date = for_Date ,@EMP_ID = EMP_ID , @CHECK_SAL_TRAN_ID = SAL_TRAN_ID FROM T0100_ADVANCE_PAYMENT WITH (NOLOCK) where Adv_ID = @Adv_ID
			
				--If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And Month(Month_St_Date)=Month(@For_date) And YEAR(Month_St_Date)=YEAR (@For_Date) )
				If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And @For_Date >= Month_St_Date And @For_Date <= Month_End_Date)
					Begin
						Raiserror('@@This Months Salary Exists@@',16,2)
						return -1
					End
				Else
					Begin
						if @Status = 'R'   --Added By Jaina 3-11-2015
							BEGIN
								Update T0090_ADVANCE_PAYMENT_APPROVAL set Advance_Status='P' Where Adv_Approval_ID=@Adv_ID AND Advance_Status='R'
								RETURN;
							END
						ELSE
							BEGIN
								-- Added for audit trail By Ali 18102013 -- Start
									Select 
									@Old_Emp_Id = Emp_ID
									,@Old_Adv_Amount = Adv_Amount
									,@Old_Comments = Adv_Comments
									,@Old_For_Date = For_Date											
									From T0100_ADVANCE_PAYMENT WITH (NOLOCK)
									Where Adv_ID = @Adv_ID
									
									Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Old_Emp_Id)
								
									set @OldValue = 'old Value' 
													+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Effect Date : ' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11))
													+ '#' + 'Advance Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Adv_Amount,0))
													+ '#' + 'Remarks : ' + ISNULL(@Old_Comments,'')
																																										
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Admin Advance Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
								-- Added for audit trail By Ali 18102013 -- End
							
								--Commented By Ramiz and Added New Condition on 04/06/2017
								--DELETE FROM T0100_ADVANCE_PAYMENT where Adv_ID = @Adv_ID
								
								IF @CHECK_SAL_TRAN_ID = 0 OR @CHECK_SAL_TRAN_ID IS NULL
									BEGIN
										DELETE FROM T0100_ADVANCE_PAYMENT where Adv_ID = @Adv_ID
									END
								ELSE
									BEGIN
										RAISERROR('@@This Advance is of Salary , Cannot be Deleted@@',16,2)
										RETURN -1
									END
								
								--Comment By Jaina 2-11-2015
								--DELETE FROM T0090_ADVANCE_PAYMENT_APPROVAL where Cmp_ID=@Cmp_ID And  EMP_ID=@EMP_ID  and  Application_Date = @For_Date and Advance_Status='A'   
								IF EXISTS(SELECT Adv_Approval_ID FROM T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK) Where Advance_Status='A' and Adv_Approval_ID=@Adv_Approval_ID)   --Added By Jaina 2-11-2015
									BEGIN								
										Update T0090_ADVANCE_PAYMENT_APPROVAL SET Advance_Status = 'P' Where Adv_Approval_ID = @Adv_Approval_ID  --Change By Jaina 17-11-2015								
									End	
								ELSE IF EXISTS(SELECT Adv_Approval_ID FROM T0090_ADVANCE_PAYMENT_APPROVAL WITH (NOLOCK) Where Application_Date = @For_Date and Advance_Status='A') 
										AND IsNull(@Adv_Approval_ID,0) = 0 --Added By Jaina 2-11-2015
									BEGIN
										Update T0090_ADVANCE_PAYMENT_APPROVAL SET Advance_Status = 'P' Where Application_Date = @For_Date   --Change By Jaina 17-11-2015								
									END
							END
					End
				
				if exists(select Emp_ID from T0140_ADVANCE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND fOR_dATE >=@FOR_DATE and adv_Closing <0 )
					begin
						Raiserror('@@Negative:You Cant Delete This Record@@',16,2)
						return -1
					end
			end
			
	RETURN




