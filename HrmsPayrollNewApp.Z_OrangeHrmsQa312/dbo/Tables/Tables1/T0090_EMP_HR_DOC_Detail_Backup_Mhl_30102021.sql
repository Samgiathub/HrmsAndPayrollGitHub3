CREATE TABLE [dbo].[T0090_EMP_HR_DOC_Detail_Backup_Mhl_30102021] (
    [Emp_doc_ID]    NUMERIC (18)   NOT NULL,
    [HR_DOC_ID]     NUMERIC (18)   NULL,
    [accetpeted]    INT            NULL,
    [accepted_date] DATETIME       NULL,
    [cmp_id]        NUMERIC (18)   NULL,
    [Emp_id]        NUMERIC (18)   NULL,
    [Doc_content]   NVARCHAR (MAX) NULL,
    [Login_id]      NUMERIC (18)   NULL,
    [Type]          TINYINT        NULL
);

