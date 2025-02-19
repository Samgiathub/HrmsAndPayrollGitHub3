CREATE TABLE [dbo].[T0090_Uniform_Requisition_Application] (
    [Uni_Req_App_Id]      NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Uni_Id]              NUMERIC (18)  NOT NULL,
    [Cmp_ID]              NUMERIC (18)  NOT NULL,
    [Uni_Req_App_Code]    NUMERIC (18)  NULL,
    [Request_Date]        DATETIME      NULL,
    [Requested_By_Emp_ID] NUMERIC (18)  NULL,
    [System_Date]         DATETIME      NULL,
    [Ip_Address]          VARCHAR (100) NULL,
    CONSTRAINT [PK_T0090_Uniform_Requisition_Application] PRIMARY KEY CLUSTERED ([Uni_Req_App_Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_T0090_Uniform_Requisition_Application_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_Uniform_Requisition_Application_T0040_Uniform_Master] FOREIGN KEY ([Uni_Id]) REFERENCES [dbo].[T0040_Uniform_Master] ([Uni_ID]),
    CONSTRAINT [FK_T0090_Uniform_Requisition_Application_T0080_EMP_MASTER] FOREIGN KEY ([Requested_By_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

