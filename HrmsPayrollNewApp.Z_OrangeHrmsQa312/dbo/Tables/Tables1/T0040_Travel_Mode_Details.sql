CREATE TABLE [dbo].[T0040_Travel_Mode_Details] (
    [Tran_ID]        NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Travel_Mode_ID] NUMERIC (18) NOT NULL,
    [Desig_ID]       NUMERIC (18) NOT NULL,
    [Modified_Date]  DATETIME     NOT NULL,
    [Cmp_ID]         NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0040_Travel_Mode_Details] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

