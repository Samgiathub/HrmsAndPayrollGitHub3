CREATE TABLE [dbo].[T0040_Task_Project_Master] (
    [Project_Id]     INT           IDENTITY (1, 1) NOT NULL,
    [pr_Code]        VARCHAR (50)  NULL,
    [pr_Title]       VARCHAR (200) NULL,
    [pr_Status]      INT           CONSTRAINT [DF_T0040_Task_Project_Master_pr_Status] DEFAULT ((1)) NULL,
    [pr_CreatedDate] SMALLDATETIME CONSTRAINT [DF_T0040_Task_Project_Master_pr_CreatedDate] DEFAULT (getdate()) NULL,
    [pr_UpdatedDate] SMALLDATETIME NULL,
    CONSTRAINT [PK_T0040_Task_Project_Master] PRIMARY KEY CLUSTERED ([Project_Id] ASC)
);

