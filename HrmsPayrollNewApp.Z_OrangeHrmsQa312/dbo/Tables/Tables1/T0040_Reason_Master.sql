CREATE TABLE [dbo].[T0040_Reason_Master] (
    [Res_Id]         INT           NOT NULL,
    [Reason_Name]    VARCHAR (100) NULL,
    [Isactive]       TINYINT       NULL,
    [Type]           VARCHAR (10)  NULL,
    [Gate_Pass_Type] VARCHAR (10)  NULL,
    [Is_Mandatory]   TINYINT       CONSTRAINT [DF_T0040_Reason_Master_Is_Mandatory] DEFAULT ((0)) NOT NULL,
    [Is_Default]     BIT           DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0040_Reason_Master] PRIMARY KEY CLUSTERED ([Res_Id] ASC) WITH (FILLFACTOR = 80)
);

