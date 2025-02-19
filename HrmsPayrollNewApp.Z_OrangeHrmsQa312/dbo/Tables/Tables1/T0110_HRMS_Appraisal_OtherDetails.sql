CREATE TABLE [dbo].[T0110_HRMS_Appraisal_OtherDetails] (
    [HAO_Id]         NUMERIC (18)   NOT NULL,
    [Cmp_ID]         NUMERIC (18)   NOT NULL,
    [Emp_ID]         NUMERIC (18)   NOT NULL,
    [InitiateId]     NUMERIC (18)   NOT NULL,
    [AO_Id]          NUMERIC (18)   NULL,
    [Justification]  NVARCHAR (MAX) NULL,
    [TimeFrame_Id]   INT            NULL,
    [Promo_Desig]    NUMERIC (18)   NULL,
    [From_Date]      DATETIME       NULL,
    [To_Date]        DATETIME       NULL,
    [Approval_Level] NVARCHAR (200) NULL,
    [Is_Applicable]  INT            NULL,
    CONSTRAINT [PK_T0110_HRMS_Appraisal_OtherDetails] PRIMARY KEY CLUSTERED ([HAO_Id] ASC) WITH (FILLFACTOR = 80)
);

