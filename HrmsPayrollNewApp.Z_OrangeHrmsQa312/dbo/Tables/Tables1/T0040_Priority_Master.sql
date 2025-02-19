CREATE TABLE [dbo].[T0040_Priority_Master] (
    [Priority_Id]    INT           IDENTITY (1, 1) NOT NULL,
    [pm_Code]        VARCHAR (50)  NULL,
    [pm_Title]       VARCHAR (200) NULL,
    [pm_Color]       VARCHAR (20)  NULL,
    [pm_Status]      INT           CONSTRAINT [DF_tbl_PriorityMaster_pm_Status] DEFAULT ((1)) NULL,
    [pm_CreatedDate] SMALLDATETIME CONSTRAINT [DF_tbl_PriorityMaster_pm_CreatedDate] DEFAULT (getdate()) NULL,
    [pm_UpdatedDate] SMALLDATETIME NULL,
    CONSTRAINT [PK_tbl_PriorityMaster] PRIMARY KEY CLUSTERED ([Priority_Id] ASC)
);

