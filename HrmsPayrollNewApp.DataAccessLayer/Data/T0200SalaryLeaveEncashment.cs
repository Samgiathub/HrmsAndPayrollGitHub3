using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200SalaryLeaveEncashment
{
    public int LeaveEncashId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal SalTranId { get; set; }

    public decimal LDaySalary { get; set; }

    public decimal EncashmentRate { get; set; }

    public decimal EncashmentDays { get; set; }

    public decimal EncashmentAmount { get; set; }

    public decimal LCalEncashDays { get; set; }

    public DateTime MonthStDate { get; set; }

    public DateTime MonthEndDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? LvEncashCalOn { get; set; }

    public decimal? CalAmount { get; set; }

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
