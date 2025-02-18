﻿CREATE TABLE [dbo].[T0100_EMP_PROBATION_SKILL_DETAIL] (
    [Prob_Skill_ID] NUMERIC (18)   NOT NULL,
    [Cmp_ID]        NUMERIC (18)   NOT NULL,
    [Emp_ID]        NUMERIC (18)   NOT NULL,
    [Skill_Rating]  NUMERIC (18)   NULL,
    [Skill_ID]      NUMERIC (18)   NOT NULL,
    [Emp_Prob_ID]   NUMERIC (18)   NOT NULL,
    [Final_Review]  NUMERIC (18)   NULL,
    [Review_Type]   VARCHAR (15)   NULL,
    [Strengths]     VARCHAR (5000) DEFAULT ('') NOT NULL,
    [Other_Factors] VARCHAR (5000) DEFAULT ('') NOT NULL,
    [Remarks]       VARCHAR (5000) DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_T0100_EMP_PROBATION_SKILL_DETAIL] PRIMARY KEY CLUSTERED ([Prob_Skill_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_EMP_PROBATION_SKILL_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_EMP_PROBATION_SKILL_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0100_EMP_PROBATION_SKILL_DETAIL_T0095_EMP_PROBATION_MASTER] FOREIGN KEY ([Emp_Prob_ID]) REFERENCES [dbo].[T0095_EMP_PROBATION_MASTER] ([Probation_Evaluation_ID])
);

