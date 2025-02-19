CREATE TABLE [dbo].[T0050_Training_Wise_CheckList] (
    [Tran_ID]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]           NUMERIC (18)   NULL,
    [Training_ID]      NUMERIC (18)   NULL,
    [Effective_Date]   DATETIME       NULL,
    [Assign_CheckList] VARCHAR (1000) NULL,
    [Modify_Date]      DATETIME       NULL,
    [Modify_By]        NUMERIC (18)   NULL,
    [Ip_Address]       VARCHAR (30)   NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

