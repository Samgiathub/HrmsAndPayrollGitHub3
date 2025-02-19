CREATE TABLE [dbo].[T0210_MONTHLY_AD_DETAIL] (
    [M_AD_Tran_ID]             NUMERIC (18)    NOT NULL,
    [Sal_Tran_ID]              NUMERIC (18)    NULL,
    [S_Sal_Tran_ID]            NUMERIC (18)    NULL,
    [L_Sal_Tran_ID]            NUMERIC (18)    NULL,
    [Emp_ID]                   NUMERIC (18)    NOT NULL,
    [Cmp_ID]                   NUMERIC (18)    NOT NULL,
    [AD_ID]                    NUMERIC (18)    NOT NULL,
    [For_Date]                 DATETIME        NOT NULL,
    [M_AD_Percentage]          NUMERIC (18, 5) NULL,
    [M_AD_Amount]              NUMERIC (18, 2) NOT NULL,
    [M_AD_Flag]                CHAR (1)        NOT NULL,
    [M_AD_Actual_Per_Amount]   NUMERIC (18, 5) NOT NULL,
    [M_AD_Calculated_Amount]   NUMERIC (18, 5) NOT NULL,
    [Temp_Sal_Tran_ID]         NUMERIC (18)    NULL,
    [M_AD_NOT_EFFECT_ON_PT]    NUMERIC (1)     CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_AD_NOT_EFFECT_ON_PT] DEFAULT ((0)) NULL,
    [M_AD_NOT_EFFECT_SALARY]   NUMERIC (1)     CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_AD_NOT_EFFECT_SALARY] DEFAULT ((0)) NULL,
    [M_AD_EFFECT_ON_OT]        NUMERIC (1)     CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_AD_EFFECT_ON_OT] DEFAULT ((0)) NULL,
    [M_AD_EFFECT_ON_EXTRA_DAY] NUMERIC (1)     CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_AD_EFFECT_ON_EXTRA_DAY] DEFAULT ((0)) NULL,
    [Sal_Type]                 INT             CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_Sal_Type] DEFAULT ((0)) NULL,
    [M_AD_EFFECT_DATE]         DATETIME        NULL,
    [M_AD_EFFECT_ON_LATE]      TINYINT         CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_M_AD_EFFECT_ON_LATE] DEFAULT ((0)) NULL,
    [M_AREAR_AMOUNT]           NUMERIC (18, 2) NULL,
    [FOR_FNF]                  TINYINT         CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_FOR_FNF] DEFAULT ((0)) NOT NULL,
    [To_date]                  DATETIME        NULL,
    [Split_Shift_Count]        NUMERIC (18)    CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_Split_Shift_Count] DEFAULT ((0)) NOT NULL,
    [Split_Shift_Date]         VARCHAR (3000)  NULL,
    [ReimShow]                 TINYINT         NULL,
    [ReimAmount]               NUMERIC (18, 2) NULL,
    [M_AREAR_AMOUNT_Cutoff]    NUMERIC (18, 2) CONSTRAINT [DF_T0210_MONTHLY_AD_DETAIL_M_AREAR_AMOUNT_Cutoff] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0210_MONTHLY_AD_DETAIL] PRIMARY KEY CLUSTERED ([M_AD_Tran_ID] ASC),
    CONSTRAINT [FK_T0210_MONTHLY_AD_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0210_MONTHLY_AD_DETAIL_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0210_MONTHLY_AD_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0210_MONTHLY_AD_DETAIL_T0200_MONTHLY_SALARY] FOREIGN KEY ([Sal_Tran_ID]) REFERENCES [dbo].[T0200_MONTHLY_SALARY] ([Sal_Tran_ID]),
    CONSTRAINT [FK_T0210_MONTHLY_AD_DETAIL_T0200_MONTHLY_SALARY_LEAVE] FOREIGN KEY ([L_Sal_Tran_ID]) REFERENCES [dbo].[T0200_MONTHLY_SALARY_LEAVE] ([L_Sal_Tran_ID]),
    CONSTRAINT [FK_T0210_MONTHLY_AD_DETAIL_T0201_MONTHLY_SALARY_SETT] FOREIGN KEY ([S_Sal_Tran_ID]) REFERENCES [dbo].[T0201_MONTHLY_SALARY_SETT] ([S_Sal_Tran_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0210_MONTHLY_AD_DETAIL_24_75147313__K5_K11_K6_K7_10]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID] ASC, [M_AD_Flag] ASC, [Cmp_ID] ASC, [AD_ID] ASC)
    INCLUDE([M_AD_Amount]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0210_MONTHLY_AD_DETAIL_24_75147313__K6_K7_K5_K1_K10_K11_22]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Cmp_ID] ASC, [AD_ID] ASC, [Emp_ID] ASC, [M_AD_Tran_ID] ASC, [M_AD_Amount] ASC, [M_AD_Flag] ASC)
    INCLUDE([M_AREAR_AMOUNT]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0210_MONTHLY_AD_DETAIL_24_75147313__K7_K5_K1_K24]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([AD_ID] ASC, [Emp_ID] ASC, [M_AD_Tran_ID] ASC, [To_date] ASC);


GO
CREATE NONCLUSTERED INDEX [T0210_Monthly_AD_Detail_Index]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Sal_Tran_ID] ASC, [Emp_ID] ASC, [AD_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0210_MONTHLY_AD_DETAIL_12_2101582525__K5_K10_K7_24]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID] ASC, [M_AD_Amount] ASC, [AD_ID] ASC)
    INCLUDE([To_date]);


GO
CREATE NONCLUSTERED INDEX [Index_10082015]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([For_Date] ASC, [Sal_Type] ASC)
    INCLUDE([Sal_Tran_ID], [Emp_ID], [AD_ID], [M_AD_Calculated_Amount]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0210_MONTHLY_AD_DETAIL_10_1314103722__K5_K11_K1_K7_K2_K8_K6_K24_10]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID] ASC, [M_AD_Flag] ASC, [M_AD_Tran_ID] ASC, [AD_ID] ASC, [Sal_Tran_ID] ASC, [For_Date] ASC, [Cmp_ID] ASC, [To_date] ASC)
    INCLUDE([M_AD_Amount]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0210_MONTHLY_AD_DETAIL_For_P0200_Pre_Salary]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Cmp_ID] ASC, [Temp_Sal_Tran_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [T0210_MONTHLY_AD_DETAIL_IX_Emp_ID_AD_Flag_TranID]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID] ASC, [M_AD_Flag] ASC, [Temp_Sal_Tran_ID] ASC)
    INCLUDE([AD_ID], [M_AD_Amount]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0210_MONTHLY_AD_DETAIL_L_Sal_Tran_ID]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([L_Sal_Tran_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_75147313_5_1]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID], [M_AD_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_5_24_7]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID], [To_date], [AD_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_24_1_7]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([To_date], [M_AD_Tran_ID], [AD_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_1_7]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [AD_ID]);


GO
CREATE STATISTICS [_dta_stat_2101582525_7_1_5_24_6]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([AD_ID], [M_AD_Tran_ID], [Emp_ID], [To_date], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_2101582525_5_1_7_6_2]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID], [M_AD_Tran_ID], [AD_ID], [Cmp_ID], [Sal_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_2101582525_7_24]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([AD_ID], [To_date]);


GO
CREATE STATISTICS [_dta_stat_2101582525_7_1_6_2]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([AD_ID], [M_AD_Tran_ID], [Cmp_ID], [Sal_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_2101582525_24_5_1]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([To_date], [Emp_ID], [M_AD_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_2101582525_1_6_2]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [Cmp_ID], [Sal_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_2101582525_11_5_24]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Flag], [Emp_ID], [To_date]);


GO
CREATE STATISTICS [_dta_stat_2101582525_1_6_7_5]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [Cmp_ID], [AD_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_5_1_7_6_10_11]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID], [M_AD_Tran_ID], [AD_ID], [Cmp_ID], [M_AD_Amount], [M_AD_Flag]);


GO
CREATE STATISTICS [_dta_stat_75147313_11_6_10_1_7]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Flag], [Cmp_ID], [M_AD_Amount], [M_AD_Tran_ID], [AD_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_5_11_6]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID], [M_AD_Flag], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_6_10]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Cmp_ID], [M_AD_Amount]);


GO
CREATE STATISTICS [_dta_stat_75147313_5_6_10_11_7]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID], [Cmp_ID], [M_AD_Amount], [M_AD_Flag], [AD_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_1_11_6]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [M_AD_Flag], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_1_5_11_6_7]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [Emp_ID], [M_AD_Flag], [Cmp_ID], [AD_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_10_7_5_1]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Amount], [AD_ID], [Emp_ID], [M_AD_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_75147313_1_6_10]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [Cmp_ID], [M_AD_Amount]);


GO
CREATE STATISTICS [_dta_stat_75147313_11_7_5_6]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Flag], [AD_ID], [Emp_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1314103722_2_5_8_1_11_6]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Sal_Tran_ID], [Emp_ID], [For_Date], [M_AD_Tran_ID], [M_AD_Flag], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1314103722_2_5_11_8_6_24]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Sal_Tran_ID], [Emp_ID], [M_AD_Flag], [For_Date], [Cmp_ID], [To_date]);


GO
CREATE STATISTICS [_dta_stat_1314103722_24_6_1_2_5_11_8]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([To_date], [Cmp_ID], [M_AD_Tran_ID], [Sal_Tran_ID], [Emp_ID], [M_AD_Flag], [For_Date]);


GO
CREATE STATISTICS [_dta_stat_1314103722_8_2_1]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([For_Date], [Sal_Tran_ID], [M_AD_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_1314103722_6_2_1_5_11]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Cmp_ID], [Sal_Tran_ID], [M_AD_Tran_ID], [Emp_ID], [M_AD_Flag]);


GO
CREATE STATISTICS [_dta_stat_1314103722_1_2_5_11]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [Sal_Tran_ID], [Emp_ID], [M_AD_Flag]);


GO
CREATE STATISTICS [_dta_stat_1314103722_11_2_1]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Flag], [Sal_Tran_ID], [M_AD_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_1314103722_2_1_7_5]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Sal_Tran_ID], [M_AD_Tran_ID], [AD_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1314103722_2_1_5_8_6_24]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Sal_Tran_ID], [M_AD_Tran_ID], [Emp_ID], [For_Date], [Cmp_ID], [To_date]);


GO
CREATE STATISTICS [_dta_stat_1314103722_5_8_7_23_1]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([Emp_ID], [For_Date], [AD_ID], [FOR_FNF], [M_AD_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_1314103722_1_23]
    ON [dbo].[T0210_MONTHLY_AD_DETAIL]([M_AD_Tran_ID], [FOR_FNF]);


GO


-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 20th July, 2018
-- Description:	To calculate the Allowance and Gross by Circular Reference
-- =============================================
CREATE TRIGGER [dbo].[Trg_T0210_MONTHLY_AD_DETAIL_CTC_Update]
   ON  [dbo].[T0210_MONTHLY_AD_DETAIL]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	/*
		IF YOU NEED TO CREATE TABLE USE BELOW SCRIPT... HARDIK 16/03/2019
		
		CREATE TABLE CIRCULAR_REFERENCE (SETTING_ENABLE TINYINT)
	*/

	IF (NOT EXISTS(SELECT 1 FROM SYS.SYSOBJECTS WHERE NAME ='CIRCULAR_REFERENCE' AND TYPE = 'U') --Hardik 16/03/2019 as Other client don't want to use Circular Reference, So When need this Trigger, so Create Circular_Reference Table
		OR EXISTS(SELECT 1 FROM T0050_AD_MASTER WHERE Prorata_On_Salary_Structure = 1))
		AND EXISTS(Select 1 From INSERTED I Inner Join T0050_AD_Master AM On I.AD_ID = AM.AD_ID And AD_DEF_ID Not In (6))
		RETURN;
				
    DECLARE @Cmp_ID			NUMERIC
    DECLARE @Emp_ID			NUMERIC
    DECLARE @For_Date		DateTime
    DECLARE @AD_ID			NUMERIC
    DECLARE @Sal_Tran_ID	NUMERIC
    DECLARE @S_SAL_TRAN_ID	NUMERIC
    
    IF EXISTS(SELECT 1 FROM DELETED)
		BEGIN
			SELECT	@Sal_Tran_ID = IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID),@AD_ID = AD_ID, @Cmp_ID=Cmp_ID, @Emp_ID=Emp_ID, @For_Date=For_Date,@S_SAL_TRAN_ID=S_SAL_TRAN_ID FROM INSERTED			
		END
	ELSE
		BEGIN
			SELECT	@Sal_Tran_ID = IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID),@AD_ID = AD_ID, @Cmp_ID=Cmp_ID, @Emp_ID=Emp_ID, @For_Date=For_Date,@S_SAL_TRAN_ID=S_SAL_TRAN_ID FROM INSERTED
		END

	IF @S_SAL_TRAN_ID IS NOT NULL
		RETURN
		
	DECLARE @Is_CircularRef BIT
	SET @Is_CircularRef = 0
	
	IF EXISTS(SELECT 1 FROM T0050_AD_MASTER WHERE AD_ID=@AD_ID AND AD_DEF_ID IN (6,3,5,2)) -- IS ESIC
		AND EXISTS(SELECT 1 FROM dbo.T0210_MONTHLY_AD_DETAIL MAD 
						INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID=AD.AD_ID
					WHERE IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID)=@Sal_Tran_ID AND AD_CALCULATE_ON='Arrears CTC' and ad.Prorata_On_Salary_Structure = 0) -- HAS Special Allowance Which Calculates On Arrear CTC
		Begin
			
			SET @Is_CircularRef = 1
		END
	ELSE IF EXISTS(SELECT 1 FROM T0050_AD_MASTER WHERE AD_ID=@AD_ID AND AD_CALCULATE_ON='Arrears CTC' and Prorata_On_Salary_Structure = 0 ) -- Is Special Allowance Which Calculates On Arrear CTC
		AND EXISTS(SELECT 1 FROM dbo.T0210_MONTHLY_AD_DETAIL MAD 
						INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID=AD.AD_ID
					WHERE IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID)=@Sal_Tran_ID AND AD_DEF_ID IN (6 ,3,5,2)) -- HAS ESIC
					Begin
						SET @Is_CircularRef = 1
					END
		
		
	IF @Is_CircularRef  = 0 
		BEGIN
			IF EXISTS(SELECT	1 
					  FROM		T0060_EFFECT_AD_MASTER EAM
								INNER JOIN T0050_AD_MASTER AD ON EAM.AD_ID=AD.AD_ID
								INNER JOIN T0060_EFFECT_AD_MASTER EAM1 ON EAM.AD_ID= EAM1.EFFECT_AD_ID AND EAM1.AD_ID=isnull(@AD_ID,0)
					  WHERE		EAM.EFFECT_AD_ID = @AD_ID
								AND AD.AD_CALCULATE_ON IN ('Basic Salary', 'Arrears CTC') 	
								AND EXISTS(SELECT 1 FROM T0210_MONTHLY_AD_DETAIL MAD WHERE Emp_ID=@Emp_ID AND MAD.AD_ID=EAM.AD_ID)
					  )
					  Begin
					
							SET @Is_CircularRef  = 1			
					END
		END 

		
			
	IF @Is_CircularRef  = 0 
		BEGIN
			IF EXISTS(SELECT	1 
					  FROM		T0060_EFFECT_AD_MASTER EAM
								INNER JOIN T0050_AD_MASTER AD ON EAM.AD_ID=AD.AD_ID
					  WHERE		EAM.EFFECT_AD_ID = isnull(@AD_ID,0)
								AND AD.AD_CALCULATE_ON IN ('Gross Salary', 'Arrears CTC') 	and ad.Prorata_On_Salary_Structure = 0
								AND EXISTS(SELECT 1 FROM T0210_MONTHLY_AD_DETAIL MAD WHERE Emp_ID=@Emp_ID AND MAD.AD_ID=EAM.AD_ID)

					  )
					  Begin
						
							SET @Is_CircularRef  = 1	
						END
		END 
			
-------------------------------For Mid Increment --------------------------------------------
--Added by ronakk 11032023 for mid increment case dicuss with Chintan bhai for WC
Declare @LetInc int 

select @LetInc=  EI.Increment_ID 
from T0095_Increment EI
where Increment_ID in 
    (select Max(TI.Increment_ID) Increment_Id from t0095_increment TI inner join
   (Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment 
       Where Increment_effective_Date <=  @For_Date And Cmp_ID=@Cmp_ID And Emp_ID = @Emp_ID 
       and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation') new_inc
   on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
   Where TI.Increment_effective_Date <=  @For_Date And Emp_ID = @Emp_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation')

			If	( select MONTH (Increment_effective_Date) 
                from T0095_Increment 
                where Emp_ID = @Emp_ID and Increment_Effective_date >= @For_Date
                and Increment_Effective_date <= dateadd(DAY,29,@For_Date) and Increment_ID <> @LetInc 
                and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' )  = Month(@For_Date)
				
				and
				
				( select year (Increment_effective_Date) 
                from T0095_Increment 
                where Emp_ID = @Emp_ID and Increment_Effective_date >= @For_Date
                and Increment_Effective_date <= dateadd(DAY,29,@For_Date) and Increment_ID <> @LetInc 
                and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' )  = year(@For_Date)
				Begin


					set @Is_CircularRef=0

			    end


-------------------------------For Mid Increment --------------------------------------------



	IF @Is_CircularRef = 1
		BEGIN									
			DECLARE @Sal_Cal_Days NUMERIC(18,2)
			DECLARE @Out_Of_Days NUMERIC(18,2)
			SELECT	@Sal_Cal_Days= Sal_Cal_Days, @Out_Of_Days= Working_Days
			FROM	T0200_Monthly_Salary
			Where	Sal_Tran_ID=@Sal_Tran_ID

			IF Object_ID('tempdb..#DataCircularRef') IS NOT NULL
				SELECT  @Sal_Cal_Days = IsNull(Sal_Cal_Days,@Sal_Cal_Days),
						@Out_Of_Days = IsNull(Out_of_Days,@Out_Of_Days),
						@For_Date = For_Date
				FROM	#DataCircularRef 
				Where	Emp_ID=@Emp_ID
				

			PRINT 'Has Circular Reference on AD_ID : ' + cast(@ad_ID as varchar(10)) 
			EXEC P_UPDATE_CTC @Cmp_ID=@Cmp_ID, @Emp_ID=@Emp_ID, @For_Date=@For_Date, @Sal_Tran_ID=@Sal_Tran_ID,@Sal_Cal_Days=@Sal_Cal_Days,@S_SAL_TRAN_ID=@S_SAL_TRAN_ID,@AD_ID=@AD_ID,@Out_Of_Days=@Out_Of_Days
		END

		

END


GO


CREATE TRIGGER [DBO].[Tri_T0210_MONTHLY_AD_DETAIL]
ON [dbo].[T0210_MONTHLY_AD_DETAIL] 
FOR  INSERT ,UPDATE
AS

	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	/*****************************
	******FOR REIMBURSEMENT*******
	*****************************/	

	if object_id('tempdb..#INSERTED') != NULL
		DROP table #INSERTED;	

	SELECT * INTO #INSERTED FROM INSERTED 

	--CREATE CLUSTERED INDEX IDX_INSERTED ON #INSERTED(M_AD_Tran_ID)
	IF EXISTS(select AM.AD_ID from inserted ins inner join T0050_AD_MASTER AM on ins.AD_ID = AM.AD_ID where AM.AD_NOT_EFFECT_SALARY = 1 and AM.Allowance_type='R' )--and ins.S_Sal_Tran_ID is null)	--'' S_Sal_Tran_ID Comment By Ankit 08032016
		EXEC P0210_MONTHLY_AD_DETAIL_TRIGGER_REIM 	
	/*****************************
	******FOR GPF*******
	*****************************/	
	IF EXISTS(	SELECT 1 FROM INSERTED INS INNER JOIN T0050_AD_MASTER AM ON INS.AD_ID = AM.AD_ID AND INS.Cmp_ID=AM.CMP_ID
				WHERE	AM.AD_DEF_ID=14 AND INS.M_AD_Amount <> 0 )			
		EXEC P0210_MONTHLY_AD_DETAIL_TRIGGER_GPF						



GO



CREATE TRIGGER [DBO].[Tri_T0210_MONTHLY_AD_DETAIL_Delete]
ON [dbo].[T0210_MONTHLY_AD_DETAIL] 
FOR  Delete
AS
	IF EXISTS(SELECT 1 FROM DELETED)
	BEGIN
		SELECT * INTO #DELETED FROM DELETED
		EXEC P0210_MONTHLY_AD_DETAIL_TRIGGER_DELETE
	END

