
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_REPORTING_DETAIL_APP]
    @Row_ID int  output
    ,@Emp_Tran_ID bigint 
	,@Emp_Application_ID int	
	,@Cmp_ID int
	,@Reporting_To varchar(30)
	,@R_Emp_ID int
	,@Reporting_Method varchar(20)
	,@tran_type varchar(1)
	,@Login_Id numeric(18,0)=0	 -- Rathod '18/04/2012'	 
	,@User_Id int = 0 -- Added for Audit Trail by Ali 09102013
	,@IP_Address varchar(30)= '' -- Added for Audit Trail by Ali 09102013 
	,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
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
	--if @emp_id = 0 
	--	set @Emp_id = null
	Set @Effect_Date= @Approved_Date
	--Ankit 13012014--
	Declare @Current_Sup_id numeric
	set @Current_Sup_id = 0
	/*
	select @Current_Sup_id = New_R_Emp_id from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY 
	where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
	--Emp_Id=@Emp_ID  
	and	Cmp_ID = @cmp_id
	--Ankit 13012014--
*/
	--For Old Values in Audit Trail
	SELECT * INTO #T0065_EMP_REPORTING_DETAIL_APP_DELETED FROM T0065_EMP_REPORTING_DETAIL_APP WITH (NOLOCK)
	 WHERE Emp_Tran_ID=@Emp_Tran_ID AND Row_ID = @Row_ID
	 --Emp_Id=@Emp_ID  
	 
	 
	Select @Effect_Date=Date_Of_Join	
	From T0060_EMP_MASTER_APP WITH (NOLOCK)
	WHERE   Emp_Tran_ID = @Emp_Tran_ID 	
		
	If @tran_type ='i' 
		BEGIN
			if Not Exists(select Row_ID from T0065_EMP_REPORTING_DETAIL_APP WITH (NOLOCK)
			WHERE Emp_Tran_ID=@Emp_Tran_ID 
			--Emp_ID = @Emp_ID 
			and R_Emp_ID = @R_Emp_ID and Reporting_Method = @Reporting_Method)
				begin
				
							select @Row_ID = isnull(max(Row_ID),0) + 1 from T0065_EMP_REPORTING_DETAIL_APP WITH (NOLOCK)
								
							
								
							INSERT INTO T0065_EMP_REPORTING_DETAIL_APP
							(Emp_Tran_ID,Emp_Application_ID, Row_ID, Cmp_ID, Reporting_To, R_Emp_ID, Reporting_Method,Approved_Emp_ID,Approved_Date,Rpt_Level)
							VALUES(@Emp_Tran_ID,@Emp_Application_ID,@Row_ID,@Cmp_ID,@Reporting_To,@R_Emp_ID,@Reporting_Method,@Approved_Emp_ID,@Effect_Date,@Rpt_Level)
			
							DECLARE @SMS_New_Emp_Code Varchar(20)
							Set @SMS_New_Emp_Code = ''
										
							DECLARE @SMS_Mobile_No Varchar(10)
							Set @SMS_Mobile_No = ''
										
							Declare @SMS_Emp_Name Varchar(100)
							Set @SMS_Emp_Name = ''
													
							DECLARE @SMS_old_Emp_ID Numeric
							Set @SMS_old_Emp_ID = 0
								
							SELECT @SMS_old_Emp_ID = R_Emp_ID
							From T0065_EMP_REPORTING_DETAIL_APP ERD WITH (NOLOCK) INNER JOIN 
								(SELECT MAX(Approved_Date) as Approved_Date, Emp_Tran_ID from T0065_EMP_REPORTING_DETAIL_APP WITH (NOLOCK)
									WHERE Approved_Date < @Effect_Date And 
									 Emp_Tran_ID = @Emp_Tran_ID
									GROUP BY Emp_Tran_ID) RQry on 									
									ERD.Emp_Tran_ID = RQry.Emp_Tran_ID and 
									ERD.Approved_Date = RQry.Approved_Date and ERD.Emp_Application_ID=@Emp_Application_ID
							WHERE  ERD.Emp_Tran_ID=@Emp_Tran_ID and ERD.Emp_Application_ID=@Emp_Application_ID
							
			
					
				end 
				
			else
				begin
					set @Row_ID = 0
				end
		end
	else if @tran_type ='u' 
		BEGIN
			
			UPDATE    T0065_EMP_REPORTING_DETAIL_APP
			SET       Cmp_ID = @Cmp_ID, Reporting_To = @Reporting_To, R_Emp_ID = @R_Emp_ID,
			 Reporting_Method = @Reporting_Method , Approved_Date = @Effect_Date,
             Approved_Emp_ID=@Approved_Emp_ID,Rpt_Level=@Rpt_Level
			WHERE    Emp_Tran_ID=@Emp_Tran_ID 
			-- Emp_ID = @Emp_ID 
			AND Row_ID = @Row_ID
					
					/* commented binal
			INSERT INTO T0065_EMP_REPORTING_DETAIL_APP_Clone
						(Emp_ID, Row_ID, Cmp_ID, Reporting_To, R_Emp_ID, Reporting_Method,System_Date,Login_Id)
			VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Reporting_To,@R_Emp_ID,@Reporting_Method,GETDATE(),@Login_Id)	
									
					--need to ask for Modify
			--Ankit 13012014--
			
			
			INSERT INTO T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY
						( Emp_id, Old_R_Emp_id, New_R_Emp_id, Cmp_id,  Comment)
			VALUES      (@Emp_id,isnull(@Current_Sup_id,0),@R_Emp_ID,@cmp_id,'Emp_Master')
			*/
			--Ankit 13012014--
					
		end
	else if @tran_type ='d'
		BEGIN
	
						
		If @Reporting_Method <> ''
			BEGIN
				DELETE  from T0065_EMP_REPORTING_DETAIL_APP 
				where Row_ID = @Row_ID and Reporting_Method = @Reporting_Method	 and
				Emp_Tran_ID=@Emp_Tran_ID 
				--Added By Ramiz on 20/01/2016
			End
		Else
			BEGIN
				DELETE  from T0065_EMP_REPORTING_DETAIL_APP 
				where Row_ID = @Row_ID and
				Emp_Tran_ID=@Emp_Tran_ID 
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
		--From T0065_EMP_REPORTING_DETAIL_APP ERD 
		--	INNER JOIN 
		--		(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
		--		 FROM T0065_EMP_REPORTING_DETAIL_APP
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
							From T0065_EMP_REPORTING_DETAIL_APP ERD WITH (NOLOCK) INNER JOIN 
								(SELECT MAX(Approved_Date) as Approved_Date, Emp_Tran_ID from T0065_EMP_REPORTING_DETAIL_APP WITH (NOLOCK)
									WHERE Approved_Date <= @Effect_Date And 
									 Emp_Tran_ID = @Emp_Tran_ID
									GROUP BY Emp_Tran_ID) RQry on 									
									ERD.Emp_Tran_ID = RQry.Emp_Tran_ID and 
									ERD.Approved_Date = RQry.Approved_Date and ERD.Emp_Application_ID=@Emp_Application_ID
							WHERE  ERD.Emp_Tran_ID=@Emp_Tran_ID and ERD.Emp_Application_ID=@Emp_Application_ID
							and Reporting_Method = 'Direct'
							
							UNION
							SELECT R_Emp_ID , 1 AS SortCol
							From T0065_EMP_REPORTING_DETAIL_APP ERD WITH (NOLOCK) INNER JOIN 
								(SELECT MAX(Approved_Date) as Approved_Date, Emp_Tran_ID from T0065_EMP_REPORTING_DETAIL_APP WITH (NOLOCK)
									WHERE Approved_Date <= @Effect_Date And 
									 Emp_Tran_ID = @Emp_Tran_ID
									GROUP BY Emp_Tran_ID) RQry on 									
									ERD.Emp_Tran_ID = RQry.Emp_Tran_ID and 
									ERD.Approved_Date = RQry.Approved_Date and ERD.Emp_Application_ID=@Emp_Application_ID
							WHERE  ERD.Emp_Tran_ID=@Emp_Tran_ID and ERD.Emp_Application_ID=@Emp_Application_ID
							and Reporting_Method = 'InDirect'
							)QRY
	ORDER BY SORTCOL
			/*				
			SELECT R_Emp_ID , 1 AS SortCol
			From T0065_EMP_REPORTING_DETAIL_APP ERD 
				INNER JOIN 
					(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
					 FROM T0065_EMP_REPORTING_DETAIL_APP
					 WHERE Effect_Date <= @Effect_Date And Emp_ID = @Emp_ID
					 GROUP BY emp_ID
					) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
			WHERE ERD.Emp_ID = @Emp_ID and Reporting_Method = 'Direct'
			UNION
			SELECT R_Emp_ID , 2 as SortCol
			From T0065_EMP_REPORTING_DETAIL_APP ERD 
				INNER JOIN 
					(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
					 FROM T0065_EMP_REPORTING_DETAIL_APP
					 WHERE Effect_Date <= @Effect_Date And Emp_ID = @Emp_ID
					 GROUP BY emp_ID
					) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
			WHERE ERD.Emp_ID = @Emp_ID and Reporting_Method = 'InDirect'
		)QRY
	ORDER BY SORTCOL
*/
	IF @RE_Emp_ID > 0
		BEGIN
			UPDATE T0060_EMP_MASTER_APP SET Emp_Superior = @RE_Emp_ID 
			WHERE Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID

			-- Emp_ID = @Emp_ID
		END
	Else --Condition Added by Sumit to pass null when no employee in Reporttin Detail 15042015
		Begin
		UPDATE T0060_EMP_MASTER_APP SET Emp_Superior = null WHERE  Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID

		--Emp_ID = @Emp_ID
		End	
	

	--For New Values in Audit Trail
	SELECT * INTO #T0065_EMP_REPORTING_DETAIL_APP_INSERTED FROM T0065_EMP_REPORTING_DETAIL_APP WITH (NOLOCK) WHERE  Row_ID = @Row_ID
		
	--EXEC P9999_AUDIT_LOG @TableName='T0065_EMP_REPORTING_DETAIL_APP', @IDFieldName='Emp_ID',@Audit_Module_Name='Employee Reporting Manager',
	--	@User_Id=@User_Id,@IP_Address=@IP_Address,@MandatoryFields='Row_ID,R_Emp_ID,Reporting_Method,Effect_Date',
	--	@Audit_Change_Type=@Tran_Type	
	-------Update Reporing Manger ID on Emp_Master Table	--Ankit 28012015
		
	RETURN
