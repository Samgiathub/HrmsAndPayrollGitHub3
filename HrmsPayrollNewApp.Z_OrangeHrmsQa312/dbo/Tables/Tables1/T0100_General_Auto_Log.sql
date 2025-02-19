CREATE TABLE [dbo].[T0100_General_Auto_Log] (
    [RowId]          NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Emp_Id]         NUMERIC (18)  NOT NULL,
    [ModuleName]     VARCHAR (150) NOT NULL,
    [Is_Success]     TINYINT       NULL,
    [Comment]        VARCHAR (400) NULL,
    [SystemDateTime] DATETIME      NULL,
    CONSTRAINT [PK_T0100_General_Auto_Log] PRIMARY KEY CLUSTERED ([RowId] ASC) WITH (FILLFACTOR = 80)
);

