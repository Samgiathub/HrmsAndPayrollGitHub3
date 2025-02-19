
-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 27-04-2017
-- Description:	For Enter Opening of Uniform
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0140_Uniform_Stock_Opening]
	  @Uniform_Name  as varchar(300)
	 ,@CMP_Id as numeric
	 ,@Uni_Opening_Amount as numeric(18,2)
	 ,@for_date  as datetime
	 ,@Log_Status Int = 0 Output 
	 ,@Row_No as Int 
	 ,@GUID as Varchar(2000) = '' 
	 ,@User_Id as Varchar(30)
	 ,@Ip_Address as Varchar(30)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Uni_ID Numeric(5,0)
	Set @Uni_ID = 0
	
	Declare @Stock_ID Numeric(18,0)
	Set @Stock_ID = 0
	
	Declare @Pre_Closing numeric(18,2)
	Declare @Temp_Max_Date as datetime
	Declare @Chg_For_Date datetime
	Declare @Chg_Stock_ID numeric 
	Declare @Temp_Uniform_Bal as numeric (18,2)				
	set @Temp_Max_Date = null
	
	if @for_date = '01-01-1900'
		Set @for_date = ''
	
	If @Uniform_Name = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Uniform Name is not Properly Inserted',0,'Enter Valid Uniform Name',GetDate(),'Uniform Opening Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
	
	If @for_date = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'For Date is not Properly Inserted',0,'Enter Proper For Date',GetDate(),'Uniform Opening Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
		
	IF NOT EXISTS (select 1 from T0040_Uniform_Master WITH (NOLOCK) where UPPER(Uni_Name) = UPPER(@Uniform_Name) and Cmp_ID = @CMP_Id)
	BEGIN			
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Uniform Name Not Exists',0,'Enter Valid Uniform Name',GETDATE(),'Uniform Opening Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
		
	if @Uniform_Name <> '' and @for_date <> ''
		Begin
			select @Uni_ID = Uni_ID from T0040_Uniform_Master WITH (NOLOCK) where UPPER(Uni_Name) = UPPER(@Uniform_Name) and Cmp_ID = @CMP_Id
			
			--IF EXISTS (select 1 from T0140_Uniform_Stock_Transaction where Uni_ID=@Uni_ID and For_Date >= @for_date and Cmp_ID = @CMP_Id)
			--BEGIN				
			--	INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Uniform Stock cannot to be updated',0,'Already Uniform assigned after For date',GETDATE(),'Uniform Opening Import',@GUID)						
			--	SET @LOG_STATUS=1			
			--	RETURN
			--END
			--if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id)
			--	BEGIN				
			--		UPDATE UST
			--			SET UST.Stock_Posting = UST.Stock_Balance,
			--				UST.Stock_Balance = 0
			--		From T0140_Uniform_Stock_Transaction UST
			--		Inner JOIN(	
			--					Select MAX(for_date) as fordate,Uni_ID 
			--					from T0140_Uniform_Stock_Transaction 
			--					where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id
			--					GROUP By Uni_ID
			--				   ) as Qry
			--		ON Qry.fordate = UST.For_Date and UST.Uni_ID = Qry.Uni_ID
			--		Where UST.Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id
			--	End
			
			if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id  and For_Date = @For_Date)
				BEGIN
					----UPDATE UST
					----	SET UST.Stock_Posting = UST.Stock_Balance,
					----		UST.Stock_Balance = 0
					----From T0140_Uniform_Stock_Transaction UST
					----Inner JOIN(	
					----			Select MAX(for_date) as fordate,Uni_ID 
					----			from T0140_Uniform_Stock_Transaction 
					----			where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id 
					----			GROUP By Uni_ID
					----		   ) as Qry
					----ON Qry.fordate = UST.For_Date and UST.Uni_ID = Qry.Uni_ID
					----Where UST.Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id
					
					select @Temp_max_Date   = max(For_Date)  from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and for_date <= @for_date 
					select @Temp_Uniform_Bal = isnull(Stock_Balance,0) from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and for_Date = @Temp_Max_DAte
					
					update dbo.T0140_Uniform_Stock_Transaction 
					set Stock_Posting = @Temp_Uniform_Bal,
					Stock_Balance = 0
					where Uni_ID = @Uni_ID and for_Date = @Temp_Max_Date AND Cmp_ID = @CMP_Id	
					
					Update T0140_Uniform_Stock_Transaction
						Set Stock_Opening = @Uni_Opening_Amount,
							Stock_Balance = (@Uni_Opening_Amount + Stock_Credit)-Stock_Debit
					Where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id  and For_Date = @For_Date				
				END
			Else
				BEGIN
					select @Temp_max_Date   = max(For_Date)  from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and for_date <= @for_date 
					select @Temp_Uniform_Bal = isnull(Stock_Balance,0) from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and for_Date = @Temp_Max_DAte
					
					update dbo.T0140_Uniform_Stock_Transaction 
					set Stock_Posting = @Temp_Uniform_Bal,
					Stock_Balance = 0
					where Uni_ID = @Uni_ID and for_Date = @Temp_Max_Date AND Cmp_ID = @CMP_Id				
					
					Select @Stock_ID = Isnull(Max(Stock_ID),0) + 1 From T0140_Uniform_Stock_Transaction WITH (NOLOCK)
					Insert into T0140_Uniform_Stock_Transaction(Stock_ID,Cmp_ID,Uni_ID,For_Date,Stock_Opening,Stock_Credit,Stock_Debit,Stock_Balance,Stock_Posting,Modify_By,Modify_Date,Ip_Address)
					VALUES(@Stock_ID,@CMP_Id,@Uni_ID,@for_date,@Uni_Opening_Amount,0,0,@Uni_Opening_Amount,0,@User_Id,SYSDATETIME(),@Ip_Address)	
				END
		
		
		if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id)
			BEGIN		
				select @Temp_max_Date   = max(For_Date)  from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and for_date = @for_date
				Select @Pre_Closing=Stock_Balance from T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date = @Temp_max_Date
					select @Temp_max_Date,@Pre_Closing
							
				if @Pre_Closing is null
					set @Pre_Closing = 0
																					
					declare cur1 cursor for 
						Select Stock_ID,For_Date from dbo.T0140_Uniform_Stock_Transaction WITH (NOLOCK) where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date > @for_date order by for_date
					open cur1
					fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date
					while @@fetch_status = 0
					begin
						--If exists(Select Stock_ID From T0140_Uniform_Stock_Transaction Where Cmp_ID = @Cmp_ID And Uni_ID = @Uni_ID and For_Date = @Chg_For_Date And Stock_Debit > 0)
						--	Begin
						--		Goto c;
						--	End
						select @Pre_Closing = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction WITH (NOLOCK) 
	    					where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction WITH (NOLOCK)
	    						where for_date < @Chg_For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID) 
	    						and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID
	    						
						update dbo.T0140_Uniform_Stock_Transaction set 
							 Stock_Opening = @Pre_Closing
							,Stock_Balance = @Pre_Closing + Stock_Credit - Stock_Debit 
							,Stock_Posting=0									
						where Stock_ID = @Chg_Stock_ID				
					--C:
					--	set @Pre_Closing = (select Stock_Balance from dbo.T0140_Uniform_Stock_Transaction where Stock_ID = @Chg_Stock_ID)
					--SELECT @Chg_Stock_ID,@Chg_For_Date,@Pre_Closing
						fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date
					end
					
					close cur1
					deallocate cur1	
			END
	END
END
