CREATE TABLE [dbo].[KPMS_T0100_Goal_Setting] (
    [GS_Id]              INT           IDENTITY (1, 1) NOT NULL,
    [GS_SheetName]       VARCHAR (300) NULL,
    [GS_FromDate]        SMALLDATETIME NULL,
    [GS_ToDate]          SMALLDATETIME NULL,
    [GS_WeightageTypeId] INT           NULL,
    [GS_WeightageValue]  INT           NULL,
    [GS_StatusId]        INT           NULL,
    [GS_CreatedDate]     SMALLDATETIME CONSTRAINT [DF_KPMS_T0100_Goal_Setting_GS_CreatedDate] DEFAULT (getdate()) NULL,
    [GS_UpdatedDate]     SMALLDATETIME NULL,
    [Cmp_Id]             INT           NULL,
    [IsLock]             INT           CONSTRAINT [DF_KPMS_T0100_Goal_Setting_IsLock] DEFAULT ((0)) NULL,
    [IsDraft]            BIT           NULL,
    CONSTRAINT [PK_KPMS_T0100_Goal_Setting] PRIMARY KEY CLUSTERED ([GS_Id] ASC) WITH (FILLFACTOR = 95)
);

