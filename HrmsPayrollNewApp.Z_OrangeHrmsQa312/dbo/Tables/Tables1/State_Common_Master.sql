CREATE TABLE [dbo].[State_Common_Master] (
    [ID]         INT            NOT NULL,
    [State]      NVARCHAR (100) NOT NULL,
    [District]   NVARCHAR (100) NOT NULL,
    [State_Type] NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_State_Common_Master] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

