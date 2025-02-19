CREATE TABLE [dbo].[T0130_EMP_WORKPLAN] (
    [Work_Tran_ID]  NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]        NUMERIC (18)  NOT NULL,
    [Emp_ID]        NUMERIC (18)  NOT NULL,
    [For_Date]      DATETIME      NOT NULL,
    [Work_InTime]   DATETIME      NOT NULL,
    [Work_OutTime]  DATETIME      NOT NULL,
    [Work_Plan]     VARCHAR (250) NULL,
    [Visit_Plan]    VARCHAR (250) NULL,
    [Work_Summary]  VARCHAR (250) NULL,
    [Visit_Summary] VARCHAR (250) NULL,
    PRIMARY KEY CLUSTERED ([Work_Tran_ID] ASC) WITH (FILLFACTOR = 95)
);

