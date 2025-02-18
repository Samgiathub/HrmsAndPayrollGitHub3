using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100NightHaltApplication
{
    public decimal ApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal NoOfDays { get; set; }

    public string? VisitPlace { get; set; }

    public string? Remarks { get; set; }

    public string? AppStatus { get; set; }

    public decimal LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0120NightHaltApproval> T0120NightHaltApprovals { get; set; } = new List<T0120NightHaltApproval>();
}
