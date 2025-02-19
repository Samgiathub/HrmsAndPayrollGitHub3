CREATE TABLE [dbo].[T0050_SurveyMaster] (
    [Survey_ID]            NUMERIC (18)   NOT NULL,
    [Cmp_ID]               NUMERIC (18)   NOT NULL,
    [SurveyStart_Date]     DATETIME       NULL,
    [SurveyEnd_Date]       DATETIME       NULL,
    [Survey_Title]         NVARCHAR (100) NULL,
    [Survey_Purpose]       NVARCHAR (500) NULL,
    [Survey_Instruction]   NVARCHAR (500) NULL,
    [Survey_OpenTill]      DATETIME       NULL,
    [Survey_CreatedBy]     NUMERIC (18)   NULL,
    [Branch_ID]            NUMERIC (18)   NULL,
    [Survey_EmpId]         VARCHAR (MAX)  NULL,
    [Survey_UpdateDate]    DATETIME       NULL,
    [Desig_ID]             VARCHAR (MAX)  NULL,
    [Start_Time]           VARCHAR (10)   DEFAULT ('') NOT NULL,
    [End_Time]             VARCHAR (10)   DEFAULT ('') NOT NULL,
    [Min_Passing_Criteria] INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0050_SurveyMaster] PRIMARY KEY CLUSTERED ([Survey_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_SurveyMaster_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

