CREATE TABLE [dbo].[T0095_Authorized_Signature] (
    [Tran_ID]        NUMERIC (18) NOT NULL,
    [Cmp_ID]         NUMERIC (18) NOT NULL,
    [Emp_ID]         NUMERIC (18) NOT NULL,
    [Branch_ID]      NUMERIC (18) NOT NULL,
    [Effective_Date] DATETIME     NOT NULL,
    [System_Date]    DATETIME     NOT NULL,
    CONSTRAINT [PK_T0095_Authorized_Signature] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

