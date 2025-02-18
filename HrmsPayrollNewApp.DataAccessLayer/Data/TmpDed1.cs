using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpDed1
{
    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? Advance { get; set; }

    public decimal? AdvanceMiscllDed { get; set; }

    public decimal? ArrearsDeduction { get; set; }

    public decimal? CanteenAmount1 { get; set; }

    public decimal? CanteenPayment { get; set; }

    public decimal? CompanyEsicContirbution { get; set; }

    public decimal? EmployeeEsicContirbution { get; set; }

    public decimal? EmployeePf { get; set; }

    public decimal? EmployeeRetention { get; set; }

    public decimal? ExtraTds { get; set; }

    public decimal? FnfRecovery { get; set; }

    public decimal? FnfTest { get; set; }

    public decimal? MessExpense { get; set; }

    public decimal? MobileBillDeduction { get; set; }

    public decimal? NightShiftAllowance { get; set; }

    public decimal? OtherDeduction { get; set; }

    public decimal? Penalty { get; set; }

    public decimal? Tds { get; set; }

    public decimal? TourDeduction { get; set; }

    public DateTime SalGenerateDate { get; set; }
}
