CREATE TABLE [dbo].[T0120_TRAINING_APPROVAL] (
    [Training_Apr_ID]   NUMERIC (18)    NOT NULL,
    [Training_App_ID]   NUMERIC (18)    NULL,
    [Login_ID]          NUMERIC (18)    NOT NULL,
    [Training_Date]     DATETIME        NOT NULL,
    [Place]             VARCHAR (100)   NOT NULL,
    [Faculty]           VARCHAR (50)    NOT NULL,
    [Company_Name]      VARCHAR (50)    NOT NULL,
    [Description]       VARCHAR (200)   NULL,
    [Training_Cost]     NUMERIC (22, 2) NULL,
    [Apr_Status]        VARCHAR (1)     NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Training_End_Date] DATETIME        NULL,
    CONSTRAINT [PK_T0120_TRAINING_APPROVAL] PRIMARY KEY CLUSTERED ([Training_Apr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_TRAINING_APPROVAL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_TRAINING_APPROVAL_T0100_TRAINING_APPLICATION] FOREIGN KEY ([Training_App_ID]) REFERENCES [dbo].[T0100_TRAINING_APPLICATION] ([Training_App_ID])
);

