CREATE VIEW [dbo].[V0100_Employee_ESOP_Master]
AS
	 SELECT 
	 Tran_Id,EffectiveDate,MarketPrice,EmployeePrice,MonthWiseLockingPeriod,Cmp_Id
	 FROM T0020_ESOP_SharePrice_Master E 
