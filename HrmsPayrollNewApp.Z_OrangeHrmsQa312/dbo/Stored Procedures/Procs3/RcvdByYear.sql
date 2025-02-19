CREATE PROCEDURE RcvdByYear
@MCode VARCHAR(20),
@year VARCHAR(10)

AS
BEGIN
SET NOCOUNT ON


SELECT datename(month,RcvDate) As Month, SUM(Accepted) AS Quantity, SUM(TotalValue) AS Value from ReceiptItems WHERE (right(YEAR(DATEADD(month, DATEDIFF(month, 0, RcvDate) -3, 0)),2) = @year)
and ReceiptItems.Code = @MCode
GROUP BY DATENAME(month, RcvDate), DATEPART( month, RcvDate )
Order by DATEPART(month, RcvDate)

END
