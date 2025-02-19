CREATE TABLE [dbo].[T0040_Setting_Mandatory_Fields] (
    [Tran_ID]              NUMERIC (18)  NULL,
    [Cmp_ID]               NUMERIC (18)  NULL,
    [Module_Name]          VARCHAR (100) NULL,
    [Fields_Name]          VARCHAR (100) NULL,
    [Is_Mandatory]         BIT           NULL,
    [Modify_Date]          DATETIME      NULL,
    [Modify_By]            NUMERIC (18)  NULL,
    [IP_Address]           VARCHAR (20)  NULL,
    [Control_Display_Name] VARCHAR (200) NULL,
    [DB_Control_ID]        VARCHAR (100) NULL
);

