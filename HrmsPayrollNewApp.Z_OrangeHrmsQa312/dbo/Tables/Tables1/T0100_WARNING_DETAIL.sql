CREATE TABLE [dbo].[T0100_WARNING_DETAIL] (
    [War_Tran_ID]       NUMERIC (18)  NOT NULL,
    [Cmp_ID]            NUMERIC (18)  NOT NULL,
    [Emp_Id]            NUMERIC (18)  NOT NULL,
    [War_ID]            NUMERIC (18)  NOT NULL,
    [Warr_Date]         DATETIME      NOT NULL,
    [Shift_ID]          NUMERIC (18)  NOT NULL,
    [Warr_Reason]       VARCHAR (500) NOT NULL,
    [Issue_By]          VARCHAR (50)  NOT NULL,
    [Authorised_By]     VARCHAR (50)  NOT NULL,
    [Login_Id]          NUMERIC (18)  NOT NULL,
    [System_Date]       DATETIME      NOT NULL,
    [Level_Id]          NUMERIC (18)  CONSTRAINT [DF_T0100_WARNING_DETAIL_Level_Id] DEFAULT ((0)) NOT NULL,
    [No_Of_Card]        NUMERIC (18)  CONSTRAINT [DF_T0100_WARNING_DETAIL_No_Of_Card] DEFAULT ((0)) NOT NULL,
    [Card_Color]        VARCHAR (50)  NULL,
    [Action_Taken_Date] DATETIME      NULL,
    [Action_Detail]     VARCHAR (500) NULL,
    CONSTRAINT [PK_T0100_WARNING_DETAIL] PRIMARY KEY CLUSTERED ([War_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Table1_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_Table1_T0040_WARNING_MASTER] FOREIGN KEY ([War_ID]) REFERENCES [dbo].[T0040_WARNING_MASTER] ([War_ID]),
    CONSTRAINT [FK_Table1_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

