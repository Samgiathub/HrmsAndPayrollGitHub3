CREATE TABLE [dbo].[T0040_Status_Master] (
    [Status_Id]     INT           IDENTITY (1, 1) NOT NULL,
    [s_Code]        VARCHAR (50)  NULL,
    [s_Title]       VARCHAR (200) NULL,
    [s_Status]      INT           CONSTRAINT [DF_tbl_StatusMaster_s_Status] DEFAULT ((1)) NULL,
    [s_Percentage]  INT           NULL,
    [s_CreatedDate] SMALLDATETIME CONSTRAINT [DF_tbl_StatusMaster_s_CreatedDate] DEFAULT (getdate()) NULL,
    [s_UpdatedDate] SMALLDATETIME NULL,
    [s_IsDefault]   BIT           DEFAULT ((0)) NULL,
    [s_IsFinal]     BIT           DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tbl_StatusMaster] PRIMARY KEY CLUSTERED ([Status_Id] ASC)
);

