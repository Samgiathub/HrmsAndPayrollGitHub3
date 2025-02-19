CREATE TABLE [dbo].[T0011_LOGIN] (
    [Login_ID]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]            NUMERIC (18)   NOT NULL,
    [Login_Name]        VARCHAR (50)   NOT NULL,
    [Login_Password]    VARCHAR (MAX)  NOT NULL,
    [Emp_ID]            NUMERIC (18)   NULL,
    [Branch_ID]         NUMERIC (18)   NULL,
    [Login_Rights_ID]   NUMERIC (18)   NULL,
    [Is_Default]        NUMERIC (1)    CONSTRAINT [DF_T0011_LOGIN_Is_Default] DEFAULT ((0)) NULL,
    [Is_HR]             TINYINT        NULL,
    [Is_Accou]          TINYINT        NULL,
    [Email_ID]          VARCHAR (60)   NULL,
    [Email_ID_Accou]    VARCHAR (60)   NULL,
    [Is_Active]         TINYINT        DEFAULT ((1)) NOT NULL,
    [Emp_Search_Type]   INT            CONSTRAINT [DF_T0011_LOGIN_Emp_Search_Type] DEFAULT ((0)) NOT NULL,
    [Login_Alias]       VARCHAR (50)   CONSTRAINT [DF_T0011_LOGIN_Login_Alias] DEFAULT ('') NOT NULL,
    [Effective_Date]    DATETIME       NULL,
    [Travel_Help_Desk]  TINYINT        NULL,
    [Branch_id_multi]   NVARCHAR (MAX) NULL,
    [Email_ID_HelpDesk] VARCHAR (50)   DEFAULT (NULL) NULL,
    [IS_IT]             NUMERIC (1)    CONSTRAINT [DF_T0011_LOGIN_IS_IT] DEFAULT ((0)) NOT NULL,
    [Email_ID_IT]       VARCHAR (100)  NULL,
    [IS_Medical]        NUMERIC (18)   NULL,
    [Is_Canteen]        NUMERIC (1)    NULL,
    [Email_ID_Canteen]  VARCHAR (100)  NULL,
    CONSTRAINT [PK_T0011_LOGIN] PRIMARY KEY CLUSTERED ([Login_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0011_LOGIN_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0011_LOGIN_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_LOGIN_26_437576597__K17_K3_K16]
    ON [dbo].[T0011_LOGIN]([Effective_Date] ASC, [Login_Name] ASC, [Login_Alias] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_LOGIN_26_437576597__K3_K16_4]
    ON [dbo].[T0011_LOGIN]([Login_Name] ASC, [Login_Alias] ASC)
    INCLUDE([Login_Password]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_LOGIN_26_437576597__K3_K16_4_17]
    ON [dbo].[T0011_LOGIN]([Login_Name] ASC, [Login_Alias] ASC)
    INCLUDE([Login_Password], [Effective_Date]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_LOGIN_26_437576597__K16_K3_1_2_4_5_6_7_15_17]
    ON [dbo].[T0011_LOGIN]([Login_Alias] ASC, [Login_Name] ASC)
    INCLUDE([Login_ID], [Cmp_ID], [Login_Password], [Emp_ID], [Branch_ID], [Login_Rights_ID], [Emp_Search_Type], [Effective_Date]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_LOGIN_26_437576597__K5_1]
    ON [dbo].[T0011_LOGIN]([Emp_ID] ASC)
    INCLUDE([Login_ID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_LOGIN_26_437576597__K14_K2]
    ON [dbo].[T0011_LOGIN]([Is_Active] ASC, [Cmp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_LOGIN_8_437576597__K2_K1_K5]
    ON [dbo].[T0011_LOGIN]([Cmp_ID] ASC, [Login_ID] ASC, [Emp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_437576597_16_17]
    ON [dbo].[T0011_LOGIN]([Login_Alias], [Effective_Date]);


GO
CREATE STATISTICS [_dta_stat_437576597_3_16_1]
    ON [dbo].[T0011_LOGIN]([Login_Name], [Login_Alias], [Login_ID]);


GO
CREATE STATISTICS [_dta_stat_437576597_1_3]
    ON [dbo].[T0011_LOGIN]([Login_ID], [Login_Name]);


GO
CREATE STATISTICS [_dta_stat_437576597_2_1_5]
    ON [dbo].[T0011_LOGIN]([Cmp_ID], [Login_ID], [Emp_ID]);

