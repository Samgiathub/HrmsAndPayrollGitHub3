CREATE TABLE [dbo].[T0050_Minimum_Wages_Master] (
    [Wages_ID]       INT             NOT NULL,
    [cmp_Id]         INT             NOT NULL,
    [State_ID]       INT             NOT NULL,
    [SkillType_ID]   INT             NOT NULL,
    [Wages_Value]    NUMERIC (18, 2) CONSTRAINT [DF_T0050_Minimum_Wages_Master_Wages_Value] DEFAULT ((0)) NULL,
    [Effective_Date] DATETIME        NULL,
    CONSTRAINT [PK_T0050_Minimum_Wages_Master] PRIMARY KEY CLUSTERED ([Wages_ID] ASC) WITH (FILLFACTOR = 80)
);

