CREATE TABLE [dbo].[T0082_Emp_Column] (
    [Tran_Id]     NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [mst_Tran_Id] NUMERIC (18)  NOT NULL,
    [cmp_Id]      NUMERIC (18)  CONSTRAINT [DF_T0082_Emp_Column_cmp_Id] DEFAULT ((0)) NOT NULL,
    [Emp_Id]      NUMERIC (18)  NOT NULL,
    [Value]       VARCHAR (MAX) NULL,
    [sys_Date]    DATETIME      CONSTRAINT [DF_T0082_Emp_Column_sys_Date] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_T0082_Emp_Column] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0082_Emp_Column_T0081_CUSTOMIZED_COLUMN] FOREIGN KEY ([mst_Tran_Id]) REFERENCES [dbo].[T0081_CUSTOMIZED_COLUMN] ([Tran_Id])
);

