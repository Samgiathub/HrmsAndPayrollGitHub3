CREATE TABLE [dbo].[T0055_HRMS_Skill_Rate_Detail] (
    [skill_Detail_Id]   NUMERIC (18)    NOT NULL,
    [Skill_ID]          NUMERIC (18)    NULL,
    [Skill_d_id]        NUMERIC (18)    NULL,
    [Skill_Actual_Rate] NUMERIC (18, 2) NULL,
    [Skill_R_Rate_Min]  NUMERIC (18, 2) NULL,
    [Skill_R_Rate_Max]  NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0055_HRMS_Skill_Rate_Detail] PRIMARY KEY CLUSTERED ([skill_Detail_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_HRMS_Skill_Rate_Detail_T0040_SKILL_MASTER] FOREIGN KEY ([Skill_ID]) REFERENCES [dbo].[T0040_SKILL_MASTER] ([Skill_ID]),
    CONSTRAINT [FK_T0055_HRMS_Skill_Rate_Detail_T0050_HRMS_Skill_Rate_Setting] FOREIGN KEY ([Skill_d_id]) REFERENCES [dbo].[T0050_HRMS_Skill_Rate_Setting] ([Skill_d_id])
);

