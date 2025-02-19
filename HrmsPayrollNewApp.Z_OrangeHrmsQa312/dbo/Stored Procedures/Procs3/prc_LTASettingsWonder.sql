-- exec prc_LTASettingsWonder
-- drop proc prc_LTASettingsWonder
CREATE procedure [dbo].[prc_LTASettingsWonder]
as
begin
	declare @tblemps table(tid int identity(1,1),t_EmpId int,t_CmpId int,t_AdId int,t_SalTranId int,t_ReimAmount float,t_ToDate smalldatetime,t_TaxAmt float,t_TaxFreeAmt float,t_AprId int)
	insert into @tblemps
	Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.ReimAmount),mad.to_Date,sum(RD.APP_Tax_Amount),sum(RD.APP_Tax_Free_Amount),RC_Apr_ID
	From T0210_MONTHLY_AD_DETAIL MAD
	INNER JOIN V0100_RC_Application RD ON MAD.AD_ID = RD.RC_ID and MAD.Emp_ID = RD.Emp_ID
	WHERE MAD.Cmp_ID = 1
	and DATEDIFF(day,'2020-04-01',To_Date) >= 0
	and DATEDIFF(day,To_Date,'2021-03-31') >= 0
	and DATEDIFF(day,'2020-04-01',RD.app_date) >= 0
	and DATEDIFF(day,RD.app_date,'2021-03-31') >= 0	
	and MAD.AD_ID = 5	
	and (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1) and Sal_Tran_ID is not null and  mad.ReimAmount > 0
	Group by Mad.Emp_ID,mad.AD_ID,mad.Cmp_ID, mad.To_Date,mad.M_AD_Flag, mad.Sal_Tran_ID,MAD.S_Sal_Tran_ID,RD.RC_Id ,RD.Emp_Id,RD.app_date,RC_Apr_ID

	MERGE T0210_Monthly_Reim_Detail AS TARGET
	USING @tblemps AS SOURCE ON t_EmpId = Emp_Id and t_SalTranId = Sal_tran_ID and t_AdId = RC_ID and t_AprId = RC_apr_ID --and t_ToDate = for_date	
	WHEN MATCHED THEN
		DELETE;
end