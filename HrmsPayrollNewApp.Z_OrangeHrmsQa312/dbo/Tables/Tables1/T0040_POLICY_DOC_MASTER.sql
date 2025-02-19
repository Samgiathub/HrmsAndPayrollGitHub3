CREATE TABLE [dbo].[T0040_POLICY_DOC_MASTER] (
    [Policy_Doc_ID]     NUMERIC (18)   NOT NULL,
    [Cmp_ID]            NUMERIC (18)   NOT NULL,
    [Policy_Title]      NVARCHAR (50)  NOT NULL,
    [Policy_Tooltip]    NVARCHAR (30)  NOT NULL,
    [Policy_Upload_Doc] VARCHAR (200)  NOT NULL,
    [Policy_From_Date]  DATETIME       NOT NULL,
    [Policy_To_Date]    DATETIME       NOT NULL,
    [Policy_Sorting]    NUMERIC (18)   CONSTRAINT [DF_T0040_POLICY_DOC_MASTER_Policy_Sorting] DEFAULT ((0)) NOT NULL,
    [Emp_ID]            NVARCHAR (MAX) NULL,
    [Dept_Id]           NVARCHAR (MAX) NULL,
    [Cmp_ID_Multi]      NVARCHAR (MAX) NULL,
    [Policy_Type]       INT            NULL,
    [DOC_TYPE]          TINYINT        DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_T0040_POLICY_DOC_MASTER] PRIMARY KEY CLUSTERED ([Policy_Doc_ID] ASC) WITH (FILLFACTOR = 80)
);

