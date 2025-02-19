CREATE TABLE [dbo].[T9999_Audit_Trail] (
    [Audit_Trail_Id]            NUMERIC (18)   NOT NULL,
    [Cmp_ID]                    NUMERIC (18)   NOT NULL,
    [Audit_Change_Type]         NVARCHAR (20)  NOT NULL,
    [Audit_Module_Name]         VARCHAR (500)  NULL,
    [Audit_Modulle_Description] NVARCHAR (MAX) NULL,
    [Audit_Change_For]          NUMERIC (18)   NULL,
    [Audit_Change_By]           NUMERIC (18)   NULL,
    [Audit_Date]                DATETIME       NOT NULL,
    [Audit_Ip]                  NVARCHAR (100) NOT NULL,
    [is_emp_id]                 TINYINT        CONSTRAINT [DF_T9999_Audit_Trail_is_emp_id_1] DEFAULT ((0)) NOT NULL,
    [KeyGUID]                   VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_T9999_Audit_Trail] PRIMARY KEY CLUSTERED ([Audit_Trail_Id] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXNC_T9999_Audit_Trail_0001]
    ON [dbo].[T9999_Audit_Trail]([Audit_Trail_Id] ASC, [Audit_Module_Name] ASC, [Audit_Change_For] ASC, [Audit_Date] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_T9999_Audit_Trail_Cmp_ID_Audit_Change_Type_Audit_Change_For_INCLUDE]
    ON [dbo].[T9999_Audit_Trail]([Cmp_ID] ASC, [Audit_Change_Type] ASC, [Audit_Change_For] ASC)
    INCLUDE([Audit_Module_Name], [KeyGUID]);


GO
CREATE STATISTICS [Audit_Module_Name]
    ON [dbo].[T9999_Audit_Trail]([Audit_Module_Name]);

