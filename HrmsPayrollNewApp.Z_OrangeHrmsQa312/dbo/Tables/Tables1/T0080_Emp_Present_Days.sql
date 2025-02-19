CREATE TABLE [dbo].[T0080_Emp_Present_Days] (
    [Id]        INT             IDENTITY (1, 1) NOT NULL,
    [Emp_Id]    NUMERIC (18)    NULL,
    [Present]   NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [WO]        NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [HO]        NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [OD]        NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Absent]    NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Leave]     NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Total]     NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [D_Present] NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [For_Date]  DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

