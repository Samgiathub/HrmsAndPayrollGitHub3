CREATE TABLE [dbo].[KPMS_T0020_Goal_Allotment_Master] (
    [Cmp_ID]           INT           NOT NULL,
    [GoalAlt_ID]       INT           IDENTITY (1, 1) NOT NULL,
    [GoalSheet_Name]   VARCHAR (300) NOT NULL,
    [Galt_Effect_Date] DATETIME      NOT NULL,
    [Galt_Dept_Name]   VARCHAR (300) NOT NULL,
    [Galt_Desig_Name]  VARCHAR (300) NOT NULL,
    [Galt_Emp_Name]    VARCHAR (300) NOT NULL,
    [Galt_Status_Name] VARCHAR (300) NOT NULL,
    [User_ID]          INT           NOT NULL,
    [Created_Date]     DATETIME      CONSTRAINT [DF_KPMS_T0020_Goal_Allotment_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Modify_Date]      DATETIME      NULL,
    CONSTRAINT [PK_KPMS_T0020_Goal_Allotment_Master] PRIMARY KEY CLUSTERED ([GoalAlt_ID] ASC) WITH (FILLFACTOR = 95)
);

