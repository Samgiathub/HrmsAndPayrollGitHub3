CREATE TABLE [dbo].[T0110_EMP_EARN_DEDUCTION_REVISED] (
    [TRAN_ID]            NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [CMP_ID]             NUMERIC (18)    NOT NULL,
    [EMP_ID]             NUMERIC (18)    NOT NULL,
    [AD_ID]              NUMERIC (18)    NOT NULL,
    [FOR_DATE]           DATETIME        NOT NULL,
    [E_AD_FLAG]          CHAR (1)        NOT NULL,
    [E_AD_MODE]          VARCHAR (10)    NOT NULL,
    [E_AD_PERCENTAGE]    NUMERIC (18, 5) NULL,
    [E_AD_AMOUNT]        NUMERIC (18, 4) NOT NULL,
    [E_AD_MAX_LIMIT]     NUMERIC (18)    NOT NULL,
    [E_AD_YEARLY_AMOUNT] NUMERIC (18, 2) NOT NULL,
    [ENTRY_TYPE]         VARCHAR (10)    NOT NULL,
    [Increment_ID]       NUMERIC (18)    NULL,
    [System_Date]        DATETIME        NULL,
    [User_ID]            NUMERIC (18)    NULL,
    [Is_Calculate_Zero]  TINYINT         CONSTRAINT [DF_T0110_EMP_EARN_DEDUCTION_Revised_Is_Calculate_Zero] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0110_EMP_EARN_DEDUCTION_REVISED] PRIMARY KEY CLUSTERED ([TRAN_ID] ASC),
    CONSTRAINT [FK_T0110_EMP_EARN_DEDUCTION_REVISED_T0010_COMPANY_MASTER] FOREIGN KEY ([CMP_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_EMP_EARN_DEDUCTION_REVISED_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0110_EMP_EARN_DEDUCTION_REVISED_T0080_EMP_MASTER] FOREIGN KEY ([EMP_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO


-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 25-Jiun-2018
-- Description:	To calculate the Gross, Special & ESIC (Cercular Reference)
-- =============================================
CREATE TRIGGER [DBO].[Trg_T0110_EMP_EARN_DEDUCTION_REVISED_ESIC]
   ON  [dbo].[T0110_EMP_EARN_DEDUCTION_REVISED]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @AD_ID			Numeric
    DECLARE @Increment_ID	Numeric
    DECLARE @For_Date		DateTime
    DECLARE @Emp_ID			Numeric
    DECLARE @Cmp_ID			Numeric
    IF EXISTS(SELECT 1 FROM DELETED)
		BEGIN
			SELECT	@AD_ID = AD_ID,@For_Date = For_Date, @Emp_ID=Emp_ID, @Cmp_ID=Cmp_ID FROM INSERTED
		END
	ELSE
		BEGIN
			SELECT	@AD_ID = AD_ID,@For_Date = For_Date, @Emp_ID=Emp_ID, @Cmp_ID=Cmp_ID FROM INSERTED
		END
		
	--SELECT	@Increment_ID = Increment_ID
	--FROM	T0095_Increment 
	--Where	Emp_ID=@Emp_ID AND Increment_Effective_Date <= @For_Date
	--Order	By Increment_Effective_Date Desc, Increment_ID Desc
		
	DECLARE @Is_CircularRef BIT
	SET @Is_CircularRef = 0
	IF EXISTS(SELECT 1 FROM T0050_AD_MASTER WHERE AD_ID=@AD_ID AND AD_DEF_ID IN (6 ,3)) -- IS ESIC
		AND EXISTS(SELECT 1 FROM dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Emp_ID,@For_Date) EED 
						INNER JOIN T0050_AD_MASTER AD ON EED.AD_ID=AD.AD_ID
					WHERE AD_CALCULATE_ON='Arrears CTC') -- HAS Special Allowance Which Calculates On Arrear CTC
		SET @Is_CircularRef = 1
	ELSE IF EXISTS(SELECT 1 FROM T0050_AD_MASTER WHERE AD_ID=@AD_ID AND AD_CALCULATE_ON='Arrears CTC') -- Is Special Allowance Which Calculates On Arrear CTC
		AND EXISTS(SELECT 1 FROM dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Emp_ID,@For_Date) EED 
						INNER JOIN T0050_AD_MASTER AD ON EED.AD_ID=AD.AD_ID
					WHERE AD_DEF_ID IN (6 ,3)) -- HAS ESIC
		SET @Is_CircularRef = 1
		
	IF @Is_CircularRef = 1
		BEGIN
			EXEC P_UPDATE_CTC @Cmp_ID=@Cmp_ID, @Emp_ID=@Emp_ID, @For_Date=@For_Date
		END

END


