CREATE TABLE [dbo].[T0200_Question_Exit_Analysis_Master] (
    [Quest_ID]         NUMERIC (18)   NOT NULL,
    [Cmp_ID]           NUMERIC (18)   NOT NULL,
    [Question]         NVARCHAR (MAX) NULL,
    [Question_Type]    NUMERIC (18)   CONSTRAINT [DF_T0200_Question_Exit_Analysis_Master_Question_Type] DEFAULT ((0)) NOT NULL,
    [Question_Options] NVARCHAR (MAX) NULL,
    [Sorting_No]       NUMERIC (18)   CONSTRAINT [DF_T0200_Question_Exit_Analysis_Master_Sorting_No] DEFAULT ((0)) NOT NULL,
    [strDesig_ID]      NVARCHAR (MAX) NULL,
    [AutoAssign]       TINYINT        CONSTRAINT [DF_T0200_Question_Exit_Analysis_Master_AutoAssign] DEFAULT ((0)) NOT NULL,
    [Group_Id]         NUMERIC (18)   CONSTRAINT [DF_T0200_Question_Exit_Analysis_Master_Group_Id] DEFAULT ((0)) NOT NULL
);

