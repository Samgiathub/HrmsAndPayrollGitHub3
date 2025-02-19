CREATE TABLE [dbo].[T0011_Password_Settings] (
    [Password_ID]       NUMERIC (18)  NOT NULL,
    [Cmp_ID]            NUMERIC (18)  NOT NULL,
    [Enable_Validation] TINYINT       CONSTRAINT [DF_T0011_Password_Settings_Enable_Validation] DEFAULT ((0)) NOT NULL,
    [Min_Chars]         NUMERIC (18)  NULL,
    [Upper_Char]        TINYINT       NULL,
    [Lower_Char]        TINYINT       NULL,
    [Is_Digit]          TINYINT       NULL,
    [Special_Char]      TINYINT       NULL,
    [Password_Format]   VARCHAR (200) NULL,
    [Pass_Exp_Days]     NUMERIC (18)  DEFAULT ((0)) NULL,
    [Reminder_Days]     NUMERIC (18)  DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0011_Password_Settings] PRIMARY KEY CLUSTERED ([Password_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0011_Password_Settings_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

