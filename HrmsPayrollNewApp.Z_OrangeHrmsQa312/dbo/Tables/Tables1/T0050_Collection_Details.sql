CREATE TABLE [dbo].[T0050_Collection_Details] (
    [Collection_Detail_ID] NUMERIC (18)    NOT NULL,
    [Collection_ID]        NUMERIC (18)    NULL,
    [Project_ID]           NUMERIC (18)    NULL,
    [Service_Type]         VARCHAR (50)    NULL,
    [Contract_Type]        VARCHAR (50)    NULL,
    [FedoraCharges]        NUMERIC (18, 2) NULL,
    [Practice_Collection]  NUMERIC (18, 2) NULL,
    [TotalCharges]         NUMERIC (18, 2) NULL,
    [Exchange_Rate]        NUMERIC (18, 2) NULL,
    [Total_Fedora_Charges] NUMERIC (18, 2) NULL,
    [Other_Remarks]        VARCHAR (100)   NULL,
    [Invoice]              INT             NULL,
    [Payment]              INT             NULL,
    CONSTRAINT [PK_T0050_Collection_Details] PRIMARY KEY CLUSTERED ([Collection_Detail_ID] ASC) WITH (FILLFACTOR = 80)
);

