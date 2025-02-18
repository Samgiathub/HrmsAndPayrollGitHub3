using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210MonthlyLeaveDetail
{
    public decimal MLeaveTranId { get; set; }

    public decimal? TempSalTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal? SalTranId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LeaveDays { get; set; }

    public string? LeaveType { get; set; }

    public string? LeavePaidUnpaid { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
