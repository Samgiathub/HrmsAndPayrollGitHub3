CREATE TABLE [dbo].[T0060_HRMS_EmployeeReward] (
    [EmpReward_Id]      NUMERIC (18)   NOT NULL,
    [Cmp_Id]            NUMERIC (18)   NOT NULL,
    [From_Date]         DATETIME       NULL,
    [To_Date]           DATETIME       NULL,
    [Employee_Id]       VARCHAR (500)  NULL,
    [Type]              INT            NULL,
    [RewardValues_Id]   VARCHAR (500)  NULL,
    [EmpReward_Rating]  INT            NULL,
    [Awards_Id]         NUMERIC (18)   NULL,
    [comments]          NVARCHAR (500) NULL,
    [Reward_Attachment] VARCHAR (200)  NULL,
    CONSTRAINT [PK_T0060_HRMS_EmployeeReward] PRIMARY KEY CLUSTERED ([EmpReward_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0060_HRMS_EmployeeReward_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0060_HRMS_EmployeeReward_T0040_HRMS_AwardMaster] FOREIGN KEY ([Awards_Id]) REFERENCES [dbo].[T0040_HRMS_AwardMaster] ([Awards_Id])
);

