CREATE TABLE [dbo].[T0040_HOLIDAY_MASTER] (
    [Hday_ID]             NUMERIC (18)    NOT NULL,
    [cmp_Id]              NUMERIC (18)    NOT NULL,
    [Hday_Name]           VARCHAR (100)   NOT NULL,
    [H_From_Date]         DATETIME        NOT NULL,
    [H_To_Date]           DATETIME        NOT NULL,
    [Is_Fix]              CHAR (1)        NOT NULL,
    [Hday_Ot_setting]     NUMERIC (18, 1) NOT NULL,
    [Branch_ID]           NUMERIC (18)    NULL,
    [Is_Half]             TINYINT         CONSTRAINT [DF_T0040_HOLIDAY_MASTER_H_Paid_Day] DEFAULT ((0)) NULL,
    [Is_P_Comp]           TINYINT         CONSTRAINT [DF_T0040_HOLIDAY_MASTER_Is_P_Comp] DEFAULT ((0)) NULL,
    [Message_Text]        VARCHAR (100)   NULL,
    [Sms]                 INT             NULL,
    [No_Of_Holiday]       AS              (datediff(day,[h_from_date],[h_to_date])+(1)),
    [System_Date]         DATETIME        CONSTRAINT [DF_T0040_HOLIDAY_MASTER_System_Date] DEFAULT (getdate()) NULL,
    [is_National_Holiday] TINYINT         CONSTRAINT [DF__T0040_HOL__is_Na__38852773] DEFAULT ((0)) NOT NULL,
    [Is_Optional]         TINYINT         NULL,
    [Multiple_Holiday]    TINYINT         CONSTRAINT [DF_T0040_HOLIDAY_MASTER_Multiple_Holiday] DEFAULT ((0)) NOT NULL,
    [Is_Unpaid_Holiday]   TINYINT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_HOLIDAY_MASTER] PRIMARY KEY CLUSTERED ([Hday_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_HOLIDAY_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_HOLIDAY_MASTER_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID])
);

