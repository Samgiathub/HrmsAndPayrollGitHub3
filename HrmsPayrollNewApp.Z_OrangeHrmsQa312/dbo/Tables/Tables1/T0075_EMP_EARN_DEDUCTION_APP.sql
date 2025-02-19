CREATE TABLE [dbo].[T0075_EMP_EARN_DEDUCTION_APP] (
    [Emp_Tran_ID]         BIGINT          NOT NULL,
    [Emp_Application_ID]  INT             NOT NULL,
    [AD_TRAN_ID]          INT             NOT NULL,
    [CMP_ID]              INT             NOT NULL,
    [AD_ID]               INT             NOT NULL,
    [INCREMENT_ID]        INT             NOT NULL,
    [E_AD_FLAG]           CHAR (1)        NOT NULL,
    [E_AD_MODE]           VARCHAR (10)    NOT NULL,
    [E_AD_PERCENTAGE]     NUMERIC (18, 5) NOT NULL,
    [E_AD_AMOUNT]         NUMERIC (18, 4) NOT NULL,
    [E_AD_MAX_LIMIT]      NUMERIC (18)    NOT NULL,
    [E_AD_YEARLY_AMOUNT]  NUMERIC (18, 2) NOT NULL,
    [It_Estimated_Amount] NUMERIC (18, 2) CONSTRAINT [DF_T0075_EMP_EARN_DEDUCTION_APP_It_Estimated_Amount] DEFAULT ((0)) NOT NULL,
    [Is_Calculate_Zero]   TINYINT         NOT NULL,
    [Approved_Emp_ID]     INT             NULL,
    [Approved_Date]       DATETIME        NULL,
    [Rpt_Level]           INT             NULL,
    CONSTRAINT [FK_T0075_EMP_EARN_DEDUCTION_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

