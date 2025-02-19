CREATE TABLE [dbo].[T0040_Induction_Checklist] (
    [Checklist_ID]   NUMERIC (18)  NOT NULL,
    [Checklist_Name] VARCHAR (200) NULL,
    [Sort_ID]        NUMERIC (18)  NULL,
    [Cmp_ID]         NUMERIC (18)  NULL,
    [Modify_Date]    DATETIME      NULL,
    [Modify_By]      NUMERIC (18)  NULL,
    [IP_Address]     VARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([Checklist_ID] ASC)
);

