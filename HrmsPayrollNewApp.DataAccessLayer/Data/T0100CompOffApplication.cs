using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100CompOffApplication
{
    public decimal CompoffAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public DateTime ExtraWorkDate { get; set; }

    public string ExtraWorkHours { get; set; } = null!;

    public string ApplicationStatus { get; set; } = null!;

    public string ExtraWorkReason { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDatetime { get; set; }

    public string? CompOffType { get; set; }

    public byte OtType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0120CompOffApproval> T0120CompOffApprovals { get; set; } = new List<T0120CompOffApproval>();
}
