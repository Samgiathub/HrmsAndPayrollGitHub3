CREATE TABLE [dbo].[T0030_Appraisal_OtherDetails] (
    [AO_Id]              NUMERIC (18)  NOT NULL,
    [Cmp_ID]             NUMERIC (18)  NOT NULL,
    [Action]             VARCHAR (MAX) NULL,
    [Desig_Required]     INT           NULL,
    [From_Date_Required] INT           NULL,
    [To_Date_Required]   INT           NULL,
    [Active]             INT           NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T0030_Appraisal_OtherDetails_Cmp_ID_AO_Id]
    ON [dbo].[T0030_Appraisal_OtherDetails]([Cmp_ID] ASC, [AO_Id] ASC);

