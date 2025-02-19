CREATE TABLE [dbo].[T0110_Travel_Application_Other_Detail] (
    [Travel_App_Other_Detail_Id] NUMERIC (18)    NOT NULL,
    [Cmp_ID]                     NUMERIC (18)    NOT NULL,
    [Travel_App_ID]              NUMERIC (18)    NOT NULL,
    [Travel_Mode_Id]             NUMERIC (18)    NOT NULL,
    [For_date]                   DATETIME        NOT NULL,
    [Description]                VARCHAR (MAX)   NULL,
    [Amount]                     NUMERIC (18, 2) NULL,
    [Self_Pay]                   TINYINT         DEFAULT ((0)) NOT NULL,
    [modify_Date]                DATETIME        CONSTRAINT [DF_T0110_Travel_Application_Other_Detail_modify_Date] DEFAULT (getdate()) NULL,
    [To_Date]                    DATETIME        NULL,
    [Curr_ID]                    NUMERIC (18)    DEFAULT (NULL) NULL,
    [SGST]                       NUMERIC (18, 2) CONSTRAINT [DF_T0110_Travel_Application_Other_Detail_SGST] DEFAULT ((0)) NOT NULL,
    [CGST]                       NUMERIC (18, 2) CONSTRAINT [DF_T0110_Travel_Application_Other_Detail_CGST] DEFAULT ((0)) NOT NULL,
    [IGST]                       NUMERIC (18, 2) CONSTRAINT [DF_T0110_Travel_Application_Other_Detail_IGST] DEFAULT ((0)) NOT NULL,
    [GST_No]                     NVARCHAR (50)   NULL,
    [GST_Company_Name]           NVARCHAR (250)  NULL,
    [Mode_ID]                    NUMERIC (18)    NULL
);

