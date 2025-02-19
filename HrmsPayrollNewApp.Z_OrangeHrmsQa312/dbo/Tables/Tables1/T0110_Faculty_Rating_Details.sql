CREATE TABLE [dbo].[T0110_Faculty_Rating_Details] (
    [Faculty_Rating_Id] NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Training_Apr_ID]   NUMERIC (18)    NOT NULL,
    [Faculty_ID]        NUMERIC (18)    NOT NULL,
    [Rating]            NUMERIC (18, 2) NOT NULL,
    [comments]          VARCHAR (500)   NULL,
    CONSTRAINT [PK_T0110_Faculty_Rating_Details] PRIMARY KEY CLUSTERED ([Faculty_Rating_Id] ASC)
);

