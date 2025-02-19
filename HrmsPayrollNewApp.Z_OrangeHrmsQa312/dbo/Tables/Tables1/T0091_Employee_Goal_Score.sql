CREATE TABLE [dbo].[T0091_Employee_Goal_Score] (
    [Emp_Goal_S_id]  NUMERIC (18)   NOT NULL,
    [appr_detail_id] NUMERIC (18)   NULL,
    [For_date]       DATETIME       NULL,
    [Emp_Goal_ID]    NUMERIC (18)   NULL,
    [Goal_rate]      INT            NULL,
    [comments]       NVARCHAR (500) NULL,
    [Goal_status]    INT            NULL,
    [Emp_status]     INT            NULL,
    CONSTRAINT [PK_T0091_Employee_Goal_Score] PRIMARY KEY CLUSTERED ([Emp_Goal_S_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0091_Employee_Goal_Score_T0090_EMP_GOAL_DETAILS] FOREIGN KEY ([Emp_Goal_ID]) REFERENCES [dbo].[T0090_EMP_GOAL_DETAILS] ([Emp_Goal_ID]),
    CONSTRAINT [FK_T0091_Employee_Goal_Score_T0090_Hrms_Appraisal_Initiation_Detail] FOREIGN KEY ([appr_detail_id]) REFERENCES [dbo].[T0090_Hrms_Appraisal_Initiation_Detail] ([Appr_Detail_Id])
);

