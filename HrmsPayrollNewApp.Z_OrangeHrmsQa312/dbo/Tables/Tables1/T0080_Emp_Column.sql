CREATE TABLE [dbo].[T0080_Emp_Column] (
    [Tran_Id]  NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]   NUMERIC (18)    CONSTRAINT [DF_T0080_Emp_Column_Cmp_Id] DEFAULT ((0)) NOT NULL,
    [Emp_id]   NUMERIC (18)    CONSTRAINT [DF_T0080_Emp_Column_Emp_id] DEFAULT ((0)) NOT NULL,
    [Day]      NUMERIC (18)    NULL,
    [Comments] VARCHAR (50)    NULL,
    [Date]     DATETIME        NULL,
    [rate]     NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0080_Emp_Column] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

