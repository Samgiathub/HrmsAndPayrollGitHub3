using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LeaveEncashApplication
{
    public decimal LvEncashAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public string LvEncashAppCode { get; set; } = null!;

    public DateTime LvEncashAppDate { get; set; }

    public decimal LvEncashAppDays { get; set; }

    public string LvEncashAppStatus { get; set; } = null!;

    public string LvEncashAppComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public decimal LeaveEncashAmount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;

    public virtual ICollection<T0120LeaveEncashApproval> T0120LeaveEncashApprovals { get; set; } = new List<T0120LeaveEncashApproval>();
}
