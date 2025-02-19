






CREATE VIEW [dbo].[V0040_NEWS_LETTER_MASTER]
AS
select dbo.T0040_NEWS_LETTER_MASTER.*,
(SELECT     E.Emp_Full_Name + ','
    FROM          T0080_EMP_MASTER E WITH (NOLOCK)
    WHERE      E.Emp_ID IN
           (SELECT     cast(data AS numeric(18, 0))
             FROM          dbo.Split(ISNULL(dbo.T0040_NEWS_LETTER_MASTER.news_announ_for, '0'), '#')
             WHERE      data <> '') FOR XML path(''))Employee_Name
from T0040_NEWS_LETTER_MASTER WITH (NOLOCK)



