CREATE TABLE [dbo].[T0050_CANTEEN_MASTER] (
    [Cmp_Id]         NUMERIC (18)    NOT NULL,
    [Cnt_Id]         NUMERIC (18)    NOT NULL,
    [Cnt_Name]       VARCHAR (50)    NOT NULL,
    [From_Time]      VARCHAR (10)    NULL,
    [To_Time]        VARCHAR (10)    NULL,
    [System_Date]    DATETIME        NULL,
    [Ip_Id]          NUMERIC (18)    NULL,
    [Canteen_Image]  VARCHAR (200)   NULL,
    [Canteen_Group]  INT             NULL,
    [GST_Percentage] NUMERIC (18, 2) NULL,
    [CutOff_Time]    VARCHAR (10)    NULL,
    [Is_Active]      INT             NULL,
    CONSTRAINT [PK_T0050_CANTEEN_MASTER] PRIMARY KEY CLUSTERED ([Cnt_Id] ASC) WITH (FILLFACTOR = 80)
);

