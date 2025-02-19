CREATE TABLE [dbo].[SMS_Template] (
    [Temp_ID]   VARCHAR (50)  NOT NULL,
    [Temp_Name] VARCHAR (50)  NULL,
    [Temp_Type] VARCHAR (50)  NULL,
    [Header]    VARCHAR (50)  NULL,
    [Message]   VARCHAR (500) NULL,
    [Entity_ID] VARCHAR (50)  NULL,
    CONSTRAINT [PK_SMS_Template] PRIMARY KEY CLUSTERED ([Temp_ID] ASC) WITH (FILLFACTOR = 95)
);

