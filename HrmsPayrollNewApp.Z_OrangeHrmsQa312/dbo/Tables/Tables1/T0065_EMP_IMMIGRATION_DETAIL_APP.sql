CREATE TABLE [dbo].[T0065_EMP_IMMIGRATION_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT         NOT NULL,
    [Emp_Application_ID] INT            NOT NULL,
    [Row_ID]             INT            NOT NULL,
    [Cmp_ID]             INT            NOT NULL,
    [Loc_ID]             INT            NULL,
    [Imm_Type]           VARCHAR (20)   NOT NULL,
    [Imm_No]             VARCHAR (20)   NOT NULL,
    [Imm_Issue_Date]     DATETIME       NULL,
    [Imm_Issue_Status]   VARCHAR (20)   NOT NULL,
    [Imm_Date_of_Expiry] DATETIME       NULL,
    [Imm_Review_Date]    DATETIME       NULL,
    [Imm_Comments]       VARCHAR (250)  NOT NULL,
    [attach_doc]         NVARCHAR (MAX) NULL,
    [Approved_Emp_ID]    INT            NULL,
    [Approved_Date]      DATETIME       NULL,
    [Rpt_Level]          INT            NULL,
    CONSTRAINT [FK_T0065_EMP_IMMIGRATION_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

