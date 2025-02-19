CREATE TABLE [dbo].[Temp_Rate_Slabs_New] (
    [CMP_ID]             NUMERIC (18)    NULL,
    [RRate_ID]           NUMERIC (18)    NULL,
    [amount]             NUMERIC (18, 2) NULL,
    [From_Limit]         NUMERIC (18)    NULL,
    [To_Limit]           NUMERIC (18)    NULL,
    [Mode]               VARCHAR (50)    NULL,
    [Effective_date]     DATETIME        NULL,
    [Effective_FromDate] DATETIME        NULL,
    [Effective_EndDate]  DATETIME        NULL
);

