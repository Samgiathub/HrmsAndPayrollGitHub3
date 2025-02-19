

CREATE PROCEDURE [dbo].[P0190_Monthly_AD_Detail_Import]    
 @Cmp_ID			NUMERIC ,    
 @Emp_Code			Varchar(40) ,    
 @Month				INT,    
 @Year				INT,    
 @AD_Sort_Name		VARCHAR(50),    
 @AD_Amount			NUMERIC(18,2) ,    
 @Comments			VARCHAR(200),
 @Increment_ID_DS	NUMERIC(18,0)=0,
 @flag              char = 'I',
 @Tran_Id			NUMERIC =0, --Added By Mukti 19012015
 @Log_Status		Int = 0 Output,	--Ankit 13072015
 @GUID				Varchar(2000) = '' -- Added by nilesh patel on 15062016
AS    
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 SET ARITHABORT ON

 
 DECLARE @E_AD_FLAG			 VARCHAR(20)
 DECLARE @E_AD_PERCENTAGE    NUMERIC(18,0)
 DECLARE @E_AD_CALCULATE	 VARCHAR(20)
 DECLARE @E_AD_AMOUNT		 VARCHAR(20)
 DECLARE @E_AD_MAX_LIMIT	 NUMERIC(18,2)

 DECLARE @Emp_ID		NUMERIC     
 DECLARE @Increment_ID  NUMERIC
 DECLARE @For_Date		DATETIME     
 DECLARE @AD_ID			NUMERIC
 --DECLARE @Tran_ID		NUMERIC
 DECLARE @Is_not_Exists INT    
 DECLARE @AD_AMT		NUMERIC(18,2)
 Declare @LogDesc	nvarchar(max)
 Declare @Calculate_on varchar(100)
 DECLARE @DATE_OF_JOIN DATETIME		--Added By Ramiz on  03/01/2017
  
 SET @AD_AMT =0    
 SET @Is_not_Exists = 0    
 set @AD_ID = 0 -- added by Gadriwala 28012014
 Set @Log_Status = 0
 set @Calculate_on = ''
 
 IF @Emp_Code = '' OR @Month =0 OR @Month > 12 OR @Year < 2000    
  RETURN

If @flag='A'
	begin 
		set @Emp_ID = @Emp_Code
		set @AD_ID = @AD_Sort_Name--@AD_Sort_Name is fetch allowance id
		SELECT @Calculate_on = AD_CALCULATE_ON FROM T0050_AD_MAster WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID AND AD_ID = @AD_ID--add by chetan/nileshbhai 24-12-16
		
	end
  
else
	begin
		 SELECT TOP 1 @Emp_ID =  Emp_ID FROM T0080_Emp_Master e WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID  and Alpha_Emp_Code =@Emp_Code ORDER BY Emp_ID DESC
		 SELECT @AD_ID = AD_ID,@E_AD_FLAG =AD_FLAG,@Calculate_on = AD_CALCULATE_ON FROM T0050_AD_MAster WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID AND (UPPER(AD_SORT_NAME) =UPPER(@AD_Sort_Name)  OR UPPER(AD_SORT_NAME) =UPPER(replace(@AD_Sort_Name,' ','_')) )  
	 end
	 --SELECT @Emp_ID = Emp_ID FROM T0080_Emp_Master e WHERE Cmp_ID =@Cmp_ID  and Alpha_Emp_Code =@Emp_Code    
	 SELECT @AD_ID = AD_ID,@E_AD_FLAG =AD_FLAG FROM T0050_AD_MAster WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID AND (UPPER(AD_SORT_NAME) =UPPER(@AD_Sort_Name)  OR UPPER(AD_SORT_NAME) =UPPER(replace(@AD_Sort_Name,' ','_')) )  
	 
	 SELECT @DATE_OF_JOIN = e.Date_Of_Join FROM T0080_Emp_Master e WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID  and EMP_Id = @Emp_ID -- Added By Ramiz on 03/01/2017 for Mid Join Employees
	 
	 IF @AD_AMOUNT = 0
		RETURN
	 
	 
	 if Object_ID('tempdb..#Temp_AD_Details') is not null
		Begin
			Drop Table #Temp_AD_Details
		End 
	 
	 Create Table #Temp_AD_Details
	 (
		Cmp_ID Numeric(18,0),
		Emp_ID Numeric(18,0),
		AD_ID  Numeric(18,0),
		For_Date Datetime
	 )
	 Declare @AD_Date Datetime
	 Set @AD_Date = dbo.GET_MONTH_ST_DATE(@Month,@Year)
	 
	 --Code Added By Ramiz on 03/01/2017 , Because for Mid Join Employees , Allowance Was Not Uploading--
	 IF @AD_Date < @DATE_OF_JOIN
		SET @AD_Date = @DATE_OF_JOIN
	--Code Ended By Ramiz on 03/01/2017 
	 
	 --Added By Nilesh For Check Only Assign Employee you will be import from Import Sheet
	 --exec P0100_EMP_EARN_DEDUCTION_REVISED @Emp_ID=@Emp_ID,@Cmp_ID=@Cmp_ID,@For_Date=@AD_Date,@Flag=1
	 
	 --if Not Exists(Select 1 From #Temp_AD_Details Where AD_ID = @AD_ID)
		--BEGIN
		--	Set @Log_Status = 1
		--	INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Allowance Details are not assign to Employee.',@EMP_CODE,'Allowance Details are not assign to Employee.',GetDate(),'Monthly Earn Dedu',@GUID)			
		--	RETURN
		--End	
	 
	 If @Emp_ID= null
		Set @Emp_ID = 0
		
	 if @AD_ID is null
		Set @AD_ID = 0
	
	if @Emp_ID = 0 
		Begin
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Employee Doesn''t exists',@EMP_CODE,'Enter proper Employee Code',GetDate(),'Monthly Earn Dedu',@GUID)			
			RETURN
		End
		
	if @AD_ID = 0 
		Begin
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Allowance details Doesn''t exists',@EMP_CODE,'Enter proper Allowance Details',GetDate(),'Monthly Earn Dedu',@GUID)			
			RETURN
		End
	if UPPER(@Calculate_on) <> UPPER('Import')
		Begin
			 --Added By Nilesh for put validation for import only import Type allowance.
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Please Enter Import Type Allowance',@EMP_CODE,'Please Enter Import Type Allowance',GetDate(),'Monthly Earn Dedu',@GUID)			
			RETURN
		End	
	if @Year = 0 
		Begin
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Year details Doesn''t exists',@EMP_CODE,'Enter proper Year Details',GetDate(),'Monthly Earn Dedu',@GUID)			
			RETURN
		End
		
	if @Month = 0 
		Begin
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Month details Doesn''t exists',@EMP_CODE,'Enter proper Month Details',GetDate(),'Monthly Earn Dedu',@GUID)			
			RETURN
		End
	 
	 SELECT @For_Date = dbo.GET_MONTH_END_DATE(@Month,@Year)       
	     
	 --IF @Emp_ID = 0 OR @AD_ID = 0     
	 -- RETURN
	   
		SELECT @Increment_ID =I.Increment_ID FROM T0095_Increment i WITH (NOLOCK) INNER JOIN
			(SELECT MAX(Increment_Id)Increment_Id ,Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment    
				WHERE Emp_ID=@Emp_ID AND Increment_effective_Date <=@For_Date GROUP BY Emp_ID )q ON i.Emp_ID =Q.emp_ID     
				AND i.Increment_Id = q.Increment_Id    
		WHERE I.Emp_ID =@Emp_ID      
	     
	 --IF NOT EXISTS(SELECT Emp_ID FROM T0100_Emp_Earn_Deduction WHERE Increment_ID =@Increment_ID AND AD_ID =@AD_ID)    
	 -- BEGIN    
		----============CHANGE BY NILAY 05/JAN/2010 ==============================================================================
	 --    EXEC P0100_EMP_EARN_DEDUCTION 0,@Emp_ID,@Cmp_ID,@AD_ID,@Increment_ID,@For_Date,@E_AD_FLAG,'Rs.',0,0,0,'I'
	 --   --===========CHANGE BY NILAY 05/JAN/2010 ==============================================================================
	 -- END  
		
	    
	 if exists(select 1 from t0200_monthly_salary WITH (NOLOCK) where emp_id=@emp_id and month(Month_End_Date) =@Month and year(Month_End_Date) =@Year) --Added By Mukti 19012015 if salary exist than not update
		begin
			
			--Added by Sumit 09072015-----------------------------------------------------------
			Declare @AD_Not_Effect_Salary as tinyint
			Declare @AD_Cal_Imported as tinyint
	 
			 select @AD_Not_Effect_Salary=AD_NOT_EFFECT_SALARY,
					@AD_Cal_Imported=Is_Calculated_On_Imported_Value from T0050_AD_MASTER WITH (NOLOCK) where AD_ID=@AD_ID and CMP_ID=@Cmp_ID
				--select @AD_Not_Effect_Salary,@AD_Cal_Imported 
				if (@AD_Not_Effect_Salary <> 1 or @AD_Cal_Imported <> 1)
					Begin	
						
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Salary Exist for the Month of ' + CAST(DATENAME(MM ,@For_Date) as varchar(3)) + '-' + cast(@Year as varchar(4)) + '',0,'Salary Exist for the Month of ' + CAST(DATENAME(MM ,@For_Date) as varchar(3)) + '-' + cast(@Year as varchar(4)) + '',GETDATE(),'Monthly Earn Dedu',@GUID)  
						SET @Log_Status=1
											
						Return
					End
			--Ended by Sumit 09072015-----------------------------------------------------------	
		
			--return
		end
		
		
		IF EXISTS(SELECT EMP_ID FROM  T0302_Process_Detail WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND month(for_date)=@Month and Year(for_date)=@Year and Ad_id=@ad_id and payment_process_id <> 0)
			Begin	
					set @LogDesc = 'Emp_Code='+@Emp_Code +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
						Insert Into dbo.T0080_Import_Log Values (0,0,@Emp_Code,'Payment Process Exists ' +@LogDesc ,'','Import proper Data',GetDate(),'Monthly Earn Dedu',@GUID)
						--exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Import','Monthly salary Exists',@LogDesc,1,''			
						SET @Log_Status=1
						return 
			end	
		IF EXISTS(SELECT EMP_ID FROM  MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND month(for_date)=@Month and Year(for_date)=@Year and Ad_id=@ad_id )
			Begin	
					set @LogDesc = 'Emp_Code='+@Emp_Code +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
						Insert Into dbo.T0080_Import_Log Values (0,0,@Emp_Code,'Payment Process Exists ' +@LogDesc ,'','Import proper Data',GetDate(),'Monthly Earn Dedu',@GUID)
						--exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Import','Monthly salary Exists',@LogDesc,1,''			
						SET @Log_Status=1
						return 
			end	
		
	 IF EXISTS(SELECT Emp_ID FROM T0190_MONTHLY_AD_DETAIL_IMPORT WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND AD_ID =@AD_ID AND MONTH =@MONTH AND YEAR =@YEAR )               
		 BEGIN    
			IF @Increment_ID_DS=0
				BEGIN
					
					DELETE FROM T0190_MONTHLY_AD_DETAIL_IMPORT WHERE EMP_ID =@EMP_ID AND AD_ID =@AD_ID AND MONTH =@MONTH AND YEAR =@YEAR        
				END
			ELSE
   				BEGIN
					DELETE from T0190_MONTHLY_AD_DETAIL_IMPORT WHERE EMP_ID =@EMP_ID And Increment_ID=@Increment_ID_DS
				END          
					BEGIN	
									
						 INSERT INTO T0190_MONTHLY_AD_DETAIL_IMPORT    
								  ( Emp_ID, Cmp_ID, AD_ID, Month, Year, For_Date, Amount, Comments,Is_not_Exists,Increment_ID)    
						 VALUES     (@Emp_ID, @Cmp_ID, @AD_ID, @Month, @Year, @For_Date, @AD_Amount, @Comments,@Is_not_Exists,@Increment_ID_DS)     
					END
			END  
	 ELSE    
	   BEGIN    
    		--	SELECT @Tran_ID =ISNULL(MAX(tran_ID),0) +1 FROM T0190_MONTHLY_AD_DETAIL_IMPORT    
	--Added By Mukti(start)19012015  
			
    		IF  @Tran_Id > 0
				BEGIN
						UPDATE T0190_MONTHLY_AD_DETAIL_IMPORT
							SET Month=@Month,Year=@Year,For_Date=@For_Date,Amount=@AD_Amount,Comments=@Comments
						WHERE  EMP_ID =@EMP_ID AND AD_ID =@AD_ID AND Tran_Id=@Tran_Id
				END
	--Added By Mukti(end)19012015
			ELSE
				BEGIN	

					INSERT INTO T0190_MONTHLY_AD_DETAIL_IMPORT    
									  ( Emp_ID, Cmp_ID, AD_ID, Month, Year, For_Date, Amount, Comments,Is_not_Exists,Increment_ID)    
					VALUES     ( @Emp_ID, @Cmp_ID, @AD_ID, @Month, @Year, @For_Date, @AD_Amount, @Comments,@Is_not_Exists,@Increment_ID_DS)     
				END
	   END      
	   
RETURN     
    
	


