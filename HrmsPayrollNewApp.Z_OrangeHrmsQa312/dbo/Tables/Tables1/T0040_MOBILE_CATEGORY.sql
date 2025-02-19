CREATE TABLE [dbo].[T0040_MOBILE_CATEGORY] (
    [Mobile_Cat_ID]     NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]            NUMERIC (18)  NOT NULL,
    [Mobile_Cat_Name]   VARCHAR (100) NULL,
    [ParentCategory_ID] NUMERIC (18)  NULL,
    [System_Date]       DATETIME      NULL,
    [Login_ID]          NUMERIC (18)  NULL,
    [Is_Active]         TINYINT       DEFAULT ((0)) NOT NULL,
    [Effective_Date]    DATETIME      DEFAULT ('') NOT NULL,
    [Sale_Active]       TINYINT       NULL,
    [Stock_Active]      TINYINT       NULL,
    PRIMARY KEY CLUSTERED ([Mobile_Cat_ID] ASC) WITH (FILLFACTOR = 95)
);

