CREATE TABLE [dbo].[T0040_HRMS_Appraisal_SOL_Master] (
    [SOL_Id]          NUMERIC (18)  NOT NULL,
    [SOL_CmpId]       NUMERIC (18)  NOT NULL,
    [SOL]             VARCHAR (400) NOT NULL,
    [SOL_IsActive]    TINYINT       NOT NULL,
    [SOL_CreatedBy]   NUMERIC (18)  NOT NULL,
    [SOL_CreatedDate] DATETIME      NOT NULL,
    [SOL_ModifyBy]    NUMERIC (18)  NULL,
    [SOL_ModifyDate]  DATETIME      NULL,
    CONSTRAINT [PK_T0040_HRMS_Appraisal_SOL_Master] PRIMARY KEY CLUSTERED ([SOL_Id] ASC) WITH (FILLFACTOR = 80)
);

