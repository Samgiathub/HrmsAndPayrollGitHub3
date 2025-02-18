using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210MonthlySalarySlipGradecount
{
    public decimal TranId { get; set; }

    public decimal SalTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime SalStDate { get; set; }

    public DateTime SalEndDate { get; set; }

    public decimal? ActualDayCount { get; set; }

    public decimal? ActualNightCount { get; set; }

    public decimal? UpgradeDayCount { get; set; }

    public decimal? UpgradeNightCount { get; set; }

    public decimal DayBasicSalary { get; set; }

    public decimal NightBasicSalary { get; set; }

    public decimal? DayBasicDa { get; set; }

    public decimal? NightBasicDa { get; set; }

    public decimal? ClLeave { get; set; }

    public decimal AvgSal { get; set; }

    public decimal GrdOtHours { get; set; }

    public virtual T0200MonthlySalary SalTran { get; set; } = null!;
}
