CREATE TABLE [dbo].[T0110_Task_Images] (
    [Task_Image_Id]    INT           IDENTITY (1, 1) NOT NULL,
    [Task_Id]          INT           NULL,
    [Task_FileName]    VARCHAR (300) NULL,
    [Task_FileNameStr] VARCHAR (300) NULL,
    CONSTRAINT [PK_T0110_Task_Images] PRIMARY KEY CLUSTERED ([Task_Image_Id] ASC)
);

