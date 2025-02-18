﻿CREATE TABLE [dbo].[T0052_Hrms_RecruitmentRequest_Approval] (
    [RecApp_Id]            NUMERIC (18)    NOT NULL,
    [Cmp_Id]               NUMERIC (18)    NOT NULL,
    [Rec_Req_ID]           NUMERIC (18)    NULL,
    [Approver_EmpId]       NUMERIC (18)    NULL,
    [Is_Final]             INT             NULL,
    [Approved_Date]        DATETIME        NULL,
    [RecApp_Status]        INT             NULL,
    [Rpt_Level]            INT             NULL,
    [Job_Title]            VARCHAR (50)    NULL,
    [Grade_Id]             NUMERIC (18)    NULL,
    [Desig_Id]             NUMERIC (18)    NULL,
    [Branch_Id]            NUMERIC (18)    NULL,
    [Type_Id]              NUMERIC (18)    NULL,
    [Dept_Id]              NUMERIC (18)    NULL,
    [Skill_detail]         NVARCHAR (1000) NULL,
    [Job_Description]      NVARCHAR (1000) NULL,
    [No_of_vacancies]      NUMERIC (3)     NULL,
    [Qualification_detail] VARCHAR (500)   NULL,
    [Experience_Detail]    VARCHAR (500)   NULL,
    [BusinessSegment_Id]   NUMERIC (18)    NULL,
    [Vertical_Id]          NUMERIC (18)    NULL,
    [SubVertical_Id]       NUMERIC (18)    NULL,
    [Type_Of_Opening]      NUMERIC (18)    NULL,
    [JD_CodeId]            NUMERIC (18)    NULL,
    [Budgeted]             BIT             NULL,
    [Exp_Min]              FLOAT (53)      NULL,
    [Exp_Max]              FLOAT (53)      NULL,
    [Rep_EmployeeId]       VARCHAR (MAX)   NULL,
    [Justification]        VARCHAR (1000)  DEFAULT ('') NOT NULL,
    [CTC_Budget]           NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Is_Left_ReplaceEmpId] BIT             DEFAULT ((0)) NOT NULL,
    [Comments]             VARCHAR (1000)  DEFAULT ('') NOT NULL,
    [Attach_Doc]           VARCHAR (2000)  NULL,
    [Document_ID]          VARCHAR (250)   DEFAULT ('') NOT NULL,
    [Experience_Type]      INT             NULL,
    [MIN_CTC_Budget]       NUMERIC (18, 2) NULL,
    [Category_ID]          INT             NULL,
    CONSTRAINT [PK_T0052_Hrms_RecruitmentRequest_Approval] PRIMARY KEY CLUSTERED ([RecApp_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_Id]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0040_Business_Segment] FOREIGN KEY ([BusinessSegment_Id]) REFERENCES [dbo].[T0040_Business_Segment] ([Segment_ID]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0040_DEPARTMENT_MASTER] FOREIGN KEY ([Dept_Id]) REFERENCES [dbo].[T0040_DEPARTMENT_MASTER] ([Dept_Id]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0040_DESIGNATION_MASTER] FOREIGN KEY ([Desig_Id]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0040_GRADE_MASTER] FOREIGN KEY ([Grade_Id]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0040_TYPE_MASTER] FOREIGN KEY ([Type_Id]) REFERENCES [dbo].[T0040_TYPE_MASTER] ([Type_ID]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0040_Vertical_Segment] FOREIGN KEY ([Vertical_Id]) REFERENCES [dbo].[T0040_Vertical_Segment] ([Vertical_ID]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0050_HRMS_Recruitment_Request] FOREIGN KEY ([Rec_Req_ID]) REFERENCES [dbo].[T0050_HRMS_Recruitment_Request] ([Rec_Req_ID]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0050_JobDescription_Master] FOREIGN KEY ([JD_CodeId]) REFERENCES [dbo].[T0050_JobDescription_Master] ([Job_Id]),
    CONSTRAINT [FK_T0052_Hrms_RecruitmentRequest_Approval_T0050_SubVertical] FOREIGN KEY ([SubVertical_Id]) REFERENCES [dbo].[T0050_SubVertical] ([SubVertical_ID])
);

