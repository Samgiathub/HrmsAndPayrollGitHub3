CREATE TABLE [dbo].[T0095_Uniform_Requisition_Application_Detail] (
    [Uni_Req_App_Detail_Id] NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Uni_Req_App_Id]        NUMERIC (18)    NULL,
    [Cmp_ID]                NUMERIC (18)    NULL,
    [Emp_ID]                NUMERIC (18)    NULL,
    [Uni_Pieces]            INT             NULL,
    [Uni_Fabric_Price]      NUMERIC (18, 2) NULL,
    [Uni_Stitching_Price]   NUMERIC (18, 2) NULL,
    [Uni_Amount]            NUMERIC (18, 2) NULL,
    [Comments]              NVARCHAR (250)  NULL,
    CONSTRAINT [PK_T0095_Uniform_Requisition_Application_Detail] PRIMARY KEY CLUSTERED ([Uni_Req_App_Detail_Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_T0095_Uniform_Requisition_Application_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_Uniform_Requisition_Application_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0095_Uniform_Requisition_Application_Detail_T0090_Uniform_Requisition_Application] FOREIGN KEY ([Uni_Req_App_Id]) REFERENCES [dbo].[T0090_Uniform_Requisition_Application] ([Uni_Req_App_Id])
);

