CREATE TABLE [dbo].[T0040_Task_Activity_Master] (
    [Activity_Id]    INT           IDENTITY (1, 1) NOT NULL,
    [am_Code]        VARCHAR (50)  NULL,
    [am_Title]       VARCHAR (200) NULL,
    [am_Status]      INT           CONSTRAINT [DF_T0040_Task_Activity_Master_am_Status] DEFAULT ((1)) NULL,
    [am_CreatedDate] SMALLDATETIME CONSTRAINT [DF_T0040_Task_Activity_Master_am_CreatedDate] DEFAULT (getdate()) NULL,
    [am_UpdatedDate] SMALLDATETIME NULL,
    CONSTRAINT [PK_T0040_Task_Activity_Master] PRIMARY KEY CLUSTERED ([Activity_Id] ASC)
);

