CREATE TABLE [dbo].[T0400_Employee_Comment] (
    [Comment_Id]        NUMERIC (18)   NOT NULL,
    [Emp_Id]            NUMERIC (18)   NOT NULL,
    [Cmp_Id]            NUMERIC (18)   NOT NULL,
    [Emp_Id_Comment]    NUMERIC (18)   NOT NULL,
    [For_date]          DATETIME       NOT NULL,
    [U_Comment_Id]      NUMERIC (18)   NOT NULL,
    [Comment_date]      DATETIME       NOT NULL,
    [Comment]           NVARCHAR (MAX) NOT NULL,
    [Comment_Status]    VARCHAR (50)   NOT NULL,
    [Notification_flag] NUMERIC (18)   CONSTRAINT [DF_T0400_Employee_Comment_Notification_flag] DEFAULT ((0)) NOT NULL,
    [Reply_Comment_Id]  NUMERIC (18)   CONSTRAINT [DF_T0400_Employee_Comment_Reply_Comment_Id] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0400_Employee_Comment] PRIMARY KEY CLUSTERED ([Comment_Id] ASC) WITH (FILLFACTOR = 95)
);

