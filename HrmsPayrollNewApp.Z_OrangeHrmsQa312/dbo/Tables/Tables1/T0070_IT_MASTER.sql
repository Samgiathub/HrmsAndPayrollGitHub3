CREATE TABLE [dbo].[T0070_IT_MASTER] (
    [IT_ID]              NUMERIC (18)    NOT NULL,
    [Cmp_ID]             NUMERIC (18)    NOT NULL,
    [IT_Name]            VARCHAR (350)   NULL,
    [IT_Alias]           VARCHAR (20)    NOT NULL,
    [IT_Max_Limit]       NUMERIC (18)    NOT NULL,
    [IT_Flag]            CHAR (1)        NOT NULL,
    [IT_Level]           INT             NOT NULL,
    [IT_Def_ID]          INT             NOT NULL,
    [IT_Is_Active]       TINYINT         NOT NULL,
    [IT_Parent_ID]       NUMERIC (18)    NULL,
    [AD_ID]              NUMERIC (18)    NULL,
    [RIMB_ID]            NUMERIC (18)    NULL,
    [Login_ID]           NUMERIC (18)    NULL,
    [System_Date]        DATETIME        NULL,
    [IT_Main_Group]      TINYINT         NOT NULL,
    [IT_Declaration_Req] TINYINT         NOT NULL,
    [IT_Doc_Name]        VARCHAR (1000)  NULL,
    [IT_Is_Header]       TINYINT         NULL,
    [IT_Is_Atth_Comp]    TINYINT         NULL,
    [IT_Is_Details]      TINYINT         NULL,
    [IT_Is_perquisite]   TINYINT         CONSTRAINT [DF_T0070_IT_MASTER_IT_Is_perquisite] DEFAULT ((0)) NOT NULL,
    [AD_String]          NVARCHAR (MAX)  NULL,
    [Exempt_Percent]     NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0070_IT_MASTER] PRIMARY KEY CLUSTERED ([IT_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0070_IT_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0070_IT_MASTER_T0011_LOGIN] FOREIGN KEY ([Login_ID]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID]),
    CONSTRAINT [FK_T0070_IT_MASTER_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0070_IT_MASTER_T0055_REIMBURSEMENT] FOREIGN KEY ([RIMB_ID]) REFERENCES [dbo].[T0055_REIMBURSEMENT] ([RIMB_ID]),
    CONSTRAINT [FK_T0070_IT_MASTER_T0070_IT_MASTER] FOREIGN KEY ([IT_Parent_ID]) REFERENCES [dbo].[T0070_IT_MASTER] ([IT_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0070_IT_MASTER_MISSING_40718]
    ON [dbo].[T0070_IT_MASTER]([Cmp_ID] ASC, [IT_Name] ASC);

