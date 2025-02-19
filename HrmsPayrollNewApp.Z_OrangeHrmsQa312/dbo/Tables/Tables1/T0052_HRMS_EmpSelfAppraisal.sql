CREATE TABLE [dbo].[T0052_HRMS_EmpSelfAppraisal] (
    [ESA_ID]          NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [Emp_ID]          NUMERIC (18)    NOT NULL,
    [InitiateId]      NUMERIC (18)    NOT NULL,
    [SApparisal_ID]   NUMERIC (18)    NOT NULL,
    [Emp_Weightage]   NUMERIC (18, 2) NOT NULL,
    [Emp_Rating]      NUMERIC (18, 2) NOT NULL,
    [Final_Emp_Score] NUMERIC (18, 2) NOT NULL,
    [RM_Weightage]    NUMERIC (18, 2) NULL,
    [RM_Rating]       NUMERIC (18, 2) NULL,
    [Final_RM_Score]  NUMERIC (18, 2) NULL,
    [RM_Comments]     VARCHAR (MAX)   NULL,
    [HOD_Weightage]   NUMERIC (18, 2) NULL,
    [HOD_Rating]      NUMERIC (18, 2) NULL,
    [Final_HOD_Score] NUMERIC (18, 2) NULL,
    [HOD_Comments]    VARCHAR (MAX)   NULL,
    [GH_Weightage]    NUMERIC (18, 2) NULL,
    [GH_Rating]       NUMERIC (18, 2) NULL,
    [Final_GH_Score]  NUMERIC (18, 2) NULL,
    [GH_Comments]     VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_T0052_HRMS_EmpSelfAppraisal] PRIMARY KEY CLUSTERED ([ESA_ID] ASC)
);

