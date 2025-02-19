CREATE TABLE [dbo].[KPMS_T0100_Goal_Setting_WithoutDepe] (
    [GS_Id]              INT           IDENTITY (1, 1) NOT NULL,
    [GS_SheetName]       VARCHAR (300) NULL,
    [GS_FromDate]        SMALLDATETIME NULL,
    [GS_ToDate]          SMALLDATETIME NULL,
    [GS_WeightageTypeId] INT           NULL,
    [GS_WeightageValue]  INT           NULL,
    [GS_StatusId]        INT           NULL,
    [GS_CreatedDate]     SMALLDATETIME NULL,
    [GS_UpdatedDate]     SMALLDATETIME NULL,
    [Cmp_Id]             INT           NULL,
    [IsLock]             INT           NULL,
    [IsDraft]            BIT           NULL
);

