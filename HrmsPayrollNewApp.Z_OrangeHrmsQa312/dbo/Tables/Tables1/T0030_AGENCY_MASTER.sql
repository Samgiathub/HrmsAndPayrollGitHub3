CREATE TABLE [dbo].[T0030_AGENCY_MASTER] (
    [Agency_ID]      NUMERIC (18)  NOT NULL,
    [State_ID]       NUMERIC (18)  NOT NULL,
    [Agency_Name]    VARCHAR (100) NOT NULL,
    [Agency_City]    VARCHAR (50)  NULL,
    [Agency_Address] VARCHAR (200) NULL,
    [Agency_phone]   VARCHAR (50)  NOT NULL,
    [Agency_mobile]  VARCHAR (50)  NULL,
    [Comment]        VARCHAR (250) NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    CONSTRAINT [PK_T0030_AGENCY_MASTER] PRIMARY KEY CLUSTERED ([Agency_ID] ASC) WITH (FILLFACTOR = 80)
);

