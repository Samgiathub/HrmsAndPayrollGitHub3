

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0070_EMP_SCHEME_APP]
	 @Tran_ID			INT OUTPUT
	,@Emp_Tran_ID bigint
    ,@Emp_Application_ID int
	,@Cmp_ID			INT
	,@Scheme_ID			INT
	,@Type				VARCHAR(100)
	,@Effective_Date	DATETIME
	,@Tran_Type			VARCHAR(1)
	,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Tran_Type = 'I'
		BEGIN
			DECLARE @Current_Scheme_ID NUMERIC
			SELECT 	@Current_Scheme_ID = Scheme_ID
			FROM 	T0070_EMP_SCHEME_APP ES WITH (NOLOCK)
					INNER JOIN (SELECT 	Max(Approved_Date) As Approved_Date
								FROM 	T0070_EMP_SCHEME_APP ES1 WITH (NOLOCK)
								WHERE	ES1.Approved_Date <= @Effective_Date 
								AND [Type] = @Type AND
								 Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
								) ES1 ON ES.Approved_Date = ES1.Approved_Date
			WHERE	[Type] = @Type AND Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
								
			
			IF @Current_Scheme_ID = @Scheme_ID
				BEGIN
					Raiserror('@@Same Scheme is already assigned@@',16,2)
					RETURN
				END
			
			SELECT 	@Current_Scheme_ID = Scheme_ID
			FROM 	T0070_EMP_SCHEME_APP ES WITH (NOLOCK)
					INNER JOIN (SELECT 	Min(Approved_Date) As Approved_Date
								FROM 	T0070_EMP_SCHEME_APP ES1 WITH (NOLOCK)
								WHERE	ES1.Approved_Date > @Effective_Date AND [Type] = @Type 
								AND Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
								) ES1 ON ES.Approved_Date = ES1.Approved_Date
			WHERE	[Type] = @Type AND Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
			IF @Current_Scheme_ID IS NOT NULL AND @Current_Scheme_ID = @Scheme_ID
				BEGIN
					Raiserror('@@Same Scheme is already assigned@@',16,2)
					RETURN
				END
		
				Begin
					Select @Tran_ID = ISNULL(Tran_ID,0) From T0070_EMP_SCHEME_APP WITH (NOLOCK) Where Cmp_ID = @Cmp_ID 
					And Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
					Declare @tmpEffDate As Datetime
					If @Tran_ID = 0
						Begin
							Select @tmpEffDate = Date_Of_Join  From T0060_EMP_MASTER_APP  WITH (NOLOCK)
							where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
							if @tmpEffDate > @Effective_Date
								begin
									set @Effective_Date = @tmpEffDate
								end
						End
							
					SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0070_EMP_SCHEME_APP WITH (NOLOCK)
					Insert Into T0070_EMP_SCHEME_APP(Tran_ID,Emp_Tran_ID,Emp_Application_ID, Cmp_ID, Scheme_ID, Type, Approved_Emp_ID,Approved_Date,Rpt_Level)
						Values(@Tran_ID,@Emp_Tran_ID,@Emp_Application_ID, @Cmp_ID,  @Scheme_ID, @Type, @Approved_Emp_ID,@Approved_Date,@Rpt_Level)
				End
		END
	
	Else If @Tran_Type = 'D'
		Begin
			/* commented binal
			Create Table #Scheme_Leave 
			(
				Leave_Loan_ID numeric
			)
		
			DECLARE @Leave_Loan_ID varchar(max) 
			DECLARE @S_Effective_Date datetime
			
			SELECT	@Leave_Loan_ID = Leave,@S_Effective_Date= ES.Effective_Date
			From	T0050_Scheme_Detail SD
					INNER JOIN T0070_EMP_SCHEME_APP ES ON SD.Scheme_Id=ES.Scheme_ID					
			WHERE Sd.Cmp_Id = @Cmp_ID AND sd.Scheme_Id = @Scheme_ID
	       
			INSERT INTO #Scheme_Leave (Leave_Loan_ID)
			select  distinct cast(isnull(data,0) as numeric)as Leave_ID from dbo.Split(@Leave_Loan_ID,'#')
				
			if @Type = 'Leave'
				Begin
											
					IF Exists ( SELECT L.Leave_Application_ID,L.Emp_ID,LD.Leave_ID FROM T0100_LEAVE_APPLICATION L INNER JOIN
								  T0110_LEAVE_APPLICATION_DETAIL LD ON L.Leave_Application_ID = ld.Leave_Application_ID INNER JOIN
								  #Scheme_Leave SL ON SL.Leave_Loan_ID = LD.Leave_ID
					WHERE L.Cmp_ID=@Cmp_ID  and L.Emp_ID=@Emp_ID AND L.Application_Date >= @S_Effective_Date)
					BEGIN
							Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
							return
					END
					
					
					if exists (SELECT LAD.Leave_ID FROM T0120_LEAVE_APPROVAL LA INNER JOIN
									  T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID= LAD.Leave_Approval_ID INNER JOIN
									   #Scheme_Leave SL ON SL.Leave_Loan_ID = LAD.Leave_ID
								WHERE lad.Cmp_ID=@Cmp_ID AND LA.Emp_ID = @Emp_ID AND LA.Approval_Date >= @S_Effective_Date)
					BEGIN
							Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
							return
					END
				END
			ELSE if @Type = 'Loan'
				Begin
					if exists (SELECT L.Emp_ID,L.Loan_ID FROM T0100_LOAN_APPLICATION L INNER JOIN
								#Scheme_Leave SL on SL.Leave_Loan_ID =  L.Loan_ID
								where Emp_ID=@Emp_ID AND L.Cmp_ID = @Cmp_ID AND L.Loan_App_Date >= @S_Effective_Date )
					BEGIN
						Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
							return
					END
					
					IF exists(SELECT * FROM T0120_LOAN_APPROVAL LA INNER JOIN
								#Scheme_Leave SL on SL.Leave_Loan_ID =  LA.Loan_IDR
							 WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND LA.Loan_Apr_Date >= @S_Effective_Date)
					BEGIN
						Raiserror('@@Scheme can''t be Deleted Reference Exist@@',16,2)
						return
					END
				End
			*/
			
			Delete From T0070_EMP_SCHEME_APP Where Tran_ID = @Tran_ID
		End
END


