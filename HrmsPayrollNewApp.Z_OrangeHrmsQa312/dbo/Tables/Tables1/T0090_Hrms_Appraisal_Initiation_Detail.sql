CREATE TABLE [dbo].[T0090_Hrms_Appraisal_Initiation_Detail] (
    [Appr_Detail_Id]   NUMERIC (18) NOT NULL,
    [Appr_Int_Id]      NUMERIC (18) NOT NULL,
    [Emp_Id]           NUMERIC (18) NOT NULL,
    [Is_Emp_Submit]    INT          NULL,
    [Is_Sup_submit]    INT          NULL,
    [Is_team_submit]   INT          NULL,
    [Is_Accept]        INT          NOT NULL,
    [Emp_Submit_Date]  DATETIME     NULL,
    [Sup_Submit_Date]  DATETIME     NULL,
    [team_submit_date] DATETIME     NULL,
    [start_date]       DATETIME     NULL,
    [End_date]         DATETIME     NULL,
    [Increment_ID]     NUMERIC (18) NULL,
    CONSTRAINT [PK_T0090_Hrms_Appraisal_Initiation_Detail] PRIMARY KEY CLUSTERED ([Appr_Detail_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Hrms_Appraisal_Initiation_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0090_Hrms_Appraisal_Initiation_Detail_T0090_Hrms_Appraisal_Initiation] FOREIGN KEY ([Appr_Int_Id]) REFERENCES [dbo].[T0090_Hrms_Appraisal_Initiation] ([Appr_Int_Id])
);

