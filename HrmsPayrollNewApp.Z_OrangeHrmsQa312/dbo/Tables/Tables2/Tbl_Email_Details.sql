CREATE TABLE [dbo].[Tbl_Email_Details] (
    [EmailId]           NUMERIC (18)  NOT NULL,
    [Cmp_Id]            NUMERIC (18)  NOT NULL,
    [Email_From_UserId] NUMERIC (18)  NULL,
    [Email_To_UserId]   NUMERIC (18)  NOT NULL,
    [Email_Subject]     VARCHAR (100) NOT NULL,
    [Email_Messages]    TEXT          NOT NULL,
    [Email_Datetime]    DATETIME      NOT NULL,
    [Email_Type]        VARCHAR (50)  NOT NULL,
    [Email_From_Status] NUMERIC (18)  NOT NULL,
    [Email_To_Status]   NUMERIC (18)  NOT NULL,
    [Email_Read_Status] NUMERIC (18)  NULL,
    [Email_Css]         VARCHAR (50)  NULL,
    CONSTRAINT [PK_Tbl_Email_Details] PRIMARY KEY CLUSTERED ([EmailId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Tbl_Email_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

