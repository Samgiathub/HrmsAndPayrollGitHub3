CREATE TABLE [dbo].[T0090_IT_Declaration_Lock_Setting] (
    [Tran_Id]         NUMERIC (18) NOT NULL,
    [Cmp_Id]          NUMERIC (18) NULL,
    [Financial_Year]  VARCHAR (50) NULL,
    [From_Date]       DATETIME     NULL,
    [To_Date]         DATETIME     NULL,
    [Emp_Enable_Days] NUMERIC (18) NULL,
    CONSTRAINT [PK_T0090_IT_Declaration_Lock_Setting] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

