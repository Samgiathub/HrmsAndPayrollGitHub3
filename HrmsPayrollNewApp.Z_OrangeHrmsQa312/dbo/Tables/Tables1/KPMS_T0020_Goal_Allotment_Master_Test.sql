CREATE TABLE [dbo].[KPMS_T0020_Goal_Allotment_Master_Test] (
    [Goal_Allot_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           INT           NULL,
    [Goal_Setting_ID]  INT           NULL,
    [GoalSheet_Name]   VARCHAR (300) NULL,
    [Galt_Effect_Date] SMALLDATETIME NULL,
    [Dept_ID]          INT           NULL,
    [Desig_ID]         INT           NULL,
    [Emp_ID]           INT           NULL,
    [User_ID]          INT           NULL,
    [Created_Date]     DATETIME      CONSTRAINT [DF_KPMS_T0020_Goal_Allotment_Master_Test_Created_Date] DEFAULT (getdate()) NULL,
    [Modify_Date]      DATETIME      NULL,
    [IsActive]         INT           CONSTRAINT [DF_KPMS_T0020_Goal_Allotment_Master_Test_IsActive] DEFAULT ((0)) NULL,
    [IsLock]           INT           CONSTRAINT [DF_KPMS_T0020_Goal_Allotment_Master_Test_IsLock] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_KPMS_T0020_Goal_Allotment_Master_Test] PRIMARY KEY CLUSTERED ([Goal_Allot_ID] ASC) WITH (FILLFACTOR = 95)
);

