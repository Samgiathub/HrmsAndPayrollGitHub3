CREATE TABLE [dbo].[T0100_Break_Time] (
    [Break_Id]         NUMERIC (5) NOT NULL,
    [Cmp_Id]           NUMERIC (5) NOT NULL,
    [Emp_Id]           NUMERIC (5) NOT NULL,
    [Dept_Id]          NUMERIC (5) NOT NULL,
    [Branch_Id]        NUMERIC (5) NOT NULL,
    [Effective_date]   DATETIME    NOT NULL,
    [Break_Start_Time] VARCHAR (5) NOT NULL,
    [Break_End_Time]   VARCHAR (5) NOT NULL,
    [Break_Duration]   VARCHAR (5) NOT NULL,
    [Type]             TINYINT     NOT NULL,
    CONSTRAINT [PK_T0100_Break_Time] PRIMARY KEY CLUSTERED ([Break_Id] ASC)
);

