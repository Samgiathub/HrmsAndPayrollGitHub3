using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0135LeaveCancelation
{
    public decimal LvCanTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveApprovalId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal LeavePeriod { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public decimal LvCanDay { get; set; }

    public decimal LvCanStatus { get; set; }

    public string LvCanComments { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;

    public virtual T0120LeaveApproval LeaveApproval { get; set; } = null!;
}
