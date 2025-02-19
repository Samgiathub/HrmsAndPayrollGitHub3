CREATE TABLE [dbo].[T0100_REJOIN_EMP] (
    [Tran_Id]     NUMERIC (18)  NOT NULL,
    [Emp_Id]      NUMERIC (18)  NOT NULL,
    [Cmp_Id]      NUMERIC (18)  NOT NULL,
    [Left_Date]   DATETIME      NOT NULL,
    [Rejoin_Date] DATETIME      NOT NULL,
    [Remarks]     VARCHAR (200) NOT NULL,
    [System_Date] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([Tran_Id] ASC)
);

