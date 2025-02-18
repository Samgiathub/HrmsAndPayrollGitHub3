using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100GatePassApplication
{
    public decimal AppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime AppDate { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime FromTime { get; set; }

    public DateTime ToTime { get; set; }

    public string Duration { get; set; } = null!;

    public decimal ReasonId { get; set; }

    public string? Remarks { get; set; }

    public decimal? AppUserId { get; set; }

    public DateTime? SystemDatetime { get; set; }

    public string? AppStatus { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0115GatePassLevelApproval> T0115GatePassLevelApprovals { get; set; } = new List<T0115GatePassLevelApproval>();

    public virtual ICollection<T0120GatePassApproval> T0120GatePassApprovals { get; set; } = new List<T0120GatePassApproval>();
}
