CREATE TABLE [dbo].[T0051_Retaintion_Rate_Details] (
    [RRateDetail_ID] NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [RRate_ID]       NUMERIC (18)    NULL,
    [Grd_ID]         NUMERIC (18)    NULL,
    [Branch_ID]      NUMERIC (18)    NULL,
    [Mode]           VARCHAR (50)    NULL,
    [Amount]         NUMERIC (18, 2) NULL,
    [From_Limit]     NUMERIC (18)    NULL,
    [To_Limit]       NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0051_Retaintion_Rate_Details] PRIMARY KEY CLUSTERED ([RRateDetail_ID] ASC) WITH (FILLFACTOR = 95)
);

