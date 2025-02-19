CREATE TABLE [dbo].[T0100_TRAVEL_APPLICATION] (
    [Travel_Application_ID] NUMERIC (18)   NOT NULL,
    [Cmp_ID]                NUMERIC (18)   NOT NULL,
    [Emp_ID]                NUMERIC (18)   NOT NULL,
    [S_Emp_ID]              NUMERIC (18)   NULL,
    [Application_Date]      DATETIME       NOT NULL,
    [Application_Code]      VARCHAR (20)   NOT NULL,
    [Application_Status]    CHAR (1)       NOT NULL,
    [Login_ID]              NUMERIC (18)   NOT NULL,
    [Create_Date]           DATETIME       NOT NULL,
    [Modify_Date]           DATETIME       NULL,
    [chk_Adv]               TINYINT        CONSTRAINT [DF_T0100_TRAVEL_APPLICATION_chk_Adv] DEFAULT ((0)) NOT NULL,
    [chk_Agenda]            TINYINT        CONSTRAINT [DF_T0100_TRAVEL_APPLICATION_chk_Agenda] DEFAULT ((0)) NOT NULL,
    [Tour_Agenda]           NVARCHAR (MAX) NULL,
    [IMP_Business_Appoint]  NVARCHAR (MAX) NULL,
    [KRA_Tour]              NVARCHAR (MAX) NULL,
    [Attached_Doc_File]     NVARCHAR (MAX) NULL,
    [Chk_International]     TINYINT        DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0100_TRAVEL_APPLICATION] PRIMARY KEY CLUSTERED ([Travel_Application_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_TRAVEL_APPLICATION_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_TRAVEL_APPLICATION_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0100_TRAVEL_APPLICATION_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

