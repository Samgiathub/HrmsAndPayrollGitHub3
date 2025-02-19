CREATE TABLE [dbo].[T0090_EMP_INSURANCE_DETAIL_Clone] (
    [Emp_Ins_Tran_ID]    NUMERIC (18)    NOT NULL,
    [Cmp_ID]             NUMERIC (18)    NOT NULL,
    [Emp_Id]             NUMERIC (18)    NOT NULL,
    [Ins_Tran_ID]        NUMERIC (18)    NOT NULL,
    [Ins_Cmp_name]       VARCHAR (50)    NOT NULL,
    [Ins_Policy_No]      VARCHAR (50)    NOT NULL,
    [Ins_Taken_Date]     DATETIME        NULL,
    [Ins_Due_Date]       DATETIME        NULL,
    [Ins_Exp_Date]       DATETIME        NULL,
    [Ins_Amount]         NUMERIC (18, 2) NOT NULL,
    [Ins_Anual_Amt]      NUMERIC (18, 2) NOT NULL,
    [System_Date]        DATETIME        NOT NULL,
    [Login_ID]           NUMERIC (18)    NOT NULL,
    [Monthly_Premium]    NUMERIC (18, 2) CONSTRAINT [DF_T0090_EMP_INSURANCE_DETAIL_Clone_Monthly_Premium] DEFAULT ((0)) NOT NULL,
    [Deduct_From_Salary] NCHAR (10)      CONSTRAINT [DF_T0090_EMP_INSURANCE_DETAIL_Clone_Deduct_From_Salary] DEFAULT ((0)) NOT NULL,
    [Sal_Effective_Date] DATETIME        NULL
);

