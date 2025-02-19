CREATE TABLE [dbo].[T0040_HRMS_Appraisal_SignoffSetting_Master] (
    [Setting_Id]          NUMERIC (18) NOT NULL,
    [Setting_CmpId]       NUMERIC (18) NOT NULL,
    [Setting_EmpId]       NUMERIC (18) NOT NULL,
    [Setting_Type]        NUMERIC (18) NOT NULL,
    [Setting_Year]        NUMERIC (18) NOT NULL,
    [Setting_FromDate]    DATETIME     NOT NULL,
    [Setting_ToDate]      DATETIME     NOT NULL,
    [Setting_CreatedBy]   NUMERIC (18) NOT NULL,
    [Setting_CreatedDate] DATETIME     NOT NULL,
    [Setting_ModifyBy]    NUMERIC (18) NULL,
    [Setting_ModifyDate]  DATETIME     NULL,
    CONSTRAINT [PK_T0040_HRMS_Appraisal_SignoffSetting_Master] PRIMARY KEY CLUSTERED ([Setting_Id] ASC) WITH (FILLFACTOR = 80)
);

