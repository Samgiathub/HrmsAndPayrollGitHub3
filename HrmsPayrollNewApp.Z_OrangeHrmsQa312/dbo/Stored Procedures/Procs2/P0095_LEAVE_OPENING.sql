
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_LEAVE_OPENING]
  @Leave_Op_ID as numeric output 
 ,@Emp_Id  as numeric
 ,@GRD_ID as numeric 
 ,@CMP_Id as numeric
 ,@Leave_Id as numeric
 ,@Leave_Op_Days as numeric(22,5)
 ,@for_date  as datetime
 ,@tran_type as varchar(1)
 ,@User_Id numeric(18,0) = 0 -- Added Audit Trail By Ali 07102013
 ,@IP_Address varchar(30)= '' -- Added Audit Trail By Ali 07102013 
   
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @Grd_Id_Old As Numeric(18,0)
		Set @Grd_Id_Old = 0
		
		-- Added Audit Trail By Ali 07102013 -- Start
		
		Declare @Old_Emp_name varchar(100)
		Declare @Old_Emp_Id as numeric
		Declare @Old_Leave_Op_Days as numeric(22,5)
		Declare @Old_for_date  as datetime
		Declare @OldValue as varchar(max)
		Declare @Old_Leave_Name as varchar(50)
		Declare @New_Leave_Name as varchar(50)
		Declare @Old_GRD_ID as numeric
		Declare @New_Grd_Name as varchar(50)
		Declare @Old_Grd_Name as varchar(50)
		Declare @Old_Leave_Id as numeric
		
		Set @Old_Emp_name = ''
		Set @Old_Emp_Id = 0
		Set @Old_Leave_Op_Days = 0
		Set @Old_for_date = null
		Set @OldValue = ''
		Set @Old_Leave_Name = ''
		Set @Old_Leave_Id = 0
		Set @Old_GRD_ID = 0
		Set @New_Leave_Name = ''
		Set @Old_Grd_Name = ''
		Set @New_Grd_Name = ''
						
		-- Added Audit Trail By Ali 07102013 -- End
		

select @GRD_ID = Grd_ID From T0095_Increment I WITH (NOLOCK) inner join     
     (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)  
     where Increment_Effective_date <= @for_date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
	 Where I.Emp_ID = @Emp_ID
	 
	if @tran_type = 'I'
		begin
			IF @GRD_ID  = 0
				SET @GRD_ID = NULL
			
			SELECT @Leave_Op_ID = ISNULL(MAX(LEAVE_OP_ID),0) + 1 FROM Dbo.T0095_LEAVE_OPENING WITH (NOLOCK)
				
			INSERT INTO Dbo.T0095_LEAVE_OPENING
						(Leave_Op_ID, Emp_Id, Grd_ID, Cmp_ID, Leave_ID, For_Date, Leave_Op_Days)
			VALUES     (@Leave_Op_ID,@Emp_Id,@Grd_ID,@Cmp_ID,@Leave_ID,@For_Date,@Leave_Op_Days)
			
							-- Added Audit Trail By Ali 07102013 -- Start
							select @Old_Emp_name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
							Select @Old_Leave_Name = (select Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_Id)
							Select @Old_Grd_Name = (Select Grd_Name from  T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @GRD_ID)
							set @OldValue = 'New Value' 
											+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_name,'') 
											+ '#' + 'Date :' + cast(ISNULL(@for_date,'') as nvarchar(11)) 
											+ '#' + 'Leave Op Days :' + CONVERT(nvarchar(20),ISNULL(@Leave_Op_Days,0))
											+ '#' + 'Leave Name :' + ISNULL(@Old_Leave_Name,'') 
											+ '#' + 'Grade Name :' + ISNULL(@Old_Grd_Name,'') 
											
												
							exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Opening',@OldValue,@Leave_Id,@User_Id,@IP_Address							
							-- Added Audit Trail By Ali 07102013 -- End
			
			
		end
	ELSE IF @tran_type = 'U'
		begin
			If Exists(select Emp_ID From Dbo.T0095_LEAVE_OPENING WITH (NOLOCK) Where Emp_ID= @Emp_ID and LEave_ID =@Leave_ID and For_Date = @for_Date)
				Begin
				----------------Nikunj Put this For Condtion where employees grade is changed and then you are going to update leave opening balance 11-Jan-2011			
					Select @Grd_Id_Old =Grd_ID  From Dbo.T0095_LEAVE_OPENING WITH (NOLOCK) Where Emp_ID= @Emp_ID and LEave_ID =@Leave_ID and For_Date = @for_Date And Cmp_Id=@Cmp_Id	
						If @GRD_ID <> @Grd_Id_Old 
						Begin
						
										-- Added Audit Trail By Ali 08102013 -- Start
										select @Old_Emp_name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
										select @Old_Leave_Id = Leave_ID
											,@Old_for_date = For_Date
											,@Old_Leave_Op_Days = Leave_Op_Days
											,@Old_GRD_ID = Grd_ID
										From T0095_LEAVE_OPENING WITH (NOLOCK) Where Emp_Id =@Emp_Id and LEave_ID = @Leave_ID and For_Date = @for_Date And Cmp_Id=@Cmp_Id	
										Select @Old_Leave_Name = (select Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Old_Leave_Id)
										Select @Old_Grd_Name = (Select Grd_Name from  T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @Old_GRD_ID)
										-- Added Audit Trail By Ali 08102013 -- End
							
						Update Dbo.T0095_LEAVE_OPENING 
						Set Grd_ID = @GRD_ID 
						Where Emp_Id =@Emp_Id and LEave_ID = @Leave_ID and For_Date = @for_Date And Cmp_Id=@Cmp_Id				
								
										-- Added Audit Trail By Ali 08102013 -- Start
										Select @New_Leave_Name = (select Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_Id)
										Select @New_Grd_Name = (Select Grd_Name from  T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @GRD_ID)
										set @OldValue = 'old Value' 
												+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_name,'') 
												+ '#' + 'Date :' + cast(ISNULL(@Old_for_date,'') as nvarchar(11)) 
												+ '#' + 'Leave Op Days :' + CONVERT(nvarchar(20),ISNULL(@Old_Leave_Op_Days,0))
												+ '#' + 'Leave Name :' + ISNULL(@Old_Leave_Name,'')
												+ '#' + 'Grade Name :' + ISNULL(@Old_Grd_Name,'')
												+ '#' + 
												'New Value' 
												+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_name,'') 
												+ '#' + 'Date :' + cast(ISNULL(@for_date,'') as nvarchar(11)) 
												+ '#' + 'Leave Op Days :' + CONVERT(nvarchar(20),ISNULL(@Leave_Op_Days,0))
												+ '#' + 'Leave Name :' + ISNULL(@New_Leave_Name,'')	
												+ '#' + 'Grade Name :' + ISNULL(@New_Grd_Name,'')				
												
										exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Opening',@OldValue,@Leave_Id,@User_Id,@IP_Address					
										-- Added Audit Trail By Ali 08102013 -- End
							
						End 
					--------------------
								-- Added Audit Trail By Ali 08102013 -- Start
										select @Old_Emp_name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
										select @Old_Leave_Id = Leave_ID
											,@Old_for_date = For_Date
											,@Old_Leave_Op_Days = Leave_Op_Days
											,@Old_GRD_ID = Grd_ID
										From T0095_LEAVE_OPENING WITH (NOLOCK) Where CMP_Id = @CMP_Id and Grd_ID = @Grd_ID and Emp_Id = @Emp_Id and Leave_ID = @Leave_ID and For_Date = @For_Date 
										Select @Old_Leave_Name = (select Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Old_Leave_Id)
										Select @Old_Grd_Name = (Select Grd_Name from  T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @Old_GRD_ID)
								-- Added Audit Trail By Ali 08102013 -- End
											
						UPDATE    Dbo.T0095_LEAVE_OPENING
						SET       Leave_Op_Days = @Leave_Op_Days
						where     CMP_Id = @CMP_Id and Grd_ID = @Grd_ID and Emp_Id = @Emp_Id and Leave_ID = @Leave_ID and For_Date = @For_Date --change by Falak on 25-Jan-2011 added for_Date condition
						
						
								-- Added Audit Trail By Ali 08102013 -- Start
										Select @New_Leave_Name = (select Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_Id)
										Select @New_Grd_Name = (Select Grd_Name from  T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @GRD_ID)
										set @OldValue = 'old Value' 
											+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_name,'') 
											+ '#' + 'Date :' + cast(ISNULL(@Old_for_date,'') as nvarchar(11)) 
											+ '#' + 'Leave Op Days :' + CONVERT(nvarchar(20),ISNULL(@Old_Leave_Op_Days,0))
											+ '#' + 'Leave Name :' + ISNULL(@Old_Leave_Name,'')
											+ '#' + 'Grade Name :' + ISNULL(@Old_Grd_Name,'')
											+ '#' + 
											'New Value' 
											+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_name,'') 
											+ '#' + 'Date :' + cast(ISNULL(@for_date,'') as nvarchar(11)) 
											+ '#' + 'Leave Op Days :' + CONVERT(nvarchar(20),ISNULL(@Leave_Op_Days,0))
											+ '#' + 'Leave Name :' + ISNULL(@New_Leave_Name,'')
											+ '#' + 'Grade Name :' + ISNULL(@New_Grd_Name,'')			
												
										exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Opening',@OldValue,@Leave_Id,@User_Id,@IP_Address					
								-- Added Audit Trail By Ali 08102013 -- End
				End
			else
				Begin
					SELECT @Leave_Op_ID = ISNULL(MAX(LEAVE_OP_ID),0) + 1 FROM Dbo.T0095_LEAVE_OPENING WITH (NOLOCK)
						
					INSERT INTO Dbo.T0095_LEAVE_OPENING
							(Leave_Op_ID, Emp_Id, Grd_ID, Cmp_ID, Leave_ID, For_Date, Leave_Op_Days)
					VALUES  (@Leave_Op_ID,@Emp_Id,@Grd_ID,@Cmp_ID,@Leave_ID,@For_Date,@Leave_Op_Days)
					
								-- Added Audit Trail By Ali 07102013 -- Start
								select @Old_Emp_name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
								Select @Old_Leave_Name = (select Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_Id)
								Select @Old_Grd_Name = (Select Grd_Name from  T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @GRD_ID)
								set @OldValue = 'New Value' 
												+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_name,'') 
												+ '#' + 'Date :' + cast(ISNULL(@for_date,'') as nvarchar(11)) 
												+ '#' + 'Leave Op Days :' + CONVERT(nvarchar(20),ISNULL(@Leave_Op_Days,0))
												+ '#' + 'Leave Name :' + ISNULL(@Old_Leave_Name,'')
												+ '#' + 'Grade Name :' + ISNULL(@Old_Grd_Name,'')  
													
								exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Opening',@OldValue,@Leave_Id,@User_Id,@IP_Address					
								-- Added Audit Trail By Ali 07102013 -- End					
				End
			return @Leave_Op_ID
			
		end
		ELSE IF @tran_type = 'D'  --Added by Jaina 04-03-2017
		Begin
		
			DECLARE @Temp_Max_Date datetime
			Declare @Leave_Close as numeric(18,2)=0
			Declare @After_delete_close as numeric(18,2)=0
			
			Select @Temp_Max_Date = Min(For_date) From dbo.T0140_leave_transaction WITH (NOLOCK) where Emp_Id=@EMP_ID And Cmp_Id=@CMP_ID And For_date >= @FOR_DATE And Leave_Id=@Leave_ID
			
			--select @Temp_Max_Date
			
			select @Leave_Close = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION  LT WITH (NOLOCK) Inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on
					LT.Leave_ID = LM.Leave_ID and Leave_Paid_Unpaid ='P' And Leave_Negative_Allow = 0
			Where emp_id = @EMP_ID and LT.leave_id = @Leave_ID and LT.CMP_ID = @CMP_ID and Leave_Closing > 0 and For_Date <= @Temp_Max_Date
			
			--Added by Jaina 17-03-2017
			IF exists(Select 1 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID=LAD.Leave_Application_ID  where Emp_ID=@emp_Id and la.Cmp_ID=@Cmp_Id And From_Date >= @FOR_DATE And Leave_Id=@Leave_ID)
			BEGIN
					RAISERROR ('Reference exists, record can''t delete.', 16, 2) 							
					return -1
			END
					
			
			IF isnull(@Leave_Close,0) > 0
				Begin
					
					DELETE FROM T0095_LEAVE_OPENING  where Leave_Op_ID = @Leave_Op_ID
					
					SELECT  top 1 @After_delete_close = Leave_Closing FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Leave_ID=@Leave_Id and For_Date > @FOR_DATE AND (Leave_Posting IS NULL OR Leave_Posting = 0)
					ORDER BY For_Date
					IF @After_delete_close < 0
					Begin
						RAISERROR ('Balance can not be negative.', 16, 2) 							
						return -1
					End
					
				End
			else
				BEGIN
					--Added by Jaina 17-03-2017
					IF Not Exists(Select 1 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID=LAD.Leave_Application_ID  where Emp_ID=@emp_Id and la.Cmp_ID=@Cmp_Id And From_Date >= @FOR_DATE And Leave_Id=@Leave_ID)
						BEGIN
							DELETE FROM T0095_LEAVE_OPENING  where Leave_Op_ID = @Leave_Op_ID
						END
					ELSE
						BEGIN
							RAISERROR ('Balance can not be negative.', 16, 2) 							
							return -1
						End
			
					
				End
			
	
			
		End
		RETURN




