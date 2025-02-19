CREATE TABLE [dbo].[T0350_Exit_Clearance_Status] (
    [Status_ID] NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]    NUMERIC (18) CONSTRAINT [DF_T0350_Exit_Clearance_Status_Cmp_ID] DEFAULT ((0)) NOT NULL,
    [Status]    VARCHAR (50) NOT NULL
);

