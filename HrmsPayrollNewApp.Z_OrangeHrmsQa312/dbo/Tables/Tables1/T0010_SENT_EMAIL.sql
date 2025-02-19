CREATE TABLE [dbo].[T0010_SENT_EMAIL] (
    [Email_Detail_ID] NUMERIC (18)   NOT NULL,
    [From_Email]      VARCHAR (50)   NOT NULL,
    [To_Email]        VARCHAR (50)   NOT NULL,
    [Cmp_ID]          NUMERIC (18)   NOT NULL,
    [From_Emp_ID]     NUMERIC (18)   NOT NULL,
    [Subject]         VARCHAR (50)   NOT NULL,
    [Message]         VARCHAR (5000) NOT NULL,
    [Email_Date]      DATETIME       NOT NULL,
    [Email_CC]        VARCHAR (50)   NOT NULL,
    [Email_BCC]       VARCHAR (50)   NOT NULL,
    [Email_Status]    VARCHAR (50)   NOT NULL,
    [Ip_Address]      VARCHAR (50)   NULL,
    [Attachment]      VARCHAR (50)   NULL,
    CONSTRAINT [PK_T0010_SENT_EMAIL] PRIMARY KEY CLUSTERED ([Email_Detail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0010_SENT_EMAIL_T0010_SENT_EMAIL] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

