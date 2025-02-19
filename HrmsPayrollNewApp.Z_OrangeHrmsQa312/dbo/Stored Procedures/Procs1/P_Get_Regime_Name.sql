
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P_Get_Regime_Name]	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	create table #Regime (
		Regime varchar(50)
		,Regime_Val varchar(50)
	)
	
	insert INTO #Regime (Regime,Regime_Val) VALUES(' -- Select -- ','0')
	insert INTO #Regime (Regime,Regime_Val) VALUES('Old Regime','Tax Regime 1')
	insert INTO #Regime (Regime,Regime_Val) VALUES('New Regime','Tax Regime 2')
	
	
	Select * from #Regime
	DROP table #Regime
end