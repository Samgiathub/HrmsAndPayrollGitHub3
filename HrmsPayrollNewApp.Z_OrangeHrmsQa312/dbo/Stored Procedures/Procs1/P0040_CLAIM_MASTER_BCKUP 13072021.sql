



--ALTER PROCEDURE [dbo].[P0040_CLAIM_MASTER]
--	  @Claim_ID numeric(18) output
--	 ,@Cmp_ID numeric(18,0)
--	 ,@Claim_Name varchar(50)
--	 ,@Claim_Max_Limit numeric(18,2)
--	 ,@tran_type char
--	 ,@Desig_Max_Limit Numeric = 0	--Ankit 29012015
--	 ,@Desig_Max_Limit_String Varchar(MAX) = ''	--Ankit 29012015
--	 ,@Claim_Apr_Deduct_From_Sal numeric(18,0)
	 
--	 ,@Grade_Max_Limit Numeric = 0	-- ADDED BY RAJPUT ON 14022018
--	 ,@Branch_Max_Limit Numeric = 0	-- ADDED BY RAJPUT ON 27022018
--	 ,@Claim_Type tinyint -- ADDED BY RAJPUT ON 010320148
--	 ,@Claim_Limit_Type tinyint -- ADDED BY RAJPUT ON 280220148
--	 ,@Attach_Mandatory bit -- ADDED BY RAJPUT ON 14022018
--	 ,@Claim_Allow_Beyond_Limit tinyint -- ADDED BY RAJPUT ON 07052018
--	 ,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016
--     ,@IP_Address varchar(30)= '' -- Add By Mukti 08072016
--AS
--	DECLARE @Tran_ID	Numeric
--	DECLARE @Desi_ID	Numeric(18,0)
--	DECLARE @Grade_ID	Numeric(18,0) -- ADDED BY RAJPUT ON 14022018
--	DECLARE @Branch_ID	Numeric(18,0) -- ADDED BY RAJPUT ON 27022018
--	DECLARE @Max_Limit_KM	Numeric(18,2)
--	DECLARE @Rate_Per_KM	Numeric(18,2)
--	DECLARE @String Varchar(MAX)
--	DECLARE @Max_Design_Tran_id Numeric(18,0)
	
--	SET @Tran_ID = 0
--	SET @Desi_ID = 0 
--	SET @Grade_ID = 0 --ADDED BY RAJPUT ON 14022018
--	SET @Branch_ID = 0 --ADDED BY RAJPUT ON 27022018
--	SET @Max_Limit_KM	= 0
--	SET @Rate_Per_KM	= 0 
--	SET @String	= ''
--	SET @Max_Design_Tran_id = 0
	
--	-- Add By Mukti 08072016(start)
--	declare @OldValue as  varchar(max)
--	Declare @String_val as varchar(max)
--	set @String_val=''
--	set @OldValue =''
--	-- Add By Mukti 08072016(end)	
	
--	if @tran_type ='I' 
--		begin
		
--			if exists (Select Claim_ID  from T0040_claim_master Where Upper(Claim_Name) = Upper(@Claim_Name)and Cmp_ID = @Cmp_ID) 
--				begin
--					set @Claim_ID = 0
--				end
--			else
--				begin
--					select @Claim_ID = isnull(max(Claim_ID),0) from T0040_claim_master
--					if @Claim_ID is null or @Claim_ID = 0
--						set @Claim_ID =1
--					else
--						set @Claim_ID = @Claim_ID + 1			
						
--					insert into T0040_claim_master(Claim_ID,Claim_Name,Cmp_ID,Claim_Max_Limit,Desig_Wise_Limit,Grade_Wise_Limit,Branch_Wise_Limit,Claim_Apr_Deduct_From_Sal,Claim_Limit_Type,Claim_Type,Claim_Allow_Beyond_Limit,Attach_Mandatory) values(@Claim_ID,@Claim_Name,@Cmp_ID,@Claim_Max_Limit,@Desig_Max_Limit,@Grade_Max_Limit,@Branch_Max_Limit,@Claim_Apr_Deduct_From_Sal,@Claim_Limit_Type,@Claim_Type,@Claim_Allow_Beyond_Limit,@Attach_Mandatory)
					
					
--					-- Add By Mukti 08072016(start)
--						exec P9999_Audit_get @table = 'T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
--						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
--					-- Add By Mukti 08072016(end)
				
--					-- Ankit 29012015
--					IF @Desig_Max_Limit = 1 OR  @Grade_Max_Limit = 1 OR @Branch_Max_Limit = 1 -- @Grade_Max_Limit = 1 ADDED BY RAJPUT ON 15022018
--						BEGIN
--						 SET @Tran_ID = 0
						
--						 DECLARE Claim_Cursor CURSOR FOR 
--							--select substring(Data,1,charindex(',',Data)-1),
--							--	substring(Data , charindex(',',Data) + 1, CHARINDEX(',',Data, CHARINDEX(',',Data, CHARINDEX(',', Data)+1))-charindex(',',Data)-1)
--							--	,substring(substring(Data,charindex(',',Data)+1,100),charindex(',',substring(Data,charindex(',',Data)+1,100))+1,100)
--							--FROM dbo.Split(@Desig_Max_Limit_String,'#')
							
--			             SELECT Data From dbo.split(@Desig_Max_Limit_String,'#')
			             
--			             OPEN Claim_Cursor 
--			               FETCH NEXT FROM Claim_Cursor INTO @String-- @Desi_ID,@Max_Limit_KM,@Rate_Per_KM
--			                WHILE @@fetch_status = 0
--								BEGIN
									
--									IF @DESIG_MAX_LIMIT = 1 --CONDITION CHANGED BY RAJPUT ON 15022018
--									  BEGIN
--										SELECT @DESI_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
--									  END
--									ELSE
--									  BEGIN
--										SET @DESI_ID = NULL
--									  END
								  	
--									IF @Grade_Max_Limit = 1 -- ADDED BY RAJPUT ON 15022018 FOR GRADE WISE CLAIM
--										BEGIN
--											SELECT @Grade_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
--										END
--									ELSE
--										BEGIN
--											SET @Grade_ID = NULL
--										END
									
--									IF @Branch_Max_Limit = 1 -- ADDED BY RAJPUT ON 27022018 FOR BRANCH WISE CLAIM
--										BEGIN
--											SELECT @Branch_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
--										END
--									ELSE
--										BEGIN
--											SET @Branch_ID = NULL
--										END
									
									 
--									 SELECT @Max_Limit_KM = Data	FROM dbo.split(@string,',') where ID=2
--									 SELECT @Rate_Per_KM = Data		FROM dbo.split(@string,',') where ID=3
									
--									 SELECT @Tran_ID = isnull(max(Tran_ID),0) + 1 FROM dbo.T0041_Claim_Maxlimit_Design
									 
--									 INSERT INTO dbo.T0041_Claim_Maxlimit_Design(Tran_ID,Claim_ID,Desig_Id,Grade_Id,Branch_ID,Max_Limit_KM,Rate_Per_KM)
--									 VALUES(@Tran_ID,@Claim_ID,cast(@Desi_ID AS NUMERIC(18,0)),cast(@Grade_ID AS NUMERIC(18,0)),cast(@Branch_ID AS NUMERIC(18,0)),cast(@Max_Limit_KM AS numeric(18,2)),cast(@Rate_Per_KM AS numeric(18,2)))
									 
--									 FETCH NEXT FROM Claim_Cursor INTO @String--@Desi_ID,@Max_Limit_KM,@Rate_Per_KM
--								END
--			             CLOSE Claim_Cursor 
--		                 DEALLOCATE Claim_Cursor
			              
--					end 	
--					-- Ankit 29012015
					
--				end
--		end 
--	else if @tran_type ='U' 
--		begin
--			if exists (Select Claim_ID  from T0040_claim_master Where Upper(Claim_Name )= upper(@Claim_Name) and Claim_ID <> @Claim_ID and Cmp_ID = @Cmp_ID) 
--				BEGIN
--					SET @Claim_ID = 0
--				END					
--			ELSE
--				BEGIN
--				-- Add By Mukti 08072016(start)
--					exec P9999_Audit_get @table='T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
--					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
--				-- Add By Mukti 08072016(end)
			
--					UPDATE T0040_claim_master
--					SET Claim_Name = @Claim_Name,
--						Claim_Max_Limit=@Claim_Max_Limit,
--						Desig_Wise_Limit = @Desig_Max_Limit,
--						Grade_Wise_Limit = @Grade_Max_Limit,
--						Branch_Wise_Limit = @Branch_Max_Limit,
--						Claim_Limit_Type = @Claim_Limit_Type,
--						Claim_Type = @Claim_Type,
--						Claim_Allow_Beyond_Limit = @Claim_Allow_Beyond_Limit, --ADDED BY RAJPUT ON 07052018
--						Attach_Mandatory = @Attach_Mandatory,
--						Claim_Apr_Deduct_From_Sal=@Claim_Apr_Deduct_From_Sal
--					WHERE Claim_ID = @Claim_ID and Cmp_ID = @Cmp_ID 
			
--				-- Add By Mukti 08072016(start)
--					exec P9999_Audit_get @table = 'T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
--					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
--				-- Add By Mukti 08072016(end) 
					
--					---Ankit 30012015
--					IF @Desig_Max_Limit = 1 OR @Grade_Max_Limit = 1 OR  @Branch_Max_Limit = 1
--						BEGIN	
--							 CREATE TABLE #Loan_Max_limit_1
--							 (
--							   ID		varchar(max),
--							   Amount	varchar(max),
--							   Rate		Varchar(max)
--							 )
							 
--							 Select @Max_Design_Tran_id = ISNULL(Tran_ID,0) from dbo.T0041_Claim_Maxlimit_Design where Claim_ID = @Claim_ID 
							 
--							 IF @Max_Design_Tran_id <> 0
--								BEGIN
--									 INSERT INTO #Loan_Max_limit_1
--									 SELECT 
--										   SUBSTRING(Data,1,charindex(',',Data)-1),
--										   SUBSTRING(Data , charindex(',',Data) + 1, CHARINDEX(',',Data, CHARINDEX(',',Data, CHARINDEX(',', Data)+1))-charindex(',',Data)-1),
--										   SUBSTRING(substring(Data,charindex(',',Data)+1,100),charindex(',',substring(Data,charindex(',',Data)+1,100))+1,100)
--									 FROM dbo.Split(@Desig_Max_Limit_String,'#')
									 
--									 IF(@Desig_Max_Limit = 1) -- Added by Rajput on 01032018
--										BEGIN
--											 UPDATE  dbo.T0041_Claim_Maxlimit_Design
--											 SET	Max_Limit_Km = (SELECT cast(Amount as numeric(18,2)) From #Loan_Max_limit_1 where ID = Desig_Id),
--													Rate_Per_Km  = (SELECT cast(Rate as numeric(18,2)) From #Loan_Max_limit_1 where ID = Desig_Id)
--											 WHERE	Claim_ID = @Claim_ID
--										 END
--									 ELSE IF(@Grade_Max_Limit = 1)
--										BEGIN
--											 UPDATE  dbo.T0041_Claim_Maxlimit_Design
--											 SET	Max_Limit_Km = (SELECT cast(Amount as numeric(18,2)) From #Loan_Max_limit_1 where ID = Grade_ID),
--													Rate_Per_Km  = (SELECT cast(Rate as numeric(18,2)) From #Loan_Max_limit_1 where ID = Grade_ID)
--											 WHERE	Claim_ID = @Claim_ID
--										END
--									ELSE IF (@Branch_Max_Limit = 1)
--										BEGIN 
--											 UPDATE  dbo.T0041_Claim_Maxlimit_Design
--											 SET	Max_Limit_Km = (SELECT cast(Amount as numeric(18,2)) From #Loan_Max_limit_1 where ID = Branch_ID),
--													Rate_Per_Km  = (SELECT cast(Rate as numeric(18,2)) From #Loan_Max_limit_1 where ID = Branch_ID)
--											 WHERE	Claim_ID = @Claim_ID
--										END
--								END
--							ELSE
--								BEGIN
--									 SET @Tran_ID = 0
--									 SET @String = ''
									 
--									 DECLARE Claim_CursorU CURSOR FOR 
--									 SELECT Data From dbo.split(@Desig_Max_Limit_String,'#')
						             
--									 OPEN Claim_CursorU 
--									   FETCH NEXT FROM Claim_CursorU INTO @String
--										WHILE @@fetch_status = 0
--											BEGIN
												
												
--												IF @DESIG_MAX_LIMIT = 1 --CONDITION CHANGED BY RAJPUT ON 15022018
--													  BEGIN
													
--														SELECT @DESI_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
													
--													  END
--												ELSE
--													  BEGIN
													
--														SET @DESI_ID = NULL
													
--													  END
											  	
--												IF @Grade_Max_Limit = 1 -- ADDED BY RAJPUT ON 15022018 FOR GRADE WISE CLAIM
--													BEGIN
--														SELECT @Grade_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
--													END
--												ELSE
--													BEGIN
--														SET @Grade_ID = NULL
--													END
												
--												IF @Branch_Max_Limit = 1 -- ADDED BY RAJPUT ON 27022018 FOR BRANCH WISE CLAIM
--													BEGIN
--														SELECT @Branch_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
--													END
--												ELSE
--													BEGIN
--														SET @Branch_ID = NULL
--													END
													
												
--												 --SELECT @Desi_ID = Data			FROM dbo.split(@string,',') where ID=1
--												 SELECT @Max_Limit_KM = Data	FROM dbo.split(@string,',') where ID=2
--												 SELECT @Rate_Per_KM = Data		FROM dbo.split(@string,',') where ID=3
												
--												 SELECT @Tran_ID = isnull(max(Tran_ID),0) + 1 FROM dbo.T0041_Claim_Maxlimit_Design
												 
--												 INSERT INTO dbo.T0041_Claim_Maxlimit_Design(Tran_ID,Claim_ID,Desig_Id,Grade_Id,Branch_ID,Max_Limit_KM,Rate_Per_KM) --Added on 01032018 
--												 VALUES(@Tran_ID,@Claim_ID,cast(@Desi_ID AS NUMERIC(18,0)),cast(@Grade_ID AS NUMERIC(18,0)),cast(@Branch_ID AS NUMERIC(18,0)),cast(@Max_Limit_KM AS numeric(18,2)),cast(@Rate_Per_KM AS numeric(18,2)))
												 
--												 --INSERT INTO dbo.T0041_Claim_Maxlimit_Design(Tran_ID,Claim_ID,Desig_Id,Max_Limit_KM,Rate_Per_KM)
--												 --VALUES(@Tran_ID,@Claim_ID,cast(@Desi_ID AS NUMERIC(18,0)),cast(@Max_Limit_KM AS numeric(18,2)),cast(@Rate_Per_KM AS numeric(18,2)))
												 
												 
												 
--												 FETCH NEXT FROM Claim_CursorU INTO @String
--											END
--									 CLOSE Claim_CursorU 
--									 DEALLOCATE Claim_CursorU
									 
--								END 
--						END 
--					ELSE
--						BEGIN
--							DELETE  FROM dbo.T0041_Claim_Maxlimit_Design WHERE Claim_ID = @Claim_ID
--						END 
--					---Ankit 30012015		
--				end
--		end	
--	else if @tran_type ='D'
--		begin
--				-- Add By Mukti 08072016(start)
--					exec P9999_Audit_get @table='T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
--					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
--				-- Add By Mukti 08072016(end)
			
			
--			IF EXISTS(SELECT 1 FROM T0140_CLAIM_TRANSACTION WHERE Claim_ID=@Claim_ID AND Cmp_ID=@Cmp_ID) -- ADDED BY RAJPUT ON 19032018
--				BEGIN 
				
--						DELETE	FROM T0140_CLAIM_TRANSACTION WHERE Claim_ID=@Claim_ID AND Cmp_ID=@Cmp_ID 
--							AND ISNULL(Claim_Opening,0.00) = 0.00 AND ISNULL(Claim_Issue,0.00) = 0.00
--							AND ISNULL(Claim_Return,0.00) = 0.00 AND ISNULL(Claim_Closing,0.00) = 0.00
					
--				END
			
--			delete  from T0041_Claim_Maxlimit_Design where Claim_ID=@Claim_ID 
--			delete  from T0040_claim_master where Claim_ID=@Claim_ID 
			
		
--		end
--		exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Master',@OldValue,@Claim_ID,@User_Id,@IP_Address
--RETURN
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_CLAIM_MASTER_BCKUP 13072021]
	  @Claim_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Claim_Name varchar(50)
	 ,@Claim_Max_Limit numeric(18,2)
	 ,@tran_type char
	 ,@Desig_Max_Limit Numeric = 0	--Ankit 29012015
	 ,@Desig_Max_Limit_String Varchar(MAX) = ''	--Ankit 29012015
	 ,@Claim_Apr_Deduct_From_Sal numeric(18,0)
	 
	 ,@Grade_Max_Limit Numeric = 0	-- ADDED BY RAJPUT ON 14022018
	 ,@Branch_Max_Limit Numeric = 0	-- ADDED BY RAJPUT ON 27022018
	 ,@Claim_Type tinyint -- ADDED BY RAJPUT ON 010320148
	 ,@Claim_Limit_Type tinyint -- ADDED BY RAJPUT ON 280220148
	 ,@Attach_Mandatory bit -- ADDED BY RAJPUT ON 14022018
	 ,@Claim_Allow_Beyond_Limit tinyint -- ADDED BY RAJPUT ON 07052018
	 ,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016
     ,@IP_Address varchar(30)= '' -- Add By Mukti 08072016
	 ,@Beyond_Max_Limit_Deduct_In_Salary tinyint = 0  --Added by Jaina 12-10-2020
	 ,@No_Of_Year_Limit Numeric(18,0) = 0 --Added by Jaina 12-10-2020
	 ,@Claim_For_FNF Numeric(18,0) = 0 --Added by Jaina 13-10-2020
	 ,@Gender_wise tinyint = 0  --Added by Jaina 31-10-2020
	 ,@For_Gender varchar(10) = ''  --Added by Jaina 31-10-2020
	 ,@Basic_Salary_wise tinyint = 0  
	 ,@Gross_Salary_wise tinyint = 0  
	 ,@Applicable_Once tinyint = 0
	 ,@ClaimDefId INT = null
	 ,@TermsCondition VARCHAR(MAX) = null
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Tran_ID	Numeric
	DECLARE @Desi_ID	Numeric(18,0)
	DECLARE @Grade_ID	Numeric(18,0) -- ADDED BY RAJPUT ON 14022018
	DECLARE @Branch_ID	Numeric(18,0) -- ADDED BY RAJPUT ON 27022018
	DECLARE @Max_Limit_KM	Numeric(18,2)
	DECLARE @Rate_Per_KM	Numeric(18,2)
	DECLARE @String Varchar(MAX)
	DECLARE @Max_Design_Tran_id Numeric(18,0)
	
	SET @Tran_ID = 0
	SET @Desi_ID = 0 
	SET @Grade_ID = 0 --ADDED BY RAJPUT ON 14022018
	SET @Branch_ID = 0 --ADDED BY RAJPUT ON 27022018
	SET @Max_Limit_KM	= 0
	SET @Rate_Per_KM	= 0 
	SET @String	= ''
	SET @Max_Design_Tran_id = 0
	
	-- Add By Mukti 08072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
	-- Add By Mukti 08072016(end)	
	
	if @tran_type ='I' 
		begin
		
			if exists (Select Claim_ID  from T0040_claim_master WITH (NOLOCK) Where Upper(Claim_Name) = Upper(@Claim_Name)and Cmp_ID = @Cmp_ID) 
				begin
					set @Claim_ID = 0
				end
			else
				begin
					select @Claim_ID = isnull(max(Claim_ID),0) from T0040_claim_master WITH (NOLOCK)
					if @Claim_ID is null or @Claim_ID = 0
						set @Claim_ID =1
					else
						set @Claim_ID = @Claim_ID + 1			
						
					insert into T0040_claim_master(Claim_ID,Claim_Name,Cmp_ID,Claim_Max_Limit,Desig_Wise_Limit,Grade_Wise_Limit,Branch_Wise_Limit,Claim_Apr_Deduct_From_Sal,Claim_Limit_Type,Claim_Type,Claim_Allow_Beyond_Limit,Attach_Mandatory,Beyond_Max_Limit_Deduct_In_Salary,No_Of_Year_Limit,Claim_For_FNF,Gender_Wise,For_Gender,Basic_Salary_wise,Gross_Salary_wise,Applicable_Once,Claim_Def_Id,Claim_Terms_Condition) 
					values(@Claim_ID,@Claim_Name,@Cmp_ID,@Claim_Max_Limit,@Desig_Max_Limit,@Grade_Max_Limit,@Branch_Max_Limit,@Claim_Apr_Deduct_From_Sal,@Claim_Limit_Type,@Claim_Type,@Claim_Allow_Beyond_Limit,@Attach_Mandatory,@Beyond_Max_Limit_Deduct_In_Salary,@No_Of_Year_Limit,@Claim_For_FNF,@Gender_wise,@For_Gender,@Basic_Salary_wise,@Gross_Salary_wise,@Applicable_Once,@ClaimDefId,@TermsCondition)
					
					
					-- Add By Mukti 08072016(start)
						exec P9999_Audit_get @table = 'T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
					-- Add By Mukti 08072016(end)
				
					-- Ankit 29012015
					IF @Desig_Max_Limit = 1 OR  @Grade_Max_Limit = 1 OR @Branch_Max_Limit = 1 -- @Grade_Max_Limit = 1 ADDED BY RAJPUT ON 15022018
						BEGIN
						 SET @Tran_ID = 0
						
						 DECLARE Claim_Cursor CURSOR FOR 
						
			             SELECT Data From dbo.split(@Desig_Max_Limit_String,'#')
			             
			             OPEN Claim_Cursor 
			               FETCH NEXT FROM Claim_Cursor INTO @String-- @Desi_ID,@Max_Limit_KM,@Rate_Per_KM
			                WHILE @@fetch_status = 0
								BEGIN
									
									IF @DESIG_MAX_LIMIT = 1 --CONDITION CHANGED BY RAJPUT ON 15022018
									  BEGIN
										SELECT @DESI_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
									  END
									ELSE
									  BEGIN
										SET @DESI_ID = NULL
									  END
								  	
									IF @Grade_Max_Limit = 1 -- ADDED BY RAJPUT ON 15022018 FOR GRADE WISE CLAIM
										BEGIN
											SELECT @Grade_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
										END
									ELSE
										BEGIN
											SET @Grade_ID = NULL
										END
									
									IF @Branch_Max_Limit = 1 -- ADDED BY RAJPUT ON 27022018 FOR BRANCH WISE CLAIM
										BEGIN
											SELECT @Branch_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
										END
									ELSE
										BEGIN
											SET @Branch_ID = NULL
										END
									
									 
									 SELECT @Max_Limit_KM = Data	FROM dbo.split(@string,',') where ID=2
									 SELECT @Rate_Per_KM = Data		FROM dbo.split(@string,',') where ID=3
									
									 SELECT @Tran_ID = isnull(max(Tran_ID),0) + 1 FROM dbo.T0041_Claim_Maxlimit_Design WITH (NOLOCK)
									 
									 
									 INSERT INTO dbo.T0041_Claim_Maxlimit_Design(Tran_ID,Claim_ID,Desig_Id,Grade_Id,Branch_ID,Max_Limit_KM,Rate_Per_KM)
									 VALUES(@Tran_ID,@Claim_ID,cast(@Desi_ID AS NUMERIC(18,0)),cast(@Grade_ID AS NUMERIC(18,0)),cast(@Branch_ID AS NUMERIC(18,0)),cast(@Max_Limit_KM AS numeric(18,2)),cast(@Rate_Per_KM AS numeric(18,2)))
									 
									 FETCH NEXT FROM Claim_Cursor INTO @String--@Desi_ID,@Max_Limit_KM,@Rate_Per_KM
								END
			             CLOSE Claim_Cursor 
		                 DEALLOCATE Claim_Cursor
			              
					end 	
					-- Ankit 29012015
					
				end
		end 
	else if @tran_type ='U' 
		begin
			if exists (Select Claim_ID  from T0040_claim_master WITH (NOLOCK) Where Upper(Claim_Name )= upper(@Claim_Name) and Claim_ID <> @Claim_ID and Cmp_ID = @Cmp_ID) 
				BEGIN
					SET @Claim_ID = 0
				END					
			ELSE
				BEGIN
				-- Add By Mukti 08072016(start)
					exec P9999_Audit_get @table='T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				-- Add By Mukti 08072016(end)
			
					UPDATE T0040_claim_master
					SET Claim_Name = @Claim_Name,
						Claim_Max_Limit=@Claim_Max_Limit,
						Desig_Wise_Limit = @Desig_Max_Limit,
						Grade_Wise_Limit = @Grade_Max_Limit,
						Branch_Wise_Limit = @Branch_Max_Limit,
						Claim_Limit_Type = @Claim_Limit_Type,
						Claim_Type = @Claim_Type,
						Claim_Allow_Beyond_Limit = @Claim_Allow_Beyond_Limit, --ADDED BY RAJPUT ON 07052018
						Attach_Mandatory = @Attach_Mandatory,
						Claim_Apr_Deduct_From_Sal=@Claim_Apr_Deduct_From_Sal,
						Beyond_Max_Limit_Deduct_In_Salary = @Beyond_Max_Limit_Deduct_In_Salary,
						No_Of_Year_Limit = @No_Of_Year_Limit,
						Claim_For_FNF = @Claim_For_FNF,
						Gender_wise = @Gender_wise,
						For_Gender = @For_Gender,
						Basic_Salary_wise=@Basic_Salary_wise,
						Gross_Salary_wise=@Gross_Salary_wise,
						Applicable_Once=@Applicable_Once,
						Claim_Def_Id = @ClaimDefId,
						Claim_Terms_Condition=@TermsCondition
					WHERE Claim_ID = @Claim_ID and Cmp_ID = @Cmp_ID 
			
				-- Add By Mukti 08072016(start)
					exec P9999_Audit_get @table = 'T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
				-- Add By Mukti 08072016(end) 
					
					---Ankit 30012015
					IF @Desig_Max_Limit = 1 OR @Grade_Max_Limit = 1 OR  @Branch_Max_Limit = 1
						BEGIN	
							 --CREATE TABLE #Loan_Max_limit_1
							 --(
							 --  ID		varchar(max),
							 --  Amount	varchar(max),
							 --  Rate		Varchar(max)
							 --)
							 
								   DELETE FROM T0041_CLAIM_MAXLIMIT_DESIGN WHERE CLAIM_ID = @Claim_ID
							 		
									
									
									IF @DESIG_MAX_LIMIT = 1 OR  @GRADE_MAX_LIMIT = 1 OR @BRANCH_MAX_LIMIT = 1 -- @GRADE_MAX_LIMIT = 1 ADDED BY RAJPUT ON 15022018
											BEGIN
											
											 SET @TRAN_ID = 0
											
											 DECLARE CLAIM_CURSOR CURSOR FOR 
											
											 SELECT DATA FROM DBO.SPLIT(@DESIG_MAX_LIMIT_STRING,'#')
								             
											 OPEN CLAIM_CURSOR 
											   FETCH NEXT FROM CLAIM_CURSOR INTO @STRING-- @DESI_ID,@MAX_LIMIT_KM,@RATE_PER_KM
												WHILE @@FETCH_STATUS = 0
													BEGIN
														
														IF @DESIG_MAX_LIMIT = 1 --CONDITION CHANGED BY RAJPUT ON 15022018
														  BEGIN
															SELECT @DESI_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
														  END
														ELSE
														  BEGIN
															SET @DESI_ID = NULL
														  END
													  	
														IF @GRADE_MAX_LIMIT = 1 -- ADDED BY RAJPUT ON 15022018 FOR GRADE WISE CLAIM
															BEGIN
																SELECT @GRADE_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
															END
														ELSE
															BEGIN
																SET @GRADE_ID = NULL
															END
														
														IF @BRANCH_MAX_LIMIT = 1 -- ADDED BY RAJPUT ON 27022018 FOR BRANCH WISE CLAIM
															BEGIN
																SELECT @BRANCH_ID = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=1
															END
														ELSE
															BEGIN
																SET @BRANCH_ID = NULL
															END
														
														 
														 SELECT @MAX_LIMIT_KM = DATA	FROM DBO.SPLIT(@STRING,',') WHERE ID=2
														 SELECT @RATE_PER_KM = DATA		FROM DBO.SPLIT(@STRING,',') WHERE ID=3
														
														 SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM DBO.T0041_CLAIM_MAXLIMIT_DESIGN WITH (NOLOCK)
														 
														 
														 INSERT INTO DBO.T0041_CLAIM_MAXLIMIT_DESIGN(TRAN_ID,CLAIM_ID,DESIG_ID,GRADE_ID,BRANCH_ID,MAX_LIMIT_KM,RATE_PER_KM)
														 VALUES(@TRAN_ID,@CLAIM_ID,CAST(@DESI_ID AS NUMERIC(18,0)),CAST(@GRADE_ID AS NUMERIC(18,0)),CAST(@BRANCH_ID AS NUMERIC(18,0)),CAST(@MAX_LIMIT_KM AS NUMERIC(18,2)),CAST(@RATE_PER_KM AS NUMERIC(18,2)))
														 
														 FETCH NEXT FROM CLAIM_CURSOR INTO @STRING--@DESI_ID,@MAX_LIMIT_KM,@RATE_PER_KM
													END
											 CLOSE CLAIM_CURSOR 
											 DEALLOCATE CLAIM_CURSOR
								              
										END 	
								
											
						END 
					ELSE
						BEGIN
							DELETE  FROM dbo.T0041_Claim_Maxlimit_Design WHERE Claim_ID = @Claim_ID
						END 
					---Ankit 30012015		
				end
		end	
	else if @tran_type ='D'
		begin
				-- Add By Mukti 08072016(start)
					exec P9999_Audit_get @table='T0040_claim_master' ,@key_column='Claim_ID',@key_Values=@Claim_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				-- Add By Mukti 08072016(end)
			
			
			IF EXISTS(SELECT 1 FROM T0140_CLAIM_TRANSACTION WITH (NOLOCK) WHERE Claim_ID=@Claim_ID AND Cmp_ID=@Cmp_ID) -- ADDED BY RAJPUT ON 19032018
				BEGIN 
				
						DELETE	FROM T0140_CLAIM_TRANSACTION WHERE Claim_ID=@Claim_ID AND Cmp_ID=@Cmp_ID 
							AND ISNULL(Claim_Opening,0.00) = 0.00 AND ISNULL(Claim_Issue,0.00) = 0.00
							AND ISNULL(Claim_Return,0.00) = 0.00 AND ISNULL(Claim_Closing,0.00) = 0.00
					
				END
			
			delete  from T0041_Claim_Maxlimit_Design where Claim_ID=@Claim_ID 
			delete  from T0040_claim_master where Claim_ID=@Claim_ID 
			
		
		end
	
		
		exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Master',@OldValue,@Claim_ID,@User_Id,@IP_Address
RETURN




