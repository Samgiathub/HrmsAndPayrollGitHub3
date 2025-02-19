

CREATE PROCEDURE [dbo].[P0090_EMP_REPORTING_DETAIL]
	@Row_ID numeric(18,0)  output
	,@Emp_ID numeric(18,0)
	,@Cmp_ID numeric(18,0)
	,@Reporting_To varchar(30)
	,@R_Emp_ID numeric
	,@Reporting_Method varchar(20)
	,@tran_type varchar(1)
	,@Login_Id numeric(18,0)=0	 -- Rathod '18/04/2012'	 
	,@User_Id numeric(18,0) = 0 -- Added for Audit Trail by Ali 09102013
	,@IP_Address varchar(30)= '' -- Added for Audit Trail by Ali 09102013 
	,@Effect_Date	Datetime = NULL	--Ankit 28012015
AS

SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	-- Added for Audit Trail by Ali 09102013 -- Start
	Declare @Old_Emp_Id as numeric
	Declare @Old_R_Emp_ID numeric
	Declare @Old_Emp_Name as varchar(100)
	Declare @Old_R_Emp_Name as varchar(100)
	Declare @New_Emp_Name as varchar(100)
	Declare @New_R_Emp_Name as varchar(100)
	Declare @Old_Reporting_To varchar(30)
	Declare @Old_Reporting_Method varchar(20)
	Declare @OldValue as varchar(max)
	Declare @OldEffect_Date as varchar(100)
										
	Set @Old_Emp_Id = 0
	Set @Old_R_Emp_ID = 0
	Set @Old_Emp_Name = ''
	Set @Old_R_Emp_Name = ''
	Set @New_Emp_Name = ''
	Set @New_R_Emp_Name = ''
	Set @Old_Reporting_To = ''
	Set @Old_Reporting_Method = ''
	Set @OldValue = ''			
	Set @OldEffect_Date = ''											
	-- Added for Audit Trail by Ali 09102013 -- End
							
	if @R_Emp_ID = 0 
		set @R_Emp_ID = null
	if @emp_id = 0 
		set @Emp_id = null

	--Ankit 13012014--
	Declare @Current_Sup_id numeric
	set @Current_Sup_id = 0
	select @Current_Sup_id = New_R_Emp_id from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY WITH (NOLOCK) where Emp_Id=@Emp_ID  and Cmp_ID = @cmp_id
	--Ankit 13012014--

	--For Old Values in Audit Trail
	SELECT * INTO #T0090_EMP_REPORTING_DETAIL_DELETED FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Row_ID = @Row_ID
	 
		
		
	If @tran_type ='i' 
		BEGIN
			if Not Exists(select Row_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID and R_Emp_ID = @R_Emp_ID and Reporting_Method = @Reporting_Method and Effect_Date = @Effect_Date)
				begin
					if Not @Emp_ID = @R_Emp_ID
						begin
							select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
									
							INSERT INTO T0090_EMP_REPORTING_DETAIL
												(Emp_ID, Row_ID, Cmp_ID, Reporting_To, R_Emp_ID, Reporting_Method,Effect_Date)
							VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Reporting_To,@R_Emp_ID,@Reporting_Method,@Effect_Date)
								
						
								
							INSERT INTO T0090_EMP_REPORTING_DETAIL_Clone
												(Emp_ID, Row_ID, Cmp_ID, Reporting_To, R_Emp_ID, Reporting_Method,System_Date,Login_Id)
							VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Reporting_To,@R_Emp_ID,@Reporting_Method,GETDATE(),@Login_Id)	
								
							--Ankit 13012014--
							INSERT INTO T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY
										( Emp_id, Old_R_Emp_id, New_R_Emp_id, Cmp_id,  Comment)
							VALUES      (@Emp_id,isnull(@Current_Sup_id,0),@R_Emp_ID,@cmp_id,'Emp_Master')
							--Ankit 13012014--
										
							DECLARE @SMS_New_Emp_Code Varchar(20)
							Set @SMS_New_Emp_Code = ''
										
							DECLARE @SMS_Mobile_No Varchar(10)
							Set @SMS_Mobile_No = ''
										
							Declare @SMS_Emp_Name Varchar(100)
							Set @SMS_Emp_Name = ''
										
							---- Added for Audit Trail by Ali 09102013 -- Start
							--Select @Old_Emp_Name = ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') , @SMS_Emp_Name = Emp_First_Name , @SMS_Mobile_No = Mobile_No  from T0080_EMP_MASTER where Emp_ID = @Emp_ID
							--Select @Old_R_Emp_Name = ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,''), @SMS_New_Emp_Code = Alpha_Emp_Code  from T0080_EMP_MASTER where Emp_ID = @R_Emp_ID
										
							--set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
							--		+ '#' + 'Reporting Manager :' + ISNULL(@Old_R_Emp_Name,'') 																						
							--		+ '#' + 'Reporting To :' +ISNULL(@Reporting_To,'') 
							--		+ '#' + 'Reporting Method :' + ISNULL(@Reporting_Method,'') 
							--		+ '#' + 'Effect Date :' + Cast(ISNULL(@Effect_Date,'') as nvarchar(11))
																			
							--exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Reporting Manager',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1 
							---- Added for Audit Trail by Ali 09102013 -- End
										
							DECLARE @SMS_old_Emp_ID Numeric
							Set @SMS_old_Emp_ID = 0
										
							SELECT @SMS_old_Emp_ID = R_Emp_ID
							From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
								(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
									WHERE Effect_Date < @Effect_Date And Emp_ID = @Emp_ID
									GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
							WHERE ERD.Emp_ID = @Emp_ID
										
							Declare @SMS_old_Emp_Code as varchar(20)
							Set @SMS_old_Emp_Code = ''
										
							Select @SMS_old_Emp_Code = Alpha_Emp_Code From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @SMS_old_Emp_ID
										
										
							DECLARE @SMS_Text Varchar(Max)
							Set @SMS_Text = ''
							Set @SMS_Text = 'Dear ' + @SMS_Emp_Name + ', your reporting manager '+ @SMS_old_Emp_Code + ' is Change from ' + CONVERT(VARCHAR(11), @Effect_Date, 103) +  ' New reporting Manager is ' + @SMS_New_Emp_Code + '  Regards, Team - HR'
										
							Declare @For_date datetime
							Set @For_date = CONVERT(DATE,GETDATE())
										
							Exec P0100_SMS_Transcation 0,@Cmp_ID,@Emp_ID,'Reporting Manager change',@SMS_Text
						end
					else
						begin
							set @Row_ID = 0
						end
				end 
			else
				begin
					set @Row_ID = 0
				end
		end
	else if @tran_type ='u' 
		BEGIN
				
			---- Added for Audit Trail by Ali 09102013 -- Start
			--Select 
			--@Old_Emp_Id = Emp_ID
			--,@Old_R_Emp_ID = R_Emp_ID
			--,@Old_Reporting_To= Reporting_To
			--,@Old_Reporting_Method = Reporting_Method
			--,@OldEffect_Date = Effect_Date
			--From T0090_EMP_REPORTING_DETAIL
			--where Row_ID = @Row_ID
										
			--Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Old_Emp_Id)
			--Set @Old_R_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Old_R_Emp_ID)
			--Set @New_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Emp_ID)
			--Set @New_R_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @R_Emp_ID)
										
										
			--set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
			--		+ '#' + 'Reporting Manager :' + ISNULL(@Old_R_Emp_Name,'') 																						
			--		+ '#' + 'Reporting To :' +ISNULL(@Old_Reporting_To,'') 
			--		+ '#' + 'Reporting Method :' + ISNULL(@Old_Reporting_Method,'') 
			--		+ '#' + 'Effect Date :' + Cast(ISNULL(@OldEffect_Date,'') As nvarchar(11))
			--		+ '#' +
			--		+ 'New Value' + '#'+ 'Employee Name :' + ISNULL( @New_Emp_Name,'') 
			--		+ '#' + 'Reporting Manager :' + ISNULL(@New_R_Emp_Name,'') 																						
			--		+ '#' + 'Reporting To :' +ISNULL(@Reporting_To,'') 
			--		+ '#' + 'Reporting Method :' + ISNULL(@Reporting_Method,'') 
			--		+ '#' + 'Effect Date :' + Cast(ISNULL(@Effect_Date,'') As nVarchar(11))
			--exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Reporting Manager',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1 
			---- Added for Audit Trail by Ali 09102013 -- End
						
										
			UPDATE    T0090_EMP_REPORTING_DETAIL
			SET              Cmp_ID = @Cmp_ID, Reporting_To = @Reporting_To, R_Emp_ID = @R_Emp_ID, Reporting_Method = @Reporting_Method , Effect_Date = @Effect_Date
			WHERE     Emp_ID = @Emp_ID AND Row_ID = @Row_ID
					
			INSERT INTO T0090_EMP_REPORTING_DETAIL_Clone
						(Emp_ID, Row_ID, Cmp_ID, Reporting_To, R_Emp_ID, Reporting_Method,System_Date,Login_Id)
			VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Reporting_To,@R_Emp_ID,@Reporting_Method,GETDATE(),@Login_Id)	
										
					
			--Ankit 13012014--
			INSERT INTO T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY
						( Emp_id, Old_R_Emp_id, New_R_Emp_id, Cmp_id,  Comment)
			VALUES      (@Emp_id,isnull(@Current_Sup_id,0),@R_Emp_ID,@cmp_id,'Emp_Master')
			--Ankit 13012014--
					
		end
	else if @tran_type ='d'
		BEGIN
	
	
			---- Added for Audit Trail by Ali 09102013 -- Start
			--Select 
			--@Old_Emp_Id = Emp_ID
			--,@Old_R_Emp_ID = R_Emp_ID
			--,@Old_Reporting_To= Reporting_To
			--,@Old_Reporting_Method = Reporting_Method
			--,@OldEffect_Date = Effect_Date
			--From T0090_EMP_REPORTING_DETAIL
			--where Row_ID = @Row_ID
						
			--Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Old_Emp_Id)
			--Set @Old_R_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Old_R_Emp_ID)
						
			--set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
			--		+ '#' + 'Reporting Manager :' + ISNULL(@Old_R_Emp_Name,'') 																						
			--		+ '#' + 'Reporting To :' +ISNULL(@Old_Reporting_To,'') 
			--		+ '#' + 'Reporting Method :' + ISNULL(@Old_Reporting_Method,'') 
			--		+ '#' + 'Effect Date :' + Cast(ISNULL(@OldEffect_Date,'') As nvarchar(11))
			--exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Reporting Manager',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1 
			---- Added for Audit Trail by Ali 09102013 -- End
						
			----DELETE  from T0090_EMP_REPORTING_DETAIL where Row_ID = @Row_ID
						
			--New Code Added By Ramiz on 20/01/2016
						
		If @Reporting_Method <> ''
			BEGIN
				DELETE  from T0090_EMP_REPORTING_DETAIL where Row_ID = @Row_ID and Reporting_Method = @Reporting_Method	--Added By Ramiz on 20/01/2016
			End
		Else
			BEGIN
				DELETE  from T0090_EMP_REPORTING_DETAIL where Row_ID = @Row_ID 
			End
		--Ended By Ramiz on 20/01/2016
	END
		
	
	-------Update Reporing Manger ID on Emp_Master Table	--Ankit 28012015
	--Old Code Commented by Ramiz on 22/01/2019--

	/*
		If We are assigning Indirect Reporting Manager with Some Effective Date (say 01-01-2019) , and if Direct Reporting Manager with Same Date Exists , 
		then Emp_Superior should not be Changed to Indirect in Employee Profile.
		
		But in Reverse Case (i.e) Indirect Manager with 01/01/2019 is Assigned , and if with same date New Direct Manager is Assigned , then that should be Changed in Emp_Superior
	*/
	/*
		--SELECT @RE_Emp_ID = R_Emp_ID
		--From T0090_EMP_REPORTING_DETAIL ERD 
		--	INNER JOIN 
		--		(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
		--		 FROM T0090_EMP_REPORTING_DETAIL
		--		 WHERE Effect_Date <= @Effect_Date And Emp_ID = @Emp_ID
		--		 GROUP BY emp_ID
		--		) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
		--WHERE ERD.Emp_ID = @Emp_ID
		
	*/
	
	--New Condition Added By Ramiz as Below on 22/01/2019--
	DECLARE @RE_Emp_ID NUMERIC
	SET @RE_Emp_ID = 0

	--First Checking "DIRECT REPORTING MANAGER" , if Available then will keep the same or Else , will go for "INDIRECT REPORTING MANAGER"
	SELECT TOP 1 @RE_Emp_ID = R_Emp_ID
	FROM
		(
			SELECT R_Emp_ID , 1 AS SortCol
			From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
				INNER JOIN 
					(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
					 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					 WHERE Effect_Date <= @Effect_Date And Emp_ID = @Emp_ID
					 GROUP BY emp_ID
					) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
			WHERE ERD.Emp_ID = @Emp_ID and Reporting_Method = 'Direct'
			UNION
			SELECT R_Emp_ID , 2 as SortCol
			From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
				INNER JOIN 
					(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
					 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					 WHERE Effect_Date <= @Effect_Date And Emp_ID = @Emp_ID
					 GROUP BY emp_ID
					) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
			WHERE ERD.Emp_ID = @Emp_ID and Reporting_Method = 'InDirect'
		)QRY
	ORDER BY SORTCOL

	IF @RE_Emp_ID > 0
		BEGIN
			UPDATE T0080_EMP_MASTER SET Emp_Superior = @RE_Emp_ID WHERE Emp_ID = @Emp_ID
		END
	Else --Condition Added by Sumit to pass null when no employee in Reporttin Detail 15042015
		Begin
		UPDATE T0080_EMP_MASTER SET Emp_Superior = null WHERE Emp_ID = @Emp_ID
		End	
	
	
	--For New Values in Audit Trail
	SELECT * INTO #T0090_EMP_REPORTING_DETAIL_INSERTED FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Row_ID = @Row_ID
		
	EXEC P9999_AUDIT_LOG @TableName='T0090_EMP_REPORTING_DETAIL', @IDFieldName='Emp_ID',@Audit_Module_Name='Employee Reporting Manager',
		@User_Id=@User_Id,@IP_Address=@IP_Address,@MandatoryFields='Row_ID,R_Emp_ID,Reporting_Method,Effect_Date',
		@Audit_Change_Type=@Tran_Type	
	-------Update Reporing Manger ID on Emp_Master Table	--Ankit 28012015
		
	RETURN




