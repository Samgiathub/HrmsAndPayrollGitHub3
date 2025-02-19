CREATE TABLE [dbo].[T0090_HRMS_Asset_Allocation] (
    [Asset_Approval_Id]  NUMERIC (18)    NOT NULL,
    [Resume_Id]          NUMERIC (18)    NOT NULL,
    [Cmp_Id]             NUMERIC (18)    NOT NULL,
    [Asset_Id]           NUMERIC (18)    NOT NULL,
    [Brand_Id]           NUMERIC (18)    NOT NULL,
    [Model_Name]         VARCHAR (250)   NOT NULL,
    [Allocation_Date]    DATETIME        NOT NULL,
    [Purchase_Date]      DATETIME        NOT NULL,
    [AssetM_Id]          NUMERIC (18)    NOT NULL,
    [Asset_Code]         VARCHAR (250)   NOT NULL,
    [Installment_Date]   DATETIME        NULL,
    [Installment_Amount] NUMERIC (18, 2) NULL,
    [Issue_Amount]       NUMERIC (18, 2) NULL,
    [Deduction_Type]     VARCHAR (15)    NULL,
    [Serial_No]          VARCHAR (50)    NULL,
    CONSTRAINT [PK_T0090_HRMS_Asset_Allocation] PRIMARY KEY CLUSTERED ([Asset_Approval_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Asset_Allocation_T0040_Asset_Details] FOREIGN KEY ([AssetM_Id]) REFERENCES [dbo].[T0040_Asset_Details] ([AssetM_ID]),
    CONSTRAINT [FK_T0090_HRMS_Asset_Allocation_T0055_Resume_Master] FOREIGN KEY ([Resume_Id]) REFERENCES [dbo].[T0055_Resume_Master] ([Resume_Id])
);

