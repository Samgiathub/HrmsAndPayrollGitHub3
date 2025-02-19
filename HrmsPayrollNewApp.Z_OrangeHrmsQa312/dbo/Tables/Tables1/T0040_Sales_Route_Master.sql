CREATE TABLE [dbo].[T0040_Sales_Route_Master] (
    [Route_ID]      INT            NOT NULL,
    [Cmp_ID]        INT            NOT NULL,
    [Route_Name]    NVARCHAR (100) NULL,
    [Route_Type]    VARCHAR (20)   NULL,
    [Is_Active]     TINYINT        NULL,
    [InActive_Date] DATETIME       NULL,
    [Route_Num]     NUMERIC (18)   NULL,
    [Route_Desc]    VARCHAR (500)  NULL,
    CONSTRAINT [PK_T0040_Sales_Route_Master] PRIMARY KEY CLUSTERED ([Route_ID] ASC)
);

