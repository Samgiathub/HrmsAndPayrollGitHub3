CREATE TABLE [dbo].[T0051_Rate_Details] (
    [RateDetail_ID] NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Rate_ID]       NUMERIC (18)    NULL,
    [Rate]          NUMERIC (18, 4) NULL,
    [From_Limit]    NUMERIC (18, 4) NULL,
    [To_Limit]      NUMERIC (18, 4) NULL,
    CONSTRAINT [PK_T0051_Rate_Details] PRIMARY KEY CLUSTERED ([RateDetail_ID] ASC)
);

