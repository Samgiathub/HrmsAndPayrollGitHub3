CREATE TABLE [dbo].[T0040_Task_Category_Master] (
    [Task_Cat_Id]    INT           IDENTITY (1, 1) NOT NULL,
    [tc_Code]        VARCHAR (50)  NULL,
    [tc_Title]       VARCHAR (200) NULL,
    [tc_Status]      INT           CONSTRAINT [DF_tvb_tc_Status] DEFAULT ((1)) NULL,
    [tc_CreatedDate] SMALLDATETIME CONSTRAINT [DF_tvb_tc_CreatedDate] DEFAULT (getdate()) NULL,
    [tc_UpdatedDate] SMALLDATETIME NULL,
    CONSTRAINT [PK_tvb] PRIMARY KEY CLUSTERED ([Task_Cat_Id] ASC)
);

