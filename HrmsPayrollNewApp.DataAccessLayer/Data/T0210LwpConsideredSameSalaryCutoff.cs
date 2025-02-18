using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210LwpConsideredSameSalaryCutoff
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SalTranId { get; set; }

    public decimal LeaveApprovalId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal LeavePeriod { get; set; }

    public DateTime ForDate { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0120LeaveApproval LeaveApproval { get; set; } = null!;

    public virtual T0200MonthlySalary SalTran { get; set; } = null!;
}
