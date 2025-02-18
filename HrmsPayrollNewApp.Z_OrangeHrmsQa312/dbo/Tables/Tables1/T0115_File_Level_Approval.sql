﻿CREATE TABLE [dbo].[T0115_File_Level_Approval] (
    [Tran_Id]            NUMERIC (18)   NOT NULL,
    [Approve_Date]       DATETIME       NOT NULL,
    [File_Apr_Id]        NUMERIC (18)   NOT NULL,
    [Cmp_Id]             NUMERIC (18)   NOT NULL,
    [File_App_Id]        NUMERIC (18)   NULL,
    [Emp_Id]             NUMERIC (18)   NOT NULL,
    [File_Number]        VARCHAR (50)   NOT NULL,
    [F_StatusId]         INT            NULL,
    [F_TypeId]           NUMERIC (18)   NULL,
    [Subject]            VARCHAR (500)  NULL,
    [Description]        VARCHAR (MAX)  NULL,
    [Process_Date]       DATETIME       NULL,
    [File_App_Doc]       VARCHAR (MAX)  NULL,
    [Forward_Emp_Id]     NUMERIC (18)   NULL,
    [Submit_Emp_Id]      NUMERIC (18)   NULL,
    [Approval_Comments]  VARCHAR (500)  NULL,
    [S_Emp_Id]           NUMERIC (18)   NULL,
    [Rpt_Level]          TINYINT        NOT NULL,
    [System_Date]        DATETIME       NOT NULL,
    [User ID]            VARCHAR (MAX)  NULL,
    [Review_Emp_Id]      NUMERIC (18)   NULL,
    [Reviewed_by_Emp_Id] NUMERIC (18)   NULL,
    [UpdatedUser ID]     VARCHAR (MAX)  NULL,
    [File_Type_Number]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0115_File_Level_Approval] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0115_File_Level_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0115_File_Level_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0115_File_Level_Approval_T0080_File_Application] FOREIGN KEY ([File_App_Id]) REFERENCES [dbo].[T0080_File_Application] ([File_App_Id])
);

