CREATE TABLE [dbo].[T0040_NEWS_LETTER_MASTER] (
    [News_Letter_ID]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]                  NUMERIC (18)   NOT NULL,
    [News_Title]              VARCHAR (50)   NOT NULL,
    [News_Description]        VARCHAR (250)  NULL,
    [Start_Date]              DATETIME       NOT NULL,
    [End_Date]                DATETIME       NOT NULL,
    [Is_Visible]              TINYINT        NULL,
    [Flag_T]                  TINYINT        NULL,
    [Flag_P]                  TINYINT        DEFAULT ((0)) NULL,
    [Login_Notification]      TINYINT        CONSTRAINT [DF_T0040_NEWS_LETTER_MASTER_Login_Notification] DEFAULT ((0)) NOT NULL,
    [Is_Member_Flag]          TINYINT        DEFAULT ((0)) NOT NULL,
    [News_Announ_EmpID]       NUMERIC (18)   NULL,
    [News_Announ_For]         VARCHAR (MAX)  NULL,
    [Branch_Wise_News_Announ] VARCHAR (2000) NULL,
    [System_Date]             DATETIME       DEFAULT (getdate()) NOT NULL,
    [flag]                    VARCHAR (10)   DEFAULT ('web') NOT NULL,
    CONSTRAINT [PK_T0040_NEWS_LETTER_MASTER] PRIMARY KEY CLUSTERED ([News_Letter_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_NEWS_LETTER_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

