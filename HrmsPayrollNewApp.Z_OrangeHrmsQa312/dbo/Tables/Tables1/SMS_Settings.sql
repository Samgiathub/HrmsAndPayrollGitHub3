CREATE TABLE [dbo].[SMS_Settings] (
    [SMS_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [Send_SMS]  BIT           NULL,
    [SMS_URL]   VARCHAR (150) NULL,
    [URLData]   VARCHAR (200) NOT NULL,
    [User_Name] VARCHAR (50)  NULL,
    [Password]  VARCHAR (50)  NULL,
    [API_key]   VARCHAR (50)  NULL,
    [Sender_ID] VARCHAR (50)  NULL,
    [Msg_Type]  VARCHAR (50)  NULL,
    [Response]  VARCHAR (50)  NULL,
    [Header_ID] VARCHAR (50)  NULL,
    [Entity_ID] VARCHAR (50)  NULL,
    [Temp_ID]   VARCHAR (50)  NULL,
    [Message]   VARCHAR (500) NULL,
    CONSTRAINT [PK_SMS_Settings] PRIMARY KEY CLUSTERED ([SMS_ID] ASC) WITH (FILLFACTOR = 95)
);

