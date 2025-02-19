CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_Goal_SignoffHistory] (
    [Signoff_ID]      NUMERIC (18) NOT NULL,
    [FK_Goal_Id]      NUMERIC (18) NOT NULL,
    [Signoff_Version] NUMERIC (18) NOT NULL,
    [Signoff_Date]    DATETIME     NOT NULL,
    [Emp_ID]          NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_P0090_HRMS_Appraisal_Emp_Goal_SignoffHistory] PRIMARY KEY CLUSTERED ([Signoff_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_Goal_SignoffHistory_T0090_HRMS_Appraisal_Emp_Goal] FOREIGN KEY ([FK_Goal_Id]) REFERENCES [dbo].[T0090_HRMS_Appraisal_Emp_Goal] ([Goal_Id])
);

