using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0201MonthlySalarySett
{
    public decimal SSalTranId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal SSalReceiptNo { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IncrementId { get; set; }

    public DateTime SMonthStDate { get; set; }

    public DateTime SMonthEndDate { get; set; }

    public DateTime SSalGenerateDate { get; set; }

    public decimal SSalCalDays { get; set; }

    public decimal? SWorkingDays { get; set; }

    public decimal? SOutofDays { get; set; }

    public decimal? SOtHours { get; set; }

    public decimal? SShiftDaySec { get; set; }

    public string? SShiftDayHour { get; set; }

    public decimal? SBasicSalary { get; set; }

    public decimal? SDaySalary { get; set; }

    public decimal? SHourSalary { get; set; }

    public decimal? SSalaryAmount { get; set; }

    public decimal? SAllowAmount { get; set; }

    public decimal? SOtAmount { get; set; }

    public decimal? SOtherAllowAmount { get; set; }

    public decimal? SGrossSalary { get; set; }

    public decimal? SDeduAmount { get; set; }

    public decimal? SLoanAmount { get; set; }

    public decimal? SLoanIntrestAmount { get; set; }

    public decimal? SAdvanceAmount { get; set; }

    public decimal? SOtherDeduAmount { get; set; }

    public decimal? STotalDeduAmount { get; set; }

    public decimal? SDueLoanAmount { get; set; }

    public decimal? SNetAmount { get; set; }

    public decimal? SActuallyGrossSalary { get; set; }

    public decimal? SPtAmount { get; set; }

    public decimal? SPtCalculatedAmount { get; set; }

    public decimal? STotalClaimAmount { get; set; }

    public decimal? SMOtHours { get; set; }

    public decimal? SMAdvAmount { get; set; }

    public decimal? SMLoanAmount { get; set; }

    public decimal? SMItTax { get; set; }

    public decimal? SLwfAmount { get; set; }

    public decimal? SRevenueAmount { get; set; }

    public string? SPtFTLimit { get; set; }

    public string? SSalType { get; set; }

    public DateTime SEffDate { get; set; }

    public decimal LoginId { get; set; }

    public DateTime ModifyDate { get; set; }

    public decimal? SMPresentDays { get; set; }

    public decimal? SWoOtHours { get; set; }

    public decimal? SHoOtHours { get; set; }

    public decimal SWoOtAmount { get; set; }

    public decimal SHoOtAmount { get; set; }

    public byte EffectOnSalary { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095Increment Increment { get; set; } = null!;

    public virtual T0200MonthlySalary? SalTran { get; set; }

    public virtual ICollection<T0210LtaMedicalPayment> T0210LtaMedicalPayments { get; set; } = new List<T0210LtaMedicalPayment>();

    public virtual ICollection<T0210MonthlyAdDetailDaily> T0210MonthlyAdDetailDailies { get; set; } = new List<T0210MonthlyAdDetailDaily>();

    public virtual ICollection<T0210MonthlyAdDetail> T0210MonthlyAdDetails { get; set; } = new List<T0210MonthlyAdDetail>();

    public virtual ICollection<T0210MonthlyLoanPayment> T0210MonthlyLoanPayments { get; set; } = new List<T0210MonthlyLoanPayment>();
}
