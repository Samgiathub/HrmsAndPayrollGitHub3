CREATE TABLE [dbo].[T0200_Exit_Interview] (
    [Interview_id] NUMERIC (18) NOT NULL,
    [emp_id]       NUMERIC (18) NOT NULL,
    [exit_id]      NUMERIC (18) NULL,
    [Question_Id]  NUMERIC (18) NULL,
    [cmp_id]       NUMERIC (18) NOT NULL,
    [login_id]     NUMERIC (18) NULL,
    [Posted_date]  DATETIME     NOT NULL,
    [int_status]   CHAR (1)     NOT NULL,
    [Is_view]      NUMERIC (1)  NULL,
    [Is_Active]    TINYINT      CONSTRAINT [DF_T0200_Exit_Interview_Is_active] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0200_Exit_Interview] PRIMARY KEY CLUSTERED ([Interview_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0200_Exit_Interview_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0200_Exit_Interview_T0080_EMP_MASTER] FOREIGN KEY ([emp_id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0200_Exit_Interview_T0200_Emp_ExitApplication] FOREIGN KEY ([exit_id]) REFERENCES [dbo].[T0200_Emp_ExitApplication] ([exit_id])
);

