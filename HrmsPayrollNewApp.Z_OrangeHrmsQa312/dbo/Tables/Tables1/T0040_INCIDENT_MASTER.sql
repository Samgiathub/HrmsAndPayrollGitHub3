CREATE TABLE [dbo].[T0040_INCIDENT_MASTER] (
    [Incident_Id]        INT           IDENTITY (1, 1) NOT NULL,
    [Cmp_id]             NUMERIC (18)  NULL,
    [Creation_Date]      DATETIME      NULL,
    [Applicable_Date]    DATETIME      NULL,
    [Incident_Name]      VARCHAR (50)  NULL,
    [Incident_Status]    VARCHAR (50)  NULL,
    [Detail_Information] VARCHAR (500) NULL,
    CONSTRAINT [PK_T0040_INCIDENT_MASTER] PRIMARY KEY CLUSTERED ([Incident_Id] ASC) WITH (FILLFACTOR = 95)
);

