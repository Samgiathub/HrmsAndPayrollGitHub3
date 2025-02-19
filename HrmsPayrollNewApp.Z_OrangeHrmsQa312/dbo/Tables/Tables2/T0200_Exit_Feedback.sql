CREATE TABLE [dbo].[T0200_Exit_Feedback] (
    [exit_feedback_id] NUMERIC (18)  NOT NULL,
    [emp_id]           NUMERIC (18)  NULL,
    [exit_id]          NUMERIC (18)  NULL,
    [cmp_id]           NUMERIC (18)  NULL,
    [question_id]      NUMERIC (18)  NULL,
    [Answer_rate]      NUMERIC (18)  NOT NULL,
    [Comments]         VARCHAR (MAX) NULL,
    [feed_status]      CHAR (1)      NULL,
    [Is_Draft]         TINYINT       CONSTRAINT [DF_T0200_Exit_Feedback_Is_Draft] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0200_Exit_Feedback] PRIMARY KEY CLUSTERED ([exit_feedback_id] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE STATISTICS [Comments]
    ON [dbo].[T0200_Exit_Feedback]([Comments]);

