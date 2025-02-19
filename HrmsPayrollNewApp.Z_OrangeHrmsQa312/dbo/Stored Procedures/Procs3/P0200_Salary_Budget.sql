


 ---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_Salary_Budget]
	@SalBudget_ID numeric(18,0) OUTPUT,
	@SalBudget_Type varchar(50),
	@SalBudget_Date datetime,
	@Cmp_ID numeric(18,0),
	@Login_ID numeric(18,0),
	@BudgetDetails XML,
	@TransType char(1)
   ,@Branch_Ids varchar(max)   = null----added on 14/11/2017 sneha (start)
   ,@SubBranch_Ids varchar(max)= null
   ,@Grade_Ids varchar(max)	   = null
   ,@Type_Ids varchar(max)	   = null
   ,@Dept_Ids varchar(max)	   = null
   ,@Desig_Ids varchar(max)	   = null
   ,@Cat_Ids varchar(max)	   = null
   ,@BusSegment_Ids varchar(max) = null
   ,@Vertical_Ids varchar(max)	 = null
   ,@SubVertical_Ids varchar(max)= null
   ,@Appraisal_DateFrom varchar(max) = null
   ,@Appraisal_DateTo varchar(max)	 = null
   ----added on 14/11/2017 sneha (end)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @SalBudget_DetailID numeric(18,0)
DECLARE @ID numeric(18,0)
DECLARE @Name varchar(50)
DECLARE @Increment numeric(18,2)
DECLARE @CurrentBasicSalary numeric(18,2)
DECLARE @CurrentGrossSalary numeric(18,2)
DECLARE @CurrentCTCSalary numeric(18,2)
DECLARE @IncrementBasicAmount numeric(18,2)
DECLARE @IncrementGrossAmount numeric(18,2)
DECLARE @IncrementCTCAmount numeric(18,2)
DECLARE @ProposeBasicSalary numeric(18,2)
DECLARE @ProposeGrossSalary numeric(18,2)
DECLARE @ProposeCTCSalary numeric(18,2)

----added on 14/11/2017 sneha (start)
if @Branch_Ids = ''
	set	 @Branch_Ids= NULL
   if @SubBranch_Ids = '' set	 @SubBranch_Ids= null
   if @SubBranch_Ids = '0' set	 @SubBranch_Ids= null
   if @Grade_Ids = '' set	 @Grade_Ids= null
   if @Type_Ids = '' set	 @Type_Ids	   = null
   if @Dept_Ids = '' set	 @Dept_Ids	   = null
   if @Desig_Ids = '' set	 @Desig_Ids	   = null
   if @Cat_Ids = '' set	 @Cat_Ids	   = null
   if @BusSegment_Ids = '' set	 @BusSegment_Ids = null
   if @Vertical_Ids = '' set	 @Vertical_Ids	 = null
  if @SubVertical_Ids = '' set	 @SubVertical_Ids= null
  if @SubVertical_Ids = '0' set	 @SubVertical_Ids= null
  ----added on 14/11/2017 sneha (end)

IF @TransType = 'I' OR  @TransType = 'U'
	BEGIN
	
		IF @SalBudget_Type <> 'Appraisal Rating'
			BEGIN 
				IF EXISTS (SELECT SalBudget_ID FROM T0200_Salary_Budget WITH (NOLOCK) WHERE SalBudget_Type = @SalBudget_Type AND SalBudget_Date = @SalBudget_Date AND Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)    
					BEGIN    
						RAISERROR('@@Same Date Entry Exists@@',16,2)
						RETURN  
					END 
			END
		ELSE
			BEGIN
				IF EXISTS (SELECT SalBudget_ID FROM T0200_Salary_Budget WITH (NOLOCK) WHERE SalBudget_Type = @SalBudget_Type AND SalBudget_Date = @SalBudget_Date AND Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID				
								AND Branch_Ids IS NULL AND SubBranch_Ids IS NULL AND Grade_Ids IS NULL AND Type_Ids IS NULL AND Dept_Ids IS NULL AND Desig_Ids IS NULL 
								AND Cat_Ids IS NULL AND BusSegment_Ids IS NULL AND Vertical_Ids IS NULL AND SubVertical_Ids IS NULL)    
					BEGIN 
						RAISERROR('@@Same Date Entry Exists@@',16,2)						
						RETURN  
					END 
				IF (@Branch_Ids IS NULL AND @SubBranch_Ids IS NULL AND @Grade_Ids IS NULL AND @Type_Ids IS NULL AND @Dept_Ids IS NULL AND @Desig_Ids IS NULL 
								AND @Cat_Ids IS NULL AND @BusSegment_Ids IS NULL AND @Vertical_Ids IS NULL AND @SubVertical_Ids IS NULL)
					BEGIN
						IF EXISTS (SELECT SalBudget_ID FROM T0200_Salary_Budget WITH (NOLOCK) WHERE SalBudget_Type = @SalBudget_Type AND SalBudget_Date = @SalBudget_Date AND Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID				
								AND (Branch_Ids IS NULL OR SubBranch_Ids IS NULL OR Grade_Ids IS NULL OR Type_Ids IS NULL OR Dept_Ids IS NULL OR Desig_Ids IS NULL 
									OR Cat_Ids IS NULL OR BusSegment_Ids IS NULL OR Vertical_Ids IS NULL OR SubVertical_Ids IS NULL))    
							BEGIN 
								RAISERROR('@@Same Date Entry Exists@@',16,2)						
								RETURN  
							END 
					END
					
				IF @Dept_Ids IS NOT NULL
					BEGIN
						IF EXISTS (SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
							WHERE EXISTS(SELECT 1 FROM dbo.Split(@Dept_Ids, '#') T1 
							CROSS APPLY (select data from dbo.Split(T.Dept_IDs, '#') T2 Where T2.data=T1.Data) T2)
							AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
							BEGIN
								RAISERROR('@@Same Date Entry Exists@@',16,2)
								RETURN 
							END						
					END
				ELSE IF @Desig_Ids IS NOT NULL
					BEGIN
						IF EXISTS (SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
							WHERE EXISTS(SELECT 1 FROM dbo.Split(@Desig_Ids, '#') T1 
							CROSS APPLY (select data from dbo.Split(T.Desig_Ids, '#') T2 Where T2.data=T1.Data) T2)
							AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
						BEGIN
							RAISERROR('@@Same Date Entry Exists@@',16,2)
							RETURN 
						END
					END
				ELSE IF @Grade_Ids IS NOT NULL
					BEGIN
						IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
							WHERE EXISTS(SELECT 1 FROM dbo.Split(@Grade_Ids, '#') T1 
							CROSS APPLY (select data from dbo.Split(T.Grade_Ids, '#') T2 Where T2.data=T1.Data) T2)
							AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
						BEGIN
							RAISERROR('@@Same Date Entry Exists@@',16,2)
							RETURN 
						END
					END
				ELSE IF @Type_Ids IS NOT NULL
					BEGIN
						IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
							WHERE EXISTS(SELECT 1 FROM dbo.Split(@Type_Ids, '#') T1 
							CROSS APPLY (select data from dbo.Split(T.Type_Ids, '#') T2 Where T2.data=T1.Data) T2)
							AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
						BEGIN
							RAISERROR('@@Same Date Entry Exists@@',16,2)
							RETURN 
						END
					END
				ELSE IF @Cat_Ids IS NOT NULL
					BEGIN
						IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
							WHERE EXISTS(SELECT 1 FROM dbo.Split(@Cat_Ids, '#') T1 
							CROSS APPLY (select data from dbo.Split(T.Cat_Ids, '#') T2 Where T2.data=T1.Data) T2)
							AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
						BEGIN  
							RAISERROR('@@Same Date Entry Exists@@',16,2)
							RETURN 
						END
					END
				ELSE IF @BusSegment_Ids IS NOT NULL
					BEGIN
						IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
							WHERE EXISTS(SELECT 1 FROM dbo.Split(@BusSegment_Ids, '#') T1 
							CROSS APPLY (select data from dbo.Split(T.BusSegment_Ids, '#') T2 Where T2.data=T1.Data) T2)
							AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
						BEGIN
							RAISERROR('@@Same Date Entry Exists@@',16,2)
							RETURN 
						END
					END
				ELSE IF @Branch_Ids IS NOT NULL
					BEGIN
						IF @SubBranch_Ids IS NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
									WHERE EXISTS(SELECT 1 FROM dbo.Split(@Branch_Ids, '#') T1 
									CROSS APPLY (select data from dbo.Split(T.Branch_Ids, '#') T2 Where T2.data=T1.Data) T2)
									AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
								BEGIN
									RAISERROR('@@Same Date Entry Exists@@',16,2)
									RETURN 
								END
							END
						ELSE
							BEGIN
								IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
									WHERE EXISTS(SELECT 1 FROM dbo.Split(@SubBranch_Ids, '#') T1 
									CROSS APPLY (select data from dbo.Split(T.SubBranch_Ids, '#') T2 Where T2.data=T1.Data) T2)
									AND T.SalBudget_Type =@SalBudget_Type AND T.SalBudget_Date=@SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
								BEGIN
									RAISERROR('@@Same Date Entry Exists@@',16,2)
									RETURN 
								END
							END
					END	
				ELSE IF @Vertical_Ids IS NOT NULL
					BEGIN
						IF @SubVertical_Ids IS NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
									WHERE EXISTS(SELECT 1 FROM dbo.Split(@Vertical_Ids,'#') T1
									CROSS APPLY (SELECT * FROM dbo.Split(T.Vertical_Ids,'#') T2 WHERE T2.data = T1.Data) T2)
									AND T.SalBudget_Type = @SalBudget_Type AND T.SalBudget_Date = @SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
								 BEGIN
									RAISERROR('@@Same Date Entry Exists@@',16,2)
									RETURN 
								 END
							END
						Else	
							BEGIN
								IF EXISTS(SELECT 1 FROM T0200_Salary_Budget T WITH (NOLOCK)
									WHERE EXISTS(SELECT 1 FROM dbo.Split(@SubVertical_Ids,'#') T1
									CROSS APPLY (SELECT * FROM dbo.Split(T.SubVertical_Ids,'#') T2 WHERE T2.data = T1.Data) T2)
									AND T.SalBudget_Type = @SalBudget_Type AND T.SalBudget_Date = @SalBudget_Date AND T.Cmp_ID = @Cmp_ID AND SalBudget_ID <> @SalBudget_ID)
								 BEGIN
									RAISERROR('@@Same Date Entry Exists@@',16,2)
									RETURN 
								 END
							END
					END				
			END
		
	END	
IF @TransType = 'I'
	BEGIN	
	
		SELECT @SalBudget_ID = ISNULL(MAX(SalBudget_ID),0) + 1 FROM T0200_Salary_Budget  WITH (NOLOCK)
		 
		INSERT INTO T0200_Salary_Budget(
						SalBudget_ID,
						SalBudget_Type,
						SalBudget_Date,
						Cmp_ID,
						Created_By,
						Created_Date,
						Branch_Ids,
						SubBranch_Ids,
						Grade_Ids,
						Type_Ids,
						Dept_Ids,
						Desig_Ids,
						Cat_Ids,
						BusSegment_Ids,
						Vertical_Ids,
						SubVertical_Ids,
						Appraisal_DateFrom,
						Appraisal_DateTo
					)
			 VALUES(
						@SalBudget_ID,
						@SalBudget_Type,
						@SalBudget_Date,
						@Cmp_ID,
						@Login_ID,
						GETDATE(),
						@Branch_Ids,
						@SubBranch_Ids,
						@Grade_Ids,
						@Type_Ids,
						@Dept_Ids,
						@Desig_Ids,
						@Cat_Ids,
						@BusSegment_Ids,
						@Vertical_Ids,
						@SubVertical_Ids,
						@Appraisal_DateFrom,
						@Appraisal_DateTo
					)
		
		SELECT Table1.value('(ID/text())[1]','numeric(18,0)') AS ID,
			Table1.value('(Name/text())[1]','varchar(50)') AS Name,
			Table1.value('(Increment/text())[1]','varchar(50)') AS Increment,
			Table1.value('(CurrentBasicSalary/text())[1]','numeric(18,2)') AS CurrentBasicSalary,
			Table1.value('(CurrentGrossSalary/text())[1]','numeric(18,2)') AS CurrentGrossSalary,
			Table1.value('(CurrentCTCSalary/text())[1]','numeric(18,2)') AS CurrentCTCSalary,
			Table1.value('(IncrementBasicAmount/text())[1]','numeric(18,2)') AS IncrementBasicAmount,
			Table1.value('(IncrementGrossAmount/text())[1]','numeric(18,2)') AS IncrementGrossAmount,
			Table1.value('(IncrementCTCAmount/text())[1]','numeric(18,2)') AS IncrementCTCAmount,
			Table1.value('(ProposeBasicSalary/text())[1]','numeric(18,2)') AS ProposeBasicSalary,
			Table1.value('(ProposeGrossSalary/text())[1]','numeric(18,2)') AS ProposeGrossSalary,
			Table1.value('(ProposeCTCSalary/text())[1]','numeric(18,2)') AS ProposeCTCSalary
			INTO #ISalaryBudget FROM @BudgetDetails.nodes('/SalaryBudget/Table1') AS Temp(Table1)
		
		DECLARE ISALARYBUDGET_CURSOR CURSOR FAST_FORWARD FOR
		SELECT ID,Name,CONVERT(numeric(18,2), Increment) AS 'Increment',CurrentBasicSalary,CurrentGrossSalary,CurrentCTCSalary,IncrementBasicAmount,IncrementGrossAmount,IncrementCTCAmount,ProposeBasicSalary,ProposeGrossSalary,ProposeCTCSalary FROM #ISalaryBudget
		OPEN ISALARYBUDGET_CURSOR
		FETCH NEXT FROM ISALARYBUDGET_CURSOR INTO @ID,@Name,@Increment,@CurrentBasicSalary,@CurrentGrossSalary,@CurrentCTCSalary,@IncrementBasicAmount,@IncrementGrossAmount,@IncrementCTCAmount,@ProposeBasicSalary,@ProposeGrossSalary,@ProposeCTCSalary
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @SalBudget_DetailID = ISNULL(MAX(SalBudget_DetailID), 0) + 1 FROM T0210_Salary_Budget_Details WITH (NOLOCK)
				
				INSERT INTO T0210_Salary_Budget_Details(SalBudget_DetailID,SalBudget_ID,SalBudget_TransID,OldBasic_Salary,OldGross_Salary,
				OldCTC_Salary,Increment_Per,Increment_BasicAmt,Increment_GrossAmt,Increment_CTCAmt,NewBasic_Salary,NewGross_Salary,NewCTC_Salary,Cmp_ID,
				Created_By,Created_Date)
				VALUES(@SalBudget_DetailID,@SalBudget_ID,@ID,@CurrentBasicSalary,@CurrentGrossSalary,@CurrentCTCSalary,@Increment,@IncrementBasicAmount,
				@IncrementGrossAmount,@IncrementCTCAmount,@ProposeBasicSalary,@ProposeGrossSalary,@ProposeCTCSalary,@Cmp_ID,@Login_ID,GETDATE())
				
				FETCH NEXT FROM ISALARYBUDGET_CURSOR INTO @ID,@Name,@Increment,@CurrentBasicSalary,@CurrentGrossSalary,@CurrentCTCSalary,@IncrementBasicAmount,@IncrementGrossAmount,@IncrementCTCAmount,@ProposeBasicSalary,@ProposeGrossSalary,@ProposeCTCSalary
			END
		CLOSE ISALARYBUDGET_CURSOR     
		DEALLOCATE ISALARYBUDGET_CURSOR
	
	END
IF @TransType = 'U'
	BEGIN
		--SELECT @SalBudget_ID = ISNULL(MAX(SalBudget_ID),0) + 1 FROM T0200_Salary_Budget  
		
		 
		--INSERT INTO T0200_Salary_Budget(SalBudget_ID,SalBudget_Type,SalBudget_Date,Cmp_ID,Created_By,Created_Date)
		--VALUES(@SalBudget_ID,@SalBudget_Type,@SalBudget_Date,@Cmp_ID,@Login_ID,GETDATE())
		
		UPDATE T0200_Salary_Budget 
		SET SalBudget_Type = @SalBudget_Type,
			SalBudget_Date = @SalBudget_Date,
			Cmp_ID = @Cmp_ID,
			Modified_By = @Login_ID ,
			Modified_Date = GETDATE(),
			Branch_Ids = @Branch_Ids,
			SubBranch_Ids= @SubBranch_Ids,
			Grade_Ids = @Grade_Ids,
			Type_Ids = @Type_Ids,
			Dept_Ids = @Dept_Ids,
			Desig_Ids = @Desig_Ids,
			Cat_Ids = @Cat_Ids,
			BusSegment_Ids = @BusSegment_Ids,
			Vertical_Ids = @Vertical_Ids,
			SubVertical_Ids = @SubVertical_Ids,
			Appraisal_DateFrom = @Appraisal_DateFrom,
			Appraisal_DateTo = @Appraisal_DateTo
		WHERE SalBudget_ID = @SalBudget_ID
		
		DELETE FROM T0210_Salary_Budget_Details WHERE SalBudget_ID = @SalBudget_ID
		
		SELECT Table1.value('(ID/text())[1]','numeric(18,0)') AS ID,
			Table1.value('(Name/text())[1]','varchar(50)') AS Name,
			Table1.value('(Increment/text())[1]','varchar(50)') AS Increment,
			Table1.value('(CurrentBasicSalary/text())[1]','numeric(18,2)') AS CurrentBasicSalary,
			Table1.value('(CurrentGrossSalary/text())[1]','numeric(18,2)') AS CurrentGrossSalary,
			Table1.value('(CurrentCTCSalary/text())[1]','numeric(18,2)') AS CurrentCTCSalary,
			Table1.value('(IncrementBasicAmount/text())[1]','numeric(18,2)') AS IncrementBasicAmount,
			Table1.value('(IncrementGrossAmount/text())[1]','numeric(18,2)') AS IncrementGrossAmount,
			Table1.value('(IncrementCTCAmount/text())[1]','numeric(18,2)') AS IncrementCTCAmount,
			Table1.value('(ProposeBasicSalary/text())[1]','numeric(18,2)') AS ProposeBasicSalary,
			Table1.value('(ProposeGrossSalary/text())[1]','numeric(18,2)') AS ProposeGrossSalary,
			Table1.value('(ProposeCTCSalary/text())[1]','numeric(18,2)') AS ProposeCTCSalary
			INTO #USalaryBudget FROM @BudgetDetails.nodes('/SalaryBudget/Table1') AS Temp(Table1)
		
		DECLARE USALARYBUDGET_CURSOR CURSOR FAST_FORWARD FOR
		SELECT ID,Name,CONVERT(numeric(18,2), Increment) AS 'Increment',CurrentBasicSalary,CurrentGrossSalary,CurrentCTCSalary,IncrementBasicAmount,IncrementGrossAmount,IncrementCTCAmount,ProposeBasicSalary,ProposeGrossSalary,ProposeCTCSalary FROM #USalaryBudget
		OPEN USALARYBUDGET_CURSOR
		FETCH NEXT FROM USALARYBUDGET_CURSOR INTO @ID,@Name,@Increment,@CurrentBasicSalary,@CurrentGrossSalary,@CurrentCTCSalary,@IncrementBasicAmount,@IncrementGrossAmount,@IncrementCTCAmount,@ProposeBasicSalary,@ProposeGrossSalary,@ProposeCTCSalary
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @SalBudget_DetailID = ISNULL(MAX(SalBudget_DetailID), 0) + 1 FROM T0210_Salary_Budget_Details  WITH (NOLOCK)
				
				INSERT INTO T0210_Salary_Budget_Details(SalBudget_DetailID,SalBudget_ID,SalBudget_TransID,OldBasic_Salary,OldGross_Salary,
				OldCTC_Salary,Increment_Per,Increment_BasicAmt,Increment_GrossAmt,Increment_CTCAmt,NewBasic_Salary,NewGross_Salary,NewCTC_Salary,Cmp_ID,
				Created_By,Created_Date)
				VALUES(@SalBudget_DetailID,@SalBudget_ID,@ID,@CurrentBasicSalary,@CurrentGrossSalary,@CurrentCTCSalary,@Increment,@IncrementBasicAmount,
				@IncrementGrossAmount,@IncrementCTCAmount,@ProposeBasicSalary,@ProposeGrossSalary,@ProposeCTCSalary,@Cmp_ID,@Login_ID,GETDATE())
				
				FETCH NEXT FROM USALARYBUDGET_CURSOR INTO @ID,@Name,@Increment,@CurrentBasicSalary,@CurrentGrossSalary,@CurrentCTCSalary,@IncrementBasicAmount,@IncrementGrossAmount,@IncrementCTCAmount,@ProposeBasicSalary,@ProposeGrossSalary,@ProposeCTCSalary
			END
		CLOSE USALARYBUDGET_CURSOR     
		DEALLOCATE USALARYBUDGET_CURSOR
	
	END
IF @TransType = 'D'
	BEGIN
		DELETE FROM T0210_Salary_Budget_Details WHERE SalBudget_ID = @SalBudget_ID
		DELETE FROM T0200_Salary_Budget WHERE SalBudget_ID = @SalBudget_ID
	END
IF @TransType = 'S'
	BEGIN
		DECLARE @Apptype as VARCHAR(50)
		SELECT @Apptype = SalBudget_Type FROM T0200_Salary_Budget WITH (NOLOCK) WHERE SalBudget_ID = @SalBudget_ID
		
		IF @Apptype <> 'Appraisal Rating'
			BEGIN
				SELECT SB.SalBudget_ID,SBD.SalBudget_TransID AS 'ID',BM.Branch_Code AS 'Code',BM.Branch_Name AS 'Name',SBD.Increment_Per AS 'Increment',
				SBD.OldBasic_Salary AS 'OldBasic_Salary',SBd.OldGross_Salary AS 'OldGross_Salary',SBD.OldCTC_Salary AS 'OldCTC',
				SBD.Increment_BasicAmt AS 'IncBasicAmt',SBD.Increment_GrossAmt  AS 'IncGrossAmt',SBD.Increment_CTCAmt AS 'IncCTCAmt',
				SBD.NewBasic_Salary AS 'NewBasicAmt',SBD.NewGross_Salary AS 'NewGrossAmt',SBD.NewCTC_Salary AS 'NewCTCAmt',
				SB.SalBudget_Type,CONVERT(varchar(11), SB.SalBudget_Date,103) AS 'SalBudget_Date',
				0 AS 'Branch_ID',0 AS 'SubBranch_ID',0 AS 'Grd_ID',0 AS 'Type_ID',0 AS 'Dept_ID',0 AS 'Desig_ID',0 AS 'Cat_ID',
				0 AS 'Segment_ID',0 AS 'Vertical_ID',0 AS 'SubVertical_ID',
				'' AS 'Branch_Name','' AS 'SubBranch_Name','' AS 'Grade_Name','' AS 'Type_Name','' AS 'Dept_Name','' AS 'Desig_Name','' AS 'Cat_Name',
				'' AS 'Segment_Name','' AS 'Vertical_Name','' AS 'SubVertical_Name'
				
				FROM T0200_Salary_Budget SB WITH (NOLOCK)
				INNER JOIN T0210_Salary_Budget_Details SBD WITH (NOLOCK) ON SB.SalBudget_ID = SBD.SalBudget_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON SBD.SalBudget_TransID = BM.Branch_ID
				WHERE SB.SalBudget_ID = @SalBudget_ID  AND SB.SalBudget_Type = 'Branch'
		
				UNION ALL
				
				SELECT SB.SalBudget_ID,SBD.SalBudget_TransID AS 'ID',DM.Dept_Code AS 'Code',DM.Dept_Name AS 'Name',SBD.Increment_Per AS 'Increment',
				SBD.OldBasic_Salary AS 'OldBasic_Salary',SBd.OldGross_Salary AS 'OldGross_Salary',SBD.OldCTC_Salary AS 'OldCTC',
				SBD.Increment_BasicAmt AS 'IncBasicAmt',SBD.Increment_GrossAmt  AS 'IncGrossAmt',SBD.Increment_CTCAmt AS 'IncCTCAmt',
				SBD.NewBasic_Salary AS 'NewBasicAmt',SBD.NewGross_Salary AS 'NewGrossAmt',SBD.NewCTC_Salary AS 'NewCTCAmt',
				SB.SalBudget_Type,CONVERT(varchar(11), SB.SalBudget_Date,103) AS 'SalBudget_Date',
				0 AS 'Branch_ID',0 AS 'SubBranch_ID',0 AS 'Grd_ID',0 AS 'Type_ID',0 AS 'Dept_ID',0 AS 'Desig_ID',0 AS 'Cat_ID',
				0 AS 'Segment_ID',0 AS 'Vertical_ID',0 AS 'SubVertical_ID',
				'' AS 'Branch_Name','' AS 'SubBranch_Name','' AS 'Grade_Name','' AS 'Type_Name','' AS 'Dept_Name','' AS 'Desig_Name','' AS 'Cat_Name',
				'' AS 'Segment_Name','' AS 'Vertical_Name','' AS 'SubVertical_Name'
				
				FROM T0200_Salary_Budget SB WITH (NOLOCK)
				INNER JOIN T0210_Salary_Budget_Details SBD WITH (NOLOCK) ON SB.SalBudget_ID = SBD.SalBudget_ID
				INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON SBD.SalBudget_TransID = DM.Dept_Id
				WHERE SB.SalBudget_ID = @SalBudget_ID  AND SB.SalBudget_Type = 'Department'
				
				UNION ALL
		
				SELECT SB.SalBudget_ID,SBD.SalBudget_TransID AS 'ID',DM.Desig_Code AS 'Code',DM.Desig_Name AS 'Name',SBD.Increment_Per AS 'Increment',
				SBD.OldBasic_Salary AS 'OldBasic_Salary',SBd.OldGross_Salary AS 'OldGross_Salary',SBD.OldCTC_Salary AS 'OldCTC',
				SBD.Increment_BasicAmt AS 'IncBasicAmt',SBD.Increment_GrossAmt  AS 'IncGrossAmt',SBD.Increment_CTCAmt AS 'IncCTCAmt',
				SBD.NewBasic_Salary AS 'NewBasicAmt',SBD.NewGross_Salary AS 'NewGrossAmt',SBD.NewCTC_Salary AS 'NewCTCAmt',
				SB.SalBudget_Type,CONVERT(varchar(11), SB.SalBudget_Date,103) AS 'SalBudget_Date',
				0 AS 'Branch_ID',0 AS 'SubBranch_ID',0 AS 'Grd_ID',0 AS 'Type_ID',0 AS 'Dept_ID',0 AS 'Desig_ID',0 AS 'Cat_ID',
				0 AS 'Segment_ID',0 AS 'Vertical_ID',0 AS 'SubVertical_ID',
				'' AS 'Branch_Name','' AS 'SubBranch_Name','' AS 'Grade_Name','' AS 'Type_Name','' AS 'Dept_Name','' AS 'Desig_Name','' AS 'Cat_Name',
				'' AS 'Segment_Name','' AS 'Vertical_Name','' AS 'SubVertical_Name'
				
				FROM T0200_Salary_Budget SB WITH (NOLOCK)
				INNER JOIN T0210_Salary_Budget_Details SBD WITH (NOLOCK) ON SB.SalBudget_ID = SBD.SalBudget_ID
				INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON SBD.SalBudget_TransID = DM.Desig_ID
				WHERE SB.SalBudget_ID = @SalBudget_ID AND SB.SalBudget_Type = 'Designation'
				
				UNION ALL
				
				SELECT SB.SalBudget_ID,SBD.SalBudget_TransID AS 'ID','' AS 'Code',GM.Grd_Name AS 'Name',SBD.Increment_Per AS 'Increment',
				SBD.OldBasic_Salary AS 'OldBasic_Salary',SBd.OldGross_Salary AS 'OldGross_Salary',SBD.OldCTC_Salary AS 'OldCTC',
				SBD.Increment_BasicAmt AS 'IncBasicAmt',SBD.Increment_GrossAmt  AS 'IncGrossAmt',SBD.Increment_CTCAmt AS 'IncCTCAmt',
				SBD.NewBasic_Salary AS 'NewBasicAmt',SBD.NewGross_Salary AS 'NewGrossAmt',SBD.NewCTC_Salary AS 'NewCTCAmt',
				SB.SalBudget_Type,CONVERT(varchar(11), SB.SalBudget_Date,103) AS 'SalBudget_Date',
				0 AS 'Branch_ID',0 AS 'SubBranch_ID',0 AS 'Grd_ID',0 AS 'Type_ID',0 AS 'Dept_ID',0 AS 'Desig_ID',0 AS 'Cat_ID',
				0 AS 'Segment_ID',0 AS 'Vertical_ID',0 AS 'SubVertical_ID',
				'' AS 'Branch_Name','' AS 'SubBranch_Name','' AS 'Grade_Name','' AS 'Type_Name','' AS 'Dept_Name','' AS 'Desig_Name','' AS 'Cat_Name',
				'' AS 'Segment_Name','' AS 'Vertical_Name','' AS 'SubVertical_Name'
				
				FROM T0200_Salary_Budget SB WITH (NOLOCK)
				INNER JOIN T0210_Salary_Budget_Details SBD WITH (NOLOCK) ON SB.SalBudget_ID = SBD.SalBudget_ID
				INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON SBD.SalBudget_TransID = GM.Grd_ID
				WHERE SB.SalBudget_ID = @SalBudget_ID AND SB.SalBudget_Type = 'Grade'
		
			UNION ALL
			
			SELECT SB.SalBudget_ID,SBD.SalBudget_TransID AS 'ID',EM.Alpha_Emp_Code AS 'Code',(EM.Alpha_Emp_Code +' - ' +EM.Initial + ' '+ EM.Emp_First_Name + ' ' + ISNULL(EM.Emp_Second_Name,'')+' '+ ISNULL(EM.Emp_Last_Name,'')  ) AS 'Name',
			SBD.Increment_Per AS 'Increment',
			SBD.OldBasic_Salary AS 'OldBasic_Salary',SBd.OldGross_Salary AS 'OldGross_Salary',SBD.OldCTC_Salary AS 'OldCTC',
			SBD.Increment_BasicAmt AS 'IncBasicAmt',SBD.Increment_GrossAmt  AS 'IncGrossAmt',SBD.Increment_CTCAmt AS 'IncCTCAmt',
			SBD.NewBasic_Salary AS 'NewBasicAmt',SBD.NewGross_Salary AS 'NewGrossAmt',SBD.NewCTC_Salary AS 'NewCTCAmt',
			SB.SalBudget_Type,CONVERT(varchar(11), SB.SalBudget_Date,103) AS 'SalBudget_Date',
			ISNULL(IC.Branch_ID,0) AS 'Branch_ID',ISNULL(IC.subBranch_ID,0) AS 'SubBranch_ID',
			ISNULL(IC.Grd_ID,0) AS 'Grd_ID',ISNULL(IC.Type_ID,0) AS 'Type_ID',ISNULL(IC.Dept_ID,0) AS 'Dept_ID',ISNULL(IC.Desig_Id,0) AS 'Desig_ID',
			ISNULL(IC.Cat_ID,0) AS 'Cat_ID',ISNULL(IC.Segment_ID,0) AS 'Segment_ID',ISNULL(IC.Vertical_ID,0) AS 'Vertical_ID',
			ISNULL(IC.SubVertical_ID,0) AS 'SubVertical_ID' ,
			B.Branch_Name AS 'Branch_Name',SC.SubBranch_Name AS 'SubBranch_Name',G.Grd_Name AS 'Grade_Name',T.Type_Name AS 'Type_Name',D.Dept_Name AS 'Dept_Name',DG.Desig_Name AS 'Desig_Name',C.Cat_Name AS 'Cat_Name',
			BS.Segment_Name AS 'Segment_Name',V.Vertical_Name AS 'Vertical_Name',SV.SubVertical_Name AS 'SubVertical_Name'
			FROM T0200_Salary_Budget SB WITH (NOLOCK)
			INNER JOIN T0210_Salary_Budget_Details SBD WITH (NOLOCK) ON SB.SalBudget_ID = SBD.SalBudget_ID
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON SBD.SalBudget_TransID = EM.Emp_ID
			INNER JOIN T0095_INCREMENT IC WITH (NOLOCK) ON SBD.SalBudget_TransID = IC.Emp_ID
			INNER JOIN
			(
				SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK)
				INNER JOIN
					(
						SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
						FROM T0095_INCREMENT WITH (NOLOCK)
						GROUP BY Emp_ID
					)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
			) AS TIC ON IC.Increment_ID = TIC.Increment_ID
			LEFT JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = IC.Branch_ID
			LEFT JOIN T0050_SubBranch SC WITH (NOLOCK) ON SC.SubBranch_ID = IC.subBranch_ID
			LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = IC.Dept_ID 
			LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID = IC.Desig_Id
			LEFT JOIN T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = IC.Grd_ID
			LEFT JOIN T0040_TYPE_MASTER T WITH (NOLOCK) ON T.Type_ID = IC.Type_ID
			LEFT JOIN T0030_CATEGORY_MASTER C WITH (NOLOCK) ON C.Cat_ID = IC.Cat_ID
			LEFT JOIN T0040_Business_Segment BS WITH (NOLOCK) ON BS.Segment_ID = IC.Segment_ID
			LEFT JOIN T0040_Vertical_Segment V WITH (NOLOCK) ON V.Vertical_ID = IC.Vertical_ID
			LEFT JOIN T0050_SubVertical SV WITH (NOLOCK) ON SV.SubVertical_ID = IC.SubVertical_ID
			WHERE SB.SalBudget_ID = @SalBudget_ID AND SB.SalBudget_Type = 'Employee'
		END	
		---added by sneha on 14/11/2017 for appraisal---------------(start)
	ELSE
		BEGIN		
		
			SELECT SB.SalBudget_ID,SBD.SalBudget_TransID AS 'ID',0 AS 'Code',RM.Achievement_Level AS 'Name',SBD.Increment_Per AS 'Increment',
			SBD.OldBasic_Salary AS 'OldBasic_Salary',SBd.OldGross_Salary AS 'OldGross_Salary',SBD.OldCTC_Salary AS 'OldCTC',
			SBD.Increment_BasicAmt AS 'IncBasicAmt',SBD.Increment_GrossAmt  AS 'IncGrossAmt',SBD.Increment_CTCAmt AS 'IncCTCAmt',
			SBD.NewBasic_Salary AS 'NewBasicAmt',SBD.NewGross_Salary AS 'NewGrossAmt',SBD.NewCTC_Salary AS 'NewCTCAmt',
			SB.SalBudget_Type,CONVERT(varchar(11), SB.SalBudget_Date,103) AS 'SalBudget_Date',
			isnull(SB.Branch_Ids,0) AS 'Branch_ID',isnull(SB.SubBranch_Ids,0) AS 'SubBranch_ID',isnull(SB.Grade_Ids,0) AS 'Grd_ID',isnull(SB.Type_Ids,0) AS 'Type_ID',isnull(SB.Dept_Ids,0) AS 'Dept_ID',isnull(SB.Desig_Ids,0) AS 'Desig_ID',isnull(SB.Cat_Ids,0) AS 'Cat_ID',
			isnull(SB.BusSegment_Ids,0) AS 'Segment_ID',isnull(SB.Vertical_Ids,0) AS 'Vertical_ID',isnull(SB.SubVertical_Ids,0) AS 'SubVertical_ID',
			isnull(SB.Branch_Name,'') AS 'Branch_Name',isnull(SB.SubBranch_Name,'') AS 'SubBranch_Name',isnull(SB.Grade_Name,'') AS 'Grade_Name',isnull(SB.Type_Name,'') AS 'Type_Name',isnull(SB.Dept_Name,'') AS 'Dept_Name',isnull(SB.Desig_Name,'') AS 'Desig_Name',isnull(SB.Cat_Name,'') AS 'Cat_Name',
			isnull(SB.Segment_Name,'') AS 'Segment_Name',isnull(SB.Vertical_Name,'') AS 'Vertical_Name',isnull(SB.SubVertical_Name,'') AS 'SubVertical_Name'
			FROM V0200_Salary_Budget SB
			INNER JOIN T0210_Salary_Budget_Details SBD WITH (NOLOCK) ON SB.SalBudget_ID = SBD.SalBudget_ID
			INNER JOIN T0040_Achievement_Master RM WITH (NOLOCK) ON SBD.SalBudget_TransID = RM.AchievementId
			WHERE SB.SalBudget_ID = @SalBudget_ID AND SB.SalBudget_Type = 'Appraisal Rating'
		END
		---added by sneha on 14/11/2017 for appraisal---------------(end)
	END
IF @TransType = 'E' -- For Employee Export to Excel
	BEGIN
	 
		SELECT EM.Alpha_Emp_Code AS 'Code',(EM.Initial + ' '+ EM.Emp_First_Name + ' ' + ISNULL(EM.Emp_Second_Name,'')+' '+ ISNULL(EM.Emp_Last_Name,'')  ) AS 'Name',
		DM.Dept_Name AS 'Department',TDM.Desig_Name AS 'Designation',CONVERT(varchar(11), EM.Date_Of_Join,103) AS 'Joining Date',
		(CONVERT(varchar(3),DATEDIFF(MONTH, EM.Date_Of_Join, GETDATE())/12) +'.'+ CONVERT(varchar(2),DATEDIFF(MONTH, EM.Date_Of_Join, GETDATE()) % 12)) AS 'Experience',
		STUFF((	SELECT ',' + US.Qual_Name FROM T0040_QUALIFICATION_MASTER US WITH (NOLOCK)
				INNER JOIN T0090_EMP_QUALIFICATION_DETAIL TM WITH (NOLOCK) ON US.Qual_ID = TM.Qual_ID
				WHERE TM.Emp_ID = IC.Emp_ID
				FOR XML PATH('')
				), 1, 1, '') AS 'Qualification',
		SBD.Increment_Per AS 'Increment',
		SBD.OldBasic_Salary AS 'CurrentBasicSalary',SBd.OldGross_Salary AS 'CurrentGrossSalary',SBD.OldCTC_Salary AS 'CurrentCTCSalary',
		SBD.Increment_BasicAmt AS 'IncrementBasicAmount',SBD.Increment_GrossAmt  AS 'IncrementGrossAmount',SBD.Increment_CTCAmt AS 'IncrementCTCAmount',
		SBD.NewBasic_Salary AS 'ProposeBasicSalary',SBD.NewGross_Salary AS 'ProposeGrossSalary',SBD.NewCTC_Salary AS 'ProposeCTCSalary'
		
		FROM T0200_Salary_Budget SB WITH (NOLOCK)
		INNER JOIN T0210_Salary_Budget_Details SBD WITH (NOLOCK) ON SB.SalBudget_ID = SBD.SalBudget_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON SBD.SalBudget_TransID = EM.Emp_ID
		INNER JOIN T0095_INCREMENT IC WITH (NOLOCK) ON SBD.SalBudget_TransID = IC.Emp_ID
		INNER JOIN
		(
			SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK)
			INNER JOIN
				(
					SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK)
					GROUP BY Emp_ID
				)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
		) AS TIC ON IC.Increment_ID = TIC.Increment_ID
		INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IC.Dept_ID = DM.Dept_Id
		INNER JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON IC.Desig_Id = TDM.Desig_ID
		WHERE SB.SalBudget_ID = @SalBudget_ID AND SB.SalBudget_Type = 'Employee'
	END
IF @TransType = 'O' -- For Employee Export to Excel
	BEGIN
		SELECT * 
		FROM T0200_Salary_Budget WITH (NOLOCK)
	END

 

