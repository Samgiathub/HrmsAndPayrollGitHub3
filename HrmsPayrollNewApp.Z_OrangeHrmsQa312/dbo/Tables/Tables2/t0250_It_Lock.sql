CREATE TABLE [dbo].[t0250_It_Lock] (
    [Lock_ID]        NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [Financial_Year] NVARCHAR (50) NULL,
    [Is_Lock]        TINYINT       NULL,
    CONSTRAINT [PK_t0250_It_Lock] PRIMARY KEY CLUSTERED ([Lock_ID] ASC) WITH (FILLFACTOR = 80)
);

