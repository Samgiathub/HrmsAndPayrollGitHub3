CREATE TABLE [dbo].[T0040_DEPARTMENT_MASTER] (
    [Dept_Id]           NUMERIC (18)    NOT NULL,
    [Cmp_Id]            NUMERIC (18)    NOT NULL,
    [Dept_Name]         VARCHAR (100)   NOT NULL,
    [Dept_Dis_no]       NUMERIC (18)    NOT NULL,
    [Dept_Code]         VARCHAR (25)    NULL,
    [IsActive]          TINYINT         CONSTRAINT [DF__T0040_DEP__IsAct__4313323F] DEFAULT ((1)) NULL,
    [InActive_EffeDate] DATETIME        CONSTRAINT [DF__T0040_DEP__InEff__44075678] DEFAULT (NULL) NULL,
    [OJT_Applicable]    TINYINT         NULL,
    [Minimum_Wages]     NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Category]          TINYINT         DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0040_DEPARTMENT_MASTER] PRIMARY KEY CLUSTERED ([Dept_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_DEPARTMENT_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

