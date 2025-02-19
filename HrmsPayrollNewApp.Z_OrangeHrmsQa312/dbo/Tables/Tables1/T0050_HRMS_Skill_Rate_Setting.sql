CREATE TABLE [dbo].[T0050_HRMS_Skill_Rate_Setting] (
    [Skill_d_id]            NUMERIC (18)    NOT NULL,
    [cmp_id]                NUMERIC (18)    NULL,
    [Dept_Id]               NUMERIC (18)    NULL,
    [Branch_Id]             NUMERIC (18)    NULL,
    [Grd_id]                NUMERIC (18)    NULL,
    [desig_id]              NUMERIC (18)    NULL,
    [avg_Skill_Actual_Rate] NUMERIC (18, 2) NULL,
    [avg_Skill_R_Rate_Min]  NUMERIC (18, 2) NULL,
    [avg_Skill_R_Rate_Max]  NUMERIC (18, 2) NULL,
    [skill_Eval_duration]   NUMERIC (18)    NULL,
    [fore_date]             DATETIME        NULL,
    CONSTRAINT [PK_T0050_HRMS_Skill_Rate_Setting] PRIMARY KEY CLUSTERED ([Skill_d_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_HRMS_Skill_Rate_Setting_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_HRMS_Skill_Rate_Setting_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_Id]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID]),
    CONSTRAINT [FK_T0050_HRMS_Skill_Rate_Setting_T0040_DEPARTMENT_MASTER] FOREIGN KEY ([Dept_Id]) REFERENCES [dbo].[T0040_DEPARTMENT_MASTER] ([Dept_Id]),
    CONSTRAINT [FK_T0050_HRMS_Skill_Rate_Setting_T0040_DESIGNATION_MASTER] FOREIGN KEY ([desig_id]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID]),
    CONSTRAINT [FK_T0050_HRMS_Skill_Rate_Setting_T0040_GRADE_MASTER] FOREIGN KEY ([Grd_id]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID])
);

