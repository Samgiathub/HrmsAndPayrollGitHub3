CREATE TABLE [dbo].[T0060_Live_Tracking] (
    [LT_Id]                NUMERIC (18)    NOT NULL,
    [Cmp_Id]               NUMERIC (18)    NULL,
    [Emp_Id]               NUMERIC (18)    NULL,
    [Origin_Location]      NVARCHAR (MAX)  NULL,
    [Destination_Location] NVARCHAR (MAX)  NULL,
    [Distance_Km]          NUMERIC (16, 2) NULL,
    [Created_Date]         DATETIME        NULL,
    CONSTRAINT [PK_T0060_Live_Tracking] PRIMARY KEY CLUSTERED ([LT_Id] ASC) WITH (FILLFACTOR = 95)
);

