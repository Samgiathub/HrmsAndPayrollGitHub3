﻿CREATE TABLE [dbo].[T0040_HRMS_KPAType_Master] (
    [KPA_Type_Id] NUMERIC (18)   NOT NULL,
    [Cmp_ID]      NUMERIC (18)   NOT NULL,
    [KPA_Type]    NVARCHAR (100) NULL,
    CONSTRAINT [PK_T0040_HRMS_KPAType_Master] PRIMARY KEY CLUSTERED ([KPA_Type_Id] ASC) WITH (FILLFACTOR = 80)
);

