CREATE TABLE [dbo].[T0040_HRMS_Appraisal_Rating_Master] (
    [Rating_Id]          NUMERIC (18) NOT NULL,
    [Rating_CmpId]       NUMERIC (18) NOT NULL,
    [Rating]             VARCHAR (50) NOT NULL,
    [Rating_IsActive]    TINYINT      NOT NULL,
    [Rating_CreatedBy]   NUMERIC (18) NOT NULL,
    [Rating_CreatedDate] DATETIME     NOT NULL,
    [Rating_ModifyBy]    NUMERIC (18) NULL,
    [Rating_ModifyDate]  DATETIME     NULL,
    CONSTRAINT [PK_T0040_HRMS_NewAppraisal_RatingMaster] PRIMARY KEY CLUSTERED ([Rating_Id] ASC) WITH (FILLFACTOR = 80)
);

