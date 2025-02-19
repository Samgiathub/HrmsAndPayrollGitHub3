CREATE TABLE [dbo].[T0051_HRMS_Recruitment_Setting] (
    [Rec_SettingId]      NUMERIC (18) NOT NULL,
    [RecApplicationId]   NUMERIC (18) NOT NULL,
    [CmpId]              NUMERIC (18) NOT NULL,
    [PostVacancy_CmpId]  NUMERIC (18) NULL,
    [PostVacancy_EmpId]  NUMERIC (18) NULL,
    [Shortlist_CmpId]    NUMERIC (18) NULL,
    [Shortlist_EmpId]    NUMERIC (18) NULL,
    [BusinessHead_CmpId] NUMERIC (18) NULL,
    [BusinessHead_EmpId] NUMERIC (18) NULL,
    [CreatedBy]          NUMERIC (18) NOT NULL,
    [CreatedDate]        DATETIME     NOT NULL,
    CONSTRAINT [PK_T0051_HRMS_Recruitment_Setting] PRIMARY KEY CLUSTERED ([Rec_SettingId] ASC) WITH (FILLFACTOR = 80)
);

