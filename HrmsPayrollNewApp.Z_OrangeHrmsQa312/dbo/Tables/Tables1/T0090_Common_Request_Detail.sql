CREATE TABLE [dbo].[T0090_Common_Request_Detail] (
    [request_id]      NUMERIC (18)  NOT NULL,
    [cmp_id]          NUMERIC (18)  NULL,
    [emp_Login_id]    NUMERIC (18)  NULL,
    [request_type]    VARCHAR (100) NULL,
    [request_date]    DATETIME      NULL,
    [request_detail]  VARCHAR (500) NULL,
    [status]          INT           NOT NULL,
    [Login_id]        NUMERIC (18)  NULL,
    [Feedback_detail] VARCHAR (500) NULL,
    [User_Id]         INT           NULL,
    [IP_Address]      VARCHAR (50)  NULL,
    CONSTRAINT [PK_T0090_Common_Request_Detail] PRIMARY KEY CLUSTERED ([request_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Common_Request_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_Common_Request_Detail_T0080_EMP_MASTER] FOREIGN KEY ([emp_Login_id]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID])
);

