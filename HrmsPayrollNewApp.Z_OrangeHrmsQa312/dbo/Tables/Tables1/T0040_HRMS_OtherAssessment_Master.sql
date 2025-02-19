CREATE TABLE [dbo].[T0040_HRMS_OtherAssessment_Master] (
    [OA_Id]    NUMERIC (18)   NOT NULL,
    [Cmp_ID]   NUMERIC (18)   NOT NULL,
    [OA_Title] NVARCHAR (100) NULL,
    [OA_Sort]  INT            NULL,
    CONSTRAINT [PK_T0040_HRMS_OtherAssessment_Master] PRIMARY KEY CLUSTERED ([OA_Id] ASC) WITH (FILLFACTOR = 80)
);

