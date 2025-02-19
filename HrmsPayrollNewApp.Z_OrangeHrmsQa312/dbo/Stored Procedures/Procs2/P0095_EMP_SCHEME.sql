



CREATE PROCEDURE [dbo].[P0095_EMP_SCHEME]
	 @Tran_ID			NUMERIC(18,0) OUTPUT
	,@Cmp_ID			NUMERIC(18,0)
	,@Emp_ID			NUMERIC(18,0)
	,@Scheme_ID			NUMERIC(18,0)
	,@Type				VARCHAR(100)
	,@Effective_Date	DATETIME
	,@Tran_Type			VARCHAR(1)
	,@IsMakerChecker    BIT = null
AS
BEGIN
	SET NOCOUNT ON;
	IF @Tran_Type = 'I'
		BEGIN
			  --added by mansi start 15-03-22
		if @Type='File Management'
		  begin 
		    begin 

		 --  print @Type
			DECLARE @Current_Scheme_ID1 NUMERIC
			DECLARE @EffDate1 datetime

			SELECT 	@Current_Scheme_ID1 = Scheme_ID , @EffDate1=ES1.Effective_Date  -- Added By Deepal Bhai and Sajid 
			FROM 	T0095_EMP_SCHEME ES With (NOLOCK)
					INNER JOIN (SELECT 	Max(Effective_Date) As Effective_Date
								FROM 	T0095_EMP_SCHEME ES1 With (NOLOCK)
								WHERE	ES1.Effective_Date <= @Effective_Date AND [Type] = @Type AND Emp_ID=@Emp_ID
								) ES1 ON ES.Effective_Date = ES1.Effective_Date
			WHERE	[Type] = @Type AND Emp_ID=@Emp_ID
			declare  @emp_full_name varchar(max)
			select @emp_full_name=Emp_Full_Name from T0080_EMP_MASTER where emp_id=@Emp_ID
			--print @emp_full_name
			--print @Current_Scheme_ID1
			--print @EffDate1
			declare  @error_msg varchar(max)
			set @error_msg='@@ Scheme is already assigned to '+@emp_full_name+'on Same Date @@'
			IF  @EffDate1 = @Effective_Date  -- Added By Deepal Bhai and Sajid 
				BEGIN
					--Raiserror('@@ Scheme is already assigned on Same Date @@',16,2)
					Raiserror(@error_msg,16,2)
					RETURN
				END
			IF @Current_Scheme_ID1 = @Scheme_ID and @EffDate1 = @Effective_Date  -- Added By Deepal Bhai and Sajid 
				BEGIN
					Raiserror('@@Same Scheme is already assigned@@',16,2)
					RETURN
				END
			
			SELECT 	@Current_Scheme_ID1 = Scheme_ID  , @EffDate1=ES1.Effective_Date  -- Added By Deepal Bhai and Sajid 
			FROM 	T0095_EMP_SCHEME ES With (NOLOCK)
					INNER JOIN (SELECT 	Min(Effective_Date) As Effective_Date
								FROM 	T0095_EMP_SCHEME ES1 With (NOLOCK)
								WHERE	ES1.Effective_Date > @Effective_Date AND [Type] = @Type AND Emp_ID=@Emp_ID
								) ES1 ON ES.Effective_Date = ES1.Effective_Date
			WHERE	[Type] = @Type AND Emp_ID=@Emp_ID
			IF @Current_Scheme_ID1 IS NOT NULL AND @Current_Scheme_ID1 = @Scheme_ID and @EffDate1 = @Effective_Date  -- Added By Deepal Bhai and Sajid 
				BEGIN
					Raiserror('@@Same Scheme is already assigned@@',16,2)
					RETURN
				END
			-- Comment by nilesh patel on 08102015 --Start
				--If Exists(Select Tran_ID From T0095_EMP_SCHEME  Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Effective_Date = @Effective_Date And Type = @Type)
				--	Begin
				--		Update T0095_EMP_SCHEME
				--			Set Type = @Type, Scheme_ID = @Scheme_ID
				--			Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Effective_Date = @Effective_Date And Type = @Type
				--	End
				--Else 
			-- Comment by nilesh patel on 08102015 --End
			--If Exists (Select Tran_ID From T0095_EMP_SCHEME  Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Effective_Date >= @Effective_Date And Type = @Type) --Added Equal to Condition after discussion with Hardik Bhai, same date same,same scheme will not be assigned its create duplicate records on 04082016
			--	Begin
			--		Set @Tran_ID = 0			
			--	End
			--Else
				Begin
					Select @Tran_ID = ISNULL(Tran_ID,0) From T0095_EMP_SCHEME With (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
					Declare @tmpEffDate1 As Datetime
					If @Tran_ID = 0
						Begin
							Select @tmpEffDate1 = Date_Of_Join  From T0080_EMP_MASTER With (NOLOCK) where Emp_ID = @Emp_ID
							if @tmpEffDate1 > @Effective_Date
								begin
									set @Effective_Date = @tmpEffDate1
								end
						End
							
					SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_EMP_SCHEME With (NOLOCK)
					Insert Into T0095_EMP_SCHEME(Tran_ID, Cmp_ID, Emp_ID, Scheme_ID, Type, Effective_Date,IsMakerChecker)
						Values(@Tran_ID, @Cmp_ID, @Emp_ID, @Scheme_ID, @Type, @Effective_Date,@IsMakerChecker)
				End
				end	
		  end 
		  else 
		  --added by mansi end 15-03-22
		  begin 
		  
			DECLARE @Current_Scheme_ID NUMERIC
			DECLARE @EffDate datetime

			SELECT 	@Current_Scheme_ID = Scheme_ID , @EffDate=ES1.Effective_Date  -- Added By Deepal Bhai and Sajid 
			FROM 	T0095_EMP_SCHEME ES With (NOLOCK)
					INNER JOIN (SELECT 	Max(Effective_Date) As Effective_Date
								FROM 	T0095_EMP_SCHEME ES1 With (NOLOCK)
								WHERE	ES1.Effective_Date <= @Effective_Date AND [Type] = @Type AND Emp_ID=@Emp_ID
								) ES1 ON ES.Effective_Date = ES1.Effective_Date
			WHERE	[Type] = @Type AND Emp_ID=@Emp_ID
								

			IF @Current_Scheme_ID = @Scheme_ID and @EffDate = @Effective_Date  -- Added By Deepal Bhai and Sajid 
				BEGIN
					Raiserror('@@Same Scheme is already assigned@@',16,2)
					RETURN
				END
				 IF @Type='Exit' and @EffDate = @Effective_Date --ronakb311224
				BEGIN
					Raiserror('@@Same Type is already assigned@@',16,2)
					RETURN
				END
			SELECT 	@Current_Scheme_ID = Scheme_ID  , @EffDate=ES1.Effective_Date  -- Added By Deepal Bhai and Sajid 
			FROM 	T0095_EMP_SCHEME ES With (NOLOCK)
					INNER JOIN (SELECT 	Min(Effective_Date) As Effective_Date
								FROM 	T0095_EMP_SCHEME ES1 With (NOLOCK)
								WHERE	ES1.Effective_Date > @Effective_Date AND [Type] = @Type AND Emp_ID=@Emp_ID
								) ES1 ON ES.Effective_Date = ES1.Effective_Date
			WHERE	[Type] = @Type AND Emp_ID=@Emp_ID
			IF @Current_Scheme_ID IS NOT NULL AND @Current_Scheme_ID = @Scheme_ID and @EffDate = @Effective_Date  -- Added By Deepal Bhai and Sajid 
				BEGIN
					Raiserror('@@Same Scheme is already assigned@@',16,2)
					RETURN
				END
			
			-- Comment by nilesh patel on 08102015 --Start
				--If Exists(Select Tran_ID From T0095_EMP_SCHEME  Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Effective_Date = @Effective_Date And Type = @Type)
				--	Begin
				--		Update T0095_EMP_SCHEME
				--			Set Type = @Type, Scheme_ID = @Scheme_ID
				--			Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Effective_Date = @Effective_Date And Type = @Type
				--	End
				--Else 
			-- Comment by nilesh patel on 08102015 --End
			--If Exists (Select Tran_ID From T0095_EMP_SCHEME  Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Effective_Date >= @Effective_Date And Type = @Type) --Added Equal to Condition after discussion with Hardik Bhai, same date same,same scheme will not be assigned its create duplicate records on 04082016
			--	Begin
			--		Set @Tran_ID = 0			
			--	End
			--Else
				Begin
					Select @Tran_ID = ISNULL(Tran_ID,0) From T0095_EMP_SCHEME With (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
					Declare @tmpEffDate As Datetime
					If @Tran_ID = 0
						Begin
							Select @tmpEffDate = Date_Of_Join  From T0080_EMP_MASTER With (NOLOCK) where Emp_ID = @Emp_ID
							if @tmpEffDate > @Effective_Date
								begin
									set @Effective_Date = @tmpEffDate
								end
						End
							
					SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_EMP_SCHEME With (NOLOCK)
					Insert Into T0095_EMP_SCHEME(Tran_ID, Cmp_ID, Emp_ID, Scheme_ID, Type, Effective_Date,IsMakerChecker)
						Values(@Tran_ID, @Cmp_ID, @Emp_ID, @Scheme_ID, @Type, @Effective_Date,@IsMakerChecker)
				End
			end
		END
	
	Else If @Tran_Type = 'D'
		Begin
			--Added by Jaina 17-11-2016 Start
			Create Table #Scheme_Leave 
			(
				Leave_Loan_ID numeric
			)
		
			DECLARE @Leave_Loan_ID varchar(max) 
			DECLARE @S_Effective_Date datetime
			
			SELECT	@Leave_Loan_ID = Leave,@S_Effective_Date= ES.Effective_Date
			From	T0050_Scheme_Detail SD With (NOLOCK)
					INNER JOIN T0095_EMP_SCHEME ES With (NOLOCK) ON SD.Scheme_Id=ES.Scheme_ID					
			WHERE Sd.Cmp_Id = @Cmp_ID AND sd.Scheme_Id = @Scheme_ID
	       
			INSERT INTO #Scheme_Leave (Leave_Loan_ID)
			select  distinct cast(isnull(data,0) as numeric)as Leave_ID from dbo.Split(@Leave_Loan_ID,'#')
				
			if @Type = 'Leave'
				Begin
											
					IF Exists ( SELECT L.Leave_Application_ID,L.Emp_ID,LD.Leave_ID FROM T0100_LEAVE_APPLICATION L With (NOLOCK) INNER JOIN
								  T0110_LEAVE_APPLICATION_DETAIL LD With (NOLOCK) ON L.Leave_Application_ID = ld.Leave_Application_ID INNER JOIN
								  #Scheme_Leave SL ON SL.Leave_Loan_ID = LD.Leave_ID
					WHERE L.Cmp_ID=@Cmp_ID  and L.Emp_ID=@Emp_ID AND L.Application_Date >= @S_Effective_Date)
					BEGIN
							Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
							return
					END
					
					
					if exists (SELECT LAD.Leave_ID FROM T0120_LEAVE_APPROVAL LA With (NOLOCK) INNER JOIN
									  T0130_LEAVE_APPROVAL_DETAIL LAD With (NOLOCK) on LA.Leave_Approval_ID= LAD.Leave_Approval_ID INNER JOIN
									   #Scheme_Leave SL ON SL.Leave_Loan_ID = LAD.Leave_ID
								WHERE lad.Cmp_ID=@Cmp_ID AND LA.Emp_ID = @Emp_ID AND LA.Approval_Date >= @S_Effective_Date)
					BEGIN
							Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
							return
					END
				END
			ELSE if @Type = 'Loan'
				Begin
					if exists (SELECT L.Emp_ID,L.Loan_ID FROM T0100_LOAN_APPLICATION L With (NOLOCK) INNER JOIN
								#Scheme_Leave SL on SL.Leave_Loan_ID =  L.Loan_ID
								where Emp_ID=@Emp_ID AND L.Cmp_ID = @Cmp_ID AND L.Loan_App_Date >= @S_Effective_Date )
					BEGIN
						Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
							return
					END
					
					IF exists(SELECT * FROM T0120_LOAN_APPROVAL LA With (NOLOCK) INNER JOIN
								#Scheme_Leave SL on SL.Leave_Loan_ID =  LA.Loan_ID
							 WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND LA.Loan_Apr_Date >= @S_Effective_Date)
					BEGIN
						Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
						return
					END
				End
			--Added by Jaina 17-11-2016 End
			
			Delete From T0095_EMP_SCHEME Where Tran_ID = @Tran_ID
		End
END




